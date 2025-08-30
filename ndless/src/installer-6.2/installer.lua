platform.apilevel = "2.7"

require "physics"

---------
-- IPC --
---------

-- ZZZ_IPC_LUA_ZZZ

----------------------
-- helper functions --
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


function pointerToHex(ptr)
    return string.format("0x%x", ptr)
end

function pointerToBin(ptr)
    return string.pack("u32", ptr % 0x100000000)
end

function getPointer(obj)
    return tonumber(tostring(obj):match(": .+"):sub(3), 16)
end

-------------------------------------------------------
-- helper functions to spray heap at certain address --
-------------------------------------------------------

heap = {}
heapString = ""

function allocateBigItems(n)
    n = n or 10
    local space
    for i=1, n do
        space = physics.Space()
        table.insert(_G.heap, space)
    end
    return getPointer(space)
end

function allocateSmallItems(n)
    n = n or 100
    local tbl
    for i=1, n do
        tbl = physics.Vect(0,0)
        table.insert(_G.heap, tbl)
    end
    return getPointer(tbl)
end

local BLOCK_SIZE = 512
function sprayHeap(target, val)
    local vLen = val:len()

    local currentHeapOffset = 0

    -- fill up the heap as much as possible until we are close
    while (currentHeapOffset + 0x30000) < target do
        currentHeapOffset = allocateBigItems(10)
    end

    -- fill up small spaces in heap with tables
    currentHeapOffset = 0
    while (currentHeapOffset + 0x30000) < target do
        currentHeapOffset = allocateSmallItems(10)
    end

    if (currentHeapOffset > target) then
        return false
    end

    local blockc  = math.floor(BLOCK_SIZE / vLen)
    while currentHeapOffset < target do
        heapString = heapString .. val:rep(blockc)
        currentHeapOffset = allocateSmallItems(1)
    end

    return true
end

function resetHeap()
    heap = {}
    heapString = ""

    collectgarbage("collect")
end

--------------------
-- Payload loader --
--------------------

function makeExecutableSpace(payload)
    local space       = physics.Space()
    local payload_tbl = { payload }

    -- keep in global mem to avoid gc
    _G.exec_payload_tbl = payload_tbl
    _G.exec_space       = space


    local p_tbl = (getPointer(payload_tbl) + 12) % 0x100000000 -- this points to the array portion of the lua table

    --[[
        ldr r0, ptr         Load the array pointer in mem
        ldr r0, [r0]        Dereference the array pointer to get the pointer to the first entry
        ldr r0, [r0]        Dereference the first entry pointer to get the TString ptr
        add r0, r0, #16     Add 16 to TString pointer to get string content
        bx r0               Jump to string content
    --]]

    local a,b,c,d = string.unpack("s32s32flfl","\12\0\159\229\0\0\144\229\0\0\144\229\16\0\128\226\16\255\47\225" .. pointerToBin(p_tbl))

    function apply()
        space:setIterations(a)
        space:setElasticIterations(b)
        space:setGravity(physics.Vect(c, d))
    end

    apply()

    local ptr  = getPointer(space)
    local hptr = pointerToHex(ptr)
    local bptr = pointerToBin(ptr)

    return {
        ptr = ptr,
        bptr = bptr,
        pretty_ptr = hptr
    }, apply
end


----------------------------
-- the payload to execute --
----------------------------

--ZZZ_INSTALLER_PAYLOAD_ZZZ

------------------------
-- exploit: exec addr --
------------------------

local execState = ""

function exec(addr, beforeExecHook)
    if type(addr) == "number" then
        addr = pointerToBin(addr)
    end

    local deviceType = getDeviceType()

    local structSize = 4
    local offsetTable = {
        cx2 = {
            offset = 0x000006ac,
            target = 0x13A00000 -- at location 0x0000_006ac in memory we have value 0x13A00000
        },
        cxw = {
            offset = 0x0001018c,
            target = 0x12fa4d68
        },
        cx = {
            offset = 0x0000EF6C,
            target = 0x12FA4D68
        }
    }


    local devOffset = offsetTable[deviceType]

    if devOffset == nil then
        return false
    end

    local exec_space = physics.Space()

    local bodiesNeededToReachOffset = devOffset.offset / structSize

    for i=1, bodiesNeededToReachOffset - 1 do
        exec_space:addBody(physics.Body(0, 0))
    end

    local bodyWithCallback = physics.Body(0, 0)
    bodyWithCallback:setVelocityFunc(function ()
        bodyWithCallback:setVelocityFunc(nil) -- only call this function once

        exec_space:setSleepTimeThreshold(1)
        exec_space:step(1) -- this update the bodies array for exec_space

        -- at this point, the loop which is calling this callback has a broken reference (null now) to the bodies array
        -- in the next loop iteration, it will try to invoke the velocity function for the next body, but end up calling *((void*)0x0000_0000)[total_body_count - 1]
        -- as we control the number of bodies in the space, we can look for plausable addresses inside the memory that could point back to the heap

        -- e.g., on the CX-II at location 0x000006ac there is the value 0x13A00000, 0x13A00000 is in accessible heap memory
        -- our goal is to get a pointer in 0x13A00000, which points to our shell code
        -- if we make enough strings we can get our pointer there
    end)

    exec_space:addBody(bodyWithCallback)
    exec_space:addBody(physics.Body(0, 0))

    -- spray the heap with our address
    local spray_success = sprayHeap(devOffset.target, addr)
    if not spray_success then
        return false
    end

    if beforeExecHook ~= nil then
        beforeExecHook()
    end

    -- trigger the exploit
    exec_space:step(1)

    -- if we return safely
    return true
end

local do_install        = false
local attemped_install  = false

function install()
    resetHeap()
    local space, refresh = makeExecutableSpace(installer)
    return exec(space.bptr, refresh)
end

local installer_result = {"install_failed:os_invalid", "install_failed:no_resources", "install_done", "install_failed"}

function getInstallerResult()
    local payloadResult   = string.byte(installer, #installer - 3)

    if payloadResult == 0 or payloadResult > #installer_result then
        payloadResult = #installer_result
    end

    return installer_result[payloadResult]
end

function on.construction()
    timer.start(0.1)

    platform.registerErrorHandler(function ()
        ipc_send("install_failed", "setup")
    end)

    ipc_subscribe("install_start", function (s, override) 
        do_install = true
        device_override = override
    end)
end

function on.timer()
    ipc_tick()

    if not attemped_install and do_install then
        gmsg = "starting install"
        local res = install()
        if res then
            installed = true
            ipc_send(getInstallerResult())
        else
            ipc_send("install_failed", "setup")
        end

        attemped_install = true
    end
end


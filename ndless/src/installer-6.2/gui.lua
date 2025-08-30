platform.apilevel = "1.0"

-----------------
-- Device Type --
-----------------

function getDeviceType()
    local _, err = math.eval("DrawLine")
    local cx2 = err == 930

    if device_override and not cx2 then
        return device_override
    end

    return cx2 and "cx2" or "unknown"
end

---------
-- IPC --
---------

-- ZZZ_IPC_LUA_ZZZ

----------
-- FONT --
----------
do
    local CHAR_HEIGHT = 12
    local CHAR_WIDTH  = 8
    
    local charMap_ascii = {
        [0x21] = {  0,  24,  60,  60,  60,  24,  24,   0,  24,  24,   0,   0},
        [0x22] = { 54,  54,  54,  20,   0,   0,   0,   0,   0,   0,   0,   0},
        [0x23] = {  0, 108, 108, 108, 254, 108, 108, 254, 108, 108,   0,   0},
        [0x24] = { 24,  24, 124, 198, 192, 120,  60,   6, 198, 124,  24,  24},
        [0x25] = {  0,   0,   0,  98, 102,  12,  24,  48, 102, 198,   0,   0},
        [0x26] = {  0,  56, 108,  56,  56, 118, 246, 206, 204, 118,   0,   0},
        [0x27] = { 12,  12,  12,  24,   0,   0,   0,   0,   0,   0,   0,   0},
        [0x28] = {  0,  12,  24,  48,  48,  48,  48,  48,  24,  12,   0,   0},
        [0x29] = {  0,  48,  24,  12,  12,  12,  12,  12,  24,  48,   0,   0},
        [0x2a] = {  0,   0,   0, 108,  56, 254,  56, 108,   0,   0,   0,   0},
        [0x2b] = {  0,   0,   0,  24,  24, 126,  24,  24,   0,   0,   0,   0},
        [0x2c] = {  0,   0,   0,   0,   0,   0,   0,  12,  12,  12,  24,   0},
        [0x2d] = {  0,   0,   0,   0,   0, 254,   0,   0,   0,   0,   0,   0},
        [0x2e] = {  0,   0,   0,   0,   0,   0,   0,   0,  24,  24,   0,   0},
        [0x2f] = {  0,   0,   2,   6,  12,  24,  48,  96, 192, 128,   0,   0},
        [0x30] = {  0, 124, 198, 206, 222, 246, 230, 198, 198, 124,   0,   0},
        [0x31] = {  0,  24, 120,  24,  24,  24,  24,  24,  24, 126,   0,   0},
        [0x32] = {  0, 124, 198, 198,  12,  24,  48,  96, 198, 254,   0,   0},
        [0x33] = {  0, 124, 198,   6,   6,  60,   6,   6, 198, 124,   0,   0},
        [0x34] = {  0,  12,  28,  60, 108, 204, 254,  12,  12,  12,   0,   0},
        [0x35] = {  0, 254, 192, 192, 192, 252,   6,   6, 198, 124,   0,   0},
        [0x36] = {  0, 124, 198, 192, 192, 252, 198, 198, 198, 124,   0,   0},
        [0x37] = {  0, 254, 198,  12,  24,  48,  48,  48,  48,  48,   0,   0},
        [0x38] = {  0, 124, 198, 198, 198, 124, 198, 198, 198, 124,   0,   0},
        [0x39] = {  0, 124, 198, 198, 198, 126,   6,   6, 198, 124,   0,   0},
        [0x3a] = {  0,   0,   0,  12,  12,   0,   0,  12,  12,   0,   0,   0},
        [0x3b] = {  0,   0,   0,  12,  12,   0,   0,  12,  12,  12,  24,   0},
        [0x3c] = {  0,  12,  24,  48,  96, 192,  96,  48,  24,  12,   0,   0},
        [0x3d] = {  0,   0,   0,   0, 254,   0, 254,   0,   0,   0,   0,   0},
        [0x3e] = {  0,  96,  48,  24,  12,   6,  12,  24,  48,  96,   0,   0},
        [0x3f] = {  0, 124, 198, 198,  12,  24,  24,   0,  24,  24,   0,   0},
        [0x40] = {  0, 124, 198, 198, 222, 222, 222, 220, 192, 126,   0,   0},
        [0x41] = {  0,  56, 108, 198, 198, 198, 254, 198, 198, 198,   0,   0},
        [0x42] = {  0, 252, 102, 102, 102, 124, 102, 102, 102, 252,   0,   0},
        [0x43] = {  0,  60, 102, 192, 192, 192, 192, 192, 102,  60,   0,   0},
        [0x44] = {  0, 248, 108, 102, 102, 102, 102, 102, 108, 248,   0,   0},
        [0x45] = {  0, 254, 102,  96,  96, 124,  96,  96, 102, 254,   0,   0},
        [0x46] = {  0, 254, 102,  96,  96, 124,  96,  96,  96, 240,   0,   0},
        [0x47] = {  0, 124, 198, 198, 192, 192, 206, 198, 198, 124,   0,   0},
        [0x48] = {  0, 198, 198, 198, 198, 254, 198, 198, 198, 198,   0,   0},
        [0x49] = {  0,  60,  24,  24,  24,  24,  24,  24,  24,  60,   0,   0},
        [0x4a] = {  0,  60,  24,  24,  24,  24,  24, 216, 216, 112,   0,   0},
        [0x4b] = {  0, 198, 204, 216, 240, 240, 216, 204, 198, 198,   0,   0},
        [0x4c] = {  0, 240,  96,  96,  96,  96,  96,  98, 102, 254,   0,   0},
        [0x4d] = {  0, 198, 198, 238, 254, 214, 214, 214, 198, 198,   0,   0},
        [0x4e] = {  0, 198, 198, 230, 230, 246, 222, 206, 206, 198,   0,   0},
        [0x4f] = {  0, 124, 198, 198, 198, 198, 198, 198, 198, 124,   0,   0},
        [0x50] = {  0, 252, 102, 102, 102, 124,  96,  96,  96, 240,   0,   0},
        [0x51] = {  0, 124, 198, 198, 198, 198, 198, 198, 214, 124,   6,   0},
        [0x52] = {  0, 252, 102, 102, 102, 124, 120, 108, 102, 230,   0,   0},
        [0x53] = {  0, 124, 198, 192,  96,  56,  12,   6, 198, 124,   0,   0},
        [0x54] = {  0, 126,  90,  24,  24,  24,  24,  24,  24,  60,   0,   0},
        [0x55] = {  0, 198, 198, 198, 198, 198, 198, 198, 198, 124,   0,   0},
        [0x56] = {  0, 198, 198, 198, 198, 198, 198, 108,  56,  16,   0,   0},
        [0x57] = {  0, 198, 198, 214, 214, 214, 254, 238, 198, 198,   0,   0},
        [0x58] = {  0, 198, 198, 108,  56,  56,  56, 108, 198, 198,   0,   0},
        [0x59] = {  0, 102, 102, 102, 102,  60,  24,  24,  24,  60,   0,   0},
        [0x5a] = {  0, 254, 198, 140,  24,  48,  96, 194, 198, 254,   0,   0},
        [0x5b] = {  0, 124,  96,  96,  96,  96,  96,  96,  96, 124,   0,   0},
        [0x5c] = {  0,   0, 128, 192,  96,  48,  24,  12,   6,   2,   0,   0},
        [0x5d] = {  0, 124,  12,  12,  12,  12,  12,  12,  12, 124,   0,   0},
        [0x5e] = { 16,  56, 108, 198,   0,   0,   0,   0,   0,   0,   0,   0},
        [0x5f] = {  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 255},
        [0x60] = { 24,  24,  24,  12,   0,   0,   0,   0,   0,   0,   0,   0},
        [0x61] = {  0,   0,   0,   0, 120,  12, 124, 204, 220, 118,   0,   0},
        [0x62] = {  0, 224,  96,  96, 124, 102, 102, 102, 102, 252,   0,   0},
        [0x63] = {  0,   0,   0,   0, 124, 198, 192, 192, 198, 124,   0,   0},
        [0x64] = {  0,  28,  12,  12, 124, 204, 204, 204, 204, 126,   0,   0},
        [0x65] = {  0,   0,   0,   0, 124, 198, 254, 192, 198, 124,   0,   0},
        [0x66] = {  0,  28,  54,  48,  48, 252,  48,  48,  48, 120,   0,   0},
        [0x67] = {  0,   0,   0,   0, 118, 206, 198, 198, 126,   6, 198, 124},
        [0x68] = {  0, 224,  96,  96, 108, 118, 102, 102, 102, 230,   0,   0},
        [0x69] = {  0,  24,  24,   0,  56,  24,  24,  24,  24,  60,   0,   0},
        [0x6a] = {  0,  12,  12,   0,  28,  12,  12,  12,  12, 204, 204, 120},
        [0x6b] = {  0, 224,  96,  96, 102, 108, 120, 108, 102, 230,   0,   0},
        [0x6c] = {  0,  56,  24,  24,  24,  24,  24,  24,  24,  60,   0,   0},
        [0x6d] = {  0,   0,   0,   0, 108, 254, 214, 214, 198, 198,   0,   0},
        [0x6e] = {  0,   0,   0,   0, 220, 102, 102, 102, 102, 102,   0,   0},
        [0x6f] = {  0,   0,   0,   0, 124, 198, 198, 198, 198, 124,   0,   0},
        [0x70] = {  0,   0,   0,   0, 220, 102, 102, 102, 124,  96,  96, 240},
        [0x71] = {  0,   0,   0,   0, 118, 204, 204, 204, 124,  12,  12,  30},
        [0x72] = {  0,   0,   0,   0, 220, 102,  96,  96,  96, 240,   0,   0},
        [0x73] = {  0,   0,   0,   0, 124, 198, 112,  28, 198, 124,   0,   0},
        [0x74] = {  0,  48,  48,  48, 252,  48,  48,  48,  54,  28,   0,   0},
        [0x75] = {  0,   0,   0,   0, 204, 204, 204, 204, 204, 118,   0,   0},
        [0x76] = {  0,   0,   0,   0, 198, 198, 198, 108,  56,  16,   0,   0},
        [0x77] = {  0,   0,   0,   0, 198, 198, 214, 214, 254, 108,   0,   0},
        [0x78] = {  0,   0,   0,   0, 198, 108,  56,  56, 108, 198,   0,   0},
        [0x79] = {  0,   0,   0,   0, 198, 198, 198, 206, 118,   6, 198, 124},
        [0x7a] = {  0,   0,   0,   0, 254, 140,  24,  48,  98, 254,   0,   0},
        [0x7b] = {  0,  14,  24,  24,  24, 112,  24,  24,  24,  14,   0,   0},
        [0x7c] = {  0,  24,  24,  24,  24,   0,  24,  24,  24,  24,   0,   0},
        [0x7d] = {  0, 112,  24,  24,  24,  14,  24,  24,  24, 112,   0,   0},
        [0x7e] = {  0, 118, 220,   0,   0,   0,   0,   0,   0,   0,   0,   0},
        
        [0xb0] = { 17,  68,  17,  68,  17,  68,  17,  68,  17,  68,  17,  68},
        [0xb1] = { 85, 170,  85, 170,  85, 170,  85, 170,  85, 170,  85, 170},
        [0xb2] = {221, 119, 221, 119, 221, 119, 221, 119, 221, 119, 221, 119},
        [0xb3] = { 24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24},
        [0xb4] = { 24,  24,  24,  24,  24,  24, 248,  24,  24,  24,  24,  24},
        [0xb5] = { 24,  24,  24,  24, 248,  24, 248,  24,  24,  24,  24,  24},
        [0xb6] = { 54,  54,  54,  54,  54,  54, 246,  54,  54,  54,  54,  54},
        [0xb7] = {  0,   0,   0,   0,   0,   0, 254,  54,  54,  54,  54,  54},
        [0xb8] = {  0,   0,   0,   0, 248,  24, 248,  24,  24,  24,  24,  24},
        [0xb9] = { 54,  54,  54,  54, 246,   6, 246,  54,  54,  54,  54,  54},
        [0xba] = { 54,  54,  54,  54,  54,  54,  54,  54,  54,  54,  54,  54},
        [0xbb] = {  0,   0,   0,   0, 254,   6, 246,  54,  54,  54,  54,  54},
        [0xbc] = { 54,  54,  54,  54, 246,   6, 254,   0,   0,   0,   0,   0},
        [0xbd] = { 54,  54,  54,  54,  54,  54, 254,   0,   0,   0,   0,   0},
        [0xbe] = { 24,  24,  24,  24, 248,  24, 248,   0,   0,   0,   0,   0},
        [0xbf] = {  0,   0,   0,   0,   0,   0, 248,  24,  24,  24,  24,  24},
        [0xc0] = { 24,  24,  24,  24,  24,  24,  31,   0,   0,   0,   0,   0},
        [0xc1] = { 24,  24,  24,  24,  24,  24, 255,   0,   0,   0,   0,   0},
        [0xc2] = {  0,   0,   0,   0,   0,   0, 255,  24,  24,  24,  24,  24},
        [0xc3] = { 24,  24,  24,  24,  24,  24,  31,  24,  24,  24,  24,  24},
        [0xc4] = {  0,   0,   0,   0,   0,   0, 255,   0,   0,   0,   0,   0},
        [0xc5] = { 24,  24,  24,  24,  24,  24, 255,  24,  24,  24,  24,  24},
        [0xc6] = { 24,  24,  24,  24,  31,  24,  31,  24,  24,  24,  24,  24},
        [0xc7] = { 54,  54,  54,  54,  54,  54,  55,  54,  54,  54,  54,  54},
        [0xc8] = { 54,  54,  54,  54,  55,  48,  63,   0,   0,   0,   0,   0},
        [0xc9] = {  0,   0,   0,   0,  63,  48,  55,  54,  54,  54,  54,  54},
        [0xca] = { 54,  54,  54,  54, 247,   0, 255,   0,   0,   0,   0,   0},
        [0xcb] = {  0,   0,   0,   0, 255,   0, 247,  54,  54,  54,  54,  54},
        [0xcc] = { 54,  54,  54,  54,  55,  48,  55,  54,  54,  54,  54,  54},
        [0xcd] = {  0,   0,   0,   0, 255,   0, 255,   0,   0,   0,   0,   0},
        [0xce] = { 54,  54,  54,  54, 247,   0, 247,  54,  54,  54,  54,  54},
        [0xcf] = { 24,  24,  24,  24, 255,   0, 255,   0,   0,   0,   0,   0},
        [0xd0] = { 54,  54,  54,  54,  54,  54, 255,   0,   0,   0,   0,   0},
        [0xd1] = {  0,   0,   0,   0, 255,   0, 255,  24,  24,  24,  24,  24},
        [0xd2] = {  0,   0,   0,   0,   0,   0, 255,  54,  54,  54,  54,  54},
        [0xd3] = { 54,  54,  54,  54,  54,  54,  63,   0,   0,   0,   0,   0},
        [0xd4] = { 24,  24,  24,  24,  31,  24,  31,   0,   0,   0,   0,   0},
        [0xd5] = {  0,   0,   0,   0,  31,  24,  31,  24,  24,  24,  24,  24},
        [0xd6] = {  0,   0,   0,   0,   0,   0,  63,  54,  54,  54,  54,  54},
        [0xd7] = { 54,  54,  54,  54,  54,  54, 255,  54,  54,  54,  54,  54},
        [0xd8] = { 24,  24,  24,  24, 255,  24, 255,  24,  24,  24,  24,  24},
        [0xd9] = { 24,  24,  24,  24,  24,  24, 248,   0,   0,   0,   0,   0},
        [0xda] = {  0,   0,   0,   0,   0,   0,  31,  24,  24,  24,  24,  24},
        [0xdb] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
        [0xdc] = {  0,   0,   0,   0,   0,   0, 255, 255, 255, 255, 255, 255},
        [0xdd] = {240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240},
        [0xde] = { 15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15},
        [0xdf] = {255, 255, 255, 255, 255, 255,   0,   0,   0,   0,   0,   0},
        
    }
    
    local charMapImages = {}
    
    local TEXT_FG    = "\224\139" --green
    local TEXT_BG    = "la"       --alpha
    local IMG_HEADER = "\8\0\0\0\12\0\0\0\0\0\0\0\16\0\0\0\16\0\1\0"
    
    local function rowToImageRow(row)
        local r = ""
        for i=1, CHAR_WIDTH do
            r = (row % 2 == 0 and TEXT_BG or TEXT_FG) .. r
            row = math.floor(row / 2)
        end
        return r
    end
    
    local function charToImage(charData)
        local r = IMG_HEADER
        for i=1, CHAR_HEIGHT do
            r = r .. rowToImageRow(charData[i])
        end
        return image.new(r)
    end
    
    local function genCharImages()
        for i=0, 255 do
           if charMap_ascii[i] then
            charMapImages[i] = charToImage(charMap_ascii[i])
           end
        end
    end
    
    local function drawChar(gc, char, x, y)
       local img = charMapImages[char:byte()]
       if img then
	       gc:drawImage(img, x, y)
	   end
    end
    
    function drawGrid(gc)
        local y=0
        for n=0, 15 do
            local c = string.format("%X", n)
            drawChar(gc, c, (n+2)*CHAR_WIDTH, 0)
            drawChar(gc, c, 0, (n+2)*CHAR_HEIGHT)
        end
        
        for y=0, 15 do
            for x=0, 15 do
                local c = y * 16 + x
                local i = charMapImages[c]
                if i then
                    gc:drawImage(i, (x+2)*CHAR_WIDTH, (y+2)*CHAR_HEIGHT)
                end
            end
        end
    end
    
    function drawMonoString(gc, str, x, y, s, n)
        local s = s or 1
        local l = #str
        local n = n or s+l
        
        
        local p = 0
        for i=s, n do
            p = p + 1
            local o = ((i-1) % l) + 1
            local char = str:sub(o, o)
            if char == "\n" then
                y = y + CHAR_HEIGHT
                p = 0
            else
                drawChar(gc, char, x + p * CHAR_WIDTH - CHAR_WIDTH, y)    
            end
        end
    end
    
    genCharImages()
end

local function addSpaces(str, n)
    return str .. string.rep(" ", n-#str)
end

local function bI(str)
    return (str:gsub("/%-", "\201\205")
	      :gsub("%-\\", "\205\187")
	      :gsub("\\_", "\200\205")
	      :gsub("_/", "\205\188")
	      :gsub("%+%-","\204\205")
	      :gsub("%-%+", "\205\185")
	      :gsub("%-", "\205")
	      :gsub("|", "\186")  
          :gsub("%$", "\219")   
	   )
end




------------------
-- Text Content --
------------------

local s_credits      = "Ndless brought to you by the Ndless team! @Vogtinator, @Satyamedh, @sasdallas, @icosahedr.n, @timmycraft, @cherpixel, @jimbauwens - Many thanks to all past contributors and testers: geogeo, ExtendeD, bsl, critor, Excale, Goplat, hoffa, Legimet, Levak, debrouxl, lkj, tangrs, Adriweb, drakeerv, NightHawk, NspireUartLover and others! ndless.me - github.com/ndless-nspire      "

local s_ndless_cxii_a =  bI([[
        /----------\ 
/-------+  Ndless  +-------\
|       \_--------_/       |
| Ndless for OS 6.2.0      |
|                          |
| Press any key to start   |
| installation...          |
|                          |
|                          |
| >$                       |
\_------------------------_/
]])

local s_ndless_cxii_b = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| Ndless for OS 6.2.0      |
|                          |
| Press any key to start   |
| installation...          |
|                          |
|                          |
| >                        |
\_------------------------_/
]])

local s_ndless_cx_a =  bI([[
        /----------\ 
/-------+  Ndless  +-------\
|       \_--------_/       |
| Ndless for OS 4.5.5      |
|                          |
| Ndless installer         |
| Press 3 for Boot 3.0.0   |
| Press 4 for Boot 4.0.1   |
|                          |
| >$                       |
\_------------------------_/
]])

local s_ndless_cx_b = bI([[
        /----------\ 
/-------+  Ndless  +-------\
|       \_--------_/       |
| Ndless for OS 4.5.5      |
|                          |
| Ndless installer         |
| Press 3 for Boot 3.0.0   |
| Press 4 for Boot 4.0.1   |
|                          |
| >                        |
\_------------------------_/
]])

local s_ndless_installing = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| INSTALLING               |
|                          |
| Please wait...           |
| Almost there...          |
|                          |
|                          |
| > exec()                 |
\_------------------------_/
]])


local s_ndless_install_done = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| SUCCESS                  |
|                          |
| Install finished!        |
| Closing document...      |
|                          |
| > closeDoc()             |
|                          |
\_------------------------_/
]])

local s_ndless_install_failed = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| ERROR                    |
|                          |
| Install failed :(        |
|                          |
| Please restart device    |
| and try again!           |
|                          |
\_------------------------_/
]])

local s_ndless_missing_resources_file = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| ERROR                    |
|                          |
| Missing resources file   |
|                          |
| Please copy resources    |
| file to device and try   |
| again!                   |
\_------------------------_/
]])

local s_ndless_invalid_os = bI([[
        /----------\
/-------+  Ndless  +-------\
|       \_--------_/       |
| ERROR                    |
|                          |
| Unsupported OS           |
|                          |
| This version of Ndless   |
| is not compatible with   |
| this device!             |
\_------------------------_/
]])

---------------------
-- End of font.lua --
---------------------

local mColorsH = {0x002B00, 0x003B00, 0x004B00, 0x005B00, 0x008F11, 0x00FF41}
local mColorsL = {0x000000, 0x000000, 0x001B00, 0x002B00, 0x004000, 0x006000}

mColorsH[0] = 0
mColorsL[0] = 0

local oMap = {}

function makeOffsetMap(c, r)
    local last = -1
    oMap = {}
    
    for i=1, c do
        local o 
        --repeat
            o = math.floor(math.random()*r)
        --until math.abs(o-last) > 2
        last = o
        oMap[i] = o
    end 
end

local current = 1

local tailSize    = 6 -- needs to be max #mColorsH
local gridSize    = 12
local blockSize   = 6
local blockOffset = math.floor((gridSize - blockSize)/2)

local width  = 320
local height = 240

local columns = math.floor(width / gridSize)
local rows    = math.floor(height / gridSize)

local b_w = 8 * 27
local b_h = 9 * 12
local b_x = (width  - b_w) / 2
local b_y = (height - b_h) / 2

makeOffsetMap(columns, rows)

local current = 0
local fade    = false
local blink   = true
local max     = #mColorsH
local status  = "ready"
local failed  = false
local cxii    = false
local trigger = false
local install_ts = 0

function on.paint(gc)
    local offsetX, offsetY = 0,0
    if status == "install_failed" then
        offsetY = -27
        offsetX = -2
    else
        gc:begin()
    end

    gc:fillRect(0,0, 320, 240)
    
    gc:setColorRGB(0x002000)
    gc:fillRect(offsetX + b_x + 8 * 8, offsetY + b_y - 12, 11 * 8, 12)
    gc:fillRect(offsetX + b_x, offsetY + b_y, b_w, b_h)
    
    for c = 1, columns do
        local mc = current + oMap[c]
        local x1 = c * gridSize - gridSize + blockOffset
        
        for i=1, tailSize do
            local pos = (i + mc) % rows
            local y1 = pos * gridSize + blockOffset
            
            local inBox = (x1 >= b_x - 8 and x1 + blockSize <= b_x + b_w + 8 and y1 >= b_y - 8 and y1 + blockSize <= b_y + b_h + 8) or y1 > 220
            local col = inBox and mColorsL[math.min(i, max)] or mColorsH[math.min(i, max)]
            
          
            gc:setColorRGB(col)
            gc:fillRect(offsetX + x1, offsetX + y1, blockSize, blockSize)
        end
    end

    local msg

    if status == "ready" then
        msg = blink and (cxii and s_ndless_cxii_a or s_ndless_cx_a) or (cxii and s_ndless_cxii_b or s_ndless_cx_b)
    elseif status == "install_start" or status == "install_requested" then
        msg = s_ndless_installing
    elseif status == "install_done" then
        msg = s_ndless_install_done
    elseif status == "install_failed" then
        if failed == "os_invalid" then
            msg = s_ndless_invalid_os
        elseif failed == "no_resources" then
            msg = s_ndless_missing_resources_file
        else
            msg = s_ndless_install_failed
        end
    else
        msg = "Status:" .. tostring(status)
    end
    
    drawMonoString(gc, msg, offsetX + b_x - 8, offsetY + b_y - 16)
    
    local counter_offset = 30
    local credit_pos = current < counter_offset and 0 or math.floor((current - counter_offset) / 2)
    drawMonoString(gc, s_credits, 0, 226+(fade and current-fade or 0), credit_pos + 1, credit_pos+40)
end

function on.timer()
    ipc_tick()

    if fade then
        max = math.max(max - 1, 0) 
    end
    
    current = current + 1
    
    if current % 6 == 0 then
        blink = not blink
    end

    local now = timer.getMilliSecCounter()

    if status == "install_start" and current - fade > 15 then
        status     = "install_requested"
        install_ts = now

        if not cxii and trigger == "3" then
            ipc_send("install_start", "cx")
        elseif not cxii and trigger == "4" then
            ipc_send("install_start", "cxw")
        else 
            ipc_send("install_start")
        end
    end

    --timeout because the other script probably crashed...
    if status == "install_requested" and (now - install_ts) > 10000 then
        status = "install_failed"
    end
    
    --platform.window:invalidate()
    platform.window:setFocus(false)
    platform.window:setFocus(true)
end

function on.charIn(ch)
    if not cxii and ch ~= "3" and ch ~= "4" then return end
    if not status == "ready" then return end

    fade    = current
    status  = "install_start"
    trigger = ch
end

on.arrowKey  = on.charIn
on.enterKey  = on.charIn
on.mouseDown = on.charIn
on.returnKey = on.charIn
on.tabKey    = on.charIn

function on.create()
    cxii = getDeviceType() == "cx2"
    timer.start(0.08)

    ipc_subscribe("install_done", function (d) 
        status = d
    end)

    ipc_subscribe("install_failed", function (f, reason) 
        status = f
        failed = reason
    end)
end


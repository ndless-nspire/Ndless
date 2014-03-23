-- The contents of this file are subject to the Mozilla Public
-- License Version 1.1 (the "License"); you may not use this file
-- except in compliance with the License. You may obtain a copy of
-- the License at http://www.mozilla.org/MPL/
--
--  The Original Code is Ndless code.
--
-- The Initial Developer of the Original Code is Jim Bauwens.
-- Portions created by the Initial Developer are Copyright (C) 2013-2014
-- the Initial Developer. All Rights Reserved.
 
-- Contributor(s): Excale and others.

-------------------
-- Set API Level --
-------------------

platform.apilevel = '1.0'

-----------------------------
-- Constants and variables --
-----------------------------

-- ndless_revision is set by ndless_version.lua
NDLESS_VERSION = "Ndless 3.6 rev. " .. ndless_revision

-- for help / strings
help = false
b  = string.uchar(10003)
bb = ":( " -- string.uchar(215)

-- Will be corrected at runtime
DEVICE_MODEL   = ""
DEVICE_HAS_CAS = false
DEVICE_MIN_OS  = ""
NO_TRICK = false

----------------------
-- Extend some libs --
----------------------

do
    function invalidateAll()
        Widget:setFocus(false)
        Widget:setFocus(true)
    end

    function AddToGC(key, func)
        local gcMetatable = getmetatable(platform.gc())
        gcMetatable[key] = func
    end

    local function drawBWHorizontalGradient(gc, from, to, x, y, w, h)
        local diff = to - from
        for i = 1, h do
            local shade = math.floor((i * diff) / h)
            gc:setColorRGB(shade, shade, shade)
            gc:fillRect(x, y + i - 1, w, 1)
        end
    end

    local function drawStringMiddle(gc, str, x, y, w, h)
        local sw = gc:getStringWidth(str)
        local sh = gc:getStringHeight(str)
        gc:drawString(str, x + (w - sw) / 2, y + (h - sh) / 2, "top")
    end

    AddToGC("drawBWHorizontalGradient", drawBWHorizontalGradient)
    AddToGC("drawStringMiddle", drawStringMiddle)
end

-----------------------
-- General functions --
-----------------------

local counter = 0
function refreshAtStart()
    counter = (counter + 1) % 100
    if counter == 5 then
        on.getFocus()
    end
end

function imgTest()
    image.new("\255\255\255\127\1\0\0\0\0\0\0\0\0\0\0\0\16\0\1\0")
end

function getVersion()
    local version

    -- is color?
    local color = platform.isColorDisplay()

    -- is cas?
    local _, caserr = math.eval("solve()")
    local has_cas = caserr == 930

    -- is computer?
    local hw
    if not platform.hw then
        hw = 0
    else
        hw = platform.hw()
    end
    local computer = hw == 7

    -- is tablet?
    local tablet = platform.isTabletModeRendering and platform.isTabletModeRendering()

    -- So what's the device
    local device

    if tablet then
        device = "TABLET"
    elseif computer then
        device = "COMPUTER"
    elseif color then
        device = "CX"
    else
        device = "BW"
    end

    local min_os
    if Widget then
        if pcall(imgTest) then
            min_os = "3.2"
        else
            min_os = "3.6"
        end
    else
        min_os = "0.0"
    end

    return device, has_cas, min_os
end

---------------
-- Main view --
---------------

function drawMainView(gc)
    gc:drawBWHorizontalGradient(0, 80, 0, 1, 320, 21)
    gc:setColorRGB(50, 50, 50)
    gc:fillRect(0, 22, 320, 1)

    gc:setColorRGB(0xCC, 0xCC, 0xCC)
    gc:fillRect(0, 23, 320, 1)

    gc:setColorRGB(0, 0, 0)
    gc:fillRect(0, 24, 320, 240 - 24)

    gc:setColorRGB(0xDD, 0xDD, 0xFF)
    gc:setFont("sansserif", "r", 12)

    if not ndless then
        gc:drawStringMiddle(L"installTitle", 0, 0, 320, 24)
    else
        gc:drawStringMiddle(L"uninstallTitle", 0, 0, 320, 24)
    end

    gc:setColorRGB(0xDD, 0xFF, 0xDD)
    gc:setFont("sansserif", "r", 9)

    if help then
        if not (DEVICE_MIN_OS == "3.6") then
            for i = 1, 3 do
                gc:drawString(L("helpErr" .. i), 5, 30 + (i - 1) * 14, "top")
            end
        else
            for i = 1, 6 do
                gc:drawString(L("help" .. i), 5, 30 + (i - 1) * 14, "top")
            end

            gc:setColorRGB(0, 0, 0)

            for i = 0, 20 do
                gc:setColorRGB(4 * i, 4 * i, 4 * i)
                gc:drawLine(20, i + 114, 150, i + 114)
            end

            gc:setFont("serif", "r", 13)
            gc:setColorRGB(255, 255, 255)
            gc:drawString(string.uchar(61703), 25, 110, "top")
            gc:drawLine(20, 134, 150, 134)

            gc:setFont("serif", "r", 11)
            gc:setColorRGB(0, 255, 0)
            gc:drawString("Ndless installed!", 46, 114, "top")

            gc:setFont("sansserif", "r", 9)
            gc:setColorRGB(0xDD, 0xFF, 0xDD)
            gc:drawString(L"success", 5, 134, "top")
			gc:drawString(L"nonpersistent", 5, 148, "top")
        end
    else
        if NO_TRICK then
            gc:drawString(L"notCalc", 5, 30, "top")
        elseif not (DEVICE_MIN_OS == "3.6") then
            gc:drawString(L"not36", 5, 30, "top")
        elseif ndless then
            gc:drawString(L"uninst1", 5, 30, "top")
            gc:drawString(L"uninst2", 5, 44, "top")
            gc:drawString(L"uninst3", 5, 58, "top")
        else
            gc:drawString(L"inst1", 5, 30, "top")
            gc:drawString(L"inst2", 5, 44, "top")
            gc:drawString(L"inst3", 5, 58, "top")
        end

        gc:setColorRGB(0xCC, 0xCC, 0xCC)
        gc:fillRect(0, 82, 320, 1)

        gc:setColorRGB(0xDD, 0xFF, 0xDD)
        gc:setFont("sansserif", "r", 9)

        gc:drawString(b .. " " .. NDLESS_VERSION .. " ", 5, 86, "top")
        gc:drawString((NO_TRICK and bb or b) .. " TI-Nspire " .. DEVICE_MODEL .. (DEVICE_HAS_CAS and " CAS" or ""), 5, 100, "top")
        gc:setColorRGB(0xCC, 0xCC, 0xCC)
        gc:fillRect(0, 122, 320, 1)

        gc:setColorRGB(0xDD, 0xFF, 0xDD)
        gc:setFont("sansserif", "r", 9)
        local b = string.uchar(61712)

        if DEVICE_MODEL == "BW" then
            gc:setColorRGB(0xFF, 0xFF, 0xFF)
        else
            gc:setColorRGB(0xFF, 0xAA, 0xAA)
        end
        gc:drawString(L"wantHelp", 5, 126, "top")
    end

    gc:setColorRGB(0xCC, 0xCC, 0xCC)
    gc:fillRect(0, 166, 320, 1)

    if not NO_TRICK then -- to go well with non-displayed credits because of weird tincs stuff...
        gc:setColorRGB(0xFF, 0xDD, 0xDD)
        gc:drawStringMiddle(L"credits", 5, 168, 320, 20)
    end
end

------------------
-- Credits code --
------------------

local credits = {
    "ExtendeD",
    "bsl",
    "Goplat",
    "Lionel Debroux",
    "Levak",
    "Excale",
    "Vogtinator",
    "Critor",
    "Tangrs",
    "Jim Bauwens"
}

local PAUSE_SPOT = 0
local DELAY = 40
local STEP = 4
local START = -320
local END = 320

local cr = 1
local cp = START
local mc = 0

function drawCredits(gc)
    gc:setColorRGB(0, 0, 0)
    gc:fillRect(0, 0, 320, 240)

    gc:setColorRGB(0xFF, 0xDD, 0xDD)
    gc:setFont("serif", "r", 14)
    gc:drawStringMiddle(credits[cr], cp, 170, 320, 20)
end

---------------------
-- Draw everything --
---------------------

local is_invalidated = true

function on.paint(gc)
    if is_invalidated or NO_TRICK then
        is_invalidated = NO_TRICK

        gc:begin()
        drawMainView(gc)
        gc:finish()
    end

    if not NO_TRICK then drawCredits(gc) end
end

function on.getFocus()
    is_invalidated = true
    platform.window:invalidate()
end

---------------------------------
-- Setup timer for credits bar --
---------------------------------

function on.create()
    timer.start(0.01)
end

function on.timer()
    if mc > 0 then
        mc = mc - 1
    elseif cp == -PAUSE_SPOT then
        cp = cp + STEP
        mc = DELAY
    elseif cp >= END then
        cp = START
        cr = cr + 1
        if cr > #credits then cr = 1 end
    else
        cp = cp + STEP
    end

    platform.window:invalidate(0, 160, 320, 80)
    refreshAtStart()
end

-----------------
-- key presses --
-----------------

function on.charIn(ch)
    if ch == "u" and ndless then
        ndless.uninst()
    end
    if ch == "h" then
        help = not help
    end
    platform.window:invalidate()
end

function on.enterKey()
    help = false
    platform.window:invalidate()
end
on.escapeKey = on.enterKey

------------------------------
-- localize all the strings --
------------------------------
strings = {
    ["inst1"] = {
        en = b .. " Press [MENU] to install Ndless",
        fr = b .. " Appuyez sur [MENU] pour installer Ndless"
    },
    ["inst2"] = {
        en = b .. " Installation will start immediately",
        fr = b .. " L’installation commencera immédiatement"
    },
    ["inst3"] = {
        en = b .. " Enjoy!",
        -- good enough.
    },
    ["uninst1"] = {
        en = b .. " Press [u] to uninstall Ndless",
        fr = b .. " Appuyez sur [u] pour désinstaller Ndless",
    },
    ["uninst2"] = {
        en = b .. " The device will reboot",
        fr = b .. " L'unité va rebooter"
    },
    ["uninst3"] = {
        en = b .. " To reinstall just reopen this document!",
        fr = b .. " Pour réinstaller, réouvrez ce document !",
    },
    ["credits"] = {
        en = "Developers & Testers",
        fr = "Développeurs & Testeurs"
    },
    ["wantHelp"] = {
        en = b .. " First time? Press [h] for a mini-tutorial!",
        fr = b .. " Première fois? Appuyez sur [h] pour un mini-tuto !",
    },
    ["success"] = {
        en = " ... Congratulations, you’ve successfully installed Ndless!",
        fr = " ... Félicitations, vous avez installé Ndless avec succès !",
    },
    ["nonpersistent"] = {
        en = "Ndless will have to be reinstalled after each reboot.",
        fr = "Ndless devra être réinstallé après chaque reboot.",
    },
    ["helpErr1"] = {
        en = bb .. "  Your device is not running OS 3.6!",
        fr = bb .. "  Votre unité n'est pas en OS 3.6 !",
    },
    ["helpErr2"] = {
        en = bb .. "  For more informations, please visit",
        fr = bb .. "  Pour plus d'informations, veuillez visiter",
    },
    ["helpErr3"] = {
        en = bb .. "  http://ndlessly.wordpress.com/ndless-user-guide",
        -- no translation
    },
    ["help1"] = {
        en = b .. " First, make sure 'ndless_resources_3.6.tns' is in the",
        fr = b .. " Déjà, soyez sûr que 'ndless_resources_3.6.tns' soit dans",
    },
    ["help2"] = {
        en = "  'ndless' folder, otherwise, the install will fail",
        fr = "      le dossier 'ndless', sinon ça ne marchera pas",
    },
    ["help3"] = {
        en = b .. " To install Ndless, simply press [MENU]",
        fr = b .. " Pour installer Ndless, appuyez juste sur [MENU]",
    },
    ["help4"] = {
        en = b .. " The screen should display a clock for a few seconds,",
        fr = b .. " L’écran va afficher l’horloge pendant quelques",
    },
    ["help5"] = {
        en = "  then the home screen should appear",
        fr = "      secondes, puis l'écran d'accueil devrait apparaître",
    },
    ["help6"] = {
        en = b .. " If you see this at the top-left of the screen...:",
        fr = b .. " Si vous voyez ceci en haut à gauche de l'écran... :",
    },
    ["installTitle"] = {
        en = "Install Ndless",
        fr = "Installer Ndless"
    },
    ["uninstallTitle"] = {
        en = "Uninstall Ndless",
        fr = "Désinstaller Ndless"
    },
    ["notCalc"] = {
        en = bb .. " This is not a TI-Nspire handheld...",
        fr = bb .. " Ceci n'est pas une calculatrice..."
    },
    ["not36"] = {
        en = bb .. " Your calculator is not running OS 3.6",
        fr = bb .. " Votre calculatrice n'a pas l'OS 3.6"
    },
    -- todo : add more languages ?
}

lang = nil
function L(key)
    lang = lang or locale.name()
    local tbl = strings[key]
    return tbl and (tbl[lang] or tbl[lang:sub(1, 2)]) or tbl["en"]
end


----------------------
-- Ndless installer --
----------------------

function on.resize()
    local device, has_cas, min_os = getVersion()

    DEVICE_MODEL = device
    DEVICE_HAS_CAS = has_cas
    DEVICE_MIN_OS = min_os
    NO_TRICK = (DEVICE_MODEL == "COMPUTER" or DEVICE_MODEL == "TABLET")

    if min_os == "3.6" and s then
        if device == "BW" and not has_cas then
            s = s .. s_ncas
        elseif device == "BW" and has_cas then
            s = s .. s_cas
        elseif device == "CX" and not has_cas then
            s = s .. s_ncascx
        elseif device == "CX" and has_cas then
            s = s .. s_cascx
        end

        if not ndless and s then
            toolpalette.register{ { s } }
        end
    end

    -- avoid running again
    on.resize = nil
end

-- The "s" string building code goes here as produced by MakeLuaInst


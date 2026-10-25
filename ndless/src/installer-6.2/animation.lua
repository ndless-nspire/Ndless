local config = {
    interval = 0.1,
    startDelayMs = 500,
    pauseMs = 500,
    backgroundColor = 0x000000,
    backgroundExtraHeight = 40,

    scanlines = {
        color = 0x182418,
        glowColor = 0x0A100A,
        spacing = 20,
        lineWidth = 1,
        glowWidth = 3,
        speed = 6,
        pulseHz = 0.45,
        pulseMin = 0.45,
        pulseMax = 1.0,
        phaseOffset = 0.55,
    },

    motion = {
        minSpin = 0.6,
        maxSpin = 2.0,
        minProgressPerSecond = 0.004 / 0.03,
        maxProgressPerSecond = 0.009 / 0.03,
    },

    font = {
        y = 55,
        columnStep = 13,
        rowStep = 15,
        pixelWidth = 12,
        pixelHeight = 12,
        letterSpacing = 6,
        glyphs = {
            N = {"1001", "1101", "1011", "1001", "1001"},
            D = {"110", "101", "101", "101", "110"},
            L = {"100", "100", "100", "100", "111"},
            E = {"111", "100", "110", "100", "111"},
            S = {"111", "100", "111", "001", "111"},
            r = {"000", "110", "101", "100", "100"},
            ["0"] = {"111", "101", "101", "101", "111"},
            ["2"] = {"110", "001", "010", "100", "111"},
            ["3"] = {"110", "001", "010", "001", "110"},
        },
    },

    morphs = {
        {text = "NDLESS", x = 24},
        {text = "r2023", x = 53},
    },

    sources = {
        {10, 10, 130, 10, 0x636563}, {170, 10, 130, 10, 0x636563},
        {20, 30, 10, 10, 0x393c39}, {40, 30, 90, 10, 0x393c39},
        {20, 50, 10, 10, 0x393c39}, {40, 50, 60, 10, 0x393c39},
        {180, 30, 10, 10, 0x393c39}, {200, 30, 50, 10, 0x393c39},
        {180, 50, 10, 10, 0x393c39}, {200, 50, 70, 10, 0x393c39},
        {180, 70, 10, 10, 0x393c39}, {200, 70, 90, 10, 0x393c39},
        {180, 90, 10, 10, 0x393c39}, {200, 90, 70, 10, 0x393c39},
        {180, 110, 10, 10, 0x393c39}, {200, 110, 90, 10, 0x393c39},
        {22, 150, 32, 32, 0x313439}, {62, 150, 32, 32, 0x21455a},
        {102, 150, 32, 32, 0x102442}, {142, 150, 32, 32, 0x004139},
        {182, 150, 32, 32, 0x4a1c39}, {222, 150, 32, 32, 0x634518},
        {262, 150, 32, 32, 0x395108},
    },
}

local animation = {interval = config.interval}

local function buildTargets(morph)
    local font = config.font
    local targets = {}
    local letterX = morph.x

    for letterIndex = 1, #morph.text do
        local character = morph.text:sub(letterIndex, letterIndex)
        local glyph = assert(font.glyphs[character], "Missing animation glyph: " .. character)

        for row = 1, #glyph do
            local column = 1
            while column <= #glyph[row] do
                if glyph[row]:sub(column, column) == "0" then
                    column = column + 1
                else
                    local runEnd = column
                    while runEnd < #glyph[row] and glyph[row]:sub(runEnd + 1, runEnd + 1) == "1" do
                        runEnd = runEnd + 1
                    end

                    targets[#targets + 1] = {
                        letterX + (column - 1) * font.columnStep,
                        font.y + (row - 1) * font.rowStep,
                        (runEnd - column) * font.columnStep + font.pixelWidth,
                        font.pixelHeight,
                    }
                    column = runEnd + 1
                end
            end
        end

        letterX = letterX + #glyph[1] * font.columnStep -
            (font.columnStep - font.pixelWidth) + font.letterSpacing
    end

    return targets
end

assert(#config.morphs > 0, "Animation requires at least one morph target")

local targets = {}
local polygonCount = 0
for i, morph in ipairs(config.morphs) do
    targets[i] = buildTargets(morph)
    polygonCount = math.max(polygonCount, #targets[i])
end

for targetIndex, target in ipairs(targets) do
    local expanded = {}
    for polygonIndex = 1, polygonCount do
        expanded[polygonIndex] = target[(polygonIndex - 1) % #target + 1]
    end
    targets[targetIndex] = expanded
end

local states = {}
local fromTargets = false
local targetIndex = 1
local toTargets = targets[targetIndex]
local startTime = false
local previousTime = false
local pauseStartTime = false
local scanlineOffset = 0
local scanlinePulse = 0

local function scaleColor(color, intensity)
    local red = math.floor(color / 0x10000) % 0x100
    local green = math.floor(color / 0x100) % 0x100
    local blue = color % 0x100
    return math.floor(red * intensity) * 0x10000 +
        math.floor(green * intensity) * 0x100 + math.floor(blue * intensity)
end

local function resetState(state)
    local motion = config.motion
    local direction = math.random(0, 1) == 0 and -1 or 1
    state.progress = 0
    state.spin = direction * (motion.minSpin + math.random() * (motion.maxSpin - motion.minSpin))
    state.speed = motion.minProgressPerSecond +
        math.random() * (motion.maxProgressPerSecond - motion.minProgressPerSecond)
end

local function corners(rect)
    return {
        rect[1], rect[2], rect[1] + rect[3], rect[2],
        rect[1] + rect[3], rect[2] + rect[4], rect[1], rect[2] + rect[4],
    }
end

local function drawPolygon(gc, index, source)
    local state = states[index]
    if not state then
        state = {}
        resetState(state)
        states[index] = state
    end

    local sourceCorners = corners(fromTargets and fromTargets[index] or source)
    local targetCorners = corners(toTargets[index])
    local polygon = {}
    local centerX, centerY = 0, 0

    for i = 1, #sourceCorners, 2 do
        polygon[i] = sourceCorners[i] + (targetCorners[i] - sourceCorners[i]) * state.progress
        polygon[i + 1] = sourceCorners[i + 1] +
            (targetCorners[i + 1] - sourceCorners[i + 1]) * state.progress
        centerX = centerX + polygon[i]
        centerY = centerY + polygon[i + 1]
    end

    centerX, centerY = centerX / 4, centerY / 4
    local angle = math.sin(state.progress * math.pi) * state.spin
    local cosine, sine = math.cos(angle), math.sin(angle)

    for i = 1, #polygon, 2 do
        local offsetX, offsetY = polygon[i] - centerX, polygon[i + 1] - centerY
        polygon[i] = centerX + offsetX * cosine - offsetY * sine
        polygon[i + 1] = centerY + offsetX * sine + offsetY * cosine
    end

    gc:fillPolygon(polygon)
end

function animation.draw(gc, x, y, w, h)
    local backgroundHeight = h + config.backgroundExtraHeight
    gc:setColorRGB(config.backgroundColor)
    gc:fillPolygon({x, y, x + w, y, x + w, y + backgroundHeight,
        x, y + backgroundHeight})

    local scanlines = config.scanlines
    local scanlineY = y + scanlineOffset - scanlines.spacing
    local lineIndex = 0
    local glowOffset = (scanlines.glowWidth - scanlines.lineWidth) / 2

    while scanlineY <= y + backgroundHeight do
        local pulse = 0.5 + 0.5 * math.sin(scanlinePulse + lineIndex * scanlines.phaseOffset)
        local intensity = scanlines.pulseMin + (scanlines.pulseMax - scanlines.pulseMin) * pulse

        gc:setColorRGB(scaleColor(scanlines.glowColor, intensity))
        gc:fillPolygon({x, scanlineY - glowOffset, x + w, scanlineY - glowOffset,
            x + w, scanlineY - glowOffset + scanlines.glowWidth,
            x, scanlineY - glowOffset + scanlines.glowWidth})

        gc:setColorRGB(scaleColor(scanlines.color, intensity))
        gc:fillPolygon({x, scanlineY, x + w, scanlineY,
            x + w, scanlineY + scanlines.lineWidth, x, scanlineY + scanlines.lineWidth})
        scanlineY = scanlineY + scanlines.spacing
        lineIndex = lineIndex + 1
    end

    for i = 1, polygonCount do
        local source = config.sources[(i - 1) % #config.sources + 1]
        gc:setColorRGB(source[5])
        drawPolygon(gc, i, source)
    end

end

function animation.update(now)
    now = now or timer.getMilliSecCounter()

    if not startTime then
        startTime = now
        previousTime = now
        return false
    end

    if now - startTime < config.startDelayMs then
        previousTime = now
        return false
    end

    local deltaSeconds = math.max(0, now - previousTime) / 1000
    previousTime = now
    local complete = #states == polygonCount
    local scanlines = config.scanlines
    local changed = deltaSeconds > 0 and (scanlines.speed ~= 0 or scanlines.pulseHz ~= 0)

    scanlineOffset = (scanlineOffset + scanlines.speed * deltaSeconds) % scanlines.spacing
    scanlinePulse = (scanlinePulse + deltaSeconds * scanlines.pulseHz * math.pi * 2) % (math.pi * 2)

    for _, state in ipairs(states) do
        if state.progress < 1 then
            state.progress = math.min(1, state.progress + state.speed * deltaSeconds)
            changed = true
        end
        if state.progress < 1 then complete = false end
    end

    if not complete then
        pauseStartTime = false
        return changed
    end

    if not pauseStartTime then
        pauseStartTime = now
        return changed
    end

    local pauseMs = config.morphs[targetIndex].pauseMs or config.pauseMs
    if now - pauseStartTime < pauseMs then return changed end

    fromTargets = toTargets
    targetIndex = targetIndex % #targets + 1
    toTargets = targets[targetIndex]

    for _, state in ipairs(states) do resetState(state) end
    pauseStartTime = false
    return changed
end

return animation

local component = require("component")
local buffer = require("doubleBuffering")
local pss = component.proxy("bab9a12d-657a-441b-8440-346b239658d0")

local h = 5
local w = math.floor(math.round(h * 13.1304347826087))
local storedCount = 30
local backColor = 0x1E1E1E
local textColor = 0xFFFFFF
local current = 0
local average = 0
local max = 0
local anim = 0
local t = ""

local storedHistory = {}
for i = 1, storedCount do
    storedHistory[i] = i
end
local storedTime = {}
for i = 1, storedCount do
    storedTime[i] = i
end
local iter = 1

local tickCounter = 5
local ticksToUpdate = 5

function drawEnergy()
    if tickCounter == ticksToUpdate then
        tickCounter = 0
        current = pss.getEUStored()
        storedHistory[iter] = current
        storedTime[iter] = os.time()
        average = (storedHistory[iter] - storedHistory[nextIter()]) / ((storedTime[iter] - storedTime[nextIter()]) / 3.6)
        iter = nextIter()
    else
        tickCounter = tickCounter + 1
    end
    buffer.clear(backColor)

    buffer.drawText(w/2 - 6, 1, textColor, "Average EU/t")
    if math.abs(average) < 100 or current >= max * 0.999 - 1000 then t = "----"
    else t = separator(math.floor(average)) end
    buffer.drawText(math.floor(w/2 - string.len(t) / 2), 2, textColor, t)

    buffer.drawText(3, 4, textColor, separator(math.floor(current)))
    t = separator(math.floor(max))
    buffer.drawText(w - string.len(t), 4, textColor, t)

    if math.abs(average) < 100 or current >= max * 0.999 - 1000 then t = "----"
    else
        if average > 0 then t = "Full in: "
        else t = "Empty in: " end
        t = t..getTime()
    end
    buffer.drawText(math.floor(w/2 - string.len(t) / 2), 5, textColor, t)

    progressBar(3, 3, w - 4, 1, current, max)
    animation()
    buffer.drawChanges()
end

function separator(val)
    local isNegative = false
    if val < 0 then
        val = math.abs(val)
        isNegative = true
    end
    local out = ""
    val = tostring(val)
    for i = 1, string.len(val), 3 do
        out = string.sub(val, -i - 2, -i).." "..out
    end
    if isNegative then out = "-"..out end
    return out
end

function animation()
    if anim > 100 then anim = math.random(-25, 0) end
    if anim < -25 then anim = math.random(75, 100) end

    if current <= max * 0.999 - 1000 then
        buffer.drawRectangle(math.floor(anim), 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ")
        if average > 0 then
            buffer.drawRectangle(math.floor(anim) - 3, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.75)
            buffer.drawRectangle(math.floor(anim) - 2, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.5)
            buffer.drawRectangle(math.floor(anim) - 1, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.25)
        else
            buffer.drawRectangle(math.floor(anim) + 3, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.75)
            buffer.drawRectangle(math.floor(anim) + 2, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.5)
            buffer.drawRectangle(math.floor(anim) + 1, 3, 1, 1, 0xFFFFFF, 0xFFFFFF, " ", 0.25)
        end
    end
    anim = anim + average / 20000
end

function progressBar(x, y, length, height, cur, max)
    local ratio = cur / (max * 0.999 - 1000)
    if ratio > 1.0 then ratio = 1.0 end
    buffer.drawRectangle(x, y, length, height, 0x000000, 0x000000, " ")
    buffer.drawRectangle(x, y, length * ratio, height, getColor(ratio), 0x000000, " ")
end

function getColor(ratio)
    if ratio >= 0.8 then return 0x00FF00
    elseif ratio >= 0.6 then return 0xCCFF00
    elseif ratio >= 0.4 then return 0xFFFF00
    elseif ratio >= 0.2 then return 0xFF7F00
    else return 0xFF0000 end
end

function nextIter()
    if iter == storedCount then return 1
    else return iter + 1 end
end

function getTime()
    local time = 0
    if average > 0 then
        time = (max - current) / average
    else
        time = current / math.abs(average)
    end
    time = time / 20
    local out = math.floor(time / 3600).."h "
    time = time % 3600
    out = out..math.floor(time / 60).."m"
    return out
end

max = pss.getEUMaxStored()
buffer.bindScreen("45314a9a-db82-4604-9f69-101332356c11")
buffer.setResolution(w, h)
buffer.clear(backColor)
buffer.drawChanges()
buffer.setDrawLimit(3, 1, w - 2, h)
while true do drawEnergy() os.sleep(0.01) end
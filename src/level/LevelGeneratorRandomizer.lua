LevelGeneratorRandomizer = Class {}

function LevelGeneratorRandomizer:init() end

---Returns random tileset index
---@return number
function LevelGeneratorRandomizer:getTileset()
    return math.random(20)
end


---Returns random topperset index
---@return number
function LevelGeneratorRandomizer:getTopperset()
    return math.random(20)
end

---Returns true if need a chasm
---@return boolean
function LevelGeneratorRandomizer:isChasm(column)
    return math.random(7) == 1
end

---Returns true in need a pillar
---@return boolean
function LevelGeneratorRandomizer:isPillar(column)
    return math.random(8) == 1
end

---Returns true if need a bush on the pillar
---@return boolean
function LevelGeneratorRandomizer:isBushOnPillar(column)
    return math.random(8) == 1
end

---Returns random bush from available
---@return number
function LevelGeneratorRandomizer:getBushFrameId()
    return BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
end

---Returns random id of the jump block frame
---@return number
function LevelGeneratorRandomizer:getJumpBlockFrameId()
    return math.random(#JUMP_BLOCKS)
end

---Returns true if need a jump block
---@return boolean
function LevelGeneratorRandomizer:isJumpBlock(column)
    return math.random(10) == 1
end

---Returns true if need spawn gem in block
---@return boolean
function LevelGeneratorRandomizer:isSpawnGem(column)
    return math.random(5) == 1
end

---Returns random id of the gem frame
---@return number
function LevelGeneratorRandomizer:getGemFrameId()
    return math.random(#GEMS)
end

function LevelGeneratorRandomizer:isBush(column)
    return math.random(8) == 1
end

function LevelGeneratorRandomizer:isSpawnLock(column, width)
    return (column > width * 0.8 and math.random(5) == 1)
        or column > width * 0.9
end

function LevelGeneratorRandomizer:getLockFrameId()
    return math.random(#LOCK_IDS)
end

function LevelGeneratorRandomizer:isSpawnKey(column, width)
    return ((column > width * 0.2) and math.random(5) == 1)
        or column > width * 0.6
end

function LevelGeneratorRandomizer:getPoleFrameId()
    return math.random(#POLE_IDS)
end

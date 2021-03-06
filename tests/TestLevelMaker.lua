local lu = require 'lib/luaunit'

--[[
    . empty
    # ground
    _ topper
    ^ bush
    o empty crate
    * gem crate
    b blocked
    k key crate
    | pole, real y coor less by 2
--]]

local TEST_TILESET = 1
local TEST_TOPPERSET = 2
local TEST_BUSH_FRAME_ID = 3
local TEST_CRATE_FRAME_ID = 4
local TEST_GEM_FRAME_ID = 5
local TEST_LOCK_FRAME_ID = 6
local TEST_POLE_FRAME_ID = 1

local function schemaToElements(schema)
    local result = {}
    for schemaRow in string.gmatch(string.gsub(schema, '%s*$', ''), '[^\n]+') do
        local row = {}
        for element in string.gmatch(string.gsub(schemaRow, '%s*', ''), '.') do
            table.insert(row, element)
        end
        table.insert(result, row)
    end
    return result
end

local function elementsToTiles(elements)
    local tiles = {}
    for y, row in pairs(elements) do
        local tilesRow = {}
        for x, element in pairs(row) do
            local tileId = TILE_ID_EMPTY
            local topper = nil
            if element == '#' then
                tileId = TILE_ID_GROUND
            elseif element == '_' or element == '^' then
                tileId = TILE_ID_GROUND
                topper = true
            elseif element == '.' then
                tileId = TILE_ID_EMPTY
            end
            local tile = Tile(x, y, tileId, topper, TEST_TILESET, TEST_TOPPERSET)
            table.insert(tilesRow, tile)
        end
        table.insert(tiles, tilesRow)
    end
    return tiles
end

local function elementsToObjects(elements)
    local objects = {}
    for y, row in pairs(elements) do
        for x, element in pairs(row) do
            if element == '^' then
                local bush = GameObject {
                    texture = 'bushes',
                    x = (x - 1) * TILE_SIZE,
                    y = (y - 2) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = TEST_BUSH_FRAME_ID,
                    collidable = false
                }
                table.insert(objects, 1, bush)
            elseif element == '*' then
                local gem = Gem(x, y, TEST_GEM_FRAME_ID)
                table.insert(objects, gem)
                local crate = Crate(x, y, TEST_CRATE_FRAME_ID, gem)
                table.insert(objects, crate)
            elseif element == 'o' then
                local crate = Crate(x, y, TEST_CRATE_FRAME_ID)
                table.insert(objects, crate)
            elseif element == 'b' then
                local blocked = Lock(x, y, TEST_LOCK_FRAME_ID)
                table.insert(objects, blocked)
            elseif element == 'k' then
                local key = Key(x, y, TEST_LOCK_FRAME_ID)
                table.insert(objects, key)
                local crate = Crate(x, y, TEST_CRATE_FRAME_ID, key)
                table.insert(objects, crate)
            elseif element == '|' then
                local pole = Pole(x, y - 2, TEST_POLE_FRAME_ID)
                table.insert(objects, pole)
            end
        end
    end
    return objects
end

local function createGameLevel(width, height, schema)
    local elements = schemaToElements(schema)
    local entities = {}
    local objects = elementsToObjects(elements)
    local map = TileMap(width, height)
    map.tiles = elementsToTiles(elements)
    return GameLevel(entities, objects, map)
end

local function assertLevelEquals(actual, expected)
    local function sortObjects(one, other)
        if one.texture == other.texture then
            if one.x == other.x then
                return one.y < other.y
            else
                return one.x < other.x
            end
        else
            return one.texture < other.texture
        end
    end
    table.sort(actual.objects, sortObjects)
    table.sort(expected.objects, sortObjects)
    -- lu.assertEquals(actual.tileMap, expected.tileMap, 'TileMap')
    -- lu.assertEquals(actual.objects, expected.objects, 'Objects')
    -- lu.assertEquals(actual.entities, expected.entities, 'Entities')
    lu.assertEquals(actual, expected)
end

TestLevelMaker = {}

function TestLevelMaker:test_generate_onlyGroundLevelWithoutObjects()
    local FakeRandomizer = Class{__includes = LevelGeneratorRandomizer}
    local randomizer = FakeRandomizer()
    function randomizer:isChasm() return false end
    function randomizer:isPillar() return false end
    function randomizer:isBush() return false end
    function randomizer:isJumpBlock() return false end
    function randomizer:getTileset() return TEST_TILESET end
    function randomizer:getTopperset() return TEST_TOPPERSET end
    function randomizer:getPoleFrameId() return TEST_POLE_FRAME_ID end

    local levelMaker = LevelMaker(randomizer)

    local width = 6
    local height = 9

    local tiles = {
        {Tile(1, 1, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 2, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 3, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 4, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 5, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 6, TILE_ID_EMPTY, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 7, TILE_ID_GROUND, true, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 8, TILE_ID_GROUND, nil, TEST_TILESET, TEST_TOPPERSET)},
        {Tile(1, 9, TILE_ID_GROUND, nil, TEST_TILESET, TEST_TOPPERSET)},
    }
    local expected = createGameLevel(width, height, [[
        ......
        ......
        ......
        ......
        ......
        ....|.
        ______
        ######
        ######
    ]])

    lu.assertEquals(levelMaker:generate(width, height), expected)
end

function TestLevelMaker:test_generate_simpleLevel()
    local FakeRandomizer = Class{__includes = LevelGeneratorRandomizer}
    local randomizer = FakeRandomizer()
    function randomizer:isChasm(column)
        return column == 6 or column == 7
    end
    function randomizer:isPillar(column)
        return column == 5 or column == 9 or column == 10
    end
    function randomizer:isBush(column)
        return column == 8
    end
    function randomizer:isBushOnPillar(column)
        return column == 10
    end
    function randomizer:isJumpBlock(column)
        return column == 5 or column == 8 or column == 10
    end
    function randomizer:isSpawnGem(column)
        return column == 8
    end
    function randomizer:isSpawnLock(column)
        return column == 9
    end
    function randomizer:isSpawnKey(column)
        return column == 5
    end
    function randomizer:getTileset() return TEST_TILESET end
    function randomizer:getTopperset() return TEST_TOPPERSET end
    function randomizer:getBushFrameId() return TEST_BUSH_FRAME_ID end
    function randomizer:getJumpBlockFrameId() return TEST_CRATE_FRAME_ID end
    function randomizer:getGemFrameId() return TEST_GEM_FRAME_ID end
    function randomizer:getLockFrameId() return TEST_LOCK_FRAME_ID end
    function randomizer:getPoleFrameId() return TEST_POLE_FRAME_ID end

    local levelMaker = LevelMaker(randomizer)

    local width = 13
    local height = 9

    local expected = createGameLevel(width, height, [[
        .............
        ....k...bo...
        .............
        .......*.....
        ...._..._^...
        ....#...##.|.
        ____#..^##___
        #####..######
        #####..######
    ]])

    assertLevelEquals(levelMaker:generate(width, height), expected)
end

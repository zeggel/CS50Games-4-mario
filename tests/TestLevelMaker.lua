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
--]]

local TEST_TILESET = 1
local TEST_TOPPERSET = 2
local TEST_BUSH_FRAME_ID = 3
local TEST_CRATE_FRAME_ID = 4
local TEST_GEM_FRAME_ID = 5

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
    lu.assertEquals(actual, expected)
end

TestLevelMaker = {}

function TestLevelMaker:test_generate_oneGroundColumnWithoutObjects()
    local FakeRandomizer = Class{__includes = LevelGeneratorRandomizer}
    local randomizer = FakeRandomizer()
    function randomizer:isChasm() return false end
    function randomizer:isPillar() return false end
    function randomizer:isBush() return false end
    function randomizer:isJumpBlock() return false end
    function randomizer:getTileset() return TEST_TILESET end
    function randomizer:getTopperset() return TEST_TOPPERSET end

    local levelMaker = LevelMaker(randomizer)

    local width = 1
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
        .
        .
        .
        .
        .
        .
        _
        #
        #
    ]])

    lu.assertEquals(levelMaker:generate(width, height), expected)
end

function TestLevelMaker:test_generate_simpleLevel()
    local FakeRandomizer = Class{__includes = LevelGeneratorRandomizer}
    local randomizer = FakeRandomizer()
    function randomizer:isChasm(column)
        return column == 3 or column == 4
    end
    function randomizer:isPillar(column)
        return column == 2 or column == 6 or column == 7
    end
    function randomizer:isBush(column)
        return column == 5
    end
    function randomizer:isBushOnPillar(column)
        return column == 7
    end
    function randomizer:isJumpBlock(column)
        return column == 5 or column == 7
    end
    function randomizer:isSpawnGem(column)
        return column == 5
    end
    function randomizer:getTileset() return TEST_TILESET end
    function randomizer:getTopperset() return TEST_TOPPERSET end
    function randomizer:getBushFrameId() return TEST_BUSH_FRAME_ID end
    function randomizer:getJumpBlockFrameId() return TEST_CRATE_FRAME_ID end
    function randomizer:getGemFrameId() return TEST_GEM_FRAME_ID end

    local levelMaker = LevelMaker(randomizer)

    local width = 7
    local height = 9

    local expected = createGameLevel(width, height, [[
        .......
        ......o
        .......
        ....*..
        ._..._^
        .#...##
        _#..^##
        ##..###
        ##..###
    ]])

    assertLevelEquals(levelMaker:generate(width, height), expected)
end

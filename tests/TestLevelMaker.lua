local lu = require 'lib/luaunit'

local TEST_TILESET = 1
local TEST_TOPPERSET = 2

local function createGameLevel(width, height, tiles, objects, entities)
    local map = TileMap(width, height)
    map.tiles = tiles or {}
    return GameLevel(entities or {}, objects or {}, map)
end

TestLevelMaker = {}

FakeRandomizer = Class{__includes = LevelGeneratorRandomizer}

function TestLevelMaker:test_generate_oneGroundColumnWithoutObjects()
    local randomizer = FakeRandomizer()
    function randomizer:isChasm() return false end
    function randomizer:isPillar() return false end
    function randomizer:isBush() return false end
    function randomizer:isJumpBlock() return false end
    function randomizer:getTileset() return 1 end
    function randomizer:getTopperset() return 2 end

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
    local expected = createGameLevel(width, height, tiles)

    lu.assertEquals(levelMaker:generate(width, height), expected)
end
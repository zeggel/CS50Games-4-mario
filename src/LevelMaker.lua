--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker:init(randomizer)
    self.randomizer = randomizer
end

function LevelMaker:generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    local keySpawned = false
    local lockSpawned = false
    local lockFrameId = self.randomizer:getLockFrameId()
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = self.randomizer:getTileset()
    local topperset = self.randomizer:getTopperset()

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    for x = 1, 3 do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        tileID = TILE_ID_GROUND
        for y = 7, height do
            table.insert(tiles[y],
                Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
        end
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 4, width - 3 do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if x > 1 and self.randomizer:isChasm(x) then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if self.randomizer:isPillar(x) then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if self.randomizer:isBushOnPillar(x) then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = self.randomizer:getBushFrameId(),
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif self.randomizer:isBush(x) then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = self.randomizer:getBushFrameId(),
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if not lockSpawned and self.randomizer:isSpawnLock(x, width) then
                local lock = Lock(x, blockHeight, lockFrameId)
                table.insert(objects, lock)
                lockSpawned = true
            elseif self.randomizer:isJumpBlock(x) then
                local inner
                if not keySpawned and self.randomizer:isSpawnKey(x, width) then
                    inner = Key(x, blockHeight, lockFrameId)
                    table.insert(objects, inner)
                    keySpawned = true
                elseif self.randomizer:isSpawnGem(x) then
                    inner = Gem(x, blockHeight, self.randomizer:getGemFrameId())
                    table.insert(objects, inner)
                end
                local crate = Crate(x, blockHeight, self.randomizer:getJumpBlockFrameId(), inner)
                table.insert(objects, crate)
            end
        end
    end

    for x = width - 2, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        tileID = TILE_ID_GROUND
        for y = 7, height do
            table.insert(tiles[y],
                Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
        end

        local blockHeight = 4
        if x == width - 1 then
            table.insert(objects, Pole(x, blockHeight, self.randomizer:getPoleFrameId()))
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end
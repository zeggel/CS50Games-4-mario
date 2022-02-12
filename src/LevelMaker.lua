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
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = self.randomizer:getTileset()
    local topperset = self.randomizer:getTopperset()

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
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
            if self.randomizer:isJumpBlock(x) then
                local gem
                if self.randomizer:isSpawnGem(x) or true then
                    gem = Gem(x, blockHeight, self.randomizer:getGemFrameId())
                    table.insert(objects, gem)
                end
                local crate = Crate(x, blockHeight, self.randomizer:getJumpBlockFrameId(), gem)
                table.insert(objects, crate)
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end
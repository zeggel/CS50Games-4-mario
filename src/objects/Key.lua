Key = Class{__includes = GameObject}

function Key:init(x, y, frameId)
    self.texture = 'keys-and-locks'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 16
    self.frame = KEY_IDS[frameId]
    self.collidable = false
    self.consumable = false
    self.solid = false
end

function Key:onConsume(player)
    gSounds['pickup']:play()
    -- player.score = player.score + 100
    player.hasKey = true
end

-- function Gem:render()
--     if self.visible then
--         GameObject.render(self)
--     end
-- end

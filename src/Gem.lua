Gem = Class{__includes = GameObject}

function Gem:init(x, y, frameId)
    self.texture = 'gems'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 16
    self.frame = frameId
    self.collidable = false
    self.consumable = false
    self.solid = false
end

function Gem:onConsume(player)
    gSounds['pickup']:play()
    player.score = player.score + 100
end

-- function Gem:render()
--     if self.visible then
--         GameObject.render(self)
--     end
-- end

Pole = Class{__includes = GameObject}

function Pole:init(x, y, frameId)
    self.texture = 'poles-and-flags'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 48
    self.frame = frameId
    self.collidable = false
    self.consumable = false
    self.solid = false
end

function Pole:render()
    love.graphics.draw(gTextures[self.texture], gFrames['poles'][self.frame], self.x, self.y)
end

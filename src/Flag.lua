Flag = Class{__includes = Entity}

function Flag:init(def)
    Entity.init(self, def)
end

function Flag:collides(entity)
    return false
end

function Flag:render()
    love.graphics.draw(
        gTextures[self.texture],
        gFrames['flags'][self.currentAnimation:getCurrentFrame()],
        self.x + 9,
        self.y + 5
    )
end
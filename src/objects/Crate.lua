Crate = Class{__includes = GameObject}

function Crate:init(x, y, frameId, innerObject)
    self.texture = 'jump-blocks'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 16

    self.frame = frameId
    self.collidable = true
    self.hit = false
    self.solid = true

    self.innerObject = innerObject
end

function Crate:onCollide()
    -- show an innerObject if we haven't already hit the block
    if not self.hit then

        if self.innerObject then
            self.innerObject.consumable = true
            self.innerObject.collidable = true
            -- make the inner object move up from the block and play a sound
            Timer.tween(0.1, {
                [self.innerObject] = {y = self.y - TILE_SIZE}
            })
            gSounds['powerup-reveal']:play()
        end

        self.hit = true
    end

    gSounds['empty-block']:play()
end

-- function Crate:render()
--     if self.innerObject then
--         self.innerObject:render()
--     end

--     GameObject.render(self)
-- end
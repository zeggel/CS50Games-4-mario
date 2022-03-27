Lock = Class{__includes = GameObject}

function Lock:init(x, y, frameId)
    self.texture = 'keys-and-locks'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 16

    self.frame = LOCK_IDS[frameId]
    self.consumable = true
    self.collidable = true
    self.hit = false
    self.solid = true
end

function Lock:onCollide()
    gSounds['empty-block']:play()
end

function Lock:onConsume(player)
    gSounds['powerup-reveal']:play()
    player.levelUnlocked = true
end

function Lock:collides(target)
    local collides = GameObject.collides(self, target)
    if collides and target.hasKey then
        self.solid = false
    end
    return collides
end
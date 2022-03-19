Lock = Class{__includes = GameObject}

function Lock:init(x, y, frameId)
    self.texture = 'keys-and-locks'
    self.x = (x - 1) * TILE_SIZE
    self.y = (y - 1) * TILE_SIZE
    self.width = 16
    self.height = 16

    self.frame = LOCK_IDS[frameId]
    self.collidable = true
    self.hit = false
    self.solid = true
end

function Lock:onCollide()
    
end
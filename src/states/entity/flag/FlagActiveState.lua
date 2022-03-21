FlagActiveState = Class{__includes = BaseState}

function FlagActiveState:init(tilemap, player, flag)
    self.tilemap = tilemap
    self.player = player
    self.flag = flag
    self.waitTimer = 0
    self.animation = Animation {
        frames = {7, 8},
        interval = 0.3
    }
    self.flag.currentAnimation = self.animation
    self.movingTimer = 0
end

function FlagActiveState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.flag.currentAnimation:update(dt)
end
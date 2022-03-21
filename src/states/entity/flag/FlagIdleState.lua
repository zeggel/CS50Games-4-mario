FlagIdleState = Class{__includes = BaseState}

function FlagIdleState:init(tilemap, player, flag)
    self.tilemap = tilemap
    self.player = player
    self.flag = flag
    self.waitTimer = 0
    self.animation = Animation {
        frames = {9},
        interval = 1
    }
    self.flag.currentAnimation = self.animation
end

function FlagIdleState:update(dt)
    if self.player.levelUnlocked then
        self.flag:changeState('active')
    end
end
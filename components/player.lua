Player = Class{
    init = function(self, x, y, spritesheet, spritewidth, spriteheight, speed)
        self.spritesheet = spritesheet
        self.spritewidth = spritewidth
        self.spriteheight = spriteheight
        self.x = x
        self.y = y

        self.speed = speed
               
        local g = anim8.newGrid(spritewidth, spriteheight, spritesheet:getWidth(), spritesheet:getHeight())
        self.animations = {
            right = anim8.newAnimation(g('1-4',1, '1-4',2),0.25),
            left = anim8.newAnimation( g('1-4',3, '1-4',4),0.25)
        }

        self.animation = self.animations.right
    end;

    update = function(self,dt)
                
        if love.keyboard.isDown("right") then
            self.animation = self.animations.right
            self.animation:resume()
        elseif love.keyboard.isDown("left") then
            self.animation = self.animations.left
            self.animation:resume()
        else
            self.animation:pause()
        end

        self.animation:update(dt)               
    end;
        
    draw = function(self)
        
        --bloom:predraw()
        --bloom:enabledrawtobloom()

        self.animation:draw(self.spritesheet, self.x, self.y)
        
        --bloom:postdraw()
    end;
}
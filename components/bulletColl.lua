BulletColl = Class{
    init = function(self)
        self.bullets = {}
    end;
        
    add = function(self, bullet)
        table.insert(self.bullets,bullet)
    end;
        
    update = function(self,dt)                
        local w = love.window.getWidth()
        local h = love.window.getHeight()
                
        for i,v in ipairs(self.bullets) do
                        
            v.x = v.x + (v.dx * dt)
            v.y = v.y + (v.dy * dt)
                        
            if (v.x < 0 or v.x > w or v.y < 0 or v.y > h) then
                table.remove(self.bullets, i)
                bulletsRemoved = bulletsRemoved + 1
            end
        end
    end;
        
    draw = function(self)                	
        love.graphics.setColor(240, 170, 40)
        for i,v in ipairs(self.bullets) do
            love.graphics.circle("fill",v.x,v.y,3)
        end
    end;
        
    Signals.register("fireNet",function(x,y,playerWidth,playerHeight,playerX,playerY)
                        
        local bc = Components.items[Components.names["bulletColl"]]
        local bulletSpeed = 450
                
        for i = 1, 5, 1 do
			local startX = playerX + playerWidth / 2
			local startY = playerY + playerHeight / 2
			local mouseX = x + (5 * i)
			local mouseY = y
			
			local angle = math.atan2((mouseY - startY), (mouseX - startX))
			
			local bulletDx = bulletSpeed * math.cos(angle)
			local bulletDy = bulletSpeed * math.sin(angle)

            bc:add(Bullet(startX,startY,bulletDx,bulletDy))
		end
    end)
}


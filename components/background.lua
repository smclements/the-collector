require "components.backgroundLayer"

Background = Class{
        
    init =  function(self)
                        	
        self.useColorTileSet = false;
        
        self.backgroundLayers = {}
        self.tileQuads = {}
        
        local tileSetImageName = "assets/image/trees.png";
        if (self.useColorTileSet) then
            tileSetImageName = "assets/image/4000x500_3.png"
        end
        
        self.tilesetImage = love.graphics.newImage(tileSetImageName)

        self.tilesetImage:setFilter("nearest", "linear") 

        self.spriteWidth = 256
        self.spriteHeight = 768
        
        local tileSetWidth = 2048;
        if (self.useColorTileSet) then
            tileSetWidth = 4000;
        end       
        for i=1, 8 do
            self.tileQuads[i] = love.graphics.newQuad( (i-1) * self.spriteWidth, 0, self.spriteWidth, self.spriteHeight, tileSetWidth, self.spriteHeight )
        end

        if (self.useColorTileSet) then
            table.insert(self.backgroundLayers,BackgroundLayer({5,3,5,4,5,6,5,8,7,7},0.45,{250,0,0,255},30,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({6,7,8,3,4,5,3,3,7,5,4},0.65,{250,0,0,255},50,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({8,7,6,5,4,3,4,6,7,5},0.85,{0,250,0,255},80,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({3,4,5,6,7,8},1.0,{0,0,0,255},110,0,0))
        else
            table.insert(self.backgroundLayers,BackgroundLayer({5,3,5,4,5,6,5,8,7,7},0.45,{115,115,115,230},30,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({6,7,8,3,4,5,3,3,7,5,4},0.65,{135,135,135,240},50,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({8,7,6,5,4,3,4,6,7,5},0.85,{205,205,205,250},80,0,0))
            table.insert(self.backgroundLayers,BackgroundLayer({3,4,5,6,7,8},1.0,{255,255,255,255},110,0,0))       
        end
    end;
                
    update = function(self,dt)
        if not love.keyboard.isDown("right") and not love.keyboard.isDown("left") then 
            return 
        end

        for i,v in ipairs(self.backgroundLayers) do

            local layer = v
            local modifier = love.keyboard.isDown("left") and 1 or -1

            layer.x = layer.x + (layer.scrollSpeed * modifier) * dt

            --self.wrap_indices(layer, modifier >= 0)
           if modifier >= 0 then
                if layer.x >= 0 then			
                    table.insert(layer.indices, 1, layer.indices[#layer.indices])
                    table.remove(layer.indices)
                    layer.x = 0 - (self.spriteWidth * layer.scale)
                end
            else
                if layer.x <= 0 - (self.spriteWidth * layer.scale) then			
                    table.insert(layer.indices, #layer.indices+1, layer.indices[1])
                    table.remove(layer.indices,1)	
                    layer.x = 0
                end
            end	                        
        end
    end;
                        
    draw = function(self)
        
        -- moon
        love.graphics.setColor(240,240,243)
        love.graphics.circle( "fill", 550, 170, 150, 100 )

        -- trees,  back row through to front row
        for i,v in ipairs(self.backgroundLayers) do
            
            local offset = 0
            local layer = v

            love.graphics.setColor(layer.color)
love.graphics.setColor(255,255,0)
love.graphics.setBlendMode("alpha")
            for ii,vv in ipairs(layer.indices) do
                love.graphics.draw( self.tilesetImage, self.tileQuads[vv], 
                                    layer.x + offset, 
                                    love.window.getHeight() - (layer.scale*self.spriteHeight) + layer.y, 
                                    0, layer.scale, layer.scale)
                offset = offset + (self.spriteWidth * layer.scale)
            end
                    
        end 
               
    end;
}
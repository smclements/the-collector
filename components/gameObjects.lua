
GameObjects = Class{
    init = function(self)
        self.items = {}
        self.names = {}
    end;
                        
    register = function(self,key,value)
        table.insert(self.items,value)
        self.names[key] = #self.items
    end;
                        
    remove = function(self,item)
        table.remove(self.items,item)
    end;
                        
    update = function(self,dt)
        for i,v in ipairs(self.items) do
            v:update(dt)
        end
    end;
                        
    draw = function(self)
        for i,v in ipairs(self.items) do
            v:draw()
        end
    end;
}


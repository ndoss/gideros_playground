-- License - http://creativecommons.org/publicdomain/zero/1.0/

stage:addChild(Bitmap.new(Texture.new("board.jpg")))
chalkTextures = {}
table.insert(chalkTextures, Texture.new("chalk1.png", true))
table.insert(chalkTextures, Texture.new("chalk2.png", true))
table.insert(chalkTextures, Texture.new("chalk3.png", true))
table.insert(chalkTextures, Texture.new("chalk4.png", true))
table.insert(chalkTextures, Texture.new("chalk5.png", true))

sim = EasyBox2d.new{stage, debug=false}
sim:createStageWalls{top=true, bottom=false, left=true, right=true, wallWidth=0.2}
sim:start()

Chalk = Core.class(Sprite)
function Chalk:init(x1,y1, x2,y2)
   self:setPosition(x1-5,y1-5)
   local particle = Bitmap.new(chalkTextures[math.random(1,5)])
   self:addChild(particle)
   self.edge = sim:addEdge{ x1=x1/30, y1=y1/30, x2=x2/30, y2=y2/30, lineWidth=10, lineColor = 0xffffff, lineAlpha=0.5 }
   stage:addChild(self)
   self.timer = Timer.new(25,50)
   self.timer:addEventListener(Event.TIMER, 
      function() 
         self:setAlpha(self:getAlpha()-.02) 
         self.edge.sprite:setAlpha(self.edge.sprite:getAlpha()-0.02)
      end)
   self.timer:addEventListener(Event.TIMER_COMPLETE, 
      function() 
         self:removeFromParent(); 
         sim:destroyBody(self.edge) 
         self.edge.sprite:removeFromParent()
      end)
   self.timer:start()
end

local v = nil
local mouseDown = false
local handleMouseDown = function(event) 
   v = { event.x, event.y }
   mouseDown = true
end

local handleMouseUp = function(event) 
   if mouseDown then
      Chalk.new(v[1], v[2], event.x, event.y)
   end
   mouseDown = false
end

local handleMouseMove = function(event) 
   if mouseDown then
      Chalk.new(v[1], v[2], event.x, event.y)
      v = { event.x, event.y }
   end
end

stage:addEventListener(Event.MOUSE_DOWN, handleMouseDown)
stage:addEventListener(Event.MOUSE_UP, handleMouseUp)
stage:addEventListener(Event.MOUSE_MOVE, handleMouseMove)


local timer = Timer.new(2000, 1)
timer:addEventListener(Event.TIMER_COMPLETE, function() 
  sim:addCircle{ x=3, y=1, radius=0.5, restitution=0.95, fillColor=0xcccccc, lineColor=0x000000, lineWidth=1, isBullet=true }
end)
timer:start()
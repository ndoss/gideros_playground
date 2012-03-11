
-- Create the water and update it periodically
local bins = 20
local layers = 3
local texture = Texture.new("water.jpg", true)

--[[
w = Water.new{ x=120, y=60, width=200, height=80, bezier=true, bins=bins, lineStyle = { 4 }}
w = Water.new{ x=360, y=60, width=200, height=80, bezier=true, bins=bins, fillStyle = { Shape.TEXTURE, texture, Matrix.new(1,0,0,1,0,-300) }}
w = Water.new{ x=120, y=260, width=200, height=80, bezier=true, velocityScale=20, viscosity=0.01, damping=0.98, bins=bins, fillStyle = { Shape.TEXTUREw = Water.new{ x=360, y=260, width=200, height=80, bezier=true, viscosity=0.995, damping=0.99, bins=bins, fillStyle = { Shape.SOLID, 0x777777, 0.3 }, 
w = Water.new{ x=360, y=160, width=200, height=80, bezier=true, bins=bins, fillStyle = { Shape.NONE }, lineStyle = { 8, 0x00ff00, 0.5 }}
w = Water.new{ x=120, y=160, width=200, height=80, bezier=true, bins=bins, fillStyle = { Shape.SOLID, 0xff0000, 0.5 }, lineStyle = { 1 }}
--]]

-- Add the water
math.randomseed(os.time())
list = {}
for i=1,layers do
   local fillStyle = { Shape.SOLID, 0x0088cc, 0.2 }
   if (i == 1) then
      fillStyle = { Shape.TEXTURE, texture, Matrix.new(1,0,0,1,0,-100) }
   end
   local w = Water.new{ 
      bins=bins, 
      fillStyle = fillStyle
   }
   stage:addChild(w)
   table.insert(list,w)
end

-- Use the mouse to add velocity to the water
local maxVel = application:getContentHeight()
local function addVelocity(event)
   local x     = event.x
   local y     = event.y
   local ratio = (y / application:getContentHeight() - 0.5);
   local vel   = ratio * maxVel
   for i,w in ipairs(list) do 
      w:setVelocity(bins * x/application:getContentWidth(), vel * math.random(0,2), math.random(3,6))
   end
end
stage:addEventListener(Event.MOUSE_DOWN, addVelocity)
stage:addEventListener(Event.MOUSE_MOVE, addVelocity)
stage:addEventListener(Event.MOUSE_UP,   addVelocity)


-- Add velocity based on timer 
local width     = application:getContentWidth()
local waterLine = application:getContentHeight() /2
local count     = 0
application:getContentHeight()
local timer = Timer.new(40,999999)
timer:addEventListener(Event.TIMER, 
   function() 
      local event = {}; 
      event.x    = count; 
      event.y    = waterLine+math.random(0,20); 
      addVelocity(event) 
      count      = (count + math.random(-5,30)) % width
   end)
timer:start()

-- Update the water every frame
local timer2 = Timer.new(40,999999)
timer2:addEventListener(Event.TIMER, function() for i,w in ipairs(list) do w:update() end end)
timer2:start()
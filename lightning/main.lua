-- Adapted from:
-- http://www.krazydad.com/bestiary/bestiary_lightning.html
-- http://developer.anscamobile.com/code/jake-gundersen


-- Settings to control the lightning
local bg        = 0
local curDetail = 1
local displace  = 100
local glowWidth = 20
local boltWidth = 3
local boltTime  = 500 -- ms
local boltColor = 0xffff88
local glowColor = 0xffffff
local glowAlpha = 0.05
local bgAdjust  = 0.3

-- Lightning example
stage:setBackgroundColor(0.0,0.0,0.0)

-- Draw lightning
local function drawLightning(shape, x1, y1, x2, y2, displace)
   if displace < curDetail then
      
      --glow around lightning
      shape:beginPath()
      shape:setLineStyle(glowWidth, glowColor, glowAlpha)
      shape:moveTo(x1,y1)
      shape:lineTo(x2,y2)
      shape:endPath()

      --bolt itself
      shape:setLineStyle(boltWidth, boltColor, 1)
      shape:moveTo(x1,y1)
      shape:lineTo(x2,y2)
      shape:endPath()

   else
      local midx = (x2+x1)/2
      local midy = (y2+y1)/2
      midx = midx + (math.random(0, 1) - 0.5)*displace
      midy = midy + (math.random(0, 1) - 0.5)*displace
      drawLightning(shape, x1, y1, midx, midy, displace/2)
      drawLightning(shape, x2, y2, midx, midy, displace/2)
   end
end

-- Function to stop the lightning and dim the background
local function endLightning(shape)
   stage:removeChild(shape) 
   bg = bg - bgAdjust
   stage:setBackgroundColor(bg,bg,bg)
end

-- On mouse press, create a shape to hold the lightning, 
--   draw lightning, brighten background, and set up 
--   timer to stop the lightning
local function onMouseDown(e)
   local shape = Shape.new()
   stage:addChild(shape)
   local start = math.random(0,width) / 2
   drawLightning(shape, start, 0, e.x, e.y, displace)

   bg = bg + bgAdjust
   stage:setBackgroundColor(bg,bg,bg)

   shape.timer = Timer.new(boltTime, 1)
   shape.timer:addEventListener(Event.TIMER, endLightning, shape)
   shape.timer:start()
end

-- Clicking the mouse will start a lightning bolt
stage:addEventListener(Event.MOUSE_DOWN, onMouseDown)

-- License - http://creativecommons.org/publicdomain/zero/1.0/

es = NdShape.new()
stage:addChild(es)

-- cartoon caption
es:setLineStyle(2)
es:setFillStyle(Shape.SOLID, 0x0000cc, 0.7)
es:beginPath()  
es:moveTo(225,25)  
es:quadraticCurveTo(175,25,175,62.5)  
es:quadraticCurveTo(175,100,200,100)  
es:quadraticCurveTo(200,120,180,125)  
es:quadraticCurveTo(210,120,215,100)  
es:quadraticCurveTo(275,100,275,62.5)  
es:quadraticCurveTo(275,25,225,25)  
es:fill()  

-- heart
es:setLineStyle(4)
es:setFillStyle(Shape.SOLID, 0xbb0000)
es:beginPath()  
es:moveTo(175,140)  
es:bezierCurveTo(175,137,170,125,150,125)  
es:bezierCurveTo(120,125,120,162.5,120,162.5)  
es:bezierCurveTo(120,180,140,202,175,220)  
es:bezierCurveTo(210,202,230,180,230,162.5)  
es:bezierCurveTo(230,162.5,230,125,200,125)  
es:bezierCurveTo(185,125,175,137,175,140)  
es:fill()  

-- Draw shapes
-- https://developer.mozilla.org/samples/canvas-tutorial/2_4_canvas_arc.html
for i=0,3 do
   for j=0,2 do
      es:beginPath()
      local x          = 25+j*50               -- x coordinate
      local y          = 25+i*50               -- y coordinate
      local radius     = 20                    -- Arc radius
      local startAngle = 0                     -- Starting point on circle
      local endAngle   = math.pi+(math.pi*j)/2 -- End point on circle
      local clockwise  = true
      if i%2==0 then clockwise = false end     -- clockwise or anticlockwise
         
      es:arc(x,y,radius,startAngle,endAngle, clockwise)
      
      if i>1 then
         es:fill()
      else 
         es:stroke()
      end
   end
end

-- FIX: Something not quite right? ... is it curve functions or this one?
function roundedRect(ctx,x,y,width,height,radius)
  ctx:beginPath();
  ctx:moveTo(x,y+radius);
  ctx:lineTo(x,y+height-radius);
  ctx:quadraticCurveTo(x,y+height,x+radius,y+height);
  ctx:lineTo(x+width-radius,y+height);
  ctx:quadraticCurveTo(x+width,y+height,x+width,y+height-radius);
  ctx:lineTo(x+width,y+radius);
  ctx:quadraticCurveTo(x+width,y,x+width-radius,y);
  ctx:lineTo(x+radius,y);
  ctx:quadraticCurveTo(x,y,x,y+radius);
  ctx:fill();
end

es:setLineStyle(4)
es:setFillStyle(Shape.SOLID, 0xff00ff, 0.5)
roundedRect(es, 60,260,100,100, 20)


-- Quick & dirty polygon drawing
local cs = nil
path = {}

stage:addEventListener(Event.MOUSE_DOWN, function(event) 
                          cs = NdShape.new()
                          cs:setLineStyle(4)
                          cs:moveTo(event.x,event.y)
                          table.insert(path, {event.x, event.y})
                          stage:addChild(cs)
                                         end)

stage:addEventListener(Event.MOUSE_UP, function(event) 
                          cs:lineTo(event.x,event.y)
                          cs:closePath()
                          cs:endPath()
                          table.insert(path, {event.x, event.y})
                          cs:clear()
                          cs:setLineStyle(4)
                          cs:setFillStyle(Shape.SOLID, 0x00ff00, 0.5)
                          cs:beginPath()
                          cs:path(path)
                          cs:closePath()
                          cs:endPath()
                          cs = nil
                          path = {}
                                       end)

stage:addEventListener(Event.MOUSE_MOVE, function(event) 
                          cs:lineTo(event.x,event.y)
                          cs:endPath()
                          cs:beginPath()
                          cs:moveTo(event.x,event.y)
                          table.insert(path, {event.x, event.y})
                                         end)


-- Adapted from https://developer.mozilla.org/samples/canvas-tutorial/2_7_canvas_combined.html
ctx = NdShape.new()
ctx:setPosition(150,300)
ctx:setLineStyle(1)
ctx:setFillStyle(Shape.SOLID, 0xffffff)
stage:addChild(ctx)

-- Draw shapes
roundedRect(ctx,12,12,150,150,15)
roundedRect(ctx,19,19,150,150,9)
roundedRect(ctx,53,53,49,33,10)
roundedRect(ctx,53,119,49,16,6)
roundedRect(ctx,135,53,49,33,10)
roundedRect(ctx,135,119,25,49,10)

-- Character 1 
ctx:beginPath()
ctx:setFillStyle(Shape.SOLID, 0x000000)
ctx:arc(37,37,13,math.pi/7,-math.pi/7,false)
ctx:lineTo(34,37)
ctx:fill()

-- blocks 
for i=0,7 do
   ctx:fillRect(51+i*16,35,4,4)
end
for i=0,5 do
   ctx:fillRect(115,51+i*16,4,4)
end
for i=0,7 do
   ctx:fillRect(51+i*16,99,4,4)
end

-- character 2 -- FIX: eyes of pacman aren't right
ctx:beginPath()
ctx:setFillStyle(Shape.SOLID, 0x00cccc)
ctx:moveTo(83,116)
ctx:lineTo(83,102)
ctx:bezierCurveTo(83,94,89,88,97,88)
ctx:bezierCurveTo(105,88,111,94,111,102)
ctx:lineTo(111,116)
ctx:lineTo(106.333,111.333)
ctx:lineTo(101.666,116)
ctx:lineTo(97,111.333)
ctx:lineTo(92.333,116)
ctx:lineTo(87.666,111.333)
ctx:lineTo(83,116)
ctx:fill()
ctx:beginPath()
ctx:setFillStyle(Shape.SOLID, 0xffffff)
ctx:moveTo(91,96)
ctx:bezierCurveTo(88,96,87,99,87,101)
ctx:bezierCurveTo(87,103,88,106,91,106)
ctx:bezierCurveTo(94,106,95,103,95,101)
ctx:bezierCurveTo(95,99,94,96,91,96)
ctx:moveTo(103,96)
ctx:bezierCurveTo(100,96,99,99,99,101)
ctx:bezierCurveTo(99,103,100,106,103,106)
ctx:bezierCurveTo(106,106,107,103,107,101)
ctx:bezierCurveTo(107,99,106,96,103,96)
ctx:fill()
ctx:setFillStyle(Shape.SOLID, 0x000000)
ctx:beginPath()
ctx:arc(101,102,2,0,math.pi*2,true)
ctx:fill()
ctx:beginPath()
ctx:arc(89,102,2,0,math.pi*2,true)
ctx:fill()


context = NdShape.new()
stage:addChild(context)
local centerX = 150
local centerY = 300
local radius = 75;
local startingAngle = 1.1 * math.pi;
local endingAngle = 1.9 * math.pi;
local counterclockwise = false;
 
context:setLineStyle(15, 0x000000)
context:arc(centerX, centerY, radius, startingAngle, endingAngle);
context:stroke();

context:setLineStyle(15, 0x0000CC)
context:arc(centerX, centerY+50, radius, startingAngle, endingAngle, false);
context:stroke();

context:setLineStyle(15, 0xCC0000)
context:arc(centerX, centerY+100, radius, startingAngle, endingAngle, true);
context:stroke();


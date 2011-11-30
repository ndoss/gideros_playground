
require("json")
require("box2d")

local function readBox2dJsonFile(file)
   local file = io.open(file,"r")
   local text = file:read("*all")
   io.close(file)
   local out = json.decode(text)
   return out.assets
end

local function toVertices(vertices)
   local vert = {}
   for i,v in ipairs(vertices) do
      table.insert(vert, v.x)
      table.insert(vert, v.y)
   end
   return vert
end

stage:setBackgroundColor(0,0,0)
local sprite = Shape.new()
stage:addChild(sprite)

local height = application:getLogicalWidth()
local width  = application:getLogicalHeight()

local world  = b2.World.new(0, 9.6, true)
b2.setScale(10)

local debugDraw = b2.DebugDraw.new()
debugDraw:setScale(1)
stage:addChild(debugDraw)
world:setDebugDraw(debugDraw)

local ground = world:createBody{}
ground:createFixture{
   shape = b2.EdgeShape.new(0, 0.9 * height, width, 0.9 * height), 
   density = 0
}

bodyList = readBox2dJsonFile("bodies.json")

count = 1

for i_body,v_body in ipairs(bodyList) do

   local body = world:createBody{
      type = b2.DYNAMIC_BODY, 
      position = { x=count * width/3, y=height/3}, 
      angle=(180 * 180 / math.pi) 
   }

--[[ IMAGES DON'T ALIGN WITH SHAPES
   local image = Bitmap.new(Texture.new(v_body.relativePath))
   image.body = body 
   sprite:addChild(image)
   ]]

   for i_poly, v_poly in ipairs(v_body.polygons) do

      local shape = b2.PolygonShape.new()
      shape:set(unpack(toVertices(v_poly.vertices)))
      body:createFixture{shape = shape, density = 5, friction = 0.2}

   end

   count = count + 1
end

local function onEnterFrame()
   world:step(1/60, 8, 3)
   
   for i=1,sprite:getNumChildren() do
      local s    = sprite:getChildAt(i)
      local body = s.body
      
      s:setPosition(body:getPosition())
      s:setRotation(body:getAngle() * 180 / math.pi)
   end
   
end
sprite:addEventListener(Event.ENTER_FRAME, onEnterFrame)


local mouseJoint = nil

function onMouseDown(event)
   local x = event.x
   local y = event.y
   local fixtures = world:queryAABB(x - 0.001, y - 0.001, x + 0.001, y + 0.001)
   if #fixtures > 0 then
      local body = fixtures[1]:getBody()
      local jd = b2.createMouseJointDef(ground, body, event.x, event.y, 100000)
      mouseJoint = world:createJoint(jd)
   end
   
end
stage:addEventListener(Event.MOUSE_DOWN, onMouseDown)

function onMouseMove(event)
   if mouseJoint then
      mouseJoint:setTarget(event.x, event.y)
   end
end
stage:addEventListener(Event.MOUSE_MOVE, onMouseMove)

function onMouseUp(event)
   if mouseJoint then
      world:destroyJoint(mouseJoint)
      mouseJoint = nil
   end
end
stage:addEventListener(Event.MOUSE_UP, onMouseUp)

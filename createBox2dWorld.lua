-- License:  MIT
require("box2d")

-- ------------------------------------------------------------------------------------
local function toVertices(vertices)
   local vert = {}
   for i,v in ipairs(vertices.x) do
      table.insert(vert, vertices.x[i])
      table.insert(vert, vertices.y[i])
   end
   return vert
end

-- ------------------------------------------------------------------------------------
local createFixture = function(body, t, parent)
   if t.edge then
      t.shape = b2.EdgeShape.new(t.edge.vertex1.x, t.edge.vertex1.y, t.edge.vertex2.x, t.edge.vertex2.y)
   end
   if t.loop then
      t.shape = b2.PolygonShape.new()
      t.shape:set(unpack(toVertices(t.loop.vertices)))
   end
   if t.polygon then
      t.shape = b2.PolygonShape.new()
      t.shape:set(unpack(toVertices(t.polygon.vertices)))
   end
   if t.circle then
      if type(t.circle.center) ~= "table" then 
         t.circle.center = { x = t.circle.center, y = t.circle.center }
      end
      t.shape = b2.CircleShape.new(t.circle.center.x, t.circle.center.y, t.circle.radius)
   end
   return body:createFixture(t)
end

-- ------------------------------------------------------------------------------------
local createBody = function(world, t, parent)
   if (not t.fixture) then return nil end

   if type(t.linearVelocity) ~= "table" then 
      t.linearVelocity = { x=t.linearVelocity, y=t.linearVelocity }
   end
   if type(t.position) ~= "table" then 
      t.position = { x=t.position, y=t.position }
   end

   local body   = world:createBody(t)
   local sprite = Sprite.new()
   sprite.body = body
   parent:addChild(sprite)

   for i,v in ipairs(t.fixture) do
      body[i] = createFixture(body, v, sprite)
      if (v.name) then body[v.name] = body[i] end
   end

   return body
end

-- ------------------------------------------------------------------------------------
local jointType = {
   revolute  = b2.REVOLUTE_JOINT;
   prismatic = b2.PRISMATIC_JOINT;
   distance  = b2.DISTANCE_JOINT;
   pulley    = b2.PULLEY_JOINT;
   mouse     = b2.MOUSE_JOINT;
   gear      = b2.GEAR_JOINT;
   wheel     = b2.WHEEL_JOINT;
   weld      = b2.WELD_JOINT;
   line      = b2.LINE_JOINT;
}

-- ------------------------------------------------------------------------------------
local createJoint = function(world, t, body)
   t.bodyA          = body[t.bodyA+1]
   t.bodyB          = body[t.bodyB+1]
   t.localAnchorA   = t.anchorA
   t.localAnchorB   = t.anchorB
   t.referenceAngle = t.refAngle
   t.type           = jointType[t.type]
   return world:createJoint(t)
end

-- ------------------------------------------------------------------------------------
box2dToScene = function(t, parent)
   scene = {}

   scene.world  = b2.World.new(t.gravity.x or 0, t.gravity.y or 0, t.allowSleep or true)
   debugDraw = b2.DebugDraw.new()
   parent:addChild(debugDraw)
   scene.world:setDebugDraw(debugDraw)
   scene.ground = scene.world:createBody({})

   scene.body   = {}
   if t.body then
      for i,v in ipairs(t.body) do
         scene.body[i] = createBody(scene.world, v, parent)
         if (v.name) then scene.body[v.name] = scene[i] end
      end
   end

   scene.joint  = {}
   if t.joint then
      for i,v in ipairs(t.joint) do
         scene.joint[i] = createJoint(scene.world, v, scene.body)
         if (v.name) then scene.joint[v.name] = scene.joint[i] end
      end
   end

   return scene
end

-- ------------------------------------------------------------------------------------
function createBox2dWorld(file, parent)
   file = io.open(file,"r")
   text = file:read("*all")
   io.close(file)
   out = json.decode(text)
   return box2dToScene(out, parent)
end

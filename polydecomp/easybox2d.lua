-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- --------------------------------------------------------------------------------
require("box2d")
myscale = 30
b2.setScale(1)

-- --------------------------------------------------------------------------------
-- TODO
-- - refactoring
--   - mixins for generic object functions
--   - add support for arbitrary polygons
--     - auto partitioning of polygons (<=8points, clockwise, convex)
-- - grouping
-- - skinning
-- - slicing
-- - add correct buoyancy physics
-- - breakable 
-- - sleeping shatter
-- - filter
-- - frame rate independent
-- - camera
-- - screen walls - add options for which walls to draw
-- - shape library
--   - bezier curves
--   - quadratic curve
--   - rectangle
--   - rounded rectangle - radiusx radiusy (radius)
--   - circle
--   - arc
--   - drawRect, drawRoundRect, drawCircle, drawEllipse
--   - curveTo, drawTriangles, gradient fill?

-- --------------------------------------------------------------------------------
-- Generic function for handling defaults
-- --------------------------------------------------------------------------------
local function genericSetDefaults(params, defaults)
   if params == nil then
      params = defaults
   elseif defaults then
      for k,v in pairs(defaults) do
         if not params[k] then
            params[k] = v
         end
      end
   end
   return params
end


-- --------------------------------------------------------------------------------
-- EasyBox2d
-- --------------------------------------------------------------------------------
EasyBox2d = gideros.class(EventDispatcher)

-- --------------------------------------------------------------------------------
function EasyBox2d:init(t)
   -- Create the world
   self.w  = b2.World.new(t.xGravity or 0, t.yGravity or 9.6, t.doSleep or true)
   self.parent = t[1] or t.parent or stage
   self.scale  = myscale
   self.gravity = { x = t.xGravity or 0, y = t.yGravity or 9.6 };
   self.controllers = {}
   self.objects = {}

   -- Set up debug draw
   if t.debug then
      self.debugDraw = b2.DebugDraw.new()
      self.debugDraw:setScale(myscale)
      self.debugDraw:setFlags(b2.DebugDraw.SHAPE_BIT + b2.DebugDraw.JOINT_BIT + b2.DebugDraw.PAIR_BIT + b2.DebugDraw.CENTER_OF_MASS_BIT)
      --other bits: b2.DebugDraw.AABB_BIT + b2.DebugDraw.CENTER_OF_MASS_BIT)
      self.parent:addChild(self.debugDraw)
      self.w:setDebugDraw(self.debugDraw)
   end

   -- Create a ground object
   self.ground = self.w:createBody{}

   -- Set global defaults
   self.defaults = { 
      -- body parameters
      type = b2.DYNAMIC_BODY, -- b2.KINEMATIC_BODY, b2.STATIC_BODY
      x = 3,
      y = 3,
      angle = 0.0,
      --linearVelocity = { x=0, y=0 },
      xVelocity = 0, 
      yVelocity = 0,
      angularVelocity = 0,
      linearDamping = 0,
      angularDamping = 0,
      allowSleep =  true, 
      awake = true,
      fixedRotation = false,
      bullet = false,
      active = true,
      gravityScale = 1,

      -- fixture parameters
      -- shape (required)
      friction = 0.5, 
      restitution = 0.2, 
      density = 1.0, 
      isSensor = false,
      -- filter

      -- display parameters
      scaleSkin = true,
      lineThickness = 1,
      lineColor = 0x000000,
      lineAlpha = 1,
      fillColor = 0xCCCCCC, 
      fillAlpha = 1,

      -- OTHER?
      maskBits = 0xFFFF, 
      categoryBits = 1, 
      groupIndex = 0,
      draggable =  true,
   } 

end

-- --------------------------------------------------------------------------------
function EasyBox2d:addController(c)
   self.controllers[c] = true
end

-- --------------------------------------------------------------------------------
function EasyBox2d:removeController(c)
   self.controllers[c] = nil
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addObject(o)
   self.objects[o] = true
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addBox(t)
   local o = EasyBox.new(self,t)
   self:addObject(o)
   return o
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addPolygon(t)
   local o = EasyPolygon.new(self,t)
   self:addObject(o)
   return o
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addCircle(t)
   local o = EasyCircle.new(self,t)
   self:addObject(o)
   return o
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addRope(t)
   local o = EasyRope.new(self,t)
   self:addObject(o)
   return o
end

-- --------------------------------------------------------------------------------
function EasyBox2d:addJellyBox(t)
   local o = EasyJellyBox.new(self,t)
   self:addObject(o)
   return o
end

-- --------------------------------------------------------------------------------
function EasyBox2d:onEnterFrame()
   self.w:step(1/60, 8, 3)

   for k,v in pairs(self.objects) do
      k:update(self)
   end

   for controller,v in pairs(self.controllers) do
      controller:step(self)
   end
end

-- --------------------------------------------------------------------------------
function EasyBox2d:start()
   self.parent:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- --------------------------------------------------------------------------------
function EasyBox2d:stop()
   self.parent:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- --------------------------------------------------------------------------------
function EasyBox2d:createStageWalls(t)
   if not t then
      t = {}
   end
   local width  = self.parent:getWidth()/self.scale
   local height = self.parent:getHeight()/self.scale
   if width == 0 or height == 0 then
      width  = application:getContentWidth()/self.scale
      height = application:getContentHeight()/self.scale
   end

   local wallWidth = t.wallWidth or 1

   if t.left == nil or t.left == true then
      self:addBox{x=0 , y=height/2, width=wallWidth, height=height, density=0, fillColor=0xaaaaaa}
   end
   if t.right == nil or t.right == true then
      self:addBox{x=width , y=height/2, width=wallWidth, height=height, density=0, fillColor=0xaaaaaa}
   end
   if t.top == nil or t.top == true then
      self:addBox{x=width/2, y=0, width=width, height=wallWidth, density=0, fillColor=0xaaaaaa}
   end
   if t.bottom == nil or t.bottom == true then
      self:addBox{x=width/2, y=height, width=width, height=wallWidth, density=0, fillColor=0xaaaaaa}
   end
end

-- --------------------------------------------------------------------------------
function EasyBox2d:onMouseDown(event)
   local x = event.x/self.scale
   local y = event.y/self.scale
   local fixtures = self.w:queryAABB(x - 0.00001, y - 0.00001, x + 0.00001, y + 0.00001)
   if #fixtures > 0 then
      local body = fixtures[1]:getBody()
      local jd   = b2.createMouseJointDef(self.ground, body, x, y, 100000)
      self.mouseJoint = self.w:createJoint(jd)
   end
end
function EasyBox2d:onMouseMove(event)
   if self.mouseJoint then
      self.mouseJoint:setTarget(event.x/self.scale, event.y/self.scale)
   end
end
function EasyBox2d:onMouseUp(event)
   if self.mouseJoint then
      self.w:destroyJoint(self.mouseJoint)
      self.mouseJoint = nil
   end
end

function EasyBox2d:mouseDrag(flag)

   -- Deal w/ mouse events
   self.mouseJoint = nil

   if flag then
      self.parent:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
      self.parent:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
      self.parent:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
   else
      self.parent:removeEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
      self.parent:removeEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
      self.parent:removeEventListener(Event.MOUSE_UP, self.onMouseUp, self)
   end
end


function EasyBox2d:defaultParams(params)
   if not params then
      params = {}
   end
   for k,v in pairs(self.defaults) do
      if not params[k] then
         params[k] = v
      end
   end
end

function EasyBox2d:setDefaults(defaults)
   if not self.defaults then
      self.defaults = defaults
   else
      for k,v in pairs(defaults) do
         self.defaults[k] = v
      end
   end
end


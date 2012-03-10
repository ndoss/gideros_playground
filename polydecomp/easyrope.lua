-- --------------------------------------------------------------------------------
-- EasyRope
-- --------------------------------------------------------------------------------
EasyRope = gideros.class(EventDispatcher)
function EasyRope:init(ebox, t)

   local links = t.links or 20
   local body1 = t.body1.body
   local body2 = t.body2.body
   local p1 = { body1:getPosition() }
   local p2 = { body2:getPosition() }

   self.bodies = {}
   self.bodies[1]     = body1
   self.bodies[links] = body2

   for i = 2,(links-1) do
      local ratio = i/links
      local x = p1[1] + (p2[1] - p1[1]) * ratio
      local y = p1[2] + (p2[2] - p1[2]) * ratio

      local body = ebox.w:createBody{type=b2.DYNAMIC_BODY, position={x=x,y=y}, gravityScale = t.gravityScale or 1 }
      local shape = b2.CircleShape.new(0,0,0.025)
      local fixture = body:createFixture{shape=shape, filter = t.filter or { } }

      self.bodies[i] = body
   end

   self.length = math.sqrt( math.pow(p1[1]-p2[1],2) + math.pow(p1[2]-p2[2],2) ) / links

   for i = 1,(links-1) do
      local j = ebox.w:createJoint{
         type = b2.DISTANCE_JOINT,
         bodyA = self.bodies[i],
         bodyB = self.bodies[i+1],
         localAnchorA = { x=0, y=0 },
         localAnchorB = { x=0, y=0 },
         length = self.length,
         frequencyHz = 0,
         dampingRatio = 1,
      }
   end

   self.lineStyle = { t.lineWidth or 3, t.lineColor or 0x000000, t.lineAlpha or 1 }
   self.sprite = Shape.new()
   ebox.parent:addChild(self.sprite)
   self:draw(ebox)

   return self
end

function EasyRope:update(ebox)
   local body = self.bodies[1]
   local x,y = body:getPosition()
   self:draw(ebox)
end

function EasyRope:draw(ebox)
   self.sprite:clear()
   self.sprite:setLineStyle(unpack(self.lineStyle))
   self.sprite:beginPath()
   for i,v in ipairs(self.bodies) do
      local x,y =  v:getPosition() 
      self.sprite:lineTo(x*ebox.scale,y*ebox.scale)
   end
   self.sprite:endPath()
end

function EasyRope:submergedArea(waterLevel)
   area = 0
   for i,body in ipairs(self.bodies) do
      local x,y = body:getPosition()
      if y > waterLevel then
         area = area + 0.05 * self.length
      end
   end
   return area
end

--[[ bezier rope ... doesn't seem to look much better -- maybe make this an option
function EasyRope:curveB3(shape, scale, p1, p2, p3, mu)
   p1 = { x=p1[1]*scale, y=p1[2]*scale }
   p2 = { x=p2[1]*scale, y=p2[2]*scale }
   p3 = { x=p3[1]*scale, y=p3[2]*scale }

   shape:moveTo(p1.x,p1.y)
   for i = 0,1,mu do
      local p = bezier3(p1,p2,p3,i)
      shape:lineTo(p.x,p.y)
   end
end

function EasyRope:draw(ebox)
   if self.sprite then
      self.sprite:removeFromParent()
   end
   
   self.sprite = Shape.new()
   self.sprite:setLineStyle(unpack(self.lineStyle))

   self.sprite:beginPath()
   local numBodies = #self.bodies
   for i = 1,numBodies-2,1 do
      if (i-1) % 2 == 0 then
         self:curveB3(self.sprite, ebox.scale,
                      {self.bodies[i]:getPosition()}, 
                      {self.bodies[i+1]:getPosition()}, 
                      {self.bodies[i+2]:getPosition()}, 0.1)
      end
   end
   self.sprite:endPath()

   ebox.parent:addChild(self.sprite)
end
--]]

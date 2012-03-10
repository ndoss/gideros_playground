-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- --------------------------------------------------------------------------------
-- EasyPolygon
-- --------------------------------------------------------------------------------
EasyPolygon = gideros.class(EventDispatcher)
function EasyPolygon:init(ebox, t)

   local type = t.type or b2.DYNAMIC_BODY
   if not t.type and t.density and t.density == 0 then 
      type = b2.STATIC_BODY 
   end

   self.bodyDef = {
      type = type,
      position = { x=t.x, y=t.y },
      angle = t.angle or 0,
      linearVelocity = { x=0, y=0 },
      angularVelocity = 0,
      linearDamping = 0,
      angularDamping = 0,
      allowSleep = true,
      awake = true,
      fixedRotation = false,
      bullet = t.isBullet or false,
      active = true,
      gravityScale = 1,
   }

   self.body = ebox.w:createBody(self.bodyDef)

   local v = t.polys
   self.shapes = {}
   self.fixtures = {}
   self.fixtureDefs = {}
   for i=1,#v do
      self.shapes[i] = b2.PolygonShape.new()
      self.shapes[i]:set(unpack(v[i]))
      self.fixtureDefs[i] = {
         shape = self.shapes[i],
         friction = 0.5,
         restitution = t.restitution or 0.2,
         density = t.density or 1,
         isSensor = false,
      }
      self.fixtures[i] = self.body:createFixture(self.fixtureDefs[i])
   end

   
   local fillStyle = t.fillStyle or { Shape.SOLID, t.fillColor or 0xFFFFFF, t.fillAlpha or 1 }
   local lineStyle = t.lineStyle or { t.lineWidth or 1, t.lineColor or 0x000000, t.lineAlpha or 1 }
   self.sprite = NdShape.new()
   self.sprite:setFillStyle(unpack(fillStyle))
   self.sprite:setLineStyle(unpack(lineStyle))

   self.sprite:beginPath()
   self.sprite:path(t.outline)
   self.sprite:closePath()
   self.sprite:endPath()
   self.sprite.body = self.body
   self.sprite:setPosition(0,0)

   ebox.parent:addChild(self.sprite)

   return self
end

function EasyPolygon:update(ebox)
   local body = self.body
   local x,y = body:getPosition()
   self.sprite:setPosition(x*ebox.scale, y*ebox.scale)
   self.sprite:setRotation(body:getAngle() * 180 / math.pi)
end
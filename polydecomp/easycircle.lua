-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- --------------------------------------------------------------------------------
-- EasyCircle
-- --------------------------------------------------------------------------------
EasyCircle = gideros.class(EventDispatcher)
function EasyCircle:init(ebox, t)

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

   self.shape = b2.CircleShape.new(0,0,t.radius)

   self.fixtureDef = {
      shape = self.shape,
      friction = 0.5,
      restitution = t.restitution or 0.2,
      density = t.density or 1,
      isSensor = false,
   }
   self.fixture = self.body:createFixture(self.fixtureDef)

   local fillStyle = { Shape.SOLID, t.fillColor or 0xFFFFFF, t.fillAlpha or 1 }
   local lineStyle = { t.lineWidth or 1, t.lineColor or 0x000000, t.lineAlpha or 1 }
   self.sprite = Shape.new()
   self.sprite:setFillStyle(unpack(fillStyle))
   self.sprite:setLineStyle(unpack(lineStyle))
   self.sprite:beginPath()
   self.radius = t.radius * ebox.scale
   local sides = self.radius
   local angleStep = 1 / sides
   for i = 0,sides do
      local angle = i * angleStep
      self.sprite:lineTo(math.cos(angle*2*math.pi) * self.radius,
                         math.sin(angle*2*math.pi) * self.radius)
   end
   self.sprite:closePath()
   self.sprite:endPath()
   self.sprite.body = self.body
   self.sprite:setPosition(t.x*ebox.scale, t.y*ebox.scale)

   ebox.parent:addChild(self.sprite)

   return self
end

function EasyCircle:submergedArea(waterLevel)
   local x,y = self.body:getPosition()
   local area = math.pi * self.radius * (self.radius + y - waterLevel) / 2
   if (area < 0) then area = 0 end
   return area
end

function EasyCircle:update(ebox)
   local body = self.body
   local x,y = body:getPosition()
   self.sprite:setPosition(x*ebox.scale, y*ebox.scale)
   self.sprite:setRotation(body:getAngle() * 180 / math.pi)
end


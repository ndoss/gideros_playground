-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- --------------------------------------------------------------------------------
-- EasyBox
-- --------------------------------------------------------------------------------
EasyBox = gideros.class(EventDispatcher)
function EasyBox:init(ebox, t)

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

   self.shape = b2.PolygonShape.new()
   self.width = t.width or 1
   self.height = t.height or 1
   self.shape:setAsBox(self.width/2, self.height/2, 0, 0, 0)

   self.fixtureDef = {
      shape = self.shape,
      friction = 0.5,
      restitution = t.restitution or 0.2,
      density = t.density or 1,
      isSensor = false,
   }
   self.fixture = self.body:createFixture(self.fixtureDef)

   local fillStyle = t.fillStyle or { Shape.SOLID, t.fillColor or 0xFFFFFF, t.fillAlpha or 1 }
   local lineStyle = t.lineStyle or { t.lineWidth or 1, t.lineColor or 0x000000, t.lineAlpha or 1 }
   self.sprite = Shape.new()
   self.sprite:setFillStyle(unpack(fillStyle))
   self.sprite:setLineStyle(unpack(lineStyle))
   self.sprite:beginPath()
   self.sprite:lineTo(-self.width/2*ebox.scale, -self.height/2*ebox.scale)
   self.sprite:lineTo( self.width/2*ebox.scale, -self.height/2*ebox.scale)
   self.sprite:lineTo( self.width/2*ebox.scale,  self.height/2*ebox.scale)
   self.sprite:lineTo(-self.width/2*ebox.scale,  self.height/2*ebox.scale)
   self.sprite:closePath()
   self.sprite:endPath()
   self.sprite.body = self.body
   self.sprite:setPosition(t.x*ebox.scale, t.y*ebox.scale)

   ebox.parent:addChild(self.sprite)

   return self
end

function EasyBox:update(ebox)
   local body = self.body
   local x,y = body:getPosition()
   self.sprite:setPosition(x*ebox.scale, y*ebox.scale)
   self.sprite:setRotation(body:getAngle() * 180 / math.pi)
end


function EasyBox:submergedArea(waterLevel)
   local x,y = self.body:getPosition()
   local area = self.width * (self.height/2 + (y-waterLevel))
   if (area < 0) then area = 0 end
   return area
end

-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- Adapted from: http://www.pixelwit.com/blog/2007/07/draw-an-arc-with-actionscript/

Arc = gideros.class(Shape)
function Arc:init(t)
   local x          = t.x or t.y or 0
   local y          = t.y or t.x or 0
   local fillStyle  = t.fillStyle or { Shape.SOLID, 0x000000, 0.5 }
   local lineStyle  = t.lineStyle or { 2, 0xffffff, 0.5  }
   local xradius    = t.xradius or t.radius or 100
   local yradius    = t.yradius or t.radius or 100
   local sides      = t.sides or (xradius + yradius)/2 
   local startAngle = t.startAngle or 0
   local arcAngle   = t.arcAngle or 1
 
   self:setFillStyle(unpack(fillStyle))
   self:setLineStyle(unpack(lineStyle))
 
   local angleStep = arcAngle / sides
 
   self:setPosition(x,y)
   local xx = math.cos(startAngle*2*math.pi) * xradius
   local yy = math.sin(startAngle*2*math.pi) * yradius
 
   self:beginPath()
   self:moveTo(xx, yy)
   for i = 1,sides do
      local angle = startAngle + i * angleStep
      self:lineTo(math.cos(angle*2*math.pi) * xradius,
                  math.sin(angle*2*math.pi) * yradius)
   end
   self:endPath()
 
   if t.alpha then
      self:setAlpha(t.alpha)
   end
   if t.parent then
      t.parent:addChild(self)
   end
 
   return self
end
 

  xy = 160
  radius = 50
  offset = 4

  Arc.new{x=xy,y=xy+radius+6,xradius=radius, yradius=radius/8, sides=sides,
              fillStyle = { Shape.SOLID, 0x000000, 0.3 },
              lineStyle = { 0, 0xffffff, 0.3 },
              parent = stage}
 
   Arc.new{x=xy+offset,y=xy+offset,radius=radius,sides=sides,
              fillStyle = { Shape.SOLID, 0x000000, 0.8 },
              lineStyle = { 4, 0x000000, 0.3 },
              parent = stage}
 
   Arc.new{x=xy,y=xy,radius=radius, sides=sides,
              fillStyle = { Shape.SOLID, 0x0000ff, 0.8 },
              lineStyle = { 8, 0xffffff, 0.3 },
              parent = stage}
 
   Arc.new{x=xy+offset,y=xy+offset,radius=radius/2,sides=sides,
              fillStyle = { Shape.SOLID, 0x000000, 0.8 },
              lineStyle = { 4, 0x000000, 0.3 },
              parent = stage}
 
   Arc.new{x=xy,y=xy,radius=radius/2, sides=sides,
              fillStyle = { Shape.SOLID, 0x00ff00, 0.8 },
              lineStyle = { 2, 0xffffff, 0.3 },
              parent = stage}
 
   Arc.new{x=200, y=300, radius=20, startAngle=-.25, arcAngle=0.5, 
          parent = stage}
   Arc.new{x=200, y=320, radius=20, startAngle=-.25, arcAngle=-0.5,
          parent = stage}
   Arc.new{x=200, y=340, radius=20, startAngle=-.25, arcAngle=0.5, 
          parent = stage}
   Arc.new{x=200, y=380, radius=20, startAngle=-.25, arcAngle=-0.5,
          parent = stage}
 
   Arc.new{x=xy,y=xy,radius=radius*2, sides=sides,
              fillStyle = { Shape.SOLID, 0x00cccc, 0.8 },
              lineStyle = { 2, 0xffffff, 0.3 },
              arcAngle=-0.5,
              parent = stage}
 
   Arc.new{x=150,y=250,xradius=70, yradius=20,
           fillStyle = { Shape.SOLID, 0x000000, 0.3 },
           lineStyle = { 0, 0xffffff, 0.3 },
           parent = stage}
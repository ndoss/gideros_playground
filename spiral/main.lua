-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- Adapted from:  http://www.pixelwit.com/blog/2008/04/how-to-draw-a-spiral/

Spiral = gideros.class(Shape)
function Spiral:init(t)
   local x          = t.x or t.y or 0
   local y          = t.y or t.x or 0
   local fillStyle  = t.fillStyle or { Shape.SOLID, 0xff0000, 0.5 }
   local lineStyle  = t.lineStyle or { 2, 0xffffff, 0.5  }
   local radius     = t.radius or 100
   local sides      = t.sides or radius
   local startAngle = t.startAngle or 0
   local arcAngle   = t.arcAngle or 1
   local coils      = t.coils or 4
   local rotation   = t.rotation or 0
 
   self:setLineStyle(unpack(lineStyle))
 
   local awayStep      = radius/sides;
   local aroundStep    = coils/sides;
   local aroundRadians = aroundStep * 2 * math.pi;
   local rotation      = rotation * 2 * math.pi;
 
   self:beginPath()
   self:setPosition(x,y)
   self:moveTo(0,0)
 
   for i = 1,sides do
      local away   = i * awayStep;
      local around = i * aroundRadians + rotation;
      self:lineTo(math.cos(around) * away, math.sin(around) * away);
   end
 
   self:endPath()
 
   if t.alpha then
      self:setAlpha(t.alpha)
   end
   if t.parent then
      t.parent:addChild(self)
   end
 
end
 
   -- Big Center spirals
   Spiral.new{x=250, y=210, radius=200, coils=4, rotation=0, 
              lineStyle={27, 0x0000ff}, parent=stage, }
 
   Spiral.new{x=250, y=210, radius=127, coils=2.5, rotation=.5, 
              lineStyle = {27, 0xFF0000}, parent=stage}
 
   -- Small corner spirals
   Spiral.new{x=50, y=50, radius=50, coils=4, rotation=0, 
              lineStyle={4, 0xFF00FF}, parent=stage}
   Spiral.new{x=125, y=50, radius=25, coils=3, rotation=0.5, 
              lineStyle={4, 0xFF00FF}, parent=stage}
 
   Spiral.new{x=450, y=50, radius=50, coils=-4, rotation=0.5, 
              lineStyle={4, 0x00FFFF}, parent=stage}
   Spiral.new{x=375, y=50, radius=25, coils=-3, rotation=0, 
              lineStyle={4, 0x00FFFF}, parent=stage}
 
   Spiral.new{x=50, y=350, radius=50, coils=-4, rotation=0, 
              lineStyle={4, 0xFFFF00}, parent=stage}
   Spiral.new{x=125, y=350, radius=25, coils=-3, rotation=0.5, 
              lineStyle={4, 0xFFFF00}, parent=stage}
 
   Spiral.new{x=450, y=350, radius=50, coils=4, rotation=0.5, 
              lineStyle={4, 0x00FF00}, parent=stage}
   Spiral.new{x=375, y=350, radius=25, coils=3, rotation=0, 
              lineStyle={4, 0x00FF00}, parent=stage}
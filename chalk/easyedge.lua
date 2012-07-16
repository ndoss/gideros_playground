-- License - http://creativecommons.org/publicdomain/zero/1.0/

-- --------------------------------------------------------------------------------
-- EasyEdge
-- --------------------------------------------------------------------------------
EasyEdge = gideros.class(EventDispatcher)
function EasyEdge:init(ebox, t)

   self.body = ebox.w:createBody{}
   self.shape = b2.ChainShape.new()
   self.shape:createChain(t.x1, t.y1, t.x2, t.y2)
   self.body:createFixture({shape = self.shape, density = 0})

   local lineStyle = t.lineStyle or { t.lineWidth or 1, t.lineColor or 0x000000, t.lineAlpha or 1 }
   self.sprite = Shape.new()
   self.sprite:setLineStyle(unpack(lineStyle))
   self.sprite:beginPath()
   self.sprite:lineTo(t.x1*ebox.scale, t.y1*ebox.scale)
   self.sprite:lineTo(t.x2*ebox.scale, t.y2*ebox.scale)
   self.sprite:endPath()
   self.sprite.body = self.body

   ebox.parent:addChild(self.sprite)

   return self
end

function EasyEdge:update(ebox)
end




-- ------------------------------------------------------------------------
-- Adapted from http://actionsnippet.com/?p=2933
local function createGraphics(t)
   local a = 100
   local b = 10
   local xscale = t.xscale or t.scale or 1
   local yscale = t.yscale or t.scale or 1

   local graphics = Shape.new()
   graphics:setFillStyle(Shape.SOLID, t.fillColor or 0xffffff)
   graphics:setLineStyle(1, t.lineColor or 0x000000, 1)

   graphics:beginPath()
   for v = 0,2*math.pi,0.05 do
      local p = ((a + b)/b)*v
      local xp = (a + b) * math.cos(v) - b * math.cos(p);
      local yp = (a + b) * math.sin(v) - b * math.sin(p);
      if (v == 0) then
         graphics:moveTo((xp*xscale)+ (t.x or 0), (yp*yscale) + (t.y or 0));
      else
         graphics:lineTo((xp*xscale)+ (t.x or 0), (yp*yscale) + (t.y or 0));
      end
   end
   graphics:endPath()

   return graphics
end

-- ------------------------------------------------------------------------
CartoonCaption = gideros.class(Sprite)
function CartoonCaption:init(t)

   self:addChild(createGraphics(t))

   if (t.parent) then
      t.parent:addChild(self)
   end

   self.focus = false
   
   self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
   self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
   self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
   
   self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
   self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
   self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
   self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
   
   return self
end

function CartoonCaption:onMouseDown(event)
   if self:hitTestPoint(event.x, event.y) then
      self.focus = true
      event:stopPropagation()
   end
end

function CartoonCaption:onMouseMove(event)
   if self.focus then
      if not self:hitTestPoint(event.x, event.y) then
	 self.focus = false;
      end
      event:stopPropagation()
   end
end

function CartoonCaption:onMouseUp(event)
   if self.focus then
      self.focus = false;
      self:dispatchEvent(Event.new("click"))
      event:stopPropagation()
   end
end

-- if CartoonCaption is on focus, stop propagation of touch events
function CartoonCaption:onTouchesBegin(event)
   if self.focus then
      event:stopPropagation()
   end
end

-- if CartoonCaption is on focus, stop propagation of touch events
function CartoonCaption:onTouchesMove(event)
   if self.focus then
      event:stopPropagation()
   end
end

-- if CartoonCaption is on focus, stop propagation of touch events
function CartoonCaption:onTouchesEnd(event)
   if self.focus then
      event:stopPropagation()
   end
end

-- if touches are cancelled, reset the state of the cartoonCaption
function CartoonCaption:onTouchesCancel(event)
   if self.focus then
      self.focus = false;
      event:stopPropagation()
   end
end


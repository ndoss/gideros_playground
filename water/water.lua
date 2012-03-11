-- License - http://creativecommons.org/publicdomain/zero/1.0/

Water = Core.class(NdShape)
function Water:init(t)
   if not t then
      t = {}
   end
   self.x             = t.x or application:getContentWidth()/2
   self.y             = t.y or 3*application:getContentHeight()/4
   self.width         = t.width or application:getContentWidth()
   self.height        = t.height or application:getContentHeight()/2
   self.bins          = t.bins or 20
   self.boundaryBins  = t.boundaryBins or 2
   self.viscosity     = t.viscosity or 0.1
   self.bezier        = t.bezier or false
   self.damping       = t.damping or 0.95
   self.fill          = t.fillStyle or { Shape.SOLID, 0x0000cc, 0.5 }
   self.line          = t.lineStyle or { 0 }
   self.scale         = self.width / self.bins 
   self.velocityScale = self.velocityScale or 1
   self.h = {}
   self.v = {}

   self.startBin = 0-self.boundaryBins
   self.endBin   = self.bins+self.boundaryBins

   self.waterHeight = self.y - self.height/2
   for i=self.startBin,self.endBin+0.1,1 do
      self.h[i] = self.waterHeight
      self.v[i] = 0
   end

   return self
end

function Water:update()
   for i=self.startBin+1,self.endBin-1 do
      self.v[i] = self.v[i] + (self.h[i-1] + self.h[i+1] + self.waterHeight) / 3 - self.h[i]
      self.v[i] = self.v[i] * self.damping
   end

   for i=self.startBin+1,self.endBin-1 do
      self.h[i] = self.h[i] + self.v[i] * self.viscosity
   end

   self.h[self.startBin] = self.h[self.startBin+1]
   self.h[self.endBin]   = self.h[self.endBin-1]

   local path = {}
   for i=0,self.bins+0.1 do
      table.insert(path, { i*self.scale + self.x-self.width/2, self.h[i] * self.velocityScale} );
   end

   self:clear()
   if self.line then
      self:setLineStyle(unpack(self.line))
   end
   if self.fill then
      self:setFillStyle(unpack(self.fill))
   end
   self:beginPath()
   self:lineTo(self.x+self.width/2, self.y+self.height/2)
   self:lineTo(self.x-self.width/2, self.y+self.height/2)
   if self.bezier then
      self:lineTo(path[1][1], path[1][2])
      for i=1,#path+0.1,2 do
         if (i+2) <= #path then
            self:quadraticCurveTo(path[i][1], path[i][2], path[i+1][1], path[i+1][2])
         end
      end
      self:lineTo(path[#path][1], path[#path][2])
   else
      self:path(path)
   end
   self:closePath()
   self:endPath()
end

function Water:setVelocity(bin, vel, width)
   if not vel or not bin then return end
   if not width then width = 1 end
   vel = math.floor(vel+0.5)
   bin = math.floor(bin+0.5)
   for i=bin-math.floor(width/2),bin+math.floor(width/2) do
      if i>= self.startBin and i<=self.endBin then
         self.v[i] = vel
      end
   end
end

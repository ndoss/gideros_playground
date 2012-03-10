-- License - http://creativecommons.org/publicdomain/zero/1.0/


-- Change this to set how much simplification is done
delta = 50      --  1e-6 = very little simplification,  200 = lots of simplification

-- Change this to set how often points are added to the line while drawing
pointDelta = 100 


-- 
vector = require("vector");

local function size(t)
   if t[0] then
      return #t+1
   else
      return 0
   end
end

function convertToZeroBasedIndex(t)
   v = {}
   for i=1,#t do
      v[i-1] = t[i]
   end
   return v
end

function convertToOneBasedIndex(t)
   v = {}
   for i=0,size(t)-1 do
      v[i+1] = t[i]
   end
   return v
end

local function insert(t,v)
   t[size(t)] = v
end

local function append(t,v,b,e)
   -- print("lower vertices", to_string(t))
   -- print("vertices", to_string(v))
   -- print("begin/end", b,e)
   if (e-1 < b) then stop_append() end
   if e > size(v) then stop_append() end
   if b < 0 then stop_append() end

   for i=b,e-1 do
      insert(t,v[i])
   end
end

-- Calculates the signed area of a triangle. A negative value
-- indicates a polygon to the right, where a positive value
-- indicates a polygon to the left.
--   a - the first vertex of the triangle
--   b - the second vertex of the triangle
--   c - the third vertex of the triangle
-- Returns the area of the triangle
local function areaOf(a, b, c)
   return ((b.x - a.x) * (c.y - a.y)) - ((c.x - a.x) * (b.y - a.y));
end

-- Checks whether the given vertices constitute a left polygon.
--   a - the first vertex of the triangle.
--   b - the second vertex of the triangle.
--   c - the third vertex of the triangle
-- Returns a value indicating whether the given vertices constitute a left polygon.
local function isLeft(a,b,c)
   return areaOf(a, b, c) > 0;
end


--- Checks whether the given vertices constitute a left or collinear polygon.
--- </summary>
--- <param name="a">The first vertex of the triangle.</param>
--- <param name="b">The second vertex of the triangle.</param>
--- <param name="c">The third vertex of the triangle.</param>
--- <returns>A value indicating whether the given vertices constitute a left or collinear polygon.</returns>
function isLeftOn(a,b,c)
   return areaOf(a, b, c) >= 0
end

-- Retrieves an element in the vector list. Wraps around the length of the list.
--   v - the list of vertices
--   pos - the position to return (will be wrapped)
-- Returns the vertex at this position
local function at(v,pos)
   return v[pos % size(v)]
end

-- Reverses the order of indexed elements of a table
function reverse(tab)
   local size = size(tab)
   local newTable = {}

   if (size-1) < 0 then stop_reverse() end

   for i=0,size-1 do
      --print(size-i-1,tab[i])
      newTable[size-i-1] = tab[i]
   end
   return newTable
end

-- Reverses the vertices in a given polygon (list of vertices) if it its
-- vertices are defined in a clockwise rotation.
-- The Bayazit algorithm assumes counter-clockwise vertices.
--   vertices - the polygon (list of vertices) to convert.
-- Returns a new polygon (list of vertices)
function reverseIfClockwise(vertices)
   local bottomRightIndex = 0;

   if (size(vertices)-1) < 1 then stop_reverseIfClockwise() end

   for i = 1,size(vertices)-1 do
      local vertex = vertices[i]
      local bottomRight = vertices[bottomRightIndex]
      if (vertex.y < bottomRight.y) or ((vertex.y == bottomRight.y) and (vertex.x > bottomRight.x)) then
         bottomRightIndex = i
      end
   end
   if  not isLeft(at(vertices,bottomRightIndex-1), at(vertices,bottomRightIndex), at(vertices,bottomRightIndex+1)) then
      return reverse(vertices)
   end
   return vertices
end

-- Checks whether the given vertices constitute a collinear polygon.
--   a - the first vertex of the triangle.
--   b - the second vertex of the triangle.
--   c - the third vertex of the triangle.
-- Returns boolean indicating whether the given vertices constitute a collinear polygon.
function isCollinear(a,b,c)
   return floatEquals(areaOf(a, b, c), 0)
end

-- Checks whether the given floats are close enough to each other to be considered equal.
--   a - the first float
--   b - the second float
-- Returns boolean indicating whether the given floats are close enough to each other to be considered equal
function floatEquals(a, b)
   --print(math.abs(a - b))
   return math.abs(a - b) <= delta
end

-- Checks whether the given vertices constitute a right polygon.
--   a - the first vertex of the triangle.
--   b - the second vertex of the triangle.
--   c - the third vertex of the triangle.
-- Returns a value indicating whether the given vertices constitute a right polygon.
function isRight(a,b,c)
   return areaOf(a, b, c) < 0
end

-- Checks whether the given vertices constitute a right or collinear polygon.
--   a - the first vertex of the triangle.
--   b - the second vertex of the triangle.
--   c - the third vertex of the triangle.
-- Returns a value indicating whether the given vertices constitute a right or collinear polygon.
function isRightOn(a,b,c)
   return areaOf(a, b, c) <= 0
end

-- Checks whether the given vertex is a reflex vertex, i.e.
-- a vertex that ends the convexity of a polygon.
--   vertices - the polygon (list of vertices)
--   position - the position to check
-- Returns a value indicating whether the given vertex is a reflex vertex.
function isReflex(vertices, position)
   return isRight(at(vertices,position-1), at(vertices, position), at(vertices, position + 1))
end

-- Simplifies all vertices by culling vertices where three consecutive vertices
-- are collinear or two consecutive vertices too close to each other.
--   vertices - the polygon (list of vertices)
-- Returns a simplified new polygon (list of vertices)
function simplify(vertices)
   local simplified = {}
   local culled = false
   local skip = false

   if size(vertices) < 3 then
      return vertices
   end

   local i=0
   while i < size(vertices) do
      local a = at(vertices, i - 1)
      local b = at(vertices, i)
      local c = at(vertices, i + 1)

      if (not isCollinear(a, b, c) and  not floatEquals(distanceSquared(b, c), 0)) then
         insert(simplified, b)
      else
         insert(simplified, c)
         i=i+1
         culled = true
      end

      i=i+1
   end      

   if culled then
      return simplify(simplified)
   else
      return simplified
   end
end

-- Calculates the intersection between two line segments.
--   p1 - The start vertex of the first line segment.
--   p2 - The end vertex of the first line segment.
--   q1 - The start vertex of the second line segment.
--   q2 - The end vertex of the second line segment.
-- Returns the point of intersection, or vector(0,0) if there is no intersection.
function getIntersectionPoint(p1, p2, q1, q2)
   local a1 = p2.y - p1.y;
   local b1 = p1.x - p2.x;
   local c1 = (a1 * p1.x) + (b1 * p1.y);
   local a2 = q2.y - q1.y;
   local b2 = q1.x - q2.x;
   local c2 = (a2 * q1.x) + (b2 * q1.y);
   local det = (a1 * b2) - (a2 * b1);

   if not floatEquals(det,0) then
      return vector.new(((b2 * c1) - (b1 * c2)) / det, ((a1 * c2) - (a2 * c1)) / det)
   else
      return vector.new(0,0)
   end
end

--
function distanceSquared(a, b)
   local dx = a.x - b.x
   local dy = a.y - b.y
   return dx * dx + dy * dy
end

-- 
decomposed = {}

----------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------
local level = 0

function decompose(vertices)
   local upperIntersectionPoint = vector.new(0,0)
   local lowerIntersectionPoint = vector.new(0,0)
   local intersectionPoint = vector.new(0,0)
   local upperDistance = 0
   local lowerDistance = 0
   local distance = 0
   local closestDistance = 0
   local upperIndex = 0
   local lowerIndex = 0
   local closestIndex = 0
   local lowerVertices = {}
   local upperVertices = {}
   local maxValue = 5.6e300
   
   level = level + 1
   if level > 50 then
      print("MAX LEVEL REACHED!")
      level = level - 1
      return
   end

   if (size(vertices)-1) < 0 then stop_decompose_a() end
   for i=0,size(vertices)-1 do
      if isReflex(vertices, i) then
         upperDistance = maxValue
         lowerDistance = maxValue

         if (size(vertices)-1) < 0 then stop_decompose_b() end
         for j=0,size(vertices)-1 do

            if isLeft(at(vertices,i-1), at(vertices,i), at(vertices,j)) and isRightOn(at(vertices,i - 1), at(vertices,i), at(vertices,j - 1)) then
               intersectionPoint = getIntersectionPoint(at(vertices,i - 1), at(vertices,i), at(vertices,j), at(vertices,j - 1))

               if isRight(at(vertices,i + 1), at(vertices,i), intersectionPoint) then
                  distance = distanceSquared(vertices[i], intersectionPoint)
                  if distance < lowerDistance then
                     lowerDistance = distance
                     lowerIntersectionPoint = intersectionPoint
                     lowerIndex = j
                  end
               end
            end
            
            if isLeft(at(vertices,i+1), at(vertices,i), at(vertices,j+1)) and isRightOn(at(vertices,i+1), at(vertices,i), at(vertices,j)) then
               intersectionPoint = getIntersectionPoint(at(vertices,i+1), at(vertices,i), at(vertices,j), at(vertices,j+1))

               if isLeft(at(vertices,i-1), at(vertices,i), intersectionPoint) then
                  distance = distanceSquared(vertices[i], intersectionPoint)
                  if distance < upperDistance then
                     upperDistance = distance
                     upperIntersectionPoint = intersectionPoint
                     upperIndex = j
                  end
               end
            end
         end

         -- if there are no vertices to connect to, choose a point in the middle
         if (lowerIndex == (upperIndex + 1) % size(vertices)) then
            intersectionPoint.x = (lowerIntersectionPoint.x + upperIntersectionPoint.x) / 2
            intersectionPoint.y = (lowerIntersectionPoint.y + upperIntersectionPoint.y) / 2

            if (i < upperIndex) then
               append(lowerVertices, vertices, i, upperIndex + 1)
               insert(lowerVertices,intersectionPoint)
               insert(upperVertices,intersectionPoint)

               if lowerIndex ~= 0 then
                  append(upperVertices,vertices, lowerIndex, size(vertices))
               end

               append(upperVertices, vertices, 0, i + 1)
            else
               if i ~= 0 then
                  append(lowerVertices, vertices, i, size(vertices))
               end
               append(lowerVertices, vertices, 0, upperIndex + 1)
               insert(lowerVertices,intersectionPoint)
               insert(upperVertices,intersectionPoint)
               append(upperVertices, vertices, lowerIndex, i + 1)
            end
         else
            if (lowerIndex > upperIndex) then
               upperIndex = upperIndex + size(vertices)
            end

            closestDistance = maxValue

            if upperIndex<lowerIndex then stop_decompose_c() end
            for j = lowerIndex,upperIndex do
               if (isLeftOn(at(vertices,i - 1), at(vertices,i), at(vertices,j)) and isRightOn(at(vertices,i + 1), at(vertices,i), at(vertices,j))) then
                  distance = distanceSquared(at(vertices,i), at(vertices,j))
                  if (distance < closestDistance) then
                     closestDistance = distance;
                     closestIndex = j % size(vertices)
                  end
               end
            end

            if (i < closestIndex) then
               append(lowerVertices, vertices, i, closestIndex + 1)
               if (closestIndex ~= 0) then
                  append(upperVertices, vertices, closestIndex, size(vertices))
               end
               append(upperVertices, vertices, 0, i + 1)
            else
               if (i ~= 0) then
                  append(lowerVertices, vertices, i, size(vertices))
               end
               append(lowerVertices, vertices, 0, closestIndex + 1)
               append(upperVertices, vertices, closestIndex, i + 1)
            end
         end

         if size(lowerVertices) < size(upperVertices) then
            decompose(lowerVertices)
            decompose(upperVertices)
         else
            decompose(upperVertices)
            decompose(lowerVertices)
         end

         return
            
      end
   end
   
   vertices = simplify(vertices);
   table.insert(decomposed, convertToOneBasedIndex(vertices))

   level = level - 1
end

function splitPoly(v)
   local out = {}
   while #v > 8 do
      local n = {}
      for i=1,8 do
         table.insert(n,v[1])
         table.remove(v,1)
      end
      table.insert(v,1,n[8])
      table.insert(v,1,n[1])
      table.insert(out,n)
   end
   if #v > 2 then
      table.insert(out,v)
   end
   return out
end

function splitPolys(v)
   local out = {}
   for i,poly in ipairs(v) do
      local result = splitPoly(poly)
      for j,newpoly in ipairs(result) do
         table.insert(out, newpoly)
      end
   end
   return out
end

-- Partitions the given polygon into convex polygon(s). 
--   vertices - the polygon (list of vertices)
-- Returns a collection of polygons (list of vertices)
function convexPartition(vertices) 
   decomposed = {}
   level = 0
   vertices = convertToZeroBasedIndex(vertices)
   vertices = reverseIfClockwise(vertices)
   vertices = simplify(vertices)
   decompose(vertices)
   return splitPolys(decomposed)
end

function toVectors(t)
   local v = {}
   if #t<1 then stop_toVectors() end
   for i=1,#t do
      v[i] = vector.new(t[i][1], t[i][2])
   end
   return v
end

function toPointList(v,scale)
   local l = {}
   if #v<1 then return l end
   for i=1,#v do
      table.insert(l,v[i].x*scale)
      table.insert(l,v[i].y*scale)
   end
   return l
end

function toPointLists(v,scale)
   local l = {}
   if #v<1 then return l end
   for i=1,#v do
      table.insert(l,toPointList(v[i],scale))
   end
   return l
end

cs = NdShape.new()
stage:addChild(cs)
cs:setLineStyle(2)

function color(i)
   local colors = {
      0xff0000,
      0x00ff00,
      0x0000ff,
      0xffff00,
      0xff00ff,
      0x00ffff,
      0x660000,
      0x006600,
      0x000066,
      0x666600,
      0x660066,
      0x006666,
   }
   i = ((i-1)%#colors)+1
   return colors[i]
end

colorIndex = 1
function drawPath(cs,p)
   cs:setFillStyle(Shape.SOLID, color(colorIndex), 0.5)
   cs:setLineStyle(2,0x000000)
   cs:beginPath()
   cs:xyPath(p)
   cs:closePath()
   cs:endPath()
   colorIndex = colorIndex + 1
end


sim = EasyBox2d.new{stage, debug=false}
sim:createStageWalls{top=false, bottom=true, wallWidth=0.2}
sim:start()

-- Quick & dirty polygon drawing
local cs = nil
local lastcs = nil
path = {}
lastEvent = nil

stage:addEventListener(Event.MOUSE_DOWN, 
   function(event) 
      cs = NdShape.new()
      cs:setLineStyle(2)
      cs:moveTo(event.x,event.y)
      table.insert(path, {event.x, event.y})
      stage:addChild(cs)
      lastEvent = { x=event.x, y=event.y }
   end)

stage:addEventListener(Event.MOUSE_UP, 
   function(event) 
      cs:lineTo(event.x,event.y)
      cs:closePath()
      cs:endPath()
      table.insert(path, {event.x, event.y})
      cs:clear()
      
      v = convexPartition(toVectors(path))
      if lastcs then
         lastcs:removeFromParent()
      end
      for n,p in ipairs(v) do
         drawPath(cs,p)
      end

      sim:addPolygon{x=0, y=0, outline=path, polys=toPointLists(v,1/30), 
                     fillColor=color(colorIndex), fillAlpha=0.5,
                     lineWidth=2, lineAlpha=1}
      
      lastcs = cs
      cs = nil
      path = {}
      lastEvent=nil
      
   end)

stage:addEventListener(Event.MOUSE_MOVE, 
   function(event) 
      cs:lineTo(event.x,event.y)
      cs:endPath()
      cs:beginPath()
      cs:moveTo(event.x,event.y)
      
      distance = distanceSquared(event, lastEvent)
      if distance > pointDelta then
         table.insert(path, {event.x, event.y})
         lastEvent = { x=event.x, y=event.y }
      end
   end)

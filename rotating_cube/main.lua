-- License - http://creativecommons.org/publicdomain/zero/1.0/
-- Adapted from - http://www.kirupa.com/developer/actionscript/rotation_center.htm

--focal length to determine perspective scaling
local focalLength = 500
 
-- initial decays of 3D cube
local userX = -0.01
local userY =  0.01
local line = {}
 
-- x, y and z properties to represent a 3D point.  
local make3DPoint = function(x,y,z)
   local point = {}
   point.x = x
   point.y = y
   point.z = z
   return point
end
 
-- similarly set up a function to make an object with 
-- x and y properties to represent a 2D point.
local make2DPoint = function(x, y)
   local point = {}
   point.x = x+200
   point.y = y+200
   return point
end
 
-- conversion function for changing an array of 3D points to an
-- array of 2D points which is to be returned.
local Transform3DPointsTo2DPoints = function(points, axisRotations)
   -- the array to hold transformed 2D points - the 3D points
   -- from the point array which are here rotated and scaled
   --to generate a point as it would appear on the screen
   local TransformedPointsArray = {}
   -- Math calcs for angles - sin and cos for each (trig)
   -- this will be the only time sin or cos is used for the
   -- entire portion of calculating all rotations
   local sx = math.sin(axisRotations.x)
   local cx = math.cos(axisRotations.x)
   local sy = math.sin(axisRotations.y)
   local cy = math.cos(axisRotations.y)
   local sz = math.sin(axisRotations.z)
   local cz = math.cos(axisRotations.z)
 
   -- a couple of variables to be used in the looping
   -- of all the points in the transform process
   local x,y,z, xy,xz, yx,yz, zx,zy, scaleRatio
 
   -- loop through all the points in your object/scene/space
   -- whatever - those points passed - so each is transformed
   local i = table.getn(points)
   while (i >0) do
      --apply Math to making transformations
      -- based on rotations
      -- assign variables for the current x, y and z
      x = points[i].x
      y = points[i].y
      z = points[i].z
 
      -- perform the rotations around each axis
      -- rotation around x
      xy = cx*y - sx*z
      xz = sx*y + cx*z
      -- rotation around y
      yz = cy*xz - sy*x
      yx = sy*xz + cy*x
      -- rotation around z
      zx = cz*yx - sz*xy
      zy = sz*yx + cz*xy
 
      -- now determine perspective scaling factor
      -- yz was the last calculated z value so its the
      -- final value for z depth
      scaleRatio = focalLength/(focalLength + yz)
      -- assign the new x and y
      x = zx*scaleRatio
      y = zy*scaleRatio
      -- create transformed 2D point with the calculated values
      -- adding it to the array holding all 2D points
      TransformedPointsArray[i] = make2DPoint(x, y)
      i = i -1
   end
   -- after looping return the array of points as they
   -- exist after the rotation and scaling
   return TransformedPointsArray
end
 
-- the points array contains all the points in the 3D
-- scene.  These 8 make a square on the screen.
local pointsArray = {
   make3DPoint(-50,-50,-50),
   make3DPoint(50,-50,-50),
   make3DPoint(50,-50,50),
   make3DPoint(-50,-50,50),
   make3DPoint(-50,50,-50),
   make3DPoint(50,50,-50),
   make3DPoint(50,50,50),
   make3DPoint(-50,50,50),
}
 
-- an object to represent the 3 angles of rotation
local cubeAxisRotations = make3DPoint(0,0,0)
 
function newpoly(parent, color, p, v)
   local shape = Shape.new()
   shape:beginPath()
   shape:setLineStyle(4, 0x00000000, 1)
   shape:setFillStyle(Shape.SOLID, color, 0.5)
   shape:moveTo(p[v[1]].y,p[v[1]].x)
   shape:lineTo(p[v[2]].y,p[v[2]].x)
   shape:lineTo(p[v[3]].y,p[v[3]].x)
   shape:lineTo(p[v[4]].y,p[v[4]].x)
   shape:lineTo(p[v[1]].y,p[v[1]].x)
   shape:endPath()
   parent:addChild(shape)
end
 
local lines = Sprite.new()
stage:addChild(lines)
 
local rotateCube = function()
   stage:removeChild(lines)
   lines = Sprite.new()
   stage:addChild(lines)
 
   cubeAxisRotations.y = cubeAxisRotations.y + userY
   cubeAxisRotations.x = cubeAxisRotations.x + userX
 
   -- create a new array to contain the 2D x and y positions of the
   -- points in the pointsArray as they would exist on the screen
   local screenPoints = Transform3DPointsTo2DPoints(pointsArray, cubeAxisRotations)
 
   -- draw the polys
   newpoly(lines, 0xff0000, screenPoints, { 1, 2, 3, 4 } )
   newpoly(lines, 0x00ff00, screenPoints, { 5, 6, 7, 8 } )
   newpoly(lines, 0x0000ff, screenPoints, { 1, 2, 6, 5 } )
   newpoly(lines, 0xff00ff, screenPoints, { 2, 3, 7, 6 } )
   newpoly(lines, 0x00ffff, screenPoints, { 3, 4, 8, 7 } )
   newpoly(lines, 0xffff00, screenPoints, { 1, 4, 8, 5 } )
 
end
 
stage:addEventListener(Event.ENTER_FRAME , rotateCube )
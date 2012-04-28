
-- ===================================================================================
-- Spriter class
-- ===================================================================================
Spriter = Core.class()

-- ===================================================================================
-- Spriter constructor
-- ===================================================================================
function Spriter:init(scmlFile, textFile, imageFile, filtering, options)

   -- Open the SCML file & parse it
   local file = io.open(scmlFile,"r")
   local text = nil
   if file then
      text = file:read("*all")
      io.close(file)
   else
      print("ERROR: Couldn't open file!!")
      return
   end
   local out = collect(text)

   -- Helper functions for re-organizing xml parse output
   local function istable(t)
      return type(t) == "table"
   end
   
   local function loadData(label, t, func)
      local ret = {}
      for _,v in ipairs(t) do
         if istable(v) and v.label == label then
            func(v,ret)
         end
      end
      return ret
   end
   
   local function loadValue(key,t)
      for _,v in ipairs(t) do
         if istable(v) and v.label == key then
            return v[1]
         end
      end
      return "ERROR"
   end

   -- Convert xml parse results into easier to work with lua tables
   self.info = loadData("spriterdata", out, function(v,ret) 
      ret.char=loadData("char", v, function(v,ret)
         ret.name=loadValue("name", v)
         ret.anim=loadData("anim", v, function(v,ret)
            table.insert(ret, {
               name  = loadValue("name", v);
               frame = loadData("frame", v, function(v,ret)
                  table.insert(ret, {
                     name      = loadValue("name", v);
                     duration  = loadValue("duration", v);
                  })
               end);
            })
         end);
         ret.box=loadData("box", v, function(v,ret)
            ret.bottom = loadValue("bottom", v)
            ret.top    = loadValue("top", v)
            ret.right  = loadValue("right", v)
            ret.left   = loadValue("left", v)
         end);
      end)
      ret.frame=loadData("frame", v, function(v,ret)
         table.insert(ret, {
            name   = loadValue("name", v);
            sprite = loadData("sprite", v, function(v,ret)
               table.insert(ret, {
                  image   = loadValue("image", v);
                  color   = loadValue("color", v);
                  opacity = loadValue("opacity", v);
                  angle   = loadValue("angle", v);
                  xflip   = loadValue("xflip", v);
                  yflip   = loadValue("yflip", v);
                  width   = loadValue("width", v);
                  height  = loadValue("height", v);
                  x       = loadValue("x", v);
                  y       = loadValue("y", v);
               })
            end);
         })
      end)
   end)

   self.pack = TexturePack.new(textFile, imageFile, filtering, options)

end

-- ===================================================================================
-- Helper function to look up a table in a list 
-- ===================================================================================
local function table_find(name, t)
   local res = nil
   for _,v in ipairs(t) do
      if v.name == name then
         res = v
         break
      end
   end
   return res
end

-- ===================================================================================
-- Helper function to apply color transform to sprite using decimal color
-- Based on code from the mighty Scouser in the Gideros forums
-- ===================================================================================
local function color_transform(col, alpha, sprite) 
   local r,g,b,_
   r, _ = math.modf(col / 65536)
   g, _ = math.modf(col / 256)
   _, g = math.modf(g   / 256)
   _, b = math.modf(col / 256)
   sprite:setColorTransform(r/256, g, b, alpha)
end

-- ===================================================================================
-- Returns timeline that can be used to build a MovieClip
-- ===================================================================================
function Spriter:timeline(name, framesPerSecond)
   -- Default to 60 frames per second
   framesPerSecond = framesPerSecond or 60

   -- Find the animation by name
   local anim = table_find(name, self.info.char.anim)
   if not anim then return nil end

   -- Find top/left
   local top  = self.info.char.box.top
   local left = self.info.char.box.left

   -- Build up a sprite for each frame and insert it into movie clip timeline
   local timeline = {}
   local startTime = 1

   for _,frame in ipairs(anim.frame) do
      local parent     = Sprite.new()
      local spriteList = table_find(frame.name, self.info.frame)

      -- Add sprites to the frame
      for _,sprite in ipairs(spriteList.sprite) do
         local region = sprite.image:gsub("\\","/")
         local bitmap = Bitmap.new(self.pack:getTextureRegion(region))
         local width  = bitmap:getWidth()
         local height = bitmap:getHeight()

         color_transform(sprite.color, sprite.opacity/100, bitmap)
         bitmap:setScale(sprite.width/width * (-2*sprite.xflip + 1), sprite.height/height * (-2*sprite.yflip + 1))
         bitmap:setPosition(sprite.x-left, sprite.y-top)
         bitmap:setRotation(360-sprite.angle)
         parent:addChild(bitmap)
      end

      -- Add the frame to the timeline
      local stopTime = startTime + math.ceil(frame.duration * framesPerSecond / 1000) + 1
      table.insert(timeline, { startTime, stopTime, parent })
      startTime = stopTime + 1
   end

   return timeline
end

-- ===================================================================================
-- Returns movie clip with specified animation or nil if named animation doesn't exist
-- ===================================================================================
function Spriter:movieClip(name, looping, framesPerSecond)

   -- Build the timeline
   local timeline = self:timeline(name,framesPerSecond)

   -- Return the movie clip
   local mc = MovieClip.new(timeline)

   -- Handle looping
   if looping then
      local lastTime = timeline[#timeline][2]
      mc:setGotoAction(lastTime, 1)
   end
   return mc
end

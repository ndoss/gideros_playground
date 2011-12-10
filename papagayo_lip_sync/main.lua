
-- Create a table w/ bitmaps for each phoneme type
function createMouth()
   return {
      AI   = Bitmap.new(Texture.new("mouth/AI.png"));
      E    = Bitmap.new(Texture.new("mouth/E.png"));
      etc  = Bitmap.new(Texture.new("mouth/etc.png"));
      FV   = Bitmap.new(Texture.new("mouth/FV.png"));
      L    = Bitmap.new(Texture.new("mouth/L.png"));
      MBP  = Bitmap.new(Texture.new("mouth/MBP.png"));
      O    = Bitmap.new(Texture.new("mouth/O.png"));
      rest = Bitmap.new(Texture.new("mouth/rest.png"));
      U    = Bitmap.new(Texture.new("mouth/U.png"));
      WQ   = Bitmap.new(Texture.new("mouth/WQ.png"));
          }
end


-- Convert table with frames into a movie clip timeline
function pgoToTimeline(t, mouth)
   local ls  = {}
   
   local firstAll = t.frames[1]
   local lastAll  = t.frames[2]

   local prevStop = 0
   local i = 1

   for w,word in ipairs(t) do
      wordFirst = t[w].frames[1]
      wordLast  = t[w].frames[2]

      for p,phoneme in ipairs(word) do

         if p == 1 then
            if phoneme.startFrame > prevStop then
               ls[i] = { prevStop, phoneme.startFrame-1, mouth["rest"] }
               i = i + 1
            end
            prevStop = wordLast + 1
         end
         
         ls[i] = {}
         ls[i][1] = phoneme.startFrame
         if p > 1 then
            ls[i-1][2] = phoneme.startFrame - 1
         end
         ls[i][3] = mouth[phoneme.phoneme]
         i = i + 1
      end
      ls[i-1][2] = wordLast

   end

   if ls[i-1][2] < lastAll then
      ls[i] = { ls[i-1][2] + 1, lastAll, mouth["rest"] }
   end

   return ls
end

-- Set a background color other than white
stage:setBackgroundColor(0.5,0.5,0.5)

-- Get height/width so we can center sun in the middle 
local width  = application:getLogicalWidth()
local height = application:getLogicalHeight()

-- Load sun and position it in the middle
local sun = Bitmap.new(Texture.new("sun.png"))
sun:setAnchorPoint(0.5,0.5)
sun:setPosition(width/2, height/2)
stage:addChild(sun)

-- Load the "mouth" images
local mouth = createMouth(0.2)

-- Read in the lua phoneme list table 
local t = dofile("phrase.lst")

-- Convert the phoneme list to a timeline that can be used with MovieClip
local timeline = pgoToTimeline(t[1][1], mouth)

-- Create a movie clip and position it in the center of the sun
local mc = MovieClip.new(timeline)
mc:setScale(0.5)
mc:setRotation(-15)
mc:setPosition(-60,-15)
sun:addChild(mc)

-- Load the sound
local sound = Sound.new(t.audioFile)

-- Play the movie and sound
mc:play()
sound:play()
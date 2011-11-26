
stage:setBackgroundColor(0,0,0)
local sprite = Shape.new()
sprite:setMatrix(Matrix.new(16, 0,0,-16,application:getLogicalWidth()/2,application:getLogicalHeight()/2))
stage:addChild(sprite)
scene = createBox2dWorld("bridge.json", sprite)
b2.setScale(20)

sprite:addEventListener(Event.ENTER_FRAME, function() scene.world:step(1/240, 8, 3) end)



application:setBackgroundColor(0x000000)

spriter = Spriter.new("BetaFormatHero.SCML", "example_hero.txt", "example_hero.png")

a = spriter:movieClip("walk")
stage:addChild(a)

b = spriter:movieClip("idle_healthy")
stage:addChild(b)
b:setPosition(0,250)
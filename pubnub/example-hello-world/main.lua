require "pubnub"

multiplayer = pubnub.new({
    publish_key   = "demo",
    subscribe_key = "demo",
    secret_key    = nil,
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

multiplayer:subscribe({
    channel  = "hello-world-gideros",
    callback = function(message)
        print(message.msgtext)
    end,
    errorback = function()
        print("Oh no!!! Dropped 3G Conection!")
    end
})

function send_a_message(text)
    multiplayer:publish({
        channel = "hello-world-gideros",
        message = { msgtext = text }
    })
end

function send_hello_world()
    send_a_message("Hello World!!!")
end

timer = Timer.new(500, 10)
timer:addEventListener(Event.TIMER, send_hello_world)
timer:start()

send_hello_world()

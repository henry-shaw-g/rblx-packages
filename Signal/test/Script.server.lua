local Signal = require(game.ReplicatedStorage.Signal)

local testSignal = Signal.new()

testSignal:connect(function()
    print("omg fired :o")
end)

testSignal:fire()
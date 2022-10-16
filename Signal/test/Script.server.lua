local Signal = require(game.ReplicatedStorage.Signal)

local testSignal = Signal.new()

local testConn = testSignal:connect(function()
    print("omg fired :o")
end)

testSignal:fire()

testConn:disconnect()
testSignal:fire()
print("omg did not fire :o")

local testConn2
testConn2 = testSignal:connect(function() 
    print("omg only firing once :o")
    testConn2:disconnect()
end)
testSignal:connect(function() 
    print("hmm")
end)
testSignal:fire()
testSignal:fire()

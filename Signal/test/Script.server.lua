local Signal = require(game.ReplicatedStorage.Signal)

local testSignal = Signal.new()

-- test basic firing
print("Testing :connect, :fire.")
local testConn = testSignal:connect(function()
    print("omg fired :o")
end)
testSignal:fire()

-- test disconnecting
print("\nTesting :disconnect.")
testConn:disconnect()
testSignal:fire()
print("omg did not fire :o")

-- test disconnecting in fire & multiple events
print("\nTesting multiple connections & in-callback :disconnect.")
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

-- test :wait()
print("\nTesting :wait.")
local testSignal2 = Signal.new()
task.spawn(function() 
    local message = testSignal2:wait()
    print(message)
end)
testSignal2:fire(":wait success.")

-- test :once()
print("\nTest :once")
local testSignal3 = Signal.new()
testSignal3:once(function() 
    print("Only once again :O")
end)
testSignal3:fire()
testSignal3:fire()
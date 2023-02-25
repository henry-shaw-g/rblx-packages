local Cleaner = require(game:GetService("ReplicatedStorage").Cleaner)

-- test 1
local cleaner1 = Cleaner.new()
local part = Instance.new("Part")
cleaner1:add(part)
cleaner1:add(function() 
    print("im being cleaned :o")
end)
cleaner1:add({
    Destroy = function() 
        print("im being destructed :o")
    end
})
local foo = {}
function foo:bar()
    print("im a method being called :o")
end
cleaner1:addMethod(foo, foo.bar)

print("starting clean ...")
cleaner1:clean()
print("part parent: ", part.Parent)

-- test 2
local cleaner2 = Cleaner.new()
local cleaner3 = Cleaner.new()
cleaner3:add(function() 
    print("im being chain cleaned?")
end)
cleaner2:add(cleaner3)

print("starting clean ...")
cleaner2:clean()
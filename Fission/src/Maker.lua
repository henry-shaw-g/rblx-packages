local Maker = {}
Maker.__index = Maker

--[[
    Author: Wafflechad
    Maker Class:
    * offers a concise syntax for constructing ui or other roblox instances.
]]

-- Constants
local PARENT_PROPERTY           = "Parent"
local CHILDREN_PROPERTY         = {}
local EVENTS_PROPERTY           = {}

local REPORT_CAUGHT_ERRORS      = true

-- Dependencies --
local Output = require(script.Parent.Output)

-- Types --
type Prop = string
type UniqueProp = {}

type EventCallback = (...any?) -> ()
type EventValue = {string | EventCallback} -- {EventName, EventCallback}

type Props = {
    [Prop | UniqueProp]: any,
}

-- Private --
local function instanceParent(child: any, parent: Instance) -- child is purposely ambigous
    local success, err = pcall(function()
        child.Parent = parent
    end)
    if not success then
        if REPORT_CAUGHT_ERRORS then
            print(err) 
        end
        Output.errorf("Cannot parent child: %s to instance.", tostring(child))
    end
end

local function instanceCreate(className: string): Instance
    local instance
    local success, err = pcall(function() 
        instance = Instance.new(className)
    end)

    if not (success and instance) then
        if REPORT_CAUGHT_ERRORS then
           print(err) 
        end
        Output.errorf("Instance could not be created. Class-name: %s", tostring(className))
    end

    return instance
end

local function instanceApplyProperty(instance: Instance, prop: Prop, value: any)
    local success, err = pcall(function() 
        instance[prop] = value
    end)

    if not success then
        if REPORT_CAUGHT_ERRORS then
            print(err) 
        end
        Output.errorf("Property could not be assigned. Class-name: %s, Property: %s, Value Type: %s, Value: %s", 
            instance.ClassName, prop, typeof(value), tostring(value))
    end
end

local function instanceConnectEvent(instance: Instance, eventName: string, callback: EventCallback)
    -- PS: be sure to delete your instances
    local success, err = pcall(function() 
        instance[eventName]:Connect(callback)
    end)

    if not success then
        if REPORT_CAUGHT_ERRORS then
            print(err)
        end
        Output.errorf("Event could not be connected to. Class-name: %s, Event-name: %s.",
            instance.ClassName, eventName)
    end
end

local function make(self, className: string, props: Props)
    -- create the instance
    local instance = instanceCreate(className)

    -- merge any class defaults, underriding props
    -- TODO: consider a 'no defaults' flag property to by pass this
    local classDefaults = self.defaults[className]
    if classDefaults then
        for prop: Prop|UniqueProp, value in classDefaults do
            if not props[prop] then
                props[prop] = value
            end
        end
    end

    --: iterate through properties and attempt to apply to instance
    for prop: Prop|UniqueProp, value in props do
        --: check for specific properties that should be applied later
        if type(prop) == "string" then
            if not (prop == PARENT_PROPERTY or prop == CHILDREN_PROPERTY or prop == EVENTS_PROPERTY) then
                instanceApplyProperty(instance, prop, value)
            end
        end
    end

    -- apply specific / special properties at end
    if props[EVENTS_PROPERTY] then
        local eventValues: {EventValue} = props[EVENTS_PROPERTY]
        for i = 1, #eventValues do
            local eventValue = eventValues[i]
            instanceConnectEvent(instance, eventValue[1], eventValue[2])
        end
    end

    -- parent children
    if props[CHILDREN_PROPERTY] then
        local children = props[CHILDREN_PROPERTY]
        for i, child in children do
            -- parent child
            instanceParent(child, instance)

            -- name child if child is specified by string key
            if type(i) == "string" then
                child.Name = i
            end
        end
    end

    -- apply parent property last for performance reasons
    if props[PARENT_PROPERTY] then
        instanceApplyProperty(instance, PARENT_PROPERTY, props[PARENT_PROPERTY])
    end

    return instance
end

-- Static --
Maker.children = CHILDREN_PROPERTY
Maker.events = EVENTS_PROPERTY

-- Public --
function Maker.new()
    local self = setmetatable({}, Maker)

     -- table of default props for class-names
    self.defaults = {}
    -- table of fields that can be set and read as any value (just a container pretty much)
    self.pallete = {} 

    return self
end

--- Instance constructor method (syntax is doing a function call on the object itself).
function Maker:__call(className: string): typeof(make)
    return function (props)
        return make(self, className, props)
    end
end

return Maker
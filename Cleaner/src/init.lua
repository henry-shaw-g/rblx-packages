local Cleaner = {}
--[[
	Cleaner: Class that handles cleaning up data after some kind of session, similar to Maid and Janitor
	author: Wafflechad
	date: December 2022
	todo:
		* cleaner chaining
		* class destruction
		* protected class
]]

-- TYPES
export type Cleaner = {
	-- fields
	things: {[any]: Instance | RBXScriptConnection},
	contextActionBindings: {[any]: string},
	renderStepBindings: {[any]: string},
	-- methods
	clean: (Cleaner) -> (),
	add: (Cleaner, any?) -> (),
	addContextActionBinding: (Cleaner, string) -> (),
	makeContextActionBinding: (Cleaner, string, any...) -> (),
	addRenderStepBinding: (Cleaner, string) -> (),
	makeRenderStepBinding: (Cleaner, string, number, (number) -> ()) -> (),
	
}

-- SERVICES
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- PRIVATE
local methodCallMeta = {
	_call = function(self, ...)
		self._method(self._obj, ...)
	end
}

local function cleanThing(thing: Instance | RBXScriptConnection)
	local typeOfThing = typeof(thing)
	local meta = getmetatable(thing)
	if typeOfThing == "RBXScriptConnection" then
		thing:Disconnect()
	elseif typeOfThing == "Instance" then
		thing:Destroy()
	elseif typeOfThing == "function" then
		thing()
	elseif typeOfThing == "table" then
		if thing.Destroy then
			thing:Destroy()
		end 
		if thing.__type == "LuauConnection" then
			thing:Disconnect() -- propietary to my Signal class
		end
	elseif meta == Cleaner then
		thing:clean()
	elseif meta == methodCallMeta then
		thing()
	end
end

-- PUBLIC
Cleaner.__index = Cleaner
function Cleaner.new(): Cleaner
	local self: Cleaner = setmetatable({}, Cleaner)
	self.things = {}
	self.contextActionBindings = {}
	self.renderStepBindings = {}
	return self
end

function Cleaner:clean()
	for _, thing in self.things do
		cleanThing(thing)
	end
	table.clear(self.things)
	for _, binding in self.contextActionBindings do
		ContextActionService:UnbindAction(binding)
	end
	table.clear(self.contextActionBindings)
	for _, binding in self.renderStepBindings do
		RunService:UnbindFromRenderStep(binding)
	end
	table.clear(self.renderStepBindings)
end

-- instances (and connections)
function Cleaner:add(thing)
	table.insert(self.things, thing)
end

-- utility adder which adds a method (object and function)
function Cleaner:addMethod<T>(thing: T, method: (T, ...any?) -> ())
	return setmetatable({
		_obj = thing,
		_method = method,
	}, methodCallMeta)
end

-- CAS bindings
function Cleaner:addContextActionBinding(binding: string)
	table.insert(self.contextActionBindings, binding)
end

function Cleaner:makeContextActionBinding(binding: string, ...)
	ContextActionService:BindAction(binding, ...)
	table.insert(self.contextActionBindings, binding)
end

-- RunService bindings
function Cleaner:addRenderStepBinding(binding: string)
	table.insert(self.renderStepBindings, binding)
end

function Cleaner:makeRenderStepBinding(binding: string, priority: number, callback)
	RunService:BindToRenderStep(binding, priority, callback)
	table.insert(self.renderStepBindings, binding)
end

return Cleaner
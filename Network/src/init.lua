local Network = {}
--[[
    Network: Module for handling networking without having to manage instances in studio.
    Author: Wafflechad
]]

-- References --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Constants --
local NETWORK_FOLDER_NAME = "NetworkRemotes"
local EVENTS_FOLDER_NAME = "RemoteEvents"
local FUNCTIONS_FOLDER_NAME = "RemoteFunctions"

-- Variables --
local networkFolder: Folder
local eventsFolder: Folder
local functionsFolder: Folder

local eventCache: {string: RemoteEvent} = {}
local functionCache: {string: RemoteFunction} = {}

-- Private --
local fetchEvent: (string) -> (RemoteEvent)
local fetchFunction: (string) -> (RemoteFunction)

if (RunService:IsClient()) then
    -- Client Implementation
    networkFolder = ReplicatedStorage:WaitForChild(NETWORK_FOLDER_NAME)
    eventsFolder = networkFolder:WaitForChild(EVENTS_FOLDER_NAME)
    functionsFolder = networkFolder:WaitForChild(FUNCTIONS_FOLDER_NAME)

    function fetchEvent(pathName: string): RemoteEvent
        local event = eventsFolder:WaitForChild(pathName)
        eventCache[pathName] = event
        return event
    end

    function fetchFunction(pathName: string): RemoteFunction
        local func = functionsFolder:WaitForChild(pathName)
        functionCache[pathName] = func
        return func
    end

elseif (RunService:IsServer()) then
    -- Server Implementation
    networkFolder = Instance.new("Folder")
    networkFolder.Name = NETWORK_FOLDER_NAME
    networkFolder.Parent = ReplicatedStorage

    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = EVENTS_FOLDER_NAME
    eventsFolder.Parent = networkFolder

    functionsFolder = Instance.new("Folder")
    functionsFolder.Name = FUNCTIONS_FOLDER_NAME
    functionsFolder.Parent = networkFolder

    function fetchEvent(pathName: string): RemoteEvent
        local event = Instance.new("RemoteEvent")
        event.Name = pathName
        event.Parent = eventsFolder
        eventCache[pathName] = event
        return event
    end

    function fetchFunction(pathName: string): RemoteFunction
        local func = Instance.new("RemoteFunction")
        func.Name = pathName
        func.Parent = functionsFolder
        functionCache[pathName] = func
        return func
    end
end

-- Public --

--[[
        :getEvent()
        params: takes a unique string identifier (termed a path name) to get the remote 
        * recommended to use a path name format like "Domain/Subdomain/Eventname"
        * ex: "Shop/Requests/BuyDailyItem"
        returns: remote event corresponding to identifier (if on the server, a remote event will be made if one does not exist)
    ]]
function Network:getEvent(pathName: string): RemoteEvent
    local event = eventCache[pathName] or fetchEvent(pathName)
    return event
end

--[[
        :getFunction()
        params: takes a unique string identifier (termed a path name) to get the remote
        * recommended to use a path name format like "Domain/Subdomain/FunctionName"
        * ex: "Shop/Requests/GetDailyItems"
        returns: remote function corresponding to identifier (if on the server, a remote event will be made if one does not exist)
    ]]
function Network:getFunction(pathName: string): RemoteEvent
    local func = functionCache[pathName] or fetchFunction(pathName)
    return func
end

return Network
--[[
    Signal: Lua sided script signal.
    Author: Wafflechad (hs747)
]]

-- Types --
export type Connection = {
    disconnect: () -> ();
}

export type Signal = {
    fire: (any...) -> (),
    connect: ((any...) -> ()) -> Connection,
}

-- Private --
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, callback): Connection
    local self = setmetatable({}, Connection)
    self._callback = callback
    self._signal = signal
    self._index = 0 -- gets set by signal class

    self._disconnected = false

    return self
end

function Connection:disconnect()
    -- prevent multiple disconnectings (would be problematic)
    if self._disconnected then return end
    self._disconnected = true

    local last = self._signal._numConnections

    self._signal._connections[self._index] = self._signal._connections[last]
    self._signal._connections[last] = nil

    self._signal._numConnections -= 1
end

-- cringe alias
Connection.Disconnect = Connection.disconnect

-- Public --
local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
    local self = setmetatable({}, Signal)
    self._connections = {}
    self._numConnections = 0
    return self
end

function Signal:fire(...: any?)
    for i = self._numConnections, 1, -1 do -- iterate backwards in case any connections disconnect themselves
        local callback = self._connections[i]._callback
        task.spawn(callback, ...)
    end
end

function Signal:connect(callback: (any...) -> ()): Connection
    if not (type(callback) == "function") then
        error("Invalid callback.")
    end

    local connection = Connection.new(self, callback)
    self._numConnections += 1
    connection._index = self._numConnections
    self._connections[self._numConnections] = connection

    return connection
end

-- cringe aliases
Signal.Fire = Signal.fire
Signal.Connect = Signal.connect

return Signal
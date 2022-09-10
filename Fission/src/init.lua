local Fission = {}
--[[
    Author: Wafflechad
    Fission: Top level container of sub libraries for the fission library.
    - Submodules:
        * Maker:
        * State: ?
]]

-- Dependencies --
local Maker = require(script.Maker)

-- Public --
Fission.maker = Maker.new

return Fission
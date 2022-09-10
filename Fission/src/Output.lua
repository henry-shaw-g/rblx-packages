local Output = {}

--[[
    Author: Wafflechad
    Output functions:
    * simply provides syntactic sugar to output formatted strings.
]]

function Output.printf(formatStr: string, ...)
    warn(string.format(formatStr, ...))
end

function Output.warnf(formatStr: string, ...)
    warn(string.format(formatStr, ...))
end

function Output.errorf(formatStr: string, ...)
    error(string.format(formatStr, ...))
end

return Output
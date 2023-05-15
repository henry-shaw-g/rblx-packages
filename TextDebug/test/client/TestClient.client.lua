local RunService = game:GetService("RunService")

local TextDebug = require(game:GetService("ReplicatedStorage").Shared.TextDebug)

local section1 = TextDebug.section()
section1:setHeader("section1:")
section1:writeLabel("RESIZING", "")

local section2 = TextDebug.section()
section2:setHeader("section 2:")
for i = 1, 30 do
    section2:writeLabel(tostring(i), "idk")
end

local section3 = TextDebug.section()
section3:setHeader("section 3:")
section3:writeLabel("LABEL_1", "in second column.")


task.spawn(function()
    local n = 1
    while task.wait(0.1) do
        local s = ""
        for _ = 1, n do s ..= "+" end
        section1:writeLabel("RESIZING", s)
        n %= 20
        n += 1
    end
end)
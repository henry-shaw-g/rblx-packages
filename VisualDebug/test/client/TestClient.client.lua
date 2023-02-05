local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local VisualDebug = require(game.ReplicatedStorage.Shared.VisualDebug)

local mouse = Players.LocalPlayer:GetMouse()
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function() 
    VisualDebug.drawSphere(mouse.Hit.Position, 0.5, VisualDebug.color.red)
    VisualDebug.drawLine(Vector3.new(0, 10, 0), mouse.Hit.Position, VisualDebug.color.green)
end)
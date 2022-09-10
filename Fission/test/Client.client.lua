local Fission = require(game.ReplicatedStorage.Fission)
local maker = Fission.maker()

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function screenGui()
    return maker ("ScreenGui") {
        Parent = playerGui,
        Enabled = true,

        [maker.children] = {
            maker ("Frame") {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 0.5,
            }
        }
    }
end

local gui = screenGui()

local button = maker "TextButton" {
    Parent = gui,
    ZIndex = 20,
    Text = "Click me.",
    BackgroundTransparency = 0,
    Size = UDim2.new(0, 300, 0, 75),
    Position = UDim2.new(0, 100, 0, 100),

    [maker.events] = {
        {"Activated", function() 
            print("I was clicked!")
        end},
        {"MouseEnter", function() 
            print("I was entered o-o")
        end},
    }
}
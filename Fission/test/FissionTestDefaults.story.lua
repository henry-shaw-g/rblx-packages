local Fission = require(game.ReplicatedStorage.Fission)
local maker = Fission.maker()

maker.defaults.Frame = {
    BackgroundColor3 = Color3.fromRGB(64, 64, 64),
    BorderSizePixel = 0,
}

maker.defaults.TextLabel = {
    Font = Enum.Font.Arcade,
    TextColor3 = Color3.fromRGB(255, 255, 255),
}

return function(Parent)
    maker("Frame") {
        Parent = Parent,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.5, 0, 0.5, 0),

        [maker.children] = {
            maker "TextLabel" {
                Name = "Header",
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(0, 0.5, 0, 15, 0),

                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextSize = 13,
                Text = "A Nice Frame"
            }
        }
    }
end
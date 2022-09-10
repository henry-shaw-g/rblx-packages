local Fission = require(game.ReplicatedStorage.Fission)
local maker = Fission.maker()

local function listItem(name)
    return maker "TextLabel" {
        Size = UDim2.new(0, 100, 0, 10),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),

        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = name,
    }
end

local function list()
    return maker "Frame" {
        Size = UDim2.new(0, 100, 0, 100),
        BackgroundColor3 = Color3.fromRGB(64, 64, 64),

        [maker.children] = {
            maker "UIListLayout" {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDim.new(0, 5),
            },

            Item1 = listItem("Item 1"),
            Item2 = listItem("Item 2"),
            Item3 = listItem("Item 3"),
        }
    }
end

return function(Parent) 
    local newList = list()
    newList.Parent = Parent

    -- test if string keys become instance names:
    for _, child in newList:GetChildren() do
        print(child.Name)
    end
end
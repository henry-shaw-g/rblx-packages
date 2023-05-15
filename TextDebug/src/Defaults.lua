--!strict

-- desc: default config
return {
    section = {
        backgroundTransparency = 0.75,
        backgroundColor = Color3.fromRGB(50, 50, 50),
        innerPadding = 5,
        outerPadding = 10,
        minWidth = 100,
        maxWidth = 250,
    },

    label = {
        font = Font.fromEnum(Enum.Font.Arial),
        headerTextColor = Color3.fromRGB(40, 252, 181),
        labelTextColor = Color3.fromRGB(20, 233, 20),
    },
}
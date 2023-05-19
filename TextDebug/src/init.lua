--!nonstrict
--[[

    local section = TextDebug.section()

    section:config({
        title = "Section Title"
        pos = UDim2.new()
        size = UDim2.new()
    })

    section:writeLabel(id, text, idk)
    section:hideLabel()
    section:showLabel()
    section:configLabel({
        color = Color3.new()
        font?
    })

    TextDebug.writeLabel(frameHandle, text, bunch of random options)
    TextDebug.configLabel(frameHandle, idk, idk)
]]

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local Defaults = require(script.Defaults)

local screenGui: ScreenGui

local tempUIDCounter = 0
local function tempUID()
    local uid = tempUIDCounter
    tempUIDCounter += 1
    tempUIDCounter %= 65536
    return uid
end

local sectionsMap = {}
local sectionsList = {}

local function layoutAllSections(list: {_Section})
    local at = Vector2.new(Defaults.section.outerPadding, Defaults.section.outerPadding)
    local wmax = 0
    local n = 1

    for i = 1, #list do
        local section = list[i]
        local size = section:getAbsSize()
        if at.Y + size.Y + Defaults.section.innerPadding > screenGui.AbsoluteSize.Y and n > 1 then
            n = 1 -- don't move to next column if the section is the only in the column
            at = Vector2.new(at.X + wmax + Defaults.section.innerPadding, Defaults.section.outerPadding)
            wmax = 0
        end
        wmax = math.max(wmax, size.X)
        section.frame.Position = UDim2.new(0, at.X, 0, at.Y + Defaults.section.outerPadding)
        at += Vector2.new(0, size.Y)
        at += Vector2.new(0, Defaults.section.innerPadding)
        n += 1
    end
end

type Label = {
    text: string,
    instance: TextLabel?,
    order: number?,
    index: number?, -- TODO: implement this to remove linear search time for removing
}

local Section = {}
Section.__index = Section

type _Section = typeof(setmetatable({} :: {
    frame: Frame,
    labels: {[string]: Label},
    ordered: {Label},
    id: number,
    header: {
        text: string,
        instance: TextLabel?,
    },
    showing: boolean,
    relayoutFlag: boolean,

    showCallback: (_Section) -> ()?,
    hideCallback: (_Section) -> ()?,
}, Section))

export type Section = {
    hideLabel: (Section) -> (),
    writeLabel: (Section) -> (),
    writeLabelFormat: (Section, string, string) -> (),
    removeLabel: (Section) -> (),
    setHeader: (Section) -> (),
    show: (Section) -> (),
    hide: (Section) -> (),
}

local function makeLabel(): TextLabel
    local inst = Instance.new("TextLabel")
    inst.FontFace = Defaults.label.font
    inst.Size = UDim2.new(1, 0, 0, 15)
    inst.BackgroundTransparency = 1
    inst.TextWrapped = false
    inst.FontFace = Defaults.label.font
    inst.TextColor3 = Defaults.label.labelTextColor
    inst.TextSize = 14
    return inst
end

local function layoutSection(self: _Section)
    local y = 2
    local wmax = 0

    if not self.header.instance then
        local instance = makeLabel()
        instance.Name = "Header"
        instance.TextXAlignment = Enum.TextXAlignment.Center
        instance.TextColor3 = Defaults.label.headerTextColor
        instance.Text = self.header.text
        instance.Parent = self.frame
        self.header.instance = instance
    end

    wmax = math.max(wmax, (self.header.instance::TextLabel).TextBounds.X)
    y += 15

    for i = 1, #self.ordered do
        y += 2
        local label = self.ordered[i]
        if not label.instance then
            local instance = makeLabel()
            instance.Name = "Text"
            instance.TextXAlignment = Enum.TextXAlignment.Left
            instance.Parent = self.frame
            label.instance = instance
        end
        label.instance.Text = label.text
        label.instance.Position = UDim2.new(0, 5, 0, y)
        wmax = math.max(wmax, label.instance.TextBounds.X)
        y += 15
    end
    y += 2

    self.frame.Size = UDim2.new(0, math.clamp(wmax + 5, Defaults.section.minWidth, Defaults.section.maxWidth), 0, y)
    layoutAllSections(sectionsList)
end

local function requestSectionRelayout(self: _Section)
    if self.relayoutFlag then return end
    self.relayoutFlag = true
    task.spawn(function()
        RunService.RenderStepped:Wait()
        layoutSection(self)
        self.relayoutFlag = false
    end)
end

function Section.new(id): _Section
    local frame: Frame = Instance.new("Frame")
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.Size = UDim2.new(0, Defaults.section.maxWidth, 0, 0)
    frame.BackgroundTransparency = Defaults.section.backgroundTransparency
    frame.BackgroundColor3 = Defaults.section.backgroundColor
    frame.Parent = screenGui

    local self: _Section = setmetatable({
        frame = frame,
        labels = {},
        ordered = {},
        id = id,
        header = {
            text = "unnamed section",
        },
        relayoutFlag = false,
        showing = false,
    }, Section)
    requestSectionRelayout(self)

    return self
end

function Section.setHeader(self: _Section, header: string)
    self.header.text = header
    requestSectionRelayout(self)
end

function Section.show(self: _Section)
    local callback = self.showCallback
    if callback then callback() end
end

function Section.hide(self: _Section)
    local callback = self.hideCallback
    if callback then callback(self) end
end

function Section.writeLabel(self: _Section, id: string, line: string)
    local label: Label = self.labels[id]
    if not label then
        local newLabel = {
            text = line,
        }
        self.labels[id] = newLabel
        table.insert(self.ordered, newLabel)
        label = newLabel
    end
    label.text = line
    requestSectionRelayout(self)
end

function Section.writeLabelFormat(self: _Section, id: string, format: string, ...: any?)
    self:writeLabel(id, string.format(format, ...))
end

function Section.removeLabel(self: _Section, id: string)
    local label = self.labels[id]
    assert(label, `No label of id {id}`)
    local index = table.find(self.ordered, label)
    if index then
        table.remove(self.ordered, index)
    end
    label.instance:Destroy()
    requestSectionRelayout(self)
end

function Section.getAbsSize(self: _Section): Vector2
    return self.frame.AbsoluteSize
end

local TextDebug = {}

local function showSectionCallback(section: _Section)
    section.showing = true
    section.frame.Visible = true
    table.insert(sectionsList, section)
end

local function hideSectionCallback(section: _Section)
    section.showing = false
    section.frame.Visible = false
    local index = table.find(sectionsList, section) -- TODO: NOT THIS
    if index then table.remove(sectionsList, index) end
end

-- desc: register a new section
function TextDebug.section(): Section
    local id = tempUID()
    local section = Section.new(id)
    section.showCallback = showSectionCallback
    section.hideCallback = hideSectionCallback

    sectionsMap[id] = section
    showSectionCallback(section)

    return section
end

-- desc: globally show the text debug view
function TextDebug.show()
    screenGui.Enabled = true
end

-- desc: globally hide the text debug view
function TextDebug.hide()
    screenGui.Enabled = false
end

-- initialize
screenGui = Instance.new("ScreenGui")
screenGui.Name = "TextDebugGui"
screenGui.DisplayOrder = 1000
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
    -- TODO: NOT THIS
    layoutAllSections(sectionsList)
end)

return TextDebug
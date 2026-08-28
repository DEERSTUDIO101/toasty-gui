-- ToastyGUI/Components/Avatar.lua
local Avatar = {}

function Avatar.new(parent, username, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 32)
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = frame

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Text = "👤"
    icon.TextSize = 14
    icon.Font = Enum.Font.Gotham
    icon.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.BackgroundTransparency = 1
    lbl.Text = username or "Gast"
    lbl.TextColor3 = username and theme.textPrimary or theme.textSecondary
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = frame

    return frame
end

return Avatar

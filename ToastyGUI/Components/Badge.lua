-- ToastyGUI/Components/Badge.lua
local Badge = {}

function Badge.new(parent, label, badgeType, theme)
    local color = badgeType == "Premium" and theme.badgePremium or theme.badgeAd

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 22)
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromHex("ffffff")
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = frame

    return frame
end

return Badge

-- ToastyGUI/Components/BottomNav.lua
local TweenService = game:GetService("TweenService")
local BottomNav = {}
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

function BottomNav.new(parent, items, theme, onSelect, initialId)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.Position = UDim2.new(0, 0, 1, 0)
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame

    local buttons = {}
    local activeId = initialId or (items[1] and items[1].id)

    local function setActive(id)
        activeId = id
        for _, b in ipairs(buttons) do
            local isActive = b.id == id
            TweenService:Create(b.btn, TWEEN, {
                BackgroundTransparency = isActive and 0.7 or 1,
                TextColor3 = isActive and theme.accent or theme.textSecondary,
            }):Play()
        end
    end

    for _, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 52, 0, 52)
        btn.BackgroundColor3 = theme.accent
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = item.icon
        btn.TextSize = 24
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = theme.textSecondary
        btn.AutoButtonColor = false
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        btn.MouseButton1Click:Connect(function()
            setActive(item.id)
            if onSelect then onSelect(item.id) end
        end)

        table.insert(buttons, {id = item.id, btn = btn})
    end

    setActive(activeId)
    return frame
end

return BottomNav

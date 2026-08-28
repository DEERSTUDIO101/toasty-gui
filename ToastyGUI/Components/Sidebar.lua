-- ToastyGUI/Components/Sidebar.lua
local TweenService = game:GetService("TweenService")
local Sidebar = {}
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

function Sidebar.new(parent, items, theme, onSelect)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 56, 1, 0)
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 4)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.Parent = frame

    local buttons = {}
    local activeId = items[1] and items[1].id

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
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.BackgroundColor3 = theme.accent
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = item.icon
        btn.TextSize = 20
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = theme.textSecondary
        btn.AutoButtonColor = false
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        btn.MouseButton1Click:Connect(function()
            setActive(item.id)
            if onSelect then onSelect(item.id) end
        end)

        table.insert(buttons, {id = item.id, btn = btn})
    end

    setActive(activeId)
    return frame
end

return Sidebar

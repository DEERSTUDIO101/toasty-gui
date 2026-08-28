-- ToastyGUI/Components/Card.lua
local TweenService = game:GetService("TweenService")
local Badge = require(script.Parent.Badge)

local Card = {}
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

function Card.new(parent, data, theme, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 200)
    btn.BackgroundColor3 = theme.cardBg
    btn.BackgroundTransparency = theme.cardBgTransparency
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.Thickness = 1
    stroke.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = btn

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = btn

    -- Game Icon
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 64, 0, 64)
    iconFrame.BackgroundColor3 = theme.panelBg
    iconFrame.BackgroundTransparency = theme.panelBgTransparency + 0.1
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = btn
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 10)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = data.iconId ~= "" and ("rbxassetid://" .. data.iconId) or ""
    icon.Parent = iconFrame

    -- Fallback text if no icon
    if data.iconId == "" then
        local fallback = Instance.new("TextLabel")
        fallback.Size = UDim2.new(1, 0, 1, 0)
        fallback.BackgroundTransparency = 1
        fallback.Text = "🎮"
        fallback.TextSize = 28
        fallback.Font = Enum.Font.Gotham
        fallback.Parent = iconFrame
    end

    -- Game Name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 18)
    name.BackgroundTransparency = 1
    name.Text = data.name
    name.TextColor3 = theme.textPrimary
    name.TextSize = 13
    name.Font = Enum.Font.GothamMedium
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = btn

    -- Badge
    Badge.new(btn, data.scriptType, data.scriptType, theme)

    -- Price
    local price = Instance.new("TextLabel")
    price.Size = UDim2.new(1, 0, 0, 16)
    price.BackgroundTransparency = 1
    price.Text = data.price
    price.TextColor3 = theme.accent
    price.TextSize = 12
    price.Font = Enum.Font.GothamBold
    price.Parent = btn

    -- Hover glow
    btn.MouseEnter:Connect(function()
        TweenService:Create(stroke, TWEEN, {Color = theme.accent, Transparency = 0.5}):Play()
        TweenService:Create(btn, TWEEN, {BackgroundTransparency = math.max(0, theme.cardBgTransparency - 0.05)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(stroke, TWEEN, {Color = theme.panelBorder, Transparency = theme.panelBorderTransparency}):Play()
        TweenService:Create(btn, TWEEN, {BackgroundTransparency = theme.cardBgTransparency}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if onClick then onClick(data) end
    end)

    return btn
end

return Card

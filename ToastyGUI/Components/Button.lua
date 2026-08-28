-- ToastyGUI/Components/Button.lua
local TweenService = game:GetService("TweenService")
local Button = {}

local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Button.new(parent, text, variant, theme, onClick)
    local bg, bgTrans, textColor

    if variant == "primary" then
        bg = theme.buttonPrimaryBg
        bgTrans = 0
        textColor = theme.buttonPrimaryText
    elseif variant == "secondary" then
        bg = theme.buttonSecondaryBg
        bgTrans = theme.buttonSecondaryTransparency
        textColor = theme.textPrimary
    else -- ghost
        bg = Color3.fromHex("ffffff")
        bgTrans = 1
        textColor = theme.buttonGhostText
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = bg
    btn.BackgroundTransparency = bgTrans
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = textColor
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    -- press animation
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TWEEN_INFO, {Size = UDim2.new(0.97, 0, 0, 42)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 44)}):Play()
        if onClick then onClick() end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 44)}):Play()
    end)

    return btn
end

return Button

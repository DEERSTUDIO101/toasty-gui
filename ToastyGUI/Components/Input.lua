-- ToastyGUI/Components/Input.lua
local TweenService = game:GetService("TweenService")
local Input = {}

local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

function Input.new(parent, placeholder, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.Thickness = 1
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = theme.textSecondary
    box.TextColor3 = theme.textPrimary
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = frame

    box.Focused:Connect(function()
        TweenService:Create(stroke, TWEEN, {Color = theme.accent, Transparency = 0}):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(stroke, TWEEN, {Color = theme.panelBorder, Transparency = theme.panelBorderTransparency}):Play()
    end)

    return {
        frame = frame,
        getValue = function() return box.Text end,
        setValue = function(v) box.Text = v end,
    }
end

return Input

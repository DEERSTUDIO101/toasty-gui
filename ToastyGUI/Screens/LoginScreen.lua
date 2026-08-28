-- ToastyGUI/Screens/LoginScreen.lua
local Button = require(script.Parent.Parent.Components.Button)
local Input = require(script.Parent.Parent.Components.Input)

local LoginScreen = {}

function LoginScreen.new(parent, theme, onLogin, onGuest)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 16)
    layout.Parent = frame

    -- Card container
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 320, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = theme.panelBg
    card.BackgroundTransparency = theme.panelBgTransparency
    card.BorderSizePixel = 0
    card.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.Thickness = 1
    stroke.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.FillDirection = Enum.FillDirection.Vertical
    cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cardLayout.Padding = UDim.new(0, 14)
    cardLayout.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 28)
    cardPad.PaddingBottom = UDim.new(0, 28)
    cardPad.PaddingLeft = UDim.new(0, 24)
    cardPad.PaddingRight = UDim.new(0, 24)
    cardPad.Parent = card

    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 36)
    logo.BackgroundTransparency = 1
    logo.Text = "🍞 Toasty Hub"
    logo.TextColor3 = theme.accent
    logo.TextSize = 24
    logo.Font = Enum.Font.GothamBold
    logo.Parent = card

    -- Subtitle
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.BackgroundTransparency = 1
    sub.Text = "Gib deinen Key ein um fortzufahren"
    sub.TextColor3 = theme.textSecondary
    sub.TextSize = 12
    sub.Font = Enum.Font.Gotham
    sub.Parent = card

    -- Key input
    local keyInput = Input.new(card, "Key (6–8 Zeichen)", theme)
    keyInput.frame.Size = UDim2.new(1, 0, 0, 44)

    -- Login button
    Button.new(card, "Login", "primary", theme, function()
        local key = keyInput.getValue()
        if #key >= 6 and #key <= 8 then
            if onLogin then onLogin(key) end
        end
    end)

    -- Guest button
    Button.new(card, "Als Gast fortfahren →", "ghost", theme, function()
        if onGuest then onGuest() end
    end)

    return frame
end

return LoginScreen

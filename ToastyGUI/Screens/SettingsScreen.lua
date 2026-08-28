-- ToastyGUI/Screens/SettingsScreen.lua
local SettingsScreen = {}

local THEME_OPTIONS = {
    {id = "Glass",  label = "Glassmorphism", desc = "Frosted glass, blur effect"},
    {id = "Dark",   label = "Dark",          desc = "Solid dark panels"},
    {id = "Flat",   label = "Flat",          desc = "Light, clean, minimal"},
}

function SettingsScreen.new(parent, theme, currentThemeName, onThemeChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 0)
    layout.Parent = frame

    -- Section title
    local titlePad = Instance.new("Frame")
    titlePad.Size = UDim2.new(1, 0, 0, 0)
    titlePad.AutomaticSize = Enum.AutomaticSize.Y
    titlePad.BackgroundTransparency = 1
    titlePad.Parent = frame
    local titleInner = Instance.new("UIPadding")
    titleInner.PaddingLeft = UDim.new(0, 24)
    titleInner.PaddingTop = UDim.new(0, 24)
    titleInner.PaddingBottom = UDim.new(0, 8)
    titleInner.Parent = titlePad

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -24, 0, 24)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "Theme"
    sectionTitle.TextColor3 = theme.textSecondary
    sectionTitle.TextSize = 12
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = titlePad

    -- Theme option cards
    for _, opt in ipairs(THEME_OPTIONS) do
        local isActive = opt.id == currentThemeName

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 64)
        row.BackgroundColor3 = theme.panelBg
        row.BackgroundTransparency = isActive and (theme.panelBgTransparency - 0.1) or theme.panelBgTransparency
        row.BorderSizePixel = 0
        row.Parent = frame

        local rowStroke = Instance.new("UIStroke")
        rowStroke.Color = isActive and theme.accent or theme.panelBorder
        rowStroke.Transparency = isActive and 0.5 or theme.panelBorderTransparency
        rowStroke.Thickness = isActive and 2 or 1
        rowStroke.Parent = row

        local rowPad = Instance.new("UIPadding")
        rowPad.PaddingLeft = UDim.new(0, 24)
        rowPad.PaddingRight = UDim.new(0, 24)
        rowPad.Parent = row

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Vertical
        rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rowLayout.Padding = UDim.new(0, 2)
        rowLayout.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = opt.label .. (isActive and "  ✓" or "")
        lbl.TextColor3 = isActive and theme.accent or theme.textPrimary
        lbl.TextSize = 14
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.BackgroundTransparency = 1
        desc.Text = opt.desc
        desc.TextColor3 = theme.textSecondary
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = row

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.ZIndex = 2
        hitbox.Parent = row
        hitbox.MouseButton1Click:Connect(function()
            if onThemeChange then onThemeChange(opt.id) end
        end)
    end

    return frame
end

return SettingsScreen

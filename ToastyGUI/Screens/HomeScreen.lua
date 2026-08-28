-- ToastyGUI/Screens/HomeScreen.lua
local Card = require(script.Parent.Parent.Components.Card)
local Avatar = require(script.Parent.Parent.Components.Avatar)
local Sidebar = require(script.Parent.Parent.Components.Sidebar)
local BottomNav = require(script.Parent.Parent.Components.BottomNav)

local HomeScreen = {}

local NAV_ITEMS = {
    {icon = "🏠", id = "home"},
    {icon = "⚙️", id = "settings"},
}

function HomeScreen.new(parent, theme, user, scripts, onSelect, onNavSelect, isMobile)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local contentOffset = isMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 56, 0, 0)
    local contentSize = isMobile
        and UDim2.new(1, 0, 1, -60)
        or UDim2.new(1, -56, 1, 0)

    -- Navigation
    if isMobile then
        BottomNav.new(frame, NAV_ITEMS, theme, onNavSelect)
    else
        Sidebar.new(frame, NAV_ITEMS, theme, onNavSelect)
    end

    -- Content area
    local content = Instance.new("Frame")
    content.Position = contentOffset
    content.Size = contentSize
    content.BackgroundTransparency = 1
    content.Parent = frame

    local _contentLayout = Instance.new("UIListLayout")
    _contentLayout.FillDirection = Enum.FillDirection.Vertical
    _contentLayout.Padding = UDim.new(0, 0)
    _contentLayout.Parent = content

    -- Header bar
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = theme.panelBg
    header.BackgroundTransparency = theme.panelBgTransparency
    header.BorderSizePixel = 0
    header.Parent = content

    local headerStroke = Instance.new("UIStroke")
    headerStroke.Color = theme.panelBorder
    headerStroke.Transparency = theme.panelBorderTransparency
    headerStroke.Parent = header

    local headerPad = Instance.new("UIPadding")
    headerPad.PaddingLeft = UDim.new(0, 16)
    headerPad.PaddingRight = UDim.new(0, 16)
    headerPad.Parent = header

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(0.5, 0, 1, 0)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = "🍞 Toasty Hub"
    logoLabel.TextColor3 = theme.accent
    logoLabel.TextSize = 16
    logoLabel.Font = Enum.Font.GothamBold
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.Parent = header

    local avatarHolder = Instance.new("Frame")
    avatarHolder.Size = UDim2.new(0.5, 0, 1, 0)
    avatarHolder.Position = UDim2.new(0.5, 0, 0, 0)
    avatarHolder.BackgroundTransparency = 1
    avatarHolder.Parent = header
    local _avatarLayout = Instance.new("UIListLayout")
    _avatarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    _avatarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    _avatarLayout.Parent = avatarHolder
    Avatar.new(avatarHolder, user and user.username or nil, theme)

    -- Scrollable card grid
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -52)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = theme.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = content

    local cols = isMobile and 2 or 3
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(1/cols, -12, 0, 200)
    grid.CellPadding = UDim2.new(0, 12, 0, 12)
    grid.Parent = scroll

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingTop = UDim.new(0, 16)
    scrollPad.PaddingLeft = UDim.new(0, 16)
    scrollPad.PaddingRight = UDim.new(0, 16)
    scrollPad.PaddingBottom = UDim.new(0, 16)
    scrollPad.Parent = scroll

    for _, scriptData in ipairs(scripts) do
        Card.new(scroll, scriptData, theme, function(data)
            if onSelect then onSelect(data) end
        end)
    end

    return frame
end

return HomeScreen

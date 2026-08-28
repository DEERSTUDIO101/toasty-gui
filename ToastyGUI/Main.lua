-- ToastyGUI/Main.lua
local CoreGui = game:GetService("CoreGui")

local ThemeProvider = require(script.Parent.Components.ThemeProvider)
local LoginScreen = require(script.Parent.Screens.LoginScreen)
local HomeScreen = require(script.Parent.Screens.HomeScreen)
local SettingsScreen = require(script.Parent.Screens.SettingsScreen)
local Modal = require(script.Parent.Components.Modal)
local Sidebar = require(script.Parent.Components.Sidebar)
local BottomNav = require(script.Parent.Components.BottomNav)

-- Dummy script data (replace with backend later)
local DUMMY_SCRIPTS = {
    {name = "Blox Fruits",       iconId = "", price = "$4.99",  scriptType = "Premium", link = ""},
    {name = "Pet Sim X",         iconId = "", price = "Ad Key", scriptType = "Ad",      link = "https://example.com"},
    {name = "Anime Champions",   iconId = "", price = "$2.99",  scriptType = "Premium", link = ""},
    {name = "Fisch",             iconId = "", price = "Ad Key", scriptType = "Ad",      link = "https://example.com"},
    {name = "Clicker Simulator", iconId = "", price = "Ad Key", scriptType = "Ad",      link = "https://example.com"},
    {name = "Sols RNG",          iconId = "", price = "$1.99",  scriptType = "Premium", link = ""},
}

-- Detect mobile
local function isMobile()
    local vp = workspace.CurrentCamera.ViewportSize
    return vp.X < 600
end

-- State
local user = nil  -- nil = guest, {username="..."} = logged in
local currentScreen = "login"

-- Root ScreenGui
local existing = CoreGui:FindFirstChild("ToastyGUI")
if existing then existing:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "ToastyGUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = CoreGui

-- Background (properties populated by rebuildBackground)
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BorderSizePixel = 0
bg.Parent = sg

local bgGrad = Instance.new("UIGradient")
bgGrad.Rotation = 135
bgGrad.Parent = bg

local function rebuildBackground()
    local theme = ThemeProvider.getTheme()
    -- Remove old orbs (children of bg that are Frame instances)
    for _, child in ipairs(bg:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    bg.BackgroundColor3 = theme.bg
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.bg),
        ColorSequenceKeypoint.new(1, theme.bgGradientEnd),
    })
    if theme.blurSize > 0 then
        for _, pos in ipairs({UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0.8, 0, 0.7, 0)}) do
            local orb = Instance.new("Frame")
            orb.Size = UDim2.new(0, 300, 0, 300)
            orb.Position = pos
            orb.AnchorPoint = Vector2.new(0.5, 0.5)
            orb.BackgroundColor3 = theme.accent
            orb.BackgroundTransparency = 0.85
            orb.BorderSizePixel = 0
            Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
            orb.Parent = bg
        end
    end
end
rebuildBackground()

-- Screen container
local screenContainer = Instance.new("Frame")
screenContainer.Size = UDim2.new(1, 0, 1, 0)
screenContainer.BackgroundTransparency = 1
screenContainer.Parent = sg

local activeScreenFrame = nil
local modal = nil

local function clearScreen()
    if activeScreenFrame then
        activeScreenFrame:Destroy()
        activeScreenFrame = nil
    end
    if modal then
        if modal.backdrop then modal.backdrop:Destroy() end
        if modal.frame then modal.frame:Destroy() end
        modal.close()
        modal = nil
    end
end

local showSettings

local function showHome()
    clearScreen()
    currentScreen = "home"
    local theme = ThemeProvider.getTheme()
    local mobile = isMobile()

    activeScreenFrame = HomeScreen.new(
        screenContainer, theme, user, DUMMY_SCRIPTS,
        function(scriptData)
            -- Card clicked → open modal
            if not modal then
                modal = Modal.new(screenContainer, theme)
            end
            modal.open(scriptData, user ~= nil)
        end,
        function(navId)
            if navId == "settings" then showSettings() end
            if navId == "home" then showHome() end
        end,
        mobile
    )
end

showSettings = function()
    clearScreen()
    currentScreen = "settings"
    local theme = ThemeProvider.getTheme()
    local mobile = isMobile()

    -- Wrap with nav
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 1, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = screenContainer
    activeScreenFrame = wrapper

    local NAV_ITEMS = {{icon="🏠", id="home"},{icon="⚙️", id="settings"}}
    local navCallback = function(id)
        if id == "home" then showHome() end
        if id == "settings" then showSettings() end
    end

    local contentX = mobile and 0 or 56
    local contentW = mobile and 0 or -56

    if mobile then
        BottomNav.new(wrapper, NAV_ITEMS, theme, navCallback, "settings")
    else
        Sidebar.new(wrapper, NAV_ITEMS, theme, navCallback, "settings")
    end

    local contentFrame = Instance.new("Frame")
    contentFrame.Position = UDim2.new(0, contentX, 0, 0)
    contentFrame.Size = UDim2.new(1, contentW, mobile and 1 or 1, mobile and -60 or 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = wrapper

    SettingsScreen.new(contentFrame, theme, ThemeProvider.getTheme().name, function(themeName)
        ThemeProvider.setTheme(themeName)
        rebuildBackground()
        showSettings()
    end)
end

local function showLogin()
    clearScreen()
    currentScreen = "login"
    local theme = ThemeProvider.getTheme()

    activeScreenFrame = LoginScreen.new(
        screenContainer, theme,
        function(key)
            -- Backend will validate; for now, accept any 6-8 char key
            user = {username = "User#0000"} -- placeholder until backend
            showHome()
        end,
        function()
            user = nil
            showHome()
        end
    )
end

-- Boot
ThemeProvider.loadSaved()
showLogin()

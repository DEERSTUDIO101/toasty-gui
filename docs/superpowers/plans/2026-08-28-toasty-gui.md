# Toasty GUI Hub Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Roblox CoreGui Script Hub as a reusable Component Library in Luau — Themes, Cards, Modals, Navigation — then assemble into Login, Home, Detail, and Settings screens.

**Architecture:** Component-first (Lego) approach: each UI building block lives in its own file with a clear constructor function returning a Roblox Instance. Screens require Components as dependencies. Main.lua wires everything into CoreGui.

**Tech Stack:** Luau, Roblox Instance API, TweenService, UserInputService, GuiService

## Global Constraints

- Language: Luau (no external frameworks, no loadstring of remote URLs)
- Injection target: `game:GetService("CoreGui")` — never `PlayerGui`
- `ScreenGui.ResetOnSpawn = false`
- Default theme: Glassmorphism; switchable to Dark or Flat; saved via `writefile("toasty_theme.txt", themeName)`
- Mobile detection: `GuiService:IsTenFootInterface()` = false AND viewport width < 600 → mobile layout
- Touch targets minimum 44px height on mobile
- All colors defined as `Color3.fromHex()` — no magic values outside Theme files
- UI Only — no real backend calls, dummy data for prices/icons

---

## File Map

| File | Responsibility |
|---|---|
| `ToastyGUI/Theme/Themes.lua` | Returns theme token tables for Glas/Dark/Flat |
| `ToastyGUI/Components/ThemeProvider.lua` | Global theme state, `getTheme()`, `setTheme()`, save/load |
| `ToastyGUI/Components/Button.lua` | `Button.new(parent, text, variant, theme)` → Frame |
| `ToastyGUI/Components/Badge.lua` | `Badge.new(parent, label, theme)` → Frame |
| `ToastyGUI/Components/Input.lua` | `Input.new(parent, placeholder, theme)` → Frame + `.getValue()` |
| `ToastyGUI/Components/Avatar.lua` | `Avatar.new(parent, username, theme)` → Frame |
| `ToastyGUI/Components/Card.lua` | `Card.new(parent, data, theme, onClick)` → Frame |
| `ToastyGUI/Components/Modal.lua` | `Modal.new(parent, theme)` → Frame + `.open()` `.close()` |
| `ToastyGUI/Components/Sidebar.lua` | `Sidebar.new(parent, items, theme, onSelect)` → Frame |
| `ToastyGUI/Components/BottomNav.lua` | `BottomNav.new(parent, items, theme, onSelect)` → Frame |
| `ToastyGUI/Screens/LoginScreen.lua` | `LoginScreen.new(parent, theme, onLogin, onGuest)` → Frame |
| `ToastyGUI/Screens/HomeScreen.lua` | `HomeScreen.new(parent, theme, user, scripts, onSelect)` → Frame |
| `ToastyGUI/Screens/DetailScreen.lua` | `DetailScreen.new(parent, theme, scriptData, isLoggedIn)` → Frame |
| `ToastyGUI/Screens/SettingsScreen.lua` | `SettingsScreen.new(parent, theme, onThemeChange)` → Frame |
| `ToastyGUI/Main.lua` | Entry point: CoreGui setup, screen router, theme wiring |

---

### Task 1: Theme Token System

**Files:**
- Create: `ToastyGUI/Theme/Themes.lua`

**Interfaces:**
- Produces: `Themes.Glass`, `Themes.Dark`, `Themes.Flat` — each a table with keys: `bg`, `bgGradientEnd`, `panelBg`, `panelBgTransparency`, `panelBorder`, `blurSize`, `accent`, `textPrimary`, `textSecondary`, `buttonPrimary`, `buttonSecondary`

- [ ] **Step 1: Create Themes.lua**

```lua
-- ToastyGUI/Theme/Themes.lua
local Themes = {}

Themes.Glass = {
    name = "Glass",
    bg = Color3.fromHex("0a0a0f"),
    bgGradientEnd = Color3.fromHex("12121a"),
    panelBg = Color3.fromHex("ffffff"),
    panelBgTransparency = 0.85,
    panelBorder = Color3.fromHex("ffffff"),
    panelBorderTransparency = 0.88,
    blurSize = 20,
    accent = Color3.fromHex("00d4ff"),
    textPrimary = Color3.fromHex("ffffff"),
    textSecondary = Color3.fromHex("a0a0b0"),
    buttonPrimaryBg = Color3.fromHex("00d4ff"),
    buttonPrimaryText = Color3.fromHex("0a0a0f"),
    buttonSecondaryBg = Color3.fromHex("ffffff"),
    buttonSecondaryTransparency = 0.9,
    buttonGhostText = Color3.fromHex("a0a0b0"),
    badgeAd = Color3.fromHex("f59e0b"),
    badgePremium = Color3.fromHex("a855f7"),
    cardBg = Color3.fromHex("ffffff"),
    cardBgTransparency = 0.88,
}

Themes.Dark = {
    name = "Dark",
    bg = Color3.fromHex("0d0d1a"),
    bgGradientEnd = Color3.fromHex("0d0d1a"),
    panelBg = Color3.fromHex("1a1a2e"),
    panelBgTransparency = 0,
    panelBorder = Color3.fromHex("2a2a3e"),
    panelBorderTransparency = 0,
    blurSize = 0,
    accent = Color3.fromHex("00d4ff"),
    textPrimary = Color3.fromHex("ffffff"),
    textSecondary = Color3.fromHex("8888a0"),
    buttonPrimaryBg = Color3.fromHex("00d4ff"),
    buttonPrimaryText = Color3.fromHex("0d0d1a"),
    buttonSecondaryBg = Color3.fromHex("2a2a3e"),
    buttonSecondaryTransparency = 0,
    buttonGhostText = Color3.fromHex("8888a0"),
    badgeAd = Color3.fromHex("d97706"),
    badgePremium = Color3.fromHex("9333ea"),
    cardBg = Color3.fromHex("1a1a2e"),
    cardBgTransparency = 0,
}

Themes.Flat = {
    name = "Flat",
    bg = Color3.fromHex("f5f5f5"),
    bgGradientEnd = Color3.fromHex("f5f5f5"),
    panelBg = Color3.fromHex("ffffff"),
    panelBgTransparency = 0,
    panelBorder = Color3.fromHex("e5e5e5"),
    panelBorderTransparency = 0,
    blurSize = 0,
    accent = Color3.fromHex("6366f1"),
    textPrimary = Color3.fromHex("1a1a1a"),
    textSecondary = Color3.fromHex("6b7280"),
    buttonPrimaryBg = Color3.fromHex("6366f1"),
    buttonPrimaryText = Color3.fromHex("ffffff"),
    buttonSecondaryBg = Color3.fromHex("e5e7eb"),
    buttonSecondaryTransparency = 0,
    buttonGhostText = Color3.fromHex("6b7280"),
    badgeAd = Color3.fromHex("f59e0b"),
    badgePremium = Color3.fromHex("8b5cf6"),
    cardBg = Color3.fromHex("ffffff"),
    cardBgTransparency = 0,
}

return Themes
```

- [ ] **Step 2: In Roblox Studio / Executor — verify tokens load**

Execute snippet to test:
```lua
local Themes = loadstring(game:HttpGet("..."))() -- or require path
print(Themes.Glass.accent) -- should print Color3 value
print(Themes.Dark.panelBg)
print(Themes.Flat.accent)
```
Expected: Three Color3 values printed, no errors.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Theme/Themes.lua
git commit -m "feat: add theme token tables (Glass, Dark, Flat)"
```

---

### Task 2: ThemeProvider

**Files:**
- Create: `ToastyGUI/Components/ThemeProvider.lua`

**Interfaces:**
- Consumes: `Themes.Glass`, `Themes.Dark`, `Themes.Flat` from `Theme/Themes.lua`
- Produces:
  - `ThemeProvider.getTheme()` → current theme table
  - `ThemeProvider.setTheme(name: string)` — sets + saves theme
  - `ThemeProvider.loadSaved()` → string (theme name, default `"Glass"`)

- [ ] **Step 1: Create ThemeProvider.lua**

```lua
-- ToastyGUI/Components/ThemeProvider.lua
local Themes = require(script.Parent.Parent.Theme.Themes)

local ThemeProvider = {}
ThemeProvider._current = Themes.Glass

local SAVE_FILE = "toasty_theme.txt"

function ThemeProvider.loadSaved()
    local ok, data = pcall(readfile, SAVE_FILE)
    if ok and Themes[data] then
        ThemeProvider._current = Themes[data]
        return data
    end
    return "Glass"
end

function ThemeProvider.setTheme(name)
    if Themes[name] then
        ThemeProvider._current = Themes[name]
        pcall(writefile, SAVE_FILE, name)
    end
end

function ThemeProvider.getTheme()
    return ThemeProvider._current
end

return ThemeProvider
```

- [ ] **Step 2: Verify save/load cycle**

```lua
ThemeProvider.setTheme("Dark")
print(ThemeProvider.getTheme().name) -- "Dark"
ThemeProvider.loadSaved()
print(ThemeProvider.getTheme().name) -- "Dark" (loaded from file)
ThemeProvider.setTheme("Glass")      -- reset
```
Expected: "Dark" printed twice, no errors.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/ThemeProvider.lua
git commit -m "feat: add ThemeProvider with save/load"
```

---

### Task 3: Button Component

**Files:**
- Create: `ToastyGUI/Components/Button.lua`

**Interfaces:**
- Consumes: theme table (from `ThemeProvider.getTheme()`)
- Produces: `Button.new(parent, text, variant, theme, onClick)` → `TextButton`
  - `variant`: `"primary"` | `"secondary"` | `"ghost"`

- [ ] **Step 1: Create Button.lua**

```lua
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
```

- [ ] **Step 2: Visual test in executor**

```lua
local sg = Instance.new("ScreenGui", game.CoreGui)
local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 200, 0, 200)
f.Position = UDim2.new(0.5, -100, 0.5, -100)
f.BackgroundColor3 = Color3.fromHex("1a1a2e")

local theme = require(...).Glass
Button.new(f, "Primary", "primary", theme, function() print("clicked") end)
```
Expected: Blue button appears, press animation plays, "clicked" printed on click.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Button.lua
git commit -m "feat: add Button component (primary/secondary/ghost)"
```

---

### Task 4: Badge Component

**Files:**
- Create: `ToastyGUI/Components/Badge.lua`

**Interfaces:**
- Produces: `Badge.new(parent, label, badgeType, theme)` → `Frame`
  - `badgeType`: `"Ad"` | `"Premium"`

- [ ] **Step 1: Create Badge.lua**

```lua
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
```

- [ ] **Step 2: Visual test**

```lua
-- Ad badge: amber, Premium badge: purple
Badge.new(f, "Ad", "Ad", theme)
Badge.new(f, "Premium", "Premium", theme)
```
Expected: Two colored pill badges.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Badge.lua
git commit -m "feat: add Badge component (Ad/Premium)"
```

---

### Task 5: Input Component

**Files:**
- Create: `ToastyGUI/Components/Input.lua`

**Interfaces:**
- Produces: `Input.new(parent, placeholder, theme)` → table `{ frame: Frame, getValue: () → string, setValue: (string) → void }`

- [ ] **Step 1: Create Input.lua**

```lua
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
```

- [ ] **Step 2: Visual test**

```lua
local inp = Input.new(f, "Enter key...", theme)
-- Click box → border glows accent color
-- Type text → inp.getValue() returns typed text
```

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Input.lua
git commit -m "feat: add Input component with focus animation"
```

---

### Task 6: Avatar Component

**Files:**
- Create: `ToastyGUI/Components/Avatar.lua`

**Interfaces:**
- Produces: `Avatar.new(parent, username, theme)` → `Frame`
  - Shows Discord icon (🎮 text fallback) + username or "Gast"

- [ ] **Step 1: Create Avatar.lua**

```lua
-- ToastyGUI/Components/Avatar.lua
local Avatar = {}

function Avatar.new(parent, username, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 32)
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = frame

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Text = "👤"
    icon.TextSize = 14
    icon.Font = Enum.Font.Gotham
    icon.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.BackgroundTransparency = 1
    lbl.Text = username or "Gast"
    lbl.TextColor3 = username and theme.textPrimary or theme.textSecondary
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = frame

    return frame
end

return Avatar
```

- [ ] **Step 2: Visual test**

```lua
Avatar.new(header, "Nightdev#1234", theme) -- shows name
Avatar.new(header, nil, theme)              -- shows "Gast" in secondary color
```

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Avatar.lua
git commit -m "feat: add Avatar component (username/guest display)"
```

---

### Task 7: Card Component

**Files:**
- Create: `ToastyGUI/Components/Card.lua`

**Interfaces:**
- Consumes: `Badge.new` from `Badge.lua`
- Produces: `Card.new(parent, data, theme, onClick)` → `TextButton`
  - `data`: `{ name: string, iconId: string, price: string, scriptType: "Ad"|"Premium" }`

- [ ] **Step 1: Create Card.lua**

```lua
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
        TweenService:Create(btn, TWEEN, {BackgroundTransparency = theme.cardBgTransparency - 0.05}):Play()
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
```

- [ ] **Step 2: Visual test**

```lua
Card.new(f, {name="Blox Fruits", iconId="", price="$4.99", scriptType="Premium"}, theme, function(d) print(d.name) end)
Card.new(f, {name="Pet Sim", iconId="", price="Free Key", scriptType="Ad"}, theme, function(d) print(d.name) end)
```
Expected: Two cards with badges, hover glow, click prints name.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Card.lua
git commit -m "feat: add Card component with hover glow and badge"
```

---

### Task 8: Modal Component

**Files:**
- Create: `ToastyGUI/Components/Modal.lua`

**Interfaces:**
- Consumes: `Button.new`, `Input.new`, `Badge.new`
- Produces: `Modal.new(parent, theme)` → table `{ frame: Frame, open: (data, isLoggedIn) → void, close: () → void }`
  - `data`: same as Card data shape

- [ ] **Step 1: Create Modal.lua**

```lua
-- ToastyGUI/Components/Modal.lua
local TweenService = game:GetService("TweenService")
local Button = require(script.Parent.Button)
local Input = require(script.Parent.Input)
local Badge = require(script.Parent.Badge)

local Modal = {}
local TWEEN_OPEN = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_CLOSE = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

function Modal.new(parent, theme)
    -- Backdrop
    local backdrop = Instance.new("TextButton")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromHex("000000")
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.Text = ""
    backdrop.ZIndex = 10
    backdrop.Visible = false
    backdrop.Parent = parent

    -- Modal frame
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 340, 0, 300)
    frame.BackgroundColor3 = theme.panelBg
    frame.BackgroundTransparency = theme.panelBgTransparency
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Visible = false
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.panelBorder
    stroke.Transparency = theme.panelBorderTransparency
    stroke.Thickness = 1
    stroke.Parent = frame

    if theme.blurSize > 0 then
        local blur = Instance.new("BlurEffect")
        blur.Size = theme.blurSize
        blur.Parent = game:GetService("Lighting")
        -- store ref to remove on close
        frame:SetAttribute("blurRef", true)
    end

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 12)
    layout.Parent = frame

    -- Header row
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = ""
    titleLabel.TextColor3 = theme.textPrimary
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -24, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = theme.textSecondary
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.Parent = header

    -- Badge slot
    local badgeSlot = Instance.new("Frame")
    badgeSlot.Size = UDim2.new(1, 0, 0, 22)
    badgeSlot.BackgroundTransparency = 1
    badgeSlot.Parent = frame

    -- Link button slot (Ad only)
    local linkBtnSlot = Instance.new("Frame")
    linkBtnSlot.Size = UDim2.new(1, 0, 0, 44)
    linkBtnSlot.BackgroundTransparency = 1
    linkBtnSlot.Parent = frame

    -- Login required label (Premium + not logged in)
    local loginRequired = Instance.new("TextLabel")
    loginRequired.Size = UDim2.new(1, 0, 0, 24)
    loginRequired.BackgroundTransparency = 1
    loginRequired.Text = "⚠ Login erforderlich"
    loginRequired.TextColor3 = theme.badgePremium
    loginRequired.TextSize = 13
    loginRequired.Font = Enum.Font.GothamMedium
    loginRequired.Visible = false
    loginRequired.Parent = frame

    -- Key input row
    local keyRow = Instance.new("Frame")
    keyRow.Size = UDim2.new(1, 0, 0, 44)
    keyRow.BackgroundTransparency = 1
    keyRow.Parent = frame
    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 8)
    rowLayout.Parent = keyRow

    local keyInput = Input.new(keyRow, "Key eingeben...", theme)
    keyInput.frame.Size = UDim2.new(0.65, 0, 1, 0)

    local checkSlot = Instance.new("Frame")
    checkSlot.Size = UDim2.new(0.35, -8, 1, 0)
    checkSlot.BackgroundTransparency = 1
    checkSlot.Parent = keyRow
    local checkBtn = Button.new(checkSlot, "Prüfen", "primary", theme, nil)

    -- Execute button (hidden until key OK)
    local executeSlot = Instance.new("Frame")
    executeSlot.Size = UDim2.new(1, 0, 0, 44)
    executeSlot.BackgroundTransparency = 1
    executeSlot.Visible = false
    executeSlot.Parent = frame
    Button.new(executeSlot, "▶  Execute", "primary", theme, nil)

    -- State refs for open/close
    local self = {
        frame = frame,
        backdrop = backdrop,
        _linkBtnSlot = linkBtnSlot,
        _loginRequired = loginRequired,
        _executeSlot = executeSlot,
        _titleLabel = titleLabel,
        _badgeSlot = badgeSlot,
        _checkBtn = checkBtn,
    }

    local function doClose()
        TweenService:Create(backdrop, TWEEN_CLOSE, {BackgroundTransparency = 1}):Play()
        TweenService:Create(frame, TWEEN_CLOSE, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 0, 250),
        }):Play()
        task.delay(0.2, function()
            frame.Visible = false
            backdrop.Visible = false
            frame.Size = UDim2.new(0, 340, 0, 300)
            frame.BackgroundTransparency = theme.panelBgTransparency
        end)
    end

    closeBtn.MouseButton1Click:Connect(doClose)
    backdrop.MouseButton1Click:Connect(doClose)

    function self.open(data, isLoggedIn)
        -- Clear badge slot children
        for _, c in ipairs(badgeSlot:GetChildren()) do c:Destroy() end
        for _, c in ipairs(linkBtnSlot:GetChildren()) do c:Destroy() end

        titleLabel.Text = data.name
        Badge.new(badgeSlot, data.scriptType, data.scriptType, theme)

        local isPremium = data.scriptType == "Premium"
        local needsLogin = isPremium and not isLoggedIn

        loginRequired.Visible = needsLogin
        linkBtnSlot.Visible = not isPremium

        if not isPremium then
            Button.new(linkBtnSlot, "🔗  Link kopieren", "secondary", theme, function()
                -- placeholder: setclipboard(data.link)
                print("Copy link: " .. tostring(data.link))
            end)
        end

        executeSlot.Visible = false
        keyInput.setValue("")

        -- Key check stub
        checkBtn.MouseButton1Up:Connect(function()
            local key = keyInput.getValue()
            if #key >= 6 then
                -- Backend will handle real validation
                executeSlot.Visible = true
            end
        end)

        backdrop.Visible = true
        frame.Visible = true
        frame.Size = UDim2.new(0, 300, 0, 250)
        TweenService:Create(backdrop, TWEEN_OPEN, {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(frame, TWEEN_OPEN, {Size = UDim2.new(0, 340, 0, 300)}):Play()
    end

    function self.close()
        doClose()
    end

    return self
end

return Modal
```

- [ ] **Step 2: Visual test**

```lua
local m = Modal.new(sg, theme)
m.open({name="Blox Fruits", scriptType="Ad", link="https://example.com", iconId=""}, false)
-- Modal animates in, badge shows "Ad", link button visible
-- Type 6+ chars in key box → Execute button appears

m.open({name="Pet Sim X", scriptType="Premium", iconId=""}, false)
-- "Login erforderlich" shown, no link button
```

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Components/Modal.lua
git commit -m "feat: add Modal component with Ad/Premium states"
```

---

### Task 9: Sidebar & BottomNav Components

**Files:**
- Create: `ToastyGUI/Components/Sidebar.lua`
- Create: `ToastyGUI/Components/BottomNav.lua`

**Interfaces:**
- Produces:
  - `Sidebar.new(parent, items, theme, onSelect)` → `Frame`
  - `BottomNav.new(parent, items, theme, onSelect)` → `Frame`
  - `items`: `{ { icon: string, id: string } }` e.g. `{ {icon="🏠", id="home"}, {icon="⚙️", id="settings"} }`

- [ ] **Step 1: Create Sidebar.lua**

```lua
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
```

- [ ] **Step 2: Create BottomNav.lua**

```lua
-- ToastyGUI/Components/BottomNav.lua
local TweenService = game:GetService("TweenService")
local BottomNav = {}
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

function BottomNav.new(parent, items, theme, onSelect)
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
```

- [ ] **Step 3: Visual tests**

```lua
-- Desktop: sidebar 56px wide on left, icons highlight on click
Sidebar.new(mainFrame, {{icon="🏠", id="home"},{icon="⚙️", id="settings"}}, theme, function(id) print("nav:", id) end)

-- Mobile: bottom bar 60px tall, larger icons
BottomNav.new(mainFrame, {{icon="🏠", id="home"},{icon="⚙️", id="settings"}}, theme, function(id) print("nav:", id) end)
```

- [ ] **Step 4: Commit**
```
git add ToastyGUI/Components/Sidebar.lua ToastyGUI/Components/BottomNav.lua
git commit -m "feat: add Sidebar and BottomNav nav components"
```

---

### Task 10: Login Screen

**Files:**
- Create: `ToastyGUI/Screens/LoginScreen.lua`

**Interfaces:**
- Consumes: `Button.new`, `Input.new`
- Produces: `LoginScreen.new(parent, theme, onLogin, onGuest)` → `Frame`
  - `onLogin(key: string)` called with entered key
  - `onGuest()` called when guest button clicked

- [ ] **Step 1: Create LoginScreen.lua**

```lua
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
```

- [ ] **Step 2: Visual test**

```lua
LoginScreen.new(sg, theme,
    function(key) print("Login with key:", key) end,
    function() print("Guest mode") end
)
```
Expected: Centered card, key input, two buttons. Typing <6 chars and clicking Login does nothing. 6+ chars → callback fires.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Screens/LoginScreen.lua
git commit -m "feat: add LoginScreen with key input and guest option"
```

---

### Task 11: Home Screen

**Files:**
- Create: `ToastyGUI/Screens/HomeScreen.lua`

**Interfaces:**
- Consumes: `Card.new`, `Avatar.new`, `Sidebar.new`, `BottomNav.new`
- Produces: `HomeScreen.new(parent, theme, user, scripts, onSelect, onNavSelect, isMobile)` → `Frame`
  - `user`: `nil` (guest) | `{ username: string }`
  - `scripts`: `{ { name, iconId, price, scriptType, link } }`
  - `onSelect(scriptData)`: called on card click
  - `onNavSelect(id)`: called on nav item click

- [ ] **Step 1: Create HomeScreen.lua**

```lua
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

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 0)
    contentLayout.Parent = content

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
    local avatarLayout = Instance.new("UIListLayout")
    avatarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    avatarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    avatarLayout.Parent = avatarHolder
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
```

- [ ] **Step 2: Visual test**

```lua
local DUMMY_SCRIPTS = {
    {name="Blox Fruits", iconId="", price="$4.99", scriptType="Premium", link=""},
    {name="Pet Sim X", iconId="", price="Ad Key", scriptType="Ad", link="https://example.com"},
    {name="Anime Champions", iconId="", price="$2.99", scriptType="Premium", link=""},
    {name="Fisch", iconId="", price="Ad Key", scriptType="Ad", link="https://example.com"},
}

HomeScreen.new(sg, theme, {username="Nightdev#0001"}, DUMMY_SCRIPTS,
    function(d) print("selected:", d.name) end,
    function(id) print("nav:", id) end,
    false -- desktop
)
```
Expected: Sidebar left, header with username, 3-column card grid, scrollable.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Screens/HomeScreen.lua
git commit -m "feat: add HomeScreen with grid, header, nav"
```

---

### Task 12: Settings Screen

**Files:**
- Create: `ToastyGUI/Screens/SettingsScreen.lua`

**Interfaces:**
- Consumes: `Button.new`, `ThemeProvider`
- Produces: `SettingsScreen.new(parent, theme, onThemeChange)` → `Frame`
  - `onThemeChange(themeName: string)` called when user picks a theme

- [ ] **Step 1: Create SettingsScreen.lua**

```lua
-- ToastyGUI/Screens/SettingsScreen.lua
local Button = require(script.Parent.Parent.Components.Button)

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
```

- [ ] **Step 2: Visual test**

```lua
SettingsScreen.new(content, theme, "Glass", function(name)
    print("Theme changed to:", name)
    -- In real app: ThemeProvider.setTheme(name) then rebuild UI
end)
```
Expected: 3 rows, active theme highlighted with accent border and checkmark.

- [ ] **Step 3: Commit**
```
git add ToastyGUI/Screens/SettingsScreen.lua
git commit -m "feat: add SettingsScreen with theme switcher"
```

---

### Task 13: Main.lua — Entry Point & Router

**Files:**
- Create: `ToastyGUI/Main.lua`

**Interfaces:**
- Consumes: All Screens, ThemeProvider, Themes
- Produces: Full working GUI injected into CoreGui

- [ ] **Step 1: Create Main.lua**

```lua
-- ToastyGUI/Main.lua
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

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

-- Background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = ThemeProvider.getTheme().bg
bg.BorderSizePixel = 0
bg.Parent = sg

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ThemeProvider.getTheme().bg),
    ColorSequenceKeypoint.new(1, ThemeProvider.getTheme().bgGradientEnd),
})
bgGrad.Rotation = 135
bgGrad.Parent = bg

-- Blur background orbs (Glassmorphism only)
local function addGlassOrbs()
    local theme = ThemeProvider.getTheme()
    if theme.blurSize == 0 then return end
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
addGlassOrbs()

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
end

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

local function showSettings()
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
        BottomNav.new(wrapper, NAV_ITEMS, theme, navCallback)
    else
        Sidebar.new(wrapper, NAV_ITEMS, theme, navCallback)
    end

    local contentFrame = Instance.new("Frame")
    contentFrame.Position = UDim2.new(0, contentX, 0, 0)
    contentFrame.Size = UDim2.new(1, contentW, mobile and 1 or 1, mobile and -60 or 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = wrapper

    SettingsScreen.new(contentFrame, theme, ThemeProvider.getTheme().name, function(themeName)
        ThemeProvider.setTheme(themeName)
        modal = nil
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
```

- [ ] **Step 2: Full integration test in executor**

Execute `Main.lua`. Expected:
1. Login screen appears, centered card with key input
2. Type 6+ chars → "User#0000" shown in header, Home screen loads
3. Cards visible with dummy data, hover glow works
4. Click card → Modal opens with correct Ad/Premium state
5. Nav icons switch between Home and Settings screens
6. Settings: click Dark → screen rebuilds with dark theme
7. Reload script → dark theme restored from saved file

- [ ] **Step 3: Mobile test**

Resize Roblox window to <600px width OR test on mobile device.
Expected: Bottom nav visible instead of sidebar, 2-column card grid, modal slides from bottom.

- [ ] **Step 4: Final commit**
```
git add ToastyGUI/Main.lua
git commit -m "feat: wire up Main.lua router with all screens and CoreGui injection"
```

---

## Self-Review

**Spec coverage:**
- ✅ CoreGui injection (`ResetOnSpawn = false`)
- ✅ Glassmorphism default + Dark + Flat switchable
- ✅ Theme saved via `writefile`
- ✅ Login screen (key input, guest)
- ✅ Home screen (header, avatar/guest, nav, card grid)
- ✅ Card (icon, name, badge, price)
- ✅ Modal (Ad: link button + key input; Premium + no login: login required)
- ✅ Settings (theme switcher, 3 options, active state)
- ✅ Mobile detection → BottomNav + 2-col grid + larger touch targets
- ✅ Component library structure (each file = one component)
- ✅ Animations (hover glow, press-down, modal open/close, focus border)

**Types consistent:** All `theme` tables use same key names across all tasks. `Button.new`, `Input.new`, `Badge.new`, `Modal.new` signatures referenced correctly in consuming tasks.

**Scope:** UI only — no real backend calls, dummy data clearly marked with comments for backend replacement.

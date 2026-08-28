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

    local blurEffect = nil

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

    checkBtn.MouseButton1Up:Connect(function()
        local key = keyInput.getValue()
        if #key >= 6 and #key <= 8 then
            -- Backend will handle real validation
            executeSlot.Visible = true
        end
    end)

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
            if blurEffect then
                blurEffect:Destroy()
                blurEffect = nil
            end
        end)
    end

    closeBtn.MouseButton1Click:Connect(doClose)
    backdrop.MouseButton1Click:Connect(doClose)

    function self.open(data, isLoggedIn)
        if blurEffect then blurEffect:Destroy() end
        if theme.blurSize > 0 then
            blurEffect = Instance.new("BlurEffect")
            blurEffect.Size = theme.blurSize
            blurEffect.Parent = game:GetService("Lighting")
        end

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

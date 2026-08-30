local ToastyUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEERSTUDIO101/toasty-gui/main/bundle.lua"))()

local user = { loggedIn=false, username=nil, discord=nil, purchased={} }

local Window = ToastyUI:CreateWindow({
    Title = "Toasty Hub",
})

local ScriptsTab = Window:AddTab("Scripts", "layers")
local SettingsTab = Window:AddTab("Settings", "settings")

local loginSection  -- forward ref so grid callbacks can refresh it

local grid = ScriptsTab:AddScriptGrid({
    scripts = {
        { id="blox-fruits", name="Blox Fruits", type="Premium", universeId="994732206",  placeId="2753915549", link="" },
        { id="pet-sim-x",   name="Pet Sim X",   type="Ad",      universeId="2316994223", placeId="6284583030", link="" },
    },
    user  = user,
    onOpen = function(scriptData, u)
        Window:OpenScriptModal(scriptData, u, {
            onCheckKey = function(id, key)
                -- key prüfen
            end,
            onGetKey = function(sd)
                if sd.link ~= "" then
                    pcall(function() setclipboard(sd.link) end)
                    Window:Notify({ Title="Link kopiert", Icon="link", Duration=3 })
                end
            end,
            onRequestLogin = function()
                Window:ShowLoginGate(
                    function(key)
                        user.loggedIn = true
                        -- user.username und user.discord hier aus API setzen wenn verfügbar
                        grid:Rebuild(grid._scripts, user)
                        if loginSection then loginSection.refresh() end
                    end,
                    function() end
                )
            end,
        })
    end,
})

loginSection = Window:AddLoginButton({
    user = user,
    onLoginClick = function()
        Window:ShowLoginGate(
            function(key)
                user.loggedIn = true
                grid:Rebuild(grid._scripts, user)
                loginSection.refresh()
            end,
            function() end
        )
    end,
})

SettingsTab:AddDropdown({ Title = "UI Design", Icon = "paintbrush-vertical",
    Options = { "Vantix", "Christmas", "Easter", "Blood", "Camo", "VantixBlue", "Neon", "Midnight", "RoseGold", "Light" }, Default = 1,
    Callback = function(selected) Window:SetTheme(selected) end })

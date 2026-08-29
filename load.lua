local ToastyUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/DEERSTUDIO101/toasty-gui@main/bundle.lua"))()

local user = { loggedIn=false, username=nil, purchased={} }

local Window = ToastyUI:CreateWindow({
    Title = "Toasty Hub",
})

local ScriptsTab = Window:AddTab("Scripts", "layers")
local SettingsTab = Window:AddTab("Settings", "settings")
local grid = ScriptsTab:AddScriptGrid({
    scripts = {
        { id="blox-fruits", name="Blox Fruits", type="Premium", universeId="1329557602", placeId="2753915549", link="" },
        { id="pet-sim-x",   name="Pet Sim X",   type="Ad",      universeId="1298332420", placeId="6284583030", link="https://toastyhub.com/key/pet-sim-x" },
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
                        grid:Rebuild(grid._scripts, user)
                    end,
                    function() end
                )
            end,
        })
    end,
})

SettingsTab:AddDropdown({ Title = "UI Design", Icon = "paintbrush-vertical",
    Options = { "Vantix", "Christmas", "Easter", "Blood", "Camo", "VantixBlue", "Neon", "Midnight", "RoseGold", "Light" }, Default = 1,
    Callback = function(selected) Window:SetTheme(selected) end })

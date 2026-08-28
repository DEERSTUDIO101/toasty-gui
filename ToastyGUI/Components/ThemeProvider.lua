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

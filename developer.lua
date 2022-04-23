Developer = Developer or {
    Fonts = {}
}

include("settings.lua")
include("filesystem.lua")

function Developer:Scale(x)
    return x * (1000/ScrH())
end

function Developer:Print(...)
    local sText = ""
    local tArgs = {...}
    for i = 1, #tArgs do
        local arg = tArgs[i]
        if IsEntity(arg) then
            if arg:IsPlayer() then
                sText = sText ..  arg:Nick() .. "("..arg:SteamID()..")"
            elseif arg == Entity(0) then
                sText = sText .. "WORLD"
            else
                sText = sText .. tostring(arg)
            end
        else
            sText = sText .. tostring(arg)
        end
    end

    MsgC(Color(90, 132, 182), "[DEVELOPER] ", color_white, sText)
    return sText
end

function Developer:CreateFont(sFontName, tFontData)
    if tFontData.scale then
        tFontData.size = tFontData.size or self:Scale(tFontData.scale)
    elseif not tFontData.size then
        return
    end

    surface.CreateFont(sFontName, tFontData)
    self.Fonts[sFontName] = tFontData
end

function Developer:TableToList(tbl)
    for k,v in ipairs(tbl) do
        tbl[v] = true
        tbl[k] = nil
    end
end

function Developer:GetRootDir()
    local dir = debug.getinfo(self.GetRootDir).source
    return dir:match("^@(.+)/")
end

hook.Add("OnScreenSizeChanged", "Developer.Fonts", function()
    for k,v in pairs(Developer.Fonts) do
        v.size = self:Scale(v.scale or 10)
        surface.CreateFont(k, v)
    end
end)

Developer:CreateFont("Developer.MenuBar", {
    font = "Roboto",
    size = 18
})

Developer:CreateFont("Developer.Menu", {
    font = "Roboto",
    size = 15
})

Developer:CreateFont("Developer.ModelBrowserElement", {
    font = "Roboto",
    size = 15
})

Developer:CreateFont("Developer.Property", {
    font = "Roboto",
    size = 15
})

Developer:CreateFont("Developer.FileBrowserRow", {
    font = "Roboto",
    size = 13
})

local vguiDir = Developer:GetRootDir().."/vgui/"
local incDir = vguiDir:match("^lua/(.+)")
local tFiles = file.Find(vguiDir.."*.lua", "GAME")
for k,v in ipairs(tFiles) do
    Developer:Print("Including ", v, "\n")
    include(incDir..v)
end
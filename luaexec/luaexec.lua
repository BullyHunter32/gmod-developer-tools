include("codepanel.lua")

local PANEL = {}

function PANEL:Init()
    self.FileStructure = self:Add("Developer.SizeablePanel")
    self.FileStructure:Dock(LEFT)
    self.FileStructure:SetSizeable(false, false, true, false)

    self.CodePanel = self:Add("Developer.LuaExecCode")
    self.CodePanel:Dock(FILL)

    self:AddMenuOption("File", "New", {
        DoClick = function()end   
    })
end

function PANEL:PerformLayout(w, h)
    self.FileStructure:SetWide(w*0.18)
end

function PANEL:OnKeyCodePressed(key)
    self.CodePanel:OnKeyCodePressed(key)
end

vgui.Register("Developer.LuaExec", PANEL, "Developer.Frame")

local f = vgui.Create("Developer.LuaExec")
f:SetSize(1000, 750)
f:Center()
f:MakePopup()
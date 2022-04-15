local PANEL = {}

function PANEL:Init()
    timer.Simple(4, function()
        self:Remove()
    end)

    self.FileStructure = self:Add("Developer.SizeablePanel")
    self.FileStructure:Dock(LEFT)
    self.FileStructure:SetSizeable(false, false, true, false)

    self:AddMenuOption("File", "New", {
        DoClick = function()end   
    })  
end

vgui.Register("Developer.LuaExec", PANEL, "Developer.Frame")

local f = vgui.Create("Developer.LuaExec")
f:SetSize(1000, 750)
f:Center()
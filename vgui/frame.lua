local PANEL = {}

function PANEL:Init()
    self.Header = self:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:SetTall(25)
    self.Header.Paint = function(pnl, w, h)
        surface.SetDrawColor(31, 36, 42)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, h-1, w, h-1)
    end

    self.Header.Close = self.Header:Add("DButton")
    self.Header.Close:Dock(RIGHT)
    self.Header.Close:SetWide(25)
    self.Header.Close.DoClick = function()
        self:Remove()
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(31, 33, 37)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("Developer.Frame", PANEL, "EditablePanel")
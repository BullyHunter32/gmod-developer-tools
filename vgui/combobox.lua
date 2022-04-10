local PANEL = {}

function PANEL:Init()
    self:SetText("")
end

function PANEL:OpenMenu()
    local x, y = self:LocalToScreen()
    local w, h = self:GetSize()
    self.Menu = DermaMenu()
    self.Menu:MakePopup()
    self.Menu:SetPos(x, y + h)
    for k,v in ipairs(self:GetOptions()) do
        local name = v.name
        local data = v.data
        self.Menu:AddOption(name, function()
            self.Selected = data
            self:OnSelected(self.Selected)
        end)
    end
end

function PANEL:OnSelected()
    
end

function PANEL:SetSelected(data)
    self.Selected = data
end

function PANEL:GetOptions()
    return {
        {
            name = "None",
            data = nil
        }
    }
end

function PANEL:DoClick()
    if IsValid(self.Menu) then
        self.Menu:Remove()
        return
    end
    self:OpenMenu()
end

function PANEL:IsOpen()
    return IsValid(self.Menu)
end

local mat = Material("developer/downarrow.png")
function PANEL:Paint(w, h)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(mat)
    local size = h*0.5
    surface.DrawTexturedRectRotated(w-(h*0.75) + (size*0.5), h*0.5, size, size, self:IsOpen() and 180 or 0)
    draw.SimpleText(self:GetSelectedName(self.Selected), "Developer.Property", h*0.2, h*0.5, color_white, 0, 1)
end

vgui.Register("Developer.ComboBox", PANEL, "DButton")
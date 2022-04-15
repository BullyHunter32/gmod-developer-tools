local PANEL = {}

function PANEL:Init()
    self.Menu = self:Add("DPanel")
    self.Menu:Dock(TOP)
    self.Menu:SetTall(25)
    self.Menu.Paint = function(pnl, w, h)
        surface.SetDrawColor(31, 36, 42)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, h-1, w, h-1)
    end

    self.Menu.Close = self.Menu:Add("DButton")
    self.Menu.Close:Dock(RIGHT)
    self.Menu.Close:SetWide(25)
    self.Menu.Close.DoClick = function()
        self:Remove()
    end

    self.MenuOptions = {}
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(35, 38, 44)
    surface.DrawRect(0, 0, w, h)
end

local color_mn_idle = Color(193, 193, 200)
local color_mn_active = color_white
function PANEL:CreateMenuCategory(sName)
    local btn = self.Menu:Add("DButton")
    btn:Dock(LEFT)
    btn:SetText(sName)
    btn:SizeToContentsX(24)
    btn:SetText("")
    btn.Paint = function(pnl, w, h)
        local col = color_mn_idle
        if pnl:IsHovered() then
            col = color_mn_active
        end
        draw.SimpleText(sName, "Developer.MenuBar", w/2, h/2, col, 1, 1)
    end
    btn.DoClick = function(pnl)
        local x,y = pnl:LocalToScreen()
        local w, h = pnl:GetSize()
        local menu = DermaMenu()
        menu:MakePopup()
        menu:SetPos(x, y + h)
        local options = self.MenuOptions[sName]
        for k, v in pairs(options or {}) do
            local setting = Developer.Settings[v.optionId]
            if not v.PopulateSubMenu then
                local op = menu:AddOption(v.Name, function(pnl)
                    if v.DoClick then
                        v.DoClick(pnl)
                    end
                    if not setting then return end
                    if setting.type == "toggle" then
                        pnl:ToggleCheck()
                    end
                end) 
                op.OnChecked = function(pnl, state)
                    setting.value = state
                end
                if setting then
                    op:SetChecked(setting.value)
                end
            else
                local op = menu:AddSubMenu(v.Name, function()
                end)
                v.PopulateSubMenu(op)
            end
        end
    end
end

function PANEL:AddMenuOption(sCategory, sName, tData)
    if not self.MenuOptions[sCategory] then
        self.MenuOptions[sCategory] = {}
        local btn = self:CreateMenuCategory(sCategory)
    end
    tData.Name = sName
    table.insert(self.MenuOptions[sCategory], tData)
end

vgui.Register("Developer.Frame", PANEL, "EditablePanel")
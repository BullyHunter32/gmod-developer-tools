local PANEL = {}

AccessorFunc(PANEL, "m_iSize", "ButtonSize", FORCE_NUMBER)

function PANEL:Init()
    self:SetButtonSize(30)
    self.Buttons = {}
end

local color_btn_idle = Color(37, 41, 46)
local color_btn_active = Color(41, 44, 49)
local color_icon_idle = Color(160, 160, 165)
local color_icon_active = Color(235, 235, 243)

function PANEL:AddButton(tData)
    local btn = self:Add("DButton")
    local size = self:GetButtonSize()
    btn:SetText("")
    btn:SetPos(0, 0)
    btn:SetSize(size, size)
    btn.Icon = tData.Icon or Material("icon16/add.png")
    btn.Paint = function(pnl, w, h)
        local col = color_btn_idle
        local iconCol = color_icon_idle
        if pnl:IsHovered() then
            col = color_btn_active
            iconCol = color_icon_active
        end
        draw.RoundedBox(2, 1, 1, w-2, h-2, col)

        surface.SetDrawColor(iconCol)
        surface.SetMaterial(pnl.Icon)
        surface.DrawTexturedRect(4, 4, w-8, h-8)
    end
    btn.DoClick = function(pnl)
        if tData.Callback then
            tData.Callback(pnl, self)
        end
    end
    table.insert(self.Buttons, btn)
    self:InvalidateLayout() 
    return btn
end

function PANEL:PerformLayout(w, h)
    local x = 0
    local y = 0
    local r = 1
    local size = self:GetButtonSize()
    local len = #self.Buttons
    for i = 1, len do
        local btn = self.Buttons[i]
        btn:SetPos(x, y)
        btn:SetSize(size, size)
        x = x + size
        if x + size > w and i ~= len then
            x = 0
            y = y + size
            r = r + 1
        end
    end 
    self:SetTall(math.max((r-1)*size, r*size))
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(29, 34, 37)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("Developer.ButtonControls", PANEL, "EditablePanel")
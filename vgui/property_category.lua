include("frame.lua") -- gets included twice cause cool

local PANEL = {}

function PANEL:Init()
    self.Header = self:Add("EditablePanel")
    self.Header:Dock(TOP)
    self.Header:SetTall(25)
    self.Header.Paint = function(pnl, w, h)
        surface.SetDrawColor(0, 0, 0, 90)
        surface.DrawLine(0, h-1, w, h-1)
    end

    self.CollapseBtn = self.Header:Add("DButton")
    self.CollapseBtn:Dock(LEFT)
    self.CollapseBtn:SetText("")
    self.CollapseBtn.Paint = function(pnl, w, h)
        surface.SetDrawColor(54, 54, 60)
        surface.DrawRect(1, 1, w, h)
        if not self.m_bCollapsible then return end
        draw.SimpleText("c", "ChatFont", w/2, h/2, color_white, 1, 1)
    end
    self.CollapseBtn.DoClick = function()
        if not self.m_bCollapsible then return end
        self:Toggle()
    end

    self.NamePanel = self.Header:Add("Developer.SizeablePanel")
    self.NamePanel:Dock(LEFT)
    self.NamePanel:SetSizeable(false, false, true, false)
    self.NamePanel.Paint = function(pnl, w, h)
        surface.SetDrawColor(0, 0, 0, 90)
        surface.DrawLine(w-1, 0, w-1, h)
    end
    self.NamePanel.OnResized = function(pnl, w)
        self:SetPropWidth(w)
    end
    self.NamePanel.Name = self.NamePanel:Add("DLabel")
    self.NamePanel.Name:Dock(FILL)
    self.NamePanel.Name:DockMargin(6, 0, 0, 0)
    self.NamePanel.Name:SetFont("Developer.Property")
    self.NamePanel.Name:SetText("Placeholder")

    self.Properties = self:Add("Panel")
    self.Properties:Dock(TOP)
    self.Properties:SetTall(0)
    self.Properties:DockPadding(13, 0, 0, 0)
    self.iProps = 0
    self.tProps = {}
end

function PANEL:SetCollapsible(bCollapsible)
    self.m_bCollapsible = bCollapsible
    if not bCollapsible then
        self:Collapse()
    end
end

function PANEL:GetPropertyHeight()
    return self.iProps * 25
end

function PANEL:SetPropWidth(w)
    for i = 1, self.iProps do
        local p = self.tProps[i]
        print("SETTING WIDTH TO ", w)
        p.NamePanel:SetWide(w)
    end
end

local types = {
    ["Vector"] = function(self, fnCallback)
        local input = self.Header:Add("DTextEntry")
        input:Dock(FILL)
        input:SetText("0, 0, 0")
        input.OnValueChange = function(pnl, txt)
            txt = string.Replace(txt, " ", "")
            local x, y, z = txt:match("([%-%d%g]+),([%-%d%g]+),([%-%d%g]+)")
            x = tonumber(x) or 0
            y = tonumber(y) or 0
            z = tonumber(z) or 0
            fnCallback(pnl, Vector(x,y,z))
        end
        return input
    end,
    ["Angle"] = function(self, fnCallback)
        local input = self.Header:Add("DTextEntry")
        input:Dock(FILL)
        input:SetText("0, 0, 0")
        input.OnValueChange = function(pnl, txt)
            txt = string.Replace(txt, " ", "")
            local x, y, z = txt:match("([%-%d%g]+),([%-%d%g]+),([%-%d%g]+)")
            x = tonumber(x) or 0
            y = tonumber(y) or 0
            z = tonumber(z) or 0
            fnCallback(pnl, Angle(x,y,z))
        end
        return input
    end,
    ["Float"] = function(self, fnCallback)
        local input = self.Header:Add("DTextEntry")
        input:Dock(FILL)
        input:SetText("1")
        input.AllowInput = function(pnl, char)
            return tonumber(char) == nil and self:GetText():find(".") == nil
        end
        input.OnValueChange = function(pnl, txt)
            if txt == "" then
                pnl:SetText("1")
            end
            fnCallback(pnl, tonumber(pnl:GetText()) or 1)
        end
        return input
    end,
    ["Integer"] = function(self, fnCallback)
        local input = self.Header:Add("DTextEntry")
        input:Dock(FILL)
        input:SetText("1")
        input.AllowInput = function(pnl, char)
            return tonumber(char) == nil
        end
        input.OnValueChange = function(pnl, txt)
            if txt == "" then
                pnl:SetText("1")
            end
            fnCallback(pnl, tonumber(pnl:GetText()) or 1)
        end
        return input
    end,
    ["Object"] = function(self, fnCallback, master)
        local input = self.Header:Add("Developer.ComboBox")
        input:Dock(FILL)
        function input:GetSelectedName(selectedData)
            if selectedData and selectedData.name then
                return selectedData.name
            end
            return "Invalid"
        end
        function input:GetOptions()
            local options = {
                {
                    name = "None",
                    data = nil
                }
            }
            for k,v in ipairs(master.Models) do
                table.insert(options, {
                    name = v.name,
                    data = v
                })
            end
            return options
        end
        function input:OnSelected(dat)
            fnCallback(pnl, dat)
        end
        return input
    end
}

function PANEL:AddProperty(sName, sType, fnSetup, fnCallback, master)
    fnCallback = fnCallback or function()end

    self.iProps = self.iProps + 1
    local pnl = self.Properties:Add("Developer.PropertyRow")
    pnl:Dock(TOP)
    pnl:SetTall(25)
    pnl:SetName(sName)
    pnl.NamePanel.OnResized = function(pnl, w)
        self:SetPropWidth(w)
    end
    pnl.Type = sType
    local type = types[sType]
    pnl.fnSetup = fnSetup
    if type then
        print("creating vector stuff")
        pnl.Input = type(pnl, fnCallback, master)
    end
    table.insert(self.tProps, pnl)
end

function PANEL:Setup(ent)
    for i = 1, self.iProps do
        local p = self.tProps[i]
        if p.fnSetup then
            p:fnSetup(ent)
        end
    end
end

function PANEL:SetName(sText)
    self.NamePanel.Name:SetText(sText)
    self.NamePanel.Name:SizeToContentsX()
    self.m_sName = sText
end

function PANEL:GetText(sText)
    return self.m_sName
end

function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.NamePanel:SetWide(w*0.5)
end

function PANEL:PerformLayout(w, h)
    self.NamePanel.Name:SizeToContentsX()
    self:InitSizes(w, h)
    self.CollapseBtn:SetWide(self.Header:GetTall())
    self:SetTall(self.Properties:GetTall()+self.Header:GetTall())
end

function PANEL:Expand()
    self.m_iCollapsing = 1
    self.m_flCollapseTime = CurTime()
end

function PANEL:Collapse()
    self.m_iCollapsing = 2
    self.m_flCollapseTime = CurTime()
end

function PANEL:Toggle()
    if self:IsCollapsed() then
        self:Expand()
    else
        self:Collapse()
    end
end

function PANEL:IsCollapsed()
    return self.m_iCollapsing == nil or self.m_iCollapsing == 4
end

function PANEL:Think()
    local collapseState = self.m_iCollapsing
    if collapseState == 1 then
        local frac = math.min((CurTime() - self.m_flCollapseTime)/0.25, 1)
        self.Properties:SetTall(frac*self:GetPropertyHeight())
        self:InvalidateLayout()
        if frac == 1 then
            self.m_iCollapsing = 3
        end
    elseif collapseState == 2 then
        local frac = 1-math.min((CurTime() - self.m_flCollapseTime)/0.25, 1)
        self.Properties:SetTall(frac*self:GetPropertyHeight())
        self:InvalidateLayout()
        if frac == 0 then
            self.m_iCollapsing = 4
        end
    end
end

vgui.Register("Developer.PropertyRow", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
    self.NamePanel:SetSizeable(false, false,false, false)
end

function PANEL:Paint(w, h)

end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)
    self.NamePanel:SetWide(w)
end

vgui.Register("Developer.PropertyCategory", PANEL, "Developer.PropertyRow")
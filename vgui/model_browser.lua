include("frame.lua") -- gets included twice cause cool

local PANEL = {}

function PANEL:Init()
    self.Search = self:Add("DTextEntry")
    self.Search:Dock(TOP)
    self.Search:SetTall(30)
    self.Search.OnEnter = function(pnl, txt)
        self:SearchModels(txt)
    end

    self.Body = self:Add("DIconLayout")
    self.Body:Dock(FILL)
end

function PANEL:SearchModels(txt)
    self.Body:Clear()

    local tResults = search.GetResults(txt, "props", 10)
    for i = 1, #tResults do
        local tResult = tResults[i]
        local btn = self.Body:Add(tResult.icon)
        btn.DoClick = function()
            self:Select(tResult)
        end
    end
end

function PANEL:OnSelected(mdl)
    
end

function PANEL:Select(tData)
    self:OnSelected(tData.words[1])
    self:Remove()
end

function PANEL:Think()
    PrintTable(self:GetChildren())
    self:MoveToFront() -- little hack
end

-- function PANEL:OnFocusChanged(bGained)
--     self:MakePopup()
-- end

vgui.Register("Developer.ModelBrowser", PANEL, "Developer.Frame")
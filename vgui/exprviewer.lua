local PANEL = {}

function PANEL:Init()
    self.CurrentDir = "/"

    self.Output = self:Add("DTextEntry")
    self.Output:Dock(RIGHT)
    self.Output:SetMultiline(true)

    self.Body = self:Add("Developer.SizeablePanel")
    self.Body:Dock(TOP)
    self.Body:SetSizeable(false, false, false, true)

    self.TextBox = self:Add("DTextEntry")
    self.TextBox:SetMultiline(true)
    self.TextBox:SetText("lorem ipsum nada nada")
    self.TextBox:Dock(FILL)

    self.Expr = self:Add("DTextEntry")
    self.Expr:Dock(BOTTOM)
    self.Expr:SetUpdateOnType(true)
    self.Expr.OnValueChange = function(pnl, txt)
        self:EvaluateExpression(txt)
    end
end

function PANEL:EvaluateExpression(expr)
    local success, txt = pcall(string.match, self.TextBox:GetText(), expr)
    txt = txt or ""
    self.Output:SetText(txt)
end

function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.TextBox:SetTall(h*0.95)
    self.Output:SetWide(w*0.25)
end

function PANEL:PerformLayout(w, h)
    self:InitSizes(w, h)
end

vgui.Register("Developer.PatternViewer", PANEL, "Developer.Frame")

-- local f = vgui.Create("Developer.PatternViewer")
-- f:SetSize(500, 400)
-- f:Center()
-- f:MakePopup()
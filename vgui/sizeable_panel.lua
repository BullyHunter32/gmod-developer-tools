local PANEL = {}

AccessorFunc(PANEL, "m_bSizeableLeft", "SizeableLeft", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSizeableRight", "SizeableRight", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSizeableTop", "SizeableTop", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSizeableBottom", "SizeableBottom", FORCE_BOOL)
AccessorFunc(PANEL, "m_iDragging", "Dragging")
AccessorFunc(PANEL, "m_iMaxSize", "MaxSize", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iMinSize", "MinSize", FORCE_NUMBER)

function PANEL:Init()
    self:SetMinSize(34)
    self:GetMaxSize(self:GetParent():GetWide())
    self:SetSizeableLeft(false)
    self:SetSizeableTop(false)
    self:SetSizeableRight(false)
    self:SetSizeableBottom(false)
end

function PANEL:SetSizeable(l, t, r, b)
    self:SetSizeableLeft(l)
    self:SetSizeableTop(t)
    self:SetSizeableRight(r)
    self:SetSizeableBottom(b)
end

function PANEL:GetDraggedSide(cx, cy)
    local w, h = self:GetSize()
    if self:GetSizeableLeft() and cx < 8 and cx > 0 then
        return LEFT
    elseif self:GetSizeableTop() and cy < 8 and cy > 0 then
        return TOP
    elseif self:GetSizeableRight() and cx > w - 8 and cx < w then
        return RIGHT
    elseif self:GetSizeableBottom() and cy > h - 8 and cy < h then
        return BOTTOM
    end
end

function PANEL:SetStartPos(cx, cy)
    self.m_vecStartCursorPos = Vector(cx, cy) -- i'm lazy
end

function PANEL:GetStartPos()
    return self.m_vecStartCursorPos
end

function PANEL:SetStartSize(w, h)
    self.m_vecStartSize = Vector(w, h)
end

function PANEL:GetStartSize(w, h)
    return self.m_vecStartSize
end

function PANEL:OnMousePressed()
    local cx, cy = input.GetCursorPos()
    local x, y = self:LocalToScreen()
    cx = cx - x
    cy = cy - y
    local side = self:GetDraggedSide(cx, cy)
    if not side then return end
    self:SetCursor("sizewe")
    self:SetDragging(side)
    self:SetStartPos(cx, cy)

    local w, h = self:GetSize()
    self:SetStartSize(w, h)
end

function PANEL:OnMouseReleased()
    self:SetDragging(nil)
    self:SetCursor("arrow")
end

function PANEL:PaintOver(w, h)
    -- if not self:IsHovered() then return end

    local cx, cy = input.GetCursorPos()
    local x, y = self:LocalToScreen()
    cx = cx - x
    cy = cy - y
    local side = self:GetDragging()--self:GetDraggedSide(cx, cy)
    if not side then return end

    
    surface.SetDrawColor(230, 230, 230, 80)

    if side == LEFT then
        surface.DrawLine(0, 0, 0, h)
    elseif side == RIGHT then
        surface.DrawLine(w-1, 0, w-1, h)
    elseif side == TOP then
        surface.DrawLine(0, 0, w, 0)
    elseif side == BOTTOM then
        surface.DrawLine(0, h-1, 0, h-1)
    end
end

function PANEL:PerformLayout()
    
end

function PANEL:OnResized(w)

end

function PANEL:Think()
    local side = self:GetDragging()
    if not side then return end
    if not input.IsMouseDown(MOUSE_LEFT) then
        self:SetDragging(nil)
        return
    end
    local startPos = self:GetStartPos()
    local cx, cy = input.GetCursorPos()
    local x, y = self:LocalToScreen()
    cx = cx - x
    cy = cy - y

    local curPosX, curPosY = self:GetPos()
    if side == LEFT then
        local newWidth = self:GetStartSize().x + (startPos.x - cx)
        newWidth = math.min(math.max(newWidth, self:GetMinSize() or 0), self:GetMaxSize() or self:GetParent():GetWide())
        self:SetWide(newWidth)
        self:OnResized(newWidth)
        self:GetParent():InvalidateLayout(t)
    elseif side == RIGHT then
        local newWidth = self:GetStartSize().x + (cx - startPos.x)
        newWidth = math.min(math.max(newWidth, self:GetMinSize() or 0), self:GetMaxSize() or self:GetParent():GetWide())
        self:SetWide(newWidth)
        self:OnResized(newWidth)
        self:GetParent():InvalidateLayout()
    elseif side == TOP then
        local newHeight = self:GetStartSize().y + (startPos.y - cy)
        self:SetTall(newHeight)
        -- self:SetPos(curPosX, curPosY+(self:GetStartSize().y-newHeight))
        self:OnResized(newHeight)
        self:GetParent():InvalidateLayout()
    end
end

vgui.Register("Developer.SizeablePanel", PANEL, "EditablePanel")
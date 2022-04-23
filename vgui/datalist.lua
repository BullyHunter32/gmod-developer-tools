local PANEL = {}

function PANEL:Init()
    self.Columns = {}
    self.Rows = {}
    self.ColumnWidths = {}

    self.Body = self:Add("DPanel")
    self.Body:Dock(FILL)
end

function PANEL:SetColumnWidth(...)
    self.ColumnWidths = {...}
    self:InvalidateLayout()
end

function PANEL:AddColumn(name)
    self.m_bInitializedSizes = false
    local column = self.Body:Add("Developer.SizeablePanel")
    print("Added column ", name, column)
    column:SetSizeable(false, false, true, false)
    column:Dock(LEFT)
    table.insert(self.Columns, column)
    PrintTable(self.Columns)
end

function PANEL:AddColumns(...)
    for k, v in ipairs({...}) do
        self:AddColumn(v)
    end
end

function PANEL:AddRow(...)
    local data = {...}
    
    local len = #data
    local pnl
    local row = {}
    for i = 1, #self.Columns do
        local column = self.Columns[i]
        local dat = data[i] or ""

        pnl = column:Add("DLabel")
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, 3, 0)
        pnl.text = tostring(dat)
        pnl:SetText(dat)
        pnl:SizeToContentsX()
        pnl:SetText("")
        pnl:SetMouseInputEnabled(true)
        pnl:SetFont("Developer.FileBrowserRow")
        pnl.DoClick = function(pnl)
            if row.DoClick then
                row.DoClick(self, pnl)
            end
        end
        pnl.PerformLayout = function(pnl, w, h)
            local txt = ""
            local curW = 8 -- for xpos
            surface.SetFont(pnl:GetFont())
            local totalWidth = surface.GetTextSize(pnl.text)
            local elipseSize = surface.GetTextSize("...")
            for i = 1, #pnl.text do
                local char = pnl.text[i]
                local cW, cH = surface.GetTextSize(char)
                curW = curW + cW
                if curW > w - (elipseSize) then -- 6px for margin
                    txt = txt .. "..."
                    break
                end
                txt = txt .. char
            end
            pnl.renderText = txt
        end
        pnl.Paint = function(pnl, w, h)
            if pnl:IsHovered() then
                row.Hovered = pnl 
            end
            if IsValid(row.Hovered) then
                if not row.Hovered:IsHovered() or column:GetDragging(nil) then
                    row.Hovered = nil
                else
                    -- local bOld = DisableClipping(true)
                    surface.SetDrawColor(180, 180, 180, 90)
                    surface.DrawRect(0, 0, w + 3, h) -- +3 for margin
                    -- DisableClipping(bOld)
                end
            end
            draw.SimpleText(pnl.renderText, pnl:GetFont(), 8, h/2, color_white, 0, 1)
        end
        table.insert(row, pnl)
    end
    table.insert(self.Rows, row)
    return row
end

function PANEL:Clear()
    for i = 1, #self.Columns do
        self.Columns[i]:Clear()
    end
    self.Rows = {}
end

function PANEL:PerformLayout(w, h)
    do
        local len = #self.Columns
        local defaultSize = w/len
        local curW = 0
        if self.m_bInitializedSizes then
            len = 0
        else
            self.m_bInitializedSizes = true
        end

        for i = 1, len do
            local column = self.Columns[i]
            if not IsValid(column) then
                print("wtf ", i, column)
                goto skip
            end
            local size = self.ColumnWidths[i] or defaultSize
            if size == -1 then
                size = w - curW
            elseif size < 1 then
                size = size * w
            end
            curW = curW + size
            column:SetWide(size)
            if i == len then
                column:Dock(FILL)
                column:SetSizeable()
            else -- Might be a previous last column so we reset to our good stuff
                column:Dock(LEFT)
                column:SetSizeable(false, false, true, false)
            end
            ::skip::
        end
    end
end

vgui.Register("Developer.DataList", PANEL, "EditablePanel")
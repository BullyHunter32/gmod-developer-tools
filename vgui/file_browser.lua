FILE_BROWSER_OPEN = 0
FILE_BROWSER_SAVE = 1

local PANEL = {}

AccessorFunc(PANEL, "m_iMode", "Mode", FORCE_NUMBER)

function PANEL:Init()
    self:SetMode(FILE_BROWSER_OPEN)

    self.CurrentDir = "/"
    self.Sidebar = self:Add("Developer.SizeablePanel")
    self.Sidebar:Dock(LEFT)
    self.Sidebar:SetSizeable(false, false, true, false)

    self.Body = self:Add("Panel")
    self.Body:Dock(FILL)

    self.Body.Files = self.Body:Add("Developer.DataList")
    self.Body.Files:AddColumn("Name")
    self.Body.Files:AddColumn("Date Modified")
    self.Body.Files:AddColumn("Type")
    self.Body.Files:AddColumn("Size")
    self.Body.Files:Dock(FILL)
    self.Body.Files.Paint = nil

    

    self.Body.Dir = self.Body:Add("DPanel")
    self.Body.Dir:Dock(TOP)
    self.Body.Dir.Paint = function(pnl, w, h)
        -- draw.SimpleText(self.CurrentDir, "Developer.Menu", h/2, h/2, color_white, 0, 1)
    end

    self.Body.FilePanel = self.Body:Add("DPanel")
    self.Body.FilePanel:Dock(BOTTOM)
    self.Body.FilePanel.Input = self.Body.FilePanel:Add("DTextEntry")
    self.Body.FilePanel.PerformLayout = function(pnl, w, h)
        local width = w*0.75
        local height = h*0.8
        pnl.Input:SetSize(width, height)
        pnl.Input:SetPos(w/2 - width*0.6, h/2 - height/2)
    end

    self:SetupFolder("")
end

local FILE_TYPES = {
    ["png"] = "PNG",
    ["jpg"] = "JPG",
    ["exe"] = "Application",
    ["zip"] = "ZIP Archive",
    ["txt"] = "Text Document"
}

function PANEL:AddFile(sDir, isFolder)
    local fileName
    -- if isFolder then
    --     fileName = sDir:match("[^/](.+)$") or sDir
    -- else
        fileName = sDir:match("([^/]+)$") or sDir
    -- end

    local dateModified = os.date("%x %H:%m", file.Time(sDir, "GAME"))
    local fileType = isFolder and "Folder" or fileName:match("([^%.]+)$") or "File"
    fileType = FILE_TYPES[fileType] or fileType

    local size = isFolder and "" or string.NiceSize(file.Size(sDir, "GAME") or 0)
    local panel = self.Body.Files:AddRow(fileName, dateModified, fileType, size)
    panel.DoClick = function(pnl)
        if isFolder then
            self:SetupFolder(sDir .. "/")
        else
            self:SelectFile(sDir, fileName)
        end
    end
end

function PANEL:SelectFile(sDir)

end

function PANEL:SetupCrumbs()
    local dir = self.CurrentDir
    local crumbs = {
        "/"
    }
    local c = 1
    for folder in dir:gmatch("[^/]+") do
        c = c + 1
        crumbs[c] = folder
    end
    self.Body.Dir:Clear()
    local cur = ""
    local name = ""
    for i = 1, c do
        if i > 1 then
            name = crumbs[i]
            cur = cur .. name .. "/"
        end


        local btn = self.Body.Dir:Add("DButton")
        btn:Dock(LEFT)
        btn.label = name == "" and "/" or name
        btn:SetText(btn.label)
        btn:SetFont("Developer.Menu")
        btn:SizeToContentsX(4)
        btn:SetText("")
        btn.dir = cur
        btn.DoClick = function(pnl)
            print(pnl.dir)
            self:SetupFolder(pnl.dir)
        end
        btn.Paint = function(pnl, w, h)
            local col
            if i == c then
                col = Color(25, 90, 210)
            elseif pnl:IsHovered() then
                col = Color(190, 190, 190)
            else
                col = Color(150, 153, 158)
            end

            draw.SimpleText(btn.label, "Developer.Menu", w/2, h/2, col, 1, 1)
        end

        if name == "" then goto skip end
        local div = self.Body.Dir:Add("DLabel")
        div:Dock(LEFT)
        div:SetText("/")
        div:SetFont("Developer.Menu")
        div:SizeToContentsX()
        ::skip::
    end
end

function PANEL:SetupFolder(sDir)
    self.CurrentDir = sDir
    self.Body.Files:Clear()
    self:SetupCrumbs()

    local files, folders = file.Find(sDir .. "*", "GAME")
    for k,v in ipairs(folders or {}) do
        if sDir == "" and v == "/" then
            goto skip
        end

        self:AddFile(sDir..v, true)
        ::skip::
    end

    for k,v in ipairs(files or {}) do
        self:AddFile(sDir..v)
    end
end



function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.Sidebar:SetWide(h*0.33)
end

function PANEL:PerformLayout(w, h)
    self:InitSizes(w, h)

    local fileW = w*0.25
    local dateModW = w*0.2
    local typeW = w*0.12
    local sizeW = w - (fileW + dateModW + typeW)
    self.Body.Files:SetColumnWidth(0.35, 0.28, 0.18, -1)
end

vgui.Register("Developer.FileBrowser", PANEL, "Developer.Frame")

local f = vgui.Create("Developer.FileBrowser")
f:SetSize(500, 400)
f:Center()
f:MakePopup()
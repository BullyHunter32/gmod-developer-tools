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

    self.Body.Files = self.Body:Add("DScrollPanel")
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

function PANEL:AddFile(sDir, isFolder)
    local fileName
    -- if isFolder then
    --     fileName = sDir:match("[^/](.+)$") or sDir
    -- else
        fileName = sDir:match("([^/]+)$") or sDir
    -- end

    local panel = self.Body.Files:Add("DButton")
    panel:Dock(TOP)
    panel:SetTall(25)
    panel:SetText("")
    panel.Paint = function(pnl, w, h)
        draw.SimpleText(fileName, "Developer.Menu", h*0.5, h*0.5, color_white, 0, 1)
    end
    panel.DoClick = function(pnl)
        if not isFolder then return end
        self:SetupFolder(sDir .. "/")
    end
end

function PANEL:AddEscape()
    local prevFolder = self.CurrentDir:match("(.+)/.+$")
    prevFolder = prevFolder and prevFolder or ""
 
    local panel = self.Body.Files:Add("DButton")
    panel:Dock(TOP)
    panel:SetTall(25)
    panel:SetText("")
    panel.Paint = function(pnl, w, h)
        draw.SimpleText("../", "Developer.Menu", h*0.5, h*0.5, color_white, 0, 1)
    end
    panel.DoClick = function(pnl)
        self:SetupFolder(prevFolder)
    end
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
        btn:SetText(name)
        btn:SetFont("Developer.Menu")
        btn:SizeToContentsX(4)
        btn.dir = cur
        btn.DoClick = function(pnl)
            print(pnl.dir)
            self:SetupFolder(pnl.dir)
        end

        local div = self.Body.Dir:Add("DLabel")
        div:Dock(LEFT)
        div:SetText("/")
        div:SetFont("Developer.Menu")
        div:SizeToContentsX(4)
    end
end

function PANEL:SetupFolder(sDir)
    self.CurrentDir = sDir
    self.Body.Files:Clear()
    self:AddEscape()
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
end

vgui.Register("Developer.FileBrowser", PANEL, "Developer.Frame")

local f = vgui.Create("Developer.FileBrowser")
f:SetSize(500, 400)
f:Center()
f:MakePopup()
include("developer.lua")

local PANEL = {}

AccessorFunc(PANEL, "m_bVisible", "IsVisible", FORCE_BOOL)


local mat_blind = Material("developer/eye_blind.png")
local mat_eye = Material("developer/eye.png")
local color_eye = Color(235, 239, 245)
local color_blind = Color(150, 150, 160)

function PANEL:Init()
    self:SetIsVisible(true)
    self.VisibilityToggle = self:Add("DButton")
    self.VisibilityToggle:Dock(RIGHT)
    self.VisibilityToggle:SetText("")
    self.VisibilityToggle.Paint = function(pnl, w, h)
        local mat = mat_blind
        local col = color_blind
        if self:GetIsVisible() then
            mat = mat_eye
            col = color_eye
        end
        surface.SetDrawColor(col)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(2, 2, w-4, h-4)
    end
    self.VisibilityToggle.DoClick = function(pnl)
        local new = not self:GetIsVisible()
        self:SetIsVisible(new)
        self:OnVisibilityToggled(new)
    end
end

function PANEL:SetData(tData)
    self.Data = tData
end

function PANEL:OnVisibilityToggled(bToggle)
    
end

function PANEL:Paint(w, h)
    local col = color_blind
    if self:GetIsVisible() then
        col = color_eye
    end

    draw.SimpleText(self:GetName(), "Developer.ModelBrowserElement", h*0.15, h*0.5, col, 0, 1)
end

function PANEL:GetName()
    return self.Data and self.Data.name or "{UNKNOWN ELEMENT NAME}"
end

function PANEL:PerformLayout(w, h)
    self.VisibilityToggle:SetWide(h*1)
end

vgui.Register("Developer.ModelBrowserElement", PANEL, "DButton")

local PANEL = {}

AccessorFunc(PANEL, "m_vecCamPos", "CamPos")
AccessorFunc(PANEL, "m_angCamAng", "CamAng")
AccessorFunc(PANEL, "m_flCamDistance", "CamDistance")

function PANEL:Init()
    self:SetCamPos(Vector(-90, 30, 50))
    self:SetCamAng((Vector() - self:GetCamPos()):Angle())
    self:SetCamDistance(90)
    timer.Simple(30, function()
        self:Remove()
    end)
    self.Menu = self:Add("DPanel")
    self.Menu:Dock(TOP)
    self.Menu:SetTall(25)
    self.Menu.Paint = function(pnl, w, h)
        surface.SetDrawColor(31, 36, 42)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, h-1, w, h-1)
    end

    self.Elements = self:Add("Developer.SizeablePanel")
    self.Elements:Dock(LEFT)
    self.Elements:SetSizeable(false, false, true, false)
    self.Elements.Paint = function(pnl, w, h)
        surface.SetDrawColor(37, 42, 49)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(w-1, 0, w-1, h)
    end
    self.Elements.Controls = self.Elements:Add("Developer.ButtonControls")
    self.Elements.Controls:Dock(TOP)
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png"), Callback = function()
        self:LookupModel(function(model)
            if model then
                self:AddModel(model)
            end
        end)
    end})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png"), Callback = function()
        self:Remove()
    end})

    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})
    self.Elements.Controls:AddButton({Icon = Material("developer/add.png")})

    self.ModelRenderer = self:Add("Panel")
    self.ModelRenderer:Dock(FILL)
    self.ModelRenderer.Paint = function(pnl, w, h)
        self:RenderModels(w, h, pnl)
    end
    self.ModelRenderer.OnMousePressed = function(pnl)
        pnl.m_bRotating = true
        pnl:MouseCapture(true)
    end
    self.ModelRenderer.OnMouseReleased = function(pnl)
        pnl:MouseCapture(false)
        pnl.m_bRotating = false
    end

    local camAng = Angle()
    local rot = 0
    self.ModelRenderer.OnCursorMoved = function(pnl, cx, cy)
        if not pnl.m_bRotating then return end   
        self.prevMousePos = self.prevMousePos or Vector(cx, cy)
        
        local diffX = self.prevMousePos.x - cx
        local diffY = self.prevMousePos.y - cy

        if diffX > 0 then
            rot = rot - 0.066
        else
            rot = rot + 0.066
        end

        local lookAtPos = Vector()
        local newCamPos = Vector(
            lookAtPos.x + self:GetCamDistance()*math.sin(rot),
            lookAtPos.y + self:GetCamDistance()*math.cos(rot),
            30
        )

        local ang = (lookAtPos-newCamPos):Angle()
        ang.z = 0

        self:SetCamAng(ang)
        self:SetCamPos(newCamPos)
        self.prevMousePos = Vector(cx, cy)
    end

    self.Properties = self:Add("Developer.SizeablePanel")
    self.Properties:Dock(RIGHT)
    self.Properties:SetSizeable(true, false, false, false)
    self.Properties.Paint = function(pnl, w, h)
        surface.SetDrawColor(37, 42, 49)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, 0, 0, h)
    end

    self.MenuOptions = {}
    
    self:AddMenuOption("File", "Open", {})
    self:AddMenuOption("File", "Save", {})
    self:AddMenuOption("File", "Open Recent", {})
    self:AddMenuOption("File", "Open Backup", {})

    self:AddMenuOption("Edit", "Undo", {})
    self:AddMenuOption("Edit", "Copy", {})
    self:AddMenuOption("Edit", "Paste", {})

    self.Models = {}
end

function PANEL:LookupModel(fnCallback)
    local height = ScrH()*0.5
    local width = height*1.15
    local frame = vgui.Create("Developer.ModelBrowser")
    frame:SetSize(width, height)   
    frame:Center()
    frame:MakePopup()
    frame.OnSelected = function(_, mdl)
        fnCallback(mdl)
    end
end

function PANEL:AddModel(mdl)
    local dat = {
        model = mdl,
        name = mdl,
        csEnt = ClientsideModel(mdl)
    }
    dat.csEnt:SetNoDraw(true)
    dat.csEnt:SetPos(Vector())

    table.insert(self.Models, dat)
    local pnl = self.Elements:Add("Developer.ModelBrowserElement")
    pnl:Dock(TOP)
    pnl:SetTall(28)
    pnl:SetData(dat)
    pnl:SetText("")
    -- pnl.data = self.Models[i]
    -- pnl.DoRightClick = function(pnl)
    --     local menu = DermaMenu(false, pnl)
    --     menu:AddOption("Rename", function()
    --         Derma_StringRequest("Rename Item", "Enter the new name", pnl.data.name, function(txt)
    --             pnl.data.name = txt
    --         end, function() end, "Confirm", "Abort")
    --     end)
    -- end
end

function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.Elements:SetWide(w*0.15)
    self.Properties:SetWide(w*0.1)
end

function PANEL:PerformLayout(w, h)
    self:InitSizes(w, h)
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
        draw.SimpleText(sName, "Developer.Menu", w/2, h/2, col, 1, 1)
    end
end

function PANEL:AddMenuOption(sCategory, sName, tData)
    if not self.MenuOptions[sCategory] then
        self.MenuOptions[sCategory] = {}
        local btn = self:CreateMenuCategory(sCategory)
    end
end

local matBlurScreen = Material( "pp/blurscreen" )
local function DrawBlur(pnl, w, h)
	local Fraction = 1

	local x, y = pnl:LocalToScreen( 0, 0 )

	-- Menu cannot do blur
	if ( !MENU_DLL ) then
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
	end

	surface.SetDrawColor( 32, 32, 32, 100 )
	surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(35, 38, 44)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:OnRemove()
    for i = 1, #self.Models do
        local dat = self.Models[i]
        if IsValid(dat.csEnt) then
            dat.csEnt:Remove()
        end
    end
end

function PANEL:OnMouseWheeled(delta)
    local dist = self:GetCamDistance() + delta
    self:SetCamDistance(dist)
end

local color_x = Color(255, 0, 0, 10)
local color_y = Color(0, 255, 0, 10)
function PANEL:DrawModelGrid()
    render.SetColorMaterial()
    for x = -5000, 5000, 100 do
        render.DrawBeam(Vector(x, -5000), Vector(x, 5000), 1, 1, 1, color_x)
    end
    for y = -5000, 5000, 100 do
        render.DrawBeam(Vector(-5000, y), Vector(5000, y), 1, 1, 1, color_y)
    end
end

function PANEL:RenderModels(w, h, pnl)
    local camPos = self:GetCamPos()
    local camAng = self:GetCamAng()

    local x, y = pnl:LocalToScreen()
    cam.Start3D(camPos, camAng, 75, x, y, w, h)
        for i = 1, #self.Models do
            local dat = self.Models[i]
            if dat and IsValid(dat.csEnt) then
                dat.csEnt:DrawModel()
            end
        end
        self:DrawModelGrid()
    cam.End3D()
end 

vgui.Register("Developer.ModelEditor", PANEL, "Panel")

local height = ScrH()*0.85
local width = height*1.66

local panel = vgui.Create("Developer.ModelEditor")
panel:SetSize(width, height)
panel:Center()
panel:MakePopup()
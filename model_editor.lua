include("developer.lua")

local PANEL = {}

AccessorFunc(PANEL, "m_bVisible", "IsVisible", FORCE_BOOL)


local mat_blind = Material("developer/eye_blind.png")
local mat_eye = Material("developer/eye.png")
local color_eye = Color(235, 239, 245)
local color_blind = Color(150, 150, 160)
local color_select_highlight = Color(185, 105, 20)
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
    if not self.Data then return end
    local ent = self.Data.csEnt
    if IsValid(ent) then
        ent.m_bShouldDraw = bToggle 
    end
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

function PANEL:OnClick()

end

function PANEL:DoClick()
    self:OnClick()
end

vgui.Register("Developer.ModelBrowserElement", PANEL, "DButton")

local PANEL = {}

AccessorFunc(PANEL, "m_vecCamPos", "CamPos")
AccessorFunc(PANEL, "m_angCamAng", "CamAng")
AccessorFunc(PANEL, "m_vecLookAt", "LookAt")
AccessorFunc(PANEL, "m_flCamDistance", "CamDistance")

local function GetCursorPos(px, py)
    local cx, cy = input.GetCursorPos()
    cx = cx - px
    cy = cy - py
    return cx, cy
end

function PANEL:Init()
    self:SetCamPos(Vector(-90, 30, 50))
    self:SetCamAng((Vector() - self:GetCamPos()):Angle())
    self:SetCamDistance(90)
    self:SetLookAt(Vector())
    
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
    -- hook.Add("PreDrawHalos", self.ModelRenderer, function()
    --     if IsValid(self.selected) then
    --         halo.Add({self.selected}, color_select_highlight, 2, 2, 2 )
    --     end
    -- end)
    self.ModelRenderer.OnMousePressed = function(pnl, key)
        if self.m_bDraggingEnt then
            if key == MOUSE_LEFT then
                self.m_bDraggingEnt = false 
                self.m_vecDragOffset = nil
                self.dragAxis = nil
                return
            elseif key == MOUSE_RIGHT then
                -- self.m_DraggingEnt:SetPos(self.m_vecDragOrigin)
                self.m_DraggingEnt.vecPos = self.m_vecDragOrigin
                self:SetupProps(self.m_DraggingEnt)
                self.selected = nil
                self.m_bDraggingEnt = false
                self.dragAxis = nil
                self.m_vecDragOffset = nil
                return
            end
        end

        if key == MOUSE_LEFT then
            local pX, pY = pnl:LocalToScreen()
            local w, h = pnl:GetSize()
            local cenX = (w/2) 
            local cenY = (h/2)
            local cX, cY = GetCursorPos(pX, pY)
            
            local fov = 75
            local diffX = ((cenX-cX)/w)*fov
            local diffY = ((cenY-cY)/h)*fov

            local dir = self:GetCamAng():Forward() - (self:GetCamAng():Right() * math.rad(diffX)) + (self:GetCamAng():Up() * math.rad(diffY))


            local ent = self:TraceLine({
                start = self:GetCamPos(),
                dir = dir,
                range = 500
            })

            self:SelectEntity(ent)

            return
        end
        if key ~= MOUSE_MIDDLE and key ~= MOUSE_RIGHT then return end
        pnl.m_bRotating = true
        pnl:MouseCapture(true)
    end
    self.ModelRenderer.OnMouseReleased = function(pnl)
        pnl:MouseCapture(false)
        pnl.m_bRotating = false
        self.prevPos = nil
    end

    local camAng = Angle()
    local rot, vert = 0,0
    self.ModelRenderer.Think = function(pnl)
        local pX, pY = pnl:LocalToScreen()
        local cx, cy = GetCursorPos(pX, pY)
        local w, h = pnl:GetSize()

        if self.m_bDraggingEnt then
            local mult = self:GetCamDistance()*0.001
            local diffX = (self.m_vecStartDragPos.x - cx)*mult
            local diffY = (self.m_vecStartDragPos.y - cy)*mult

            local pos = self.m_vecDragOrigin + (self.m_vecDragOffset or Vector())
            local newPos
            if self.dragAxis then
                if self.dragAxis == 1 then
                    newPos = pos + self.m_DraggingEnt:GetAngles():Right()*diffX
                elseif self.dragAxis == 2 then
                    newPos = pos + self.m_DraggingEnt:GetAngles():Forward()*diffX
                elseif self.dragAxis == 3 then
                    newPos = pos + self.m_DraggingEnt:GetAngles():Up()*diffY
                end
            else
                newPos = pos - self:GetCamAng():Right()*diffX + self:GetCamAng():Up()*diffY
            end

            -- self.m_DraggingEnt:SetPos(newPos)
            self.m_DraggingEnt.vecPos = newPos
            self:SetupProps(self.m_DraggingEnt)

            local bReset = false
            local realx, realy = input.GetCursorPos()
            if cx > w then
                input.SetCursorPos(pX + 1, realy)
                bReset = true
            end
            if cx < 0 then
                input.SetCursorPos(pX + (w-1), realy) 
                bReset = true
            end
            if cy > h then
                input.SetCursorPos(realx, pY + 1)
                bReset = true
            end
            if cy < 0 then
                input.SetCursorPos(realx, pY + (h-1)) 
                bReset = true
            end

            if bReset then
                cx, cy = GetCursorPos(pX, pY)
                self.m_vecStartDragPos = Vector(cx, cy)
                self.m_vecDragOffset = (self.m_vecDragOffset or Vector()) + self.m_DraggingEnt:GetPos() - (self.m_vecDragOffset or self.m_vecDragOrigin) 
            end
            return
        end

        local cenX = pX + (w/2) 
        local cenY = pY + (h/2) 

        if pnl.m_bRotating then
            self.prevPos = self.prevPos or Vector(cx, cy)
            local diffX = self.prevPos.x - cx
            local diffY = self.prevPos.y - cy

            rot = rot - diffX*0.002
            vert = vert - diffY*0.002

            self.prevPos = Vector(cx, cy)
        end

        local lookAtPos = self:GetLookAt()
        local newCamPos = Vector(
            lookAtPos.x + self:GetCamDistance()*math.sin(rot),
            lookAtPos.y + self:GetCamDistance()*math.cos(rot),
            lookAtPos.z + self:GetCamDistance()*math.sin(vert)
        )     
        self:SetCamPos(newCamPos)
        self:SetCamAng((self:GetLookAt()-newCamPos):Angle())
    end
    self.ModelRenderer.StartDrag = function(pnl, ent)
        local pX, pY = pnl:LocalToScreen()
        local cx, cy = GetCursorPos(pX, pY)
        self.m_bDraggingEnt = true
        self.m_vecStartDragPos = Vector(cx,cy)
        self.m_DraggingEnt = ent
        self.m_vecDragOrigin = ent:GetPos()
        self.dragAxis = nil
    end
    self.ModelRenderer.FocusOnEnt = function(pnl, ent)
        local mins, maxs = ent:GetRenderBounds()
        local size = math.max(mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z)
        self:SetCamDistance(size*2)
        self:SetLookAt(ent:GetPos() + ((mins + maxs)/2))
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
    self:AddMenuOption("File", "Close", {
        DoClick = function()
            self:Remove()
        end
    })

    self:AddMenuOption("Edit", "Undo", {})
    self:AddMenuOption("Edit", "Copy", {})
    self:AddMenuOption("Edit", "Paste", {})

    self:AddMenuOption("View", "Wireframe Boxes", {
        toggleable = true,
        optionId = "modeledit_wireframe"
    })

    self:AddMenuOption("Export", "Quick Export", {
        DoClick = function()
            local code = ""
            for k,v in ipairs(self.Models) do
                local c = [[
local {variableName} = ClientsideModel("{model}")
-- {variableName}.Parent = ... ({parentModel})
{variableName}.posOffset = {posOffset}
{variableName}.angOffset = {angOffset}
function {variableName}:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

        pos = pos + ang:Right()*self.posOffset.x
        pos = pos + ang:Forward()*self.posOffset.y
        pos = pos + ang:Up()*self.posOffset.z

        ang:RotateAroundAxis(ang:Right(), self.angOffset.x)
        ang:RotateAroundAxis(ang:Forward(), self.angOffset.y)
        ang:RotateAroundAxis(ang:Up(), self.angOffset.z)
    end

    self:SetPos(pos)
    self:SetAngles(ang)
end

]]
                local varName = v.name:Replace(" ", "_")
                if v.name == v.model then
                    varName = v.model:match("([^/]+)%.mdl$") or v.name
                end
                local variables = {
                    ["variableName"] = varName,
                    ["model"] = v.model,
                    ["posOffset"] = ("Vector(%s, %s, %s)"):format(
                        v.csEnt.vecPos.x, v.csEnt.vecPos.y, v.csEnt.vecPos.z
                    ),
                    ["angOffset"] = ("Angle(%s, %s, %s)"):format(
                        v.csEnt.angAngles.x, v.csEnt.angAngles.y, v.csEnt.angAngles.z
                    ),
                    ["parentModel"] = v.csEnt.parentObject and v.csEnt.parentObject.model or "Not required",
                }

                c = c:gsub("{(.-)}", function(code)
                    return variables[code] or code
                end)
                code = code .. c
            end
            SetClipboardText(code)
        end
    })

    self.PropertyTypes = {}

    self:AddPropertyType("Transform", "Position", "Vector", function(this, ent)
        local pos = ent:GetPos()
        local txt = string.format("%.2f, %.2f, %.2f", pos.x, pos.y, pos.z)
        this.Input:SetText(txt)
    end, function(_, vec)
        -- self.selected:SetPos(vec)
        self.selected.vecPos = vec
    end)

    self:AddPropertyType("Transform", "Angle", "Angle", function(this, ent)
        local ang = ent:GetAngles()
        local txt = string.format("%.2f, %.2f, %.2f", ang.x, ang.y, ang.z)
        this.Input:SetText(txt)
    end, function(this, ang)
        self.selected.angAngles = ang
        self.selected:SetAngles(ang)
    end)

    self:AddPropertyType("Transform", "Scale", "Float", function(this, ent)
        local scale = ent:GetModelScale()
        this.Input:SetText(scale)
    end, function(this, scale)
        self.selected:SetModelScale(scale, 0)
    end)

    self:AddPropertyType("Parent", "Object", "Object", function(this, ent)
        this.Input:SetSelected(ent.parentObject or nil)
    end, function(this, selected)
        self.selected.parentObject = selected
        PrintTable(self.selected.parentObject or {"L"})
    end)

    self:AddPropertyType("Parent", "Bone", "Float", function(this, ent)
        local bone = ent.parentBone
        this.Input:SetText(bone or "0")
    end, function(this, bone)
        self.selected.parentBone = bone
    end)

    self.Models = {}
end

function PANEL:AddPropertyType(sCategory, sName, sType, fnSetup, fnCallback)
    if not self.PropertyTypes[sCategory] then
        local pnl = self.Properties:Add("Developer.PropertyCategory")
        self.PropertyTypes[sCategory] = pnl
        pnl:Dock(TOP)
        pnl:SetTall(25)
        pnl:SetName(sCategory)
        pnl:SetCollapsible(true)
    end
    self.PropertyTypes[sCategory]:AddProperty(sName, sType, fnSetup, fnCallback, self)
end

function PANEL:SelectEntity(ent)
    self.selected = ent
    self:OnSelected(ent)
end

function PANEL:SetupProps(ent)
    if not IsValid(ent) then return end
    for k,v in pairs(self.PropertyTypes) do
        v:Setup(ent)
    end
end

function PANEL:OnSelected(ent)
    self:SetupProps(ent)
end

function PANEL:OnMoved(ent)
    self:SetupProps(ent)
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

function PANEL:OnKeyCodePressed(key)
    if key == KEY_G then
        if self.selected then
            self.ModelRenderer:StartDrag(self.selected)
        end
    end

    if key == KEY_PERIOD then
        if self.selected then
            self.ModelRenderer:FocusOnEnt(self.selected)
        end
    end
    
    if self.m_bDraggingEnt then
        if key == KEY_X then
            self.dragAxis = 1
        elseif key == KEY_Y then
            self.dragAxis = 2
        elseif key == KEY_Z then
            self.dragAxis = 3
        end
    end

    if key == KEY_DELETE then
        if IsValid(self.selected) then
            for i = 1, #self.Models do
                local d = self.Models[i]
                if d.csEnt == self.selected then
                    d.panel:Remove()
                    d.csEnt:Remove()
                    table.remove(self.Models, i)
                    self.selected = nil
                    break
                end
            end
        end
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
    dat.csEnt.vecPos = Vector()
    dat.csEnt.angAngles = Angle()

    table.insert(self.Models, dat)
    local pnl = self.Elements:Add("Developer.ModelBrowserElement")
    dat.panel = pnl
    pnl:Dock(TOP)
    pnl:SetTall(28)
    pnl:SetData(dat)
    pnl:SetText("")
    pnl.OnClick = function(pnl)
        self:SelectEntity(pnl.Data.csEnt)
    end
    pnl.DoRightClick = function(pnl)
        local x, y = pnl:LocalToScreen()
        local w, h = pnl:GetSize()
        local menu = DermaMenu()
        menu:SetPos(x, y + h)
        menu:MakePopup()
        menu:AddOption("Rename", function()
            Derma_StringRequest("Rename Item", "Enter the new name", dat.name, function(txt)
                dat.name = txt
            end, function() end, "Confirm", "Abort")
        end)
        menu:AddSpacer()
        menu:AddOption("Delete", function()
            Derma_Query("You sure?", "Delete", "Yes", function()
                for i = 1, #self.Models do
                    local d = self.Models[i]
                    if d.csEnt == dat.csEnt then
                        d.panel:Remove()
                        d.csEnt:Remove()
                        table.remove(self.Models, i)
                        break
                    end
                end

            end, "No")
        end)
    end
end

function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.Elements:SetWide(w*0.12)
    self.Properties:SetWide(w*0.125)
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
    btn.DoClick = function(pnl)
        local x,y = pnl:LocalToScreen()
        local w, h = pnl:GetSize()
        local menu = DermaMenu()
        menu:MakePopup()
        menu:SetPos(x, y + h)
        local options = self.MenuOptions[sName]
        for k, v in pairs(options or {}) do
            local setting = Developer.Settings[v.optionId]
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
    local dist = self:GetCamDistance() - delta*5
    self:SetCamDistance(dist)
end

local color_x = Color(255, 0, 0, 40)
local color_y = Color(0, 255, 0, 40)
local color_m = Color(90, 90, 90, 80) -- misc
function PANEL:DrawModelGrid()
    render.SetColorMaterial()
    for x = -5000, 5000, 100 do
        render.DrawBeam(Vector(x, -5000), Vector(x, 5000), 0.1, 1, 1, color_m)
    end
    for y = -5000, 5000, 100 do
        render.DrawBeam(Vector(-5000, y), Vector(5000, y), 0.1, 1, 1, color_m)
    end
    render.DrawBeam(Vector(-5000, 0), Vector(5000, 0), 0.3, 1, 1, color_x)
    render.DrawBeam(Vector(0, -5000), Vector(0, 5000), 0.3, 1, 1, color_y)
end

local function GetRenderPos(ent)
    local entPos = ent.vecPos or Vector()
    local entAng = ent.angAngles or Angle()
    local renderPos = entPos
    local renderAng = entAng
    if ent.parentObject and IsValid(ent.parentObject.csEnt) then
        local parent = ent.parentObject.csEnt
        renderPos, ang = GetRenderPos(parent)
        renderPos = renderPos + ang:Right()*entPos.x
        renderPos = renderPos + ang:Forward()*entPos.y
        renderPos = renderPos + ang:Up()*entPos.z

        renderAng = Angle(ang.x, ang.y, ang.z)
        renderAng:RotateAroundAxis(renderAng:Right(), entAng.x)
        renderAng:RotateAroundAxis(renderAng:Forward(), entAng.y)
        renderAng:RotateAroundAxis(renderAng:Up(), entAng.z)
    end
    return renderPos, renderAng
end

function PANEL:RenderModels(w, h, pnl)
    local camPos = self:GetCamPos()
    local camAng = self:GetCamAng()

    local x, y = pnl:LocalToScreen()
    cam.Start3D(camPos, camAng, 75, x, y, w, h)
        for i = 1, #self.Models do
            local dat = self.Models[i]
            if dat and IsValid(dat.csEnt) and dat.csEnt.m_bShouldDraw ~= false then
                if self.selected == dat.csEnt then
                    render.SetColorMaterial()
                    render.SetColorModulation(1, 0 ,0)
                end
                local ent = dat.csEnt
                local renderPos, renderAng = GetRenderPos(dat.csEnt)
                
                dat.csEnt:SetPos(renderPos)
                dat.csEnt:SetAngles(renderAng)
                dat.csEnt:DrawModel()
                draw.NoTexture()
                render.SetColorModulation(1, 1, 1)

                if Developer:GetSetting("modeledit_wireframe") then
                    local mins, maxs = dat.csEnt:GetRenderBounds()
                    local pos = dat.csEnt:GetPos()
                    render.DrawWireframeBox(pos, Angle(), mins, maxs, color_white)
                end
            end
        end
        -- if self.lastTrace then
        --     render.DrawBeam(self.lastTrace[1], self.lastTrace[1] + self.lastTrace[2] * self.lastTrace[3], 1, 1, 1, color_x)

        --     local start = self.lastTrace[1]
        --     local dir = self.lastTrace[2]
        --     local distance = self.lastTrace[3]
                
        --     local pos = start
        --     local inc = distance/100
        --     for i = 1, distance, inc do
        --         pos = pos + (dir*inc)
        --         render.DrawWireframeSphere(pos, 0.1, 10, 10, color_white)
        --     end
        -- end
        self:DrawModelGrid()
    cam.End3D()

end 

local function CheckCollision(self, pos)
    for i = 1, #self.Models do
        local dat = self.Models[i]
        if dat and IsValid(dat.csEnt) and dat.csEnt.m_bShouldDraw ~= false then
            local mins, maxs = dat.csEnt:GetRenderBounds()
            local epos = dat.csEnt:GetPos()
            mins = mins + epos
            maxs = maxs + epos
            if pos:WithinAABox(mins, maxs) then
                return dat.csEnt
            end
        end
    end
end

function PANEL:TraceLine(tData)
    local start = tData.start or self:GetCamPos()
    local dir = tData.dir or self:GetCamAng():Forward()
    local distance = tData.range or 800

    self.lastTrace = {start,dir,distance}

    local pos = start
    local inc = distance/100
    for i = 1, distance, inc do
        pos = pos + (dir*inc)
        local hit = CheckCollision(self, pos)
        if hit then
            return hit
        end
    end
end

vgui.Register("Developer.ModelEditor", PANEL, "EditablePanel")

local height = ScrH()*0.85
local width = height*1.66

local panel = vgui.Create("Developer.ModelEditor")
panel:SetSize(width, height)
panel:Center()
panel:MakePopup()
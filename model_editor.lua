include("developer.lua")

local function SaveScene(name, models)
    local data = {
        elements = {},
        props = {}
    }
    for k,v in ipairs(models) do
        local anim = v.csEnt.animSequence
        anim = anim and anim.index
        table.insert(data.elements, {
            name = v.name,
            model = v.model,
            pos = v.csEnt.vecPos,
            ang = v.csEnt.angAngles,
            entity = v.csEnt,
            sequence = anim,
            scale = v.csEnt:GetModelScale()
        })
    end

    for k,v in ipairs(data.elements) do
        local parent = v.entity.parentObject
        if parent and IsValid(parent.csEnt) then
            for i, dat in ipairs(data.elements) do
                local ent = dat.entity
                if parent.csEnt == ent then
                    local bone = v.entity.parentBone
                    bone = bone and bone.boneid
                    data.props[k] = {
                        parent = i,
                        bone = bone,
                    }
                end
            end
        end
    end

    file.Write("developer/"..name..".json", util.TableToJSON(data, true))
end

local function LoadScene(name, pnl)
    local fileContent = file.Read("developer/"..name..".json", "DATA")
    local data = util.JSONToTable(fileContent)

    for k,v in ipairs(pnl.Models) do
        pnl:DeleteModel(v.csEnt)
    end

    local elements = {}
    for k,v in ipairs(data.elements) do
        local dat = pnl:AddModel(v.model)
        dat.name = v.name or "{CORRUPTED}"
        local ent = dat.csEnt
        if IsValid(ent) then
            ent.vecPos = Vector(v.pos)
            ent.angAngles = Angle(v.ang)
            if v.scale then
                ent:SetModelScale(v.scale)
            end
            if v.sequence then
                ent.animSequence = ent:GetSequenceInfo(v.sequence)
            end
        end
        table.insert(elements, dat)
    end

    for k,v in pairs(data.props) do
        local element = elements[k]
        if elements[v.parent] then
            element.csEnt.parentObject = elements[v.parent]

            if v.bone then
                print("Bone: ", v.bone)
                element.csEnt.parentBone = {
                    boneid = v.bone,
                    name = element.csEnt.parentObject.csEnt:GetBoneName(v.bone)
                }
            end
        end
    end

    PrintTable(elements)
end

local function GetRecentSaves()
    local files = file.Find("developer/*.json", "DATA", "datedesc")
    local exp = {}
    PrintTable(files)
    for i = 1, math.min(#files, 8) do
        local name = files[i]:match("(.-)%.")
        exp[i] = name
    end
    return exp
end
GetRecentSaves()

local MATERIAL_WIREFRAME = Material("models/wireframe")

-- Forward Declarations
local GetRenderPos

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
    self:SetCamDistance(50)
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

    self.ModelRenderer.CamDrag = self.ModelRenderer:Add("DButton")
    self.ModelRenderer.CamDrag.OnMousePressed = function(pnl, key)
        if key == MOUSE_LEFT then
            self.m_bCamDragging = true
            pnl:MouseCapture(true)

            local w, h = pnl:GetSize()
    
            local rcX, rcY = pnl:LocalToScreen()
            rcX = rcX + w*0.5
            rcY = rcY + h*0.5
            input.SetCursorPos(rcX, rcY)
            self.camDragPivot = Vector(rcX, rcY)
        end
    end
    self.ModelRenderer.CamDrag.OnMouseReleased = function(pnl, key)
        self.m_bCamDragging = false
        pnl:MouseCapture(false)
    end

    self.ModelRenderer.CamDrag.OnCursorMoved = function(pnl, x, y)
     
    end

    self.ModelRenderer.OnMousePressed = function(pnl, key)
        if not self.m_bDraggingEnt or not self.m_bCamDragging then
            if key == MOUSE_MIDDLE then
                if input.IsKeyDown(KEY_LSHIFT) then
                    self.m_bCamDragging = true    
                    local x, y = input.GetCursorPos()
                    self.camDragPivot = Vector(x, y)
                else
                    pnl.m_bRotating = true
                    pnl:MouseCapture(true)
                end
                return
            end
        end

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
            local cenX = w/2 
            local cenY = h/2
            local cX, cY = GetCursorPos(pX, pY)
            local k = 0.85
            w = w * k
            h = h * k
            local fov = 75
            local diffX = (cenX-cX)/w
            local diffY = (cenY-cY)/h

            local x = math.rad(diffX)*fov
            local y = math.rad(diffY)*(h*(fov/w))

            local dir = self:GetCamAng():Forward() - (self:GetCamAng():Right() * x) + (self:GetCamAng():Up()*y)
            local ent = self:TraceLine({
                start = self:GetCamPos(),
                dir = dir,
                range = 500
            })

            self:SelectEntity(ent)

            return
        end
    end
    self.ModelRenderer.OnMouseReleased = function(pnl, key)
        if self.m_bCamDragging and (key == MOUSE_MIDDLE or key == MOUSE_RIGHT) then
            self.m_bCamDragging = false
        end
        pnl:MouseCapture(false)
        pnl.m_bRotating = false
        self.prevPos = nil
    end

    local camAng = Angle()
    local rot, vert = -0.55, 0.3
    self.ModelRenderer.Think = function(pnl)
        local pX, pY = pnl:LocalToScreen()
        local cx, cy = GetCursorPos(pX, pY)
        local w, h = pnl:GetSize()

        if self.m_bCamDragging then
            local w, h = pnl.CamDrag:GetSize()
            local x, y = input.GetCursorPos()
    
            local rcX, rcY = self.camDragPivot.x, self.camDragPivot.y

            local diffX = x - rcX
            local diffY = y - rcY

            local mult = (self:GetCamDistance())*0.001
            diffX = diffX*mult
            diffY = diffY*mult

            local curLookAt = self:GetLookAt()
            local newLookAt = curLookAt
            newLookAt = newLookAt + self:GetCamAng():Right()*(diffX*0.01)
            newLookAt = newLookAt - self:GetCamAng():Up()*(diffY*0.01)
            self:SetLookAt(newLookAt)

        elseif self.m_bDraggingEnt then
            local mult = self:GetCamDistance()*0.001
            local diffX = (self.m_vecStartDragPos.x - cx)*mult
            local diffY = (self.m_vecStartDragPos.y - cy)*mult

            local pos = self.m_vecDragOrigin + (self.m_vecDragOffset or Vector())
            local newPos
            if self.dragAxis then
                if self.dragAxis == 1 then
                    newPos = pos + angle_zero:Right()*diffX
                elseif self.dragAxis == 2 then
                    newPos = pos + angle_zero:Forward()*diffX
                elseif self.dragAxis == 3 then
                    newPos = pos + angle_zero:Up()*diffY
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
                self.m_vecDragOffset = (self.m_vecDragOffset or Vector()) + self.m_DraggingEnt.vecPos - (self.m_vecDragOffset or self.m_vecDragOrigin) 
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
        self.m_vecDragOrigin = ent.vecPos
        self.dragAxis = nil
    end
    self.ModelRenderer.FocusOnEnt = function(pnl, ent)
        local mins, maxs = ent:GetRenderBounds()
        mins:Rotate(ent:GetAngles())
        maxs:Rotate(ent:GetAngles())
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

    self.AnimTimeline = self:Add("Developer.SizeablePanel")
    self.AnimTimeline:Dock(BOTTOM)
    self.AnimTimeline:SetSizeable(false, true, false, false)
    self.AnimTimeline.Paint = function(pnl, w, h)
        surface.SetDrawColor(37, 42, 49)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, 0, w, 0)
    end
    self.AnimTimeline.Header = self.AnimTimeline:Add("Panel")
    self.AnimTimeline.Header:Dock(TOP)
    self.AnimTimeline.Header:SetTall(24)
    self.AnimTimeline.Header:SetKeyboardInputEnabled(false)
    self.AnimTimeline.Header.OnMousePressed = function(key)
        self.AnimTimeline:OnMousePressed(key)

    end
    self.AnimTimeline.Header.OnMouseReleased = function(key)
        self.AnimTimeline:OnMouseReleased(key)
        
    end
    
    self.AnimTimeline.Caret = self.AnimTimeline.Header:Add("DPanel")
    self.AnimTimeline.Caret:SetSize(24, 24)
    self.AnimTimeline.Caret.OnMousePressed = function(pnl, key)
        if key == MOUSE_LEFT then
            local cx, cy = input.GetCursorPos()
            local px, py = pnl:GetPos()
            pnl.m_bDragging = true
            pnl.cursorPos = Vector(cx, cy)
            pnl.startPos = Vector(px, py)
            pnl:MouseCapture(true)
        end
    end
    self.AnimTimeline.Caret.OnMouseReleased = function(pnl, key)
        pnl.m_bDragging = false
        pnl:MouseCapture(false)
    end
    self.AnimTimeline.Caret.Think = function(pnl)
        if not pnl.m_bDragging then return end
        local cx, cy = input.GetCursorPos()
        local w = self.AnimTimeline.Header:GetWide()
        local h = pnl:GetTall()
        local diffX = cx - pnl.cursorPos.x

        local minX = -h*0.5
        local maxX = w-(h*0.5)

        local newPos = math.max(math.min(pnl.startPos.x + diffX, maxX), minX)
        local ratio = (newPos - minX)/w

        self:OnTimelineChange(ratio)
        pnl:SetPos(newPos, 0)
    end
   
    self.MenuOptions = {}
    
    self:AddMenuOption("File", "Open", {
        Shortcut = {KEY_LCONTROL, KEY_O}
    })
    self:AddMenuOption("File", "Save", {
        DoClick = function()            
            Derma_StringRequest("Save Object", "Enter a unique filename", "untitled", function(txt)
                SaveScene(txt, self.Models)
            end, function() end, "Save", "Cancel")
        end,
        Shortcut = {KEY_LCONTROL, KEY_S}
    })
    self:AddMenuOption("File", "Open Recent", {
        PopulateSubMenu = function(pnl)
            local files = GetRecentSaves()
            for i = 1, #files do
                pnl.Menu:AddOption(files[i], {
                    DoClick = function()
                        LoadScene(files[i], self)
                    end
                })
            end
        end,
    })
    self:AddMenuOption("File", "Close", {
        DoClick = function()
            self:Remove()
        end,
        Shortcut = {KEY_LALT, KEY_F4}
    })

    self:AddMenuOption("Edit", "Undo", {
        Shortcut = {KEY_LCONTROL, KEY_Z}
    })
    self:AddMenuOption("Edit", "Copy", {
        Shortcut = {KEY_LCONTROL, KEY_C}
    })
    self:AddMenuOption("Edit", "Paste", {
        Shortcut = {KEY_LCONTROL, KEY_V}
    })

    self:AddMenuOption("View", "Wireframe Bounds", {
        toggleable = true,
        optionId = "modeledit_wireframe"
    })
    
    self:AddMenuOption("View", "Wireframe Models", {
        toggleable = true,
        optionId = "modeledit_wireframemodels"
    })

    self:AddMenuOption("Export", "Quick Export", {
        DoClick = function()
            local code = ""
            for k,v in ipairs(self.Models) do
                local c = [[
local {variableName} = ClientsideModel("{model}")
{variableName}.Parent = {parentName} -- {parentModel}
{variableName}.BoneId = {parentBoneID}
{variableName}.posOffset = {posOffset}
{variableName}.angOffset = {angOffset}
function {variableName}:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        if self.BoneId then
            pos, ang = parent:GetBonePosition(self.BoneId)
        else
            pos = parent:GetPos()
            ang = parent:GetAngles()
        end

        pos = pos + ang:Forward()*self.posOffset.x
        pos = pos + ang:Right()*self.posOffset.y
        pos = pos + ang:Up()*self.posOffset.z

        ang:RotateAroundAxis(ang:Forward(), self.angOffset.x)
        ang:RotateAroundAxis(ang:Right(), self.angOffset.y)
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
                local parentName = "nil"
                local parent = v.csEnt.parentObject
                if parent then
                    parentName = parent.name
                    if parentName == parent.model then
                        parentName = parent.model:match("([^/]+)%.mdl$") or parentName
                    end
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
                    ["parentName"] = v.csEnt.parentObject and v.csEnt.parentObject.name or "nil",
                    ["parentBone"] = v.csEnt.parentBone and v.csEnt.parentBone.name or "",
                    ["parentBoneID"] = v.csEnt.parentBone and v.csEnt.parentBone.boneid or "nil"
                }

                c = c:gsub("{(.-)}", function(code)
                    return variables[code] or code
                end)
                code = code .. c
            end
            SetClipboardText(code)
        end
    })

    self:AddMenuOption("Export", "Export as PNG", {
        DoClick = function()
            local bExported = false
            -- local x, y = self.ModelRenderer:LocalToScreen()
            local w, h = ScrW(), ScrH()
            local rt = GetRenderTarget("transparent_png_export", w, h, false)
            local renderTarget = render.GetRenderTarget()
            local texture = Material("icon16/add.png"):GetTexture("$basetexture")
            hook.Add("PreRender", self, function()
                render.Clear(0, 0, 0, 0, true, true)
                render.SetWriteDepthToDestAlpha(false)

                -- render.OverrideAlphaWriteEnable(false)
                if bExported then
                    hook.Remove("PreRender", self)
                    return
                end
   
                bExported = true

                local mdlRenW, mdlRenH = self.ModelRenderer:GetSize()
                local ratio = mdlRenW/mdlRenH

                local camPos = self:GetCamPos()
                local camAng = self:GetCamAng()
                camPos = camPos - (camAng:Forward()*ratio)
                -- render.SetBlend(1)
                cam.Start3D(camPos, camAng, 75, 0, 0, ScrW(), ScrH())
                    render.SetColorModulation(1, 1, 1)
                    for i = 1, #self.Models do
                        local dat = self.Models[i]
                        if dat and IsValid(dat.csEnt) then
                            local ent = dat.csEnt
                            local renderPos, renderAng = GetRenderPos(dat.csEnt)
                            
                            if dat.csEnt.animSequence then
                                local expectedSequence = dat.csEnt:LookupSequence(dat.csEnt.animSequence.label)
                                if not dat.csEnt.seqStart then --dat.csEnt:GetSequence() ~= expectedSequence or dat.csEnt:IsSequenceFinished() or dat.csEnt:SequenceDuration(expectedSequence) > CurTime() - (dat.csEnt.seqStart or 0) then
                                    dat.csEnt:ResetSequence(expectedSequence)
                                    dat.csEnt.seqStart = CurTime()
                                end
                            end
            
                            if Developer:GetSetting("modeledit_wireframemodels") then
                                render.SetMaterial(MATERIAL_WIREFRAME)
                                dat.csEnt:SetMaterial("models/wireframe")
                            else
                                dat.csEnt:SetMaterial("")
                            end
            
                            dat.csEnt:SetPos(renderPos)
                            dat.csEnt:SetAngles(renderAng)
                            if dat.csEnt.m_bShouldDraw ~= false then
                                dat.csEnt:DrawModel()
                            end
                            draw.NoTexture()
                            render.SetColorModulation(1, 1, 1)
            
                            if Developer:GetSetting("modeledit_wireframe") then
                                local mins, maxs = dat.csEnt:GetRenderBounds()
                                render.DrawWireframeBox(renderPos, renderAng, mins, maxs, color_white)
                            end
                        end
                    end
                    self:DrawModelGrid()
                cam.End3D()

                local img = render.Capture({
                    x = 0, y = 0, 
                    w = w, h = h,
                    format = "png",
                    quality = 100,
                    alpha = true
                })
                file.Write("dev_export.png", img)

                return true
            end)
        end
    })

    self.PropertyTypes = {}

    self:AddPropertyType("Transform", "Position", "Vector", function(this, ent)
        local pos = ent.vecPos
        local txt = string.format("%.2f, %.2f, %.2f", pos.x, pos.y, pos.z)
        this.Input:SetText(txt)
    end, function(_, vec)
        self.selected.vecPos = vec
    end)

    self:AddPropertyType("Transform", "Angle", "Angle", function(this, ent)
        local ang = ent.angAngles
        local txt = string.format("%.2f, %.2f, %.2f", ang.x, ang.y, ang.z)
        this.Input:SetText(txt)
    end, function(this, ang)
        self.selected.angAngles = ang
    end)

    self:AddPropertyType("Transform", "Scale", "Float", function(this, ent)
        local scale = ent:GetModelScale()
        this.Input:SetText(scale)
    end, function(this, scale)
        self.selected:SetModelScale(scale, 0)
    end)

    self:AddPropertyType("Parent", "Object", "Object", function(this, ent)
        this.Input:SetSelected(ent.parentObject)
    end, function(this, selected)
        self.selected.parentObject = selected
        self.selected.parentBone = nil
        self:SetupProps(self.selected)
    end)

    self:AddPropertyType("Parent", "Bone", "ComboBox", function(this, ent)
        this.Input:SetSelected(ent.parentBone)
        return function()
            local parent = ent.parentObject
            if not parent or not IsValid(parent.csEnt) then
                return
            end
            parent = parent.csEnt

            local bones = {}
            local x = 0
            for i = 0, parent:GetBoneCount() do
                x = x + 1
                local name = string.format("[%d] %s", i, parent:GetBoneName(i))
                bones[x] = {
                    name = name,
                    data = {
                        name = name,
                        boneid = i
                    }
                }
                ::skip::    
            end

            table.sort(bones, function(a, b)
                return a.name > b.name
            end)

            table.insert(bones, 1, {name = "None", boneid = -1})
            return bones
        end
    end, function(this, bone)
        self.selected.parentBone = bone
        self:SetupProps(self.selected)
    end)

    self:AddPropertyType("Animations", "Sequence", "ComboBox", function(this, ent)
        this.Input:SetSelected(ent.animSequence)
        return function()
            local sequences = {}
            local x = 0
            for i = 0, ent:GetSequenceCount() do
                local seqInfo = ent:GetSequenceInfo(i)
                if not seqInfo then
                    goto skip
                end
                x = x + 1
                seqInfo.index = i
                sequences[x] = {
                    name = seqInfo.label,
                    data = seqInfo
                }

                ::skip::
            end

            table.sort(sequences, function(a, b)
                return string.lower(a.name) < string.lower(b.name)
            end)

            table.insert(sequences, 1, {name = "None"})

            return sequences
        end
    end, function(this, sequence)
        self.selected.animSequence = sequence
        self.selected.seqStart = nil
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
        self:DeleteModel(self.selected)
    end

    if key == KEY_A then
        local menu = Developer.CreateMenu()
        menu:AddOption("Create Model", {
            Shortcut = {KEY_LSHIFT, KEY_A},
        })  
    end
end

function PANEL:AddModel(mdl)
    local dat = {
        model = mdl,
        name = mdl,
        csEnt = ClientsideModel(mdl)
    }
    dat.name = dat.model:match("([^/]+)%.mdl$") or dat.name

    dat.csEnt:SetupBones()
    dat.csEnt:SetNoDraw(true)
    dat.csEnt:SetIK(false)
    dat.csEnt:SetPos(Vector())
    -- dat.csEnt:SetMoveType(MOVETYPE_NONE)
    -- dat.csEnt:SetSolid(SOLID_VPHYSICS)
    -- dat.csEnt:PhysicsInit(SOLID_VPHYSICS)
    -- dat.csEnt:PhysWake()
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
        local x, y = input.GetCursorPos()
        local w, h = pnl:GetSize()
        local menu = DermaMenu()
        menu:SetPos(x, y + 1)
        menu:MakePopup()
        menu:AddOption("Rename", function()
            Derma_StringRequest("Rename Item", "Enter the new name", dat.name, function(txt)
                dat.name = txt
            end, function() end, "Confirm", "Abort")
        end)
        menu:AddSpacer()
        menu:AddOption("Delete", function()
            Derma_Query("You sure?", "Delete", "Yes", function()
                self:DeleteModel(dat.csEnt)
            end, "No")
        end)
    end
    return dat
end

function PANEL:DeleteModel(mdl)
    if IsValid(mdl) then
        for i = 1, #self.Models do
            local d = self.Models[i]
            if d.csEnt == mdl then
                d.panel:Remove()
                d.csEnt:Remove()
                table.remove(self.Models, i)
                mdl = nil
                break
            end
        end
    end
end

function PANEL:InitSizes(w, h)
    if self.m_bInitializedLayout then return end
    self.m_bInitializedLayout = true
    self.Elements:SetWide(w*0.12)
    self.Properties:SetWide(w*0.125)
    self.AnimTimeline:SetTall(52)
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
        draw.SimpleText(sName, "Developer.MenuBar", w/2, h/2, col, 1, 1)
    end
    btn.DoClick = function(pnl)
        local x,y = pnl:LocalToScreen()
        local w, h = pnl:GetSize()
        -- local menu = DermaMenu()
        local menu = Developer.CreateMenu()
        -- menu:MakePopup()
        menu:SetPos(x, y + h)
        local options = self.MenuOptions[sName]
        for k, v in pairs(options or {}) do
            local setting = Developer.Settings[v.optionId]
            if not v.PopulateSubMenu then
                local op = menu:AddOption(v.Name, {
                    DoClick = function(pnl)
                        if v.DoClick then
                            v.DoClick(pnl)
                        end
                        if not setting then return end
                        if setting.type == "toggle" then
                            pnl:ToggleCheck()
                        end
                    end,
                    Shortcut = v.Shortcut
                })
                op.OnChecked = function(pnl, state)
                    setting.value = state
                end
                if setting then
                    op:SetChecked(setting.value)
                end
            else
                local op = menu:AddSubMenu(v.Name, {

                })
                v.PopulateSubMenu(op)
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
    local dist = math.max(self:GetCamDistance() - delta*5, 2)
    self:SetCamDistance(dist)
end

local color_x = Color(255, 0, 0, 20)
local color_y = Color(0, 255, 0, 20)
local color_m = Color(90, 90, 90, 40) -- misc
local color_transparent_white = Color(255, 255, 255, 20)
function PANEL:DrawModelGrid()
    render.SetColorMaterial()
    if Developer:GetSetting("modeledit_drawgrid") then
        for x = -5000, 5000, 100 do
            render.DrawBeam(Vector(x, -5000), Vector(x, 5000), 0.1, 1, 1, color_m)
        end
        for y = -5000, 5000, 100 do
            render.DrawBeam(Vector(-5000, y), Vector(5000, y), 0.1, 1, 1, color_m)
        end
        render.DrawBeam(Vector(-5000, 0), Vector(5000, 0), 0.3, 1, 1, color_x)
        render.DrawBeam(Vector(0, -5000), Vector(0, 5000), 0.3, 1, 1, color_y)
    end

    if Developer:GetSetting("modeledit_drawfocuspoint") then
        render.DrawWireframeSphere(self:GetLookAt(), 0.33, 7, 6, color_transparent_white)
    end
end

function GetRenderPos(ent)
    local entPos = ent.vecPos or Vector()
    local entAng = ent.angAngles or Angle()
    local renderPos = entPos
    local renderAng = entAng
    if ent.parentObject and IsValid(ent.parentObject.csEnt) then
        local parent, ang = ent.parentObject.csEnt
        -- print("parent: ", parent, parent.parentBone, parent.parentBone.boneid)
        if ent.parentBone and ent.parentBone.boneid then
            renderPos, ang = parent:GetBonePosition(ent.parentBone.boneid)
        else
            renderPos, ang = GetRenderPos(parent)
        end
        renderPos = renderPos + ang:Forward()*entPos.x
        renderPos = renderPos + ang:Right()*entPos.y
        renderPos = renderPos + ang:Up()*entPos.z

        renderAng = Angle(ang.x, ang.y, ang.z)
        renderAng:RotateAroundAxis(renderAng:Forward(), entAng.x)
        renderAng:RotateAroundAxis(renderAng:Right(), entAng.y)
        renderAng:RotateAroundAxis(renderAng:Up(), entAng.z)
    end
    return renderPos, renderAng
end

local prePadding = 2
local postPadding = 2
function PANEL:GetAnimDuration()
    local max = 0
    for i = 1, #self.Models do
        local dat = self.Models[i]
        local ent = dat.csEnt
        if IsValid(ent) then
            if ent.animSequence then
                local seqId = ent:LookupSequence(ent.animSequence.label)
                local dur = ent:SequenceDuration(seqId)
                if dur > max then
                    max = dur
                end
            end
        end
    end
    return max + prePadding + postPadding
end

function PANEL:UpdateSequences(time)
    print("Updating to ", time)
    for i = 1, #self.Models do
        local dat = self.Models[i]
        local ent = dat.csEnt
        if IsValid(ent) then
            if ent.animSequence then
                local seqId = ent:LookupSequence(ent.animSequence.label)
                -- ent:ResetSequence(seqId)
                local start = ent:GetAnimTime()
                local diff = CurTime()-start 
                ent:SetCycle(time)

                if not self.AnimTimeline.Caret.m_bDragging then
                    ent:FrameAdvance( FrameTime() )
                end
            end
        end
    end


end

function PANEL:OnTimelineChange(ratio)
    local totalDuration = self:GetAnimDuration()
    self:UpdateSequences(ratio)
end

local function Draw3DCircle(origin, radius, angle, degStart, degFin)
    local offset = angle:Forward()


    local top = origin + (angle:Up()*radius)
    local bot = origin - (angle:Up()*radius)
    render.DrawBeam(origin, top, 1, 1, 1, color_white)
    render.DrawBeam(origin, bot, 1, 1, 1, color_white)

    local prevPoint
    for i = 0, degStart, degFin do
        local point = origin + angle:Right()*(math.cos(math.rad(i))*radius)
        local point = origin + angle:Forward()*(math.sin(math.rad(i))*radius)
        local point = origin + angle:Up()*i
        if prevPoint then
            render.DrawBeam(prevPoint, point, 1, 1, 1, color_white)
        end
        prevPoint = point
    end
end

local function DrawRotationAxis(self, ent)
    local radius = (self:GetCamDistance()/math.min(self:GetTall(), self:GetWide()))*320

    local pos = ent:GetPos()
    local right = pos + ent:GetRight()*radius
    -- render.DrawBeam(pos, right, 1, 1, 1, color_white)
    Draw3DCircle(pos, radius, ent:GetAngles(), -90, 90)
end

function PANEL:RenderModels(w, h, pnl)
    local camPos = self:GetCamPos()
    local camAng = self:GetCamAng()

    local x, y = pnl:LocalToScreen()
    -- if self.animTime then
    --     self:UpdateSequences(self.animTime)
    -- end
    cam.Start3D(camPos, camAng, 75, x, y, w, h)
        for i = 1, #self.Models do
            local dat = self.Models[i]
            if dat and IsValid(dat.csEnt) then
                if self.selected == dat.csEnt then
                    render.SetColorMaterial()
                    render.SetColorModulation(1, 0 ,0)
                    DrawRotationAxis(self, dat.csEnt)
                end
                local ent = dat.csEnt
                local renderPos, renderAng = GetRenderPos(dat.csEnt)
                
                if dat.csEnt.animSequence then
                    local expectedSequence = dat.csEnt:LookupSequence(dat.csEnt.animSequence.label)
                    if not dat.csEnt.seqStart then --dat.csEnt:GetSequence() ~= expectedSequence or dat.csEnt:IsSequenceFinished() or dat.csEnt:SequenceDuration(expectedSequence) > CurTime() - (dat.csEnt.seqStart or 0) then
                        dat.csEnt:ResetSequence(expectedSequence)
                        dat.csEnt.seqStart = CurTime()
                    end
                end

                if Developer:GetSetting("modeledit_wireframemodels") then
                    render.SetMaterial(MATERIAL_WIREFRAME)
                    dat.csEnt:SetMaterial("models/wireframe")
                else
                    dat.csEnt:SetMaterial("")
                end

                dat.csEnt:SetPos(renderPos)
                dat.csEnt:SetAngles(renderAng)
                if dat.csEnt.m_bShouldDraw ~= false then
                    dat.csEnt:DrawModel()
                    if Developer:GetSetting("modeledit_wireframe") then
                        local mins, maxs = dat.csEnt:GetRenderBounds()
                        render.DrawWireframeBox(renderPos, renderAng, mins, maxs, color_white)
                    end
                end
                draw.NoTexture()
                render.SetColorModulation(1, 1, 1)

            end
        end
        if self.lastTrace then
            render.DrawBeam(self.lastTrace[1], self.lastTrace[1] + self.lastTrace[2] * self.lastTrace[3], 1, 1, 1, color_x)

            -- local start = self.lastTrace[1]
            -- local dir = self.lastTrace[2]
            -- local distance = self.lastTrace[3]
                
            -- local pos = start
            -- local inc = distance/100
            -- for i = 1, distance, inc do
            --     pos = pos + (dir*inc)
            --     render.DrawWireframeSphere(pos, 0.1, 10, 10, color_white)
            -- end
        end
        self:DrawModelGrid()
    cam.End3D()

end 

local function CheckCollision(self, pos, models)
    models = models or self.Models
    for i = 1, #models do
        local dat = models[i]
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
    local hits = {}


    local models = table.Copy(self.Models)
    table.sort(models, function(a, b)
        local entA = a.csEnt
        local entB = b.csEnt

        local mins, maxs = entA:GetRenderBounds()
        local sizeA = math.max(mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z)
         
        mins, maxs = entB:GetRenderBounds()
        local sizeB = math.max(mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z)
        return sizeA < sizeB
    end)

    PrintTable(models)

    local pos = start
    local inc = distance/333
    for i = 1, distance, inc do
        pos = pos + (dir*inc)
        local hit = CheckCollision(self, pos, models)
        if hit then
            table.insert(hits, hit)
        end
    end

    local smallestObj
    local smallestSize
    for i = 1, #hits do
        local ent = hits[i]
        local mins, maxs = ent:GetRenderBounds()
        local size = math.max(mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z)
        -- print("Size of ", ent:GetModel(), size)
        if not smallestSize or size < smallestSize then
            smallestSize = size
            smallestObj = ent
        end
    end
    return smallestObj
end

vgui.Register("Developer.ModelEditor", PANEL, "EditablePanel")

local height = ScrH()*0.85
local width = height*1.66

local panel = vgui.Create("Developer.ModelEditor")
panel:SetSize(width, height)
panel:Center()
panel:MakePopup()
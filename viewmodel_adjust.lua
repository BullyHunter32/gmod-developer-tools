--[[
    --[[
    if (ironSightsPos) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), ironSightsAng.x * multiplier)
		ang:RotateAroundAxis(ang:Up(), ironSightsAng.y * multiplier)
		ang:RotateAroundAxis(ang:Forward(), ironSightsAng.z * multiplier)
	end

	pos = pos + ironSightsPos.x * ang:Right() * multiplier
	pos = pos + ironSightsPos.y * ang:Forward() * multiplier
	pos = pos + ironSightsPos.z * ang:Up() * multiplier
]]

-- do
--     local SWEP = {}
--     SWEP.PrintName = "ViewModel Adjuster"
--     SWEP.Spawnable = true
--     SWEP.Author = "BullyHunter"
--     SWEP.Category = "Dev Tools"
--     SWEP.SwayScale = 0
--     SWEP.BobScale = 0
--     SWEP.IronSightsAng = Angle(0, 0, 0)
--     SWEP.IronSightsPos = Vector(2, 2, 2)
--     SWEP.EditorFOV = 75

--     AccessorFunc(SWEP, "m_bADS", "ADS", FORCE_BOOL)

--     function SWEP:Initialize()
--         self:SetADS(false)
--     end

--     function SWEP:PrimaryAttack()
--     end

--     function SWEP:SecondaryAttack()
--     end

--     function SWEP:Reload()
--         if SERVER then return end 
--         if IsValid(self.Menu) then return end
--         local pnl = vgui.Create("Developer.ViewModelAdjust")
--         self.Menu = pnl
--         pnl:SetSize(600, 400)
--         pnl:SetPos(40, ScrH()/2 - 200)
--         pnl:MakePopup()
--     end

--     function SWEP:Think()
--         if SERVER then return end
--         if IsValid(self.Menu) then
--             self:SetADS(true)
--         else
--             self:SetADS(self:GetOwner():KeyDown(IN_ATTACK2))
--         end
--     end

--     function SWEP:GetViewModelPosition(pos, ang)
--         if not self:GetADS() then return end

--         local ironSightsAng = self.IronSightsAng
--         local ironSightsPos = self.IronSightsPos

--         ang = ang * 1
--         ang:RotateAroundAxis(ang:Right(), ironSightsAng.x)
--         ang:RotateAroundAxis(ang:Up(), ironSightsAng.y)
--         ang:RotateAroundAxis(ang:Forward(), ironSightsAng.z)
            
--         pos = pos + ironSightsPos.x * ang:Right()
--         pos = pos + ironSightsPos.y * ang:Forward()
--         pos = pos + ironSightsPos.z * ang:Up()

--         return pos, ang
--     end
    
--     weapons.Register(SWEP, "developer_vm_adjust")
-- end

if SERVER then return end

include("developer.lua")


local PANEL = {}

function PANEL:Init()
    
    self.Menu = self:Add("DPanel")
    self.Menu:Dock(TOP)
    self.Menu:SetTall(25)
    self.Menu.Paint = function(pnl, w, h)
        surface.SetDrawColor(31, 36, 42)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(0, h-1, w, h-1)
    end

    self.Menu.Close = self.Menu:Add("DButton")
    self.Menu.Close:Dock(RIGHT)
    self.Menu.Close:SetWide(25)
    self.Menu.Close.DoClick = function()
        self:Remove()
    end

    self.Properties = self:Add("Developer.SizeablePanel")
    self.Properties:Dock(LEFT)
    self.Properties:SetSizeable(false, false, true, false)
    self.Properties:SetWide(160)
    self.Properties.Paint = function(pnl, w, h)
        surface.SetDrawColor(37, 42, 49)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawLine(w-1, 0, w-1, h)
    end

    self.PropertyTypes = {}

    self:AddPropertyType("Screen", "Draw Reticle", "Boolean", function(this, ent)
        this.Input:SetState(Developer:GetSetting("viewmodel_adjust_reticle"))
    end, function(this, state)
        Developer:SetSetting("viewmodel_adjust_reticle", state)
    end)

    self:AddPropertyType("Iron Sights", "Pos", "Vector", function(this, ent)
        local pos = ent.IronSightsPos
        local txt = string.format("%.2f, %.2f, %.2f", pos.x, pos.y, pos.z)
        this.Input:SetText(txt)
    end, function(this, vec)
        self:SetWeaponProp("IronSightsPos", vec)
    end)

    self:AddPropertyType("Iron Sights", "Angle", "Angle", function(this, ent)
        local ang = ent.IronSightsAng
        local txt = string.format("%.2f, %.2f, %.2f", ang.x, ang.y, ang.z)
        this.Input:SetText(txt)
    end, function(this, ang)
        self:SetWeaponProp("IronSightsAng", ang)
    end)

    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) then
        self:SetupProps(wep)
    end
end

function PANEL:SetWeaponProp(key, value)
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) then
        wep[key] = value
    end
end

function PANEL:SetupProps(ent)
    if not IsValid(ent) then return end
    for k,v in pairs(self.PropertyTypes) do
        v:Setup(ent)
    end
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
    local prop = self.PropertyTypes[sCategory]:AddProperty(sName, sType, fnSetup, fnCallback, self)
    prop.NamePanel:SetWide(500)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(35, 38, 44)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:GetWeapon()
    return LocalPlayer():GetActiveWeapon()
end

function PANEL:OnKeyCodePressed(code)
    if code == KEY_G then
        self:MouseCapture(true)
        self.m_bDraggingVM = true
        self.m_bRotatingVM = false

        self.m_vecStartPos = self:GetWeapon().IronSightsPos
        self.m_vecIronSightOffset = self:GetWeapon().IronSightsPos
        input.SetCursorPos(ScrW()/2, ScrH()/2)
    elseif code == KEY_R then
        self:MouseCapture(true)
        self.m_bRotatingVM = true
        self.m_bDraggingVM = false

        self.m_vecStartAng = Vector(self:GetWeapon().IronSightsAng.x, self:GetWeapon().IronSightsAng.y, self:GetWeapon().IronSightsAng.z)
        self.m_vecIronSightOffset = self:GetWeapon().IronSightsAng
    end

    if self.m_bRotatingVM then
        if code == KEY_X then
            self.m_iRotateAxis = 1
        elseif code == KEY_Y then
            self.m_iRotateAxis = 2 
        elseif code == KEY_Z then
            self.m_iRotateAxis = 3
        end
    end
end

function PANEL:OnMousePressed(key)
    if self.m_bDraggingVM then
        if key == MOUSE_LEFT then
            self:MouseCapture(false)
            self.m_bDraggingVM = false
        elseif key == MOUSE_RIGHT then
            self:MouseCapture(false)
            self.m_bDraggingVM = false
            self:GetWeapon().IronSightsPos = self.m_vecStartPos
        end
    elseif self.m_bRotatingVM then
        if key == MOUSE_LEFT then
            self:MouseCapture(false)
            self.m_bRotatingVM = false
        elseif key == MOUSE_RIGHT then
            self:MouseCapture(false)
            self.m_bRotatingVM = false
            self:GetWeapon().IronSightsAng = self.m_vecStartAng
        end
    end
end

function PANEL:Think()
    local wep = self:GetWeapon()
    if wep.GetIronSights then
        if wep:GetIronSights() == 0 then
            wep:SetIronSights(CurTime())
        end
    end

    if self.m_bRotatingVM then
        local axis = self.m_iRotateAxis
        if axis then
            local cx, cy = input.GetCursorPos()
            local diffX = cx - ScrW()/2
            local diffY = cy - ScrH()/2
            input.SetCursorPos(ScrW()/2, ScrH()/2)
    
            local mult = wep.EditorFOV*0.0002
            diffX = diffX*mult
            diffY = diffY*mult
            
            if axis == 1 then
                self.m_vecIronSightOffset:RotateAroundAxis(self.m_vecIronSightOffset:Right(), diffY)
            elseif axis == 2 then
                self.m_vecIronSightOffset:RotateAroundAxis(self.m_vecIronSightOffset:Up(), diffX)
            elseif axis == 3 then
                self.m_vecIronSightOffset:RotateAroundAxis(self.m_vecIronSightOffset:Forward(), diffX)
            end
            -- self.m_vecIronSightOffset.z = self.m_vecIronSightOffset.z - diffY
            wep.IronSightsAng = self.m_vecIronSightOffset
        end
    elseif self.m_bDraggingVM then

        local cx, cy = input.GetCursorPos()
        local diffX = cx - ScrW()/2
        local diffY = cy - ScrH()/2
        input.SetCursorPos(ScrW()/2, ScrH()/2)

        local mult = wep.EditorFOV*0.00001
        diffX = diffX*mult
        diffY = diffY*mult
        
        self.m_vecIronSightOffset.x = self.m_vecIronSightOffset.x + diffX
        self.m_vecIronSightOffset.z = self.m_vecIronSightOffset.z - diffY
        wep.IronSightsPos = self.m_vecIronSightOffset
    end

    self:SetupProps(wep)
end

function PANEL:OnMouseWheeled(delta)
    local wep = self:GetWeapon()
    -- print("keyDown: ", input.IsKeyDown(KEY_LSHIFT))
    -- if --[[self.m_bDraggingVM and]] input.IsKeyDown(KEY_LSHIFT) then
    --     local mult = 4
    --     local diff = delta*mult
    --     print("adjusting by ", diff)
    --     self.m_vecIronSightOffset.y = self.m_vecIronSightOffset.y + diff
    -- else
        wep.EditorFOV = wep.EditorFOV - (delta*0.5)
    -- end
end

vgui.Register("Developer.ViewModelAdjust", PANEL, "EditablePanel")

hook.Add("HUDPaint", "Developer.ViewModelAdjust", function()
    local wep = LocalPlayer():GetActiveWeapon() 
    if not IsValid(wep) then return end

    if not wep.EDITOR_HOOK then
        local _, tH = draw.SimpleText("Press 'Insert' to hook this weapon", "DermaLarge", 25, 25, color_white)
        draw.SimpleText("After hooked, press 'Reload' to open menu.", "DermaLarge", 25, 25 + tH, color_white)
    end

    local menu = wep.Menu
    if not IsValid(menu) then return end

    local txt = "NONE"
    if menu.m_bDraggingVM then
        txt = "DRAGGING"
    elseif menu.m_bRotatingVM then
        txt = "ROTATING"
    end

    draw.SimpleText(txt, "DermaLarge", ScrW()*0.5, ScrH()*0.05, color_white, 1, 1)

    if Developer:GetSetting("viewmodel_adjust_reticle") then
        surface.SetDrawColor(255, 0, 0)
        surface.DrawLine(0, ScrH()*0.5, ScrW(), ScrH()*0.5)
        surface.DrawLine(ScrW()*0.5, 0, ScrW()*0.5, ScrH())
    end
end)

hook.Add("CalcView", "Developer.ViewModelAdjust", function(ply)
    local wep = ply:GetActiveWeapon()
    if not wep:IsValid() or not IsValid(wep.Menu) then
        return
    end

    return {
        fov = wep.EditorFOV
    }
end)

hook.Add("PlayerButtonDown", "Developer.ViewModelAdjust", function(ply, key)
    if key == KEY_INSERT then
        local SWEP = ply:GetActiveWeapon()
        if not IsValid(SWEP) or SWEP.EDITOR_HOOK then return end
        SWEP.EditorFOV = SWEP.ViewModelFOV or 75
        SWEP.EDITOR_HOOK = true
        SWEP.Reload = function(self)
            if SERVER then return end 
            if IsValid(self.Menu) then return end
            local pnl = vgui.Create("Developer.ViewModelAdjust")
            self.Menu = pnl
            pnl:SetSize(600, 400)
            pnl:SetPos(40, ScrH()/2 - 200)
            pnl:MakePopup()
        end
    end
end)

hook.Add("CreateMove", "Developer.ViewModelAdjustment", function(cmd)
    local btns = cmd:GetButtons()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or not wep.EDITOR_HOOK then return end
    if not IsValid(wep.Menu) then return end

    if bit.band(btns, IN_ATTACK2) == 0 then
        -- btns = bit.band(btns, bit.bnot(IN_ATTACK2))
        -- cmd:SetButtons(btns)
        cmd:AddKey(IN_ATTACK2)
    end
end)
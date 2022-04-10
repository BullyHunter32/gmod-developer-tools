local body = ClientsideModel("models/weapons/w_deagle.mdl")
body.posOffset = Vector(0, 0, 0)
body.angOffset = Angle(0, 0, 0)
function body:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local riflerail = ClientsideModel("models/jarheads/weapons/attachments/rifle_rail_2.mdl")
riflerail.Parent = body
riflerail.posOffset = Vector(0, 1.2617242336273, 6.2280855178833)
riflerail.angOffset = Angle(0, 0, 0)
function riflerail:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local scoperail = ClientsideModel("models/jarheads/weapons/attachments/scope_rail_2.mdl")
scoperail.Parent = riflerail
scoperail.posOffset = Vector(0, 0.65770727396011, -0.14764857292175)
scoperail.angOffset = Angle(0, 0, 0)
function scoperail:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local scope = ClientsideModel("models/jarheads/weapons/attachments/scope_pm2.mdl")
scope.Parent = scoperail
scope.posOffset = Vector(0, 0.26328992843628, 0.5271680355072)
scope.angOffset = Angle(0, 0, 0)
function scope:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local stock = ClientsideModel("models/jarheads/weapons/components/870_stock.mdl")
stock.Parent = body
stock.posOffset = Vector(0, -9.7307119369507, 2.523815870285)
stock.angOffset = Angle(0, 0, 0)
function stock:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local barrel = ClientsideModel("models/jarheads/weapons/components/mp510_barrel.mdl")
barrel.Parent = body
barrel.posOffset = Vector(0, 10.596905708313, 4.8447232246399)
barrel.angOffset = Angle(0, 0, 0)
function barrel:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local suppressor = ClientsideModel("models/jarheads/weapons/attachments/suppressor_76251.mdl")
suppressor.Parent = barrel
suppressor.posOffset = Vector(0, 8.7231931686401, -0.37355053424835)
suppressor.angOffset = Angle(0, 0, 0)
function suppressor:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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

local magazine = ClientsideModel("models/jarheads/weapons/magazines/85870_5.mdl")
magazine.Parent = body
magazine.posOffset = Vector(0, 2.3818862438202, 1.9979751110077)
magazine.angOffset = Angle(0, 0, 0)
function magazine:UpdatePos()
    local parent = self.Parent
    local pos, ang = self:GetPos(), self:GetAngles()
    if parent then
        pos = parent:GetPos()
        ang = parent:GetAngles()

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



hook.Add("PostDrawOpaqueRenderables", "", function()
    body:SetPos(LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector()*30)
    body:SetAngles(Angle(0, CurTime()*32, 0))
    riflerail:UpdatePos()
    scoperail:UpdatePos()
    scope:UpdatePos()
    stock:UpdatePos()
    barrel:UpdatePos()
    suppressor:UpdatePos()
    magazine:UpdatePos()
end)

concommand.Add("purge", function()
    for k,v in ipairs(ents.FindByClass("class C_BaseFlex")) do
        v:Remove()
    end
    hook.Remove("PostDrawOpaqueRenderables", "")
end)
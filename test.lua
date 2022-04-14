
local barney = ClientsideModel("models/player/barney.mdl")
barney.Parent = nil -- Not required
barney.BoneId = nil
barney.posOffset = Vector(0, 0, 0)
barney.angOffset = Angle(0, 0, 0)
function barney:UpdatePos()
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

local ak101 = ClientsideModel("models/weapons/w_ak101.mdl")
ak101.Parent = barney -- models/player/barney.mdl
ak101.BoneId = 11
ak101.posOffset = Vector(13.131999969482, 1.0880000591278, 1.8559999465942)
ak101.angOffset = Angle(0, 180, 270)
function ak101:UpdatePos()
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

local rifle_rail = ClientsideModel("models/jarheads/weapons/attachments/rifle_rail_2.mdl")
rifle_rail.Parent = ak101 -- models/weapons/w_ak101.mdl
rifle_rail.BoneId = 4
rifle_rail.posOffset = Vector(0.08500000089407, -2.7049999237061, 8.0970001220703)
rifle_rail.angOffset = Angle(0, 0, 0)
function rifle_rail:UpdatePos()
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

local stock = ClientsideModel("models/jarheads/weapons/components/870_stock.mdl")
stock.Parent = ak101 -- models/weapons/w_ak101.mdl
stock.BoneId = nil
stock.posOffset = Vector(0.083999998867512, -15.442799568176, 4.0739998817444)
stock.angOffset = Angle(0, 0, 0)
function stock:UpdatePos()
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

local suppressor = ClientsideModel("models/jarheads/weapons/attachments/suppressor_76251.mdl")
suppressor.Parent = ak101 -- models/weapons/w_ak101.mdl
suppressor.BoneId = 1
suppressor.posOffset = Vector(0.088799998164177, 21.305299758911, 5.102499961853)
suppressor.angOffset = Angle(0, 0, 0)
function suppressor:UpdatePos()
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

local magazine = ClientsideModel("models/jarheads/weapons/magazines/85870_5.mdl")
magazine.Parent = ak101 -- models/weapons/w_ak101.mdl
magazine.BoneId = nil
magazine.posOffset = Vector(0, -3.1726999282837, 4.7139000892639)
magazine.angOffset = Angle(0, 0, 0)
function magazine:UpdatePos()
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

local scope_rail = ClientsideModel("models/jarheads/weapons/attachments/scope_rail_2.mdl")
scope_rail.Parent = rifle_rail -- models/jarheads/weapons/attachments/rifle_rail_2.mdl
scope_rail.BoneId = nil
scope_rail.posOffset = Vector(0, -0.22360000014305, -0.3643000125885)
scope_rail.angOffset = Angle(0, 0, 0)
function scope_rail:UpdatePos()
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

local scope_atar = ClientsideModel("models/jarheads/weapons/attachments/scope_atacr.mdl")
scope_atar.Parent = scope_rail -- models/jarheads/weapons/attachments/scope_rail_2.mdl
scope_atar.BoneId = nil
scope_atar.posOffset = Vector(0, 0.46880000829697, 0.74479997158051)
scope_atar.angOffset = Angle(0, 0, 0)
function scope_atar:UpdatePos()
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




-- hook.Add("PostDrawOpaqueRenderables", "", function()
--     if not IsValid(barney) then return end

    local pos = Entity(1):GetEyeTrace().HitPos --(Entity(1):GetShootPos() + Entity(1):GetAimVector()*100) + barney:OBBCenter()
    barney:SetPos(pos)
    ak101:UpdatePos()
    rifle_rail:UpdatePos()
    scope_rail:UpdatePos()
    scope_atar:UpdatePos()
    magazine:UpdatePos()
    suppressor:UpdatePos()
    stock:UpdatePos()
-- end)

concommand.Add("purge", function()
    for k, v in ipairs(ents.FindByClass("class C_BaseFlex")) do
        v:Remove()
    end
end)
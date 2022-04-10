local w_ak101 = ClientsideModel("models/weapons/w_ak101.mdl")
-- w_ak101.Parent = ... (Not required)
w_ak101.posOffset = Vector(0, 0, 0)
w_ak101.angOffset = Angle(0, 0, 0)
function w_ak101:UpdatePos()
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

local rifle_eotech = ClientsideModel("models/jarheads/weapons/attachments/rifle_eotech.mdl")
-- rifle_eotech.Parent = ... (models/jarheads/weapons/attachments/rifle_rail_2.mdl)
rifle_eotech.posOffset = Vector(0, -0.55000001192093, -0.20000000298023)
rifle_eotech.angOffset = Angle(0, 0, 0)
function rifle_eotech:UpdatePos()
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

local rifle_rail_2 = ClientsideModel("models/jarheads/weapons/attachments/rifle_rail_2.mdl")
-- rifle_rail_2.Parent = ... (models/weapons/w_ak101.mdl)
rifle_rail_2.posOffset = Vector(0, -2.356409072876, 8.0875682830811)
rifle_rail_2.angOffset = Angle(0, 0, 0)
function rifle_rail_2:UpdatePos()
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

local stock_scarl = ClientsideModel("models/jarheads/weapons/attachments/stock_scarl.mdl")
-- stock_scarl.Parent = ... (models/weapons/w_ak101.mdl)
stock_scarl.posOffset = Vector(0.13976898789406, -13.210072517395, 2.0694127082825)
stock_scarl.angOffset = Angle(0, 0, 0)
function stock_scarl:UpdatePos()
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

local 76251_20_2 = ClientsideModel("models/jarheads/weapons/magazines/76251_20_2.mdl")
-- 76251_20_2.Parent = ... (models/weapons/w_ak101.mdl)
76251_20_2.posOffset = Vector(0, -2.1158220767975, 2.4837911128998)
76251_20_2.angOffset = Angle(0, 0, 0)
function 76251_20_2:UpdatePos()
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

local suppressor_12733 = ClientsideModel("models/jarheads/weapons/attachments/suppressor_12733.mdl")
-- suppressor_12733.Parent = ... (models/weapons/w_ak101.mdl)
suppressor_12733.posOffset = Vector(0, 21.055541992188, 5.191162109375)
suppressor_12733.angOffset = Angle(0, 0, 0)
function suppressor_12733:UpdatePos()
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

local mp5k_vertgrip = ClientsideModel("models/jarheads/weapons/components/mp5k_vertgrip.mdl")
-- mp5k_vertgrip.Parent = ... (models/weapons/w_ak101.mdl)
mp5k_vertgrip.posOffset = Vector(0.075712241232395, 4.8579931259155, 1.6198259592056)
mp5k_vertgrip.angOffset = Angle(0, 0, 0)
function mp5k_vertgrip:UpdatePos()
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


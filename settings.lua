Developer.Settings = Developer.Settings or {}
function Developer:GetSetting(sId)
    local t = self.Settings[sId]
    return t and t.value or false
end

function Developer:SetSetting(sId, value)
    local t = self.Settings[sId]
    if t then
        t.value = value
    end
end

local function Add(sId, tData)
    if Developer.Settings[sId] then
        tData.default = tData.default or false
        return
    end
    tData.value = tData.default
    Developer.Settings[sId] = tData
end

Add("modeledit_wireframe", {
    default = false,
    type = "toggle"
})

Add("modeledit_drawgrid", {
    default = true,
    type = "toggle"
})

Add("modeledit_drawfocuspoint", {
    default = true,
    type = "toggle"
})

Add("modeledit_wireframemodels", {
    default = true,
    type = "toggle"
})

Add("viewmodel_adjust_reticle", {
    default = false,
    type = "toggle"
})
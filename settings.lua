Developer.Settings = Developer.Settings or {}
function Developer:GetSetting(sId)
    local t = self.Settings[sId]
    return t and t.value or false
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
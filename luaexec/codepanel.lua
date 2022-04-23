local PANEL = {}

function PANEL:Init()
    self.LineId = 0
    self.Text = ""
end

local KEY_WORDS = {
    "and",
    "local",
    "self",
    "function",
    "return",
    "end",
    "if",
    "then",
    "while",
    "do",
    "until",
    "repeat",
    "for",
    "in",
}

local DATA_TYPES = {
    [0] = {
        function(i)
            return tonumber(i) ~= nil
        end,
    },
    "true",
    "false",
}

Developer:TableToList(KEY_WORDS)
Developer:TableToList(DATA_TYPES)

function PANEL:IsDataType(str)
    if DATA_TYPES[str] then
        return true
    end

    for i = 1, #DATA_TYPES[0] do
        if DATA_TYPES[0][i](str) then
            print(str, " is a number")
            return true
        end
    end
    return false
end

function PANEL:IsFunction(word)
    local func = word:match("%((.-)%)$")
    return func ~= nil
end

function PANEL:TextToTable()
    local tbl = {}
    local cur = ""
    for i = 1, #self.Text do
        if self.Text[i] == " " and #cur > 0 then
            table.insert(tbl, cur)
            cur = ""
        else
            cur = cur .. self.Text[i]
        end
    end
    if #cur > 0 then
        table.insert(tbl, cur)
        cur = ""
    end

    return tbl
end

function PANEL:Paint(w, h)
    if self.LineId == self.Master.CurLine then
        surface.SetDrawColor(66, 66, 66, 120)
        surface.DrawRect(0, 0, w, h)
    end
    draw.SimpleText(self.LineId, "ChatFont", 0, 0, color_black, 0, 0)
    surface.SetFont("ChatFont")

    local words = self:TextToTable()
    local offset = h/2 -- margin
    local _, yPos = surface.GetTextSize("Cookies")
    yPos = h/2 - yPos/2

    local spaceSize = surface.GetTextSize(" ")
    for i = 1, #words do
        local word = words[i]
        if KEY_WORDS[word] then
            surface.SetTextColor(160, 193, 255)
        elseif self:IsDataType(word) then
            surface.SetTextColor(110, 140, 255)
        elseif self:IsFunction(word) then
            surface.SetTextColor(125, 90, 180)
        else
            surface.SetTextColor(255, 255, 255)
        end
        surface.SetTextPos(offset, yPos)
        surface.DrawText(word)
        local tW, tH = surface.GetTextSize(word)
        offset = offset + tW + spaceSize
    end
    -- draw.SimpleText(self.Text, "ChatFont", h/2, h/2, color_white, 0, 1)
end

local KEY_CHARS = {
    [KEY_SPACE] = " ",
    [KEY_SEMICOLON] = ";"
}

local KEY_SYMBOLS = {
    [KEY_1] = "!",
    [KEY_2] = "\"",
    [KEY_3] = "£",
    [KEY_4] = "$",
    [KEY_5] = "%",
    [KEY_6] = "^",
    [KEY_7] = "&",
    [KEY_8] = "*",
    [KEY_9] = "(",
    [KEY_0] = ")",
    [KEY_COMMA] = "<",
    [KEY_PERIOD] = ">",
    [KEY_SLASH] = "?"
}

local function KeyToChar(key)
    local char = KEY_CHARS[key]
    if not char then
        char = input.GetKeyName(key) or "-"
    end
    return char
end

function PANEL:AddCharacter(keycode, isCapital)
    local char = KeyToChar(keycode)
    if isCapital then
        char = KEY_SYMBOLS[keycode] or string.upper(char)
    end

    self.Text = self.Text .. char
end

function PANEL:RemoveCharacter()
    self.Text = self.Text:sub(1, #self.Text-1)
end

vgui.Register("Developer.LuaExecLine", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
    self.Lines = {}
    self.CurLine = 0
    self:AddLine(1)
end

function PANEL:AddLine(pos)
    local line = self:Add("Developer.LuaExecLine")
    line.Master = self
    line:Dock(TOP)
    self.CurLine = pos
    line.LineId = pos
    table.insert(self.Lines, pos, line)
    self:ReEvaluateLines()
end

function PANEL:ReEvaluateLines()
    for i = 1, #self.Lines do
        local line = self.Lines[i]
        line.LineId = i
        line:SetZPos(i)
    end
end

local VALID_KEYS = {
    [KEY_SPACE] = true
}

local function IsKeyValid(key)
    if VALID_KEYS[key] then
        return true
    end
    if key >= 1 and key <= 63 then
        return true
    end
    return false
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_ENTER then
        self:AddLine(self.CurLine + 1)
        return
    end
    local line = self.Lines[self.CurLine]
    if not IsValid(line) then return end

    if key == KEY_BACKSPACE then
        line:RemoveCharacter()
    elseif key == KEY_UP then
        self.CurLine = math.max(self.CurLine - 1, 1)
    elseif key == KEY_DOWN then
        self.CurLine = math.min(self.CurLine + 1, #self.Lines)
    end

    if not IsKeyValid(key) then return end
    line:AddCharacter(key, input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT))
end

vgui.Register("Developer.LuaExecCode", PANEL, "DScrollPanel")
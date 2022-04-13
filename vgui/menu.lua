local function CreateSMat(sName, sMat)
    return CreateMaterial( sName, "UnlitGeneric", {
        ["$basetexture"] = sMat or "gui/corner8",
        --["$model"] = 1,
        --["$translucent"] = 1,
        --["$nocull"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1,
        ["$alphatest"] = 1
    })
end

local tex_corner8 = CreateSMat("tex_corner8", "gui/corner8")
local tex_corner16 = CreateSMat("tex_corner16", "gui/corner16")
local tex_corner32 = CreateSMat("tex_corner32", "gui/corner32")
local tex_corner64 = CreateSMat("tex_corner64", "gui/corner64")
local tex_corner512 = CreateSMat("tex_corner512", "gui/corner512")
local function RoundedBoxEx( bordersize, x, y, w, h, color, tl, tr, bl, br ) -- stencil friendly

    surface.SetDrawColor( color.r, color.g, color.b, color.a )

    if ( bordersize <= 0 ) then
        surface.DrawRect( x, y, w, h )
        return
    end

    x = math.Round( x )
    y = math.Round( y )
    w = math.Round( w )
    h = math.Round( h )
    bordersize = math.min( math.Round( bordersize ), math.floor( w / 2 ), math.floor( h / 2 ) )

    surface.DrawRect( x + bordersize, y, w - bordersize * 2, h )
    surface.DrawRect( x, y + bordersize, bordersize, h - bordersize * 2 )
    surface.DrawRect( x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2 )

    local tex = tex_corner8
    if ( bordersize > 8 ) then tex = tex_corner16 end
    if ( bordersize > 16 ) then tex = tex_corner32 end
    if ( bordersize > 32 ) then tex = tex_corner64 end
    if ( bordersize > 64 ) then tex = tex_corner512 end

    surface.SetMaterial(tex)

    if ( tl ) then
        surface.DrawTexturedRectUV( x, y, bordersize, bordersize, 0, 0, 1, 1 )
    else
        surface.DrawRect( x, y, bordersize, bordersize )
    end

    if ( tr ) then
        surface.DrawTexturedRectUV( x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1 )
    else
        surface.DrawRect( x + w - bordersize, y, bordersize, bordersize )
    end

    if ( bl ) then
        surface.DrawTexturedRectUV( x, y + h -bordersize, bordersize, bordersize, 0, 1, 1, 0 )
    else
        surface.DrawRect( x, y + h - bordersize, bordersize, bordersize )
    end

    if ( br ) then
        surface.DrawTexturedRectUV( x + w - bordersize, y + h - bordersize, bordersize, bordersize, 1, 1, 0, 0 )
    else
        surface.DrawRect( x + w - bordersize, y + h - bordersize, bordersize, bordersize )
    end
end


local PANEL = {}

AccessorFunc(PANEL, "m_Shortcut", "Shortcut")

function PANEL:Init()
    self.m_bIsMenuComponent = true
    self:SetShortcut({KEY_LSHIFT, KEY_A})
end

function PANEL:GetShortcutText()
    local shortcut = self:GetShortcut()
    local txt = ""
    if isstring(shortcut) then
        txt = shortcut
    elseif isnumber(shortcut) then -- KEY_ ENUM
        txt = input.GetKeyName(shortcut)
    elseif istable(shortcut) then
        local len = #shortcut
        for i = 1, len do
            local key = shortcut[i]
            txt = txt .. string.upper(input.GetKeyName(key) or ",")
            if i ~= len then
                txt = txt .. "+"
            end
        end
    end
    return txt
end

function PANEL:Paint(w, h)
    if self:IsHovered() then
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 103, 158, 98))
    end
    draw.SimpleText(self:GetText(), "ChatFont", h*0.15, h*0.5, color_white, 0, 1)
    draw.SimpleText(self:GetShortcutText(), "ChatFont", w-h*0.15, h*0.5, color_white, 2, 1)
end

vgui.Register("Developer.PopupMenuRow", PANEL, "DButton")

local PANEL = {}

AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_bDrawOnTop", "DrawOnTop")

function PANEL:Init()
    self:SetDeleteSelf(true)
    self:SetDrawOnTop(true)

    RegisterDermaMenuForClose(self)
    self.m_iChildren = 0
end


function PANEL:AddOption(sText, fnCallback)
    local btn = self:Add("Developer.PopupMenuRow")
    btn.ParentMenu = self
    btn.m_bIsMenuComponent = true
    btn:Dock(TOP)
    btn:SetTall(24)
    btn:SetText(sText)
    btn.DoClick = function()
        if fnCallback then
            fnCallback(self, btn)
        end
    end
    self.m_iChildren = self.m_iChildren + 1
    self:SetTall(self.m_iChildren*24)
end

local matBlurScreen = Material( "pp/blurscreen" )

--[[
	This is designed for Paint functions..
--]]
local function Derma_DrawBackgroundBlur( panel, starttime )

	local Fraction = 1

	if ( starttime ) then
		Fraction = math.Clamp( (SysTime() - starttime) / 1, 0, 1 )
	end

	local x, y = panel:LocalToScreen( 0, 0 )

	-- local wasEnabled = DisableClipping( true )

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

	surface.SetDrawColor( 0, 0, 0, 19)
	surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

	-- DisableClipping( wasEnabled )

end

function PANEL:Paint(w, h)
    -- Derma_DrawBackgroundBlur(self, 0)
    -- -- draw.RoundedBox(4, 0, 0, w, h, Color(42, 42, 42, 80))
    -- -- draw.RoundedBox(4, 1, 1, w-2, h-2, Color(35, 35, 35, 80))
    -- render.SetStencilWriteMask( 0xFF )
    -- render.SetStencilTestMask( 0xFF )
    -- render.SetStencilReferenceValue( 0 )
    -- render.SetStencilCompareFunction( STENCIL_ALWAYS )
    -- render.SetStencilPassOperation( STENCIL_KEEP )
    -- render.SetStencilFailOperation( STENCIL_KEEP )
    -- render.SetStencilZFailOperation( STENCIL_KEEP )
    -- render.ClearStencil()

    -- render.SetStencilEnable(true)
    --     render.SetStencilReferenceValue(1)
    --     render.SetStencilFailOperation(STENCIL_REPLACE)
    --     render.SetStencilCompareFunction(STENCIL_NEVER)
    --     --HALLOWEEN_EVENT.RoundedBoxEx(self.m_iCornerRadius, 2, 2, w-4, h-self.Price:GetTall()-4, THEME.ItemFrame.Border[bActive], true, true, true, true)
    --     RoundedBoxEx(8, 1, 1, w-2, h-2, color_white, true, true, true, true)
    --     render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    --     RoundedBoxEx(8, 0, 0, w, h, Color(0, 0, 0), true, true, true, true)
    --     -- HALLOWEEN_EVENT.RoundedBoxEx(self.m_iCornerRadius, 0, 0, w, h-self.Price:GetTall(), THEME.ItemFrame.Border[bActive], true, true, true, true)
    -- render.SetStencilEnable(false)
    draw.RoundedBox(4, 0, 0, w, h, Color(41, 45, 49))
end

vgui.Register("Developer.PopupMenu", PANEL, "DScrollPanel")

function Developer.CreateMenu()
    local x, y = input.GetCursorPos()
    local pnl = vgui.Create("Developer.PopupMenu")
    pnl:SetPos(x, y)
    pnl:SetSize(200, 24)
    pnl:MakePopup()
    return pnl
end
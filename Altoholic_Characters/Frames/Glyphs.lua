local addonName = "Altoholic"
local addon = _G[addonName]

addon.Glyphs = {}

local ns = addon.Glyphs		-- ns = glyphs namespace

local parent = "AltoholicFrameGlyphs"

-- *** GLYPHS ***

local GLYPH_TYPE_MAJOR = 1;
local GLYPH_TYPE_MINOR = 2;
	
local glyphSlotTexCoord = {
	-- copied from Blizzard_GlyphUI.lua, no idea why they're not visible from here .. :/

	[GLYPH_TYPE_MAJOR] = {
		ring = { size = 62, left = 0.85839844, right = 0.93847656, top = 0.22265625, bottom = 0.30273438 },
		highlight = { size = 76, left = 0.85839844, right = 0.95214844, top = 0.30468750, bottom = 0.39843750 }
	},
	[GLYPH_TYPE_MINOR] = {
		ring = { size = 66, left = 0.85839844, right = 0.92285156, top = 0.00097656, bottom = 0.06542969 },
		highlight = { size = 80, left = 0.85839844, right = 0.93652344, top = 0.06738281, bottom = 0.14550781 }
	},
}

local function DrawGlyph(spec, id)
	local name = parent .. "Glyph" .. (((spec-1)*6)+id)
	local glyph = _G[name]
	
	local character = addon.Tabs.Characters:GetAltKey()
	local enabled, glyphType, spell, icon = DataStore:GetGlyphSocketInfo(character, spec, id)
	
	local info = glyphSlotTexCoord[glyphType]
	if info then
		glyph.glyphType = glyphType;
		
		glyph.ring:SetWidth(info.ring.size);
		glyph.ring:SetHeight(info.ring.size);
		glyph.ring:SetTexCoord(info.ring.left, info.ring.right, info.ring.top, info.ring.bottom);
		
		glyph.highlight:SetWidth(info.highlight.size);
		glyph.highlight:SetHeight(info.highlight.size);
		glyph.highlight:SetTexCoord(info.highlight.left, info.highlight.right, info.highlight.top, info.highlight.bottom);
		
		glyph.glyph:SetWidth(info.ring.size - 4);
		glyph.glyph:SetHeight(info.ring.size - 4);
		glyph.glyph:SetAlpha(0.75);
	end
	
	local vc = 1		-- vertexColor
	if enabled == 0 then
		glyph.glyph:Hide();
		vc = 0.25
	elseif spell == 0 then
		glyph.glyph:Hide();
	else
		glyph.glyph:Show();
		SetPortraitToTexture(glyph.glyph, icon)
	end

	glyph.ring:SetVertexColor(vc, vc, vc)
	glyph.highlight:SetVertexColor(vc, vc, vc)
	glyph:SetScale(0.80)
end

function ns:Update()
	local character = addon.Tabs.Characters:GetAltKey()
	
	AltoholicTabCharactersStatus:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), GLYPHS))
	
	for spec = 1, 2 do
		for id = 1, 6 do
			DrawGlyph(spec, id)
		end
	end
end

function ns:Button_OnLoad(frame)
	local name = frame:GetName()
	local id = frame:GetID()
	local glyph = _G[name]
	
	glyph.glyph = _G[name .. "Glyph"]
	glyph.highlight = _G[name .. "Highlight"]
	glyph.ring = _G[name .. "Ring"]
	
	local ratio = 0.7
	if (id == 1) or (id == 4) or (id == 6) then		-- major
		ratio = 0.85
	end

	glyph.glyph:SetWidth(63 * ratio);
	glyph.glyph:SetHeight(63 * ratio);
	glyph.highlight:SetWidth(108 * ratio);
	glyph.highlight:SetHeight(108 * ratio);
	glyph.highlight:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
	glyph.ring:SetWidth(82 * ratio);
	glyph.ring:SetHeight(82 * ratio);
	glyph.ring:SetPoint("CENTER", glyph, "CENTER", 0, -1);
	glyph.ring:SetTexCoord(0.767578125, 0.92578125, 0.32421875, 0.482421875);
end

local glyphTypes = {
	MAJOR_GLYPH,
	MINOR_GLYPH,
}

function ns:Button_OnEnter(frame)
	local id = frame:GetID()
	local currentSpecGroup = 1
	
	if id > 6 then
		currentSpecGroup = 2
		id = id - 6
	end

	local character = addon.Tabs.Characters:GetAltKey()
	local enabled, glyphType, spell, _, glyphID, tooltipIndex = DataStore:GetGlyphSocketInfo(character, currentSpecGroup, id)
	if not glyphType then return end
	
	-- DEFAULT_CHAT_FRAME:AddMessage("spell : " .. spell .. " glyph ID : " .. glyphID)
	
	local glyphTypeText = "|cFF69CCF0" .. glyphTypes[tonumber(glyphType)]

	AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
	AltoTooltip:ClearLines();
	if enabled == 0 then
		AltoTooltip:AddLine("|cFFFF0000" .. GLYPH_LOCKED);
		AltoTooltip:AddLine(glyphTypeText);
		AltoTooltip:AddLine(_G["GLYPH_SLOT_TOOLTIP"..tooltipIndex]);

		AltoTooltip:Show();
		return
	elseif spell == 0 then
		AltoTooltip:AddLine("|cFF808080" .. GLYPH_EMPTY);
		AltoTooltip:AddLine(glyphTypeText);
		AltoTooltip:AddLine(GLYPH_EMPTY_DESC);
		AltoTooltip:Show();
		return 
	end

	local link = DataStore:GetGlyphLink(glyphID)
	if link then 
		AltoTooltip:SetHyperlink(link);
	end
	AltoTooltip:Show();
end

function ns:Button_OnClick(frame, button)
	local id = frame:GetID()
	local currentSpecGroup = 1
	
	if id > 6 then
		currentSpecGroup = 2
		id = id - 6
	end
	
	local character = addon.Tabs.Characters:GetAltKey()
	local enabled, glyphType, spell, _, glyphID = DataStore:GetGlyphSocketInfo(character, currentSpecGroup, id)

	if not spell then return end
	
	if ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local link = DataStore:GetGlyphLink(glyphID)
			if link then
				chat:Insert(link)
			end
		end
	end
end

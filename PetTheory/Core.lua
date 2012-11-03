-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local pairs = _G.pairs
local type = _G.type


-- Libraries
local string = _G.string
local table = _G.table


-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...

local LibStub = _G.LibStub
local addon = LibStub("AceAddon-3.0"):NewAddon(FOLDER_NAME, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local LPJ = LibStub("LibPetJournal-2.0")


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------
local COMPANION_BUTTON_HEIGHT = 46
local COMPANION_PETS_LABEL = _G.select(3, _G.GetAuctionItemSubClasses(9))
local MAX_ACTIVE_PETS = 3
local BATTLEPET_REGISTRY = {}


local SORT_FIELDS = {
	[_G.LEVEL] = "level",
	[_G.NAME] = "name",
	[_G.TYPE] = "type",
	[_G.PET_BATTLE_STAT_HEALTH] = "max_health",
	[_G.PET_BATTLE_STAT_POWER] = "attack",
	[_G.STAT_TEMPLATE:format(_G.PRIMARY)] = "primary_stat",
	[_G.PET_BATTLE_STAT_QUALITY] = "rarity",
	[_G.PET_BATTLE_STAT_SPEED] = "speed",
}


local GENERIC_FALLBACKS = {
	"level:false",
	"name:true",
}


local SORT_FALLBACKS = {
	attack = GENERIC_FALLBACKS,
	level = {
		"name:true",
	},
	max_health = GENERIC_FALLBACKS,
	name = {
		"level:false",
	},
	primary_stat = GENERIC_FALLBACKS,
	rarity = GENERIC_FALLBACKS,
	speed = GENERIC_FALLBACKS,
	type = GENERIC_FALLBACKS,
}


local NPC_ID_FROM_ITEM_ID = {
	[4401] = 2671, -- Mechanical Squirrel Box = Mechanical Squirrel
	[8485] = 7385, -- Cat Carrier (Bombay) = Bombay Cat
	[8486] = 7384, -- Cat Carrier (Cornish Rex) = Cornish Rex Cat
	[8487] = 7382, -- Cat Carrier (Orange Tabby) = Orange Tabby Cat
	[8488] = 7381, -- Cat Carrier (Silver Tabby) = Silver Tabby Cat
	[8489] = 7386, -- Cat Carrier (White Kitten) = White Kitten
	[8490] = 7380, -- Cat Carrier (Siamese) = Siamese Cat
	[8491] = 7383, -- Cat Carrier (Black Tabby) = Black Tabby Cat
	[8492] = 7387, -- Parrot Cage (Green Wing Macaw) = Green Wing Macaw
	[8495] = 7389, -- Parrot Cage (Senegal) = Senegal
	[8496] = 7390, -- Parrot Cage (Cockatiel) = Cockatiel
	[8497] = 7560, -- Rabbit Crate (Snowshoe) = Snowshoe Rabbit
	[8498] = 7545, -- Tiny Emerald Whelpling = Emerald Whelpling
	[8499] = 7544, -- Tiny Crimson Whelpling = Crimson Whelpling
	[10394] = 14421, -- Prairie Dog Whistle = Brown Prairie Dog
	[11026] = 7549, -- Tree Frog Box = Tree Frog
	[11027] = 7550, -- Wood Frog Box = Wood Frog
	[15996] = 12419, -- Lifelike Mechanical Toad = Lifelike Toad
	[21301] = 15698, -- Green Helper Box = Father Winter's Helper
	[21305] = 15705, -- Red Helper Box = Winter's Little Helper
	[21308] = 15706, -- Jingling Bell = Winter Reindeer
	[21309] = 15710, -- Snowman Kit = Tiny Snowman
	[22235] = 16085, -- Truesilver Shafted Arrow = Peddlefeet
	[23083] = 16701, -- Captured Flame = Spirit of Summer
	[29364] = 20472, -- Brown Rabbit Crate = Brown Rabbit
	[29901] = 21010, -- Blue Moth Egg = Blue Moth
	[29902] = 21009, -- Red Moth Egg = Red Moth
	[29903] = 21008, -- Yellow Moth Egg = Yellow Moth
	[29904] = 21018, -- White Moth Egg = White Moth
	[29960] = 21076, -- Captured Firefly = Firefly
	[32233] = 22943, -- Wolpertinger's Tankard = Wolpertinger
	[44794] = 32791, -- Spring Rabbit's Foot = Spring Rabbit
	[46398] = 34364, -- Cat Carrier (Calico Cat) = Calico Cat
}


local DATABASE_DEFAULTS = {
	global = {
		display = {},
		filters = {
			zone_only = false,
		},
		sort = {
			ascending = true,
			type = "name",
		},
	},
}


-------------------------------------------------------------------------------
-- Variables.
-------------------------------------------------------------------------------
local db
local num_unique_pets = 0

local sorted_pets = {}

local known_pets_by_npc_id = {}
local unknown_pets_by_npc_id = {}

local known_pets_by_name = {}
local unknown_pets_by_name = {}

local pets_by_npc_id = {}

-------------------------------------------------------------------------------
-- Helper functions.
-------------------------------------------------------------------------------
local AcquireTable
local ReleaseTable
do
	local table_cache = {}


	function AcquireTable()
		return table.remove(table_cache) or {}
	end


	function ReleaseTable(tbl)
		if not tbl then
			return
		end
		table.wipe(tbl)
		table.insert(table_cache, tbl)
	end
end -- do block


local BattlePetInfoString
do
	local LEVEL_PARENS_FORMAT = _G.PARENS_TEMPLATE:format(("%s %%d"):format(_G.LEVEL_ABBR))

	local output = {}
	local working_output = {}

	function BattlePetInfoString(identifier, known_table, unknown_table)
		local known_entries = known_table[identifier]
		local unknown_entries = unknown_table[identifier]
		table.wipe(output)

		if known_entries then
			local shown_header

			for index = 1, #known_entries do
				local pet = known_entries[index]
				table.wipe(working_output)

				if not shown_header then
					if pet.is_wild then
						table.insert(working_output, "|cff82c5ff" .. _G.BATTLE_PET_CAPTURED .. " " .. _G.PARENS_TEMPLATE:format(pet.name) .. _G.HEADER_COLON .. "|r\n")
					else
						table.insert(working_output, "|cff20ff20" .. _G.ITEM_SPELL_KNOWN .. _G.HEADER_COLON .. " |r\n")
					end
					shown_header = true
				end

				if pet.rarity then
					table.insert(working_output, _G.ITEM_QUALITY_COLORS[pet.rarity - 1].hex .. _G["BATTLE_PET_BREED_QUALITY" .. pet.rarity])
					table.insert(working_output, "|r |cffffffff")
					table.insert(working_output, LEVEL_PARENS_FORMAT:format(pet.level))
					table.insert(working_output, "|r")

					if index == #known_entries then
						table.insert(working_output, ".")
					else
						table.insert(working_output, ", ")
					end
				end
				table.insert(output, table.concat(working_output, ""))
			end
		elseif unknown_entries then
			local pet = unknown_entries[1]
			table.wipe(working_output)

			if pet.is_wild then
				table.insert(working_output, "|cff82c5ff" .. _G.UNIT_CAPTURABLE .. _G.HEADER_COLON .. " " .. pet.name .. "|r")
			else
				table.insert(working_output, "|cffff2020" .. _G.UNKNOWN .. "|r")
			end
			table.insert(output, table.concat(working_output, ""))
		end

		if #output > 0 then
			return table.concat(output, "")
		end
	end
end


local function ModifyTooltip(tooltip, identifier, known_table, unknown_table)
	local output = BattlePetInfoString(identifier, known_table, unknown_table)

	if not output then
		return
	end
	tooltip:AddLine("\n" .. output, true)
end


_G.GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local name, link = self:GetItem()

	if not link then
		return
	end
	local sub_class = _G.select(7, _G.GetItemInfo(link))

	if sub_class == COMPANION_PETS_LABEL then
		if known_pets_by_name[name] or unknown_pets_by_name[name] then
			ModifyTooltip(self, name, known_pets_by_name, unknown_pets_by_name)
		else
			ModifyTooltip(self, NPC_ID_FROM_ITEM_ID[_G.tonumber(link:match("item:(%d+):"))], known_pets_by_npc_id, unknown_pets_by_npc_id)
		end
	end
end)

do
	local previous_tooltip_line
	local entity_registry = {}

	_G.GameTooltip:HookScript("OnUpdate", function(self)
		if not _G.Minimap:IsMouseOver() then
			return
		end
		local tooltip_line = _G["GameTooltipTextLeft1"]:GetText()

		if not tooltip_line or tooltip_line == previous_tooltip_line then
			return
		end
		previous_tooltip_line = tooltip_line
		tooltip_line = tooltip_line:gsub([[|T(.-)|t]], "")

		if tooltip_line:find("\n") then
			local entities = { ("\n"):split(tooltip_line) }
			table.wipe(entity_registry)

			for index = 1, #entities do
				local entity = entities[index]

				if not entity_registry[entity] then
					ModifyTooltip(_G.GameTooltip, entity, known_pets_by_name, unknown_pets_by_name)
					entity_registry[entity] = true
				end
			end
		else
			ModifyTooltip(_G.GameTooltip, tooltip_line, known_pets_by_name, unknown_pets_by_name)
		end
		_G.GameTooltip:Show()
	end)

	_G.GameTooltip:HookScript("OnHide", function()
		previous_tooltip_line = nil
	end)
end -- do-block


do
	local PET_TEXTURES = {
		"Border",
		"BorderAlive",
	}

	local PET_FONTS = {
		"Name",
	}

	addon:SecureHook("PetBattleUnitFrame_UpdateDisplay", function(frame)
		if not frame.petOwner or not frame.petIndex then
			return
		end
		local r, g, b, hex = _G.GetItemQualityColor(_G.C_PetBattles.GetBreedQuality(frame.petOwner, frame.petIndex) - 1)

		for index = 1, #PET_TEXTURES do
			if frame[PET_TEXTURES[index]] then
				frame[PET_TEXTURES[index]]:SetVertexColor(r, g, b)
			end
		end

		for index = 1, #PET_FONTS do
			local font_string = frame[PET_FONTS[index]]

			if font_string then
				local text = font_string:GetText()

				if text then
					font_string:SetFormattedText("|c%s%s|r", hex, text)
				end
			end
		end
	end)
end -- do-block


local function ResetScrollBar()
	_G.PetJournal.listScroll.scrollBar:SetValue(_G.PetJournal.listScroll.scrollBar:GetMinMaxValues())
end


local function FilterDropDown_Initialize(self, level)
	local info = _G.UIDropDownMenu_CreateInfo()
	info.keepShownOnClick = true

	if level == 1 then
		info.isNotRadio = true

		info.text = _G.RACE_CLASS_ONLY:format(_G.ZONE)
		info.func = function()
			db.filters.zone_only = not db.filters.zone_only
			ResetScrollBar()
			private.PopulateSortedList()
		end
		info.checked = db.filters.zone_only
		_G.UIDropDownMenu_AddButton(info, level)

		info.text = _G.COLLECTED
		info.func = function(_, _, _, value)
			ResetScrollBar()
			_G.C_PetJournal.SetFlagFilter(_G.LE_PET_JOURNAL_FLAG_COLLECTED, value)

			if (value) then
				_G.UIDropDownMenu_EnableButton(1, 3)
			else
				_G.UIDropDownMenu_DisableButton(1, 3)
			end
		end
		info.checked = not _G.C_PetJournal.IsFlagFiltered(_G.LE_PET_JOURNAL_FLAG_COLLECTED)
		_G.UIDropDownMenu_AddButton(info, level)

		info.text = _G.FAVORITES_FILTER
		info.func = function(_, _, _, value)
			_G.C_PetJournal.SetFlagFilter(_G.LE_PET_JOURNAL_FLAG_FAVORITES, value)
		end
		info.disabled = not info.checked or info.checked ~= true
		info.checked = not _G.C_PetJournal.IsFlagFiltered(_G.LE_PET_JOURNAL_FLAG_FAVORITES)
		info.leftPadding = 16
		_G.UIDropDownMenu_AddButton(info, level)

		info.leftPadding = 0
		info.disabled = nil

		info.text = _G.NOT_COLLECTED
		info.func = function(_, _, _, value)
			ResetScrollBar()
			_G.C_PetJournal.SetFlagFilter(_G.LE_PET_JOURNAL_FLAG_NOT_COLLECTED, value)
		end
		info.checked = not _G.C_PetJournal.IsFlagFiltered(_G.LE_PET_JOURNAL_FLAG_NOT_COLLECTED)
		_G.UIDropDownMenu_AddButton(info, level)

		info.checked = nil
		info.isNotRadio = nil
		info.func = nil
		info.hasArrow = true
		info.notCheckable = true

		info.text = _G.PET_FAMILIES
		info.value = "FAMILIES"
		_G.UIDropDownMenu_AddButton(info, level)

		info.text = _G.SOURCES
		info.value = "SOURCES"
		_G.UIDropDownMenu_AddButton(info, level)

		info.text = _G.RAID_FRAME_SORT_LABEL
		info.value = "SORTING"
		_G.UIDropDownMenu_AddButton(info, level)
	else --if level == 2 then
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true

		if _G.UIDROPDOWNMENU_MENU_VALUE == "FAMILIES" then
			info.text = _G.CHECK_ALL
			info.func = function()
				_G.C_PetJournal.AddAllPetTypesFilter()
				_G.UIDropDownMenu_Refresh(_G.PetTheory_FilterDropDown, 1, 2)
			end
			_G.UIDropDownMenu_AddButton(info, level)

			info.text = _G.UNCHECK_ALL
			info.func = function()
				_G.C_PetJournal.ClearAllPetTypesFilter()
				_G.UIDropDownMenu_Refresh(_G.PetTheory_FilterDropDown, 1, 2)
			end
			_G.UIDropDownMenu_AddButton(info, level)

			info.notCheckable = false
			local numTypes = _G.C_PetJournal.GetNumPetTypes()
			for i = 1, numTypes do
				info.text = _G["BATTLE_PET_NAME_" .. i]
				info.func = function(_, _, _, value)
					_G.C_PetJournal.SetPetTypeFilter(i, value)
				end
				info.checked = function() return not _G.C_PetJournal.IsPetTypeFiltered(i) end
				_G.UIDropDownMenu_AddButton(info, level)
			end
		elseif _G.UIDROPDOWNMENU_MENU_VALUE == "SOURCES" then
			info.text = _G.CHECK_ALL
			info.func = function()
				_G.C_PetJournal.AddAllPetSourcesFilter()
				_G.UIDropDownMenu_Refresh(_G.PetTheory_FilterDropDown, 2, 2)
			end
			_G.UIDropDownMenu_AddButton(info, level)

			info.text = _G.UNCHECK_ALL
			info.func = function()
				_G.C_PetJournal.ClearAllPetSourcesFilter()
				_G.UIDropDownMenu_Refresh(_G.PetTheory_FilterDropDown, 2, 2)
			end
			_G.UIDropDownMenu_AddButton(info, level)

			info.notCheckable = false
			local numSources = _G.C_PetJournal.GetNumPetSources()
			for i = 1, numSources do
				info.text = _G["BATTLE_PET_SOURCE_" .. i]
				info.func = function(_, _, _, value)
					_G.C_PetJournal.SetPetSourceFilter(i, value)
				end
				info.checked = function() return not _G.C_PetJournal.IsPetSourceFiltered(i) end
				_G.UIDropDownMenu_AddButton(info, level)
			end
		elseif _G.UIDROPDOWNMENU_MENU_VALUE == "SORTING" then
			info.keepShownOnClick = true
			info.checked = false
			info.isNotRadio = false
			info.notCheckable = false

			for sort_label, sort_field in pairs(SORT_FIELDS) do
				info.text = sort_label
				info.func = function(_, _, _, value)
					db.sort.type = sort_field
					_G.UIDropDownMenu_Refresh(_G.PetTheory_FilterDropDown, 1, 2)
					private.PopulateSortedList()
				end
				info.checked = function()
					return db.sort.type == sort_field
				end
				_G.UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end


local function fallback_sort(a, b, field, current_fallback)
	local fallback, is_ascending = (":"):split(SORT_FALLBACKS[field][current_fallback])
	local a_field, b_field = a[fallback], b[fallback]

	if a_field == b_field and SORT_FALLBACKS[field][current_fallback + 1] then
		return fallback_sort(a, b, field, current_fallback + 1)
	end

	if type(a_field) == "boolean" then
		a_field = a_field and 1 or 0
		b_field = b_field and 1 or 0
	end

	if is_ascending == "true" then
		return a_field and b_field and a_field < b_field
	end
	return a_field and b_field and a_field > b_field
end


local function sort_check_boolean(a, b, bool_field)
	if not a[bool_field] and b[bool_field] then
		return false
	elseif not b[bool_field] and a[bool_field] then
		return true
	end
end


local BOOL_CHECKS = {
	"can_battle",
	"is_favorite",
	"is_owned",
}


local function field_sort(a, b)
	for index = 1, #BOOL_CHECKS do
		local bool_value = sort_check_boolean(a, b, BOOL_CHECKS[index])

		if _G.type(bool_value) == "boolean" then
			return bool_value
		end
	end
	local field = db.sort.type
	local bool_value = sort_check_boolean(a, b, field)

	if _G.type(bool_value) == "boolean" then
		return bool_value
	end
	local a_field, b_field = a[field], b[field]

	if a_field == b_field then
		return fallback_sort(a, b, field, 1)
	end

	if db.sort.ascending then
		return a_field and b_field and a_field < b_field
	end
	return a_field and b_field and a_field > b_field
end


local PET_STAT_MULTIPLIERS = {
	attack = 1,
	max_health = 0.15,
	speed = 1,
}


do
	local current_pet_ids = {}
	local removed_pet_ids = {}


	local function NewPetEntry(identifier, can_battle, creature_id, is_wild, name, pet_type)
		local pet = {
			can_battle = can_battle,
			creature_id = creature_id,
			is_wild = is_wild,
			name = name,
			type = pet_type,
		}

		BATTLEPET_REGISTRY[identifier] = pet
		return pet
	end


	function private.PopulateSortedList()
		-------------------------------------------------------------------------------
		-- Update currently-owned pets.
		-------------------------------------------------------------------------------
		table.wipe(current_pet_ids)

		for index, pet_id in LPJ:IteratePetIDs() do
			local species_id, custom_name, level, exp, max_exp, display_id, name, icon, pet_type, creature_id = _G.C_PetJournal.GetPetInfoByPetID(pet_id)
			local _, _, _, _, _, _, is_wild, can_battle, tradable, unique = _G.C_PetJournal.GetPetInfoBySpeciesID(species_id)
			local _, max_health, attack, speed, rarity = _G.C_PetJournal.GetPetStats(pet_id)

			current_pet_ids[pet_id] = true

			local pet = BATTLEPET_REGISTRY[pet_id] or NewPetEntry(pet_id, can_battle, creature_id, is_wild, name, pet_type)
			pet.attack = attack
			pet.custom_name = custom_name
			pet.id = pet_id
			pet.is_favorite = _G.C_PetJournal.PetIsFavorite(pet_id)
			pet.is_owned = true
			pet.level = level
			pet.max_health = max_health
			pet.speed = speed
			pet.rarity = rarity

			local top_stat
			local top_value = 0

			for stat_name, multiplier in pairs(PET_STAT_MULTIPLIERS) do
				if pet[stat_name] then
					local weighed_value = pet[stat_name] * multiplier

					if weighed_value > top_value then
						top_stat = stat_name
						top_value = weighed_value
					elseif weighed_value == top_value then
						top_stat = nil
						top_value = 0
					end
				end
			end
			pet.primary_stat = top_stat
		end

		-------------------------------------------------------------------------------
		-- Build sorted list for display in the PetJournal frame.
		-------------------------------------------------------------------------------
		local num_pets = _G.C_PetJournal.GetNumPets(_G.PetJournal.isWild)

		table.wipe(sorted_pets)

		for pet_index = 1, num_pets do
			local pet_id, _, _, _, _, _, _, name, _, pet_type, creature_id, source_text, _, is_wild, can_battle = _G.C_PetJournal.GetPetInfoByIndex(pet_index, false)
			local identifier

			if pet_id == 0 then
				identifier = name
			else
				identifier = pet_id
			end
			local pet = BATTLEPET_REGISTRY[identifier] or NewPetEntry(identifier, can_battle, creature_id, is_wild, name, pet_type)
			pet.journal_index = pet_index

			if not db.filters.zone_only or source_text:find(private.zone_name) or source_text:find(private.real_zone_name) or (private.subzone_name ~= "" and source_text:find(private.subzone_name)) then
				sorted_pets[#sorted_pets + 1] = pet
			end
		end
		table.sort(sorted_pets, field_sort)

		-------------------------------------------------------------------------------
		-- Update reference tables.
		-------------------------------------------------------------------------------
		table.wipe(removed_pet_ids)

		for identifier, pet in pairs(BATTLEPET_REGISTRY) do
			if type(identifier) == "number" and not current_pet_ids[identifier] then
				removed_pet_ids[identifier] = true
			end
		end

		for identifier in pairs(removed_pet_ids) do
			local pet = BATTLEPET_REGISTRY[identifier]

			pet.id = nil
			pet.is_favorite = nil
			pet.is_owned = nil

			if #known_pets_by_npc_id > 0 and #known_pets_by_npc_id[pet.creature_id] == 1 then
				BATTLEPET_REGISTRY[pet.name] = pet
			end
			BATTLEPET_REGISTRY[identifier] = nil
		end

		for npc_id, pet_list in pairs(pets_by_npc_id) do
			ReleaseTable(pet_list)
		end
		table.wipe(pets_by_npc_id)

		for identifier, pet in pairs(BATTLEPET_REGISTRY) do
			local creature_id = pet.creature_id
			pets_by_npc_id[creature_id] = pets_by_npc_id[creature_id] or AcquireTable()
			pets_by_npc_id[creature_id][#pets_by_npc_id[creature_id] + 1] = pet
		end
		table.wipe(known_pets_by_npc_id)
		table.wipe(unknown_pets_by_npc_id)

		table.wipe(known_pets_by_name)
		table.wipe(unknown_pets_by_name)

		num_unique_pets = 0

		for creature_id, pet_list in pairs(pets_by_npc_id) do
			if pet_list[1].is_owned then
				num_unique_pets = num_unique_pets + 1
				known_pets_by_npc_id[creature_id] = pet_list
				known_pets_by_name[pet_list[1].name] = pet_list
			else
				unknown_pets_by_npc_id[creature_id] = pet_list
				unknown_pets_by_name[pet_list[1].name] = pet_list
			end
		end
		private.UpdatePetList()
	end
end -- do-block


local function PetListButton_OnEnter(button)
	if not button.canBattle then
		return
	end
	private.current_button = button
	_G.PetJournal_ShowAbilityTooltip(button, button.abilityID, button.speciesID, button.petID)
end


local function PetListButton_OnLeave(button)
	private.current_button = nil
	_G.PetJournal_HideAbilityTooltip(button)
end


local function PetListButton_OnDoubleClick(button, mouse_button)
	_G.C_PetJournal.SummonPetByID(button.petID)
end


do
	local MODIFIER_ABILITIES = {
		"SHIFT",
		"CTRL",
		"ALT",
	}

	function addon:MODIFIER_STATE_CHANGED(event_name, modifier, is_down)
		local button = private.current_button

		if not button then
			return
		end

		if is_down == 0 then
			_G.PetJournal_ShowAbilityTooltip(button, button.abilityID, button.speciesID, button.petID)
			return
		end
		local abilities, levels = _G.C_PetJournal.GetPetAbilityList(button.speciesID)
		local ability_id

		for index = 1, #MODIFIER_ABILITIES do
			if modifier:find(MODIFIER_ABILITIES[index]) then
				ability_id = abilities[index]
				break
			end
		end

		if not ability_id then
			return
		end
		_G.PetJournal_ShowAbilityTooltip(button, ability_id, button.speciesID, button.petID)
	end
end -- do-block


local function InitializePetListButton(button)
	if not button.stat_icon then
		local drag_button = button.dragButton
		local layer, sublayer = drag_button.levelBG:GetDrawLayer()

		local stat_icon = drag_button:CreateTexture(nil, "OVERLAY")
		stat_icon:SetSize(10, 10)
		stat_icon:SetPoint("BOTTOMRIGHT", drag_button.levelBG, "BOTTOMRIGHT", 3, -3)
		stat_icon:SetTexture([[Interface\PetBattles\PetBattle-StatIcons]])
		stat_icon:SetDrawLayer(layer, sublayer + 1)
		button.stat_icon = stat_icon
	end
	button:SetScript("OnEnter", PetListButton_OnEnter)
	button:SetScript("OnLeave", PetListButton_OnLeave)
	button:SetScript("OnDoubleClick", PetListButton_OnDoubleClick)

	PetListButton_OnLeave(button)
end


function private.UpdatePetList()
	if not _G.PetJournal or not _G.PetJournal:IsVisible() then
		return
	end
	local scroll_frame = _G.PetJournal.listScroll
	local offset = _G.HybridScrollFrame_GetOffset(scroll_frame)
	local pet_buttons = scroll_frame.buttons
	local pet_button, index

	local is_wild = _G.PetJournal.isWild
	scroll_frame:Show()

	local summoned_pet_id = _G.C_PetJournal.GetSummonedPetID()
	--	local num_pets, num_owned = _G.C_PetJournal.GetNumPets(is_wild)
	local num_owned = _G.select(2, _G.C_PetJournal.GetNumPets(is_wild))
	local num_pets = #sorted_pets

	_G.PetJournal.PetCount.Count:SetText(num_owned)
	_G.PetJournal.PetCount.UniqueCount:SetText(num_unique_pets)

	for button_index = 1, #pet_buttons do
		pet_button = pet_buttons[button_index]
		index = offset + button_index

		InitializePetListButton(pet_button)

		if index <= #sorted_pets then
			local pet_id, species_id, is_owned, custom_name, level, favorite, is_revoked, name, icon, pet_type, creature_id, source_text, description, is_wild_pet, can_battle = _G.C_PetJournal.GetPetInfoByIndex(sorted_pets[index].journal_index, is_wild)

			if custom_name then
				pet_button.name:SetText(custom_name)
				pet_button.name:SetHeight(12)
				pet_button.subName:Show()
				pet_button.subName:SetText(name)
			else
				pet_button.name:SetText(name)
				pet_button.name:SetHeight(30)
				pet_button.subName:Hide()
			end
			pet_button.icon:SetTexture(icon)
			pet_button.petTypeIcon:SetTexture(_G.GetPetTypeTexture(pet_type))

			if favorite then
				pet_button.dragButton.favorite:Show()
			else
				pet_button.dragButton.favorite:Hide()
			end

			if is_owned then
				local health, max_health, attack, speed, rarity = _G.C_PetJournal.GetPetStats(pet_id)
				local colors = _G.ITEM_QUALITY_COLORS[rarity - 1]

				pet_button.name:SetFormattedText("%s%s|r", colors.hex, pet_button.name:GetText())
				pet_button.dragButton.levelBG:SetShown(can_battle)
				pet_button.dragButton.level:SetShown(can_battle)
				pet_button.dragButton.level:SetText(level)

				pet_button.icon:SetDesaturated(0)
				pet_button.name:SetFontObject("GameFontNormal")
				pet_button.petTypeIcon:SetShown(can_battle)
				pet_button.petTypeIcon:SetDesaturated(0)
				pet_button.dragButton:Enable()
				pet_button.iconBorder:Show()
				pet_button.iconBorder:SetVertexColor(colors.r, colors.g, colors.b)

				if health and health <= 0 then
					pet_button.isDead:Show()
				else
					pet_button.isDead:Hide()
				end

				if is_revoked then
					pet_button.dragButton.levelBG:Hide()
					pet_button.dragButton.level:Hide()
					pet_button.iconBorder:Hide()
					pet_button.icon:SetDesaturated(1)
					pet_button.petTypeIcon:SetDesaturated(1)
					pet_button.dragButton:Disable()
				end

				if can_battle then
					local primary_stat = BATTLEPET_REGISTRY[pet_id].primary_stat

					if primary_stat then
						if primary_stat == "attack" then
							pet_button.stat_icon:SetTexCoord(0.0, 0.5, 0.0, 0.5)
						elseif primary_stat == "max_health" then
							pet_button.stat_icon:SetTexCoord(0.5, 1.0, 0.5, 1.0)
						elseif primary_stat == "speed" then
							pet_button.stat_icon:SetTexCoord(0.0, 0.5, 0.5, 1)
						end
						pet_button.stat_icon:Show()
					else
						pet_button.stat_icon:Hide()
					end
				else
					pet_button.stat_icon:Hide()
				end
			else
				pet_button.dragButton.levelBG:Hide()
				pet_button.dragButton.level:Hide()
				pet_button.icon:SetDesaturated(1)
				pet_button.iconBorder:Hide()
				pet_button.name:SetFontObject("GameFontDisable")
				pet_button.petTypeIcon:SetShown(can_battle)
				pet_button.petTypeIcon:SetDesaturated(1)
				pet_button.dragButton:Disable()
				pet_button.isDead:Hide()
				pet_button.stat_icon:Hide()
			end

			if pet_id and pet_id == summoned_pet_id then
				pet_button.dragButton.ActiveTexture:Show()
			else
				pet_button.dragButton.ActiveTexture:Hide()
			end
			pet_button.petID = pet_id
			pet_button.speciesID = species_id
			pet_button.abilityID = _G.PET_BATTLE_PET_TYPE_PASSIVES[pet_type]
			pet_button.index = sorted_pets[index].journal_index
			pet_button.owned = is_owned
			pet_button.canBattle = can_battle
			pet_button:Show()

			--Update Petcard Button
			if _G.PetJournalPetCard.petIndex == sorted_pets[index].journal_index then
				pet_button.selected = true
				pet_button.selectedTexture:Show()
			else
				pet_button.selected = false
				pet_button.selectedTexture:Hide()
			end
		else
			pet_button:Hide()
		end
	end
	local scroll_frame_height = scroll_frame:GetHeight()
	local button_heights = 0

	for button_index = 1, #pet_buttons do
		button_heights = button_heights + COMPANION_BUTTON_HEIGHT

		if button_heights > scroll_frame_height then
			PetListButton_OnLeave(pet_buttons[button_index])
			break
		end
	end
	_G.HybridScrollFrame_Update(scroll_frame, num_pets * COMPANION_BUTTON_HEIGHT, scroll_frame_height)
end


-------------------------------------------------------------------------------
-- Initialization functions.
-------------------------------------------------------------------------------
function addon:OnInitialize()
	db = LibStub("AceDB-3.0"):New("PetTheorySettings", DATABASE_DEFAULTS, true).global

	self:RegisterEvent("ADDON_LOADED")
end


function addon:OnEnable(event_name)
	if _G.IsAddOnLoaded("Blizzard_PetJournal") then
		self:ADDON_LOADED("", "Blizzard_PetJournal")
	else
		self:ScheduleTimer(function()
			_G.UIParentLoadAddOn("Blizzard_PetJournal")
		end, 10)
	end
end


local function InitializeHooks()
	addon:RawHook("PetJournal_UpdatePetList", private.PopulateSortedList, true)

	addon:SecureHook("PetJournal_OnSearchTextChanged", function()
		private.PopulateSortedList()
	end)

	addon:SecureHook("PetJournal_UpdatePetCard", function()
		local frame = _G.PetJournalPetCard

		if not frame.petID then
			return
		end
		local health, max_health, power, speed, rarity = _G.C_PetJournal.GetPetStats(_G.PetJournalPetCard.petID)

		if not rarity then
			return
		end
		local color = _G.ITEM_QUALITY_COLORS[rarity - 1]

		-- No idea why Blizzard hides this if not a captured pet or unable to battle, but I'm undoing it.
		frame.QualityFrame.quality:SetText(_G["BATTLE_PET_BREED_QUALITY" .. rarity])
		frame.QualityFrame.quality:SetVertexColor(color.r, color.g, color.b)
		frame.QualityFrame:Show()
	end)


	addon:SecureHook("PetJournal_UpdatePetLoadOut", function()
		for index = 1, MAX_ACTIVE_PETS do
			local plate = _G.PetJournal.Loadout["Pet" .. index]
			local pet_id, _, _, _, locked = _G.C_PetJournal.GetPetLoadOutInfo(index)

			if not locked and pet_id > 0 then
				local hex = _G.ITEM_QUALITY_COLORS[BATTLEPET_REGISTRY[pet_id].rarity - 1].hex

				plate.name:SetFormattedText("%s%s|r", hex, plate.name:GetText())
			end
		end
	end)


	_G.PetJournal:HookScript("OnHide", function(self)
		for index = 1, #self.listScroll.buttons do
			local button = self.listScroll.buttons[index]
			PetListButton_OnLeave(button)
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button:SetScript("OnDoubleClick", nil)
		end
	end)


	local function ClearInfo_OnHide(self)
		if self.initial_height then
			self:SetHeight(self.initial_height)
			self.initial_height = nil
		end

		-- The FloatingBattlePetTooltip doesn't have an info_line (yet).
		if self.info_line then
			self.info_line:Hide()
		end
	end


	local info_line = _G.PetBattlePrimaryUnitTooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	info_line:SetSize(250, 72)
	info_line:SetJustifyH("LEFT")
	_G.PetBattlePrimaryUnitTooltip.info_line = info_line


	addon:SecureHook("PetBattleUnitTooltip_UpdateForUnit", function(self, pet_owner, pex_index)
		if pet_owner == _G.LE_BATTLE_PET_ALLY then
			return
		end
		local pet_name = _G.C_PetBattles.GetName(pet_owner, pex_index)

		if not pet_name then
			return
		end
		if not self.hooked_hide then
			self:HookScript("OnHide", ClearInfo_OnHide)
			self.hooked_hide = true
		end
		self.info_line:ClearAllPoints()

		if self.SpeedAdvantageIcon and self.SpeedAdvantageIcon:IsVisible() then
			self.info_line:SetPoint("BOTTOMLEFT", self.SpeedAdvantageIcon, "TOPLEFT", 0, -3)
		else
			self.info_line:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 8, -5)
		end
		self.info_line:SetText(BattlePetInfoString(pet_name, known_pets_by_name, unknown_pets_by_name))
		self:SetHeight(self:GetHeight() + self.info_line:GetStringHeight() + 10)
		self.info_line:Show()
	end)


	local info_line = _G.BattlePetTooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	info_line:SetJustifyH("LEFT")
	info_line:SetSize(240, 72)
	info_line:SetJustifyH("LEFT")
	info_line:SetPoint("TOPLEFT", _G.BattlePetTooltip.SpeedTexture, "BOTTOMLEFT", 0, -2)
	info_line:SetPoint("BOTTOMLEFT", _G.BattlePetTooltip, "BOTTOMLEFT")
	_G.BattlePetTooltip.info_line = info_line


	addon:SecureHook("BattlePetTooltipTemplate_SetBattlePet", function(self, data)
		if not self.info_line then
			-- The FloatingBattlePetTooltip doesn't have an info_line (yet).
			return
		end

		if not self.hooked_hide then
			self:HookScript("OnHide", ClearInfo_OnHide)
			self.hooked_hide = true
		end

		if not self.initial_height then
			self.initial_height = self:GetHeight()
		end
		self.info_line:SetText(BattlePetInfoString(data.name, known_pets_by_name, unknown_pets_by_name))
		self:SetHeight(self.initial_height + self.info_line:GetStringHeight() + 10)
		self.info_line:Show()
	end)

	_G.StaticPopupDialogs["BATTLE_PET_RELEASE"].OnShow = function(self)
		self.text:SetText(self.text:GetText():gsub("|cffffd200", _G.ITEM_QUALITY_COLORS[BATTLEPET_REGISTRY[self.data].rarity - 1].hex))
	end
	InitializeHooks = nil
end


local function UpdateZoneData()
	private.zone_name = _G.GetZoneText() or _G.UNKNOWN
	private.real_zone_name = _G.GetRealZoneText() or _G.UNKNOWN
	private.subzone_name = _G.GetSubZoneText() or _G.UNKNOWN

	private.PopulateSortedList()
end


local function InitializeFrames()
	-------------------------------------------------------------------------------
	-- Replace the PetJournalListScrollFrame with something we can manipulate.
	-------------------------------------------------------------------------------
	_G.PetJournalFilterButton:Hide()
	_G.PetJournalFilterButton:ClearAllPoints()

	local filter_dropdown = _G.CreateFrame("Frame", "PetTheory_FilterDropDown", _G.PetJournal, "UIDropDownMenuTemplate")
	_G.UIDropDownMenu_Initialize(filter_dropdown, FilterDropDown_Initialize, "MENU");

	local filter_button = _G.CreateFrame("Button", "PetTheory_FilterButton", _G.PetJournal, "UIMenuButtonStretchTemplate")
	filter_button:SetSize(70, 22)
	filter_button:SetPoint("TOPRIGHT", _G.PetJournalLeftInset, -28, -9)
	filter_button:SetText(_G.FILTERS)
	filter_button.rightArrow:Show()
	filter_button:SetScript("OnClick", function(self)
		_G.PlaySound("igMainMenuOptionCheckBoxOn")
		_G.ToggleDropDownMenu(1, nil, filter_dropdown, "PetTheory_FilterButton", 74, 15)
	end)

	local sort_toggle = _G.CreateFrame("Button", nil, _G.PetJournal)
	sort_toggle:SetSize(24, 24)
	sort_toggle:SetPoint("LEFT", filter_button, "RIGHT", 0, 0)

	sort_toggle:SetScript("OnClick", function(self, button, down)
		db.sort.ascending = not db.sort.ascending
		self:SetTexture()
		private.PopulateSortedList()
	end)

	function sort_toggle:SetTexture()
		if db.sort.ascending then
			self:SetNormalTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollDown-Up]])
			self:SetPushedTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollDown-Down]])
			self:SetDisabledTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollDown-Disabled]])
		else
			self:SetNormalTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollUp-Up]])
			self:SetPushedTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollUp-Down]])
			self:SetDisabledTexture([[Interface\CHATFRAME\UI-ChatIcon-ScrollUp-Disabled]])
		end
	end

	sort_toggle:SetHighlightTexture([[Interface\CHATFRAME\UI-ChatIcon-BlinkHilight]])
	sort_toggle:SetTexture()

	_G.PetJournalListScrollFrame:Hide()
	_G.PetJournalListScrollFrame:ClearAllPoints()

	local scroll_frame = _G.CreateFrame("ScrollFrame", "PetTheory_ScrollFrame", _G.PetJournal, "HybridScrollFrameTemplate")
	scroll_frame:SetPoint("TOPLEFT", _G.PetJournalLeftInset, "TOPLEFT", 3, -36)
	scroll_frame:SetPoint("BOTTOMRIGHT", _G.PetJournalLeftInset, "BOTTOMRIGHT", -2, 5)

	scroll_frame.update = private.UpdatePetList
	addon.scroll_frame = scroll_frame
	_G.PetJournal.listScroll = scroll_frame

	local scroll_bar = _G.CreateFrame("Slider", "PetTheory_ScrollBar", scroll_frame, "HybridScrollBarTrimTemplate")
	scroll_bar:SetPoint("TOPLEFT", scroll_frame, "TOPRIGHT", 4, 20)
	scroll_bar:SetPoint("BOTTOMLEFT", scroll_frame, "BOTTOMRIGHT", 4, 11)

	scroll_bar.trackBG:Show()
	scroll_bar.trackBG:SetVertexColor(0, 0, 0.75)
	scroll_bar.doNotHide = true

	scroll_frame.scrollBar = scroll_bar
	_G.HybridScrollFrame_CreateButtons(scroll_frame, "CompanionListButtonTemplate", 44, 0)

	local pet_count = _G.PetJournal.PetCount
	pet_count:SetWidth(250)
	pet_count:ClearAllPoints()
	pet_count:SetPoint("LEFT", _G.PetJournalSummonButton, "RIGHT", 72, -1)

	pet_count.Label:ClearAllPoints()
	pet_count.Count:ClearAllPoints()

	pet_count.Label:SetPoint("LEFT", 10, 0)
	pet_count.Count:SetPoint("LEFT", pet_count.Label, "RIGHT", 3, 0)

	pet_count.Label:SetFormattedText("%s%s", pet_count.Label:GetText(), _G.HEADER_COLON)

	local unique_count = pet_count:CreateFontString(nil, nil, "GameFontHighlightSmall")
	unique_count:SetPoint("RIGHT", -10, 0)
	pet_count.UniqueCount = unique_count

	local unique_label = pet_count:CreateFontString(nil, nil, "GameFontNormalSmall")
	unique_label:SetPoint("RIGHT", unique_count, "LEFT", -3, 0)
	unique_label:SetFormattedText("%s%s", _G.ITEM_UNIQUE, _G.HEADER_COLON)
	pet_count.UniqueLabel = unique_label

	InitializeFrames = nil
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------
function addon:ADDON_LOADED(event_name, addon_name)
	if addon_name ~= "Blizzard_PetJournal" then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("ZONE_CHANGED", UpdateZoneData)
	self:RegisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneData)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneData)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	InitializeFrames()
	InitializeHooks()

	LPJ:RegisterCallback("PetListUpdated", private.PopulateSortedList)
	UpdateZoneData()
end


function addon:UPDATE_MOUSEOVER_UNIT()
	if not _G.UnitIsWildBattlePet("mouseover") then
		return
	end
	ModifyTooltip(_G.GameTooltip, _G.tonumber(_G.UnitGUID("mouseover"):sub(6, 10), 16), known_pets_by_npc_id, unknown_pets_by_npc_id)
	_G.GameTooltip:Show()
end

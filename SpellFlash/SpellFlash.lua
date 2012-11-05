local MinBuild, OverBuild, Build = 50000, 0, select(4, GetBuildInfo())
if Build < (MinBuild or 0) or ( (OverBuild or 0) > 0 and Build >= OverBuild ) then return end
local AddonName, a = ...
a.AddonName = AddonName
local AddonTitle = select(2, GetAddOnInfo(AddonName))
local PlainAddonTitle = AddonTitle:gsub("|c........", ""):gsub("|r", "")
local L = a.Localize
SpellFlashAddon = {}
local s = SpellFlashAddon
s.config = {}
local GetSpellInfo = SpellFlashCore.GetSpellInfo
local GetItemInfo = SpellFlashCore.GetItemInfo
s.SpellName = SpellFlashCore.SpellName
s.ItemName = SpellFlashCore.ItemName
s.Replace = SpellFlashCore.Replace
s.CopyTable = SpellFlashCore.CopyTable
s.RegisterBigLibTimer = SpellFlashCore.RegisterBigLibTimer
s.RegisterBigLibTimer(a)

function a.print(...)
	print("|cFF00FFFF["..PlainAddonTitle.."]|r", ...)
end

local MELEESPELL = {
	DEATHKNIGHT = 45902--[[Blood Strike]],
	DRUID = 33876--[[Mangle]],
	MONK = 100780--[[Jab]],
	PALADIN = 35395--[[Crusader Strike]],
	ROGUE = 1752--[[Sinister Strike]],
	SHAMAN = 73899--[[Primal Strike]],
	WARRIOR = 78--[[Heroic Strike]],
}

local GLOBALCOOLDOWNSPELL = {
	DEATHKNIGHT = 47541--[[Death Coil]],
	DRUID = 5176--[[Wrath]],
	HUNTER = 883--[[Call Pet 1]],
	MAGE = 44614--[[Frostfire Bolt]],
	MONK = 100780--[[Jab]],
	PALADIN = 7328--[[Redemption]],
	PRIEST = 585--[[Smite]],
	ROGUE = 1752--[[Sinister Strike]],
	SHAMAN = 403--[[Lightning Bolt]],
	WARLOCK = 686--[[Shadow Bolt]],
	WARRIOR = 5308--[[Execute]],
}

local HEALERCLASS = {
	DRUID = "Druid",
	MONK = "Monk",
	PALADIN = "Paladin",
	PRIEST = "Priest",
	SHAMAN = "Shaman",
}

local ALTERNATEFORM = {
	[s.SpellName(33943--[[Flight Form]], 1)] = s.SpellName(40120--[[Swift Flight Form]], 1),
	[s.SpellName(40120--[[Swift Flight Form]], 1)] = s.SpellName(33943--[[Flight Form]], 1),
}

a.ImmunityDebuffs = {
	710--[[Banish]],
	33786--[[Cyclone]],
	--605--[[Mind Control]],
}

a.BreakOnDamage = {
	19503--[[Scatter Shot]],
	1499--[[Freezing Trap]],
	6358--[[Seduction]],
	9484--[[Shackle Undead]],
	6770--[[Sap]],
	118--[[Polymorph]],
	51514--[[Hex]],
	2094--[[Blind]],
	2637--[[Hibernate]],
	76780--[[Bind Elemental]],
	19386--[[Wyvern Sting]],
}

a.Fear = {
	5782--[[Fear]],
	5484--[[Howl of Terror]],
	8122--[[Psychic Scream]],
	1513--[[Scare Beast]],
	10326--[[Turn Evil]],
	5246--[[Intimidating Shout]],
}

a.Root = {
	339--[[Entangling Roots]],
	122--[[Frost Nova]],
	45524--[[Chains of Ice]],
	16979--[[Feral Charge - Bear]],
}

a.MovementImpairing = {
	5116--[[Concussive Shot]],
	2974--[[Wing Clip]],
	13809--[[Ice Trap]],
	116--[[Frostbolt]],
	120--[[Cone of Cold]],
	11113--[[Blast Wave]],
	31589--[[Slow]],
	15407--[[Mind Flay]],
	3408--[[Crippling Poison]],
	26679--[[Deadly Throw]],
	8056--[[Frost Shock]],
	2484--[[Earthbind Totem]],
	18223--[[Curse of Exhaustion]],
	1715--[[Hamstring]],
	12323--[[Piercing Howl]],
}

a.PetActions = {
	Attack = "PET_ACTION_ATTACK",
	Follow = "PET_ACTION_FOLLOW",
	Stay = "PET_ACTION_WAIT",
	["Move To"] = "PET_ACTION_MOVE_TO",
	Aggressive = "PET_MODE_AGGRESSIVE",
	Defensive = "PET_MODE_DEFENSIVE",
	Passive = "PET_MODE_PASSIVE",
	PET_ACTION_ATTACK = "PET_ACTION_ATTACK",
	PET_ACTION_FOLLOW = "PET_ACTION_FOLLOW",
	PET_ACTION_WAIT = "PET_ACTION_WAIT",
	PET_ACTION_MOVE_TO = "PET_ACTION_MOVE_TO",
	PET_MODE_AGGRESSIVE = "PET_MODE_AGGRESSIVE",
	PET_MODE_DEFENSIVE = "PET_MODE_DEFENSIVE",
	PET_MODE_PASSIVE = "PET_MODE_PASSIVE",
	[PET_ACTION_ATTACK or "PET_ACTION_ATTACK"] = "PET_ACTION_ATTACK",
	[PET_ACTION_FOLLOW or "PET_ACTION_FOLLOW"] = "PET_ACTION_FOLLOW",
	[PET_ACTION_WAIT or "PET_ACTION_WAIT"] = "PET_ACTION_WAIT",
	[PET_ACTION_MOVE_TO or "PET_ACTION_MOVE_TO"] = "PET_ACTION_MOVE_TO",
	[PET_MODE_AGGRESSIVE or "PET_MODE_AGGRESSIVE"] = "PET_MODE_AGGRESSIVE",
	[PET_MODE_DEFENSIVE or "PET_MODE_DEFENSIVE"] = "PET_MODE_DEFENSIVE",
	[PET_MODE_PASSIVE or "PET_MODE_PASSIVE"] = "PET_MODE_PASSIVE",
}

-- http://www.wowhead.com/npcs?filter=cr=34;crs=0;crv=270
a.DummyIDNumbers = {
	[1921] = "Combat Dummy",
	[32542] = "Disciple's Training Dummy",
	[25297] = "Drill Dummy",
	[32546] = "Ebon Knight's Training Dummy",
	[17059] = "Hellfire Combat Dummy",
	[17060] = "Hellfire Combat Dummy Small",
	[17578] = "Hellfire Training Dummy",
	[32547] = "Highlord's Nemesis Trainer",
	[32541] = "Initiate's Training Dummy",
	[32545] = "Initiate's Training Dummy",
	[33229] = "Melee Target",
	[19139] = "Nagrand Target Dummy",
	[16211] = "Naxxramas Combat Dummy",
	[42328] = "Practice Dummy",
	[25225] = "Practice Dummy",
	[31146] = "Raider's Training Dummy",
	[18504] = "Silvermoon Practice Dummy",
	[43560] = "Smilin' Timmy Sticks",
	[4952] = "Theramore Combat Dummy",
	[38038] = "Tiki Target",
	[64446] = "Training Dummy",
	[60197] = "Training Dummy",
	[44171] = "Training Dummy",
	[48304] = "Training Dummy",
	[44937] = "Training Dummy",
	[44389] = "Training Dummy",
	[44614] = "Training Dummy",
	[44548] = "Training Dummy",
	[44703] = "Training Dummy",
	[44794] = "Training Dummy",
	[44820] = "Training Dummy",
	[44848] = "Training Dummy",
	[32666] = "Training Dummy",
	[32667] = "Training Dummy",
	[31144] = "Training Dummy",
	[46647] = "Training Dummy",
	[5652] = "Undercity Practice Dummy",
	[32543] = "Veteran's Training Dummy",
}


local DEFAULT_FLASH_SIZE_PERCENT = 240
local DEFAULT_FLASH_BRIGHTNESS_PERCENT = 100
local FLASH_SIZE_PERCENT = DEFAULT_FLASH_SIZE_PERCENT
local FLASH_BRIGHTNESS_PERCENT = DEFAULT_FLASH_BRIGHTNESS_PERCENT
local ENABLE_BLINKING = nil
local DISABLE_MACRO_FLASHING = nil
local SUPPRESS_RANGE_CHECK = nil
local SUPPRESS_SPEED_CHECK = nil
local CLASS = select(2, UnitClass("player"))
local RACE = select(2, UnitRace("player")):upper():gsub("[^A-Z]", ""):gsub("^SCOURGE$", "UNDEAD")
s.L = s.CopyTable(L)
s.UpdatedVariables = {}
local Spam = {}
local OptionsFrame = {}
local SettingsListenerFunctions = {}
local OtherAurasFunctions = {}
local OtherAurasFromSpell = {}
local OtherAurasSpellFromAura = {}
local SPELL_DELAY = {}
local ALL_SPELL_DELAY = {}
local LAST_SPELL_TRAVEL_TIME_START = {}
local LAST_SPELL_TRAVEL_TIME_END = {}
local LAST_SPELL_TRAVEL_TIME = {}
local LAST_UNITID_FOUND = setmetatable({}, {__mode = "k"})
local SPELLCAST = {}
SPELLCAST.player = {}
SPELLCAST.vehicle = {}
local OUTSIDEMELEESPELL = nil
local VARIABLES_CHECKED = nil
local SPELLS = {}
local PET_SPELLS = {}
local TALENTS = {}
local CLASSMODULES = {}
local CLASSMODULES_ADDONNAMES = {}
local GLOBAL_COOLDOWN_SPELL = nil
local CURRENTFORM = nil
local SHOOT = nil
local SERVER = nil
local REALM = nil
local PLAYER = nil
local LOADING = true
local parent = "SpellFlashAddonOptionsFrame"

--[[
s.PRIEST
s.ROGUE
s.PALADIN
s.WARLOCK
s.WARRIOR
s.HUNTER
s.MAGE
s.SHAMAN
s.DRUID
s.DEATHKNIGHT
]]
s[CLASS] = {}

--[[
s.HUMAN
s.DWARF
s.GNOME
s.NIGHTELF
s.BLOODELF
s.ORC
s.UNDEAD
s.TAUREN
s.TROLL
s.DRAENEI
]]
s[RACE] = {}

local function Paste(text, title)
	StaticPopupDialogs[AddonName] = StaticPopupDialogs[AddonName] or {
		text = "%s",
		button2 = CLOSE,
		timeout = 0,
		hasEditBox = true,
		hasWideEditBox = true,
		editBoxWidth = 350,
		whileDead = true,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        OnShow = function(self)
			local editBox = self.wideEditBox or self.editBox
			local button = self.button2
			self:SetWidth(420)
			editBox:SetText(tostring(StaticPopupDialogs[AddonName].editBoxText))
			editBox:SetFocus()
			editBox:HighlightText()
			button:ClearAllPoints()
			button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
		end,
	}
	StaticPopupDialogs[AddonName].editBoxText = text
	StaticPopup_Show(AddonName, title or ( select(2, GetAddOnInfo(AddonName)) ))
end

local function DecodeItemLink(link)
	if type(link) == "string" then
		local id, name = link:match("item:(%d+):.*%[(.*)%]")
		if id then
			return name, tonumber(id)
		end
	end
	return nil
end

local function ItemIDFromItemName(ItemName)
	if type(ItemName) == "string" then
		return ( select(2, DecodeItemLink(select(2, GetItemInfo(ItemName)))) )
	end
	return nil
end

local function ItemSubType(ItemID)
	if ItemID then
		return ( select(7, GetItemInfo(ItemID)) )
	end
	return nil
end

function s.Dummy(unit)
	local Type, ID = s.UnitInfo(unit)
	if Type == "npc" then
		return a.DummyIDNumbers[ID]
	end
	return nil
end

local function VehicleSlot(SpellName)
	if type(SpellName) == "table" then
		for _, SpellName in ipairs(SpellName) do
			if VehicleSlot(SpellName) then
				return true
			end
		end
		return false
	elseif UnitInVehicle("player") then
		local SpellName = s.SpellName(SpellName)
		if SpellName then
			for i = 121, 138 do
				local name = s.SpellName((select(2, GetActionInfo(i))))
				if name and name == SpellName then
					return i
				end
			end
		end
	end
	return nil
end

local function CheckVariables()
	PLAYER = UnitName("player")
	if not PLAYER then
		--Character name not available yet
		return a:SetTimer("CheckVariables", 1, 0, CheckVariables)
	end
	REALM = GetRealmName()
	SERVER = GetCVar("realmList"):lower()
	if not SpellFlashAddonConfig then
		SpellFlashAddonConfig = {}
	end
	if not SpellFlashAddonConfig.SERVER then
		SpellFlashAddonConfig.SERVER = {}
	end
	if not SpellFlashAddonConfig.SERVER[SERVER] then
		SpellFlashAddonConfig.SERVER[SERVER] = {}
	end
	if not SpellFlashAddonConfig.SERVER[SERVER].REALM then
		SpellFlashAddonConfig.SERVER[SERVER].REALM = {}
	end
	if not SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM] then
		SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM] = {}
	end
	if not SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM].PLAYER then
		SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM].PLAYER = {}
	end
	if not SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM].PLAYER[PLAYER] then
		SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM].PLAYER[PLAYER] = {}
	end
	s.config = SpellFlashAddonConfig.SERVER[SERVER].REALM[REALM].PLAYER[PLAYER]
	if not s.config.MODULE then
		s.config.MODULE = {}
	end
	FLASH_SIZE_PERCENT = s.config.flash_size_percent or DEFAULT_FLASH_SIZE_PERCENT
	FLASH_BRIGHTNESS_PERCENT = s.config.flash_brightness_percent or DEFAULT_FLASH_BRIGHTNESS_PERCENT
	DISABLE_MACRO_FLASHING = s.config.disable_macro_flashing
	SUPPRESS_RANGE_CHECK = s.config.suppress_range_check
	SUPPRESS_SPEED_CHECK = s.config.suppress_speed_check
	ENABLE_BLINKING = s.config.enable_blinking
	VARIABLES_CHECKED = 1
end

s.Spam = {} -- Old code left in to indicate that a module has not been updated to use the new format

local function LoadAddOns()
	local Loaded, Error
	for i = 1, GetNumAddOns() do
		local name, title, notes, enabled = GetAddOnInfo(i)
		if enabled and not name:lower():match("^spellflash_templateaddon$") then
			local Metadata = GetAddOnMetadata(name, "X-SpellFlashAddon-LoadWith") or ""
			if Metadata:match("%w") then
				local LoadWith = ","..Metadata:upper():gsub("[^A-Z,%+]", ""):gsub("%+", "++")..","
				if LoadWith:match(",ANY,")
				or LoadWith:match(","..CLASS..",")
				or LoadWith:match(","..RACE..",")
				or LoadWith:match("[,%+]"..CLASS.."%+".."[^,]*".."%+"..RACE.."[,%+]")
				or LoadWith:match("[,%+]"..RACE.."%+".."[^,]*".."%+"..CLASS.."[,%+]")
				or LoadWith:match("[,%+]"..CLASS.."%+".."[^,]*".."%+ANY[,%+]")
				or LoadWith:match("[,%+]"..RACE.."%+".."[^,]*".."%+ANY[,%+]")
				or LoadWith:match("[,%+]ANY%+".."[^,]*".."%+"..CLASS.."[,%+]")
				or LoadWith:match("[,%+]ANY%+".."[^,]*".."%+"..RACE.."[,%+]")
				then
					Loaded = IsAddOnLoaded(i)
					if not Loaded and IsAddOnLoadOnDemand(i) then
						Loaded, Error = LoadAddOn(name)
						if not Loaded then
							a.print(L["Error loading:"], title:gsub("|c........", ""):gsub("|r", "").."   ("..name..")", "("..Error..")")
						end
					end
					if Loaded then
						if s.Spam[name] then -- Old code left in to indicate that a module has not been updated to use the new format
							a.print(L["This module has not been updated to work with the latest expansion:"], title:gsub("|c........", ""):gsub("|r", "").."   ("..name..")")
						elseif LoadWith:match(","..CLASS..",") then
							CLASSMODULES[name] = title.."   "..GRAY_FONT_COLOR_CODE.."("..name..")"..FONT_COLOR_CODE_CLOSE
							CLASSMODULES_ADDONNAMES[CLASSMODULES[name]] = name
						end
					end
				end
			end
		end
	end
	if not s.config.selected_class_module or not CLASSMODULES[s.config.selected_class_module] then
		local name = next(CLASSMODULES)
		if tostring(name):lower():match("^spellflash_x$") then
			local nextname = next(CLASSMODULES, name)
			if nextname then
				name = nextname
			end
		end
		s.config.selected_class_module = name
	end
	local function Initialize(frame, level)
		for _, v in pairs(CLASSMODULES) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.func = function(self)
				UIDropDownMenu_SetSelectedID(frame, self:GetID())
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(_G[parent.."ClassModulesList"], Initialize)
	if next(CLASSMODULES) then
		UIDropDownMenu_SetSelectedName(_G[parent.."ClassModulesList"], CLASSMODULES[s.config.selected_class_module])
		UIDropDownMenu_SetText(_G[parent.."ClassModulesList"], CLASSMODULES[s.config.selected_class_module])
	end
end

local function FindEnemy(unit)
	if s.Enemy(unit) then
		return unit
	end
	local u = unit.."target"
	local jumps = 1
	while UnitExists(u) do
		if s.Enemy(u) then
			return u
		end
		local t = unit
		for _ = 1, jumps do
			if UnitIsUnit(u, t) then
				return unit
			end
			t = t.."target"
		end
		jumps = jumps + 1
		u = u.."target"
	end
	return unit
end

local EnemyTargetFound = "target"

local function RunSpam()
	if not s.config.in_combat_only or s.InCombat() then
		local x = s.UpdatedVariables
		x.ActiveEnemy = s.ActiveEnemy()
		x.Enemy = x.ActiveEnemy or s.Enemy()
		x.NoCC = x.ActiveEnemy or not s.NoDamageCC()
		x.PetAlive = UnitHealth("pet") > 0
		x.PetActiveEnemy = x.PetAlive and s.ActiveEnemy("pettarget")
		x.PetNoCC = not x.PetAlive or x.PetActiveEnemy or not s.BreakOnDamageCC("pettarget")
		x.InInstance, x.InstanceType = IsInInstance()
		x.Lag = select(3, GetNetStats()) / 1000
		x.DoubleLag = x.Lag * 2
		x.ThreatPercent = select(3, UnitDetailedThreatSituation("player", s.UnitSelection())) or 0
		x.EnemyDetected = s.InCombat() or x.Enemy or s.Enemy("mouseover") or s.Enemy("focus") or s.Enemy("enemy")
		x.ShouldPermanentBuff = not UnitIsDeadOrGhost("player") and HasFullControl() and not IsMounted() and not UnitOnTaxi("player") and not UnitInVehicle("player")
		x.ShouldTemporaryBuff = x.ShouldPermanentBuff and ( x.EnemyDetected or not IsResting() )
		if IsModifiedClick("FOCUSCAST") and UnitExists("focus") then
			EnemyTargetFound = FindEnemy("focus")
		else
			EnemyTargetFound = FindEnemy("target")
		end
		for n, v in pairs(Spam) do
			if s.GetModuleFlashable(n) then
				v()
			end
		end
	end
end

local function SetSpam()
	if not s.config.spell_flashing_off then
		for n in pairs(Spam) do
			if s.GetModuleFlashable(n) then
				if not a:IsTimer("RunSpam") then
					a:SetTimer("RunSpam", 0, 0.2, RunSpam)
				end
				return
			end
		end
	end
	a:ClearTimer("RunSpam")
end

local function RegisterOtherAuras()
	OtherAurasFromSpell = a:CreateTable(OtherAurasFromSpell, 1)
	for _, Function in pairs(OtherAurasFunctions) do
		Function()
	end
	OtherAurasSpellFromAura = a:CreateTable(OtherAurasSpellFromAura, 1)
	for Spell, t in pairs(OtherAurasFromSpell) do
		for Aura in pairs(t) do
			if not OtherAurasSpellFromAura[Aura] then
				OtherAurasSpellFromAura[Aura] = a:CreateTable()
			end
			OtherAurasSpellFromAura[Aura][Spell] = 1
		end
	end
end

-- Registers the current Form or Stance
local function RegisterForm()
	local n = GetShapeshiftForm()
	if not n or n == 0 then
		CURRENTFORM = nil
	else
		CURRENTFORM = select(2, GetShapeshiftFormInfo(n))
	end
	SpellFlashCore.debug("Now in "..( CURRENTFORM or "Caster Form" ).."!")
end

local function GetNumSpellBookItems()
	local t = GetNumSpellTabs()
	local n
	while true do
		local name, texture, offset, numSpells = GetSpellTabInfo(t)
		if not name then
			break
		end
		n = offset + numSpells
		t = t + 1
	end
	return n
end

local function RegisterSpells()
	wipe(SPELLS)
	for i = 1, GetNumSpellBookItems() do
		local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		local skillType, spellId = GetSpellBookItemInfo(i, "player")
		if ( skillType == "SPELL" and IsPlayerSpell(spellId) ) or skillType == "FLYOUT" then
			if spellSubName and spellSubName ~= "" then
				spellName = spellName.."("..spellSubName..")"
			end
			SPELLS[spellName] = 1
			SPELLS[s.SpellName(spellId) or spellName] = 1
			SPELLS[spellId or spellName] = 1
			--a.print(BOOKTYPE_SPELL, i, spellName, skillType, spellId)
		end
	end
end

local function RegisterPetSpells()
	wipe(PET_SPELLS)
	local i = 1
	while true do
		local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_PET)
		if not spellName then
			break
		end
		local skillType, spellId = GetSpellBookItemInfo(i, "pet")
		if skillType == "SPELL" or skillType == "FLYOUT" then
			if spellSubName and spellSubName ~= "" then
				spellName = spellName.."("..spellSubName..")"
			end
			PET_SPELLS[spellName] = 1
			PET_SPELLS[s.SpellName(spellId) or spellName] = 1
			PET_SPELLS[spellId or spellName] = 1
			--a.print(BOOKTYPE_PET, i, spellName, spellId)
		end
		i = i + 1
	end
end

local function RegisterTalents()
	for i = 1, GetNumTalents() do
		local name, texture, tier, column, selected = GetTalentInfo(i)
		if name then
			TALENTS[name] = ( selected and 1 ) or nil
		end
	end
end

local function RegisterOutsideMeleeDistanceSpell()
	if not s.HasSpell(MELEESPELL[CLASS]) then
		OUTSIDEMELEESPELL = nil
		for i = 1, GetNumSpellBookItems() do
			local skillType, spellId = GetSpellBookItemInfo(i, "player")
			if skillType == "SPELL" and IsPlayerSpell(spellId) and s.SpellHasRange(spellId) then
				local MinRange, MaxRange = select(8,GetSpellInfo(spellId))
				if MinRange == 5 and MaxRange >= 10 then
					OUTSIDEMELEESPELL = spellId
					break
				end
			end
		end
	end
end

function SpellFlashAddon.OpenToClassCategory()
	local AddonName = CLASSMODULES_ADDONNAMES[UIDropDownMenu_GetText(_G[parent.."ClassModulesList"])]
	if AddonName and OptionsFrame[AddonName] then
		InterfaceOptionsFrame_OpenToCategory(OptionsFrame[AddonName])
	end
end

function SpellFlashAddon.TestFlashSettings()
	local sizepercent = _G[parent.."FlashSizePercent"]:GetNumber()
	if sizepercent > 0 then
		FLASH_SIZE_PERCENT = sizepercent
	else
		FLASH_SIZE_PERCENT = DEFAULT_FLASH_SIZE_PERCENT
	end
	local brightnesspercent = _G[parent.."FlashBrightnessPercent"]:GetNumber()
	if brightnesspercent > 0 and brightnesspercent < 100 then
		FLASH_BRIGHTNESS_PERCENT = brightnesspercent
	else
		FLASH_BRIGHTNESS_PERCENT = DEFAULT_FLASH_BRIGHTNESS_PERCENT
	end
end

local function ResetFlashSettings()
	FLASH_SIZE_PERCENT = s.config.flash_size_percent or DEFAULT_FLASH_SIZE_PERCENT
	FLASH_BRIGHTNESS_PERCENT = s.config.flash_brightness_percent or DEFAULT_FLASH_BRIGHTNESS_PERCENT
end

local function ResetDefaults()
	s.config.spell_flashing_off = nil
	s.config.enable_blinking = nil
	s.config.disable_macro_flashing = nil
	s.config.use_all_class_modules = nil
	s.config.suppress_range_check = nil
	s.config.suppress_speed_check = nil
	s.config.flash_size_percent = nil
	s.config.flash_brightness_percent = nil
	s.config.in_combat_only = nil
	s.config.disable_default_proc_highlighting = nil
	CheckVariables()
	SetSpam()
end

local function LoadOptionsFrameSettings()
	if next(CLASSMODULES) then
		UIDropDownMenu_SetSelectedName(_G[parent.."ClassModulesList"], CLASSMODULES[s.config.selected_class_module])
		UIDropDownMenu_SetText(_G[parent.."ClassModulesList"], CLASSMODULES[s.config.selected_class_module])
	end
	SpellFlashAddonOptionsFrame_SpellFlashing:SetChecked(not s.config.spell_flashing_off)
	_G[parent.."BlinkSpells"]:SetChecked(s.config.enable_blinking)
	_G[parent.."disable_macro_flashing"]:SetChecked(not s.config.disable_macro_flashing)
	_G[parent.."UseAllClassModules"]:SetChecked(s.config.use_all_class_modules)
	_G[parent.."suppress_range_check"]:SetChecked(not s.config.suppress_range_check)
	_G[parent.."suppress_speed_check"]:SetChecked(not s.config.suppress_speed_check)
	_G[parent.."FlashSizePercent"]:SetNumber(s.config.flash_size_percent or DEFAULT_FLASH_SIZE_PERCENT)
	_G[parent.."FlashBrightnessPercent"]:SetNumber(s.config.flash_brightness_percent or DEFAULT_FLASH_BRIGHTNESS_PERCENT)
	_G[parent.."in_combat_only"]:SetChecked(s.config.in_combat_only)
	_G[parent.."disable_default_proc_highlighting"]:SetChecked(not s.config.disable_default_proc_highlighting)
end

local function SaveOptionsFrameSettings()
	if next(CLASSMODULES) then
		s.config.selected_class_module = CLASSMODULES_ADDONNAMES[UIDropDownMenu_GetText(_G[parent.."ClassModulesList"])]
	end
	s.config.spell_flashing_off = not SpellFlashAddonOptionsFrame_SpellFlashing:GetChecked() or nil
	s.config.enable_blinking = not not _G[parent.."BlinkSpells"]:GetChecked() or nil
	s.config.disable_macro_flashing = not _G[parent.."disable_macro_flashing"]:GetChecked() or nil
	s.config.use_all_class_modules = not not _G[parent.."UseAllClassModules"]:GetChecked() or nil
	s.config.suppress_range_check = not _G[parent.."suppress_range_check"]:GetChecked() or nil
	s.config.suppress_speed_check = not _G[parent.."suppress_speed_check"]:GetChecked() or nil
	s.config.in_combat_only = not not _G[parent.."in_combat_only"]:GetChecked() or nil
	s.config.disable_default_proc_highlighting = not _G[parent.."disable_default_proc_highlighting"]:GetChecked() or nil
	local sizepercent = _G[parent.."FlashSizePercent"]:GetNumber()
	if sizepercent > 0 and sizepercent ~= DEFAULT_FLASH_SIZE_PERCENT then
		s.config.flash_size_percent = sizepercent
	else
		s.config.flash_size_percent = nil
	end
	local brightnesspercent = _G[parent.."FlashBrightnessPercent"]:GetNumber()
	if brightnesspercent > 0 and brightnesspercent < 100 then
		s.config.flash_brightness_percent = brightnesspercent
	else
		s.config.flash_brightness_percent = nil
	end
	CheckVariables()
	RegisterOtherAuras()
	for Function in pairs(SettingsListenerFunctions) do
		Function()
	end
	SetSpam()
end

local function LocalizeFontStrings(frame)
	for _, f in next, {frame:GetChildren()} do
		if f:GetObjectType() == "FontString" then
			f:SetText(L[f:GetText()])
		else
			for _, f in next, {f:GetRegions()} do
				if f:GetObjectType() == "FontString" then
					f:SetText(L[f:GetText()])
				end
			end
		end
	end
end

function SpellFlashAddon.OptionsFrame_OnLoad(self)
	
	LocalizeFontStrings(self)
	
	_G[self:GetName().."TitleString"]:SetText(select(2, GetAddOnInfo(AddonName)).." "..GetAddOnMetadata(AddonName, "Version"))
	
	-- Set the name for the Category for the Panel
	self.name = select(2, GetAddOnInfo(AddonName))
	
	-- When the player clicks okay, run this function.
	self.okay = SaveOptionsFrameSettings
	
	-- When the player clicks cancel, run this function.
	self.cancel = ResetFlashSettings
	
	-- This is a function that is called when the player presses the Default Button.
	self.default = ResetDefaults
	
	-- This will run whenever the options frame is loaded or after defaults are loaded.
	self.refresh = LoadOptionsFrameSettings
	
	-- Add the panel to the Interface Options
	InterfaceOptions_AddCategory(self)
	
end


local Event = {}
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
	Event[event](event, ...)
end)

function Event.START_AUTOREPEAT_SPELL()
	SHOOT = 1
end

function Event.STOP_AUTOREPEAT_SPELL()
	SHOOT = nil
end

Event.UPDATE_SHAPESHIFT_FORM = RegisterForm

local function RegisterSpellCast(SpellName, GUID, Modifier, Time, EndTime)
	if GUID and GUID ~= "0x0000000000000000" then
		if not Modifier then
			if LAST_SPELL_TRAVEL_TIME_START[SpellName] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] then
				a:RecycleTable(tremove(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID], 1))
			end
		else
			if not LAST_SPELL_TRAVEL_TIME_START[SpellName] then
				LAST_SPELL_TRAVEL_TIME_START[SpellName] = a:CreateTable()
			end
			if not LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] then
				LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] = a:CreateTable()
			end
			local Timeout = 10
			if Modifier == 3 then
				if LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1][1] then
					LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1][2] = Time
				end
			elseif Modifier == 2 then
				local Table = a:CreateTable()
				tinsert(Table, Time)
				tinsert(Table, Time)
				tinsert(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID], 1, Table)
			else
				Timeout = Timeout + EndTime - Time
				if Modifier == 1 then
					local Table = a:CreateTable()
					tinsert(Table, EndTime)
					tinsert(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID], 1, Table)
				elseif LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1] then
					LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1][1] = EndTime
				end
			end
			if not a:ReplaceTimer(SpellName.."ClearTravelTime"..GUID, Timeout) then a:SetTimer(SpellName.."ClearTravelTime"..GUID, Timeout, 0,
				function()
					if LAST_SPELL_TRAVEL_TIME_START[SpellName] then
						LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] = a:RecycleTable(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID], 1)
					end
				end
			) end
			if Modifier > 1 then
				if not SPELL_DELAY[SpellName] then
					SPELL_DELAY[SpellName] = a:CreateTable()
				end
				SPELL_DELAY[SpellName][GUID] = (SPELL_DELAY[SpellName][GUID] or 0) + 1
				ALL_SPELL_DELAY[SpellName] = (ALL_SPELL_DELAY[SpellName] or 0) + 1
				if not a:ReplaceTimer(SpellName.."ClearSpellDelay"..GUID, Timeout) then a:SetTimer(SpellName.."ClearSpellDelay"..GUID, Timeout, 0,
					function()
						if SPELL_DELAY[SpellName] then
							SPELL_DELAY[SpellName][GUID] = nil
						end
					end
				) end
				if not a:ReplaceTimer(SpellName.."ClearAllSpellDelay", Timeout) then a:SetTimer(SpellName.."ClearAllSpellDelay", Timeout, 0,
					function()
						ALL_SPELL_DELAY[SpellName] = nil
					end
				) end
			end
		end
	end
end

function Event.COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local Time = GetTime()
	local Event = select(2, ...)
	local sourceGUID = select(4, ...)
	local GUID = select(8, ...)
	local SpellName = select(13, ...)
	local EventType = select(15, ...)
	local FromMe
	if sourceGUID == UnitGUID("player") then
		FromMe = "player"
	elseif sourceGUID == UnitGUID("vehicle") then
		FromMe = "vehicle"
	end
	if Event == "SPELL_CAST_SUCCESS" then
		if FromMe then
			RegisterSpellCast(SpellName, GUID, 2, Time)
		end
	elseif Event == "UNIT_DIED" then
		if LAST_SPELL_TRAVEL_TIME[GUID] then
			LAST_SPELL_TRAVEL_TIME[GUID] = a:RecycleTable(LAST_SPELL_TRAVEL_TIME[GUID])
			LAST_SPELL_TRAVEL_TIME_END[GUID] = a:RecycleTable(LAST_SPELL_TRAVEL_TIME_END[GUID])
		end
	elseif EventType == "IMMUNE" and Event ~= "SWING_DAMAGE" and Event ~= "RANGE_DAMAGE" then
		if FromMe or s.HasSpell(SpellName) then
			a:SetTimer(SpellName.."TempImmune"..GUID, 5)
		end
	elseif Event == "SPELL_MISS" or Event == "SPELL_MISSED" or Event == "SPELL_DAMAGE" or Event == "SPELL_HEAL" or Event == "SPELL_AURA_REFRESH" or Event == "SPELL_AURA_APPLIED" or Event == "SPELL_AURA_APPLIED_DOSE" then
		if Event ~= "SPELL_MISS" and Event ~= "SPELL_MISSED" then
			a:ClearTimer(SpellName.."TempImmune"..GUID)
		end
		if FromMe then
			local AURA_CHECK = Event:match("AURA")
			if AURA_CHECK then
				AURA_CHECK = a:ClearTimer(SpellName.."AuraDelay"..GUID)
				if OtherAurasSpellFromAura[SpellName] then
					for SpellName in pairs(OtherAurasSpellFromAura[SpellName]) do
						if a:ClearTimer(SpellName.."AuraDelay"..GUID) then
							AURA_CHECK = 1
						end
					end
				end
				if not AURA_CHECK and SPELL_DELAY[SpellName] and SPELL_DELAY[SpellName][GUID] then
					local Lag = select(3, GetNetStats()) / 1000
					a:SetTimer(SpellName.."HitDelay"..GUID, math.max(1, Lag))
				end
			elseif Event == "SPELL_DAMAGE" or Event == "SPELL_HEAL" then
				AURA_CHECK = a:ClearTimer(SpellName.."HitDelay"..GUID)
				if OtherAurasFromSpell[SpellName] then
					for SpellName in pairs(OtherAurasFromSpell[SpellName]) do
						if a:ClearTimer(SpellName.."HitDelay"..GUID) then
							AURA_CHECK = 1
						end
					end
				end
				if not AURA_CHECK and SPELL_DELAY[SpellName] and SPELL_DELAY[SpellName][GUID] then
					local Lag = select(3, GetNetStats()) / 1000
					a:SetTimer(SpellName.."AuraDelay"..GUID, math.max(1, Lag))
				end
			end
			if not AURA_CHECK then
				if (ALL_SPELL_DELAY[SpellName] or 0) > 0 then
					ALL_SPELL_DELAY[SpellName] = ALL_SPELL_DELAY[SpellName] - 1
				end
				if SPELL_DELAY[SpellName] and SPELL_DELAY[SpellName][GUID] then
					if SPELL_DELAY[SpellName][GUID] > 1 then
						SPELL_DELAY[SpellName][GUID] = SPELL_DELAY[SpellName][GUID] - 1
					else
						SPELL_DELAY[SpellName][GUID] = nil
					end
				end
				if LAST_SPELL_TRAVEL_TIME_START[SpellName] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1] then
					local LastTimeTable = tremove(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID])
					if not LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1] then
						LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] = a:RecycleTable(LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID])
					end
					local LastTime = LastTimeTable[1]
					if Event ~= "SPELL_MISS" and Event ~= "SPELL_MISSED" then
						local TravelTime = math.max(Time - LastTime, 0)
						if not LAST_SPELL_TRAVEL_TIME[GUID] then
							LAST_SPELL_TRAVEL_TIME_END[GUID] = a:CreateTable()
							LAST_SPELL_TRAVEL_TIME[GUID] = a:CreateTable()
						end
						LAST_SPELL_TRAVEL_TIME_END[GUID][SpellName] = Time
						LAST_SPELL_TRAVEL_TIME[GUID][SpellName] = TravelTime
						--a.print("(Actual)", Time - (LastTimeTable[2] or Time), "-", "(Estimate)", Time - (LastTimeTable[1] or Time), "=", (Time - (LastTimeTable[2] or Time)) - (Time - (LastTimeTable[1] or Time)))
					end
					a:RecycleTable(LastTimeTable)
				end
			end
		end
	end
end

function Event.UNIT_SPELLCAST_SENT(event, unit, SpellName, rank, target, ID)
	if SPELLCAST[unit] then
		if ID > 0 then
			local UnitID = s.UnitID(target)
			if UnitID then
				--a.print(GetTime(), event, SpellName, ID)
				SPELLCAST[unit][ID] = UnitGUID(UnitID)
				return
			end
		end
		SPELLCAST[unit][ID] = nil
	end
end

function Event.UNIT_SPELLCAST_START(event, unit, SpellName, rank, ID)
	if SPELLCAST[unit] then
		local GUID = SPELLCAST[unit][ID]
		if GUID then
			--a.print(GetTime(), event, SpellName, ID)
			RegisterSpellCast(SpellName, GUID, 1, GetTime(), ( select(6, UnitCastingInfo(unit)) or 0 ) / 1000)
			SPELLCAST[unit].CURRENT = ID
		end
	end
end

function Event.UNIT_SPELLCAST_DELAYED(event, unit, SpellName, rank, ID)
	if SPELLCAST[unit] then
		if SPELLCAST[unit].CURRENT == ID then
			--a.print(GetTime(), event, SpellName, ID)
			local GUID = SPELLCAST[unit][ID]
			RegisterSpellCast(SpellName, GUID, 0, GetTime(), ( select(6, UnitCastingInfo(unit)) or 0 ) / 1000)
		end
	end
end

function Event.UNIT_SPELLCAST_INTERRUPTED(event, unit, SpellName, rank, ID)
	if SPELLCAST[unit] then
		if not UnitCastingInfo(unit) then
			if SPELLCAST[unit].CURRENT == ID then
				--a.print(GetTime(), event, SpellName, ID)
				SPELLCAST[unit].CURRENT = nil
				local GUID = SPELLCAST[unit][ID]
				RegisterSpellCast(SpellName, GUID)
			end
			SPELLCAST[unit][ID] = nil
		end
	end
end

function Event.UNIT_SPELLCAST_SUCCEEDED(event, unit, SpellName, rank, ID)
	if SPELLCAST[unit] then
		if SPELLCAST[unit].CURRENT == ID then
			--a.print(GetTime(), event, SpellName, ID)
			SPELLCAST[unit].CURRENT = nil
			local GUID = SPELLCAST[unit][ID]
			RegisterSpellCast(SpellName, GUID, 3, GetTime())
		end
		SPELLCAST[unit][ID] = nil
	end
end


local function RegisterAll()
	LAST_SPELL_TRAVEL_TIME = a:CreateTable(LAST_SPELL_TRAVEL_TIME, 1)
	LAST_SPELL_TRAVEL_TIME_END = a:CreateTable(LAST_SPELL_TRAVEL_TIME_END, 1)
	RegisterSpells()
	RegisterPetSpells()
	RegisterTalents()
	RegisterOtherAuras()
	a:SetTimer("RegisterOutsideMeleeDistanceSpell", 0.5, 0, RegisterOutsideMeleeDistanceSpell)
	if not GLOBAL_COOLDOWN_SPELL and s.HasSpell(GLOBALCOOLDOWNSPELL[CLASS]) then
		GLOBAL_COOLDOWN_SPELL = GLOBALCOOLDOWNSPELL[CLASS]
	end
end

local function StartUp()
	LAST_SPELL_TRAVEL_TIME = a:CreateTable(LAST_SPELL_TRAVEL_TIME, 1)
	LAST_SPELL_TRAVEL_TIME_END = a:CreateTable(LAST_SPELL_TRAVEL_TIME_END, 1)
	if LOADING then
		if not a:ReplaceTimer("RegisterFunctions", 2) then a:SetTimer("RegisterFunctions", 2, 0,
			function()
				if LOADING then
					if VARIABLES_CHECKED then
						LoadAddOns()
						RegisterAll()
						RegisterForm()
						SetSpam()
						Event.ACTIONBAR_HIDEGRID = RegisterAll
						Event.LEARNED_SPELL_IN_TAB = RegisterAll
						Event.CHARACTER_POINTS_CHANGED = RegisterAll
						Event.ACTIVE_TALENT_GROUP_CHANGED = RegisterAll
						Event.PLAYER_SPECIALIZATION_CHANGED = RegisterAll
						Event.UPDATE_MACROS = RegisterAll
						Event.PET_BAR_UPDATE = RegisterPetSpells
						Event.PET_TALENT_UPDATE = RegisterPetSpells
						for event in pairs(Event) do
							EventFrame:RegisterEvent(event)
						end
						LOADING = nil
					else
						a:ReplaceTimer("RegisterFunctions", 2)
					end
				end
			end
		) end
	end
end
Event.PLAYER_ENTERING_WORLD = StartUp
Event.PLAYER_ALIVE = StartUp

function Event.ADDON_LOADED(event, Name)
	if Name == AddonName then
		CheckVariables()
	end
end

for event in pairs(Event) do
	EventFrame:RegisterEvent(event)
end



_G["SLASH_"..AddonName.."1"] = "/spellflash"
_G["SLASH_"..AddonName.."2"] = "/sflash"
_G["SLASH_"..AddonName.."3"] = "/sf"
SlashCmdList[AddonName] = function(msg)
	local msg = msg:lower()
	if msg:match("reset") or msg:match("clear") or msg:match("wipe") or msg:match("erase") or msg:match("default") then
		VARIABLES_CHECKED = nil
		SpellFlashAddonConfig = nil
		CheckVariables()
		s.config.selected_class_module = next(CLASSMODULES)
		LoadOptionsFrameSettings()
		RegisterOtherAuras()
		for Function in pairs(SettingsListenerFunctions) do
			Function()
		end
		SetSpam()
		a.print(L["SpellFlash settings have been reset for all players"])
	elseif msg:match("debuff") then
		s.ShowDebuffs()
	elseif msg:match("buff") then
		s.ShowBuffs()
	else
		InterfaceOptionsFrame_OpenToCategory(SpellFlashAddonOptionsFrame)
	end
end

CreateFrame("GameTooltip", "SpellFlashAddon_Tooltip", nil, "GameTooltipTemplate")
SpellFlashAddon_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function Immune(SpellName, unit)
	local SpellName = s.SpellName(SpellName, 1)
	local GUID = UnitGUID(s.UnitSelection(unit))
	return SpellName and SpellName ~= "" and GUID and a:IsTimer(SpellName.."TempImmune"..GUID)
end

local function UnitIsBossUnit(unit)
	for i = 1, 4 do
		if UnitExists("boss"..i) and UnitIsUnit(unit, "boss"..i) then
			return true
		end
	end
	return false
end

local WeaponSlotPosition = {mainhandslot = 1, secondaryhandslot = 4, rangedslot = 7}

local function CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, GiveExpirationTime, GiveApplications, Debuff)
	if type(unit) == "string" then
		local group = string.lower("|"..unit.."|")
		local raid, party = group:match("|raid|"), group:match("|party|")
		if raid or party then
			local all, notself, afk, range, healer, mana = group:match("|all|"), group:match("|notself|"), group:match("|afk|"), group:match("|range|"), group:match("|healer|"), group:match("|mana|")
			local u = "player"
			local r = s.InRaid()
			local p = s.InParty()
			if all then
				if not UnitIsDeadOrGhost(u) then
					if not notself
						and ( not healer or HEALERCLASS[CLASS] )
					then
						if not CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
							if GiveApplications or GiveExpirationTime then
								return 0
							end
							return nil
						end
					end
					if raid and r then
						for i = 1, r do
							u = "raid"..i
							if not UnitIsUnit(u, "player") and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
								and ( not afk or not UnitIsAFK(u) )
								and ( not range or UnitInRange(u) )
								and ( not healer or HEALERCLASS[s.Class(u)] )
								and ( not mana or UnitPowerType(u) == SPELL_POWER_MANA )
							then
								if not CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
									if GiveApplications or GiveExpirationTime then
										return 0
									end
									return nil
								end
							end
						end
					elseif p then
						for i = 1, p do
							u = "party"..i
							if UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
								and ( not afk or not UnitIsAFK(u) )
								and ( not range or UnitInRange(u) )
								and ( not healer or HEALERCLASS[s.Class(u)] )
								and ( not mana or UnitPowerType(u) == SPELL_POWER_MANA )
							then
								if not CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
									if GiveApplications or GiveExpirationTime then
										return 0
									end
									return nil
								end
							end
						end
					end
				end
				return 1
			else
				if not UnitIsDeadOrGhost(u) then
					if not notself
						and ( not healer or HEALERCLASS[CLASS] )
					then
						if CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
							return 1
						end
					end
					if raid and r then
						for i = 1, r do
							u = "raid"..i
							if not UnitIsUnit(u, "player") and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
								and ( not afk or not UnitIsAFK(u) )
								and ( not range or UnitInRange(u) )
								and ( not healer or HEALERCLASS[s.Class(u)] )
								and ( not mana or UnitPowerType(u) == SPELL_POWER_MANA )
							then
								if CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
									return 1
								end
							end
						end
					elseif p then
						for i = 1, p do
							u = "party"..i
							if UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
								and ( not afk or not UnitIsAFK(u) )
								and ( not range or UnitInRange(u) )
								and ( not healer or HEALERCLASS[s.Class(u)] )
								and ( not mana or UnitPowerType(u) == SPELL_POWER_MANA )
							then
								if CheckAura(SpellName, u, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, nil, nil, Debuff) then
									return 1
								end
							end
						end
					end
				end
				if GiveApplications or GiveExpirationTime then
					return 0
				end
				return nil
			end
		end
		if WeaponSlotPosition[unit:lower()] then
			local hasEnchant, Expiration, Charges = select(WeaponSlotPosition[unit:lower()], GetWeaponEnchantInfo())
			if hasEnchant and ( type(DurationRemainingGreaterThan) ~= "number" or DurationRemainingGreaterThan <= 0 or (Expiration or 0) == 0 or Expiration / 1000 > DurationRemainingGreaterThan ) then
				local SpellName = s.SpellName(SpellName, 1)
				if SpellName then
					SpellFlashAddon_Tooltip:ClearLines()
					if SpellFlashAddon_Tooltip:SetInventoryItem("player", (GetInventorySlotInfo(unit))) then
						local regions = select("#", SpellFlashAddon_Tooltip:GetRegions())
						if regions > 0 then
							for i = 1, regions do
								local region = select(i, SpellFlashAddon_Tooltip:GetRegions())
								local text = nil
								if region and region:GetObjectType() == "FontString" then
									text = region:GetText()
								end
								if text and text ~= "" then
									if type(SpellName) == "table" then
										for _, v in ipairs(SpellName) do
											local SpellName = s.SpellName(v, 1)
											if SpellName and text:find(SpellName, nil, true) then
												if GiveApplications then
													if Charges == 0 then
														return 1
													end
													return Charges or 1
												elseif GiveExpirationTime then
													return Expiration / 1000
												end
												return 1
											end
										end
									elseif text:find(SpellName, nil, true) then
										if GiveApplications then
											if Charges == 0 then
												return 1
											end
											return Charges or 1
										elseif GiveExpirationTime then
											return Expiration / 1000
										end
										return 1
									end
								end
							end
						end
					end
				else
					if GiveApplications then
						if Charges == 0 then
							return 1
						end
						return Charges or 1
					elseif GiveExpirationTime then
						return Expiration / 1000
					end
					return 1
				end
			end
			if GiveApplications or GiveExpirationTime then
				return 0
			end
			return nil
		end
	end
	if type(SpellName) == "table" then
		local remaining = 0
		for _, v in ipairs(SpellName) do
			local result = CheckAura(v, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, Type, owner, GiveExpirationTime, GiveApplications, Debuff)
			if result then
				if GiveApplications or GiveExpirationTime then
					if result > remaining then
						remaining = result
					end
				else
					return result
				end
			end
		end
		if GiveApplications or GiveExpirationTime then
			return remaining
		end
		return nil
	end
	local u = s.UnitSelection(unit)
	if UnitExists(u) then
		local d = "HELPFUL"
		if Debuff then
			d = "HARMFUL"
		end
		local m = ""
		local o = owner
		if o and UnitIsUnit(o, "player") then
			m = "|PLAYER"
			o = nil
		end
		local c = ""
		if Castable then
			c = "|RAID"
		end
		local id
		if UseBuffID then
			id = SpellName
		end
		local SpellName = s.SpellName(SpellName, 1)
		if SpellName then
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitAura(u, SpellName, nil, d..m..c)
			if name then
				if not id or id == spellID then
					if ( not Type or Type:lower() == tostring(debuffType):lower() )
					and ( not Stealable or isStealable )
					and ( not GiveExpirationTime or expirationTime ~= 0 )
					and ( not o or ( type(unitCaster) == "string" and unitCaster ~= "" and UnitIsUnit(unitCaster, o) ) )
					and ( type(DurationRemainingGreaterThan) ~= "number" or DurationRemainingGreaterThan <= 0 or (expirationTime or 0) == 0 or expirationTime - GetTime() > DurationRemainingGreaterThan )
					then
						if GiveApplications then
							if count == 0 then
								return 1
							end
							return count or 1
						elseif GiveExpirationTime then
							return expirationTime - GetTime()
						end
						return 1
					end
					id = nil
				end
			else
				id = nil
			end
		end
		if not SpellName or id then
			local i = 1
			local spellID = select(11, UnitAura(u, i, d))
			while spellID do
				if not id or id == spellID then
					local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(u, i, d..m..c)
					if name
					and ( not Type or Type:lower() == tostring(debuffType):lower() )
					and ( not Stealable or isStealable )
					and ( not GiveExpirationTime or expirationTime ~= 0 )
					and ( not o or ( type(unitCaster) == "string" and unitCaster ~= "" and UnitIsUnit(unitCaster, o) ) )
					and ( type(DurationRemainingGreaterThan) ~= "number" or DurationRemainingGreaterThan <= 0 or (expirationTime or 0) == 0 or expirationTime - GetTime() > DurationRemainingGreaterThan )
					then
						if GiveApplications then
							if count == 0 then
								return 1
							end
							return count or 1
						elseif GiveExpirationTime then
							return expirationTime - GetTime()
						end
						return 1
					end
					if id == spellID then
						break
					end
				end
				i = i + 1
				spellID = select(11, UnitAura(u, i, d))
			end
		end
	end
	if GiveApplications or GiveExpirationTime then
		return 0
	end
	return nil
end

local function Hook_ActionButton_ShowOverlayGlow(self)
	if s.config.disable_default_proc_highlighting and self.overlay then
		if self.overlay.animIn:IsPlaying() then
			self.overlay.animIn:Stop()
		end
		ActionButton_OverlayGlowAnimOutFinished(self.overlay.animOut)
	end
end
hooksecurefunc("ActionButton_ShowOverlayGlow", Hook_ActionButton_ShowOverlayGlow)

-- This is used for testing purposes only
function SpellFlashAddon.ShowBuffs(unit, Debuff)
	local unit = unit
	if not unit then
		if UnitExists("target") then
			unit = "target"
		else
			unit = "player"
		end
	end
	local Debuff = Debuff
	local msg
	if Debuff then
		Debuff = "HARMFUL"
		msg = UnitName(unit).."'s Debuff Slot"
	else
		Debuff = "HELPFUL"
		msg = UnitName(unit).."'s Buff Slot"
	end
	local c = 1
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster = UnitAura(unit, c, Debuff)
	if name then
		while name do
			local caster = ""
			if type(unitCaster) == "string" and unitCaster ~= "" and UnitExists(unitCaster) then
				caster = "     From: \""..unitCaster.."\" = "..UnitName(unitCaster)
			end
			a.print(msg.." "..c..": "..name..caster)
			c = c + 1
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster = UnitAura(unit, c, Debuff)
		end
	else
		a.print("All "..msg.."'s are empty.")
	end
end

-- This is used for testing purposes only
function SpellFlashAddon.ShowDebuffs(unit)
	SpellFlashAddon.ShowBuffs(unit, 1)
end

-- This is a test function
function SpellFlashAddon.ShowOffHandType()
	local Type = ItemSubType(GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot")))
	if Type then
		Paste(Type, "Localized Off Hand Type")
	else
		message("You do not have an off hand item equipped.")
	end
end




function s.RegisterModuleSpamFunction(AddonName, Function)
	Spam[AddonName] = Function
end

function s.RegisterModuleOptionsWindow(AddonName, Frame)
	OptionsFrame[AddonName] = Frame
end

function s.GetModuleFlashable(AddonName)
	if VARIABLES_CHECKED and not s.config.spell_flashing_off and type(AddonName) == "string" and type(Spam[AddonName]) == "function" and not s.GetModuleConfig(AddonName, "spell_flashing_off") and ( not CLASSMODULES[AddonName] or s.config.selected_class_module == AddonName or s.config.use_all_class_modules ) then
		return true
	end
	return false
end

function s.GetModuleConfig(AddonName, config)
	if VARIABLES_CHECKED and type(AddonName) == "string" and type(config) == "string" and s.config.MODULE[AddonName] then
		return s.config.MODULE[AddonName][config]
	end
	return nil
end

function s.SetModuleConfig(AddonName, config, value)
	if VARIABLES_CHECKED and type(AddonName) == "string" and type(config) == "string" then
		if value then
			if not s.config.MODULE[AddonName] then
				s.config.MODULE[AddonName] = a:CreateTable()
			end
			if s.config.MODULE[AddonName][config] ~= value then
				s.config.MODULE[AddonName][config] = value
				if config == "spell_flashing_off" and a:IsTimer("RunSpam") then
					SetSpam()
				end
			end
		elseif s.config.MODULE[AddonName] and s.config.MODULE[AddonName][config] then
			s.config.MODULE[AddonName][config] = nil
			if config == "spell_flashing_off" and not a:IsTimer("RunSpam") then
				SetSpam()
			end
		end
	end
end

function s.ClearAllModuleConfigs(AddonName)
	if VARIABLES_CHECKED and type(AddonName) == "string" and s.config.MODULE[AddonName] then
		wipe(s.config.MODULE[AddonName])
		if not a:IsTimer("RunSpam") then
			SetSpam()
		end
	end
end

function s.If(Argument, True, False)
	if Argument then
		return True
	end
	return False
end

local ModuleEvents = {}

function s.RegisterModuleEvent(AddonName, Event, Function)
	if not ModuleEvents[AddonName] then
		ModuleEvents[AddonName] = a:CreateTable()
		ModuleEvents[AddonName].EventFrame = CreateFrame("Frame")
		ModuleEvents[AddonName].EventFrame.AddonName = AddonName
		ModuleEvents[AddonName].EventFrame.Events = a:CreateTable()
		ModuleEvents[AddonName].EventFrame:SetScript("OnEvent", function(self, event, ...)
			if not Spam[self.AddonName] or s.GetModuleFlashable(self.AddonName) then
				self.Events[event](event, ...)
			end
		end)
	end
	ModuleEvents[AddonName].EventFrame.Events[Event] = Function
	ModuleEvents[AddonName].EventFrame:RegisterEvent(Event)
end

function s.UnregisterModuleEvent(AddonName, Event)
	if ModuleEvents[AddonName] then
		ModuleEvents[AddonName].EventFrame:UnregisterEvent(Event)
		ModuleEvents[AddonName].EventFrame.Events[Event] = nil
	end
end

function s.RegisterOtherAurasFunction(Function, AddonName)
	if type(Function) == "function" then
		if AddonName then
			OtherAurasFunctions[Function] = function()
				if s.GetModuleFlashable(AddonName) then
					Function()
				end
			end
		else
			OtherAurasFunctions[Function] = Function
		end
	end
end

function s.SetOtherAuras(Spell, Aura, Delete)
	local Spell = s.SpellName(Spell, 1)
	if Spell then
		local Aura = s.SpellName(Aura, 1)
		if Aura then
			if Delete then
				if OtherAurasFromSpell[Spell] then
					OtherAurasFromSpell[Spell][Aura] = nil
					if next(OtherAurasFromSpell[Spell]) == nil then
						OtherAurasFromSpell[Spell] = nil
					end
				end
			else
				if not OtherAurasFromSpell[Spell] then
					OtherAurasFromSpell[Spell] = a:CreateTable()
				end
				OtherAurasFromSpell[Spell][Aura] = 1
			end
		end
	end
end

function s.AddSettingsListener(Function)
	if type(Function) == "function" then
		SettingsListenerFunctions[Function] = true
	end
end

local function GetSpellDelay(SpellName, unit, any)
	local count = 0
	if type(SpellName) == "table" then
		for _, value in ipairs(SpellName) do
			count = count + (GetSpellDelay(value, unit) or 0)
			if any and count > 0 then
				return count
			end
		end
	else
		local SpellName = s.SpellName(SpellName, 1)
		if SpellName then
			if OtherAurasSpellFromAura[SpellName] then
				for spell in pairs(OtherAurasSpellFromAura[SpellName]) do
					if spell ~= SpellName then
						if unit == "all" then
							count = count + (ALL_SPELL_DELAY[spell] or 0)
						else
							local GUID = UnitGUID(unit)
							if GUID and SPELL_DELAY[spell] then
								count = count + (SPELL_DELAY[spell][GUID] or 0)
							end
						end
					end
				end
			end
			if unit == "all" then
					count = count + (ALL_SPELL_DELAY[SpellName] or 0)
			else
				local GUID = UnitGUID(unit)
				if GUID and SPELL_DELAY[SpellName] then
					count = count + (SPELL_DELAY[SpellName][GUID] or 0)
				end
			end
		end
	end
	if count > 0 then
		return count
	end
	return nil
end

function s.SpellDelay(SpellName, unit, any)
	local unit = s.UnitSelection(unit):lower()
	return GetSpellDelay(SpellName, unit, any)
end

function GetAuraDelay(SpellName, GUID)
	if type(SpellName) == "table" then
		for _, SpellName in ipairs(SpellName) do
			if GetAuraDelay(SpellName, GUID) then
				return 1
			end
		end
		return nil
	end
	local SpellName = s.SpellName(SpellName, 1)
	if SpellName then
		if a:IsTimer(SpellName.."AuraDelay"..GUID) then
			return 1
		elseif OtherAurasSpellFromAura[SpellName] then
			for SpellName in pairs(OtherAurasSpellFromAura[SpellName]) do
				if a:IsTimer(SpellName.."AuraDelay"..GUID) then
					return 1
				end
			end
		end
	end
	return nil
end

function s.AuraDelay(SpellName, unit)
	local unit = s.UnitSelection(unit)
	local GUID = UnitGUID(unit)
	if GUID then
		return GetAuraDelay(SpellName, GUID)
	end
	return nil
end

function s.SpellOrAuraDelay(SpellName, unit, any)
	local count = 0
	if s.AuraDelay(SpellName, unit) then
		if any then
			return 1
		end
		count = 1
	end
	count = count + (s.SpellDelay(SpellName, unit, any) or 0)
	if count > 0 then
		return count
	end
	return nil
end

function s.AuraCastingOrChanneling(SpellName, unit)
	if type(SpellName) == "table" then
		for _, value in ipairs(SpellName) do
			if s.AuraCastingOrChanneling(value, unit) then
				return 1
			end
		end
	else
		local SpellName = s.SpellName(SpellName, 1)
		if SpellName then
			local Spell = s.CastingOrChannelingName(nil, unit, nil, 1)
			if SpellName == Spell or ( OtherAurasFromSpell[Spell] and OtherAurasFromSpell[Spell][SpellName] ) then
				return 1
			end
		end
	end
	return nil
end

local UnitTypesTable = {["0"] = "player", ["8"] = "player", ["4"] = "pet", ["3"] = "npc", ["5"] = "vehicle"}
local UnitIDPosition = {player = {6}, pet = {6, 10}, npc = {7, 10}, vehicle = {7, 10}, unknown = {7, 10}}
function s.GUIDInfo(GUID)
	if type(GUID) == "string" and GUID ~= "" then
		local Type = UnitTypesTable[GUID:sub(5, 5)] or "unknown"
		return Type, tonumber(GUID:sub(unpack(UnitIDPosition[Type])), 16)
	end
	return nil
end

function s.UnitInfo(unit)
	return s.GUIDInfo(UnitGUID(s.UnitSelection(unit)))
end

function s.UnitSelection(unit)
	if type(unit) == "string" then
		if unit:lower() == "enemy" then
			return EnemyTargetFound
		else
			return unit
		end
	elseif IsModifiedClick("FOCUSCAST") and UnitExists("focus") then
		return "focus"
	end
	return "target"
end

function s.Form(form)
	local form = s.SpellName(form, 1)
	if form and CURRENTFORM then
		if form == CURRENTFORM or ALTERNATEFORM[form] == CURRENTFORM then
			return CURRENTFORM
		end
		return nil
	end
	return CURRENTFORM
end

function s.HasTalent(TalentName)
	local TalentName = s.SpellName(TalentName, 1)
	return TalentName and TALENTS[TalentName]
end

function s.TalentRank(TalentName)
	return s.HasTalent(TalentName) or 0
end

function s.Spec(SpecializationNumber)
	if SpecializationNumber then
		local spec = GetSpecialization() or 0
		if SpecializationNumber == spec then
			return spec
		end
		return nil
	end
	return GetSpecialization()
end
s.TalentMastery = s.Spec

-- This also works for pet spells.
function s.HasSpell(SpellName)
	if type(SpellName) == "number" and IsPlayerSpell(SpellName) then
		return 1
	end
	local SpellName = s.SpellName(SpellName) or SpellName
	if SpellName and ( SPELLS[SpellName] or PET_SPELLS[SpellName] or ( type(SpellName) == "string" and SpellName ~= "" and GetSpellInfo(SpellName) ) ) then
		return 1
	end
	return nil
end

function s.HasItem(ItemName)
	local ItemName = s.ItemName(ItemName)
	return type(ItemName) == "string" and ItemName ~= "" and GetItemCount(ItemName) > 0
end


function s.SpellCooldown(SpellName)
	if SpellName then
		local start, duration = GetSpellCooldown(SpellName)
		local TimeLeft = (start or 0) + (duration or 0) - GetTime()
		if TimeLeft > 0 then
			return TimeLeft, duration
		end
	else
		return nil
	end
	return 0, 0
end

function s.ItemCooldown(ItemName)
	if ItemName then
		local ItemID = ItemName
		if type(ItemID) ~= "number" then
			ItemID = ItemIDFromItemName(ItemName)
		end
		if ItemID then
			local start, duration = GetItemCooldown(ItemID)
			local TimeLeft = (start or 0) + (duration or 0) - GetTime()
			if TimeLeft > 0 then
				return TimeLeft, duration
			end
		end
	end
	return 0, 0
end

function s.ActionCooldown(ActionID)
	if type(ActionID) == "number" then
		local start, duration = GetActionCooldown(ActionID)
		local TimeLeft = (start or 0) + (duration or 0) - GetTime()
		if TimeLeft > 0 then
			return TimeLeft, duration
		end
	else
		return nil
	end
	return 0, 0
end

function s.PetActionCooldown(PetActionID)
	if type(PetActionID) == "number" then
		local start, duration = GetPetActionCooldown(PetActionID)
		local TimeLeft = (start or 0) + (duration or 0) - GetTime()
		if TimeLeft > 0 then
			return TimeLeft, duration
		end
	else
		return nil
	end
	return 0, 0
end

function s.GlobalCooldown()
	return s.SpellCooldown(GLOBAL_COOLDOWN_SPELL)
end

function s.Autocast(SpellName)
	local SpellName = s.SpellName(SpellName)
	if SpellName then
		return not not ( select(2, GetSpellAutocast(SpellName)) )
	end
	return false
end

function s.CastTime(SpellName)
	if SpellName then
		local castTime = select(7, GetSpellInfo(SpellName)) or 0
		if castTime > 0 then
			return castTime / 1000
		end
	end
	return 0
end

function s.SpellCost(SpellName, PowerType)
	if SpellName then
		local name, rank, icon, cost, isFunnel, powerType = GetSpellInfo(SpellName)
		if not PowerType or PowerType == powerType then
			return cost or 0
		end
	end
	return 0
end


function s.HasGlyph(GlyphName)
	local GlyphName = s.SpellName(GlyphName, 1)
	if GlyphName then
		for i=1,GetNumGlyphSockets() do
			if s.SpellName((select(4, GetGlyphSocketInfo(i))), 1) == GlyphName then
				return true
			end
		end
	end
	return false
end

function s.MeleeDistance(unit)
	if s.HasSpell(MELEESPELL[CLASS]) then
		return s.SpellInRange(MELEESPELL[CLASS], unit)
	end
	return CheckInteractDistance(s.UnitSelection(unit), 3) and ( not OUTSIDEMELEESPELL or not s.SpellInRange(OUTSIDEMELEESPELL, unit) )
end

function s.Moving(unit)
	return GetUnitSpeed(s.UnitSelection(unit)) > 0
end

--Example: s.Class("target", "Death Knight")
--The example above will return true if your target is a Death Knight.
--This function has been made so that english class names must be used with this function even if you are not using an english game client.
--Spaces are allowed in the class name and the class name may also be in upper or lower case when using this function.
function s.Class(unit, class)
	local unit = s.UnitSelection(unit)
	if s.Player(unit) then
		local C = select(2, UnitClass(unit))
		if type(class) == "table" then
			for _, v in ipairs(class) do
				if tostring(v):upper():gsub("[^A-Z]", "") == C then
					return C
				end
			end
		elseif type(class) ~= "string" or class:upper():gsub("[^A-Z]", "") == C then
			return C
		end
	end
	return nil
end

--Example: s.Race("target", "Night Elf")
--The example above will return true if your target is a Night Elf.
--This function has been made so that english race names must be used with this function even if you are not using an english game client.
--Spaces are allowed in the race name and the race name may also be in upper or lower case when using this function.
function s.Race(unit, race)
	local unit = s.UnitSelection(unit)
	if s.Player(unit) then
		local R = select(2, UnitRace(unit)):upper():gsub("[^A-Z]", ""):gsub("^SCOURGE$", "UNDEAD")
		if type(race) == "table" then
			for _, v in ipairs(race) do
				if tostring(v):upper():gsub("[^A-Z]", ""):gsub("^SCOURGE$", "UNDEAD") == R then
					return R
				end
			end
		elseif type(race) ~= "string" or race:upper():gsub("[^A-Z]", ""):gsub("^SCOURGE$", "UNDEAD") == R then
			return R
		end
	end
	return nil
end

function s.SpellInRange(SpellName, unit)
	local unit = s.UnitSelection(unit)
	if type(SpellName) == "table" then
		for _, v in ipairs(SpellName) do
			if s.SpellInRange(v, unit) then
				return 1
			end
		end
		return nil
	end
	local SpellName = s.SpellName(SpellName)
	if SpellName and IsSpellInRange(SpellName, unit) == 1 then
		return 1
	end
	return nil
end


function s.SpellHasRange(SpellName)
	if type(SpellName) == "table" then
		for _, v in ipairs(SpellName) do
			if s.SpellHasRange(v) then
				return 1
			end
		end
		return nil
	end
	local SpellName = s.SpellName(SpellName)
	if SpellName and SpellHasRange(SpellName) then
		return 1
	end
	return nil
end


function s.UsableSpell(SpellName)
	if type(SpellName) == "table" then
		for _, v in ipairs(SpellName) do
			if s.UsableSpell(v) then
				return 1
			end
		end
		return nil
	end
	if not SpellName then
		return nil
	end
	return IsUsableSpell(SpellName)
end


function s.CurrentSpell(SpellName)
	if type(SpellName) == "table" then
		for _, v in ipairs(SpellName) do
			if s.CurrentSpell(v) then
				return 1
			end
		end
		return false
	end
	local SpellName = s.SpellName(SpellName)
	if SpellName and IsCurrentSpell(SpellName) then
		return 1
	end
	return nil
end


function s.CurrentItem(ItemName)
	if type(ItemName) == "table" then
		for _, v in ipairs(ItemName) do
			if s.CurrentItem(v) then
				return 1
			end
		end
		return false
	end
	if ItemName and IsCurrentItem(ItemName) then
		return 1
	end
	return nil
end


function s.CurrentVehicle(VehicleSpellName)
	if type(VehicleSpellName) == "table" then
		for _, v in ipairs(VehicleSpellName) do
			if s.CurrentVehicle(v) then
				return 1
			end
		end
		return false
	end
	local slot = VehicleSlot(VehicleSpellName)
	if slot and IsCurrentAction(slot) then
		return 1
	end
	return nil
end

function s.Casting(SpellName, unit, interruptible, NoSubName)
	local name, subtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(s.UnitSelection(unit))
	if name and ( not interruptible or not notInterruptible ) then
		if not SpellName then
			return (endTime / 1000) - GetTime()
		end
		if not NoSubName and subtext and subtext ~= "" then
			name = name.."("..subtext..")"
		end
		if type(SpellName) == "table" then
			for _, SpellName in ipairs(SpellName) do
				if ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
					return (endTime / 1000) - GetTime()
				end
			end
		elseif ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
			return (endTime / 1000) - GetTime()
		end
	end
	return nil
end

function s.Channeling(SpellName, unit, interruptible, NoSubName)
	local name, subtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(s.UnitSelection(unit))
	if name and ( not interruptible or not notInterruptible ) then
		if not SpellName then
			return (endTime / 1000) - GetTime()
		end
		if not NoSubName and subtext and subtext ~= "" then
			name = name.."("..subtext..")"
		end
		if type(SpellName) == "table" then
			for _, SpellName in ipairs(SpellName) do
				if ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
					return (endTime / 1000) - GetTime()
				end
			end
		elseif ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
			return (endTime / 1000) - GetTime()
		end
	end
	return nil
end

function s.CastingOrChanneling(SpellName, unit, interruptible, NoSubName)
	return s.Casting(SpellName, unit, interruptible, NoSubName) or s.Channeling(SpellName, unit, interruptible, NoSubName)
end

function s.GetCasting(SpellName, unit, interruptible, NoSubName)
	return s.Casting(SpellName, unit, interruptible, NoSubName) or 0
end

function s.GetChanneling(SpellName, unit, interruptible, NoSubName)
	return s.Channeling(SpellName, unit, interruptible, NoSubName) or 0
end

function s.GetCastingOrChanneling(SpellName, unit, interruptible, NoSubName)
	return s.CastingOrChanneling(SpellName, unit, interruptible, NoSubName) or 0
end

function s.CastingName(SpellName, unit, interruptible, NoSubName)
	local name, subtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(s.UnitSelection(unit))
	if name and ( not interruptible or not notInterruptible ) then
		if not NoSubName and subtext and subtext ~= "" then
			name = name.."("..subtext..")"
		end
		if not SpellName then
			return name
		end
		if type(SpellName) == "table" then
			for _, SpellName in ipairs(SpellName) do
				if ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
					return name
				end
			end
		elseif ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
			return name
		end
	end
	return nil
end

function s.ChannelingName(SpellName, unit, interruptible, NoSubName)
	local name, subtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(s.UnitSelection(unit))
	if name and ( not interruptible or not notInterruptible ) then
		if not NoSubName and subtext and subtext ~= "" then
			name = name.."("..subtext..")"
		end
		if not SpellName then
			return name
		end
		if type(SpellName) == "table" then
			for _, SpellName in ipairs(SpellName) do
				if ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
					return name
				end
			end
		elseif ( s.SpellName(SpellName, NoSubName) or SpellName ) == name then
			return name
		end
	end
	return nil
end

function s.CastingOrChannelingName(SpellName, unit, interruptible, NoSubName)
	return s.CastingName(SpellName, unit, interruptible, NoSubName) or s.ChannelingName(SpellName, unit, interruptible, NoSubName)
end

s.InCombat = InCombatLockdown

function s.InRaid()
	if IsInRaid() then
		local members = GetNumGroupMembers()
		if members > 1 then
			return members
		end
	end
	return nil
end

function s.InParty()
	local members = GetNumSubgroupMembers()
	if members > 0 then
		return members
	end
	return nil
end

function s.InGroup()
	local members = GetNumGroupMembers()
	if members > 1 then
		return members
	end
	return nil
end
s.InRaidOrParty = s.InGroup

function s.Health(unit)
	return UnitHealth(s.UnitSelection(unit)) or 0
end

function s.MaxHealth(unit)
	return UnitHealthMax(s.UnitSelection(unit)) or 0
end


local function UnitIDTargetOfTarget(unit, name)
	local u = unit.."target"
	local jumps = 1
	while UnitExists(u) do
		if UnitName(u) == name then
			return u
		end
		local t = unit
		for _ = 1, jumps do
			if UnitIsUnit(u, t) then
				return nil
			end
			t = t.."target"
		end
		jumps = jumps + 1
		u = u.."target"
	end
	return nil
end

local TargetFirstUnitIDs = {"target", "focus", "mouseover", "pet", "vehicle"}
local FocusFirstUnitIDs = {"focus", "target", "mouseover", "pet", "vehicle"}

local function CheckUnitNameForID(unit, name, round)
	if round == 2 then
		local unit = UnitIDTargetOfTarget(unit, name)
		if unit then
			LAST_UNITID_FOUND[name] = unit
			return unit
		end
	elseif UnitName(unit) == name then
		LAST_UNITID_FOUND[name] = unit
		return unit
	end
	return nil
end

function s.UnitID(name)
	if type(name) == "string" and name ~= "" then
		local last = LAST_UNITID_FOUND[name]
		if last then
			if UnitName(last) == name then
				return last
			else
				LAST_UNITID_FOUND[name] = nil
			end
		end
		if UnitExists(name) then
			return name
		end
		local t
		if IsModifiedClick("FOCUSCAST") and UnitExists("focus") then
			t = FocusFirstUnitIDs
		else
			t = TargetFirstUnitIDs
		end
		for round = 1, 2 do
			for _, u in ipairs(t) do
				local unit = CheckUnitNameForID(u, name, round)
				if unit then return unit end
			end
			if UnitExists("boss1") then
				for i = 1, 4 do
					local unit = CheckUnitNameForID("boss"..i, name, round)
					if unit then return unit end
				end
			end
			if IsActiveBattlefieldArena() then
				for i = 1, 5 do
					local unit = CheckUnitNameForID("arena"..i, name, round)
					if unit then return unit end
				end
				for i = 1, 5 do
					local unit = CheckUnitNameForID("arenapet"..i, name, round)
					if unit then return unit end
				end
			end
			local r = s.InRaid()
			if r then
				if round == 2 then
					for i = 1, r do
						local unit = CheckUnitNameForID("raid"..i, name, round)
						if unit then return unit end
					end
				end
				for i = 1, r do
					local unit = CheckUnitNameForID("raidpet"..i, name, round)
					if unit then return unit end
				end
			else
				local p = s.InParty()
				if p then
					if round == 2 then
						for i = 1, p do
							local unit = CheckUnitNameForID("party"..i, name, round)
							if unit then return unit end
						end
					end
					for i = 1, p do
						local unit = CheckUnitNameForID("partypet"..i, name, round)
						if unit then return unit end
					end
				end
			end
		end
	end
	return nil
end

function s.SpellTravelStartTime(SpellName, unit)
	local SpellName = s.SpellName(SpellName, 1)
	if SpellName then
		if unit and unit:lower() == "all" then
			if LAST_SPELL_TRAVEL_TIME_START[SpellName] and next(LAST_SPELL_TRAVEL_TIME_START[SpellName]) then
				return LAST_SPELL_TRAVEL_TIME_START[SpellName]
			end
		else
			local GUID = UnitGUID(s.UnitSelection(unit))
			if GUID and LAST_SPELL_TRAVEL_TIME_START[SpellName] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID] and LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID][1] then
				return LAST_SPELL_TRAVEL_TIME_START[SpellName][GUID]
			end
		end
	end
	return nil
end

function s.LastSpellTravelTime(SpellName, unit)
	local GUID = UnitGUID(s.UnitSelection(unit))
	local SpellName = s.SpellName(SpellName, 1)
	if GUID and SpellName and LAST_SPELL_TRAVEL_TIME[GUID] then
		return LAST_SPELL_TRAVEL_TIME[GUID][SpellName], LAST_SPELL_TRAVEL_TIME_END[GUID][SpellName]
	end
	return nil
end

local LastPrimaryThreatTargetFound = {}

function s.GetPrimaryThreatTarget(unit)
	local unit = s.UnitSelection(unit)
	if type(unit) == "string" and UnitExists(unit) and UnitAffectingCombat(unit) and not UnitPlayerControlled(unit) then
		if LastPrimaryThreatTargetFound[unit] and UnitExists(LastPrimaryThreatTargetFound[unit]) then
			if UnitDetailedThreatSituation(LastPrimaryThreatTargetFound[unit], unit) then
				return LastPrimaryThreatTargetFound[unit]
			else
				LastPrimaryThreatTargetFound[unit] = nil
			end
		end
		if UnitExists("targettarget") and UnitDetailedThreatSituation("targettarget", unit) then
			LastPrimaryThreatTargetFound[unit] = "targettarget"
			return "targettarget"
		elseif UnitExists("player") and UnitDetailedThreatSituation("player", unit) then
			LastPrimaryThreatTargetFound[unit] = "player"
			return "player"
		elseif UnitExists("pet") and UnitDetailedThreatSituation("pet", unit) then
			LastPrimaryThreatTargetFound[unit] = "pet"
			return "pet"
		end
		local r = s.InRaid()
		if r then
			for i = 1, r do
				local u = "raid"..i
				if UnitExists(u) and UnitDetailedThreatSituation(u, unit) then
					LastPrimaryThreatTargetFound[unit] = u
					return u
				end
			end
			for i = 1, r do
				local u = "raidpet"..i
				if UnitExists(u) and UnitDetailedThreatSituation(u, unit) then
					LastPrimaryThreatTargetFound[unit] = u
					return u
				end
			end
		else
			local p = s.InParty()
			if p then
				for i = 1, p do
					local u = "party"..i
					if UnitExists(u) and UnitDetailedThreatSituation(u, unit) then
						LastPrimaryThreatTargetFound[unit] = u
						return u
					end
				end
				for i = 1, p do
					local u = "partypet"..i
					if UnitExists(u) and UnitDetailedThreatSituation(u, unit) then
						LastPrimaryThreatTargetFound[unit] = u
						return u
					end
				end
			end
		end
	end
	return nil
end

function s.HealthPercent(unit)
	if type(unit) == "string" then
		local group = string.lower("|"..unit.."|")
		local raid, party = group:match("|raid|"), group:match("|party|")
		if raid or party then
			local notself, afk, range, healer, notfull, average = group:match("|notself|"), group:match("|afk|"), group:match("|range|"), group:match("|healer|"), group:match("|notfull|"), group:match("|average|")
			local u = "player"
			local remaining = 0
			local counted = 0
			local result
			if not UnitIsDeadOrGhost(u) then
				if not notself
					and ( not healer or HEALERCLASS[CLASS] )
				then
					local Max = s.MaxHealth(u)
					if Max > 0 then
						result = ( s.Health(u) / Max ) * 100
					else
						result = 0
					end
					if result < 90 or not notfull then
						counted = 1
						remaining = result
					end
				end
				local r = s.InRaid()
				if raid and r then
					for i = 1, r do
						u = "raid"..i
						if not UnitIsUnit(u, "player") and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
							and ( not afk or not UnitIsAFK(u) )
							and ( not range or UnitInRange(u) )
							and ( not healer or HEALERCLASS[s.Class(u)] )
						then
							local Max = s.MaxHealth(u)
							if Max > 0 then
								result = ( s.Health(u) / Max ) * 100
							else
								result = 0
							end
							if result < 90 or not notfull then
								counted = counted + 1
								if average then
									remaining = remaining + result
								elseif remaining == 0 or result < remaining then
									remaining = result
								end
							end
						end
					end
				else
					local p = s.InParty()
					if p then
						for i = 1, p do
							u = "party"..i
							if UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
								and ( not afk or not UnitIsAFK(u) )
								and ( not range or UnitInRange(u) )
								and ( not healer or HEALERCLASS[s.Class(u)] )
							then
								local Max = s.MaxHealth(u)
								if Max > 0 then
									result = ( s.Health(u) / Max ) * 100
								else
									result = 0
								end
								if result < 90 or not notfull then
									counted = counted + 1
									if average then
										remaining = remaining + result
									elseif remaining == 0 or result < remaining then
										remaining = result
									end
								end
							end
						end
					end
				end
			end
			if counted > 1 and average then
				return ( remaining / counted ), counted
			end
			return remaining, counted
		end
	end
	local Max = s.MaxHealth(unit)
	if Max > 0 then
		return ( s.Health(unit) / Max ) * 100
	end
	return 0
end

function s.HealthDamage(unit)
	return s.MaxHealth(unit) - s.Health(unit)
end

function s.HealthDamagePercent(unit)
	local remaining, counted = s.HealthPercent(unit)
	if counted then
		return ( 100 - remaining ), counted
	end
	return 100 - remaining
end

function s.Power(unit, ...)
	return UnitPower(s.UnitSelection(unit), ...) or 0
end

function s.MaxPower(unit, ...)
	return UnitPowerMax(s.UnitSelection(unit), ...) or 0
end

function s.PowerPercent(unit, ...)
	if type(unit) == "string" then
		local group = string.lower("|"..unit.."|")
		local raid, party = group:match("|raid|"), group:match("|party|")
		if raid or party then
			local notself, afk, range, healer, notfull, average = group:match("|notself|"), group:match("|afk|"), group:match("|range|"), group:match("|healer|"), group:match("|notfull|"), group:match("|average|")
			local u = "player"
			local r = s.InRaid()
			local p = s.InParty()
			local remaining = 0
			local counted = 0
			local result
			if not UnitIsDeadOrGhost(u) then
				if not notself
					and ( not healer or HEALERCLASS[CLASS] )
				then
					local Max = s.MaxPower(u, ...)
					if Max > 0 then
						result = ( s.Power(u, ...) / Max ) * 100
					else
						result = 0
					end
					if result < 90 or not notfull then
						counted = 1
						remaining = result
					end
				end
				if raid and r then
					for i = 1, r do
						u = "raid"..i
						if not UnitIsUnit(u, "player") and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
							and ( not afk or not UnitIsAFK(u) )
							and ( not range or UnitInRange(u) )
							and ( not healer or HEALERCLASS[s.Class(u)] )
						then
							local Max = s.MaxPower(u, ...)
							if Max > 0 then
								result = ( s.Power(u, ...) / Max ) * 100
							else
								result = 0
							end
							if result < 90 or not notfull then
								counted = counted + 1
								if average then
									remaining = remaining + result
								elseif remaining == 0 or result < remaining then
									remaining = result
								end
							end
						end
					end
				elseif p then
					for i = 1, p do
						u = "party"..i
						if UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
							and ( not afk or not UnitIsAFK(u) )
							and ( not range or UnitInRange(u) )
							and ( not healer or HEALERCLASS[s.Class(u)] )
						then
							local Max = s.MaxPower(u, ...)
							if Max > 0 then
								result = ( s.Power(u, ...) / Max ) * 100
							else
								result = 0
							end
							if result < 90 or not notfull then
								counted = counted + 1
								if average then
									remaining = remaining + result
								elseif remaining == 0 or result < remaining then
									remaining = result
								end
							end
						end
					end
				end
			end
			if counted > 1 and average then
				return ( remaining / counted ), counted
			end
			return remaining, counted
		end
	end
	local Max = s.MaxPower(unit, ...)
	if Max > 0 then
		return ( s.Power(unit, ...) / Max ) * 100
	end
	return 0
end

function s.PowerMissing(unit, ...)
	return s.MaxPower(unit, ...) - s.Power(unit, ...)
end

function s.PowerMissingPercent(unit, ...)
	local remaining, counted = s.PowerPercent(unit, ...)
	if counted then
		return ( 100 - remaining ), counted
	end
	return 100 - remaining
end

function s.UsesMana(unit)
	return UnitPowerType(s.UnitSelection(unit)) == SPELL_POWER_MANA or UnitPowerMax(s.UnitSelection(unit), SPELL_POWER_MANA) > 0
end

function s.HasMana(unit)
	return UnitPower(s.UnitSelection(unit), SPELL_POWER_MANA) > 0
end



function s.Healer(unit)
	if type(unit) == "string" then
		local group = string.lower("|"..unit.."|")
		local raid, party = group:match("|raid|"), group:match("|party|")
		if raid or party then
			local notself, afk, range = group:match("|notself|"), group:match("|afk|"), group:match("|range|")
			local u = "player"
			local r = s.InRaid()
			local p = s.InParty()
			if not UnitIsDeadOrGhost(u) then
				if not notself then
					if HEALERCLASS[CLASS] then
						return u
					end
				end
				if raid and r then
					for i = 1, r do
						u = "raid"..i
						if not UnitIsUnit(u, "player") and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
							and ( not afk or not UnitIsAFK(u) )
							and ( not range or UnitInRange(u) )
						and HEALERCLASS[s.Class(u)] then
							return u
						end
					end
				elseif p then
					for i = 1, p do
						u = "party"..i
						if UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u)
							and ( not afk or not UnitIsAFK(u) )
							and ( not range or UnitInRange(u) )
						and HEALERCLASS[s.Class(u)] then
							return u
						end
					end
				end
			end
			return nil
		end
	end
	local u = s.UnitSelection(unit)
	if UnitIsUnit(u, "player") then
		if not UnitIsDeadOrGhost(u) and HEALERCLASS[CLASS] then
			return u
		end
	elseif s.Player(u) and UnitIsVisible(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u) and HEALERCLASS[s.Class(u)] then
		return u
	end
	return nil
end

function s.Buff(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
end

function s.BuffStack(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, nil, nil, 1)
end

function s.BuffDuration(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, nil, 1)
end

function s.MyBuff(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, "player")
end

function s.MyBuffStack(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, "player", nil, 1)
end

function s.MyBuffDuration(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, "player", 1)
end

function s.SelfBuff(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID)
	local unit = s.UnitSelection(unit)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Castable, UseBuffID, nil, unit)
end

function s.Debuff(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, nil, nil, nil, 1)
end

function s.DebuffStack(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, nil, nil, 1, 1)
end

function s.DebuffDuration(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, nil, 1, nil, 1)
end

function s.MyDebuff(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, "player", nil, nil, 1)
end

function s.MyDebuffStack(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, "player", nil, 1, 1)
end

function s.MyDebuffDuration(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type)
	return CheckAura(SpellName, unit, DurationRemainingGreaterThan, Stealable, Dispelable, UseDebuffID, Type, "player", 1, nil, 1)
end


function s.MainHandItemBuff(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "MainHandSlot", DurationRemainingGreaterThan)
end

function s.MainHandItemBuffStack(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "MainHandSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, nil, 1)
end

function s.MainHandItemBuffDuration(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "MainHandSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, 1)
end

function s.OffHandItemBuff(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "SecondaryHandSlot", DurationRemainingGreaterThan)
end

function s.OffHandItemBuffStack(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "SecondaryHandSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, nil, 1)
end

function s.OffHandItemBuffDuration(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "SecondaryHandSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, 1)
end

function s.RangedItemBuff(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "RangedSlot", DurationRemainingGreaterThan)
end

function s.RangedItemBuffStack(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "RangedSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, nil, 1)
end

function s.RangedItemBuffDuration(SpellName, DurationRemainingGreaterThan)
	return CheckAura(SpellName, "RangedSlot", DurationRemainingGreaterThan, nil, nil, nil, nil, nil, 1)
end


function s.Enemy(unit)
	local unit = s.UnitSelection(unit)
	return UnitExists(unit) and UnitCanAttack("player", unit) and ( not UnitIsDeadOrGhost(unit) or UnitAffectingCombat(unit) or UnitExists(unit.."target") )
end

function s.ActiveEnemy(unit, NoCrowedControlCheck)
	local unit = s.UnitSelection(unit)
	return s.Enemy(unit) and ( UnitAffectingCombat(unit) or s.Player(unit) or s.Dummy(unit) ) and not UnitIsDeadOrGhost(unit) and ( NoCrowedControlCheck or not s.NoDamageCC(unit) )
end

function s.GivesXP(unit)
	local unit = s.UnitSelection(unit)
	return s.Enemy(unit) and not UnitIsTrivial(unit) and UnitFactionGroup(unit) ~= UnitFactionGroup("player") and ( not UnitPlayerControlled(unit) or s.Player(unit) ) and ( s.Player(unit) or not UnitIsTapped(unit) or UnitIsTappedByPlayer(unit) or UnitIsTappedByAllThreatList(unit) )
end

function s.NotDieing(unit)
	local unit = s.UnitSelection(unit)
	return UnitExists(unit) and ( not UnitIsDeadOrGhost(unit) or UnitAffectingCombat(unit) or UnitExists(unit.."target") ) and ( s.HealthPercent(unit) > 25 or s.Player(unit) or s.Boss(unit) )
end

function s.Player(unit)
	return UnitIsPlayer(s.UnitSelection(unit))
end

function s.Boss(unit)
	local unit = s.UnitSelection(unit)
	return UnitExists(unit) and not UnitPlayerControlled(unit) and ( tostring(UnitClassification(unit)):lower():match("boss") or UnitLevel(unit) == -1 or UnitIsBossUnit(unit) )
end

function s.EnemyTargetingYourFriend(unit)
	local unit = s.UnitSelection(unit)
	return s.Enemy(unit) and UnitIsFriend("player", unit.."target") and not ( UnitIsUnit(unit.."target", "player") or ( UnitExists("vehicle") and UnitIsUnit(unit.."target", "vehicle") ) )
end

function s.EnemyTargetingYou(unit)
	local unit = s.UnitSelection(unit)
	return s.Enemy(unit) and ( UnitIsUnit(unit.."target", "player") or ( UnitExists("vehicle") and UnitIsUnit(unit.."target", "vehicle") ) )
end

function s.SameTargetAsPet(unit)
	local unit = s.UnitSelection(unit)
	return UnitExists("pettarget") and UnitIsUnit(unit, "pettarget")
end


-- 15590--[[Fist Weapons]]
-- 227--[[Staves]]
-- 200--[[Polearms]]
-- 198--[[One-Handed Maces]]
-- 199--[[Two-Handed Maces]]
-- 196--[[One-Handed Axes]]
-- 197--[[Two-Handed Axes]]
-- 201--[[One-Handed Swords]]
-- 202--[[Two-Handed Swords]]
-- 1180--[[Daggers]]

-- checks to see if a fist weapon is equipped in the main hand
function s.MainHand(ItemType)
	if type(ItemType) == "table" then
		for _, v in ipairs(ItemType) do
			local result = s.MainHand(v)
			if result then
				return result
			end
		end
	else
		local ItemType = ItemType
		if type(ItemType) == "number" then
			ItemType = s.SpellName(ItemType, 1)
			if not ItemType then
				return nil
			end
		end
		local slot = GetInventorySlotInfo("MainHandSlot")
		local Type = ItemSubType(GetInventoryItemID("player", slot))
		if Type and not GetInventoryItemBroken("player", slot) and ( not ItemType or Type == ItemType ) then
			return Type
		end
	end
	return nil
end

-- checks to see if a fist weapon is equipped in the main hand
function s.OffHand(ItemType)
	if type(ItemType) == "table" then
		for _, v in ipairs(ItemType) do
			local result = s.MainHand(v)
			if result then
				return result
			end
		end
	else
		local ItemType = ItemType
		if type(ItemType) == "number" then
			ItemType = s.SpellName(ItemType, 1)
			if not ItemType then
				return nil
			end
		end
		local slot = GetInventorySlotInfo("SecondaryHandSlot")
		local Type = ItemSubType(GetInventoryItemID("player", slot))
		if Type and not GetInventoryItemBroken("player", slot) and ( not ItemType or Type == ItemType ) then
			return Type
		end
	end
	return nil
end


-- checks to see if a shield is equipped
function s.ShieldEquipped()
	return s.OffHand(L["Shields"])
end


function s.Equipped(ItemName, Slot)
	if type(ItemName) == "table" then
		for _, v in ipairs(ItemName) do
			local result = s.Equipped(v, Slot)
			if result then
				return result
			end
		end
	elseif Slot then
		local Slot = Slot
		if type(Slot) == "string" then
			Slot = GetInventorySlotInfo(Slot)
		end
		if type(Slot) == "number" then
			local ID = GetInventoryItemID("player", Slot)
			if ID and not GetInventoryItemBroken("player", Slot) and ( not ItemName or ItemName == ID or ( type(ItemName) == "string" and ItemName == s.ItemName(ID) ) ) then
				return Slot
			end
		end
	elseif ItemName then
		for i = 0, 19 do
			local ID = GetInventoryItemID("player", i)
			if ID and not GetInventoryItemBroken("player", i) and ( ItemName == ID or ( type(ItemName) == "string" and ItemName == s.ItemName(ID) ) ) then
				return i
			end
		end
	end
	return nil
end


function s.Shooting()
	return not not SHOOT
end

function s.PetCastable(SpellName, PetFrameNeeded, PetHealthNotNeeded, GlobalPetCooldownSpell, EvenIfNotUsable)
	local unit
	if UnitExists("pettarget") then
		unit = "pettarget"
	else
		unit = s.UnitSelection()
	end
	if Immune(SpellName, unit) then
		return false
	end
	local SpellName = s.SpellName(SpellName)
	if type(SpellName) == "string" and SpellName ~= "" and ( a.PetActions[SpellName] or s.HasSpell(SpellName) ) and not s.CastingOrChanneling(SpellName, "pet") and ( PetHealthNotNeeded or UnitHealth("pet") > 0 ) and ( not PetFrameNeeded or UnitExists("pet") ) then
		for n = 1, NUM_PET_ACTION_SLOTS do
			local name, subtext, texture, isToken, isActive = GetPetActionInfo(n)
			if subtext and subtext ~= "" then
				name = name.."("..subtext..")"
			end
			if ( a.PetActions[SpellName] or SpellName ) == name then
				local globalcooldown = nil
				local GlobalCooldownSpell = s.SpellName(GlobalPetCooldownSpell)
				if s.HasSpell(GlobalCooldownSpell) then
					globalcooldown = s.SpellCooldown(GlobalCooldownSpell)
				end
				local Lag = select(3, GetNetStats()) / 1000
				local cooldown, duration = s.PetActionCooldown(n)
				return not isActive and ( EvenIfNotUsable or GetPetActionSlotUsable(n) ) and ( duration <= 1.5 or cooldown <= Lag or ( globalcooldown and cooldown <= 1.5 and cooldown <= globalcooldown ) )
			end
		end
	end
	return false
end


local AuraStackFunctions = {
	MyDebuff = s.MyDebuffStack,
	MyBuff = s.MyBuffStack,
	Debuff = s.DebuffStack,
	Buff = s.BuffStack,
}

function s.Castable(z)
	if type(z.Override) == "function" and not z:Override() then
		return nil
	elseif type(z.CheckFirst) == "function" and not z:CheckFirst() then
		return nil
	elseif type(z.Check) == "function" and not z:Check() then
		return nil
	elseif type(z.RunFirst) == "function" then
		z:RunFirst()
	end
	if type(z.Run) == "function" then
		z:Run()
	end
	if z.Type == "item" then
		if not s.CheckIfItemCastable(z) then
			return nil
		end
	elseif z.Type == "pet" then
		if not s.CheckIfPetSpellCastable(z) then
			return nil
		end
	elseif z.Type == "vehicle" then
		if not s.CheckIfVehicleSpellCastable(z) then
			return nil
		end
	elseif not s.CheckIfSpellCastable(z) then
		return nil
	end
	if type(z.CheckLast) == "function" and not z:CheckLast() then
		return nil
	end
	if type(z.RunLast) == "function" then
		z:RunLast()
	end
	return 1
end

function s.CheckIfSpellCastable(z)
	if z.Override then
		return true
	end
	if not z.ID then
		z.ID = z.SpellID
	end
	if z.Type == "form" and s.Form(z.ID) then
		return false
	end
	if type(z.Name) ~= "string" then
		z.Name = s.SpellName(z.ID)
	end
	if type(z.Name) ~= "string" or not s.HasSpell(z.Name) then
		return false
	end
	z.Unit = s.UnitSelection(z.Unit)
	if z.EnemyTargetNeeded and Immune(z.ID, z.Unit) then
		return false
	end
	local name, rank, icon, cost, isFunnel, powerType, castTime = GetSpellInfo(z.ID)
	if not castTime or castTime < 0 then
		castTime = 0
	end
	local Lag = select(3, GetNetStats()) / 1000
	local DoubleLag = Lag * 2
	local CastingTimeLeft = s.GetCasting(nil, "player")
	local CastRegenPower = 0
	if not z.NoPowerCheck and CastingTimeLeft > 0 and powerType and UnitPowerType("player") == powerType then
		local Regen, activeRegen = GetPowerRegen()
		if s.InCombat then
			Regen = activeRegen
		end
		CastRegenPower = math.floor(Regen * CastingTimeLeft)
	end
	if z.NoStopChannel then
		if type(z.NoStopChannel) == "table" or type(z.NoStopChannel) == "string" or ( type(z.NoStopChannel) == "number" and z.NoStopChannel > 1 ) then
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(z.NoStopChannel, "player")
		else
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(nil, "player")
		end
	end
	local Casting = s.Casting(z.Name, "player")
	local Channeling = s.Channeling(z.Name, "player")
	local CastingOrChanneling = Casting or Channeling
	local Current = s.CurrentSpell(z.Name)
	if z.NotIfActive then
		if type(z.NotIfActive) == "table" or type(z.NotIfActive) == "string" or ( type(z.NotIfActive) == "number" and z.NotIfActive > 1 ) then
			local Casting = s.Casting(z.NotIfActive, "player")
			local Channeling = s.Channeling(z.NotIfActive, "player")
			local Current = s.CurrentSpell(z.NotIfActive)
			if Current or Casting or ( Channeling and Channeling > Lag ) then
				return false
			end
		elseif Current or Casting or ( Channeling and Channeling > Lag ) then
			return false
		end
	end
	local globalcooldown = 0
	if not z.NoGCD then
		globalcooldown = s.GlobalCooldown()
	end
	local cooldown, duration = s.SpellCooldown(z.ID)
	z.CastTime = z.CastTime or castTime / 1000
	local i = ""
	local p = ""
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling or s.AuraCastingOrChanneling(z[p..Aura..i], "player") then
					CastingQueued = z[p.."StackGiven"..i]
					if CastingQueued >= z[p.."Stack"..i] then
						return false
					end
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."EarlyRefresh"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued + CastingQueued >= z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Consume"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..""..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				if (z[p.."StackTaken"..i] or 0) < 1 then
					z[p.."StackTaken"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling then
					CastingQueued = z[p.."StackTaken"..i]
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if s.AuraCastingOrChanneling(z[p..Aura..i], "player") then
					AuraCastingQueued = AuraCastingQueued + z[p.."StackGiven"..i]
				end
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] + CastingQueued then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Require"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	local isUsable, notEnoughPower = s.UsableSpell(z.ID)
	return ( z.EvenIfNotUsable or isUsable or ( not z.Conditional and notEnoughPower ) )
		and ( not z.Melee or s.MeleeDistance(z.Unit) )
		and ( z.NoPowerCheck or (cost or 0) == 0 or UnitPower("player", powerType) + CastRegenPower >= (cost or 0) + s.SpellCost(s.CastingName(nil, "player"), powerType) )
		and ( SUPPRESS_SPEED_CHECK or not z.NotWhileMoving or not s.Moving("player") )
		and ( cooldown <= Lag + CastingTimeLeft or ( not globalcooldown and duration <= 1.5 ) or ( globalcooldown and cooldown <= globalcooldown ) )
		and ( SUPPRESS_RANGE_CHECK or z.NoRangeCheck or UnitIsUnit(z.Unit, "player") or UnitIsUnit(z.Unit, "vehicle") or not s.SpellHasRange(z.Name) or s.SpellInRange(z.Name, z.Unit) )
		and ( not z.EnemyTargetNeeded or s.Enemy(z.Unit) )
		and ( not z.TargetThatUsesManaNeeded or s.UsesMana(z.Unit) )
		and ( not z.Interrupt or s.GetCastingOrChanneling(nil, z.Unit, 1) > (CastingOrChanneling or (cooldown + z.CastTime)) + DoubleLag )
end


function s.CheckIfItemCastable(z)
	if z.Override then
		return true
	end
	if not z.ID then
		z.ID = z.ItemID
	end
	if type(z.Name) ~= "string" then
		z.Name = s.ItemName(z.ID)
	end
	if type(z.Name) ~= "string" or not s.HasItem(z.Name) then
		return false
	end
	z.Unit = s.UnitSelection(z.Unit)
	if z.EnemyTargetNeeded and Immune(z.Name, z.Unit) then
		return false
	end
	local Lag = select(3, GetNetStats()) / 1000
	local DoubleLag = Lag * 2
	local CastingTimeLeft = s.GetCasting(nil, "player")
	if z.NoStopChannel then
		if type(z.NoStopChannel) == "string" or type(z.NoStopChannel) == "table" or ( type(z.NoStopChannel) == "number" and z.NoStopChannel > 1 ) then
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(z.NoStopChannel, "player")
		else
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(nil, "player")
		end
	end
	local Casting = s.Casting(z.Name, "player")
	local Channeling = s.Channeling(z.Name, "player")
	local CastingOrChanneling = Casting or Channeling
	local Current = s.CurrentItem(z.ID)
	if z.NotIfActive then
		if type(z.NotIfActive) == "table" or type(z.NotIfActive) == "string" or ( type(z.NotIfActive) == "number" and z.NotIfActive > 1 ) then
			local Casting = s.Casting(z.NotIfActive, "player")
			local Channeling = s.Channeling(z.NotIfActive, "player")
			local Current = s.CurrentItem(z.NotIfActive)
			if Current or Casting or ( Channeling and Channeling > Lag ) then
				return false
			end
		elseif Current or Casting or ( Channeling and Channeling > Lag ) then
			return false
		end
	end
	local globalcooldown = 0
	if not z.NoGCD then
		globalcooldown = s.GlobalCooldown()
	end
	local cooldown, duration = s.ItemCooldown(z.ID)
	z.CastTime = z.CastTime or 0
	local i = ""
	local p = ""
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling or s.AuraCastingOrChanneling(z[p..Aura..i], "player") then
					CastingQueued = z[p.."StackGiven"..i]
					if CastingQueued >= z[p.."Stack"..i] then
						return false
					end
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."EarlyRefresh"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued + CastingQueued >= z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Consume"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				if (z[p.."StackTaken"..i] or 0) < 1 then
					z[p.."StackTaken"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling then
					CastingQueued = z[p.."StackTaken"..i]
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if s.AuraCastingOrChanneling(z[p..Aura..i], "player") then
					AuraCastingQueued = AuraCastingQueued + z[p.."StackGiven"..i]
				end
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] + CastingQueued then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Require"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	local isUsable, notEnoughPower = IsUsableItem(z.ID)
	return ( z.EvenIfNotUsable or isUsable ) and ( z.NoPowerCheck or not notEnoughPower )
		and ( not z.Melee or s.MeleeDistance(z.Unit) )
		and ( z.NoEquipCheck or not IsEquippableItem(z.ID) or IsEquippedItem(z.ID) )
		and ( SUPPRESS_SPEED_CHECK or not z.NotWhileMoving or not s.Moving("player") )
		and ( cooldown <= Lag + CastingTimeLeft or ( not globalcooldown and duration <= 1.5 ) or ( globalcooldown and cooldown <= globalcooldown ) )
		and ( SUPPRESS_RANGE_CHECK or z.NoRangeCheck or UnitIsUnit(z.Unit, "player") or UnitIsUnit(z.Unit, "vehicle") or not ItemHasRange(z.ID) or IsItemInRange(z.ID, z.Unit) == 1 )
		and ( not z.EnemyTargetNeeded or s.Enemy(z.Unit) )
		and ( not z.TargetThatUsesManaNeeded or s.UsesMana(z.Unit) )
		and ( not z.Interrupt or s.GetCastingOrChanneling(nil, z.Unit, 1) > (CastingOrChanneling or (cooldown + z.CastTime)) + DoubleLag )
end


function s.CheckIfVehicleSpellCastable(z)
	if z.Override then
		return true
	end
	if not z.ID then
		z.ID = z.SpellID
	end
	if not UnitInVehicle("player") then return false end
	if type(z.Name) ~= "string" then
		z.Name = s.SpellName(z.ID)
	end
	if type(z.Name) ~= "string" then
		return false
	end
	z.Unit = s.UnitSelection(z.Unit)
	if z.EnemyTargetNeeded and Immune(z.ID, z.Unit) then
		return false
	end
	local slot = VehicleSlot(z.Name)
	if not slot then
		return false
	end
	local Lag = select(3, GetNetStats()) / 1000
	local DoubleLag = Lag * 2
	local CastingTimeLeft = s.GetCasting(nil, "vehicle")
	if z.NoStopChannel then
		if type(z.NoStopChannel) == "string" or type(z.NoStopChannel) == "table" or ( type(z.NoStopChannel) == "number" and z.NoStopChannel > 1 ) then
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(z.NoStopChannel, "vehicle")
		else
			CastingTimeLeft = CastingTimeLeft + s.GetChanneling(nil, "vehicle")
		end
	end
	local Casting = s.Casting(z.Name, "vehicle")
	local Channeling = s.Channeling(z.Name, "vehicle")
	local CastingOrChanneling = Casting or Channeling
	local Current = IsCurrentAction(slot)
	if z.NotIfActive then
		if type(z.NotIfActive) == "table" or type(z.NotIfActive) == "string" or ( type(z.NotIfActive) == "number" and z.NotIfActive > 1 ) then
			local Casting = s.Casting(z.NotIfActive, "vehicle")
			local Channeling = s.Channeling(z.NotIfActive, "vehicle")
			local Current = s.CurrentVehicle(z.NotIfActive)
			if Current or Casting or ( Channeling and Channeling > Lag ) then
				return false
			end
		elseif Current or Casting or ( Channeling and Channeling > Lag ) then
			return false
		end
	end
	local globalcooldown = 0
	if not z.NoGCD then
		globalcooldown = s.ActionCooldown(VehicleSlot(z.GlobalVehicleCooldownSpell))
	end
	local cooldown, duration = s.ActionCooldown(slot)
	z.CastTime = z.CastTime or 0
	local i = ""
	local p = ""
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling or s.AuraCastingOrChanneling(z[p..Aura..i], "vehicle") then
					CastingQueued = z[p.."StackGiven"..i]
					if CastingQueued >= z[p.."Stack"..i] then
						return false
					end
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."EarlyRefresh"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued + CastingQueued >= z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Consume"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				if (z[p.."StackTaken"..i] or 0) < 1 then
					z[p.."StackTaken"..i] = 1
				end
				local CastingQueued = 0
				if Current or CastingOrChanneling then
					CastingQueued = z[p.."StackTaken"..i]
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if s.AuraCastingOrChanneling(z[p..Aura..i], "vehicle") then
					AuraCastingQueued = AuraCastingQueued + z[p.."StackGiven"..i]
				end
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] + CastingQueued then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	i = ""
	p = "Require"
	if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
		i = 1
	end
	while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
		for Aura, Function in pairs(AuraStackFunctions) do
			if z[p..Aura..i] then
				if (z[p.."Stack"..i] or 0) < 1 then
					z[p.."Stack"..i] = 1
				end
				if (z[p.."StackGiven"..i] or 0) < 1 then
					z[p.."StackGiven"..i] = 1
				end
				local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
				if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] then
					return false
				end
			end
		end
		i = ( tonumber(i) or 0 ) + 1
	end
	local isUsable, notEnoughPower = IsUsableAction(slot)
	return ( z.EvenIfNotUsable or isUsable ) and ( z.NoPowerCheck or not notEnoughPower )
		and ( SUPPRESS_SPEED_CHECK or not z.NotWhileMoving or not s.Moving("vehicle") )
		and ( duration <= 1.5 or cooldown <= Lag + CastingTimeLeft or ( globalcooldown and cooldown <= 1.5 and cooldown <= globalcooldown ) )
		and ( SUPPRESS_RANGE_CHECK or z.NoRangeCheck or UnitIsUnit(z.Unit, "player") or UnitIsUnit(z.Unit, "vehicle") or not ActionHasRange(slot) or IsActionInRange(slot, z.Unit) == 1 )
		and ( not z.EnemyTargetNeeded or s.Enemy(z.Unit) )
		and ( not z.TargetThatUsesManaNeeded or s.UsesMana(z.Unit) )
		and ( not z.Interrupt or s.GetCastingOrChanneling(nil, z.Unit, 1) > (CastingOrChanneling or (cooldown + z.CastTime)) + DoubleLag )
end

function s.CheckIfPetSpellCastable(z)
	if z.Override then
		return true
	end
	if type(z.Name) ~= "string" then
		z.Name = s.SpellName(z.ID)
	end
	if type(z.Name) ~= "string" or ( not a.PetActions[z.Name] and not s.HasSpell(z.Name) ) then
		return false
	end
	if not z.Unit then
		if UnitExists("pettarget") then
			z.Unit = "pettarget"
		else
			z.Unit = s.UnitSelection()
		end
	end
	if Immune(z.ID, z.Unit) then
		return false
	end
	local Lag = select(3, GetNetStats()) / 1000
	local Casting = s.Casting(z.Name, "pet")
	local Channeling = s.Channeling(z.Name, "pet")
	local CastingOrChanneling = Casting or Channeling
	if z.NotIfActive then
		if type(z.NotIfActive) == "table" or type(z.NotIfActive) == "string" or ( type(z.NotIfActive) == "number" and z.NotIfActive > 1 ) then
			local Casting = s.Casting(z.NotIfActive, "pet")
			local Channeling = s.Channeling(z.NotIfActive, "pet")
			if Casting or ( Channeling and Channeling > Lag ) then
				return false
			end
		elseif Casting or ( Channeling and Channeling > Lag ) then
			return false
		end
	end
	if ( z.PetHealthNotNeeded or UnitHealth("pet") > 0 ) and ( not z.PetFrameNeeded or UnitExists("pet") ) then
		for n = 1, NUM_PET_ACTION_SLOTS do
			local name, subtext, texture, isToken, isActive = GetPetActionInfo(n)
			if subtext and subtext ~= "" then
				name = name.."("..subtext..")"
			end
			if ( a.PetActions[z.Name] or z.Name ) == name then
				local name, rank, icon, cost, isFunnel, powerType, castTime = GetSpellInfo(z.ID)
				if not castTime or castTime < 0 then
					castTime = 0
				end
				local DoubleLag = Lag * 2
				local CastingTimeLeft = s.GetCasting(nil, "pet")
				if z.NoStopChannel then
					if type(z.NoStopChannel) == "string" or type(z.NoStopChannel) == "table" or ( type(z.NoStopChannel) == "number" and z.NoStopChannel > 1 ) then
						CastingTimeLeft = CastingTimeLeft + s.GetChanneling(z.NoStopChannel, "pet")
					else
						CastingTimeLeft = CastingTimeLeft + s.GetChanneling(nil, "pet")
					end
				end
				local cooldown, duration = s.PetActionCooldown(n)
				z.CastTime = z.CastTime or castTime / 1000
				local i = ""
				local p = ""
				if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
					i = 1
				end
				while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
					for Aura, Function in pairs(AuraStackFunctions) do
						if z[p..Aura..i] then
							if (z[p.."Stack"..i] or 0) < 1 then
								z[p.."Stack"..i] = 1
							end
							if (z[p.."StackGiven"..i] or 0) < 1 then
								z[p.."StackGiven"..i] = 1
							end
							local CastingQueued = 0
							if CastingOrChanneling or s.AuraCastingOrChanneling(z[p..Aura..i], "pet") then
								CastingQueued = z[p.."StackGiven"..i]
								if CastingQueued >= z[p.."Stack"..i] then
									return false
								end
							end
							local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
							if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."EarlyRefresh"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued + CastingQueued >= z[p.."Stack"..i] then
								return false
							end
						end
					end
					i = ( tonumber(i) or 0 ) + 1
				end
				i = ""
				p = "Consume"
				if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
					i = 1
				end
				while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
					for Aura, Function in pairs(AuraStackFunctions) do
						if z[p..Aura..i] then
							if (z[p.."Stack"..i] or 0) < 1 then
								z[p.."Stack"..i] = 1
							end
							if (z[p.."StackGiven"..i] or 0) < 1 then
								z[p.."StackGiven"..i] = 1
							end
							if (z[p.."StackTaken"..i] or 0) < 1 then
								z[p.."StackTaken"..i] = 1
							end
							local CastingQueued = 0
							if Current or CastingOrChanneling then
								CastingQueued = z[p.."StackTaken"..i]
							end
							local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
							if s.AuraCastingOrChanneling(z[p..Aura..i], "pet") then
								AuraCastingQueued = AuraCastingQueued + z[p.."StackGiven"..i]
							end
							if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, z.CastTime + math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] + CastingQueued then
								return false
							end
						end
					end
					i = ( tonumber(i) or 0 ) + 1
				end
				i = ""
				p = "Require"
				if not z[p.."Buff"..i] and not z[p.."Debuff"..i] and not z[p.."MyBuff"..i] and not z[p.."MyDebuff"..i] then
					i = 1
				end
				while z[p.."Buff"..i] or z[p.."Debuff"..i] or z[p.."MyBuff"..i] or z[p.."MyDebuff"..i] do
					for Aura, Function in pairs(AuraStackFunctions) do
						if z[p..Aura..i] then
							if (z[p.."Stack"..i] or 0) < 1 then
								z[p.."Stack"..i] = 1
							end
							if (z[p.."StackGiven"..i] or 0) < 1 then
								z[p.."StackGiven"..i] = 1
							end
							local AuraCastingQueued = (s.SpellOrAuraDelay(z[p..Aura..i], z.Unit) or 0) * z[p.."StackGiven"..i]
							if ( Function(z[p..Aura..i], z[p.."BuffUnit"..i] or z.Unit, math.max(CastingTimeLeft, cooldown) + DoubleLag + (z[p.."MoreBuffTime"..i] or 0), nil, nil, z[p.."UseBuffID"..i]) or 0 ) + AuraCastingQueued < z[p.."Stack"..i] then
								return false
							end
						end
					end
					i = ( tonumber(i) or 0 ) + 1
				end
				local globalcooldown = 0
				if not z.NoGCD then
					globalcooldown = nil
					local GlobalCooldownSpell = s.SpellName(z.GlobalPetCooldownSpell)
					if s.HasSpell(GlobalCooldownSpell) then
						globalcooldown = s.SpellCooldown(GlobalCooldownSpell)
					end
				end
				return ( not z.NotIfActive or not isActive ) and ( z.EvenIfNotUsable or GetPetActionSlotUsable(n) )
					and ( z.NoPowerCheck or (cost or 0) == 0 or UnitPower("pet", powerType) >= (cost or 0) + s.SpellCost(s.CastingName(nil, "pet"), powerType) )
					and ( cooldown <= Lag + CastingTimeLeft or ( not globalcooldown and duration <= 1.5 ) or ( globalcooldown and cooldown <= globalcooldown ) )
					and ( not z.EnemyTargetNeeded or s.Enemy(z.Unit) )
					and ( not z.Interrupt or s.GetCastingOrChanneling(nil, z.Unit, 1) > (CastingOrChanneling or (cooldown + z.CastTime)) + DoubleLag )
			end
		end
	end
	return false
end


function s.BreakOnDamageCC(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(a.BreakOnDamage, unit, DurationRemainingGreaterThan, Stealable, Dispelable)
		or s.Debuff(19386--[[Wyvern Sting]], unit, DurationRemainingGreaterThan, Stealable, Dispelable, L["Asleep"])
end


function s.ImmunityDebuff(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(a.ImmunityDebuffs, unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


--all forms of fear and movement impairing affects are not included since they do not prevent the target from being damaged
--Mind Control is no longer included as a CC in this function
function s.NoDamageCC(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.BreakOnDamageCC(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	or s.ImmunityDebuff(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


--movement impairing affects are not included since the target could still attack
function s.CrowedControlled(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.NoDamageCC(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	or s.Feared(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


--movement impairing affects are not included since the target could still attack
function s.Feared(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(a.Fear, unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


function s.Rooted(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(a.Root, unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


function s.MovementImpaired(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Rooted(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	or s.Debuff(a.MovementImpairing, unit, DurationRemainingGreaterThan, Stealable, Dispelable)
end


function s.Poisoned(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(nil, unit, DurationRemainingGreaterThan, Stealable, Dispelable, nil, "Poison")
end

function s.Diseased(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(nil, unit, DurationRemainingGreaterThan, Stealable, Dispelable, nil, "Disease")
end

function s.Cursed(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(nil, unit, DurationRemainingGreaterThan, Stealable, Dispelable, nil, "Curse")
end

function s.Magic(unit, DurationRemainingGreaterThan, Stealable, Dispelable)
	return s.Debuff(nil, unit, DurationRemainingGreaterThan, Stealable, Dispelable, nil, "Magic")
end




function s.CheckThenFlash(z, NoFlash)
	if type(z.Override) == "function" and not z:Override() then
		return nil
	elseif type(z.CheckFirst) == "function" and not z:CheckFirst() then
		return nil
	elseif type(z.Check) == "function" and not z:Check() then
		return nil
	elseif type(z.RunFirst) == "function" then
		z:RunFirst()
	end
	if type(z.Run) == "function" then
		z:Run()
	end
	local FlashID = z.FlashID or z.ID
	if type(FlashID) == "table" and not FlashID[1] then
		FlashID = z.ID
	end
	if z.Type == "item" then
		if not s.ItemFlashable(FlashID, z.FlashNoMacros) or not s.CheckIfItemCastable(z) or ( type(z.CheckLast) == "function" and not z:CheckLast() ) then
			return nil
		elseif not NoFlash then
			s.FlashItem(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink, z.FlashNoMacros)
		end
	elseif z.Type == "vehicle" then
		if not s.CheckIfVehicleSpellCastable(z) or ( type(z.CheckLast) == "function" and not z:CheckLast() ) then
			return nil
		elseif not NoFlash then
			s.FlashVehicle(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink)
		end
	elseif z.Type == "pet" then
		if not s.CheckIfPetSpellCastable(z) or ( type(z.CheckLast) == "function" and not z:CheckLast() ) then
			return nil
		elseif not NoFlash then
			s.FlashPet(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink)
		end
	elseif z.Type == "form" then
		if not s.CheckIfSpellCastable(z) or ( type(z.CheckLast) == "function" and not z:CheckLast() ) then
			return nil
		elseif not NoFlash then
			s.Flash(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink, z.FlashNoMacros)
			s.FlashForm(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink)
		end
	elseif not s.Flashable(FlashID, z.FlashNoMacros) or not s.CheckIfSpellCastable(z) or ( type(z.CheckLast) == "function" and not z:CheckLast() ) then
		return nil
	elseif not NoFlash then
		s.Flash(FlashID, z.FlashColor, z.FlashSize, z.FlashBrightness, z.FlashBlink, z.FlashNoMacros)
	end
	if type(z.RunLast) == "function" then
		z:RunLast()
	end
	return 1
end


function s.FlashSizePercent()
	return FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT
end

function s.FlashBrightnessPercent()
	return FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT
end

function s.Flashable(SpellName, NoMacros)
	return SpellFlashCore.Flashable(SpellName, NoMacros or DISABLE_MACRO_FLASHING)
end

function s.Flash(SpellName, color, size, brightness, blink, NoMacros)
	SpellFlashCore.FlashAction(SpellName, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING, NoMacros or DISABLE_MACRO_FLASHING)
end

function s.ItemFlashable(ItemName, NoMacros)
	return SpellFlashCore.ItemFlashable(ItemName, NoMacros or DISABLE_MACRO_FLASHING)
end

function s.FlashItem(ItemName, color, size, brightness, blink, NoMacros)
	SpellFlashCore.FlashItem(ItemName, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING, NoMacros or DISABLE_MACRO_FLASHING)
end

function s.VehicleFlashable(SpellName)
	return not not VehicleSlot(SpellName)
end

function s.FlashVehicle(SpellName, color, size, brightness, blink)
	SpellFlashCore.FlashVehicle(SpellName, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end

function s.FlashPet(SpellName, color, size, brightness, blink)
	SpellFlashCore.FlashPet(SpellName, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end

function s.FlashForm(SpellName, color, size, brightness, blink)
	SpellFlashCore.FlashForm(SpellName, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end

function s.FlashTotemCall(color, size, brightness, blink)
	SpellFlashCore.FlashTotemCall(color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end

function s.FlashTotemRecall(color, size, brightness, blink)
	SpellFlashCore.FlashTotemRecall(color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end

function s.FlashFrame(frame, color, size, brightness, blink)
	SpellFlashCore.FlashFrame(frame, color, size or FLASH_SIZE_PERCENT or DEFAULT_FLASH_SIZE_PERCENT, brightness or FLASH_BRIGHTNESS_PERCENT or DEFAULT_FLASH_BRIGHTNESS_PERCENT, blink or ENABLE_BLINKING)
end


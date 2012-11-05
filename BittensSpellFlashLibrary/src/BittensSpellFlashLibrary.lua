local libName, lib = ...
local s = SpellFlashAddon

BittensSpellFlashLibrary = {}
local c = BittensSpellFlashLibrary

BINDING_HEADER_BITTENS_SPELLFLASH = select(2, GetAddOnInfo(libName))
BINDING_NAME_BITTENS_SPELLFLASH_AOE = lib.Localize["Toggle AoE Mode"]
BINDING_NAME_BITTENS_SPELLFLASH_DEBUGGING
	= lib.Localize["Print Debugging Info"]
BINDING_NAME_BITTENS_SPELLFLASH_FLOATING_TEXT
	= lib.Localize["Toggle Floating Combat Text"]

local GetNumGroupMembers = GetNumGroupMembers
local GetTime = GetTime
local IsInRaid = IsInRaid
local IsMounted = IsMounted
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsUnit = UnitIsUnit
local UnitSpellHaste = UnitSpellHaste
local UnitThreatSituation = UnitThreatSituation
local math = math
local pairs = pairs
local print = print
local select = select
local string = string
local table = table
local type = type
local unpack = unpack

c.Debugging = false

function c.Init(a)
	lib.A = a
end

function c.GetCurrentRotation(a)
	for _, rotation in pairs(a.Rotations) do
		if (rotation.CheckFirst == nil or rotation.CheckFirst())
			and rotation.Spec == s.TalentMastery()
			and (rotation.OffSwitch == nil
				or not a.GetConfig(rotation.OffSwitch)) then
			
			return rotation
		end
	end
end

function c.Flash(a)
	local rotation = c.GetCurrentRotation(a)
	if rotation == nil then
		c.EnableDefaultProcHilighting()
		return
	end
	
	c.DisableDefaultProcHilighting()
	
	local inCombat = s.InCombat()
	if IsMounted() and not inCombat then
		return
	end
	
	c.Init(a)
	if rotation.FlashAlways then
		rotation:FlashAlways()
	end
	if inCombat then
		if rotation.FlashInCombat then
			rotation:FlashInCombat()
		end
	else
		if rotation.FlashOutOfCombat then
			rotation:FlashOutOfCombat()
		end
	end
end

function c.GetSpell(name)
	if lib.A.Spells then
		local spell = lib.A.Spells[name]
		if spell == nil then
			spell = c.AddSpell(name)
		end
		return spell
	else
		return lib.A.spells[name]
	end
end

function c.GetCooldown(name, noGCD)
	return math.max(0, s.SpellCooldown(c.GetID(name)) - c.GetBusyTime(noGCD))
end

function c.GetIDs(...)
	local ids = {}
	for i = 1, select("#", ...) do
		local id = c.GetID(select(i, ...))
		if id then
			table.insert(ids, id)
		end
	end
	return ids
end

function c.GetID(name)
	if type(name) == "number" or type(name) == "table" then
		return name
	end
	
	local id
	if lib.A.SpellIDs == nil then
		local spell = lib.A.spells[name]
		if spell ~= nil then
			id = spell.ID
		end
	else
		id = lib.A.SpellIDs[name]
	end
	if id then
		return id
   	else
  	  	print("No spell defined (or no ID attribute):", name)
  	end
end

function c.Debug(tag, ...)
	if c.Debugging then
		return print("|cFF00FFFF["..tag.."]|r", ...)
	end
end

function c.IsCasting(name)
	local id = c.GetID(name)
	return s.CurrentSpell(id) or s.Channeling(id, "player")
end

function c.IsCastingOrInAir(name)
	return c.IsCasting(name) or s.SpellDelay(c.GetID(name))
end

function c.IsAuraPendingFor(name)
	return c.IsCastingOrInAir(name) or s.AuraDelay(c.GetID(name))
end

function c.IsTanking()
	local status = UnitThreatSituation("player", "target")
	return status == 2 or status == 3
end

function c.CheckFirstForTaunts(z)
	local primaryTarget = s.GetPrimaryThreatTarget()
	if not primaryTarget or UnitIsUnit(primaryTarget, "player") then
		return false
	end
	
	if UnitGroupRolesAssigned(primaryTarget) == "TANK" then
		z.FlashSize = s.FlashSizePercent() / 2
		z.FlashColor = "yellow"
	else
		z.FlashSize = nil
		z.FlashColor = "red"
	end
	return true
end

function c.WearingSet(number, name)
	local count = 0
	for slot, piece in pairs(lib.A.EquipmentSets[name]) do
		if s.Equipped(piece, slot) then
			count = count + 1
		end
	end
	return count >= number
end

function c.AssociateTravelTimes(estimate, ...)
	if lib.A.TravelTimes == nil then
		lib.A.TravelTimes = {}
	end
	local info = {
		Estimate = estimate,
		IDs = c.GetIDs(...)
	}
	for i = 1, select("#", ...) do
		lib.A.TravelTimes[select(i, ...)] = info
	end
end

function c.EstimateTravelTime(name)
	if lib.A.TravelTimes then
		local info = lib.A.TravelTimes[name]
		local travel = info.Estimate
		local recordedAt = 0
		for _, id in pairs(info.IDs) do
			local t, ra = s.LastSpellTravelTime(id)
			if t and ra > recordedAt then
				travel = t
				recordedAt = ra
			end 
		end
		return travel
	end
end

local function incrementIfLanding(
	count, startDelay, endDelay, castDelay, travelTime)
	
	if castDelay == nil then
		return count
	end
	
	local landDelay = castDelay + travelTime
	if startDelay <= landDelay and landDelay < endDelay then
		return count + 1
	else
		return count
	end
end

function c.CountLandings(name, startDelay, endDelay, countNextCast)
	local count = 0
	local travel = c.EstimateTravelTime(name)
	
	-- in the air
	local currentEstimated = -10
	local timesForAllTargets = s.SpellTravelStartTime(c.GetID(name), "all")
	if timesForAllTargets then
		for _, timesForOneTarget in pairs(timesForAllTargets) do
			for _, timesForOneLaunch in pairs(timesForOneTarget) do
				local estimated, actual = unpack(timesForOneLaunch)
--c.Debug("Lib", "loop", estimated, actual)
				if estimated ~= nil then
					if actual then
--c.Debug("Lib", "actual", name, " in air lands in", estimated - GetTime() + travel)
						count = incrementIfLanding(
							count,
							startDelay,
							endDelay,
							estimated - GetTime(),
							travel)
					elseif estimated > currentEstimated then
						currentEstimated = estimated - GetTime()
					end
				end
			end
		end
	end
	
	-- currently casting
	if c.IsCasting(name) then
		if currentEstimated > -10 then
--c.Debug("Lib", "currentEstimated in", currentEstimated)
			count = incrementIfLanding(
				count, startDelay, endDelay, currentEstimated, travel)
		else
--c.Debug("Lib", "current, but not estimated")
			count = incrementIfLanding(
				count, startDelay, endDelay, c.GetCastTime(name), travel)
		end
	end
	
	-- will have time to cast
	if countNextCast then
		count = incrementIfLanding(
			count,
			startDelay,
			endDelay,
			c.GetBusyTime() + c.GetCastTime(name),
			travel)
	end
	
	return count
end

function c.ShouldCastToRefresh(
	spellName, debuffName, earlyRefresh, willApplyDebuff, ...)
	
	if willApplyDebuff and c.IsAuraPendingFor(spellName) then
		return false
	end
	
	local duration = s.MyDebuffDuration(c.GetID(debuffName))
	if c.CountLandings(spellName, -3, duration) > 0 then
		return false
	end
	
	for i = 1, select("#", ...) do
		if c.CountLandings(select(i, ...), -3, duration) > 0 then
			return false
		end
	end
	
	local landing =
		c.GetBusyTime()
			+ c.GetCastTime(spellName)
			+ c.EstimateTravelTime(spellName)
	return landing > duration - earlyRefresh + .1
		and (willApplyDebuff or landing < duration - .1)
end

function c.HasTalent(name)
	return s.HasTalent(lib.A.TalentIDs[name])
end

function c.GetTalentRank(name)
	return s.TalentRank(lib.A.TalentIDs[name])
end

function c.HasGlyph(name)
	return s.HasGlyph(lib.A.GlyphIDs[name])
end

function c.RegisterAura(spellName, auraName)
	s.SetOtherAuras(c.GetID(spellName), c.GetID(auraName))
end

function c.GetCastTime(spellName)
	return s.CastTime(s.SpellName(c.GetID(spellName)))
end

function c.GetCost(spellName)
	return s.SpellCost(s.SpellName(c.GetID(spellName)))
end

local fullChannels = {}

function c.RegisterForFullChannels(name, unhastedChannelTime)
	fullChannels[s.SpellName(c.GetID(name))] = unhastedChannelTime
end

function c.GetBusyTime(noGCD)
	local info = c.GetQueuedInfo()
	if info then
		local castTime = fullChannels[info.Name]
		if castTime ~= nil then
			castTime = c.GetHastedTime(castTime)
		else
			castTime = s.CastTime(info.Name)
		end
		if noGCD then
			return math.max(0, info.CastStart + castTime - GetTime())
		else
			return math.max(
					info.GCDStart + lib.LastGCD, info.CastStart + castTime)
				- GetTime()
		end
	end
	
	local remaining
	if fullChannels[s.ChannelingName(nil, "player")] then
		remaining = s.GetChanneling(nil, "player")
	else
		remaining = s.GetCasting(nil, "player")
	end
	if noGCD then
		return remaining
	else
		local gcd, _ = s.GlobalCooldown()
		return math.max(remaining, gcd)
	end
end

-- If you supply a powerType it will not consider any currently casting spell.
-- But that should be OK, since I can only think of instant cast spells that use
-- secondary power.
function c.GetPower(regen, powerType)
	local power = s.Power("player", powerType)
	local max = s.MaxPower("player", powerType)
	local t = GetTime()
	local busy = s.GetCastingOrChanneling(nil, "player")
	
--c.Debug("Lib", power, "--------")
	local info = c.GetCastingInfo()
	if info and not powerType then
		power = math.min(max, power + busy * regen)
		power = math.min(max, power - info.Cost)
		t = t + busy
--c.Debug("Lib", power, info.Name, "cast", busy)
	end
	
	info = c.GetQueuedInfo()
	if info then
		local castTime = s.CastTime(info.Name)
		local busy = castTime + (info.CastStart - t)
		power = math.min(max, power + busy * regen)
		power = math.min(
			max, power - (info.Cost or s.SpellCost(info.Name, powerType)))
		t = t + busy
--c.Debug("Lib", power, info.Name, "queue", busy)
		
		busy = math.max(0, info.GCDStart + lib.LastGCD - t)
		power = math.min(max, power + busy * regen)
--c.Debug("Lib", power, "gcd", busy)
	else
		local gcd = s.GlobalCooldown()
		busy = math.max(0, gcd - busy)
		power = math.min(max, power + busy * regen)
--c.Debug("Lib", power, "gcd", busy)
	end
	return power
end

local function convertToIDs(attributes, key, ...)
	if string.find(key, "Use") then
		return
	end
	for i = 1, select("#", ...) do
		local pattern = select(i, ...)
		local _, last = string.find(key, pattern)
		if last == #key then
			local value = attributes[key]
			if type(value) == "table" then
				attributes[key] = c.GetIDs(unpack(value))
			else
				attributes[key] = c.GetID(value)
			end
		end
	end
end

function c.AddSpell(spellName, tag, attributes)
	local name = spellName
	if tag then
		name = name .. " " .. tag
	end
	if lib.A.Spells == nil then
		lib.A.Spells = {}
	elseif lib.A.Spells[name] then
		print("Warning:", name, "is already defined")
	end
	if attributes == nil then
		attributes = {}
	end
	for k, v in pairs(attributes) do
		convertToIDs(attributes, k, "ID", "Debuff%d*", "Buff%d*")
	end
	if attributes.ID == nil then
		attributes.ID = c.GetID(spellName)
	end
	lib.A.Spells[name] = attributes
	return attributes
end

function c.AddOptionalSpell(name, tag, attributes, color)
	local spell = c.AddSpell(name, tag, attributes)
	spell.Continue = true
	if color ~= nil then
		spell.FlashColor = color
	elseif spell.FlashColor == nil then
		spell.FlashColor = "yellow"
	end
	return spell
end

function c.AddInterrupt(name)
	return c.AddOptionalSpell(name, nil, { Interrupt = true }, "aqua")
end

function c.AddTaunt(name, tag, attributes)
	return c.AddOptionalSpell(name, tag, { CheckFirst = c.CheckFirstForTaunts })
end

function c.CloneSpell(sourceName, tag, attributes)
	local sourceAttributes = lib.A.Spells[sourceName]
	if sourceAttributes == nil then
		print("Cannot clone", sourceName, "if it does not exist!")
		return
	end
	
	local spell = c.AddSpell(sourceName, tag, attributes)
	for k, v in pairs(sourceAttributes) do
		if spell[k] == nil then
			spell[k] = v
		end
	end
	return spell
end

function c.PriorityFlash(...)
	local flashed = nil
	local defaultColor
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local spell = c.GetSpell(name)
		local color = spell.FlashColor
		if color == nil and c.AoE then
			spell.FlashColor = "purple"
		end
		local success = s.CheckThenFlash(spell)
		spell.FlashColor = color
		if success then
			flashed = name
			if not spell.Continue then
				break
			end
		end
	end
	return flashed
end

function c.FlashAll(...)
	local flashed = false
	for i = 1, select("#", ...) do
		if s.CheckThenFlash(c.GetSpell(select(i, ...))) then
			flashed = true
		end
	end
	return flashed
end

function c.GetGroupMembers()
	local last = 0
	local max = math.max(1, GetNumGroupMembers())
	local type
	if IsInRaid() then
		type = "raid"
	else
		type = "party"
	end
	return function()
		last = last + 1
		if last < max then
			return type .. last
		elseif last == max and type ~= "raid" then
			return "player"
		end
	end
end

function c.GetHastedTime(unhastedTime)
	return unhastedTime / (1 + UnitSpellHaste("player") / 100)
end

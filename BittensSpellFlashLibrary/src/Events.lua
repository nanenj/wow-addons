local libName, lib = ...
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local ActionBarActionEventsFrame = ActionBarActionEventsFrame
local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitIsUnit = UnitIsUnit
local math = math
local pairs = pairs
local print = print
local select = select
local type = type

local managedDots = {}
local registeredAddons = {}
local currentSpells = {}
--[[
local template = {
	Name = "Spell Name",
	Target = "Unit ID",
	ID = spellID, -- nil until CAST
	Status = "Queued/Casting/Interrupted",
	Cost = "Mana/Focus/etc cost", -- nil until CAST
	GCDStart = GetTime(),
	CastStart = GetTime(),
}
--]]

-------------------------------------------------------------- Public Functions
function c.RegisterForEvents(a)
	registeredAddons[a] = true
end

function c.ManageDotRefresh(name, unhastedTick, spellID)
	if not spellID then
		spellID = c.GetID(name)
	end
	if not managedDots[spellID] then
		managedDots[spellID] = {}
	end
	managedDots[spellID][c.GetSpell(name)] = unhastedTick
end

function c.GetCastingInfo()
	for _, info in pairs(currentSpells) do
		if info.Status == "Casting" then
			return info
		end
	end
end

function c.GetQueuedInfo()
	for _, info in pairs(currentSpells) do
		if info.Status == "Queued" then
			return info
		end
	end
end

local function nameMatches(info, name)
	return s.SpellName(c.GetID(name), true) == info.Name
end

function c.InfoMatches(info, ...)
	if info ~= nil then
		for i = 1, select("#", ...) do
			local name = select(i, ...)
			if type(name) == "table" then
				for _, name in pairs(name) do
					if nameMatches(info, name) then
						return true
					end
				end
			elseif nameMatches(info, name) then
				return true
			end
		end
	end
end

------------------------------------------------------- Internal Event Handling
local LABFrame

local frame = CreateFrame("frame")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
frame:RegisterEvent("UNIT_SPELLCAST_START")
--frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
--frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ADDON_LOADED")

local function fireEvent(functionName, ...)
	for a, _ in pairs(registeredAddons) do
		local rotation = c.GetCurrentRotation(a)
		if rotation ~= nil
			and rotation[functionName] ~= nil then
			
			c.Init(a)
			rotation[functionName](...)
		end
	end
end

local function handleLogEvent(...)
	local source = select(5, ...)
	if source == nil or not UnitIsUnit(source, "player") then
		return
	end
--c.Debug("Lib", ...)
	
	local event = select(2, ...)
	local target = select(9, ...)
	local spellID = select(12, ...)
	local spellSchool = select(13, ...)
--c.Debug("Lib", event, target, spellID, spellSchool)
	if event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
		local amount = select(15, ...)
		local damageSchool = select(17, ...)
		local critical = select(21, ...)
		fireEvent(
			"SpellDamage",
			spellID,
			target,
			amount,
			critical,
			spellSchool,
			damageSchool,
			event == "SPELL_PERIODIC_DAMAGE")
	elseif event == "SPELL_MISSED" then
		fireEvent("SpellMissed", spellID, target, spellSchool)
	elseif event == "SPELL_AURA_APPLIED"
		or event == "SPELL_AURA_REFRESH"
		or event == "SPELL_AURA_APPLIED_DOSE" then
		
		fireEvent("AuraApplied", spellID, target, spellSchool)
	elseif event == "SPELL_AURA_REMOVED"
		or event == "SPELL_AURA_REMOVED_DOSE" then
	
		fireEvent("AuraRemoved", spellID, target, spellSchool)
	elseif event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then
		local amount = select(15, ...)
		local overheal = select(16, ...)
		fireEvent(
			"SpellHeal",
			spellID,
			target,
			amount,
			overheal,
			spellSchool,
			event == "SPELL_PERIODIC_HEAL")
	elseif event == "SPELL_ENERGIZE" then
		local amount = select(15, ...)
		fireEvent("Energized", spellID, amount)
	end
end

local function printCurrentSpells()
	local list = ""
	for id, info in pairs(currentSpells) do
		c.Debug("Lib", " ", id, info.Name,
			"Target:", info.Target,
			"ID:", info.ID or "?",
			"Status:", info.Status)
	end
end

lib.LastGCD = 1.5
frame:SetScript("OnEvent", 
	function(self, event, ...)
		if event == "ADDON_LOADED" then
			if select(1, ...) == libName then
				return
			end
			
			if LibStub and LibStub.libs["LibActionButton-1.0"] then
				LABFrame = LibStub.libs["LibActionButton-1.0"].eventFrame
			end
		end

		local gcd, totalGcd = s.GlobalCooldown()
		if totalGcd and totalGcd > 0 then
			lib.LastGCD = totalGcd
		end
		 
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			handleLogEvent(...)
			return
		end
		
		if event == "PLAYER_REGEN_ENABLED" then
			fireEvent("LeftCombat")
			return
		end
		
		local unitID = select(1, ...)
		local spell = select(2, ...)
		if unitID ~= "player" then
			return
		end
		
--c.Debug("Lib", event, spell)
		local info
		if event == "UNIT_SPELLCAST_SENT" then
			local target = select(4, ...)
			local lineID = select(5, ...)
			local gcdStart = GetTime() + s.GetCasting(nil, "player")
			local lag = select(3, GetNetStats()) / 1000
			info = {
				LineID = lineID,
				Name = spell,
				Target = target,
				Status = "Queued",
				GCDStart = gcdStart,
				CastStart = math.max(gcdStart, GetTime() + 2 * lag),
			}
			currentSpells[lineID] = info
			fireEvent("CastQueued", info)
--printCurrentSpells()
			return
		end
		
		local lineID = select(4, ...)
		local spellID = select(5, ...)
		info = currentSpells[lineID]
		if info == nil then
			if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				info = c.GetCastingInfo()
				if info == nil then
					return
				end
				
				lineID = info.LineID
			else
--c.Debug("Lib", "  no record of spell", lineID)
				return
			end 
		end
		info.ID = spellID
		
		if event == "UNIT_SPELLCAST_START" then
			info.Status = "Casting"
			info.Cost = s.SpellCost(info.Name)
			fireEvent("CastStarted", info)
			
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			if managedDots[info.ID] then
				for z, unhasted in pairs(managedDots[info.ID]) do
					local tick = c.GetHastedTime(unhasted)
					z.EarlyRefresh = tick
					c.Debug("Library", info.Name, "ticks every", tick)
				end
			end
			if s.Channeling(info.name, "player") then
				if info.Status == "Queued" then
					info.Status = "Casting"
					info.Cost = 0
					fireEvent("CastStarted", info)
				end
			else
				fireEvent("CastSucceeded", info)
				currentSpells[lineID] = nil
			end
			
		elseif event == "UNIT_SPELLCAST_FAILED"
			or event == "UNIT_SPELLCAST_FAILED_QUIET" then
			
			if info.Status == "Casting" then
				fireEvent("CastFailed", info)
			end
			currentSpells[lineID] = nil
			
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			if info.Status == "Interrupted" then
				fireEvent("CastFailed", info)
				currentSpells[lineID] = nil
			else
				info.Status = "Interrupted"
			end
		
		elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			fireEvent("CastSucceeded", info)
			currentSpells[lineID] = nil
			
		else
			print(event, "unhandled")
		end
--printCurrentSpells()
	end
)

------------------------------------------------------- Disable Proc Hilighting
local is = IsSpellOverlayed
local isnt = function() return false end
local show = ActionButton_ShowOverlayGlow
local noshow = function() end

s.AddSettingsListener(
	function()
		c.EnableDefaultProcHilighting()
	end
)

function c.EnableDefaultProcHilighting()
	IsSpellOverlayed = is
	ActionButton_ShowOverlayGlow = show
	if LABFrame then 
		LABFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") 
	end
end

function c.DisableDefaultProcHilighting()
	IsSpellOverlayed = isnt
	ActionButton_ShowOverlayGlow = noshow
	if LABFrame then 
		LABFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") 
	end
end

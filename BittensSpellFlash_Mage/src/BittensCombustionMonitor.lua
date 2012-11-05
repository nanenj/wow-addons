local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

a.BCM = {}
local bcm = a.BCM

local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellCritChance = GetSpellCritChance
local UnitDebuff = UnitDebuff
local UnitIsUnit = UnitIsUnit
local UnitSpellHaste = UnitSpellHaste
local floor = floor
local pairs = pairs
local select = select

------------------------------------------------------------------ Calculations
local function countDebuff(name, delay)
	local duration = 0
	if delay then
		duration = c.GetBusyTime(true)
	end
	return s.MyDebuffDuration(c.GetID(name)) > duration
end

function bcm.PredictDamage(delay, debug)
	local perTick = 0
	local spellPower = GetSpellBonusDamage(3)
	if debug then
		c.Debug("Combustion", "Spell Power:", spellPower)
	end
	if countDebuff("Pyroblast", delay) then
		local tick = 337 + spellPower / 2.778
		perTick = perTick + tick / 3
		if debug then
			c.Debug("Combustion", "Pyroblast Tick:", tick)
		end
	end
	if countDebuff("Ignite", delay) then
		local tick = select(
			14, 
			UnitDebuff("target", s.SpellName(c.GetID("Ignite")), nil, "PLAYER"))
		perTick = perTick + tick / 2
		if debug then
			c.Debug("Combustion", "Ignite Tick:", tick)
		end
	end
	
	local numTicks = floor(.5 + 10 * (1 + UnitSpellHaste("player") / 100))
	local crit = (GetSpellCritChance(3) - 1.8) / 100
	local total = perTick * numTicks * (1.055 * crit + 1)
	
	if debug then
		c.Debug("Combustion", "Num Ticks:", numTicks)
		c.Debug("Combustion", "Current Crit:", crit)
		c.Debug("Combustion", "Estimate Per Tick:", perTick)
		c.Debug("Combustion", "Total Estimate:", total)
	end
	return total, perTick, numTicks, crit
end

-------------------------------------------------------------------- The Window
local window = CreateFrame("Frame", nil, UIParent)
window:SetFrameStrata("HIGH")
window:SetSize(90, 45)
window:EnableMouse(true)
window:SetMovable(true)
window:RegisterForDrag("LeftButton")
window:CreateTitleRegion():SetAllPoints(true)

local function createLine(anchor)
	local line = window:CreateFontString()
	line:SetPoint(anchor)
	line:SetSize(window:GetWidth(), window:GetHeight() / 3)
	line:SetJustifyH("LEFT")
	line:SetFont("Fonts\\FRIZQT__.TTF", 10) 
	line:SetTextColor(1, 1, 1)
	return line
end

local line1 = createLine("TOP")
local line2 = createLine("CENTER")
local line3 = createLine("BOTTOM")

local function saveWindowPosition()
	local settings = CombustionMonitorSettings
	if settings == nil then
		settings = {}
		CombustionMonitorSettings = settings
	end
	settings.WindowPoints = {}
	for i = 1, window:GetNumPoints() do
		local point, relativeTo, relativePoint, xoffset, yoffset
			= window:GetPoint(i)
		settings.WindowPoints[i] = {
			point = point,
			relativePoint = relativePoint,
			xoffset = xoffset,
			yoffset = yoffset }
	end
end

local function positionWindow()
	local settings = CombustionMonitorSettings
	if settings == nil then
		window:SetPoint("CENTER")
	else
		for _, point in pairs(settings.WindowPoints) do
			window:SetPoint(
				point.point,
				nil,
				point.relativePoint,
				point.xoffset,
				point.yoffset)
		end
	end
end

function bcm.UpdateVisibility()
	local hide = s.TalentMastery() ~= 2
		or a.GetConfig("fire_off")
		or a.GetConfig("hide_BCM")
		or not s.GetModuleFlashable(AddonName)
		or (s.config.in_combat_only and not s.InCombat())
	local isShowing = window:IsShown()
	if hide and isShowing then
		window:Hide()
	elseif not hide and not isShowing then
		window:Show()
	end
end
s.AddSettingsListener(a.UpdateBCMVisibility)

SLASH_BITTENS_COMBUSTION_MONITOR1 = "/bcm"
function SlashCmdList.BITTENS_COMBUSTION_MONITOR(args)
	if string.find(args, "reset") then
		CombustionMonitorSettings = nil
		positionWindow()
	end
end

local function getDisplayText(damage, perTick)
	local text = floor(damage / 1000) .. "K"
	if igniteIsDirty then
		text = text .. "*"
	end
	text = text .. " (" .. floor(perTick / 1000 + .5) .. "K"
	if igniteIsDirty then
		text = text .. "*"
	end
	return text .. ")"
end

local function updateWindow()
	if not window:IsShown() then
		return
	end
	
	local damage, perTick, numTicks, crit
		= bcm.PredictDamage(false, false)
	local text = floor(crit * 1000 + .5) / 10 .. "%   x" .. numTicks
	line1:SetText(text)
	line2:SetText(getDisplayText(damage, perTick))
	line3:SetText(getDisplayText(bcm.PredictDamage(true, false)))
end

c.Init(a)
updateWindow()

------------------------------------------------------------------------ Events
local logHandlers = {}

function logHandlers.SPELL_PERIODIC_DAMAGE(spellID, ...)
	if spellID == c.GetID("Combustion DoT") then
		local tick = select(15, ...)
		c.Debug("Combustion", "Acutal Combustion tick:", tick)
	end
end

function logHandlers.SPELL_CAST_SUCCESS(spellID, ...)
	if spellID == c.GetID("Combustion") then
		bcm.PredictDamage(false, true)
	end
end

function logHandlers.SPELL_AURA_APPLIED(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_REMOVED(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_APPLIED_DOSE(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_REMOVED_DOSE(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_REFRESH(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_BROKEN(spellID, ...)
	updateWindow()
end

function logHandlers.SPELL_AURA_BROKEN_SPELL(spellID, ...)
	updateWindow()
end

local eventHandlers = {}

function eventHandlers.ADDON_LOADED(addonName)
	if addonName == AddonName then
		positionWindow()
	end
end

function eventHandlers.PLAYER_LOGOUT()
	saveWindowPosition()
end

function eventHandlers.UNIT_SPELLCAST_START()
	updateWindow()
end

function eventHandlers.UNIT_SPELLCAST_STOP()
	updateWindow()
end

function eventHandlers.UNIT_SPELLCAST_SUCCEEDED()
	updateWindow()
end

function eventHandlers.COMBAT_LOG_EVENT_UNFILTERED(...)
	local source = select(5, ...)
	if source == nil or not UnitIsUnit(source, "player") then
		return
	end
	
	local event = select(2, ...)
	if logHandlers[event] then
		logHandlers[event](select(12, ...), ...)
	end
end

for event, _ in pairs(eventHandlers) do
	window:RegisterEvent(event)
end
window:SetScript("OnEvent", function(self, event, ...)
	eventHandlers[event](...)
end)

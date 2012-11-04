-- Pawn by Vger-Azjol-Nerub
-- www.vgermods.com
-- © 2006-2012 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
-- See Readme.htm for more information.

-- 
-- Version 1.6.9: updated Wowhead scales
------------------------------------------------------------


PawnVersion = 1.609

-- Pawn requires this version of VgerCore:
local PawnVgerCoreVersionRequired = 1.08

-- Floating point math
local PawnEpsilon = 0.0000000001

-- Caching
-- 	An item in the cache has the following properties: Name, NumLines, UnknownLines, Stats, SocketBonusStats, UnenchantedStats, UnenchantedSocketBonusStats, Values, Link, PrettyLink, Level, Rarity, ID, InvType, Texture, ShouldUseGems
--	(See PawnGetEmptyCachedItem.)
--	An entry in the Values table is an ordered array in the following format:
--	{ ScaleName, Value, UnenchantedValue, UseRed, UseYellow, UseBlue }
local PawnItemCache = nil
local PawnItemCacheMaxSize = 50

local PawnScaleTotals = { }
-- PawnScaleBestGems["Scale name"] = {
-- 	["RedSocket"] = { gem info, gem info },
--	["YellowSocket"] = { gem info },
--	["BlueSocket"] = { gem info },
--	["PrismaticSocket"] = { gem info },
--	["MetaSocket"] = { gem info },
--	["BestGems"] = { ["Value"] = 123.0, ["String"] = "Red/Yellow", ["RedSocket"] = true, ["YellowSocket"] = true, ["BlueSocket"] = false } }
PawnScaleBestGems = { }

PawnPlayerFullName = nil
local PawnPlayerEnteredWorld

-- Formatting
local PawnEnchantedAnnotationFormat = nil
local PawnUnenchantedAnnotationFormat = nil
local PawnNoValueAnnotationFormat = nil

-- Plugin scale providers

-- PawnScaleProviders["Wowhead"] = { ["Name"] = "Wowhead scales", ["Function"] = <function> }
PawnScaleProviders = { }
local PawnScaleProvidersInitialized = nil

-- "Constants"
local PawnCurrentScaleVersion = 1

local PawnTooltipAnnotation = " " .. PawnQuestionTexture -- (?) texture defined in Localization.lua

local PawnScaleColorDarkFactor = 0.75 -- the unenchanted color is 75% of the enchanted color

PawnShowAsterisksNever = 0
PawnShowAsterisksNonzero = 1
PawnShowAsterisksAlways = 2
PawnShowAsterisksNonzeroNoText = 3

PawnButtonPositionHidden = 0
PawnButtonPositionLeft = 1
PawnButtonPositionRight = 2

PawnImportScaleResultSuccess = 1
PawnImportScaleResultAlreadyExists = 2
PawnImportScaleResultTagError = 3

PawnIgnoreStatValue = -1000000
PawnBigUpgradeThreshold = 100 -- 100 = 10000% upgrade: don't display upgrade numbers that large

-- Data used by PawnGetSlotsForItemType.
local PawnItemEquipLocToSlot1 = 
{
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 13,
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = 16,
	INVTYPE_SHIELD = 17,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_RANGED = 16,
	INVTYPE_RANGEDRIGHT = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17,
	INVTYPE_TABARD = 19,
}
local PawnItemEquipLocToSlot2 = 
{
	INVTYPE_FINGER = 12,
	INVTYPE_TRINKET = 14,
	INVTYPE_WEAPON = 17,
}

local PawnReforgeableStats = { "CritRating", "DodgeRating", "ExpertiseRating", "HasteRating", "HitRating", "MasteryRating", "ParryRating", "Spirit" }
local PawnStatFriendlyNames = -- Currently only contains stat names used for reforging.
{
	["CritRating"] = ITEM_MOD_CRIT_RATING_SHORT,
	["DodgeRating"] = ITEM_MOD_DODGE_RATING_SHORT,
	["ExpertiseRating"] = ITEM_MOD_EXPERTISE_RATING_SHORT,
	["HasteRating"] = ITEM_MOD_HASTE_RATING_SHORT,
	["HitRating"] = ITEM_MOD_HIT_RATING_SHORT,
	["MasteryRating"] = ITEM_MOD_MASTERY_RATING_SHORT,
	["ParryRating"] = ITEM_MOD_PARRY_RATING_SHORT,
	["Spirit"] = ITEM_MOD_SPIRIT_SHORT,
}

-- Don't taint the global variable "_".
local _


------------------------------------------------------------


-- Called when an event that Pawn cares about is fired.
function PawnOnEvent(Event, arg1, arg2, ...)
	if Event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		-- REVIEW: This fires a TON every time you change zones. ***
		PawnOnInventoryChanged()
	elseif Event == "ITEM_LOCKED" then
		PawnOnItemLocked(arg1, arg2)
	elseif Event == "ADDON_LOADED" then
		if arg1 == "Pawn" then PawnInitialize() end
		PawnOnAddonLoaded(arg1, ...)
	elseif Event == "PLAYER_ENTERING_WORLD" then -- was UPDATE_BINDINGS
		if not PawnPlayerEnteredWorld then
			PawnSetDefaultKeybindings()
			PawnPlayerEnteredWorld = true
		end
	elseif Event == "PLAYER_LOGOUT" then
		PawnOnLogout()
	elseif Event == "VARIABLES_LOADED" then
		-- LinkWrangler compatibility
		if LinkWrangler then
			LinkWrangler.RegisterCallback("Pawn", PawnLinkWranglerOnTooltip, "refresh")
			LinkWrangler.RegisterCallback("Pawn", PawnLinkWranglerOnTooltip, "refreshcomp")
		end
	end 
end

-- Initializes Pawn after all saved variables have been loaded.
function PawnInitialize()

	-- Check the current version of VgerCore.
	if (not VgerCore) or (not VgerCore.Version) or (VgerCore.Version < PawnVgerCoreVersionRequired) then
		if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cfffe8460" .. PawnLocal.NeedNewerVgerCoreMessage) end
		message(PawnLocal.NeedNewerVgerCoreMessage)
		return
	end

	SLASH_PAWN1 = "/pawn"
	SlashCmdList["PAWN"] = PawnCommand
	
	-- Set any unset options to their default values.  If the user is a new Pawn user, all options
	-- will be set to default values.  If upgrading, only missing options will be set to default values.
	PawnInitializeOptions()
	
	-- Now, load any plugins that are ready to be loaded.
	PawnInitializePlugins()
	
	-- Go through the user's scales and check them for errors.
	for ScaleName, _ in pairs(PawnCommon.Scales) do
		PawnCorrectScaleErrors(ScaleName)
	end
	
	-- Then, recalculate totals.
	-- This must be done after checking for errors is completed on all scales because it can trigger other recalculations.
	for ScaleName, _ in pairs(PawnCommon.Scales) do
		PawnRecalculateScaleTotal(ScaleName)
	end
	
	-- Adjust UI elements.
	PawnUI_InventoryPawnButton_Move()
	
	-- Hook into events.
	
	-- UI functions
	hooksecurefunc("DeleteCursorItem",
		function()
			PawnOnItemLost(PawnLastCursorItemID)
		end)
	hooksecurefunc("UseContainerItem",
		function(BagID, Slot)
			if MerchantFrame:IsShown() then
				local ItemLink = GetContainerItemLink(BagID, Slot)
				if ItemLink then PawnOnItemLost(PawnGetItemIDFromLink(ItemLink)) end
			end
		end)
	hooksecurefunc("PickupMerchantItem",
		function(Index)
			if Index == 0 then PawnOnItemLost(PawnLastCursorItemID) end
		end)
	
	-- Main game tooltip
	hooksecurefunc(GameTooltip, "SetAuctionItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetAuctionItem", ...) end)
	hooksecurefunc(GameTooltip, "SetAuctionSellItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetAuctionSellItem", ...) end)
	hooksecurefunc(GameTooltip, "SetBagItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetBagItem", ...) end)
	hooksecurefunc(GameTooltip, "SetBuybackItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetBuybackItem", ...) end)
	hooksecurefunc(GameTooltip, "SetExistingSocketGem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetExistingSocketGem", ...) end)
	hooksecurefunc(GameTooltip, "SetGuildBankItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetGuildBankItem", ...) end)
	hooksecurefunc(GameTooltip, "SetHyperlink", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetHyperlink", ...) end)
	hooksecurefunc(GameTooltip, "SetInboxItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetInboxItem", ...) end)
	hooksecurefunc(GameTooltip, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetInventoryItem", ...) end)
	hooksecurefunc(GameTooltip, "SetItemByID", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetItemByID", ...) end)
	hooksecurefunc(GameTooltip, "SetLootItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetLootItem", ...) end)
	hooksecurefunc(GameTooltip, "SetLootRollItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetLootRollItem", ...) end)
	hooksecurefunc(GameTooltip, "SetMerchantItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetMerchantItem", ...) end)
	hooksecurefunc(GameTooltip, "SetMissingLootItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetMissingLootItem", ...) end)
	hooksecurefunc(GameTooltip, "SetQuestItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetQuestItem", ...) end)
	hooksecurefunc(GameTooltip, "SetQuestLogItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetQuestLogItem", ...) end)
	hooksecurefunc(GameTooltip, "SetSendMailItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetSendMailItem", ...) end)
	hooksecurefunc(GameTooltip, "SetSocketGem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetSocketGem", ...) end)
	hooksecurefunc(GameTooltip, "SetTradePlayerItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradePlayerItem", ...) end)
	hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradeSkillItem", ...) end)
	hooksecurefunc(GameTooltip, "SetTradeTargetItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetTradeTargetItem", ...) end)
	hooksecurefunc(GameTooltip, "SetVoidItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetVoidItem", ...) end)
	hooksecurefunc(GameTooltip, "SetVoidDepositItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetVoidDepositItem", ...) end)
	hooksecurefunc(GameTooltip, "SetVoidWithdrawalItem", function(self, ...) PawnUpdateTooltip("GameTooltip", "SetVoidWithdrawalItem", ...) end)
	hooksecurefunc(GameTooltip, "SetTrainerService",
		function(self, Index)
			local ItemLink = GetTrainerServiceItemLink(Index)
			if ItemLink then PawnUpdateTooltip("GameTooltip", "SetHyperlink", ItemLink) end
		end)
	hooksecurefunc(GameTooltip, "Hide", function(self, ...) PawnLastHoveredItem = nil end)
	
	-- World map tooltip (for quest rewards)
	hooksecurefunc(WorldMapTooltip, "SetQuestLogItem", function(self, ...) PawnUpdateTooltip("WorldMapTooltip", "SetQuestLogItem", ...) end)
	hooksecurefunc(WorldMapTooltip, "Hide", function(self, ...) PawnLastHoveredItem = nil end)
	
	-- The item link tooltip (only hook it if it's an actual item)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink",
		function(self, ItemLink, ...)
			-- Attach an icon to the tooltip first so that an existing icon can be hidden if the new hyperlink doesn't have one.
			PawnAttachIconToTooltip(ItemRefTooltip, false, ItemLink)
			if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
			PawnUpdateTooltip("ItemRefTooltip", "SetHyperlink", ItemLink, ...)
		end)
	VgerCore.HookInsecureScript(ItemRefTooltip, "OnEnter", function() local _; _, PawnLastHoveredItem = ItemRefTooltip:GetItem() end)
	VgerCore.HookInsecureScript(ItemRefTooltip, "OnLeave", function() PawnLastHoveredItem = nil end)
	VgerCore.HookInsecureScript(ItemRefTooltip, "OnMouseUp",
		function(object, button)
			if button == "RightButton" then
				local _, ItemLink = ItemRefTooltip:GetItem()
				PawnUI_SetCompareItemAndShow(2, ItemLink)
			end
		end)
	
	-- The group loot roll window
	local LootRollClickHandler =
		function(object, button)
			if button == "RightButton" then
				local ItemLink = GetLootRollItemLink(object:GetParent().rollID)
				PawnUI_SetCompareItemAndShow(2, ItemLink)
			end
		end
	GroupLootFrame1.IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame2.IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame3.IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	GroupLootFrame4.IconFrame:SetScript("OnMouseUp", LootRollClickHandler)
	VgerCore.HookInsecureScript(GroupLootFrame1, "OnShow", PawnUI_GroupLootFrame_OnShow)
	VgerCore.HookInsecureScript(GroupLootFrame2, "OnShow", PawnUI_GroupLootFrame_OnShow)
	VgerCore.HookInsecureScript(GroupLootFrame3, "OnShow", PawnUI_GroupLootFrame_OnShow)
	VgerCore.HookInsecureScript(GroupLootFrame4, "OnShow", PawnUI_GroupLootFrame_OnShow)
	
	-- The loot history window
	hooksecurefunc("LootHistoryFrame_UpdateItemFrame", PawnUI_LootHistoryFrame_UpdateItemFrame)
	
	-- The loot won window
	hooksecurefunc("LootWonAlertFrame_SetUp", PawnUI_LootWonAlertFrame_SetUp)
	
	-- The "currently equipped" tooltips (two, in case of rings, trinkets, and dual wielding)
	hooksecurefunc(ShoppingTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip1, true) end)
	hooksecurefunc(ShoppingTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip2, true) end)
	--if ShoppingTooltip3 then
		-- In current builds, this returns the same ItemLink as the original item (the view-as-level parameter hasn't changed).
		--hooksecurefunc(ShoppingTooltip3, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ShoppingTooltip3", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ShoppingTooltip3, true) end)
	--end
	hooksecurefunc(ItemRefShoppingTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefShoppingTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ItemRefShoppingTooltip1, true) end)
	hooksecurefunc(ItemRefShoppingTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefShoppingTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ItemRefShoppingTooltip2, true) end)
	hooksecurefunc(ShoppingTooltip1, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip1", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip1, true) end) -- EQCompare compatibility
	hooksecurefunc(ShoppingTooltip2, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip2", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip2, true) end) -- EQCompare compatibility
	--if ShoppingTooltip3 then
		--hooksecurefunc(ShoppingTooltip3, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ShoppingTooltip3", "SetInventoryItem", ...) PawnAttachIconToTooltip(ShoppingTooltip3, true) end) -- EQCompare compatibility, assuming EQCompare adds support for the third shopping tooltip
	--end
	hooksecurefunc(WorldMapCompareTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("WorldMapCompareTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(WorldMapCompareTooltip1, true) end)
	hooksecurefunc(WorldMapCompareTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("WorldMapCompareTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(WorldMapCompareTooltip2, true) end)
	--hooksecurefunc(WorldMapCompareTooltip3, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("WorldMapCompareTooltip3", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(WorldMapCompareTooltip3, true) end)
		
	-- MultiTips compatibility
	if MultiTips then
		VgerCore.HookInsecureFunction(ItemRefTooltip2, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip2", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip2, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip3, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip3", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip3, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip4, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip4", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip4, false, ItemLink) end)
		VgerCore.HookInsecureFunction(ItemRefTooltip5, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ItemRefTooltip5", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ItemRefTooltip5, false, ItemLink) end)
	end
	
	-- EquipCompare compatibility
	if ComparisonTooltip1 then
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end)
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetHyperlinkCompareItem", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetHyperlinkCompareItem", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end)
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetInventoryItem", ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end) -- EquipCompare with CharactersViewer
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetInventoryItem", function(self, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetInventoryItem", ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end) -- EquipCompare with CharactersViewer
		VgerCore.HookInsecureFunction(ComparisonTooltip1, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip1", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip1, true) end) -- EquipCompare with Armory
		VgerCore.HookInsecureFunction(ComparisonTooltip2, "SetHyperlink", function(self, ItemLink, ...) PawnUpdateTooltip("ComparisonTooltip2", "SetHyperlink", ItemLink, ...) PawnAttachIconToTooltip(ComparisonTooltip2, true) end) -- EquipCompare with Armory
	end
	
	-- Outfitter compatibility
	if Outfitter and Outfitter._ExtendedCompareTooltip then
		VgerCore.HookInsecureFunction(Outfitter._ExtendedCompareTooltip, "AddShoppingLink", function(self, pTitle, pName, pLink, ...) PawnUpdateTooltip("OutfitterCompareTooltip" .. self.NumTooltipsShown, "SetHyperlink", pLink) end)
	end
	
	-- AtlasLoot Enhanced compatibility
	if AtlasLootTooltip then
		VgerCore.HookInsecureFunction(AtlasLootTooltip, "SetHyperlink", function(self, ...) PawnUpdateTooltip("AtlasLootTooltip", "SetHyperlink", ...) end)
	end
	
end

function PawnOnLogout()
	-- Uninitialize all scale provider plugins.
	PawnUnitializePlugins()
	-- Clear out cached best item lists for all disabled scales.
	if (not PawnCommon.ShowUpgradesOnTooltips) and (not PawnCommon.ShowLootUpgradeAdvisor) and (not PawnCommon.ShowQuestUpgradeAdvisor) then
		-- The user has disabled all upgrade options, so clear out all upgrade information.
		PawnInvalidateBestItems()
	else
		local Scale, _
		for _, Scale in pairs(PawnCommon.Scales) do
			local CharacterOptions = Scale.PerCharacterOptions[PawnPlayerFullName]
			if CharacterOptions and not CharacterOptions.Visible then
				-- If this scale is hidden for this character, we can remove the character options table entirely since
				-- Visible and BestItems are currently the only two members and we want to clear out BestItems for
				-- invisible scales.  (If more members are added in the future, this will need to be fleshed out.)
				Scale.PerCharacterOptions[PawnPlayerFullName] = nil
			end
		end
	end
end

function PawnOnAddonLoaded(AddonName)
	if AddonName == "Blizzard_InspectUI" then
		-- After the inspect UI is loaded, we want to hook it to add the Pawn button.
		PawnUI_InspectPawnButton_Attach()
	elseif AddonName == "Blizzard_ItemSocketingUI" then
		-- After the socketing UI is loaded, it gets a Pawn button too.
		PawnUI_SocketingPawnButton_Attach()
	elseif AddonName == "Blizzard_ReforgingUI" then
		-- After the reforging UI is loaded, it gets the Pawn Reforging Advisor.
		PawnUI_ReforgingAdvisor_Initialize()
	end
end

-- Resets all Pawn options and scales.  Used to set the saved variable to a default state.
function PawnResetOptions()
	PawnCommon = nil
	PawnOptions = nil
	PawnInitializeOptions()
end

-- Sets values for any options that don't have a value set yet.  Useful when upgrading.  This method can also be
-- called by any code that might run before initialization finishes to ensure that PawnCommon exists and is set up.
function PawnInitializeOptions()
	-- If either of the options tables don't exist yet, create them now.
	if not PawnCommon then PawnCommon = {} end
	if not PawnOptions then PawnOptions = {} end
	
	-- We need to know the player's full name for some server-specific settings.
	PawnPlayerFullName = UnitName("player") .. "-" .. GetRealmName()
	-- Save the last known player name to PawnOptions so that we can detect character renames and server
	-- transfers in the future.
	PawnOptions.LastPlayerFullName = PawnPlayerFullName
	
	-- Now, migrate all settings over to PawnCommon, and upgrade to the current version from any previous version
	-- of Pawn (or none at all).  Settings are respected in this order of preference:
	-- 1. Global settings in PawnCommon
	-- 2. Per-character settings in PawnOptions (used prior to Pawn 1.3)
	-- 3. The default values for the settings.
	PawnMigrateSetting("Debug", false)
	PawnMigrateSetting("Digits", 1)
	PawnMigrateSetting("ShowAsterisks", PawnShowAsterisksNonzero)
	PawnMigrateSetting("ShowItemID", false)
	PawnMigrateSetting("AlignNumbersRight", false)
	PawnMigrateSetting("ShowSpace", false)
	PawnMigrateSetting("ButtonPosition", PawnButtonPositionRight)
	PawnMigrateSetting("ShowTooltipIcons", true)
	
	-- Set default values for other new options.
	if PawnCommon.ShowUpgradesOnTooltips == nil then PawnCommon.ShowUpgradesOnTooltips = true end
	if PawnCommon.ShowValuesForUpgradesOnly == nil then PawnCommon.ShowValuesForUpgradesOnly = true end
	if PawnCommon.ColorTooltipBorder == nil then PawnCommon.ColorTooltipBorder = true end
	if PawnCommon.ShowUpgradeAdvisors ~= nil then
		-- If the user's upgrading from Pawn 1.5.4 or earlier, migrate the single upgrade advisors setting into the two settings in 1.5.5.
		if PawnCommon.ShowLootUpgradeAdvisor == nil then PawnCommon.ShowLootUpgradeAdvisor = PawnCommon.ShowUpgradeAdvisors end
		if PawnCommon.ShowQuestUpgradeAdvisor == nil then PawnCommon.ShowQuestUpgradeAdvisor = PawnCommon.ShowUpgradeAdvisors end
		PawnCommon.ShowUpgradeAdvisors = nil
	else
		-- Otherwise just default them to on.
		if PawnCommon.ShowLootUpgradeAdvisor == nil then PawnCommon.ShowLootUpgradeAdvisor = true end
		if PawnCommon.ShowQuestUpgradeAdvisor == nil then PawnCommon.ShowQuestUpgradeAdvisor = true end
	end
	if PawnCommon.ShowSocketingAdvisor == nil then PawnCommon.ShowSocketingAdvisor = true end
	if PawnCommon.ShowReforgingAdvisor == nil then PawnCommon.ShowReforgingAdvisor = true end

	-- Now, migrate all scales from this character over to PawnCommon.
	if not PawnCommon.Scales then PawnCommon.Scales = {} end
	if PawnOptions.Scales then
		-- Looks like there's one or more scales on this character that need to be migrated.
		for ScaleName, Scale in pairs(PawnOptions.Scales) do
			if PawnCommon.Scales[ScaleName] then
				-- This scale name already exists, so we have to make it unique first.
				-- First, try just appending the player name.
				-- If that's not good enough, start trying sequential numbers.  (Sigh; why do people need
				-- to make things so complicated?  Did you really need ten characters with the same name
				-- and identically named scales on each one?)
				ScaleName = ScaleName .. " (" .. UnitName("player") .. ")"
				local ScaleNameBase = ScaleName .. " ("
				local i = 0
				while PawnCommon.Scales[ScaleName] do
					i = i + 1
					ScaleName = ScaleNameBase .. i .. ")"
				end
			end
			
			-- We now have a unique name for this scale, so transfer it over to the master scale list.
			PawnCommon.Scales[ScaleName] = Scale
			Scale.PerCharacterOptions = { }
			Scale.PerCharacterOptions[PawnPlayerFullName] = { }
			if not Scale.Hidden then
				Scale.PerCharacterOptions[PawnPlayerFullName].Visible = true
			end
			Scale.NormalizationFactor = PawnOptions.NormalizationFactor
			Scale.Hidden = nil
		end
	end
	-- Now that migration is complete, remove all migrated scales from the per-character options.
	PawnOptions.Scales = nil
	
	-- These options have been removed or otherwise are no longer useful.
	PawnOptions.ShowItemLevel = nil
	PawnOptions.ShownGettingStarted = nil
	PawnOptions.NormalizationFactor = nil
	PawnCommon.ShowUnenchanted = nil
	
	-- Any new stuff since the last version they used?
	if (not PawnCommon.LastVersion) or (PawnCommon.LastVersion < 1.507) then
		-- When upgrading to 1.5.7, invalidate all best item data.
		PawnInvalidateBestItems()
	end
	PawnCommon.LastVersion = PawnVersion

	-- Finally, this stuff needs to get done after options are changed.
	PawnRecreateAnnotationFormats()
	
end

-- If the specified setting does not exist in the common settings list, this function first tries to migrate it from the
-- current character's settings (from Pawn 1.2 or earlier).  If it's not there either, it's set to a default value.
function PawnMigrateSetting(SettingName, Default)
	if PawnCommon[SettingName] ~= nil then
		PawnOptions[SettingName] = nil
		return
	end
	if PawnOptions[SettingName] ~= nil then
		PawnCommon[SettingName] = PawnOptions[SettingName]
		PawnOptions[SettingName] = nil
		return
	end
	PawnCommon[SettingName] = Default
end

-- Once per new version of Pawn that adds keybindings, bind the new actions to default keys.
function PawnSetDefaultKeybindings()
	-- It's possible that this will happen before the main initialization code, so we need to ensure that the
	-- default Pawn options have been set already.  Doing this multiple times is harmless.
	PawnInitializeOptions()

	if PawnOptions.LastKeybindingsSet == nil  then PawnOptions.LastKeybindingsSet = 0 end
	local BindingSet = false
	
	-- Keybindings for opening the Pawn UI and setting comparison items.
	if PawnOptions.LastKeybindingsSet < 1 then
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_TOGGLE_UI_DEFAULT_KEY, "PAWN_TOGGLE_UI") or BindingSet
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_COMPARE_LEFT_DEFAULT_KEY, "PAWN_COMPARE_LEFT") or BindingSet
		BindingSet = PawnSetKeybindingIfAvailable(PAWN_COMPARE_RIGHT_DEFAULT_KEY, "PAWN_COMPARE_RIGHT") or BindingSet
	end
	
	-- If any keybindings were changed, save the user's bindings.
	if BindingSet then
		local CurrentBindingSet = GetCurrentBindingSet()
		if CurrentBindingSet == 1 or CurrentBindingSet == 2 then
			SaveBindings(CurrentBindingSet)
		else
			VgerCore.Fail("GetCurrentBindingSet() returned unexpected value: " .. tostring(CurrentBindingSet))
		end
	end
	
	-- Record that we've set those keybindings, so we don't try to set them again in the future, even if
	-- the user clears them.
	PawnOptions.LastKeybindingsSet = 1
end

-- Sets a keybinding to its default value if it's not already assigned to something else.  Returns true if anything was changed.
function PawnSetKeybindingIfAvailable(Key, Binding)
	-- Is this key already bound?
	local ExistingBinding = GetBindingAction(Key)
	if not ExistingBinding or ExistingBinding == "" then
		-- Bind this key to its default Pawn action.
		SetBinding(Key, Binding)
		return true
	else
		-- This key is already bound, so do nothing.
		return false
	end
end

-- Returns an empty Pawn scale table.
function PawnGetEmptyScale()
	return
	{
		["SmartGemSocketing"] = true,
		["GemQualityLevel"] = PawnDefaultGemQualityLevel,
		["SmartMetaGemSocketing"] = true,
		["MetaGemQualityLevel"] = PawnDefaultMetaGemQualityLevel,
		["CogwheelQualityLevel"] = PawnDefaultCogwheelGemQualityLevel,
		["UpgradesFollowSpecialization"] = true,
		["PerCharacterOptions"] = { },
		["Values"] = { },
	}
end

-- Returns the default Pawn scale table.
function PawnGetDefaultScale()
	return 
	{
		["SmartGemSocketing"] = true,
		["GemQualityLevel"] = PawnDefaultGemQualityLevel,
		["SmartMetaGemSocketing"] = true,
		["MetaGemQualityLevel"] = PawnDefaultMetaGemQualityLevel,
		["CogwheelQualityLevel"] = PawnDefaultCogwheelGemQualityLevel,
		["UpgradesFollowSpecialization"] = true,
		["PerCharacterOptions"] = { },
		["Values"] =
		{
			["Strength"] = 1,
			["Agility"] = 1,
			["Stamina"] = 2/3,
			["Intellect"] = 1,
			["Spirit"] = 1,
			["Armor"] = 0.1,
			["Dps"] = 3.4,
			["ExpertiseRating"] = 1,
			["HitRating"] = 1,
			["CritRating"] = 1,
			["ResilienceRating"] = 1,
			["HasteRating"] = 1,
			["Ap"] = 0.5,
			["Hp5"] = 2,
			["Mana"] = 1/15,
			["Health"] = 1/15,
			["DodgeRating"] = 1,
			["ParryRating"] = 1,
			["SpellPower"] = 6/7,
			["SpellPenetration"] = 0.8,
			["AllResist"] = 2.5,
			["FireResist"] = 1,
			["ShadowResist"] = 1,
			["NatureResist"] = 1,
			["ArcaneResist"] = 1,
			["FrostResist"] = 1,
			["MetaSocketEffect"] = 72,
		},
	}
end

-- LinkWrangler compatibility
function PawnLinkWranglerOnTooltip(Tooltip, ItemLink)
	if not Tooltip then return end
	PawnUpdateTooltip(Tooltip:GetName(), "SetHyperlink", ItemLink)
	PawnAttachIconToTooltip(Tooltip, false, ItemLink)
end

-- If debugging is enabled, show a message; otherwise, do nothing.
function PawnDebugMessage(Message)
	if PawnCommon.Debug then
		VgerCore.Message(Message)
	end
end

-- Processes an Pawn slash command.
function PawnCommand(Command)
	if Command == "" then
		PawnUIShow()
	elseif Command == PawnLocal.DebugOnCommand then
		PawnCommon.Debug = true
		PawnResetTooltips()
		if PawnUIFrame_DebugCheck then PawnUIFrame_DebugCheck:SetChecked(PawnCommon.Debug) end
	elseif Command == PawnLocal.DebugOffCommand then
		PawnCommon.Debug = false
		PawnResetTooltips()
		if PawnUIFrame_DebugCheck then PawnUIFrame_DebugCheck:SetChecked(PawnCommon.Debug) end
	elseif Command == PawnLocal.BackupCommand then
		PawnUIExportAllScales()
	else
		PawnUsage()
	end
end

-- Displays Pawn usage information.
function PawnUsage()
	VgerCore.Message(" ")
	VgerCore.MultilineMessage(PawnLocal.Usage)
	VgerCore.Message(" ")
end

-- Returns an empty item for use in the item cache.
function PawnGetEmptyCachedItem(NewItemLink, NewItemName, NewNumLines)
	-- Also includes properties set to nil by default: Stats, SocketBonusStats, UnenchantedState, UnenchantedSocketBonusStats, Values, Level, ItemID
	return { Name = NewItemName, NumLines = NewNumLines, UnknownLines = {}, Link = NewItemLink }
end

-- Searches the item cache for an item, and either returns the correct cached item, or nil.
function PawnGetCachedItem(ItemLink, ItemName, NumLines)
	-- If the item cache is empty, skip all this...
	if (not PawnItemCache) or (#PawnItemCache == 0) then return end
	-- If debug mode is on, the cache is disabled.
	if PawnCommon.Debug then return end

	-- Otherwise, search the item cache for this item.
	local _
	for _, CachedItem in pairs(PawnItemCache) do
		if (not NumLines) or (NumLines == CachedItem.NumLines) then
			if ItemLink and CachedItem.Link then
				if ItemLink == CachedItem.Link then return CachedItem end
			else
				if ItemName == CachedItem.Name then return CachedItem end
			end
		end
	end
end

-- Adds an item to the item cache, removing existing items if necessary.
function PawnCacheItem(CachedItem)
	-- If debug mode is on, the cache is disabled.
	if PawnCommon.Debug then return end
	
	-- Cache it.
	if PawnItemCacheMaxSize <= 0 then return end
	if not PawnItemCache then PawnItemCache = {} end
	tinsert(PawnItemCache, CachedItem)
	while #PawnItemCache > PawnItemCacheMaxSize do
		tremove(PawnItemCache, 1)
	end
end

-- Clears the item cache.
function PawnClearCache()
	PawnItemCache = nil
	-- We should also clear out the gem cache when doing this.
	PawnClearCacheValuesOnly()
end

-- Clears only the calculated values for items in the cache, retaining things like stats.
function PawnClearCacheValuesOnly()
	local CachedItem, _
	-- First, the main item cache.
	if PawnItemCache then
		for _, CachedItem in pairs(PawnItemCache) do
			CachedItem.Values = nil
		end
	end
	-- Then, the gem cache.
	local GemTable
	for _, GemTable in pairs(PawnGemQualityTables) do
		for _, CachedItem in pairs(GemTable) do
			CachedItem[9] = nil
		end
	end
	for _, GemTable in pairs(PawnMetaGemQualityTables) do
		for _, CachedItem in pairs(GemTable) do
			CachedItem[9] = nil
		end
	end
	for _, GemTable in pairs(PawnCogwheelQualityTables) do
		for _, CachedItem in pairs(GemTable) do
			CachedItem[9] = nil
		end
	end
end

-- Clears all calculated values and causes them to be recalculated the next time tooltips are displayed.  The stats
-- will not be re-read next time, however.
function PawnResetTooltips()
	-- Clear out the calculated values in the cache, leaving item data.
	PawnClearCacheValuesOnly()
	-- Then, attempt to reset tooltips where possible.  On-hover tooltips don't need to be reset manually, but the
	-- item link tooltip does.
	PawnResetTooltip("ItemRefTooltip")
	PawnResetTooltip("ItemRefTooltip2") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip3") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip4") -- MultiTips compatibility
	PawnResetTooltip("ItemRefTooltip5") -- MultiTips compatibility
	PawnResetTooltip("ComparisonTooltip1") -- EquipCompare compatibility
	PawnResetTooltip("ComparisonTooltip2") -- EquipCompare compatibility
	PawnResetTooltip("AtlasLootTooltip") -- AtlasLoot compatibility
	-- Update advisors.
	if LootHistoryFrame then LootHistoryFrame_FullUpdate(LootHistoryFrame) end
end

-- Attempts to reset a single tooltip, causing Pawn values to be recalculated.  Returns true if successful.
function PawnResetTooltip(TooltipName)
	local Tooltip = getglobal(TooltipName)
	if not Tooltip or not Tooltip.IsShown or not Tooltip:IsShown() or not Tooltip.GetItem then return end
	
	local _, ItemLink = Tooltip:GetItem()
	if not ItemLink then return end
	
	Tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	Tooltip:SetHyperlink(ItemLink)
	Tooltip:Show()
	return true
end

-- Recalculates the total value of all stats in a scale, as well as the socket values if smart gem socketing is enabled.
function PawnRecalculateScaleTotal(ScaleName)
	-- Find the appropriate scale.
	local ThisScale = PawnCommon.Scales[ScaleName]
	local ThisScaleValues
	if ThisScale then ThisScaleValues = ThisScale.Values end
	if not ThisScaleValues then
		-- If the passed-in scale doesn't exist, remove it from our cache and exit.
		PawnScaleTotals[ScaleName] = nil
		PawnScaleBestGems[ScaleName] = nil
		return
	end
	
	-- Calculate the total.  When calculating the total value for a scale, ignore sockets.
	local Total = 0
	for StatName, Value in pairs(ThisScaleValues) do
		if Value and Value > 0 and StatName ~= "RedSocket" and StatName ~= "YellowSocket" and StatName ~= "BlueSocket" and StatName ~= "MetaSocket" and StatName ~= "MetaSocketEffect" and StatName ~= "PrismaticSocket" and StatName ~= "CogwheelSocket" then
			Total = Total + Value
		end
	end
	PawnScaleTotals[ScaleName] = Total
	
	-- If this scale has smart gem socketing enabled, also recalculate socket values.
	-- Even if smart gem socketing is disabled, still calculate gem info, because we will need it elsewhere in the UI.
	local BestPrismatic, BestRed, BestYellow, BestBlue, BestCogwheel, BestMeta
	if not PawnScaleBestGems[ScaleName] then PawnScaleBestGems[ScaleName] = { } end
	BestPrismatic, PawnScaleBestGems[ScaleName].PrismaticSocket = PawnFindBestGems(ScaleName, true, true, true)
	BestRed, PawnScaleBestGems[ScaleName].RedSocket = PawnFindBestGems(ScaleName, true, false, false)
	BestYellow, PawnScaleBestGems[ScaleName].YellowSocket = PawnFindBestGems(ScaleName, false, true, false)
	BestBlue, PawnScaleBestGems[ScaleName].BlueSocket = PawnFindBestGems(ScaleName, false, false, true)
	BestCogwheel, PawnScaleBestGems[ScaleName].CogwheelSocket = PawnFindBestGems(ScaleName, false, false, false, false, true)
	BestMeta, PawnScaleBestGems[ScaleName].MetaSocket = PawnFindBestGems(ScaleName, false, false, false, true, false)
	if ThisScale.SmartGemSocketing then
		ThisScale.Values.RedSocket = BestRed
		ThisScale.Values.YellowSocket = BestYellow
		ThisScale.Values.BlueSocket = BestBlue
		ThisScale.Values.PrismaticSocket = BestPrismatic
		ThisScale.Values.CogwheelSocket = BestCogwheel
	end
	if ThisScale.SmartMetaGemSocketing then
		ThisScale.Values.MetaSocket = BestMeta - (ThisScale.Values.MetaSocketEffect or 0)
	end
	
	-- Finally, find which gem colors have the highest raw values.
	local BestGemValue = 0
	local BestGemString = ""
	local BestGemRed, BestGemYellow, BestGemBlue = false, false, false
	if ThisScaleValues.RedSocket and ThisScaleValues.RedSocket > BestGemValue then
		BestGemValue = ThisScaleValues.RedSocket
		BestGemString = RED_GEM
		BestGemRed, BestGemYellow, BestGemBlue = true, false, false
	elseif ThisScaleValues.RedSocket == BestGemValue then
		BestGemString = BestGemString .. "/" .. RED_GEM
		BestGemRed = true
	end
	if ThisScaleValues.YellowSocket and ThisScaleValues.YellowSocket > BestGemValue then
		BestGemValue = ThisScaleValues.YellowSocket
		BestGemString = YELLOW_GEM
		BestGemRed, BestGemYellow, BestGemBlue = false, true, false
	elseif ThisScaleValues.YellowSocket == BestGemValue then
		BestGemString = BestGemString .. "/" .. YELLOW_GEM
		BestGemYellow = true
	end
	if ThisScaleValues.BlueSocket and ThisScaleValues.BlueSocket > BestGemValue then
		BestGemValue = ThisScaleValues.BlueSocket
		BestGemString = BLUE_GEM
		BestGemRed, BestGemYellow, BestGemBlue = false, false, true
	elseif ThisScaleValues.BlueSocket == BestGemValue then
		BestGemString = BestGemString .. "/" .. BLUE_GEM
		BestGemBlue = true
	end
	PawnScaleBestGems[ScaleName].BestGems =
	{
		["Value"] = BestGemValue,
		["String"] = BestGemString,
		["RedSocket"] = BestGemRed,
		["YellowSocket"] = BestGemYellow,
		["BlueSocket"] = BestGemBlue,
	}
end

-- Recreates the tooltip annotation format strings.
function PawnRecreateAnnotationFormats()
	-- REVIEW: When the number of digits is set to 0, we should use commas (LARGE_NUMBER_SEPERATOR) instead
	-- of a format string.  (These would have to be functions instead of just a format string.)  (Remember that the *SEPERATOR
	-- constants don't exist in every locale.)
	PawnNoValueAnnotationFormat = "%s%s:"
	PawnUnenchantedAnnotationFormat = PawnNoValueAnnotationFormat .. "  %." .. PawnCommon.Digits .. "f"
	PawnEnchantedAnnotationFormat = PawnUnenchantedAnnotationFormat .. "  %s(%." .. PawnCommon.Digits .. "f " .. PawnLocal.BaseValueWord .. ")"
end

-- Gets the item data for a specific item link.  Retrieves the information from the cache when possible; otherwise, it gets fresh information.
-- Return value type is the same as PawnGetCachedItem.
function PawnGetItemData(ItemLink)
	if not ItemLink then return end
	
	-- Only item links are supported; other links are not.
	if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
	
	-- If we have an item link, we can extract basic data from it from the user's WoW cache (not the Pawn item cache).
	-- We get a new, normalized version of ItemLink so that items don't end up in the cache multiple times if they're requested
	-- using different styles of links that all point to the same item.
	ItemID = PawnGetItemIDFromLink(ItemLink)
	local ItemName, NewItemLink, ItemRarity, ItemLevel, _, _, _, _, InvType, ItemTexture = GetItemInfo(ItemLink)
	if InvType == "INVTYPE_RELIC" or InvType == "INVTYPE_THROWN" then
		-- Relics might have sockets and therefore "stats" but they aren't equippable so they shouldn't get values, so just bail out now.
		return
	end
	if NewItemLink then
		ItemLink = NewItemLink
	else
		-- We didn't get a new item link.  This is almost certainly because the item is not in the user's local WoW cache.
		-- REVIEW: In the future, would it be possible to detect this case, and then poll the tooltip until item information
		-- comes back, and THEN parse and annotate it?  There's also an OnTooltipSetItem event.
	end
	
	-- Now, with that information, we can look up the item in the Pawn item cache.
	local Item = PawnGetCachedItem(ItemLink, ItemName, ItemNumLines)
	if Item and Item.Values then
		return Item
	end
	-- If Item is non-null but Item.Values is null, we're not done yet!

	-- If we don't have a cached item at all, that means we have to load a tooltip and parse it.
	if not Item then
		Item = PawnGetEmptyCachedItem(ItemLink, ItemName, ItemNumLines)
		Item.Rarity = ItemRarity
		Item.Level = ItemLevel
		Item.ID = ItemID
		if InvType ~= "" then Item.InvType = InvType end
		Item.Texture = ItemTexture
		if PawnCommon.Debug then
			PawnDebugMessage(" ")
			PawnDebugMessage("====================")
			local IDs = PawnGetItemIDsForDisplay(ItemLink)
			if IDs then
				PawnDebugMessage(ItemLink .. VgerCore.Color.Green .. " (" .. tostring(IDs) .. VgerCore.Color.Green .. ")")
			else
				PawnDebugMessage(ItemLink)
			end
		end
		
		-- First the enchanted stats.
		Item.Stats, Item.SocketBonusStats, Item.UnknownLines, Item.PrettyLink = PawnGetStatsFromTooltipWithMethod("PawnPrivateTooltip", true, "SetHyperlink", Item.Link)

		-- Then, the unenchanted stats.  But, we only need to do this if the item is enchanted or socketed.  PawnUnenchantItemLink
		-- will return nil if the item isn't enchanted, so we can skip that process.
		local UnenchantedItemLink = PawnUnenchantItemLink(ItemLink)
		if UnenchantedItemLink then
			PawnDebugMessage(" ")
			PawnDebugMessage(PawnLocal.UnenchantedStatsHeader)
			Item.UnenchantedStats, Item.UnenchantedSocketBonusStats = PawnGetStatsForItemLink(UnenchantedItemLink, true)
			if not Item.UnenchantedStats then
				PawnDebugMessage(PawnLocal.FailedToGetUnenchantedItemMessage)
			end
		else
			-- If there was no unenchanted item link, then it's because the original item was not
			-- enchanted.  So, the unenchanted item is the enchanted item; copy the stats over.
			-- (Don't just copy the reference, because then changes to one stat table would also
			-- change the other!)
			local TableCopy = {}
			if Item.Stats then
				for StatName, Value in pairs(Item.Stats) do
					TableCopy[StatName] = Value
				end
			end
			Item.UnenchantedStats = TableCopy
			TableCopy = {}
			if Item.SocketBonusStats then
				for StatName, Value in pairs(Item.SocketBonusStats) do
					TableCopy[StatName] = Value
				end
			end
			Item.UnenchantedSocketBonusStats = TableCopy
		end
		
		-- MetaSocketEffect is special: if it's present in the unenchanted version of an item it should appear
		-- in the enchanted version too, if the enchanted version's socket is full.
		if Item.UnenchantedStats and Item.Stats and Item.UnenchantedStats.MetaSocketEffect and not Item.Stats.MetaSocketEffect and not Item.Stats.MetaSocket then
			Item.Stats.MetaSocketEffect = Item.UnenchantedStats.MetaSocketEffect
		end
		
		-- Enchanted items should not get points for empty sockets, nor do they get socket bonuses if there are any empty sockets.
		if Item.Stats and (Item.Stats.PrismaticSocket or Item.Stats.RedSocket or Item.Stats.YellowSocket or Item.Stats.BlueSocket or Item.Stats.MetaSocket or Item.Stats.CogwheelSocket) then
			Item.SocketBonusStats = {}
			Item.Stats.PrismaticSocket = nil
			Item.Stats.RedSocket = nil
			Item.Stats.YellowSocket = nil
			Item.Stats.BlueSocket = nil
			Item.Stats.MetaSocket = nil
			Item.Stats.CogwheelSocket = nil
		end
		
		-- Cache this item so we don't have to re-parse next time.
		PawnCacheItem(Item)
	end
	
	-- Recalculate the scale values for the item only if necessary.
	PawnRecalculateItemValuesIfNecessary(Item)
	
	return Item
end

-- Gets the item data for a gem, given a table of gem data from Gems.lua.
-- This function does not add gem details to the Pawn item cache.
-- Return value type is the same as PawnGetCachedItem.
function PawnGetGemData(GemData)
	-- If we've already called this function for this gem, keep the stored data.
	if GemData[9] then return GemData[9] end
	
	local ItemID = GemData[1]
	local ItemName, ItemLink, ItemRarity, ItemLevel, _, _, _, _, _, ItemTexture = GetItemInfo(ItemID)
	if ItemLink == nil or ItemName == nil then
		-- If the gem doesn't exist in the user's local cache, we'll have to fake up some info for it.
		ItemLink = format(PawnLocal.GenericGemLink, ItemID, ItemID)
		ItemName = format(PawnLocal.GenericGemName, ItemID)
	end
	local Item = PawnGetEmptyCachedItem(ItemLink, ItemName)
	Item.ID = ItemID
	Item.Rarity = ItemRarity
	Item.Level = ItemLevel
	Item.Texture = ItemTexture
	Item.UnenchantedStats = { }
	if GemData[5] then
		Item.UnenchantedStats[GemData[5]] = GemData[6]
	end
	if GemData[7] then
		Item.UnenchantedStats[GemData[7]] = GemData[8]
	end
	PawnRecalculateItemValuesIfNecessary(Item, true) -- Ignore the user's normalization factor when determining these gem values.
	
	-- Save this value for next time.
	GemData[9] = Item
	return Item
end

-- Gets the item data for a specific item.  Retrieves the information from the cache when possible; otherwise, gets it from the tooltip specified.
-- Return value type is the same as PawnGetCachedItem.
function PawnGetItemDataFromTooltip(TooltipName, MethodName, Param1, ...)
	VgerCore.Assert(TooltipName, "TooltipName must be non-null!")
	VgerCore.Assert(MethodName, "MethodName must be non-null!")
	if (not TooltipName) or (not MethodName) then return end
	
	-- First, find the tooltip.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	
	-- If we have a tooltip, try to get an item link from it.
	local ItemLink, ItemID, ItemLevel, _
	if (MethodName == "SetHyperlink") and Param1 then
		-- Special case: if the method is SetHyperlink, then we already have an item link.
		-- (Normally, GetItem will work, but SetHyperlink is used by some mod compatibility code.)
		ItemLink = Param1
	elseif Tooltip.GetItem then
		_, ItemLink = Tooltip:GetItem()
	end
	
	-- If we got an item link from the tooltip (or it was passed in), we can go through the simpler and more effective code that specifically
	-- uses item links, and skip the rest of this function.
	if ItemLink then
		return PawnGetItemData(ItemLink)
	end
	
	-- If we made it this far, then we're in the degenerate case where the tooltip doesn't have item information.  Let's look for the item's name,
	-- and maybe we'll get lucky and find that in our item cache.
	local ItemName, ItemNameLineNumber = PawnGetItemNameFromTooltip(TooltipName)
	if (not ItemName) or (not ItemNameLineNumber) then return end
	local ItemNumLines = Tooltip:NumLines()
	local Item = PawnGetCachedItem(nil, ItemName, ItemNumLines)
	if Item and Item.Values then
		return Item
	end
	-- If Item is non-null but Item.Values is null, we're not done yet!
	
	-- Ugh, the tooltip doesn't have item information and this item isn't in the Pawn item cache, so we'll have to try to parse this tooltip.	
	if not Item then
		Item = PawnGetEmptyCachedItem(nil, ItemName, ItemNumLines)
		PawnDebugMessage(" ")
		PawnDebugMessage("====================")
		PawnDebugMessage(VgerCore.Color.Green .. ItemName)
		
		-- Since we don't have an item link, we have to just read stats from the original tooltip, so we only get enchanted values.
		PawnFixStupidTooltipFormatting(TooltipName)
		Item.Stats, Item.SocketBonusStats, Item.UnknownLines = PawnGetStatsFromTooltip(TooltipName, true)
		PawnDebugMessage(PawnLocal.FailedToGetItemLinkMessage)
		
		-- Cache this item so we don't have to re-parse next time.
		PawnCacheItem(Item)
	end
	
	-- Recalculate the scale values for the item only if necessary.
	PawnRecalculateItemValuesIfNecessary(Item)
	
	return Item
end

-- Returns the same information as PawnGetItemData, but based on an inventory slot index instead of an item link.
-- If requested, data for the base unenchanted item can be returned instead; otherwise, the actual item is returned.
function PawnGetItemDataForInventorySlot(Slot, Unenchanted, UnitName)
	if UnitName == nil then UnitName = "player" end
	local ItemLink = GetInventoryItemLink(UnitName, Slot)
	if not ItemLink then return end
	if Unenchanted then
		local UnenchantedItem = PawnUnenchantItemLink(ItemLink)
		if UnenchantedItem then ItemLink = UnenchantedItem end
	end
	return PawnGetItemData(ItemLink)
end

-- Recalculates the scale values for a cached item if necessary, and returns them.
--	 Parameters: Item, NoNormalization
--		Item: The item to update.
--		NoNormalization: If true, ignores the user's normalization factor.
-- 	Returns: Values
--		Values: The item's table of item values.  Only includes enabled scales with nonzero values.
function PawnRecalculateItemValuesIfNecessary(Item, NoNormalization)
	-- We now have stats for the item.  If values aren't already calculated for the item, calculate those.  This happens when we have
	-- just retrieved the stats for the item, and also when the item values were cleared from the cache but not the stats.
	if not Item.Values then
		-- Calculate each of the values for which there are scales.
		Item.Values = PawnGetAllItemValues(Item.Stats, Item.Level, Item.SocketBonusStats, Item.UnenchantedStats, Item.UnenchantedSocketBonusStats, true, NoNormalization)

		PawnDebugMessage(" ")
	end
	
	return Item.Values
end

-- Returns a single scale value (in both its enchanted and unenchanted forms) for a cached item.  Returns nil for any values that are not present.
function PawnGetSingleValueFromItem(Item, ScaleName)
	if PawnIsScaleVisible(ScaleName) then
		-- If they've enabled this scale, its value should already be calculated.
		local ValuesTable = PawnRecalculateItemValuesIfNecessary(Item)
		if not ValuesTable then return end
		
		-- The scale values are sorted alphabetically, so we need to go through the list.
		local Count = #ValuesTable
		for i = 1, Count do
			local Value = ValuesTable[i]
			if Value[1] == ScaleName then
				return Value[2], Value[3]
			end
		end
		
		-- If we didn't find a value, it's because this item doesn't have a value for this scale.
		return 0, 0
	end
	
	-- If this scale isn't enabled, just calculate it as a one-off.
	local Value, UnenchantedValue
	Value = PawnGetItemValue(Item.Stats, Item.Level, Item.SocketBonusStats, ScaleName, false, false, true)
	UnenchantedValue = PawnGetItemValue(Item.UnenchantedStats, Item.Level, Item.UnenchantedSocketBonusStats, ScaleName, false, false, false)
	return Value, UnenchantedValue
end

-- Updates a specific tooltip.
function PawnUpdateTooltip(TooltipName, MethodName, Param1, ...)
	if not PawnCommon.Scales then return end
	
	-- Get information for the item in this tooltip.  This function will use item links and cached data whenever possible.
	local Item = PawnGetItemDataFromTooltip(TooltipName, MethodName, Param1, ...)
	-- If there's no item data, then something failed, so we can't update this tooltip.
	if not Item then return end
	-- Is this an upgrade?
	local UpgradeInfo, BestItemFor, SecondBestItemFor
	if PawnCommon.ShowUpgradesOnTooltips then UpgradeInfo, BestItemFor, SecondBestItemFor = PawnIsItemAnUpgrade(Item) end
	
	-- If this is the main GameTooltip, remember the item that was hovered over.
	-- AtlasLoot compatibility: enable hover comparison for AtlasLoot tooltips too.
	if TooltipName == "GameTooltip" or TooltipName == "AtlasLootTooltip" then
		PawnLastHoveredItem = Item.Link
	end
	
	-- Now, just update the tooltip with the item data we got from the previous call.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then
		VgerCore.Fail("Where'd the tooltip go?  I seem to have misplaced it.")
		return
	end
	
	-- If necessary, add a blank line to the tooltip.
	local AddSpace = PawnCommon.ShowSpace
	
	-- Add the scale values to the tooltip.
	if AddSpace and #Item.Values > 0 and (UpgradeInfo or BestItemFor or SecondBestItemFor or not PawnCommon.ShowValuesForUpgradesOnly) then Tooltip:AddLine(" ") AddSpace = false end
	PawnAddValuesToTooltip(Tooltip, Item.Values, UpgradeInfo, BestItemFor, SecondBestItemFor, Item.InvType)
	if PawnCommon.ColorTooltipBorder then
		if UpgradeInfo then Tooltip:SetBackdropBorderColor(0, 1, 0) else Tooltip:SetBackdropBorderColor(1, 1, 1) end
	end
	
	-- If there were unrecognized values, annotate those lines.
	local Annotated = false
	if Item.UnknownLines and (PawnCommon.ShowAsterisks == PawnShowAsterisksAlways) or ((PawnCommon.ShowAsterisks == PawnShowAsterisksNonzero or PawnCommon.ShowAsterisks == PawnShowAsterisksNonzeroNoText) and #Item.Values > 0) then
		Annotated = PawnAnnotateTooltipLines(TooltipName, Item.UnknownLines)
	end
	-- If we annotated the tooltip for unvalued stats, display a message.
	if (Annotated and PawnCommon.ShowAsterisks ~= PawnShowAsterisksNonzeroNoText) then
		Tooltip:AddLine(PawnLocal.AsteriskTooltipLine, VgerCore.Color.BlueR, VgerCore.Color.BlueG, VgerCore.Color.BlueB)
	end

	-- Add the item ID to the tooltip if known.
	if PawnCommon.ShowItemID and Item.Link then
		local IDs = PawnGetItemIDsForDisplay(Item.Link)
		if IDs then
			if PawnCommon.AlignNumbersRight then
				Tooltip:AddDoubleLine(PawnLocal.ItemIDTooltipLine, IDs, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
			else
				Tooltip:AddLine(PawnLocal.ItemIDTooltipLine .. ":  " .. IDs, VgerCore.Color.OrangeR, VgerCore.Color.OrangeG, VgerCore.Color.OrangeB)
			end
		end
	end
	
	-- Show the updated tooltip.	
	Tooltip:Show()
end

-- Returns a sorted list of all scale values for an item (and its unenchanted version, if supplied).
-- Parameters:
-- 	Item: A table of item stats in the format returned by GetStatsFromTooltip.
--	ItemLevel: The item's level.
-- 	SocketBonus: A table of socket bonus values in the format returned by GetStatsFromTooltip.
-- 	UnenchantedItem: A table of unenchanted item values in the format returned by GetStatsFromTooltip.
-- 	UnenchantedItemSocketBonus: A table of unenchanted item socket bonuses in the format returned by GetStatsFromTooltip.
--	DebugMessages: If true, debug messages will be printed.
--	NoNormalization: If true, the user's normalization factor will be ignored and the item won't be reforgeable.
-- Return value: ItemValues
-- 	ItemValues: A sorted table of scale values in the following format: { {"Scale 1", 100, 90, ...}, {"\"Provider\":Scale2", 200, 175, ...} }.
--	Values for scales that are not currently enabled are not included.
function PawnGetAllItemValues(Item, ItemLevel, SocketBonus, UnenchantedItem, UnenchantedItemSocketBonus, DebugMessages, NoNormalization)
	local ItemValues = {}
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		local ShowScale = PawnIsScaleVisible(ScaleName)
		if ShowScale then -- Skip all disabled scales.  PawnGetSingleValueFromItem will calculate them on-demand if necessary.
			if ShowScale and DebugMessages then
				PawnDebugMessage(" ")
				PawnDebugMessage(PawnGetScaleLocalizedName(ScaleName) .. " --------------------")
			end
			local Value
			local UnenchantedValue, UseRed, UseYellow, UseBlue
			if UnenchantedItem then
				UnenchantedValue, UseRed, UseYellow, UseBlue = PawnGetItemValue(UnenchantedItem, ItemLevel, UnenchantedItemSocketBonus, ScaleName, ShowScale and DebugMessages, NoNormalization, NoNormalization)
			end
			if Item then
				if ShowScale and DebugMessages and PawnCommon.ShowEnchanted then
					PawnDebugMessage(" ")
					PawnDebugMessage(PawnLocal.EnchantedStatsHeader)
				end
				Value = PawnGetItemValue(Item, ItemLevel, SocketBonus, ScaleName, ShowScale and DebugMessages and PawnCommon.ShowEnchanted, NoNormalization, true)
			end
			
			-- Add these values to the table.
			if Value == nil then Value = 0 end
			if UnenchantedValue == nil then UnenchantedValue = 0 end
			if Value > 0 or UnenchantedValue > 0 then
				tinsert(ItemValues, {ScaleName, Value, UnenchantedValue, UseRed, UseYellow, UseBlue, PawnGetScaleLocalizedName(ScaleName)})
			end
		end
	end
	
	-- Sort the table, then return it.
	sort(ItemValues, PawnItemValueCompare)
	return ItemValues
end

-- Adds an array of item values to a tooltip, handling formatting options.
-- Parameters: Tooltip, ItemValues, UpgradeInfo, BestItemFor, SecondBestItemFor, InvType, OnlyFirstValue
-- 	Tooltip: The tooltip to annotate.  (Not a name.)
-- 	ItemValues: An array of item values to use to annotate the tooltip, in the format returned by PawnGetAllItemValues.
--	UpgradeInfo: An array of item upgrade information, in the format returned by PawnIsItemAnUpgrade.
--	BestItemFor, SecondBestItemFor: A table of scales for which this is the best or second-best item available, in the format returned by PawnIsItemAnUpgrade.
--	InvType: Optionally, the type of item this is.
--	OnlyFirstValue: If true, only the first value (the "enchanted" one) is used, regardless of the user's settings.
function PawnAddValuesToTooltip(Tooltip, ItemValues, UpgradeInfo, BestItemFor, SecondBestItemFor, InvType, OnlyFirstValue)
	-- First, check input arguments.
	if type(Tooltip) ~= "table" then
		VgerCore.Fail("Tooltip must be a valid tooltip, not '" .. type(Tooltip) .. "'.")
		return
	end
	if not ItemValues then return end
	
	-- In the simplified upgrades-only mode, show some simple messages.
	if PawnCommon.ShowValuesForUpgradesOnly then
		if UpgradeInfo then
			Tooltip:AddLine(PawnLocal.TooltipAnyUpgradeLine)
		elseif BestItemFor or SecondBestItemFor then
			Tooltip:AddLine(PawnLocal.TooltipAnyBestItemLine)
		end
	end

	-- Loop through all of the item value subtables.
	local Entry, _
	for _, Entry in pairs(ItemValues) do
		local ScaleName, Value, UnenchantedValue, LocalizedName = Entry[1], Entry[2], Entry[3], Entry[7]
		local Scale = PawnCommon.Scales[ScaleName]
		VgerCore.Assert(Scale ~= nil, "Scale name in item value list doesn't exist!")
		
		if PawnIsScaleVisible(ScaleName) then
			-- Ignore values that we don't want to display.
			if OnlyFirstValue then
				UnenchantedValue = 0
			else
				if not PawnCommon.ShowEnchanted then Value = 0 end
			end
		
			local TooltipText = nil
			local TextColor = PawnGetScaleColor(ScaleName)
			local UnenchantedTextColor = PawnGetScaleColor(ScaleName, true)
			
			if PawnCommon.ShowValuesForUpgradesOnly then
				TooltipText = format(PawnNoValueAnnotationFormat, TextColor, LocalizedName)
			elseif Value and Value > 0 and UnenchantedValue and UnenchantedValue > 0 and math.abs(Value - UnenchantedValue) >= ((10 ^ -PawnCommon.Digits) / 2) then
				TooltipText = format(PawnEnchantedAnnotationFormat, TextColor, LocalizedName, tostring(Value), UnenchantedTextColor, tostring(UnenchantedValue))
			elseif Value and Value > 0 then
				TooltipText = format(PawnUnenchantedAnnotationFormat, TextColor, LocalizedName, tostring(Value))
			elseif UnenchantedValue and UnenchantedValue > 0 then
				TooltipText = format(PawnUnenchantedAnnotationFormat, TextColor, LocalizedName, tostring(UnenchantedValue))
			end
			
			-- Add upgrade info to the tooltip if this item is an upgrade.
			local ThisUpgrade, WasUpgrade, _
			if UpgradeInfo then
				for _, ThisUpgrade in pairs(UpgradeInfo) do
					if ThisUpgrade.ScaleName == ScaleName then
						local SetAnnotation = ""
						if InvType == "INVTYPE_2HWEAPON" then
							SetAnnotation = PawnLocal.TooltipUpgradeFor2H
						elseif InvType == "INVTYPE_WEAPONMAINHAND" or InvType == "INVTYPE_WEAPON" or InvType == "INVTYPE_WEAPONOFFHAND" then
							SetAnnotation = PawnLocal.TooltipUpgradeFor1H
						end
						if ThisUpgrade.PercentUpgrade >= PawnBigUpgradeThreshold then -- 100 = 10,000%
							-- For particularly huge upgrades, don't say ridiculous things like "999999999% upgrade"
							TooltipText = format(PawnLocal.TooltipBigUpgradeAnnotation, TooltipText, SetAnnotation)
						else
							TooltipText = format(PawnLocal.TooltipUpgradeAnnotation, TooltipText, 100 * ThisUpgrade.PercentUpgrade, SetAnnotation)
						end
						WasUpgrade = true
						break
					end
				end
			elseif not PawnCommon.ShowValuesForUpgradesOnly and BestItemFor and BestItemFor[ScaleName] then
				TooltipText = format(PawnLocal.TooltipBestAnnotation, TooltipText)
			elseif not PawnCommon.ShowValuesForUpgradesOnly and SecondBestItemFor and SecondBestItemFor[ScaleName] then
				TooltipText = format(PawnLocal.TooltipSecondBestAnnotation, TooltipText)
			end
			if not WasUpgrade and PawnCommon.ShowValuesForUpgradesOnly then TooltipText = nil end
			
			-- Add the line to the tooltip.
			if TooltipText then
				-- This could be optimized a bit, but it's not incredibly necessary.
				if PawnCommon.AlignNumbersRight then
					local Pos = VgerCore.StringFindReverse(TooltipText, ": ") -- search for a colon followed by a space so we don't get texture escape sequences
					local Left = strsub(TooltipText, 0, Pos - 1) -- ignore the colon
					local Right = strsub(TooltipText, 0, 10) .. strsub(TooltipText, Pos + 3) -- add the color string and ignore the spaces following the colon
					Tooltip:AddDoubleLine(Left, Right)
				else
					Tooltip:AddLine(TooltipText)
				end
			end
		end
	end
end

-- Returns the total scale values of all equipped items.  Only counts enchanted values.  Returns nil if item information
-- is unavailable for any item currently equipped.
-- Parameters: UnitName
--		UnitName: The name of the unit from whom the inventory item should be retrieved.  Defaults to "player".
-- Return value: ItemValues, Count, EpicItemLevel, AverageItemLevel
-- 		ItemValues: Same as PawnGetAllItemValues, or nil if unsuccessful.
--		Count: The number of item values calculated.
--		EpicItemLevel: An average epic-equivalent item level for all equipped items.
--		AverageItemLevel: An average item level for all equipped items, ignoring rarity.
function PawnGetInventoryItemValues(UnitName)
	local Total = {}
	local TotalItemLevel, TotalItemLevelIgnoringRarity = 0, 0
	local SlotStats
	local Slot
	local _
	for Slot = 1, 17 do
		if Slot ~= 4 then -- Skip slots 0, 4, 18, and 19 (they're not gear).
			-- REVIEW: The item level of the ranged slot appears to be ignored for Ulduar vehicle scaling, at least for shamans.
			local ItemID = GetInventoryItemID(UnitName, Slot)
			local Item = PawnGetItemDataForInventorySlot(Slot, false, UnitName)
			if Item then
				ItemValues = PawnGetAllItemValues(Item.Stats, Item.Level, Item.SocketBonusStats)
				-- Add the item's level to our running total.  If it's a 2H weapon AND the off-hand slot is empty, double its value.
				-- (We can't assume that the off-hand is empty just because the main hand slot contains a 2H weapon... stupid
				-- Titan's Grip warriors.)
				local ThisItemLevel = PawnGetEpicEquivalentItemLevel(Item.Level, Item.Rarity)
				local ThisItemLevelIgnoringRarity = Item.Level
				if not ThisItemLevelIgnoringRarity then return end -- If we have item information but no level, bail out rather than return inaccurate totals.
				if Slot == 16 then
					local _, _, _, _, _, _, _, _, InvType = GetItemInfo(GetInventoryItemLink(UnitName, Slot))
					if InvType == "INVTYPE_2HWEAPON" and GetInventoryItemID(UnitName, 17) == nil then
						ThisItemLevel = ThisItemLevel * 2
						ThisItemLevelIgnoringRarity = ThisItemLevelIgnoringRarity * 2
					end
				end
				if ThisItemLevel then
					TotalItemLevel = TotalItemLevel + ThisItemLevel
					TotalItemLevelIgnoringRarity = TotalItemLevelIgnoringRarity + ThisItemLevelIgnoringRarity
				end
				-- Now, add these values to our running totals.
				for _, Entry in pairs(ItemValues) do
					local ScaleName, Value = Entry[1], Entry[2]
					PawnAddStatToTable(Total, ScaleName, Value) -- (not actually stats, but the function does what we want)
				end
			elseif ItemID then
				-- If we have an item link but no item data, then the player HAS an item in that slot but we don't have data.
				-- So we should just bail out now to avoid reporting inaccurate totals.  BUT, we should go ahead and query for
				-- information on the other items before we do so that we have everything by the next time this is called.
				while Slot <= 17 do
					Item = PawnGetItemDataForInventorySlot(Slot, false, UnitName)
					Slot = Slot + 1
				end
				return
			end
		end
	end
	-- Once we're done, we need to convert our addition table to one that we can return.
	local TotalValues = {}
	local Count = 0
	for ScaleName, Value in pairs(Total) do
		tinsert(TotalValues, { ScaleName, Value, 0, false, false, false, PawnGetScaleLocalizedName(ScaleName) })
		Count = Count + 1
	end
	sort(TotalValues, PawnItemValueCompare)
	-- Return our totals.
	TotalItemLevel = math.floor(TotalItemLevel / 16 + .05)
	TotalItemLevelIgnoringRarity = math.floor(TotalItemLevelIgnoringRarity / 16 + .05)
	return TotalValues, Count, TotalItemLevel, TotalItemLevelIgnoringRarity
end

-- Works around annoying inconsistencies in the way that Blizzard formats tooltip text.
-- Enchantments and random item properties ("of the whale") are formatted like this: "|cffffffff+15 Intellect|r\r\n".
-- We correct this here.
function PawnFixStupidTooltipFormatting(TooltipName)
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	for i = 1, Tooltip:NumLines() do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		local Text = LeftLine:GetText()
		local Updated = false
		if Text and strsub(Text, 1, 2) ~= "\n" then
			-- First, look for a color.
			if strsub(Text, 1, 10) == "|cffffffff" then
				Text = strsub(Text, 11)
				LeftLine:SetTextColor(1, 1, 1)
				Updated = true
			end
			-- Then, look for a trailing \r\n, unless that's all that's left of the string.
			if (strlen(Text) > 2) and (strbyte(Text, -1) == 10) then
				Text = strsub(Text, 1, -4)
				Updated = true
			end
			-- Then, look for a trailing color restoration flag.
			if strsub(Text, -2) == "|r" then
				Text = strsub(Text, 1, -3)
				Updated = true
			end
			-- Update the tooltip with the new string.
			if Updated then
				--VgerCore.Message("Old: [" .. PawnEscapeString(LeftLine:GetText()) .. "]")
				LeftLine:SetText(Text)
				--VgerCore.Message("New: [" .. PawnEscapeString(Text) .. "]")
			end
		end
	end
end

-- Calls a method on a tooltip and then returns stats from that tooltip.
-- Parameters: ItemID, DebugMessages
--		TooltipName: The name of the tooltip to use.
--		DebugMessages: If true, debug messages will be shown.
--		Method: The name of the method to call on the tooltip, followed optionally by arguments to that method.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsFromTooltipWithMethod(TooltipName, DebugMessages, MethodName, ...)
	if not TooltipName or not MethodName then
		VgerCore.Fail("PawnGetStatsFromTooltipWithMethod requires a valid tooltip name and method name.")
		return
	end
	local Tooltip = getglobal(TooltipName)
	Tooltip:ClearLines() -- Without this, sometimes SetHyperlink seems to fail when called rapidly
	local Method = Tooltip[MethodName]
	Method(Tooltip, ...)
	PawnFixStupidTooltipFormatting(TooltipName)
	return PawnGetStatsFromTooltip(TooltipName, DebugMessages)
end

-- Reads the stats for a given item ID, eventually calling PawnGetStatsFromTooltip.
-- Parameters: ItemID, DebugMessages
--		ItemID: The item ID for which to get stats.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForItemID(ItemID, DebugMessages)
	if not ItemID then
		VgerCore.Fail("PawnGetStatsForItemID requires a valid item ID.")
		return
	end
	return PawnGetStatsForItemLink("item:" .. ItemID, DebugMessages)
end

-- Reads the stats for a given item link, eventually calling PawnGetStatsFromTooltip.
-- Parameters: ItemLink, DebugMessages
--		ItemLink: The item link for which to get stats.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForItemLink(ItemLink, DebugMessages)
	if not ItemLink then
		VgerCore.Fail("PawnGetStatsForItemLink requires a valid item link.")
		return
	end
	-- Other types of hyperlinks, such as enchant, quest, or spell are ignored by Pawn.
	if PawnGetHyperlinkType(ItemLink) ~= "item" then return end
	
	PawnPrivateTooltip:ClearLines() -- Without this, sometimes SetHyperlink seems to fail when called rapidly
	PawnPrivateTooltip:SetHyperlink(ItemLink)
	PawnFixStupidTooltipFormatting("PawnPrivateTooltip")
	return PawnGetStatsFromTooltip("PawnPrivateTooltip", DebugMessages)
end

-- Returns the stats of an equipped item, eventually calling PawnGetStatsFromTooltip.
-- 	Parameters: Slot
-- 		Slot: The slot number (0-19).  If not looping through all slots, use GetInventorySlotInfo("HeadSlot") to get the number.
--		DebugMessages: If true, debug messages will be shown.
--		UnitName: The name of the unit from whom the inventory item should be retrieved.  Defaults to "player".
-- Return value: Same as PawnGetStatsFromTooltip, or nil if unsuccessful.
function PawnGetStatsForInventorySlot(Slot, DebugMessages, UnitName)
	if type(Slot) ~= "number" then
		VgerCore.Fail("PawnGetStatsForInventorySlot requires a valid slot number.  Did you mean to use GetInventorySlotInfo to get a number?")
		return
	end
	if not UnitName then UnitName = "player" end
	return PawnGetStatsFromTooltipWithMethod("PawnPrivateTooltip", DebugMessages, "SetInventoryItem", UnitName, Slot)
end

-- Reads the stats from a tooltip.
-- Returns a table mapping stat name with a quantity of that statistic.
-- For example, ReturnValue["Strength"] = 12.
-- Parameters: TooltipName, DebugMessages
--		TooltipName: The tooltip to read.
--		DebugMessages: If true (default), debug messages will be shown.
-- Return value: Stats, UnknownLines
--		Stats: The table of stats for the item.
--		SocketBonusStats: The table of stats for the item's socket bonus.
--		UnknownLines: A list of lines in the tooltip that were not understood.
--		PrettyLink: A beautified item link, if available.
function PawnGetStatsFromTooltip(TooltipName, DebugMessages)
	local Stats, SocketBonusStats, UnknownLines = {}, {}, {}
	local HadUnknown = false
	local SocketBonusIsValid = false
	local Tooltip = getglobal(TooltipName)
	if DebugMessages == nil then DebugMessages = true end
	
	-- Get the item name.  It could be on line 2 if the first line is "Currently Equipped".
	local ItemName, ItemNameLineNumber = PawnGetItemNameFromTooltip(TooltipName)
	if (not ItemName) or (not ItemNameLineNumber) then
		--VgerCore.Fail("Failed to find name of item on the hidden tooltip")
		return
	end

	-- First, check for the ignored item names: for example, any item that starts with "Design:" should
	-- be ignored, because it's a jewelcrafting design, not a real item with stats.
	local ThisName, _
	for _, ThisName in pairs(PawnIgnoreNames) do
		if strsub(ItemName, 1, strlen(ThisName)) == ThisName then
			-- This is a known ignored item name; don't return any stats.
			return
		end
	end
	
	-- Now, read the tooltip for stats.
	for i = ItemNameLineNumber + 1, Tooltip:NumLines() do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		local LeftLineText = LeftLine:GetText()
		
		-- Look for this line in the "kill lines" list.  If it's there, we're done.
		local IsKillLine = false
		-- Dirty, dirty hack for 2.3: check the color of the text; if it's "name of item set" yellow, then treat it as a kill line.
		-- Not needed because we look for the (1/8) at the end instead.
		--local r, g, b = LeftLine:GetTextColor()
		--if (math.abs(r - 1) < .01) and (math.abs(g - .82) < .01) and (b < .01) then
		--	IsKillLine = true
		--end
		if not IsKillLine then
			local ThisKillLine
			for _, ThisKillLine in pairs(PawnKillLines) do
				if strfind(LeftLineText, ThisKillLine) then
					-- This is a known ignored kill line; stop now.
					IsKillLine = true
					break
				end
			end
		end
		if IsKillLine then break end
		
		for Side = 1, 2 do
			local CurrentParseText, RegexTable, CurrentDebugMessages, IgnoreErrors
			if Side == 1 then
				CurrentParseText = LeftLineText
				RegexTable = PawnRegexes
				CurrentDebugMessages = DebugMessages
				IgnoreErrors = false
			else
				local RightLine = getglobal(TooltipName .. "TextRight" .. i)
				CurrentParseText = RightLine:GetText()
				if (not CurrentParseText) or (CurrentParseText == "") then break end
				RegexTable = PawnRightHandRegexes
				CurrentDebugMessages = false
				IgnoreErrors = true
			end
			
			local ThisLineIsSocketBonus = false
			if Side == 1 and strsub(CurrentParseText, 1, strlen(PawnSocketBonusPrefix)) == PawnSocketBonusPrefix then
				-- This line is the socket bonus.
				ThisLineIsSocketBonus = true
				if LeftLine.GetTextColor then
					SocketBonusIsValid = (LeftLine:GetTextColor() == 0) -- green's red component is 0, but grey's red component is .5	
				else
					PawnDebugMessage(VgerCore.Color.Blue .. "Failed to determine whether socket bonus was valid, so assuming that it is indeed valid.")
					SocketBonusIsValid = true
				end
				CurrentParseText = strsub(CurrentParseText, strlen(PawnSocketBonusPrefix) + 1)
			end
			
			local Understood
			if ThisLineIsSocketBonus then
				Understood = PawnLookForSingleStat(RegexTable, SocketBonusStats, CurrentParseText, CurrentDebugMessages)
			else
				Understood = PawnLookForSingleStat(RegexTable, Stats, CurrentParseText, CurrentDebugMessages)
			end
			
			if not Understood then
				-- We don't understand this line.  Let's see if it's a complex stat.
				
				-- First, check to see if it starts with any of the ignore prefixes, such as "Use:".
				local IgnoreLine = false
				local ThisPrefix
				for _, ThisPrefix in pairs(PawnSeparatorIgnorePrefixes) do
					if strsub(CurrentParseText, 1, strlen(ThisPrefix)) == ThisPrefix then
						-- We know that this line doesn't contain a complex stat, so ignore it.
						IgnoreLine = true
						if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(CurrentParseText))) end
						if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[CurrentParseText] = 1 end
						break
					end
				end
				
				-- If this line wasn't ignorable, try to break it up.
				if not IgnoreLine then
					-- We'll assume the entire line was understood for now, but if we find any PART that
					-- we don't understand, we'll clear the "understood" flag again.
					Understood = true
					
					local Pos = 1
					local NextPos = 0
					local InnerStatLine = nil
					local InnerUnderstood = nil
					
					while Pos < strlen(CurrentParseText) do
						local ThisSeparator
						for _, ThisSeparator in pairs(PawnSeparators) do
							NextPos = strfind(CurrentParseText, ThisSeparator, Pos, false)
							if NextPos then
								-- One of the separators was found.  Check this string.
								InnerStatLine = strsub(CurrentParseText, Pos, NextPos - 1)
								if ThisLineIsSocketBonus then
									InnerUnderstood = PawnLookForSingleStat(RegexTable, SocketBonusStats, InnerStatLine, CurrentDebugMessages)
								else
									InnerUnderstood = PawnLookForSingleStat(RegexTable, Stats, InnerStatLine, CurrentDebugMessages)
								end
								if not InnerUnderstood then
									-- We don't understand this line.
									Understood = false
									if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(InnerStatLine))) end
									if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[InnerStatLine] = 1 end
								end
								-- Regardless of the outcome, advance to the next position.
								Pos = NextPos + strlen(ThisSeparator)
								break
							end -- (if NextPos...)
							-- If we didn't find that separator, continue the for loop to try the next separator.
						end -- (for ThisSeparator...)
						if (Pos > 1) and (not NextPos) then
							-- If there are no more separators left in the string, but we did find one before that, then we have
							-- one last string to check: everything after the last separator.
							InnerStatLine = strsub(CurrentParseText, Pos)
							if ThisLineIsSocketBonus then
								InnerUnderstood = PawnLookForSingleStat(RegexTable, SocketBonusStats, InnerStatLine, CurrentDebugMessages)
							else
								InnerUnderstood = PawnLookForSingleStat(RegexTable, Stats, InnerStatLine, CurrentDebugMessages)
							end
							if not InnerUnderstood then
								-- We don't understand this line.
								Understood = false
								if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(InnerStatLine))) end
								if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[InnerStatLine] = 1 end
							end
							break
						elseif not NextPos then
							-- If there are no more separators in the string and we hadn't found any before that, we're done.
							Understood = false
							if CurrentDebugMessages then PawnDebugMessage(VgerCore.Color.Blue .. format(PawnLocal.DidntUnderstandMessage, PawnEscapeString(CurrentParseText))) end
							if not Understood and not IgnoreErrors then HadUnknown = true UnknownLines[CurrentParseText] = 1 end
							break
						end 
						-- Continue on to the next portion of the string.  The loop ends when we run out of string.
					end -- (while Pos...)
				end -- (if not IgnoreLine...)
			end
		end
	end

	-- Before returning, some stats require special handling.
	
	if Stats["IsMainHand"] or Stats["IsOneHand"] or Stats["IsOffHand"] or Stats["IsTwoHand"] or Stats["IsRanged"] then
		-- Only perform this conversion if this is an actual weapon.  This works around a problem that occurs when you
		-- enchant your ring with weapon damage and then Pawn would try to calculate DPS for your ring with no Min/MaxDamage.
		local Min = Stats["MinDamage"]
		if not Min then Min = 0 end
		local Max = Stats["MaxDamage"]
		if not Max then Max = 0 end
		if (Min > 0 or Max > 0) and Stats["Speed"] then
			-- Convert damage to DPS if *either* minimum or maximum damage is present.  (A few annoying items
			-- like the Brewfest steins have only max damage.)
			PawnAddStatToTable(Stats, "Dps", (Min + Max) / Stats["Speed"] / 2)
		else
			local WeaponStats = 0
			if Stats["MinDamage"] then WeaponStats = WeaponStats + 1 end
			if Stats["MaxDamage"] then WeaponStats = WeaponStats + 1 end
			if Stats["Speed"] then WeaponStats = WeaponStats + 1 end
			VgerCore.Assert(WeaponStats == 0 or WeaponStats == 3, "Weapon with mismatched or missing speed and damage stats was not converted to DPS")
		end
	end
	
	if Stats["IsMainHand"] then
		PawnAddStatToTable(Stats, "MainHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "MainHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "MainHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "MainHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsMainHand"] = nil
	end

	if Stats["IsShield"] then
		-- Shields aren't off-hand weapons.
		Stats["IsOffHand"] = nil
	end
	if Stats["IsOffHand"] then
		PawnAddStatToTable(Stats, "OffHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "OffHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "OffHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "OffHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
	end

	if Stats["IsOneHand"] then
		PawnAddStatToTable(Stats, "OneHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "OneHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "OneHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "OneHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		Stats["IsOneHand"] = nil
	end

	if Stats["IsTwoHand"] then
		PawnAddStatToTable(Stats, "TwoHandDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "TwoHandSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "TwoHandMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "TwoHandMaxDamage", Stats["MaxDamage"])
		PawnAddStatToTable(Stats, "IsMelee", 1)
		-- Also need to convert weapon stats for two-handed weapons, since two-handed appears on the left and weapon type appears on the right.
		PawnAddStatToTable(Stats, "Is2HAxe", Stats["IsAxe"])
		Stats["IsAxe"] = nil
		PawnAddStatToTable(Stats, "Is2HMace", Stats["IsMace"])
		Stats["IsMace"] = nil
		PawnAddStatToTable(Stats, "Is2HSword", Stats["IsSword"])
		Stats["IsSword"] = nil

		Stats["IsTwoHand"] = nil
	end

	if Stats["IsMelee"] and Stats["IsRanged"] then
		VgerCore.Fail("Weapon that is both melee and ranged was converted to both Melee* and Ranged* stats")
	end	
	
	if Stats["IsMelee"] then
		PawnAddStatToTable(Stats, "MeleeDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "MeleeSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "MeleeMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "MeleeMaxDamage", Stats["MaxDamage"])
		Stats["IsMelee"] = nil
	end

	if Stats["IsRanged"] then
		PawnAddStatToTable(Stats, "RangedDps", Stats["Dps"])
		PawnAddStatToTable(Stats, "RangedSpeed", Stats["Speed"])
		PawnAddStatToTable(Stats, "RangedMinDamage", Stats["MinDamage"])
		PawnAddStatToTable(Stats, "RangedMaxDamage", Stats["MaxDamage"])
		Stats["IsRanged"] = nil
	end
	
	if Stats["MetaSocket"] then
		-- For each meta socket, add credit for meta socket effects.
		-- Enchanted items will get the benefit of meta sockets on their unenchanted version later.
		PawnAddStatToTable(Stats, "MetaSocketEffect", Stats["MetaSocket"])
	end
	
	-- Now, socket bonuses require special handling.
	if SocketBonusIsValid then
		-- If the socket bonus is valid (green), then just add those stats directly to the main stats table and be done with it.
		PawnAddStatsToTable(Stats, SocketBonusStats)
		SocketBonusStats = {}
	else
		-- If the socket bonus is not valid, then we need to check for sockets.
		if Stats["PrismaticSocket"] or Stats["RedSocket"] or Stats["YellowSocket"] or Stats["BlueSocket"] or Stats["MetaSocket"] or Stats["CogwheelSocket"] then
			-- There are sockets left, so the player could still meet the requirements.
		else
			-- There are no sockets left and the socket bonus requirements were not met.  Ignore the
			-- socket bonus, since the user purposely chose to mis-socket.
			SocketBonusStats = {}
		end
	end
	
	-- Done!
	local _, PrettyLink = Tooltip:GetItem()
	if not HadUnknown then UnknownLines = nil end
	return Stats, SocketBonusStats, UnknownLines, PrettyLink
end

-- Looks for a single string in the regex table, and adds it to the stats table if it finds it.
-- Parameters: Stats, ThisString, DebugMessages
--		RegexTable: The regular expression table to look through.
--		Stats: The stats table to modify if anything is found.
--		ThisString: The string to look for.
--		DebugMessages: If true, debug messages will be shown.
-- Return value: Understood
--		Understood: True if the string was understood (even if empty or ignored), otherwise false.
function PawnLookForSingleStat(RegexTable, Stats, ThisString, DebugMessages)
	-- First, perform a series of normalizations on the string.  For example, "Stamina +5" should
	-- be converted to "+5 Stamina" so we don't need two strings for everything.
	ThisString = strtrim(ThisString)
	local Entry
	for _, Entry in pairs(PawnNormalizationRegexes) do
		local Regex, Replacement = unpack(Entry)
		local OldString = ThisString
		ThisString, Count = gsub(ThisString, Regex, Replacement, 1)
		--if Count > 0 then PawnDebugMessage("Normalized string using \"" .. PawnEscapeString(Regex) .. "\" -- was " .. PawnEscapeString(OldString) .. " and is now " .. PawnEscapeString(ThisString)) end
	end

	-- Now, look for the string in the main regex table.
	local Props, Matches = PawnFindStringInRegexTable(ThisString, RegexTable)
	if not Props then
		-- We don't understand this.  Return false to indicate this, so the caller can handle the case.
		return false
	else
		-- We understand this.  It could either be an ignored line like "Soulbound", or an actual stat.
		-- The same code handles both cases; just keep going until we find a stat of nil; in the ignored case, we hit this immediately.
		local Index = 2
		while true do
			local Stat, Number, Source = Props[Index], tonumber(Props[Index + 1]), Props[Index + 2]
			if not Stat then break end -- There are no more stats left to process.
			if not Number then Number = 1 end
			
			if Source == PawnMultipleStatsExtract or Source == PawnSingleStatMultiplier or Source == nil then
				-- This is a variable number of a stat, the standard case.
				local MatchIndex
				if Source == PawnMultipleStatsExtract then
					MatchIndex = math.abs(Number)
				else
					MatchIndex = 1
				end
				local ExtractedValue = Matches[MatchIndex]
				if LARGE_NUMBER_SEPERATOR and LARGE_NUMBER_SEPERATOR ~= "" then
					-- Remove commas in numbers.  We need to use % in case it's a dot, and we need to 
					-- skip this entirely in case there's no large number separator at all (Spanish).
					ExtractedValue = gsub(ExtractedValue, "%" .. LARGE_NUMBER_SEPERATOR, "")
				end
				if DECIMAL_SEPERATOR and DECIMAL_SEPERATOR ~= "." then
					-- If this is the German client or any other version that uses something other than "." for
					-- the decimal separator, we need to substitute here, because tonumber() parses things
					-- in English format only.
					ExtractedValue = gsub(ExtractedValue, DECIMAL_SEPERATOR, ".")
				end
				ExtractedValue = tonumber(ExtractedValue) -- broken onto multiple lines because gsub() returns multiple values and tonumber accepts multiple arguments
				if Number < 0 then ExtractedValue = -ExtractedValue end
				if Source == PawnSingleStatMultiplier then ExtractedValue = ExtractedValue * Number end
				if DebugMessages then PawnDebugMessage(format(PawnLocal.FoundStatMessage, ExtractedValue, Stat)) end
				PawnAddStatToTable(Stats, Stat, ExtractedValue)
			elseif Source == PawnMultipleStatsFixed then
				-- This is a fixed number of a stat, such as a socket (1).
				if DebugMessages then PawnDebugMessage(format(PawnLocal.FoundStatMessage, Number, Stat)) end
				PawnAddStatToTable(Stats, Stat, Number)
			else
				VgerCore.Fail("Incorrect source value of '" .. Source .. "' for regex: " .. Props[1])
			end
			
			Index = Index + 3
		end
	end

	return true
end

-- Gets the name of an item given a tooltip name, and the line on which the item appears.
-- Normally this is line 1, but it can be line 2 if the first line is "Currently Equipped".
-- Parameters: TooltipName
--		TooltipName: The name of the tooltip to read.
-- Return value: ItemName, LineNumber
--		ItemName: The name of the item in the tooltip, or nil if the tooltip didn't have one.
--		LineNumber: The line number on which the name was found, or nil if no item was found.
function PawnGetItemNameFromTooltip(TooltipName)
	-- First, get the tooltip details.
	local TooltipTopLine = getglobal(TooltipName .. "TextLeft1")
	if not TooltipTopLine then return end
	local ItemName = TooltipTopLine:GetText()
	if not ItemName or ItemName == "" then return end
	
	-- If this is a Currently Equipped tooltip, skip the first line.
	if ItemName == CURRENTLY_EQUIPPED then
		ItemNameLineNumber = 2
		TooltipTopLine = getglobal(TooltipName .. "TextLeft2")
		if not TooltipTopLine then return end
		return TooltipTopLine:GetText(), 2
	end
	return ItemName, 1
end

-- Annotates zero or more lines in a tooltip with the name TooltipName, adding a (?) to the end
-- of each line specified by index in the list Lines.
-- Returns true if any lines were annotated.
function PawnAnnotateTooltipLines(TooltipName, Lines)
	if not Lines then return false end

	local Annotated = false
	local Tooltip = getglobal(TooltipName)
	local LineCount = Tooltip:NumLines()
	for i = 2, LineCount do
		local LeftLine = getglobal(TooltipName .. "TextLeft" .. i)
		if LeftLine then
			local LeftLineText = LeftLine:GetText()
			if Lines[LeftLineText] then
				-- Getting the line text can fail in the following scenario, observable with MobInfo-2:
				-- 1. Other mod modifies a tooltip to include unrecognized text.
				-- 2. Pawn reads the tooltip, noting those unrecognized lines and remembering them so that they
				-- can get marked with (?) later.
				-- 3. Something causes the tooltip to be refreshed.  For example, picking up the item.  All customizations
				-- by Pawn and other mods are lost.
				-- 4. Pawn re-annotates the tooltip with (?) before the other mod has added the lines that are supposed
				-- to get the (?).
				-- In this case, we just ignore the problem and leave off the (?), since we can't really come back later.
				LeftLine:SetText(LeftLineText .. PawnTooltipAnnotation)
				Annotated = true
			end
		end
	end
	return Annotated
end

-- Adds an amount of one stat to a table of stats, increasing the value if
-- it's already there, or adding it if it isn't.
function PawnAddStatToTable(Stats, Stat, Amount)
	if not Amount or Amount == 0 then return end
	if Stats[Stat] then
		Stats[Stat] = Stats[Stat] + Amount
	else
		Stats[Stat] = Amount
	end
end

-- Adds the contents of one stat table to another.
function PawnAddStatsToTable(Dest, Source)
	if not Dest then
		VgerCore.Fail("PawnAddStatsToTable requires a destination table!")
		return
	end
	if not Source then return end
	for Stat, Quantity in pairs(Source) do
		PawnAddStatToTable(Dest, Stat, Quantity)
	end
end

-- Looks for the first regular expression in a given table that matches the given string.
-- Parameters: String, RegexTable
--		String: The string to look for.
--		RegexTable: The table of regular expressions to look through.
--	Return value: Props, Matches
--		Props: The row from the table with a matching regex.
--		Matches: The array of captured matches.
-- 		Returns nil, nil if no matches were found.
--		Returns {}, {} if the string was ignored.
function PawnFindStringInRegexTable(String, RegexTable)
	if (String == nil) or (String == "") or (String == " ") then return {}, {} end
	local Entry
	for _, Entry in pairs(RegexTable) do
		local StartPos, EndPos, m1, m2, m3, m4, m5 = strfind(String, Entry[1])
		if StartPos then return Entry, { m1, m2, m3, m4, m5 } end
	end
	return nil, nil
end

-- Calculates the value of an item.
--	Parameters: Item, SocketBonus, ScaleName, DebugMessages, NoNormalization, NoReforging
--		Item: Item stats in the format returned by GetStatsFromTooltip.
--		ItemLevel: The item's level.
--		SocketBonus: Socket bonus stats in the format returned by GetStatsFromTooltip.
--		DebugMessages: If true, debug messages will be shown if appropriate.
--		NoNormalization: If true, the user's normalization factor will be ignored.
--		NoReforging: If true, reforging calculations will be skipped.
--	Returns: Value, ShouldUseRed, ShouldUseYellow, ShouldUseBlue
--		Value: The numeric value of an item based on the given scale values.  (example: 21.75)
--		ShouldUseRed: If true, the player should socket this item with red gems.
--		ShouldUseYellow: If true, the player should socket this item with yellow gems.
--		ShouldUseBlue: If true, the player should socket this item with blue gems.
function PawnGetItemValue(Item, ItemLevel, SocketBonus, ScaleName, DebugMessages, NoNormalization, NoReforging)
	-- If either the item or scale is empty, exit now.
	if (not Item) or (not ScaleName) then return end
	local ScaleOptions = PawnCommon.Scales[ScaleName]
	if not ScaleOptions then return end
	ScaleValues = ScaleOptions.Values
	if not ScaleValues then return end
	
	-- Calculate the value.
	local Total = 0
	local IsUnusable
	local ThisValue, Stat, Quantity
	for Stat, Quantity in pairs(Item) do
		ThisValue = ScaleValues[Stat]
		-- This isn't an unusable stat, is it?
		if ThisValue and ThisValue <= PawnIgnoreStatValue then
			Total = 0
			IsUnusable = true
			if DebugMessages then PawnDebugMessage(format(PawnLocal.UnusableStatMessage, Stat)) end
			break
		end
		-- Colored sockets are considered separately.  You can't mismatch prismatic or cogwheel sockets, so treat those just
		-- like any other stat.
		if Stat ~= "RedSocket" and Stat ~= "YellowSocket" and Stat ~= "BlueSocket" then
			if ThisValue then
				-- This stat has a value; add it to the running total.
				if ScaleValues.SpeedBaseline and (
					Stat == "Speed" or
					Stat == "MeleeSpeed" or
					Stat == "MainHandSpeed" or
					Stat == "OffHandSpeed" or
					Stat == "OneHandSpeed" or
					Stat == "TwoHandSpeed" or
					Stat == "RangedSpeed"	
				) then
					-- Speed is a special case; subtract SpeedBaseline from the speed value.
					Quantity = Quantity - ScaleValues.SpeedBaseline
				end
				Total = Total + ThisValue * Quantity
				if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
		end
	end
	
	-- Decide what to do with socket bonuses.
	local BestGemRed, BestGemYellow, BestGemBlue = false, false, false
	if SocketBonus and not IsUnusable then
		-- Start by counting the sockets; if there are no sockets, we can quit.
		local TotalColoredSockets = 0
		if Item["RedSocket"] then TotalColoredSockets = TotalColoredSockets + Item["RedSocket"] end
		if Item["YellowSocket"] then TotalColoredSockets = TotalColoredSockets + Item["YellowSocket"] end
		if Item["BlueSocket"] then TotalColoredSockets = TotalColoredSockets + Item["BlueSocket"] end
		if TotalColoredSockets > 0 then
			-- Find the value of the sockets if they are socketed properly.
			if DebugMessages then PawnDebugMessage(PawnLocal.SocketBonusValueCalculationMessage) end
			local ProperSocketValue = 0
			Stat = "RedSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			Stat = "YellowSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			Stat = "BlueSocket" Quantity = Item[Stat] ThisValue = ScaleValues[Stat]
			if Quantity and ThisValue then
				ProperSocketValue = ProperSocketValue + Quantity * ThisValue
				if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
			end
			for Stat, Quantity in pairs(SocketBonus) do
				ThisValue = ScaleValues[Stat]
				if ThisValue then
					ProperSocketValue = ProperSocketValue + ThisValue * Quantity
					if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, Quantity, Stat, ThisValue, Quantity * ThisValue)) end
				end
			end
			-- Then, find the value of the sockets if they are socketed with the best gem, ignoring the socket bonus.
			local BestGemValue = 0
			local BestGemName = ""
			local MissocketedValue = 0
			if ScaleOptions.SmartGemSocketing then
				BestGemRed, BestGemYellow, BestGemBlue, BestGemValue, BestGemName = PawnGetBestGemColorsForScale(ScaleName)
				if BestGemValue and BestGemValue > 0 then MissocketedValue = TotalColoredSockets * BestGemValue end
			end
			-- So, which one should we use?
			if MissocketedValue <= ProperSocketValue then
				-- If it's not worthwhile to mis-socket, clear out the best-gem fields.
				BestGemRed, BestGemYellow, BestGemBlue = false, false, false
			end
			if ScaleOptions.SmartGemSocketing and MissocketedValue > ProperSocketValue then
				-- It's better to mis-socket and ignore the socket bonus.
				if DebugMessages then PawnDebugMessage(format(PawnLocal.MissocketWorthwhileMessage, BestGemName)) end
				Total = Total + MissocketedValue
				if DebugMessages then PawnDebugMessage(format(PawnLocal.ValueCalculationMessage, TotalColoredSockets, BestGemName, BestGemValue, MissocketedValue)) end
			else
				-- It's better to socket this item normally.
				Total = Total + ProperSocketValue
			end
		end
	end
	
	-- Perform normalizations on the total if that option is enabled.
	if (not IsUnusable) and (not NoNormalization) and PawnScaleTotals[ScaleName] then
		if ScaleOptions.NormalizationFactor and ScaleOptions.NormalizationFactor > 0 then
			Total = ScaleOptions.NormalizationFactor * Total / PawnScaleTotals[ScaleName]
			if DebugMessages then PawnDebugMessage(format(PawnLocal.NormalizationMessage, PawnScaleTotals[ScaleName])) end
		end
	end
	
	-- Decide if the item should be reforged.
	if (not IsUnusable) and (not NoReforging) and (ItemLevel and ItemLevel >= 200) then
		local ReforgePotential = PawnFindOptimalReforgingCore(ScaleName, ScaleOptions, ScaleValues, Item, true)
		if ReforgePotential and ReforgePotential > 0 then
			if DebugMessages then PawnDebugMessage(format(PawnLocal.ReforgeDebugMessage, ReforgePotential)) end
			Total = Total + ReforgePotential
		end
	end

	if DebugMessages then PawnDebugMessage(format(PawnLocal.TotalValueMessage, Total)) end
	
	return Total, BestGemRed, BestGemYellow, BestGemBlue
end

-- Finds which gem colors are best for a given scale.
-- Returns: BestGemRed, BestGemYellow, BestGemBlue, BestGemValue, BestGemString
function PawnGetBestGemColorsForScale(ScaleName)
	local Best = PawnScaleBestGems[ScaleName]
	if not Best then
		VgerCore.Fail("The best gem colors for this scale should have already been calculated; we don't have any info on it.")
		return
	end
	local BestGems = Best.BestGems
	if not BestGems then
		VgerCore.Fail("The list of best gems for this scale is missing, so we can't find which colors are best.")
		return
	end
	
	return BestGems.RedSocket, BestGems.YellowSocket, BestGems.BlueSocket, BestGems.Value, BestGems.String
end

-- Given a scale name and a socket color (like RedSocket), return the name of the single best gem of that color, or the name of
-- the color if there's no single best gem.
function PawnGetBestSingleGemForScale(ScaleName, Color)
	local GemName
	local Gems = PawnScaleBestGems[ScaleName]
	if Gems and Gems[Color] and #(Gems[Color]) == 1 then
		-- There's exactly one best gem of this color, so return its name.
		-- If it's in the Pawn cache, use its name from there.  Otherwise,
		-- return the color name; that's much more useful than (Gem 1234).
		local Item = PawnGetItemData("item:" .. Gems[Color][1].ID)
		if Item and Item.Name then
			return Item.Name
		end
	end
	
	-- Otherwise, return the color name.
	if Color == "RedSocket" then
		return RED_GEM
	elseif Color == "YellowSocket" then
		return YELLOW_GEM
	elseif Color == "BlueSocket" then
		return BLUE_GEM
	elseif Color == "CogwheelSocket" then
		return PawnLocal.CogwheelName
	elseif Color == "MetaSocket" then
		return META_GEM
	else
		VgerCore.Fail("Improper color value passed to PawnGetBestSingleGemForScale.")
	end
end

-- Returns a string of gems and a number, such as "2 Runed Scarlet Ruby" or "3 Yellow or Blue".
function PawnGetGemListString(GemCount, UseRed, UseYellow, UseBlue, ScaleName)
	if UseRed and UseYellow and UseBlue then
		return format(PawnLocal.GemColorList3, GemCount)
	elseif UseRed and UseYellow and not UseBlue then
		return format(PawnLocal.GemColorList2, GemCount, RED_GEM, YELLOW_GEM)
	elseif UseYellow and UseBlue and not UseRed then
		return format(PawnLocal.GemColorList2, GemCount, YELLOW_GEM, BLUE_GEM)
	elseif UseRed and UseBlue and not UseYellow then
		return format(PawnLocal.GemColorList2, GemCount, RED_GEM, BLUE_GEM)
	elseif UseRed then
		return format(PawnLocal.GemColorList1, GemCount, PawnGetBestSingleGemForScale(ScaleName, "RedSocket"))
	elseif UseYellow then
		return format(PawnLocal.GemColorList1, GemCount, PawnGetBestSingleGemForScale(ScaleName, "YellowSocket"))
	elseif UseBlue then
		return format(PawnLocal.GemColorList1, GemCount, PawnGetBestSingleGemForScale(ScaleName, "BlueSocket"))
	else
		return format(PawnLocal.GemColorList3, GemCount)
	end
end

-- Returns the type of hyperlink passed in, or nil if it's not a hyperlink.
-- Possible values include: item, enchant, quest, spell
function PawnGetHyperlinkType(Hyperlink)
	-- First, try colored links.
	local _, _, LinkType = strfind(Hyperlink, "^|c%x%x%x%x%x%x%x%x|H(.-):")
	if not LinkType then
		-- Then, try links prepended with |H.  (Outfitter does this.)
		_, _, LinkType = strfind(Hyperlink, "^|H(.-):")
	end
	if not LinkType then
		-- Then, try raw links.
		_, _, LinkType = strfind(Hyperlink, "^(.-):")
	end
	return LinkType
end

-- If the item link is of the clickable form, strip off the initial hyperlink portion.
function PawnStripLeftOfItemLink(ItemLink)
	local _, _, InnerLink = strfind(ItemLink, "^|%x+|H(.+)")
	if InnerLink then return InnerLink else return ItemLink end
end

-- Extracts the item ID from an ItemLink string and returns it, or nil if unsuccessful.
function PawnGetItemIDFromLink(ItemLink)
	local Pos, _, ItemID = strfind(PawnStripLeftOfItemLink(ItemLink), "^item:(%-?%d+):?")
	if Pos then return tonumber(ItemID) else return nil end
end

-- Returns a new item link that represents an unenchanted version of the original item link, or
-- nil if unsuccessful or the item is not enchanted.
function PawnUnenchantItemLink(ItemLink)
	local TrimmedItemLink = PawnStripLeftOfItemLink(ItemLink)
	local Pos, _, ItemID, EnchantID, GemID1, GemID2, GemID3, GemID4, SuffixID, MoreInfo, ViewAtLevel, Reforge = strfind(TrimmedItemLink, "^item:(%-?%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)")

	if Pos then
		if
			EnchantID ~= "0" or EnchantID == "" or EnchantID == nil or
			GemID1 ~= "0" or GemID1 == "" or GemID1 == nil or
			GemID2 ~= "0" or GemID2 == "" or GemID2 == nil or
			GemID3 ~= "0" or GemID3 == "" or GemID3 == nil or
			GemID4 ~= "0" or GemID4 == "" or GemID4 == nil or
			Reforge ~= "0" or Reforge == "" or Reforge == nil
		then
			-- This item is enchanted.  Return a new link.
			if SuffixID == nil or SuffixID == "" then SuffixID = "0" end
			if MoreInfo == nil or MoreInfo == "" then MoreInfo = "0" end
			if ViewAtLevel == nil or ViewAtLevel == "" then ViewAtLevel = "0" end
			return "item:" .. ItemID .. ":0:0:0:0:0:" .. SuffixID .. ":" .. MoreInfo .. ":" .. ViewAtLevel
		else
			-- This item is not enchanted.  Return nil.
			return nil
		end
	else
		-- We couldn't parse this item link.  Return nil.
		VgerCore.Fail("Could not parse the item link: " .. PawnEscapeString(ItemLink))
		return nil
	end
end

-- Returns a nice-looking string that shows the item IDs for an item, its enchantments, and its gems.
function PawnGetItemIDsForDisplay(ItemLink)
	local Pos, _, ItemID, MoreInfo = strfind(ItemLink, "^|%x+|Hitem:(%-?%d+)([^|]+)|")
	if not Pos then return end

	if MoreInfo and MoreInfo ~= "" then
		return ItemID .. VgerCore.Color.Silver .. MoreInfo .. "|r"
	else
		return ItemID
	end
end

-- Reads a Pawn scale tag, and breaks it into parts.
-- 	Parameters: ScaleTag
--		ScaleTag: A Pawn scale tag.  Example:  '(Pawn:v1:"Healbot":Stamina=1,Intellect=1.24)'
--	Return value: Name, Values; or nil if unsuccessful, or if the version number is too high.
--		Name: The scale name.
--		Values: A table of scale stats and values.  Example: {["Stamina"] = 1, ["Intellect"] = 1.24}
function PawnParseScaleTag(ScaleTag)
	-- Read the scale and perform basic validation.
	local Pos, _, Version, Name, ValuesString = strfind(ScaleTag, "^%s*%(%s*Pawn%s*:%s*v(%d+)%s*:%s*\"([^\"]+)\"%s*:%s*(.+)%s*%)%s*$")
	Version = tonumber(Version)
	if (not Pos) or (not Version) or (not Name) or (Name == "") or (not ValuesString) or (ValuesString == "") then return end
	if Version > PawnCurrentScaleVersion then return end
	
	-- Now, parse the values string for stat names and values.
	local Values = {}
	local function SplitStatValuePair(Pair)
		local Pos, _, Stat, Value = strfind(Pair, "^%s*([%a%d]+)%s*=%s*(%-?[%d%.]+)%s*,$")
		Value = tonumber(Value)
		if Pos and Stat and (Stat ~= "") and Value then 
			Values[Stat] = Value
		end
	end
	gsub(ValuesString .. ",", "[^,]*,", SplitStatValuePair)
	
	-- Looks like everything worked.
	return Name, Values
end

-- Escapes a string so that it can be more easily printed.
function PawnEscapeString(String)
	return gsub(gsub(gsub(String, "\r", "\\r"), "\n", "\\n"), "|", "||")
end

-- Corrects errors in scales: either human errors, or to correct for bugs in current or past versions of Pawn.
function PawnCorrectScaleErrors(ScaleName)
	local ThisScaleOptions = PawnCommon.Scales[ScaleName]
	if not ThisScaleOptions then return end
	local ThisScale = ThisScaleOptions.Values
	if not ThisScale then
		ThisScale = { }
		ThisScaleOptions.Values = ThisScale
	end
	
	-- Pawn 1.5.5 adds an option to follow specialization when upgrading.
	if ThisScaleOptions.UpgradesFollowSpecialization == nil then ThisScaleOptions.UpgradesFollowSpecialization = true end
	
	-- Pawn 1.3 adds per-character options to each scale.
	if ThisScaleOptions.PerCharacterOptions == nil then ThisScaleOptions.PerCharacterOptions = {} end
	if ThisScaleOptions.PerCharacterOptions[PawnPlayerFullName] == nil then ThisScaleOptions.PerCharacterOptions[PawnPlayerFullName] = {} end
	
	-- Pawn 1.0.1 adds a per-scale setting for smart gem socketing that defaults to on.
	-- Pawn 1.2 adds another setting for meta gems that defaults to whatever the colored gem setting was, or on.
	-- Pawn 1.5.5 adds cogwheel support.
	if ThisScaleOptions.SmartGemSocketing == nil then ThisScaleOptions.SmartGemSocketing = true end
	if ThisScaleOptions.GemQualityLevel == nil then ThisScaleOptions.GemQualityLevel = PawnDefaultGemQualityLevel end
	if ThisScaleOptions.CogwheelQualityLevel == nil then ThisScaleOptions.CogwheelQualityLevel = PawnDefaultCogwheelGemQualityLevel end
	if ThisScaleOptions.SmartMetaGemSocketing == nil then ThisScaleOptions.SmartMetaGemSocketing = ThisScaleOptions.SmartGemSocketing end
	if ThisScaleOptions.MetaGemQualityLevel == nil then ThisScaleOptions.MetaGemQualityLevel = PawnDefaultMetaGemQualityLevel end
	
	-- Some versions of Pawn call resilience rating Resilience and some call it ResilienceRating.
	PawnReplaceStat(ThisScale, "Resilience", "ResilienceRating")
	
	-- Early versions of Pawn 0.7.x had a typo in the configuration UI so that none of the special DPS stats worked.
	PawnReplaceStat(ThisScale, "MeleeDPS", "MeleeDps")
	PawnReplaceStat(ThisScale, "RangedDPS", "RangedDps")
	PawnReplaceStat(ThisScale, "MainHandDPS", "MainHandDps")
	PawnReplaceStat(ThisScale, "OffHandDPS", "OffHandDps")
	PawnReplaceStat(ThisScale, "OneHandDPS", "OneHandDps")
	PawnReplaceStat(ThisScale, "TwoHandDPS", "TwoHandDps")
	
	-- Remove spell damage and healing stats from the scale, and replace with spell power if it doesn't already have a stat.
	if not ThisScale.SpellPower and (ThisScale.SpellDamage or ThisScale.Healing) then
		local Healing = ThisScale.Healing
		if not Healing then Healing = 0 end
		local SpellDamage = ThisScale.SpellDamage
		if not SpellDamage then SpellDamage = 0 end
		ThisScale.SpellPower = SpellDamage + (13 * Healing / 7)
		if ThisScale.SpellDamage and ThisScale.SpellDamage > ThisScale.SpellPower then ThisScale.SpellPower = ThisScale.SpellDamage end
		if ThisScale.SpellPower <= 0 then ThisScale.SpellPower = nil end
	end
	ThisScale.SpellDamage = nil
	ThisScale.Healing = nil
	
	-- Combine melee/ranged/spell hit, crit, and haste ratings into the hybrid stats that work for all.
	PawnCombineStats(ThisScale, "HitRating", "SpellHitRating")
	PawnCombineStats(ThisScale, "CritRating", "SpellCritRating")
	PawnCombineStats(ThisScale, "HasteRating", "SpellHasteRating")
	
	-- Cataclysm and Pawn 1.4 remove a bunch more stats.
	-- MP5 is replaced with Spirit.
	if ThisScale.Mp5 then
		if (ThisScale.Spirit == nil) or (ThisScale.Spirit < ThisScale.Mp5 / 2) then
			-- This scale has a value for MP5 but gives Spirit a low value.  Convert MP5 into Spirit 2:1, just like Blizzard did.
			ThisScale.Spirit = ThisScale.Mp5 / 2
		end
		ThisScale.Mp5 = nil
	end
	-- Many other stats were also removed, but items with those stats are being converted into similar stats, so no conversions
	-- are particularly necessary.  Spell power is being converted into Intellect on most items, but spell power will remain on
	-- weapons, and since both stats are staying around, there's no sensible conversion to apply.
	ThisScale.ArmorPenetration = nil
	ThisScale.BlockValue = nil
	ThisScale.BlockRating = nil
	ThisScale.DefenseRating = nil
	ThisScale.FeralAp = nil
	ThisScale.Rap = nil
	ThisScale.FireSpellDamage = nil
	ThisScale.ShadowSpellDamage = nil
	ThisScale.NatureSpellDamage = nil
	ThisScale.ArcaneSpellDamage = nil
	ThisScale.FrostSpellDamage = nil
	ThisScale.HolySpellDamage = nil
	ThisScale.Hp5 = nil
	ThisScale.Mana = nil
	ThisScale.Health = nil
	
	-- Colorless sockets are no longer valued by Pawn.  (Not the same as Prismatic Sockets.)
	ThisScale.ColorlessSocket = nil
	
	-- Elemental resistances are no longer valued by Pawn as of Pawn 1.6.
	ThisScale.AllResist = nil
	ThisScale.FireResist = nil
	ThisScale.ShadowResist = nil
	ThisScale.NatureResist = nil
	ThisScale.ArcaneResist = nil
	ThisScale.FrostResist = nil
	
	-- Pawn 1.6 removed base armor and bonus armor.
	if (ThisScale.Armor == nil) and (ThisScale.BaseArmor or ThisScale.BonusArmor) then
		ThisScale.Armor = (ThisScale.BaseArmor or 0) + (ThisScale.BonusArmor or 0)
	end
	ThisScale.BaseArmor = nil
	ThisScale.BonusArmor = nil
	
	-- Pawn 1.6.1 removed IsRelic and IsThrown
	ThisScale.IsRelic = nil
	ThisScale.IsThrown = nil
end

-- Replaces one incorrect stat with a correct stat.
function PawnReplaceStat(ThisScale, OldStat, NewStat)
	if ThisScale[OldStat] then
		if not ThisScale[NewStat] then ThisScale[NewStat] = ThisScale[OldStat] end
		ThisScale[OldStat] = nil
	end
end

-- Combines two stats into one.  For example, combines HitRating and SpellHitRating, putting the larger of the 
-- two values in HitRating.
function PawnCombineStats(ThisScale, PrimaryStat, SecondaryStat)
	if ThisScale[SecondaryStat] then
		if ThisScale[PrimaryStat] and ThisScale[PrimaryStat] > ThisScale[SecondaryStat] then
			-- If the primary stat is larger, do nothing.
		else
			-- If the secondary stat is larger, increase the value of the primary to the secondary.
			ThisScale[PrimaryStat] = ThisScale[SecondaryStat]
		end
		-- Regardless, clear out the secondary stat afterward.
		ThisScale[SecondaryStat] = nil
	end
end

-- Causes the Pawn private tooltip to be shown when next hovering an item.
--function PawnTestShowPrivateTooltip()
--	PawnPrivateTooltip:SetOwner(UIParent, "ANCHOR_TOPRIGHT")
--end

-- Hides the Pawn private tooltip (normal).
--function PawnTestHidePrivateTooltip()
--	PawnPrivateTooltip:SetOwner(UIParent, "ANCHOR_NONE")
--	PawnPrivateTooltip:Hide()
--end

-- Depending on the user's current tooltip icon settings, show and hide icons as appropriate.
function PawnToggleTooltipIcons()
	PawnAttachIconToTooltip(ItemRefTooltip)
	PawnAttachIconToTooltip(ShoppingTooltip1, true)
	PawnAttachIconToTooltip(ShoppingTooltip2, true)
	
	-- MultiTips compatibility
	PawnAttachIconToTooltip(ItemRefTooltip2)
	PawnAttachIconToTooltip(ItemRefTooltip3)
	PawnAttachIconToTooltip(ItemRefTooltip4)
	PawnAttachIconToTooltip(ItemRefTooltip5)
	
	-- EquipCompare compatibility
	PawnAttachIconToTooltip(ComparisonTooltip1, true)
	PawnAttachIconToTooltip(ComparisonTooltip2, true)
end

-- If tooltip icons are enabled, attaches an icon to the upper-left corner of a tooltip.  Otherwise, hides
-- any icons attached to that tooltip if they exist.
-- Optionally, the caller may include an item link so this function doesn't need to get one.
function PawnAttachIconToTooltip(Tooltip, AttachAbove, ItemLink)
	-- If the tooltip doesn't exist, exit now.
	if not Tooltip then return end

	-- Find the right texture to use, but skip all this if the user has icons turned off.
	local TextureName
	if PawnCommon.ShowTooltipIcons then
		-- Don't retrieve an item link if one was passed in.
		if not ItemLink then
			local _
			_, ItemLink = Tooltip:GetItem()
		end
		if ItemLink then
			TextureName = GetItemIcon(ItemLink)
		end
	end
	
	-- Now, if we don't have a texture to use, or icons are disabled, hide this icon if it's visible
	-- and then exit.
	local IconFrame = Tooltip.PawnIconFrame
	if not TextureName then
		if IconFrame then
			IconFrame:Hide()
			IconFrame.PawnIconTexture = nil
			Tooltip.PawnIconFrame = nil
		end
		return
	end
	
	-- Create the icon's frame if it doesn't already exist.
	if not IconFrame then
		IconFrame = CreateFrame("Frame", nil, Tooltip)
		Tooltip.PawnIconFrame = IconFrame
		IconFrame:SetWidth(37)
		IconFrame:SetHeight(37)
		
		local IconTexture = IconFrame:CreateTexture(nil, "BACKGROUND")
		IconTexture:SetTexture(TextureName)
		IconTexture:SetAllPoints(IconFrame)
		IconFrame.PawnIconTexture = IconTexture
	else
		-- If the icon already existed, then we just need to update the texture.
		IconFrame.PawnIconTexture:SetTexture(TextureName)
	end

	-- Attach the icon frame and show it.
	if AttachAbove then
		IconFrame:SetPoint("BOTTOMLEFT", Tooltip, "TOPLEFT", 2, -2)
	else
		IconFrame:SetPoint("TOPRIGHT", Tooltip, "TOPLEFT", 2, -2)
	end
	IconFrame:Show()
	
	return IconFrame
end

-- Hides any icons on a tooltip, if there are any.
function PawnHideTooltipIcon(TooltipName)
	-- Find the tooltip.  If it doesn't exist, we can skip out now.
	local Tooltip = getglobal(TooltipName)
	if not Tooltip then return end
	
	-- Is there an icon on it?  If not, exit.
	local IconFrame = Tooltip.PawnIconFrame
	if not IconFrame then return end
	
	-- Hide the icon frame if it's there, and remove the reference to it so it can be garbage-collected.
	IconFrame:Hide()
	IconFrame.PawnIconTexture = nil
	Tooltip.PawnIconFrame = nil
end

-- Comparer function for use in sort that sorts strings alphabetically, ignoring case, and also ignoring a
-- 10-character color format at the beginning of the string.
function PawnColoredStringCompare(a, b)
	return strlower(strsub(a, 11)) < strlower(strsub(b, 11))
end

-- Comparer function for use in sort that sorts sub-tables alphabetically by the localized name in the sub-table, ignoring case.
function PawnItemValueCompare(a, b)
	return strlower(a[7]) < strlower(b[7])
end

-- Takes an ItemEquipLoc and returns one or two slot IDs where that item type can be equipped.
-- Bags are not supported.
function PawnGetSlotsForItemType(ItemEquipLoc)
	if (not ItemEquipLoc) or (ItemEquipLoc == "") then return end
	return PawnItemEquipLocToSlot1[ItemEquipLoc], PawnItemEquipLocToSlot2[ItemEquipLoc]
end

-- Takes an item level and a rarity, and returns a roughly equivalent item level if that item were an epic.
-- This formula is based on the fact that when considering the scaling health of Ulduar vehicles, dropping
-- 13 levels on an epic alters the vehicle's health the same as replacing an epic with a blue of the same level.
-- This results in the .935 value; other values are simply assumptions.
function PawnGetEpicEquivalentItemLevel(ItemLevel, Rarity)
	if not ItemLevel or ItemLevel <= 1 or not Rarity then return 0 end
	if Rarity < 2 or Rarity > 5 then -- Common, poor, or heirloom
		return 0
	elseif Rarity == 2 then -- Uncommon
		return math.floor(ItemLevel * .87 + .05)
	elseif Rarity == 3 then	-- Rare
		return math.floor(ItemLevel * .935 + .05)
	elseif Rarity == 4 then -- Epic
		return ItemLevel
	elseif Rarity == 5 then -- Legendary
		return math.floor(ItemLevel * 1.065 + .05)
	end
end

-- Finds the best gems for a particular scale in one or more colors.
-- 	Parameters: ScaleName, FindRed, FindYellow, FindBlue
--		ScaleName: The name of the scale for which to find gems.
--		FindRed: If true, consider red gems as a possibility.
--		FindYellow: If true, consider yellow gems as a possibility.
--		FindBlue: If true, consider blue gems as a possibility.
--		FindMeta: If true, consider meta gems only.  Cannot be used with FindRed/Yellow/Blue/Cogwheel.
--		FindCogwheel: If true, consider cogwheels only.  Cannot be used with FindRed/Yellow/Blue/Meta.
--	Return value: Value, GemList
--		Value: The value of the best gem or gems for the chosen colors.
--		GemList: A table of gems of that value.  Each item in the list is in the standard Pawn item table format, and
--			the list is sorted alphabetically by name.
function PawnFindBestGems(ScaleName, FindRed, FindYellow, FindBlue, FindMeta, FindCogwheel)
	local BestScore = 0
	local BestItems = { }

	if (not FindRed) and (not FindYellow) and (not FindBlue) and (not FindMeta) and (not FindCogwheel) then
		VgerCore.Fail("PawnFindBestGems must be given a color of gem to search for.")
		return
	elseif
		(FindMeta and (FindRed or FindYellow or FindBlue or FindCogwheel)) or
		(FindCogwheel and (FindRed or FindYellow or FindBlue))
	then
		VgerCore.Fail("PawnFindBestGems can find colored gems, meta gems, OR cogwheels, but not simultaneously.")
		return 
	end
	
	-- Go through the list of gems, checking each item that matches one of the find criteria.
	local GemTable, GemData, ThisGem, _
	if FindMeta then
		GemTable = PawnMetaGemQualityTables[PawnCommon.Scales[ScaleName].MetaGemQualityLevel]
	elseif FindCogwheel then
		GemTable = PawnCogwheelQualityTables[PawnCommon.Scales[ScaleName].CogwheelQualityLevel]
	else
		GemTable = PawnGemQualityTables[PawnCommon.Scales[ScaleName].GemQualityLevel]
	end
	if not GemTable then
		VgerCore.Fail("Couldn't find gems for this scale because no gem quality level was selected.")
		return
	end
	for _, GemData in pairs(GemTable) do
		if FindMeta or FindCogwheel or (FindRed and GemData[2]) or (FindYellow and GemData[3]) or (FindBlue and GemData[4]) then
			-- This gem is of a color we care about, so let's check it out.
			ThisGem = PawnGetGemData(GemData)
			if ThisGem then
				local ThisValue = PawnGetItemValue(ThisGem.UnenchantedStats, ThisGem.Level, nil, ScaleName, false, true, true)
				if ThisValue and ThisValue > BestScore then
					-- This gem is better than any we've found so far.
					BestScore = ThisValue
					wipe(BestItems)
					tinsert(BestItems, ThisGem)
				elseif ThisValue and ThisValue == BestScore then
					-- This gem is tied with the best gems we've found so far.
					tinsert(BestItems, ThisGem)
				end
			else
				VgerCore.Fail("Failed to get information about gem " .. GemData[1])
			end
		end
	end
	
	-- Now we have a list of the best gems.  Sort them alphabetically.
	sort(BestItems, PawnItemComparer)
	
	-- In debug mode, display them.
	if PawnCommon.Debug then
		local Header = "=== Best "
		if FindRed then Header = Header .. "Red " end
		if FindYellow then Header = Header .. "Yellow " end
		if FindBlue then Header = Header .. "Blue " end
		if FindMeta then Header = Header .. "Meta " end
		if FindCogwheel then Header = Header .. "Cogwheel " end
		Header = Header .. "gems for " .. PawnGetScaleLocalizedName(ScaleName) .. ": ==="
		VgerCore.Message(Header)
		for _, ThisGem in pairs(BestItems) do
			VgerCore.Message("  " .. ThisGem.Link)
		end
		VgerCore.Message(" --> Score: " .. tostring(BestScore))
	end
	
	-- Return the value and list of gems.
	return BestScore, BestItems
	
end

-- Refreshes a cached item with new information if available.  Currently meant only for refreshing
-- best-gem item data, which often doesn't have a name or texture, with that information.
-- Returns true if it did anything.
function PawnRefreshCachedItem(Item)
	if not Item then
		VgerCore.Fail("PawnRefreshCachedItem requires an item table.")
		return false
	end
	
	-- Request the new information.
	local ItemName, _, _, _, _, _, _, _, _, ItemTexture = GetItemInfo(Item.ID)
	if not ItemName then
		-- The client doesn't have any further information on this item yet, so bail out.
		return false
	end
	
	-- Save this new information into the cached item record.
	Item.Name = ItemName
	Item.Texture = ItemTexture
	return true
end

-- Determines if an item is an upgrade for any of the current user's enabled scales, and if so, by how much.
-- Parameters:
--	Item: The item table for the item in question.
--	DoNotRescan: If best item data is not available, just return nil instead of rescanning.
-- Returns nothing if the item is not an upgrade and is not one of the player's best items.  Otherwise:
--	UpgradeInfo, BestItemFor, SecondBestItemFor
--	UpgradeInfo: a sorted table of upgrades, with each element being another table:
--		{ { ScaleName, LocalizedScaleName, PercentUpgrade, ExistingItem }, ... }
--		ScaleName: the raw scale name.
--		LocalizedScaleName: the localized scale name, suitable for display.
--		PercentUpgrade: for example, for an item that is a 15% upgrade over the current item, .15.
--		ExistingItemID: the item that would be replaced if the user upgraded to the item passed in.
--	BestItemFor, SecondBestItemFor: a table of scales for which this item is already the player's best or second-best item, or nil if none.
--		{ ["Scale1"] = true, ["Scale2"] = true }
function PawnIsItemAnUpgrade(Item, DoNotRescan)

	-- Before we begin, check for unsupported item types and bail out early if appropriate.
	if Item and type(Item) ~= "table" then
		VgerCore.Fail("Item must be a table of item stats, not '" .. type(Item) .. "'.")
		return
	end
	local InvType = Item.InvType
	if not InvType or InvType == "" or InvType == "INVTYPE_TRINKET" or InvType == "INVTYPE_BAG" or InvType == "INVTYPE_QUIVER" or InvType == "INVTYPE_TABARD" or InvType == "INVTYPE_BODY" or InvType == "INVTYPE_THROWN" or InvType == "INVTYPE_AMMO" or InvType == "INVTYPE_RELIC" then return nil end

	-- If the user doesn't want to see upgrades for 2H items when they're using 1H items or vice-versa, do that
	-- check now.
	if not PawnCommon.ShowBoth1HAnd2HUpgrades then
		local MainWeaponID = GetInventoryItemID("player", INVSLOT_MAINHAND) or GetInventoryItemID("player", INVSLOT_OFFHAND)
		if MainWeaponID then
			local MainWeapon = PawnGetItemData("item:" .. MainWeaponID)
			if MainWeapon then
				local MainWeaponInvType = MainWeapon.InvType
				if MainWeaponInvType == "INVTYPE_RANGED"  or MainWeaponInvType == "INVTYPE_RANGEDRIGHT" then
					if MainWeapon.Stats and MainWeapon.Stats.IsWand then
						MainWeaponInvType = "INVTYPE_WEAPONMAINHAND"
					else
						MainWeaponInvType = "INVTYPE_2HWEAPON"
					end
				end
				if MainWeaponInvType == "INVTYPE_2HWEAPON" then
					-- They're using a two-handed weapon.  Bail out now if this is a one-handed weapon.
					if InvType == "INVTYPE_WEAPON" or InvType == "INVTYPE_WEAPONMAINHAND" or InvType == "INVTYPE_WEAPONOFFHAND" or InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE" then return end
				else
					-- They're using a one-handed weapon.  Bail out now if this is a two-handed weapon.
					if InvType == "INVTYPE_2HWEAPON" then return end
				end
			end
		end
	end

	-- Is this item an heirloom that will continue to either scale or provide an XP boost?
	local IsScalingHeirloom = (UnitLevel("player") <= PawnGetMaxLevelItemIsUsefulHeirloom(Item))
	
	local _
	local UpgradeTable, BestItemTable, SecondBestItemTable
	local ScaleName, Scale
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		InvType = Item.InvType -- need to reset this here since it gets nil'ed out in the coming while loop
		if InvType == "INVTYPE_RANGED"  or InvType == "INVTYPE_RANGEDRIGHT" then
			-- Wands are one-handed weapons and all other ranged weapons are two-handed weapons.  We can't tell
			-- the difference based on the InvType alone.
			if Item.Stats and Item.Stats.IsWand then
				InvType = "INVTYPE_WEAPONMAINHAND"
			else
				InvType = "INVTYPE_2HWEAPON"
			end
		end
		
		if PawnIsScaleVisible(ScaleName) and not
			(Scale.DoNotShow1HUpgrades and (InvType == "INVTYPE_WEAPON" or InvType == "INVTYPE_WEAPONMAINHAND" or InvType == "INVTYPE_WEAPONOFFHAND" or InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE")) and not
			(Scale.DoNotShow2HUpgrades and InvType == "INVTYPE_2HWEAPON") and
			((not Scale.UpgradesFollowSpecialization) or PawnIsArmorBestTypeForPlayer(Item))
		then
			-- Find the best item for that slot.  Or, if a second-best item is available, compare versus that.
			local CharacterOptions = Scale.PerCharacterOptions[PawnPlayerFullName]
			if not CharacterOptions then
				VgerCore.Fail("PerCharacterOptions should be initialized before using PawnIsItemAnUpgrade.")
				return nil
			end
			if not CharacterOptions.BestItems then
				if DoNotRescan then return nil end
				-- If best item data hasn't been calculated yet, go ahead and calculate it now.  If you decide not to
				-- do this in final code, then we should at least always recalculate when a loot window appears.
				PawnFindBestItems(ScaleName)
			end
			
			local InvType2 = nil
			if InvType == "INVTYPE_WEAPON" then
				-- Check one-handed weapons against both the main hand and off hand, and report the best upgrade.
				-- (One-handed weapons aren't stored past the initial scan, so we don't need to check those.)
				InvType = "INVTYPE_WEAPONMAINHAND"
				if Scale.Values.IsOffHand == nil or Scale.Values.IsOffHand > PawnIgnoreStatValue then
					-- Only try putting off-hand weapons in the off hand if they fit there!
					InvType2 = "INVTYPE_WEAPONOFFHAND"
				end
			elseif InvType == "INVTYPE_ROBE" then
				-- Robes are chest armor.
				InvType = "INVTYPE_CHEST"
			elseif InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE" then
				-- Treat shields and held in off hand items the same as off-hand weapons since they go into the same slot.
				InvType = "INVTYPE_WEAPONOFFHAND"
			end
			-- TODO: A MH weapon can actually upgrade an OH weapon if the following are true:
			-- 1) The new MH weapon isn't better than the current MH one (because then it would upgrade that instead)
			-- 2) The current best MH weapon is a one-hander
			-- 3) The new MH weapon is better than the old OH weapon
			-- But, it's not clear how best to present this to the user, so this case (and the vice-versa case) is ignored for now.
			local ThisValue = nil
			local NewTableEntry = nil
			
			while InvType do
				local BestData = CharacterOptions.BestItems[InvType]
				if BestData then
					local BestValue = BestData[4] or BestData[1]
					local BestItem = BestData[5] or BestData[2]
					local BestMaxHeirloomLevel = BestData[6] or BestData[3]
					if BestValue then
						-- Don't bother looking for this item's value if we don't have a best item for this slot.
						if not ThisValue then _, ThisValue = PawnGetSingleValueFromItem(Item, ScaleName) end
						
						if Item.ID == BestData[2] then
							-- If the item IS the first best item for a scale, then it can't be an upgrade.  (Technically that's only the case if
							-- the item is unique or unique-equipped, but Pawn currently can't determine that.)
							NewTableEntry = nil
							if BestItemTable == nil then BestItemTable = { [ScaleName] = true } else BestItemTable[ScaleName] = true end
							break
						elseif Item.ID == BestData[5] then
							-- If it's the second-best item for a scale it's not an upgrade either.
							NewTableEntry = nil
							if SecondBestItemTable == nil then SecondBestItemTable = { [ScaleName] = true } else SecondBestItemTable[ScaleName] = true end
							break
						elseif ThisValue > BestValue * 1.005 and (IsScalingHeirloom or UnitLevel("player") >= MAX_PLAYER_LEVEL or UnitLevel("player") > BestMaxHeirloomLevel) then
							-- Hooray, it's an upgrade!  Add it to the table.
							-- (Only count upgrades that are at least 0.5% better.)
							-- If the best item is an heirloom, either the new one must be or the player must be at max level.
							local Difference = ThisValue - BestValue
							local PercentUpgrade = Difference / BestValue
							if NewTableEntry then
								-- We already found a best item for another inventory type.
								if PercentUpgrade > NewTableEntry.PercentUpgrade then
									NewTableEntry.PercentUpgrade = PercentUpgrade
									NewTableEntry.ExistingItemID = BestItem
								end
							else
								NewTableEntry = { ["ScaleName"] = ScaleName, ["LocalizedScaleName"] = Scale.LocalizedName or ScaleName, ["PercentUpgrade"] = PercentUpgrade, ["ExistingItemID"] = BestItem }
							end
						end
					end
				else
					-- Not having best item data for a particular slot isn't a bizarre case; it will happen often for low-level characters
					-- who don't have any helms or shoulders.
					if not ThisValue then _, ThisValue = PawnGetSingleValueFromItem(Item, ScaleName) end
					if ThisValue and ThisValue > 0 then
						NewTableEntry = { ["ScaleName"] = ScaleName, ["LocalizedScaleName"] = Scale.LocalizedName or ScaleName, ["PercentUpgrade"] = PawnBigUpgradeThreshold, ["ExistingItemID"] = BestItem }
					end
				end
				
				-- If this item counts as two types of items, now scan the other type.
				InvType = InvType2
				InvType2 = nil
			end -- loop through inventory types
			
			if NewTableEntry then
				if not UpgradeTable then UpgradeTable = { } end
				tinsert(UpgradeTable, NewTableEntry)
			end
			
		end -- if scale is visible
	end -- loop through scales
	
	if UpgradeTable then sort(UpgradeTable, PawnLocalizedScaleNameComparer) end
	
	-- Print out the contents of the upgrade table for debugging purposes.
	--if UpgradeTable then
	--	VgerCore.Message(tostring(Item.Link) .. " is an upgrade for:")
	--	local Upgrade
	--	for _, Upgrade in pairs(UpgradeTable) do
	--		VgerCore.Message("    " .. Upgrade.LocalizedScaleName .. ": " .. tostring(100 * Upgrade.PercentUpgrade) .. "% upgrade from item ID " .. tostring(Upgrade.ExistingItemID))
	--	end
	--else
	--	VgerCore.Message(tostring(Item.Link) .. " is not an upgrade.")
	--end
	--if BestItemTable then
	--	for ScaleName in pairs(BestItemTable) do
	--		VgerCore.Message("    " .. tostring(ScaleName) .. ": best item")
	--	end
	--end
	--if SecondBestItemTable then
	--	for ScaleName in pairs(SecondBestItemTable) do
	--		VgerCore.Message("    " .. tostring(ScaleName) .. ": second-best item")
	--	end
	--end
	
	return UpgradeTable, BestItemTable, SecondBestItemTable
end

-- Comparer function for tables with subtables including a LocalizedScaleName entry.
function PawnLocalizedScaleNameComparer(a, b)
	if not b then return a end
	if not a then return b end
	return strlower(a.LocalizedScaleName) < strlower(b.LocalizedScaleName)
end

-- Invalidates all lists of best items for all characters and scales.
function PawnInvalidateBestItems()
	local ScaleName
	for ScaleName, _ in pairs(PawnCommon.Scales) do
		PawnInvalidateBestItemsForScale(ScaleName)
	end
end

-- Invalidates ALL characters' best items for a single scale.  (This happens whenever that scale's values change.)
function PawnInvalidateBestItemsForScale(ScaleName)
	local Scale = PawnCommon.Scales[ScaleName]
	if not Scale then
		VgerCore.Fail("PawnInvalidateBestItemsForScale: ScaleName must be the name of an existing scale.")
		return
	end
	local CharacterName, CharacterOptions
	for CharacterName, CharacterOptions in pairs(Scale.PerCharacterOptions) do
		CharacterOptions.BestItems = nil
	end
end

-- Checks the player's equipped items for any new upgrades to his or her item sets.
function PawnCheckInventoryForUpgrades()
	local ScaleName
	for ScaleName, _ in pairs(PawnCommon.Scales) do
		PawnFindBestItems(ScaleName, true)
	end
end

-- Looks through a player's gear and finds the best items they have for that scale.
-- If InventoryOnly is true, then only check currently equipped items, not other things like equipment sets, unless no best
-- item data is currently available, in which case everything will be scanned as normal.
function PawnFindBestItems(ScaleName, InventoryOnly)
	local Scale = PawnCommon.Scales[ScaleName]
	if not Scale then
		VgerCore.Fail("PawnFindBestItems: ScaleName must be the name of an existing scale.")
		return
	end
	local CharacterOptions = Scale.PerCharacterOptions[PawnPlayerFullName]
	if not CharacterOptions then
		VgerCore.Fail("PerCharacterOptions should be initialized before using PawnFindBestItems on that scale.")
		return
	end
	
	if not CharacterOptions.Visible then
		-- This scale is not visible for this character.  We should invalidate best item data for the scale if it's present,
		-- and if it's not, just exit quickly.
		CharacterOptions.BestItems = nil
		return
	end
	
	local OldCacheSize = PawnItemCacheMaxSize
	PawnItemCacheMaxSize = 500 -- temporarily increase maximum cache size for performance reasons
	
	-- Start with the best items that we already know of.  Obviously in most cases, your existing best items
	-- are already your best ones.  This is a persistent per-scale per-character option, not just per-scale.
	local BestItems = CharacterOptions.BestItems
	if not BestItems then
		BestItems = { }
		InventoryOnly = false -- need to scan everything if we don't have existing valid data
		CharacterOptions.BestItems = BestItems
	end
	-- = { ["INVTYPE_HEAD"] = { 123.45, itemID, heirloom level }, ...,  ["INVTYPE_FINGER"] = { 67.8, itemID, level, 50.50, second itemID, second level }, ... }
	-- (Include a second-best item for INVTYPE_FINGER and INVTYPE_WEAPON)
	-- (ugh, if you ever have to change this again in the future, don't do raw array indices again... super-pain to add another index...)
	
	
	-- Helper function to check an item to see if it should go into BestItems, since we'll be performing this
	-- operation in different ways from multiple blocks of code.
	-- Returns true if the item is a new best or second-best item.
	local function CheckItem(ScaleName, BestItems, Item, PreviousItemID)
		-- Skip trinkets because we can't reliably tell which trinkets are best.
		-- Also skip item classes that don't have stats, and items that have a zero value.
		if not Item then return end
		local InvType = Item.InvType
		if not InvType or InvType == "" or InvType == "INVTYPE_TRINKET" or InvType == "INVTYPE_BAG" or InvType == "INVTYPE_QUIVER" or InvType == "INVTYPE_TABARD" or InvType == "INVTYPE_BODY" then return end
		local _, Value = PawnGetSingleValueFromItem(Item, ScaleName)
		if Value <= 0 then return end
		
		-- Merge some equivalent item types.
		if InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE" then
			InvType = "INVTYPE_WEAPONOFFHAND"
		elseif InvType == "INVTYPE_ROBE" then
			InvType = "INVTYPE_CHEST"
		elseif InvType == "INVTYPE_RANGED" or InvType == "INVTYPE_RANGEDRIGHT" then
			-- Wands are one-handed weapons and all other ranged weapons are two-handed weapons.  We can't tell
			-- the difference based on the InvType alone.
			if Item.Stats and Item.Stats.IsWand then
				InvType = "INVTYPE_WEAPONMAINHAND"
			else
				InvType = "INVTYPE_2HWEAPON"
			end
		end
		
		-- Okay, now do the calculations.
		local BestOfType = BestItems[InvType]
		if BestOfType == nil or Value > (BestOfType[1] + PawnEpsilon) then
			-- This item's an upgrade.
			if BestOfType == nil then
				BestOfType = { }
				BestItems[InvType] = BestOfType
			end
			if InvType == "INVTYPE_FINGER" or InvType == "INVTYPE_WEAPON" then
				-- If this is a ring or weapon, keep the current best item as a second-best item.
				BestOfType[4] = BestOfType[1]
				BestOfType[5] = BestOfType[2]
				BestOfType[6] = BestOfType[3]
			end
			BestOfType[1] = Value
			BestOfType[2] = Item.ID
			BestOfType[3] = PawnGetMaxLevelItemIsUsefulHeirloom(Item)
			return true
		elseif
			-- Only rings and one-handed weapons have second-best versions tracked.
			(InvType == "INVTYPE_FINGER" or InvType == "INVTYPE_WEAPON") and
			-- If we don't have a second item stored at all, this is obviously the second best.
			-- Otherwise, the new item's value must be greater than the current second best.
			(BestOfType[4] == nil or Value > (BestOfType[4] + PawnEpsilon)) and
			-- The item's ID must be different from the best item of this type, OR it must be the same
			-- as the last item that was scanned, indicating that the player has two copies of that item.
			-- Otherwise, we assume that the player only has one, so it can't be both first and second best.
			(Item.ID == PreviousItemID or Item.ID ~= BestOfType[2])
			then
			-- This item's an upgrade of the current second-best item.
			BestOfType[4] = Value
			BestOfType[5] = Item.ID
			BestOfType[6] = PawnGetMaxLevelItemIsUsefulHeirloom(Item)
			return true
		end
		return false
	end

	
	-- Obviously, check the player's currently equipped gear.
	local Slot, PreviousItemID
	for Slot = 1, 17 do if Slot ~= 4 and Slot ~= 13 and Slot ~= 14 then -- Skip slots 0 (ammo), 4 (shirt), 13-14 (trinkets), 18 (ranged/relic), and 19 (tabard)
		local Item = PawnGetItemDataForInventorySlot(Slot, true, "player")
		if Item then
			CheckItem(ScaleName, BestItems, Item, PreviousItemID)
			PreviousItemID = Item.ID
		end
	end end
	
	-- Now, scan all of the items in the player's equipment sets.
	if not InventoryOnly then
		local NumSets = GetNumEquipmentSets()
		local ItemsInSet = { }
		local i
		for i = 1, NumSets do
			wipe(ItemsInSet)
			GetEquipmentSetItemIDs(GetEquipmentSetInfo(i), ItemsInSet)
			PreviousItemID = nil
			for Slot = 1, 17 do if Slot ~= 4 and Slot ~= 13 and Slot ~= 14 then
				local ItemID = ItemsInSet[Slot]
				if ItemID and ItemID > 0 then
					local Item = PawnGetItemData("item:" .. ItemID)
					CheckItem(ScaleName, BestItems, Item, PreviousItemID)
				end
				PreviousItemID = ItemID
			end end
		end
	end
	
	-- Now we've scanned all of the items we're going to scan.  Next we have to assign out one-handed items to the main
	-- hand and off-hand slots as appropriate.
	PawnAssignOneHandedBestItems(Scale, BestItems)
	
	-- Finally, to test this out, print out the list of best items to the console.
	--VgerCore.Message("------------------------------------------------------------")
	--VgerCore.Message(VgerCore.Color.Blue .. "Pawn found the best items for " .. PawnGetScaleLocalizedName(ScaleName) .. ".")
	--VgerCore.Message(" ")
	--local InvType, BestOfType
	--for InvType, BestOfType in pairs(BestItems) do
	--	local _, ItemLink = GetItemInfo(BestOfType[2]
	--	VgerCore.Message(InvType .. ": " .. ItemLink .. " = " .. tostring(BestOfType[1]))
	--	if BestOfType[4] then
	--		_, ItemLink = GetItemInfo(BestOfType[5]
	--		VgerCore.Message("    and " .. ItemLink .. " = " .. BestOfType[4])
	--	end
	--end
	--VgerCore.Message(" ")
	--VgerCore.Message(string.format("The item cache now contains %s items.", #PawnItemCache))
	
	-- Restore the original cache size.  The cache will be trimmed the next time we try to add an item to it.
	PawnItemCacheMaxSize = OldCacheSize
end

-- Helper function to assign one-handed weapons to the main hand and off-hand best item slots.
function PawnAssignOneHandedBestItems(Scale, BestItems)
	-- First, get the values of the four weapons we're considering.
	local BestMH, BestOH, Best1H, SecondBest1H = 0, 0, 0, 0
	if BestItems.INVTYPE_WEAPONMAINHAND then BestMH = BestItems.INVTYPE_WEAPONMAINHAND[1] or 0 end
	if BestItems.INVTYPE_WEAPONOFFHAND then BestOH = BestItems.INVTYPE_WEAPONOFFHAND[1] or 0 end
	if BestItems.INVTYPE_WEAPON then
		-- Before continuing, if the best one-hand weapons have already been assigned to the main hand and off
		-- hand slots, remove them.  (This needs to happen in two separate phases; if a weapon appears in both one-hand
		-- slots, then having it as the best main hand item should not remove it from both slots.)
		if BestItems.INVTYPE_WEAPONMAINHAND and BestItems.INVTYPE_WEAPONMAINHAND[2] == BestItems.INVTYPE_WEAPON[2] then
			BestItems.INVTYPE_WEAPON[1] = BestItems.INVTYPE_WEAPON[4]
			BestItems.INVTYPE_WEAPON[2] = BestItems.INVTYPE_WEAPON[5]
			BestItems.INVTYPE_WEAPON[3] = BestItems.INVTYPE_WEAPON[6]
			BestItems.INVTYPE_WEAPON[4] = nil
			BestItems.INVTYPE_WEAPON[5] = nil
			BestItems.INVTYPE_WEAPON[6] = nil
		elseif BestItems.INVTYPE_WEAPONMAINHAND and BestItems.INVTYPE_WEAPONMAINHAND[2] == BestItems.INVTYPE_WEAPON[5] then
			BestItems.INVTYPE_WEAPON[4] = nil
			BestItems.INVTYPE_WEAPON[5] = nil
			BestItems.INVTYPE_WEAPON[6] = nil
		end
		if BestItems.INVTYPE_WEAPONOFFHAND and BestItems.INVTYPE_WEAPONOFFHAND[2] == BestItems.INVTYPE_WEAPON[2] then
			BestItems.INVTYPE_WEAPON[1] = BestItems.INVTYPE_WEAPON[4]
			BestItems.INVTYPE_WEAPON[2] = BestItems.INVTYPE_WEAPON[5]
			BestItems.INVTYPE_WEAPON[3] = BestItems.INVTYPE_WEAPON[6]
			BestItems.INVTYPE_WEAPON[4] = nil
			BestItems.INVTYPE_WEAPON[5] = nil
			BestItems.INVTYPE_WEAPON[6] = nil
		elseif BestItems.INVTYPE_WEAPONOFFHAND and BestItems.INVTYPE_WEAPONOFFHAND[2] == BestItems.INVTYPE_WEAPON[5] then
			BestItems.INVTYPE_WEAPON[4] = nil
			BestItems.INVTYPE_WEAPON[5] = nil
			BestItems.INVTYPE_WEAPON[6] = nil
		end
		
		Best1H = BestItems.INVTYPE_WEAPON[1] or 0
		SecondBest1H = BestItems.INVTYPE_WEAPON[4] or 0
	end
	
	-- Also check if the user is allowed to put one-handed weapons in the off hand.  (Remember that shields
	-- and off-hand frill have been converted into off-hand weapons, and real off-hand weapons will have a
	-- value of zero.)
	local CanUseOH = (Scale.Values.IsOffHand == nil or Scale.Values.IsOffHand > PawnIgnoreStatValue)
	-- Now, find which of the scenarios produces the largest final value.
	if		CanUseOH and
			(Best1H + SecondBest1H) >= (Best1H + BestOH) and
			(Best1H + SecondBest1H) >= (BestMH + Best1H) and
			(Best1H + SecondBest1H) >= (BestMH + BestOH)
	then
		-- The best scenario is to use both of the one-handed weapons.
		if BestItems.INVTYPE_WEAPON and BestItems.INVTYPE_WEAPON[1] then
			BestItems.INVTYPE_WEAPONMAINHAND = { BestItems.INVTYPE_WEAPON[1], BestItems.INVTYPE_WEAPON[2], BestItems.INVTYPE_WEAPON[3] }
		else
			BestItems.INVTYPE_WEAPONMAINHAND = nil
		end
		if BestItems.INVTYPE_WEAPON and BestItems.INVTYPE_WEAPON[4] then
			BestItems.INVTYPE_WEAPONOFFHAND = { BestItems.INVTYPE_WEAPON[4], BestItems.INVTYPE_WEAPON[5], BestItems.INVTYPE_WEAPON[6] }
		else
			BestItems.INVTYPE_WEAPONOFFHAND = nil
		end
	elseif	(Best1H + BestOH) >= (Best1H + SecondBest1H) and
			(Best1H + BestOH) >= (BestMH + Best1H) and
			(Best1H + BestOH) >= (BestMH + BestOH)
	then
		-- The best scenario is to use the best one-handed weapon in the main hand with the best off-hand weapon.
		if BestItems.INVTYPE_WEAPON and BestItems.INVTYPE_WEAPON[1] then
			BestItems.INVTYPE_WEAPONMAINHAND = { BestItems.INVTYPE_WEAPON[1], BestItems.INVTYPE_WEAPON[2], BestItems.INVTYPE_WEAPON[3] }
		else
			BestItems.INVTYPE_WEAPONMAINHAND = nil
		end
	elseif	CanUseOH and
			(BestMH + Best1H) >= (Best1H + SecondBest1H) and
			(BestMH + Best1H) >= (Best1H + BestOH) and
			(BestMH + Best1H) >= (BestMH + BestOH)
	then
		-- The best scenario is to use the best main hand weapon with the best one-handed weapon in the off hand.
		if BestItems.INVTYPE_WEAPON and BestItems.INVTYPE_WEAPON[1] then
			BestItems.INVTYPE_WEAPONOFFHAND = { BestItems.INVTYPE_WEAPON[1], BestItems.INVTYPE_WEAPON[2], BestItems.INVTYPE_WEAPON[3] }
		else
			BestItems.INVTYPE_WEAPONOFFHAND = nil
		end
	else
		-- The best scenario is to use the best main and off-hand weapons and ignore the one-handed weapons.
	end
	BestItems.INVTYPE_WEAPON = nil
end

-- Comparer function for use in sort that sorts items by their name.
function PawnItemComparer(a, b)
	if not b then return a end
	if not a then return b end
	return a.Name < b.Name
end

-- Called whenever the player's inventory changed.  We need to check their currently-equipped items whenever this happens.
function PawnOnInventoryChanged()
	-- Ignore equipment change events when the player is in combat: they're unlikely to equip a NEW item in combat,
	-- and we wouldn't want this procedure to slow them down even a little.
	if InCombatLockdown() then return end
	-- Ignore inventory change events before we've finished loading.
	if not PawnScaleProvidersInitialized then return end

	PawnCheckInventoryForUpgrades()
end

-- Called whenever the player vendors or destroys an item.  We need to check their best-item sets for that item and remove it
-- if they just got rid of one of their best items.
function PawnOnItemLost(ItemID)
	if not ItemID then return end
	local _, _, _, _, _, _, _, _, InvType = GetItemInfo(ItemID)
	if not InvType or InvType == "" or InvType == "INVTYPE_TRINKET" or InvType == "INVTYPE_BAG" or InvType == "INVTYPE_QUIVER" or InvType == "INVTYPE_TABARD" or InvType == "INVTYPE_BODY" then return end
	if InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE" then
		InvType = "INVTYPE_WEAPONOFFHAND"
	elseif InvType == "INVTYPE_ROBE" then
		InvType = "INVTYPE_CHEST"
	elseif InvType == "INVTYPE_RANGED" or InvType == "INVTYPE_RANGEDRIGHT" then
		-- A ranged weapon could be one-handed (weapons) or two-handed (everything else) but it always goes in the main hand.
		InvType = "INVTYPE_WEAPONMAINHAND"
	end
	local InvType2 = nil
	if InvType == "INVTYPE_WEAPON" then
		InvType = "INVTYPE_WEAPONMAINHAND"
		InvType2 = "INVTYPE_WEAPONOFFHAND"
	end
	
	local ScaleName, Scale
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		local CharacterOptions = Scale.PerCharacterOptions[PawnPlayerFullName]
		if CharacterOptions then
			local BestItems = CharacterOptions.BestItems
			if BestItems then
				local RemovedItem = false
				-- Okay, this scale has a list of best items.  Look through the list and remove this item if present.
				local ItemsForSlot = BestItems[InvType]
				if ItemsForSlot and (ItemsForSlot[2] == ItemID or ItemsForSlot[5] == ItemID) then
					RemovedItem = true
				elseif InvType2 then
					ItemsForSlot = BestItems[InvType2]
					if ItemsForSlot and (ItemsForSlot[2] == ItemID or ItemsForSlot[5] == ItemID) then
						RemovedItem = true
					end
				end
				-- If they lost an item from this scale's list of best items, we need to invalidate the best items list for the scale.
				if RemovedItem then
					--VgerCore.Message(VgerCore.Color.Blue .. "Pawn: Warning! You just lost your best " .. _G[InvType] .. " from " .. PawnGetScaleLocalizedName(ScaleName) .. ". :(")
					CharacterOptions.BestItems = nil
				end
			end
		end
	end
end

-- When an item is locked due to being picked up, remember its ID in case they decide to delete it.
function PawnOnItemLocked(arg1, arg2)
	local ItemLink
	if arg2 == nil then
		ItemLink = GetInventoryItemLink("player", arg1)
	else
		ItemLink = GetContainerItemLink(arg1, arg2)
	end
	if ItemLink then
		PawnLastCursorItemID = PawnGetItemIDFromLink(ItemLink)
	else
		PawnLastCursorItemID = nil
	end
end

-- Takes a list of items and trims it down to only those items that are interesting upgrades.  If none are upgrades, then
-- one of the items is chosen as most valuable.
-- Arguments: List
--	List: A table of items in this format: { Item, RewardType, Usable }
--		Item: An item data table.
--		RewardType: "reward" or "choice".  If "reward", the player is guaranteed to get this item, and it should not be selected as most valuable.
--		Usable: true or false.  If false, the player cannot currently use this item and thus it should not be presented as an upgrade.
--		Additional fields can be present.
-- Returns: List
--	List: The same table passed in, with one additional field added: { ..., Result }
--		Result: "upgrade" if the item is an upgrade, "vendor" if the item is the most valuable choice, "trinket" if the item is a trinket, or nil if none of the above.
function PawnFindInterestingItems(List)
	local Info, _
	local HighestValue, HighestValueInfo = 0, nil
	local DoNotVendor
	
	for _, Info in pairs(List) do
		if Info.Item.InvType == "INVTYPE_TRINKET" then
			Info.Result = "trinket"
		end
		if Info.Usable and PawnIsItemAnUpgrade(Info.Item) then
			-- If it's usable and an upgrade, mark it as such.
			Info.Result = "upgrade"
			-- If it's a choice item, then we shouldn't pick a choice item to vendor.
			if Info.RewardType == "choice" then DoNotVendor = true end
		elseif Info.RewardType == "choice" and Info.Item.InvType == "INVTYPE_TRINKET" then
			-- If one of the choices is a trinket, don't mark any items as vendor items.
			DoNotVendor = true
		elseif (not DoNotVendor) and Info.RewardType == "choice" then
			-- If we haven't already found a choice item upgrade, and this is a choice item, see
			-- if it's the best thing to vendor.
			local _, _, _, _, _, _, _, _, _, _, Value = GetItemInfo(Info.Item.Link)
			if Value and Value > HighestValue then
				HighestValue = Value
				HighestValueInfo = Info
			end
		end
	end
	
	if (not DoNotVendor) and HighestValueInfo then
		HighestValueInfo.Result = "vendor"
	end
	
	return List
end

-- Given an item table, returns true if the item is of the player's armor specialization OR if it's not armor
-- at all.  Returns false if it's the wrong type of armor for the current character's class and level.
function PawnIsArmorBestTypeForPlayer(Item)
	local Stats = Item.UnenchantedStats
	if not Stats then return false end
	-- If the item isn't armor then we don't need to check anything.	
	if (not Stats.IsCloth) and (not Stats.IsLeather) and (not Stats.IsMail) and (not Stats.IsPlate) then return true end
	-- At level 40 some classes learn a new type of armor.
	-- Before level 50 it's fine if the player is wearing the wrong type of armor.
	local Level = UnitLevel("player")
	local IsLevelForBestArmorType = (Level >= 40)
	local IsLevelForSpecialization = (Level >= 50)
	-- Now, the rest depends on the user's class.
	local _, Class = UnitClass("player")
	if Class == "MAGE" or Class == "PRIEST" or Class == "WARLOCK" then
		-- Cloth classes are easy!
		if Stats.IsCloth then return true else return false end
	elseif Class == "DRUID" or Class == "ROGUE" or Class == "MONK" then
		if Stats.IsLeather then
			return true
		elseif Stats.IsCloth then
			return not IsLevelForBestArmorType
		else
			return false
		end
	elseif Class == "HUNTER" or Class == "SHAMAN" then
		if IsLevelForSpecialization then
			if Stats.IsMail then return true else return false end
		elseif Stats.IsMail and IsLevelForBestArmorType then
			return true
		elseif Stats.IsLeather or Stats.IsCloth then
			return true
		else
			return false
		end
	elseif Class == "DEATHKNIGHT" or Class == "PALADIN" or Class == "WARRIOR" then
		if IsLevelForSpecialization then
			if Stats.IsPlate then return true else return false end
		elseif Stats.IsPlate then
			return IsLevelForBestArmorType
		else
			return true
		end
	end
	VgerCore.Fail("PawnIsArmorBestTypeForPlayer didn't know how to handle this item.")
end

-- Determines how best to reforge an item to maximize its value for a particular scale.
-- Parameters: Item, ScaleName, NoInstructions
--	Item: The item data table to reforge.
--	ScaleName: The name of the scale to use.
--	NoInstructions: If true, only the ValueDelta will be calculated and returned.
-- Returns: ValueDelta, ReforgeString, SuggestedCappedStat
--	ValueDelta: The increase in the item's value if this reforge is performed.
--	ReforgeString: A localized string that explains how to reforge the item, such as "25 Critical Strike Rating into Haste Rating".
--	SuggestedCappedStat: If one of the suggested reforgings was from a capped stat (Hit or Expertise), true, otherwise, false.
-- If it's impossible to reforge the item, nil is returned.  (This would be the case regardless of the scale passed in, so there's no need to call this
-- again for the same item and a different scale.)  If it's possible to reforge an item but unwise, the delta will be 0 and the reforge
-- string will be a localized string containing an explanation.
function PawnFindOptimalReforging(Item, ScaleName, NoInstructions)
	-- Items below level 200 can't be reforged.
	if not Item.Level or Item.Level < 200 then return end
	local InvType = Item.InvType
	if InvType == "nil" or InvType == "" or InvType == "INVTYPE_TABARD" or InvType == "INVTYPE_BAG" then return end
	
	local Scale = PawnCommon.Scales[ScaleName]
	local Values = Scale.Values
	local Stats = Item.UnenchantedStats
	if not Stats then return end
	
	return PawnFindOptimalReforgingCore(ScaleName, Scale, Values, Stats, NoInstructions)
end

-- Core functionality of PawnFindOptimalReforging that can be used without an Item table constructed.
-- PawnGetItemValue also uses this.
function PawnFindOptimalReforgingCore(ScaleName, Scale, Values, Stats, NoInstructions)
	-- Find the stat to reforge TO.
	local ReforgeTo
	if not NoInstructions then ReforgeTo = { } end
	local BestValue = 0
	local Stat, _
	for _, Stat in pairs(PawnReforgeableStats) do
		if not Stats[Stat] then
			local Value = Values[Stat]
			-- The item doesn't already have this stat.
			if Value and Value > BestValue then
				-- This is the best reforgeable stat so far.
				if not NoInstructions then
					wipe(ReforgeTo)
					tinsert(ReforgeTo, PawnStatFriendlyNames[Stat])
				end
				BestValue = Value
			elseif Value == BestValue then
				-- This stat ties the current best value, so add it to the list.
				if not NoInstructions then
					tinsert(ReforgeTo, PawnStatFriendlyNames[Stat])
				end
			end
		end
	end
	if BestValue == 0 or (ReforgeTo and #ReforgeTo == #PawnReforgeableStats) then
		if not NoInstructions then
			return 0, PawnLocal.ReforgeInstructionsNoReforge, false
		else
			return 0
		end
	end
	
	-- Now, find the stat to reforge FROM.
	local ReforgeFrom = { }	
	local BestReforgeDelta = 0
	local SuggestedCappedStat = false
	for _, Stat in pairs(PawnReforgeableStats) do
		local Value = Values[Stat]
		if not Value or Value < 0 then Value = 0 end -- This would be a great: reforging away a stat with no value at all!
		local Quantity = Stats[Stat]
		if Quantity and Value < BestValue then
			local Quantity = Stats[Stat]
			if Quantity then
				local ReforgeQuantity = floor(Quantity * .4)
				if ReforgeQuantity > 0 then
					local StatDelta = ReforgeQuantity * (BestValue - Value)
					if StatDelta > BestReforgeDelta then
						-- This is the stat with the best reforge potential so far.
						if not NoInstructions then
							SuggestedCappedStat = (Stat == "HitRating" or Stat == "ExpertiseRating")
							wipe(ReforgeFrom)
							tinsert(ReforgeFrom, format("%d %s", ReforgeQuantity, PawnStatFriendlyNames[Stat]))
						end
						BestReforgeDelta = StatDelta
					elseif StatDelta == BestReforgeDelta then
						-- This stat has the same reforge potential as the best so far.
						if not NoInstructions then
							SuggestedCappedStat = SuggestedCappedStat or (Stat == "HitRating" or Stat == "ExpertiseRating")
							tinsert(ReforgeFrom, format("%d %s", ReforgeQuantity, PawnStatFriendlyNames[Stat]))
						end
					end
				end
			end
		end
	end
	if BestReforgeDelta == 0 then
		if not NoInstructions then
			return 0, PawnLocal.ReforgeInstructionsNoReforge, false
		else
			return 0
		end
	end
	
	-- Apply the scale's normalization factor if present.
	if Scale.NormalizationFactor and Scale.NormalizationFactor > 0 and PawnScaleTotals[ScaleName] then
		BestReforgeDelta = Scale.NormalizationFactor * BestReforgeDelta / PawnScaleTotals[ScaleName]
	end
	
	-- Finally, turn it all into a nice localized string.
	local ReforgeString
	if not NoInstructions then
		ReforgeString = format(PawnLocal.ReforgeInstructions, PawnConcatenateWithConjunction(ReforgeFrom, PawnLocal.Or), PawnConcatenateWithConjunction(ReforgeTo, PawnLocal.Or))
	end
	
	return BestReforgeDelta, ReforgeString, SuggestedCappedStat
end

-- Appends the strings in a table together with commas and a conjunction ("or ") as appropriate.  The conjunction can be nil, but if it isn't, it should end in a space.
function PawnConcatenateWithConjunction(Table, Conjunction)
	local Size = #Table
	if Conjunction == nil then Conjunction = "" end
	if Size == 0 then
		return ""
	elseif Size == 1 then
		return Table[1]
	elseif Size == 2 then
		return Table[1] .. " " .. Conjunction .. Table[2]
	else
		local Concatenated = ""
		local Index = 1
		local Item, _
		for _, Item in ipairs(Table) do
			if Index == Size then
				Concatenated = Concatenated .. Conjunction .. Item
			else
				Concatenated = Concatenated .. Item .. ", "
			end
			Index = Index + 1
		end
		return Concatenated
	end
end

-- Returns true if the player is a high-level engineer and is interested in seeing stuff about cogwheels in the UI.
function PawnPlayerUsesCogwheels()
	local Profession1, Profession2 = GetProfessions()
	return UnitLevel("player") >= 81 and (
		(Profession1 and (GetProfessionInfo(Profession1) == PawnLocal.EngineeringName)) or
		(Profession2 and (GetProfessionInfo(Profession2) == PawnLocal.EngineeringName))
		)
end

-- Returns the maximum level an item is a useful heirloom item, or 0 if it never is.  As long as the player's level
-- is equal to or less than this number, this item is always considered superior to other items that don't meet
-- these same requirements.
function PawnGetMaxLevelItemIsUsefulHeirloom(Item)
	if Item.UnenchantedStats and Item.UnenchantedStats.MaxScalingLevel then
		-- This item scales until you reach MaxScalingLevel.
		-- Verified as of patch 5.0.5: the level 1-80 heirloom items stop granting their XP bonus as soon as
		-- you hit level 80.  Previously Pawn valued those items as being always superior until you hit level 81.
		return Item.UnenchantedStats.MaxScalingLevel - 1
	else
		-- This item doesn't scale.
		return 0
	end
end

------------------------------------------------------------
-- Pawn API
------------------------------------------------------------

-- Resets all custom Pawn scales.
function PawnResetScales()
	return PawnResetScalesCore(true, false)
end

-- Resets all read-only scales from scale providers.
function PawnResetProviderScales()
	return PawnResetScalesCore(false, true)
end

-- Common code for scale resetting functions.
function PawnResetScalesCore(ResetCustomScales, ResetProviderScales)
	local ScaleName, Scale, _
	local ScalesToRemove = {}
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		if (ResetProviderScales and Scale.Provider) or (ResetCustomScales and ScaleProvider == nil) then tinsert(ScalesToRemove, ScaleName) end
	end
	for _, ScaleName in pairs(ScalesToRemove) do
		PawnCommon.Scales[ScaleName] = nil
	end
	PawnResetTooltips()
	return true
end

-- Adds a new scale with no values.  Returns true if successful.
function PawnAddEmptyScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnAddEmptyScale(\"ScaleName\")")
		return false
	elseif PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnCommon.Scales[ScaleName] = PawnGetEmptyScale()
	PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName] = { }
	PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName].Visible = true
	PawnRecalculateScaleTotal(ScaleName)
	return true
end

-- Adds a new scale with the default values.  Returns true if successful.
function PawnAddDefaultScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnAddDefaultScale(\"ScaleName\")")
		return false
	elseif PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnCommon.Scales[ScaleName] = PawnGetDefaultScale()
	PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName] = { }
	PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName].Visible = true
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return true
end

-- Deletes a scale.  Returns true if successful.
function PawnDeleteScale(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnDeleteScale(\"ScaleName\")")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("ScaleName cannot be the name of a read-only scale.")
		return false
	end
	
	PawnCommon.Scales[ScaleName] = nil
	PawnRecalculateScaleTotal(ScaleName)
	PawnResetTooltips()
	return true
end

-- Renames an existing scale.  Returns true if successful.
function PawnRenameScale(OldScaleName, NewScaleName)
	if (not OldScaleName) or (OldScaleName == "") or (not NewScaleName) or (NewScaleName == "") then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be empty.  Usage: PawnRenameScale(\"OldScaleName\", \"NewScaleName\")")
		return false
	elseif OldScaleName == NewScaleName then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be the same.")
		return false
	elseif not PawnCommon.Scales[OldScaleName] then
		VgerCore.Fail("OldScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnCommon.Scales[NewScaleName] then
		VgerCore.Fail("NewScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("ScaleName cannot be the name of a read-only scale.")
		return false
	end
	
	PawnCommon.Scales[NewScaleName] = PawnCommon.Scales[OldScaleName]
	PawnCommon.Scales[OldScaleName] = nil
	PawnRecalculateScaleTotal(OldScaleName)
	PawnRecalculateScaleTotal(NewScaleName)
	PawnResetTooltips()
	return true
end

-- Creates a new scale based on an old one.  Returns true if successful.
function PawnDuplicateScale(OldScaleName, NewScaleName)
	if (not OldScaleName) or (OldScaleName == "") or (not NewScaleName) or (NewScaleName == "") then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be empty.  Usage: PawnDuplicateScale(\"OldScaleName\", \"NewScaleName\")")
		return false
	elseif OldScaleName == NewScaleName then
		VgerCore.Fail("OldScaleName and NewScaleName cannot be the same.")
		return false
	elseif not PawnCommon.Scales[OldScaleName] then
		VgerCore.Fail("OldScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnCommon.Scales[NewScaleName] then
		VgerCore.Fail("NewScaleName cannot be the name of an existing scale, and is case-sensitive.")
		return false
	end

	-- Create the copy.
	PawnCommon.Scales[NewScaleName] = {}
	PawnCommon.Scales[NewScaleName].Color = PawnCommon.Scales[OldScaleName].Color
	PawnCommon.Scales[NewScaleName].SmartGemSocketing = PawnCommon.Scales[OldScaleName].SmartGemSocketing
	PawnCommon.Scales[NewScaleName].GemQualityLevel = PawnCommon.Scales[OldScaleName].GemQualityLevel
	PawnCommon.Scales[NewScaleName].SmartMetaGemSocketing = PawnCommon.Scales[OldScaleName].SmartMetaGemSocketing
	PawnCommon.Scales[NewScaleName].MetaGemQualityLevel = PawnCommon.Scales[OldScaleName].MetaGemQualityLevel
	PawnCommon.Scales[NewScaleName].CogwheelQualityLevel = PawnCommon.Scales[OldScaleName].CogwheelQualityLevel
	PawnCommon.Scales[NewScaleName].NormalizationFactor = PawnCommon.Scales[OldScaleName].NormalizationFactor
	PawnCommon.Scales[NewScaleName].PerCharacterOptions = {}
	PawnCommon.Scales[NewScaleName].PerCharacterOptions[PawnPlayerFullName] = {}
	PawnCommon.Scales[NewScaleName].PerCharacterOptions[PawnPlayerFullName].Visible = true
	PawnCommon.Scales[NewScaleName].Values = {}
	local NewScale = PawnCommon.Scales[NewScaleName].Values
	for StatName, Value in pairs(PawnCommon.Scales[OldScaleName].Values) do
		NewScale[StatName] = Value
	end
	
	-- Do post-copy calculations, and we're done.
	PawnRecalculateScaleTotal(NewScaleName)
	PawnResetTooltips()
	return true
end

-- Returns the value of one stat in a scale, or nil if unsuccessful.
function PawnGetStatValue(ScaleName, StatName)
	if (not ScaleName) or (ScaleName == "") or (not StatName) or (StatName == "") then
		VgerCore.Fail("ScaleName and StatName cannot be empty.  Usage: x = PawnGetStatValue(\"ScaleName\", \"StatName\")")
		return nil
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	return PawnCommon.Scales[ScaleName].Values[StatName]
end

-- Returns true if a particular scale exists, or false if not.
function PawnDoesScaleExist(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnDoesScaleExist(\"ScaleName\")")
		return false
	end
	
	if PawnCommon.Scales[ScaleName] then
		return true
	else
		return false
	end
end

-- Returns a table of all stats and their values for a particular scale, or nil if unsuccessful.
-- This returns the actual internal table of stat values, so be careful not to modify it!
function PawnGetAllStatValues(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnGetAllStatValues(\"ScaleName\")")
		return nil
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	--local TableCopy = {}
	--for StatName, Value in pairs(PawnCommon.Scales[ScaleName].Values) do
	--	TableCopy[StatName] = Value
	--end
	--return TableCopy
	return PawnCommon.Scales[ScaleName].Values
end

-- Sets the value of one stat in a scale.  Returns true if successful.
-- Use 0 or nil as the Value to remove a stat from the scale.
function PawnSetStatValue(ScaleName, StatName, Value)
	if (not ScaleName) or (ScaleName == "") or (not StatName) or (StatName == "") then
		VgerCore.Fail("ScaleName and StatName cannot be empty.  Usage: PawnSetStatValue(\"ScaleName\", \"StatName\", Value)")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("ScaleName cannot be the name of a read-only scale.")
		return false
	end
	
	if Value == 0 then Value = nil end
	PawnCommon.Scales[ScaleName].Values[StatName] = Value
	PawnRecalculateScaleTotal(ScaleName) -- also recalculates socket values
	PawnInvalidateBestItemsForScale(ScaleName)
	PawnResetTooltips()
	return true
end

-- Returns a table of all Pawn scale names.  Returns all custom scales not from scale providers, whether visible or not.
-- For more information in one big table, use PawnGetAllScalesEx.  This method is provided here for backwards compatibility.
-- DEPRECATED
function PawnGetAllScales()
	local TableCopy = {}
	local ScaleName, Scale
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		if (not Scale.Provider) or (Scale.ProviderActive) then
			-- Don't include scales from a provider that isn't active any longer.  (Abandoned provider scales)
			tinsert(TableCopy, ScaleName)
		end
	end
	sort(TableCopy, VgerCore.CaseInsensitiveComparer)
	return TableCopy
end

-- Return a sorted table of all Pawn scale names and some data about each scale.
-- Each element in the table returned is a table with these values:
-- 	{ Name, LocalizedName, Header, IsVisible }
-- 	Name: The internal name of the scale.  Examples: "My custom scale"; "\"Wowhead\":DruidFeralDps"
-- 	LocalizedName: The display name of the scale.  Examples: "My custom scale"; "Druid feral DPS"
-- 	Header: The header text to display above this scale.  Examples: "Vger's scales"; "Wowhead scales"
-- 	IsVisible: Whether or not this scale is visible for the current character.  Examples: true, true
--	IsProvider: Whether or not this scale comes from a scale provider.  Examples: true, false
function PawnGetAllScalesEx()
	local TableCopy = {}
	local ScaleName, Scale
	local ActiveScalesHeader = format(PawnLocal.VisibleScalesHeader, UnitName("player"))
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		local IsVisible = PawnIsScaleVisible(ScaleName)
		local ScaleData =
		{
			["Name"] = ScaleName,
			["LocalizedName"] = Scale.LocalizedName or ScaleName,
			["IsVisible"] = IsVisible,
			["IsProvider"] = Scale.Provider ~= nil
		}
		if IsVisible then
			ScaleData.Header = ActiveScalesHeader
		elseif Scale.Provider and Scale.ProviderActive then
			ScaleData.Header = PawnScaleProviders[Scale.Provider].Name
		else
			ScaleData.Header = PawnLocal.HiddenScalesHeader
		end
		if (not Scale.Provider) or (Scale.ProviderActive) then
			-- Don't include scales from a provider that isn't active any longer.  (Abandoned provider scales)
			tinsert(TableCopy, ScaleData)
		--else
		--	VgerCore.Message("Not including " .. ScaleName .. " because it seems to be abandoned.")
		end
	end
	sort(TableCopy, PawnGetAllScalesExComparer)
	
	return TableCopy
end

-- Sort function used by PawnGetAllScalesEx.  Returns true if a should sort before b.
function PawnGetAllScalesExComparer(a, b)
	if not b then return a end
	if not a then return b end
	-- First, if one is visible and the other is not, then sort the visible ones first.
	local AVisible = a.IsVisible
	local BVisible = b.IsVisible
	if AVisible and not BVisible then return true end
	if BVisible and not AVisible then return false end
	-- They're both the same visibility.  Sort custom (non-provider) scales first.
	local AIsProvider = a.IsProvider
	local BIsProvider = b.IsProvider
	if AIsProvider and not BIsProvider then return false end
	if BIsProvider and not AIsProvider then return true end
	-- Then, sort by provider.
	if AIsProvider or BIsProvider then
		local AProvider = PawnGetProviderNameFromScale(a.Name)
		local BProvider = PawnGetProviderNameFromScale(b.Name)
		if AProvider and BProvider and AProvider ~= BProvider then
			return strlower(PawnGetProviderLocalizedName(AProvider)) < strlower(PawnGetProviderLocalizedName(BProvider))
		end
	end
	-- If both scales are from the same provider, then just sort by display name, case-insensitive.
	return strlower(a.LocalizedName) < strlower(b.LocalizedName)
end

-- Gets the preferred gem quality level for a scale.  (See Gems.lua.)
function PawnGetGemQualityLevel(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnGetGemQualityLevel(\"ScaleName\")")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	return PawnCommon.Scales[ScaleName].GemQualityLevel
end

-- Gets the preferred meta gem quality level for a scale.  (See Gems.lua.)
function PawnGetMetaGemQualityLevel(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnGetMetaGemQualityLevel(\"ScaleName\")")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	return PawnCommon.Scales[ScaleName].MetaGemQualityLevel
end

-- Sets the preferred gem quality level for a scale.  (See Gems.lua.)
function PawnSetGemQualityLevel(ScaleName, QualityLevel)
	if (not ScaleName) or (ScaleName == "") or (not QualityLevel) or (not PawnGemQualityTables[QualityLevel]) then
		VgerCore.Fail("ScaleName and QualityLevel cannot be empty.  Usage: PawnSetGemQualityLevel(\"ScaleName\", QualityLevel)")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnCommon.Scales[ScaleName].GemQualityLevel = QualityLevel
	PawnRecalculateScaleTotal(ScaleName) -- also recalculates socket values
	PawnInvalidateBestItemsForScale(ScaleName)
	PawnResetTooltips()
	return true
end

-- Sets the preferred metagem quality level for a scale.  (See Gems.lua.)
function PawnSetMetaGemQualityLevel(ScaleName, QualityLevel)
	if (not ScaleName) or (ScaleName == "") or (not QualityLevel) or (not PawnMetaGemQualityTables[QualityLevel]) then
		VgerCore.Fail("ScaleName and QualityLevel cannot be empty.  Usage: PawnSetMetaGemQualityLevel(\"ScaleName\", QualityLevel)")
		return false
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	end
	
	PawnCommon.Scales[ScaleName].MetaGemQualityLevel = QualityLevel
	PawnRecalculateScaleTotal(ScaleName) -- also recalculates socket values
	PawnInvalidateBestItemsForScale(ScaleName)
	PawnResetTooltips()
	return true
end

-- Enables or disables smart gem socketing for a scale.
function PawnSetSmartGemSocketing(ScaleName, Value)
	local Scale = PawnCommon.Scales[ScaleName]
	if not ScaleName or ScaleName == "" or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("Can't change a read-only scale.")
		return false
	end
	
	Scale.SmartGemSocketing = Value
	PawnRecalculateScaleTotal(PawnUICurrentScale)
	PawnInvalidateBestItemsForScale(PawnUICurrentScale)
	PawnResetTooltips()
	return true
end

-- Enables or disables smart meta gem socketing for a scale.
function PawnSetSmartMetaGemSocketing(ScaleName, Value)
	local Scale = PawnCommon.Scales[ScaleName]
	if not ScaleName or ScaleName == "" or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("Can't change a read-only scale.")
		return false
	end
	
	Scale.SmartMetaGemSocketing = Value
	PawnRecalculateScaleTotal(PawnUICurrentScale)
	PawnInvalidateBestItemsForScale(PawnUICurrentScale)
	PawnResetTooltips()
	return true
end

-- Changes the normalization factor for a scale.  (Expected values are 1/true and 0/false/nil.)
function PawnSetScaleNormalizationFactor(ScaleName, Value)
	local Scale = PawnCommon.Scales[ScaleName]
	if not ScaleName or ScaleName == "" or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return false
	elseif PawnScaleIsReadOnly(ScaleName) then
		VgerCore.Fail("Can't change a read-only scale.")
		return false
	end
	
	if Value == true then Value = 1 elseif Value == 0 or Value == false then Value = nil end
	Scale.NormalizationFactor = Value
	PawnInvalidateBestItemsForScale(PawnUICurrentScale) -- it'll be the same items as before, but with new values
	PawnResetTooltips()
	return true
end

-- Creates a Pawn scale tag for a scale.
--	Parameters: ScaleName
--		ScaleName: The name of a Pawn scale.
--	Return value: ScaleTag, or nil if unsuccessful.
--		ScaleTag: A Pawn scale tag.  Example:  '( Pawn: v1: "Healbot": Stamina=1, Intellect=1.24 )'
function PawnGetScaleTag(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnGetScaleTag(\"ScaleName\")")
		return
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return
	elseif not PawnCommon.Scales[ScaleName].Values then
		return
	end
	
	-- Concatenate the stats.
	local ScaleFriendlyName = PawnGetScaleLocalizedName(ScaleName)
	local ScaleTag = "( Pawn: v" .. PawnCurrentScaleVersion .. ": \"" .. ScaleFriendlyName .. "\": "
	local AddComma = false
	local IncludeThis
	local SmartGemSocketing = PawnCommon.Scales[ScaleName].SmartGemSocketing
	local SmartMetaGemSocketing = PawnCommon.Scales[ScaleName].SmartMetaGemSocketing
	for StatName, Value in pairs(PawnCommon.Scales[ScaleName].Values) do
		local IncludeThis = (Value and Value ~= 0)
		 -- If smart gem socketing is enabled, don't include socket stats.
		if IncludeThis and (StatName == "PrismaticSocket" or StatName == "CogwheelSocket") then IncludeThis = false end
		if IncludeThis and SmartGemSocketing and (StatName == "RedSocket" or StatName == "YellowSocket" or StatName == "BlueSocket") then IncludeThis = false end
		if IncludeThis and SmartMetaGemSocketing and (StatName == "MetaSocket") then IncludeThis = false end
		if IncludeThis then
			if AddComma then ScaleTag = ScaleTag .. ", " end
			ScaleTag = ScaleTag .. StatName .. "=" .. tostring(Value)
			AddComma = true
		end
	end
	-- Add gem quality levels.
	if AddComma then ScaleTag = ScaleTag .. ", " end
	ScaleTag = ScaleTag .. "GemQualityLevel=" .. tostring(PawnCommon.Scales[ScaleName].GemQualityLevel)
	ScaleTag = ScaleTag .. ", MetaGemQualityLevel=" .. tostring(PawnCommon.Scales[ScaleName].MetaGemQualityLevel)
	
	ScaleTag = ScaleTag .. " )"
	return ScaleTag
end

-- Imports a Pawn scale tag, adding that scale to the current character.
--	Parameters: ScaleTag, Overwrite
--		ScaleTag: A Pawn scale tag to add.  Example:  '( Pawn: v1: "Healbot": Stamina=1, Intellect=1.24 )'
--		Overwrite: If true, this function will overwrite an existing scale with the same name.
--	Return value: Status, ScaleName
--		Status: One of the PawnImportScaleResult* constants.
--		ScaleName: The name of the Pawn scale specified by ScaleTag, or nil if ScaleTag could not be parsed.
function PawnImportScale(ScaleTag, Overwrite)
	local ScaleName, Values = PawnParseScaleTag(ScaleTag)
	if not ScaleName then
		-- This tag couldn't be parsed.
		return PawnImportScaleResultTagError
	end
	
	local AlreadyExists = PawnCommon.Scales[ScaleName] ~= nil
	if AlreadyExists and (PawnScaleIsReadOnly(ScaleName) or not Overwrite) then
		-- A scale with this name already exists.  You can't import a scale with the same name as an existing one,
		-- unless you specify Overwrite = true.
		return PawnImportScaleResultAlreadyExists, ScaleName
	end
	
	-- Looks like everything's okay.  Import the scale.  If the scale already exists but Overwrite = true was passed,
	-- don't change other options about this scale, such as the color.
	if not AlreadyExists then
		-- REVIEW: Shouldn't this really use the default new blank scale codepath?
		PawnCommon.Scales[ScaleName] = { }
		PawnCommon.Scales[ScaleName].PerCharacterOptions = { }
		PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName] = { }
		PawnCommon.Scales[ScaleName].PerCharacterOptions[PawnPlayerFullName].Visible = true
	end
	PawnCommon.Scales[ScaleName].Values = Values	
	PawnCorrectScaleErrors(ScaleName)
	
	-- Gem quality levels are included as if they're a stat, but they're not.  Move them to a scale setting.  (If this property
	-- isn't set it will be added later.)
	if Values.GemQualityLevel then
		PawnCommon.Scales[ScaleName].GemQualityLevel = Values.GemQualityLevel
		Values.GemQualityLevel = nil
	end
	if Values.MetaGemQualityLevel then
		PawnCommon.Scales[ScaleName].MetaGemQualityLevel = Values.MetaGemQualityLevel
		Values.MetaGemQualityLevel = nil
	end
	
	-- Determine whether to automatically set socket values based on whether or not socket values were specified
	-- in the scale.
	if not AlreadyExists then
		if (not Values.RedSocket) and (not Values.YellowSocket) and (not Values.BlueSocket) then
			PawnCommon.Scales[ScaleName].SmartGemSocketing = true
		end
		if (not Values.MetaSocket) then
			PawnCommon.Scales[ScaleName].SmartMetaGemSocketing = true
		end
	end
	
	PawnRecalculateScaleTotal(ScaleName)
	if AlreadyExists then PawnInvalidateBestItemsForScale(ScaleName) end
	PawnResetTooltips()
	return PawnImportScaleResultSuccess, ScaleName
end

-- Sets the visibility of all scales from a particular scale provider to be visible or hidden in a single operation.
function PawnSetAllScaleProviderScalesVisible(ProviderInternalName, Visible)
	if (not PawnPlayerFullName) then
		VgerCore.Fail("PawnSetAllScaleProviderScalesVisible failed because Pawn didn't know your character's name yet.")
		return nil
	end
	if (not ProviderInternalName) or (ProviderInternalName == "") then
		VgerCore.Fail("ProviderInternalName cannot be empty.  Usage: PawnSetAllScaleProviderScalesVisible(\"ProviderInternalName\", Visible)")
		return nil
	end
	
	-- Using the provider internal name provided, produce a prefix that we'll search for in the list of scales.  This works because
	-- the format of a provider scale is "ProviderName":ScaleName.
	local ScaleNamePrefix = PawnGetProviderScaleName(ProviderInternalName, "")
	local ScaleNamePrefixLength = strlen(ScaleNamePrefix)
	
	-- Loop through all scales and turn them on or off.
	local ScaleName, Scale
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		if strsub(ScaleName, 1, ScaleNamePrefixLength) == ScaleNamePrefix then
			Scale.PerCharacterOptions[PawnPlayerFullName].Visible = Visible
			PawnResetTooltips()
		end
	end
	return true
end

-- Sets whether or not a scale is visible.  If Visible is nil, it will be considered as false.
function PawnSetScaleVisible(ScaleName, Visible)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnSetScaleVisible(\"ScaleName\", Visible)")
		return nil
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	local Scale = PawnCommon.Scales[ScaleName]
	if Scale.PerCharacterOptions[PawnPlayerFullName].Visible ~= Visible then
		Scale.PerCharacterOptions[PawnPlayerFullName].Visible = Visible
		PawnResetTooltips()
	end
	return true
end

-- Returns true if a given scale is visible in tooltips.
function PawnIsScaleVisible(ScaleName)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: x = PawnIsScaleVisible(\"ScaleName\")")
		return nil
	elseif not PawnCommon.Scales[ScaleName] then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	local Scale = PawnCommon.Scales[ScaleName]
	if Scale.PerCharacterOptions == nil then
		VgerCore.Fail("All per-character options for " .. ScaleName .. " were missing.")
		return false
	end
	if Scale.PerCharacterOptions[PawnPlayerFullName] == nil then
		VgerCore.Fail("Per-character options for this character (" .. PawnPlayerFullName .. ") and scale (" .. ScaleName .. ") were missing.")
		return false
	end
	return Scale.PerCharacterOptions[PawnPlayerFullName].Visible
end

-- Gets the color of a scale in hex format.  If the scale doesn't specify a color, the default is returned.
-- If Unenchanted is true, then the unenchanted color for the scale is returned.
function PawnGetScaleColor(ScaleName, Unenchanted)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: rrggbb = PawnGetScaleColor(\"ScaleName\", Unenchanted)")
		return VgerCore.Color.Blue
	end
	local Scale = PawnCommon.Scales[ScaleName]
	if not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return VgerCore.Color.Blue
	end
	
	if Unenchanted then
		if Scale.UnenchantedColor and strlen(Scale.UnenchantedColor) == 6 then return "|cff" .. Scale.UnenchantedColor end
		return VgerCore.Color.DarkBlue
	else
		if Scale.Color and strlen(Scale.Color) == 6 then return "|cff" .. Scale.Color end
		return VgerCore.Color.Blue
	end
end

-- Sets the color of a scale in six-character hex format.  The unenchanted color for the scale will also be set
-- to a slightly darker color.
function PawnSetScaleColor(ScaleName, HexColor)
	if (not ScaleName) or (ScaleName == "") then
		VgerCore.Fail("ScaleName cannot be empty.  Usage: PawnGetScaleColor(\"ScaleName\", \"rrggbb\")")
		return nil
	end
	local Scale = PawnCommon.Scales[ScaleName]
	if not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	if not HexColor or strlen(HexColor) ~= 6 then
		VgerCore.Fail("HexColor must be a six-digit hexadecimal color code, such as '66c0ff'.")
		return nil
	end

	local r, g, b = VgerCore.HexToRGB(HexColor)
	Scale.Color = HexColor
	Scale.UnenchantedColor = VgerCore.RGBToHex(r * PawnScaleColorDarkFactor, g * PawnScaleColorDarkFactor, b * PawnScaleColorDarkFactor)
end

-- Gets whether a stat is a 1-handed weapon stat, a 2-handed weapon stat, or neither.  (Only tracks things that go into either the main hand
-- or off-hand slot.  Ranged weapons are neither.)
function PawnGetWeaponSetForStat(StatName)
	if StatName == "IsAxe" or StatName == "IsDagger" or StatName == "IsFist" or StatName == "IsMace" or StatName == "IsSword" or StatName == "IsOffHand" or StatName == "IsFrill" then
		return 1
	elseif StatName == "Is2HAxe" or StatName == "Is2HMace" or StatName == "IsPolearm" or StatName == "IsStaff" or StatName == "Is2HSword" then
		return 2
	else
		return nil
	end
end

-- Gets whether or not upgrades are shown for either 1- or 2-handed weapons.
function PawnGetShowUpgradesForWeapons(ScaleName, WeaponSet)
	local Scale = PawnCommon.Scales[ScaleName]
	if (not ScaleName) or (ScaleName == "") or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	if WeaponSet ~= 1 and WeaponSet ~= 2 then
		VgerCore.Fail("WeaponSet must be 1 or 2.")
		return nil
	end
	
	if WeaponSet == 1 then
		return not Scale.DoNotShow1HUpgrades
	else
		return not Scale.DoNotShow2HUpgrades
	end
end

-- Sets whether or not upgrades are shown for either 1- or 2-handed weapons.
function PawnSetShowUpgradesForWeapons(ScaleName, WeaponSet, ShowUpgrades)
	local Scale = PawnCommon.Scales[ScaleName]
	if (not ScaleName) or (ScaleName == "") or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	if WeaponSet ~= 1 and WeaponSet ~= 2 then
		VgerCore.Fail("WeaponSet must be 1 or 2.")
		return nil
	end

	if WeaponSet == 1 then
		Scale.DoNotShow1HUpgrades = not ShowUpgrades
	else
		Scale.DoNotShow2HUpgrades = not ShowUpgrades
	end
	PawnInvalidateBestItemsForScale(ScaleName)
	PawnResetTooltips()
end

-- Gets whether only the current player's best armor type is shown for upgrades after level 50.
function PawnGetUpgradesFollowSpecialization(ScaleName)
	local Scale = PawnCommon.Scales[ScaleName]
	if (not ScaleName) or (ScaleName == "") or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	return Scale.UpgradesFollowSpecialization
end

-- Sets whether only the current player's best armor type is shown for upgrades after level 50.
function PawnSetUpgradesFollowSpecialization(ScaleName, FollowSpecialization)
	local Scale = PawnCommon.Scales[ScaleName]
	if (not ScaleName) or (ScaleName == "") or not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	
	if FollowSpecialization then
		Scale.UpgradesFollowSpecialization = true
	else
		Scale.UpgradesFollowSpecialization = false
	end
	PawnInvalidateBestItemsForScale(ScaleName)
	PawnResetTooltips()
end

-- Returns true if a scale is read-only.
function PawnScaleIsReadOnly(ScaleName)
	local Scale = PawnCommon.Scales[ScaleName]
	return Scale and Scale.Provider ~= nil
end

-- Returns the localized name for a scale if it has one.  Otherwise, it returns the scale's unlocalized name.
function PawnGetScaleLocalizedName(ScaleName)
	local Scale = PawnCommon.Scales[ScaleName]
	if Scale and Scale.LocalizedName then
		return Scale.LocalizedName
	else
		return ScaleName
	end
end

-- Uninitialize the plugin infrastructure and clean up our stale data.  We'll do this upon logging out or reloading the UI.
function PawnUnitializePlugins()
	-- Remove values from all read-only scales from providers so they don't get serialized to SavedVariables unnecessarily.
	local ScaleName, Scale
	for ScaleName, Scale in pairs(PawnCommon.Scales) do
		if Scale.Provider then
			Scale.ProviderActive = nil
			Scale.Values = nil
			Scale.Header = nil
		end
	end
	
	-- Clear out the provider data.
	PawnScaleProviders = nil
end

-- Initializes all delay-loaded scale providers.
function PawnInitializePlugins()
	-- This only needs to be done once.  PawnAddPluginScaleProvider will take care of anything that needs to
	-- happen after this is called.
	if PawnScaleProvidersInitialized then return end
	PawnScaleProvidersInitialized = true
	
	-- Go through the list of scale providers and call their initialization function.  They'll create all of their
	-- scales as necessary.
	local Provider, _
	for _, Provider in pairs(PawnScaleProviders) do
		if Provider.Function then
			-- After we call each provider's initialization function, empty it out so that function can be
			-- garbage-collected if necessary.
			Provider.Function()
			Provider.Function = nil
		end
	end
end

-- Registers a plugin scale provider.
-- Arguments: ProviderInternalName, LocalizedName
--	ProviderInternalName: An unlocalized internal name for the scale provider.
--	LocalizedName: The localized name for the scale provider, to show up in the UI.
-- 	Function: A function to call that adds the scales when it is time.
function PawnAddPluginScaleProvider(ProviderInternalName, LocalizedName, Function)
	-- If the scale provider already exists, ignore the second registration.
	if PawnScaleProviders[ProviderInternalName] then return end
	
	if strfind(ProviderInternalName, "\"") then
		VgerCore.Fail("Pawn scale providers cannot include double quotes ('\"') in their name.")
		return
	end
	
	if PawnScaleProvidersInitialized then
		-- If we've already initialized scale providers, just do this one immediately.
		PawnScaleProviders[ProviderInternalName] = { ["Name"] = LocalizedName }
		Function()
	else
		-- Otherwise, we'll get to it later.
		VgerCore.Assert(Function, "Scale provider \"" .. LocalizedName .. "\" was registered but won't initialize properly because no initialization function was specified.")
		PawnScaleProviders[ProviderInternalName] = { ["Name"] = LocalizedName, ["Function"] = Function }
	end
end

-- Given a scale provider name and a scale name, returns the full name of a scale from a provider.
function PawnGetProviderScaleName(ProviderInternalName, ScaleInternalName)
	return "\"" .. ProviderInternalName .. "\":" .. ScaleInternalName
end

-- Given a scale internal name, return the provider internal name.
function PawnGetProviderNameFromScale(ScaleInternalName)
	-- If this isn't a provider scale, then just return the scale name.
	if not ScaleInternalName or strsub(ScaleInternalName, 1, 1) ~= "\"" then return ScaleInternalName end

	-- Otherwise, get the provider name.
	local Pos = strfind(ScaleInternalName, "\"", 2, true)
	if not Pos then
		VgerCore.Fail("Didn't understand the provider name in the scale " .. tostring(ScaleInternalName) .. ".")
		return ScaleInternalName
	end
	return strsub(ScaleInternalName, 2, Pos - 1)
end

-- Given a provider internal name, return the localized name.
function PawnGetProviderLocalizedName(ProviderInternalName)
	local Provider = PawnScaleProviders[ProviderInternalName]
	if not Provider then
		VgerCore.Fail("Pawn scale provider \"" .. tostring(ProviderInternalName) .. " is not registered yet so we can't get its display name.")
		return ProviderInternalName
	end

	return Provider.Name
end

-- Adds a plugin scale to Pawn.  Plugin scales are read-only once added, and are not saved; they must be added on every login.
-- If this plugin scale already exists (it was added this session), it will be overwritten.
function PawnAddPluginScale(ProviderInternalName, ScaleInternalName, LocalizedName, Color, Values, NormalizationFactor, WeaponSetToHideUpgradesFor)
	if not PawnScaleProviders[ProviderInternalName] then
		VgerCore.Fail("A scale provider with that name is not registered.  Use PawnAddPluginScaleProvider first.")
		return
	end
	
	PawnInitializeOptions()
	
	-- Now, add this new scale to the master list (starting with default scale options), or if it's already there, update it with the data from the scale provider.
	local ScaleFullName = PawnGetProviderScaleName(ProviderInternalName, ScaleInternalName)
	local NewScale
	if PawnCommon.Scales[ScaleFullName] then
		NewScale = PawnCommon.Scales[ScaleFullName]
	else
		NewScale = PawnGetEmptyScale()
	end
	NewScale.ProviderActive = true
	NewScale.Provider = ProviderInternalName
	NewScale.LocalizedName = LocalizedName
	NewScale.Header = PawnScaleProviders[ProviderInternalName].Name
	NewScale.NormalizationFactor = NormalizationFactor
	NewScale.Values = Values
	if not NewScale.PerCharacterOptions then NewScale.PerCharacterOptions = {} end
	if not NewScale.PerCharacterOptions[PawnPlayerFullName] then NewScale.PerCharacterOptions[PawnPlayerFullName] = {} end
	if not PawnCommon.Scales[ScaleFullName] then PawnCommon.Scales[ScaleFullName] = NewScale end
	if NewScale.DoNotShow1HUpgrades == nil then NewScale.DoNotShow1HUpgrades = (WeaponSetToHideUpgradesFor == 1) end
	if NewScale.DoNotShow2HUpgrades == nil then NewScale.DoNotShow2HUpgrades = (WeaponSetToHideUpgradesFor == 2) end
	
	if not NewScale.Color then PawnSetScaleColor(ScaleFullName, Color) end -- If the user has customized the color, don't overwrite theirs.
end

-- Returns the ItemID of the best item that a user has for a particular scale and inventory type.
-- Parameters:
--	ScaleName: The scale to find a best item for.
--	InvType: An inventory type (ItemEquipLoc) for which to find a best item, such as "INVTYPE_HEAD".
--	Index: If 1 or nil, return the best item for that slot.  If 2, return the second-best item for that slot.  (Most types don't have a second-best item.)
--	DoNotRescan: If true, don't rescan for best items if information is not available.
function PawnGetBestItemID(ScaleName, InvType, Index, DoNotRescan)
	if not InvType or InvType == "" or InvType == "INVTYPE_TRINKET" or InvType == "INVTYPE_BAG" or InvType == "INVTYPE_QUIVER" or InvType == "INVTYPE_TABARD" or InvType == "INVTYPE_BODY" then return nil end

	Index = Index or 1
	if Index ~= 1 and Index ~= 2 then
		VgerCore.Fail("Index must be 1 or 2.")
		return nil
	end
	local Scale = PawnCommon.Scales[ScaleName]
	if not Scale then
		VgerCore.Fail("ScaleName must be the name of an existing scale, and is case-sensitive.")
		return nil
	end
	local CharacterOptions = Scale.PerCharacterOptions[PawnPlayerFullName]
	if not CharacterOptions then
		VgerCore.Fail("This method can't be used if per-character options haven't been set up for this scale yet.")
		return nil
	end
	local BestItems = CharacterOptions.BestItems
	if not BestItems then
		if DoNotRescan then return end
		PawnFindBestItems(ScaleName)
		if not BestItems then return end
	end
	
	if InvType == "INVTYPE_WEAPON" then
		if Index == 2 then InvType = "INVTYPE_WEAPONOFFHAND" Index = 1 else InvType = "INVTYPE_WEAPONMAINHAND" end
	elseif InvType == "INVTYPE_SHIELD" or InvType == "INVTYPE_HOLDABLE" then
		InvType = "INVTYPE_WEAPONOFFHAND"
	elseif InvType == "INVTYPE_ROBE" then
		InvType = "INVTYPE_CHEST"
	elseif InvType == "INVTYPE_RANGED" or InvType == "INVTYPE_RANGEDRIGHT" then
		-- All ranged weapons go in the main hand now.
		InvType = "INVTYPE_WEAPONMAINHAND"
	end
	local BestData = BestItems[InvType]
	if not BestData then return nil end
	
	return BestData[3 * Index - 1]
end

-- Shortcut for PawnIsItemAnUpgrade that takes in an item ID.
-- Returns data in the same format as PawnIsItemAnUpgrade.
function PawnIsItemIDAnUpgrade(ItemID)
	local Item = PawnGetItemData("item:" .. ItemID)
	if not Item then return end
	return PawnIsItemAnUpgrade(Item)
end

-- Shows or hides the Pawn UI.
function PawnUIShow()
	if not PawnUIFrame then
		VgerCore.Fail("Pawn UI is not loaded!")
		return
	end
	if PawnUIFrame:IsShown() then
		PawnUIFrame:Hide()
	else
		PawnUIFrame:Show()
	end
end

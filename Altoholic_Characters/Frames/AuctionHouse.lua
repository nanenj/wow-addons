local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local ORANGE	= "|cFFFF7F00"
local RED		= "|cFFFF0000"
local TEAL		= "|cFF00FF9A"

local view
local viewSortField = "name"
local viewSortOrder
local isViewValid
local listType			-- "Auctions" or "Bids"

local function SortByName(a, b)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()

	local _, idA = DS:GetAuctionHouseItemInfo(character, listType, a)
	local _, idB = DS:GetAuctionHouseItemInfo(character, listType, b)
	
	local textA = GetItemInfo(idA) or ""
	local textB = GetItemInfo(idB) or ""
	
	if viewSortOrder then
		return textA < textB
	else
		return textA > textB
	end
end

local function SortByPlayer(a, b)
	-- sort by owner (for bids), or highBidder (for auctions), both the 4th return value
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local _, _, _, nameA = DS:GetAuctionHouseItemInfo(character, listType, a)
	local _, _, _, nameB = DS:GetAuctionHouseItemInfo(character, listType, b)

	nameA = nameA or ""
	nameB = nameB or ""
	
	if viewSortOrder then
		return nameA < nameB
	else
		return nameA > nameB
	end
end

local function SortByPrice(a, b)
	-- sort by owner (for bids), or highBidder (for auctions), both the 4th return value
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local _, _, _, _, _, priceA = DS:GetAuctionHouseItemInfo(character, listType, a)
	local _, _, _, _, _, priceB = DS:GetAuctionHouseItemInfo(character, listType, b)

	if viewSortOrder then
		return priceA < priceB
	else
		return priceA > priceB
	end
end

local PrimaryLevelSort = {	-- sort functions for the mains
	["name"] = SortByName,
	["owner"] = SortByPlayer,
	["highBidder"] = SortByPlayer,
	["buyoutPrice"] = SortByPrice,
}

local function BuildView()
	view = view or {}
	wipe(view)
	
	local character = addon.Tabs.Characters:GetAltKey()
	if not character then return end
	
	local num
	if listType == "Auctions" then
		num = DataStore:GetNumAuctions(character) or 0
	else
		num = DataStore:GetNumBids(character) or 0
	end
	
	for i = 1, num do
		table.insert(view, i)
	end
	
	table.sort(view, PrimaryLevelSort[viewSortField])

	isViewValid = true
end

addon.AuctionHouse = {}

local ns = addon.AuctionHouse		-- ns = namespace

local updateHandler

function ns:Update()
	if not isViewValid then
		BuildView()
	end

	ns[updateHandler](ns)
end

function ns:SetUpdateHandler(h)
	updateHandler = h
end

function ns:SetListType(list)
	listType = list
	ns:SetUpdateHandler("Update"..list)
end

function ns:Sort(self, field, AHType)
	viewSortField = field
	viewSortOrder = self.ascendingSort
	
	ns:SetListType(AHType)
	ns:InvalidateView()
end

function ns:InvalidateView()
	isViewValid = nil
	if AltoholicFrameAuctions:IsVisible() then
		ns:Update()
	end
end

function ns:UpdateAuctions()
	local VisibleLines = 7
	local frame = "AltoholicFrameAuctions"
	local entry = frame.."Entry"

	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local numAuctions = DS:GetNumAuctions(character) or 0
	AltoholicTabCharactersStatus:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), format(L["Auctions %s(%d)"], GREEN, numAuctions)))
	
	if numAuctions == 0 then		-- make sure the scroll frame is cleared !
		addon:ClearScrollFrame( _G[ frame.."ScrollFrame" ], entry, VisibleLines, 41)
		return
	end

	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );
	
	for i=1, VisibleLines do
		local line = i + offset
		if line <= numAuctions then
			local index = view[line]

			local isGoblin, itemID, count, highBidder, startPrice, buyoutPrice, timeLeft = DS:GetAuctionHouseItemInfo(character, "Auctions", index)

			local itemName, _, itemRarity = GetItemInfo(itemID)
			itemName = itemName or L["N/A"]
			itemRarity = itemRarity or 1
			_G[ entry..i.."Name" ]:SetText("|c" .. select(4, GetItemQualityColor(itemRarity)) .. itemName)
			
			if not timeLeft then	-- secure this in case it is nil (may happen when other auction monitoring addons are present)
				timeLeft = 1
			elseif (timeLeft < 1) or (timeLeft > 4) then
				timeLeft = 1
			end
			
			_G[ entry..i.."TimeLeft" ]:SetText( TEAL .. _G["AUCTION_TIME_LEFT"..timeLeft] 
								.. " (" .. _G["AUCTION_TIME_LEFT"..timeLeft .. "_DETAIL"] .. ")")

			local bidder = (isGoblin) and L["Goblin AH"] .. "\n" or ""
			bidder = (highBidder) and WHITE .. highBidder or RED .. NO_BIDS
			_G[ entry..i.."HighBidder" ]:SetText(bidder)
			
			_G[ entry..i.."Price" ]:SetText(addon:GetMoneyString(startPrice) .. "\n"  
					.. GREEN .. BUYOUT .. ": " ..  addon:GetMoneyString(buyoutPrice))
			_G[ entry..i.."ItemIconTexture" ]:SetTexture(GetItemIcon(itemID));
			if count and count > 1 then
				_G[ entry..i.."ItemCount" ]:SetText(count)
				_G[ entry..i.."ItemCount" ]:Show()
			else
				_G[ entry..i.."ItemCount" ]:Hide()
			end

			_G[ entry..i.."Item" ]:SetID(index)
			_G[ entry..i ]:Show()
		else
			_G[ entry..i ]:Hide()
		end
	end
	
	if numAuctions < VisibleLines then
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], numAuctions, VisibleLines, 41);
	end
end

function ns:UpdateBids()
	local VisibleLines = 7
	local frame = "AltoholicFrameAuctions"
	local entry = frame.."Entry"
	
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local numBids = DS:GetNumBids(character) or 0
	AltoholicTabCharactersStatus:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), format(L["Bids %s(%d)"], GREEN, numBids)))
	
	if numBids == 0 then		-- make sure the scroll frame is cleared !
		addon:ClearScrollFrame( _G[ frame.."ScrollFrame" ], entry, VisibleLines, 41)
		return
	end
	
	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );
	
	for i=1, VisibleLines do
		local line = i + offset
		if line <= numBids then
			local index = view[line]
			local isGoblin, itemID, count, ownerName, bidPrice, buyoutPrice, timeLeft = DS:GetAuctionHouseItemInfo(character, "Bids", index)
			
			local itemName, _, itemRarity = GetItemInfo(itemID)
			itemName = itemName or L["N/A"]
			itemRarity = itemRarity or 1
			_G[ entry..i.."Name" ]:SetText("|c" .. select(4, GetItemQualityColor(itemRarity)) .. itemName)
			
			_G[ entry..i.."TimeLeft" ]:SetText( TEAL .. _G["AUCTION_TIME_LEFT"..timeLeft] 
								.. " (" .. _G["AUCTION_TIME_LEFT"..timeLeft .. "_DETAIL"] .. ")")
			
			if isGoblin then
				_G[ entry..i.."HighBidder" ]:SetText(L["Goblin AH"] .. "\n" .. WHITE .. ownerName)
			else
				_G[ entry..i.."HighBidder" ]:SetText(WHITE .. ownerName)
			end
			
			_G[ entry..i.."Price" ]:SetText(ORANGE .. CURRENT_BID .. ": " .. addon:GetMoneyString(bidPrice) .. "\n"  
					.. GREEN .. BUYOUT .. ": " ..  addon:GetMoneyString(buyoutPrice))
			_G[ entry..i.."ItemIconTexture" ]:SetTexture(GetItemIcon(itemID));
			if count and count > 1 then
				_G[ entry..i.."ItemCount" ]:SetText(count)
				_G[ entry..i.."ItemCount" ]:Show()
			else
				_G[ entry..i.."ItemCount" ]:Hide()
			end

			_G[ entry..i.."Item" ]:SetID(index)
			_G[ entry..i ]:Show()
		else
			_G[ entry..i ]:Hide()
		end
	end
	
	if numBids < VisibleLines then
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], numBids, VisibleLines, 41);
	end
end

function ns:OnEnter(frame)
	local character = addon.Tabs.Characters:GetAltKey()
	local _, id = DataStore:GetAuctionHouseItemInfo(character, listType, frame:GetID())
	if not id then return end
	
	local _, link = GetItemInfo(id)
	if not link then return end

	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(link);
	GameTooltip:Show();
end

function ns:OnClick(frame, button)
	local character = addon.Tabs.Characters:GetAltKey()
	local _, id = DataStore:GetAuctionHouseItemInfo(character, listType, frame:GetID())
	if not id then return end

	local _, link = GetItemInfo(id)
	if not link then return end
	
	if ( button == "LeftButton" ) and ( IsControlKeyDown() ) then
		DressUpItemLink(link);
	elseif ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			chat:Insert(link)
		else
			AltoholicFrame_SearchEditBox:SetText(GetItemInfo(link))
		end
	end
end


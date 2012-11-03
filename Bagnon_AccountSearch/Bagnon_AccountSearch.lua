Bagnon_AccountSearch = LibStub('AceAddon-3.0'):NewAddon('Bagnon_AccountSearch', 'AceEvent-3.0', 'AceConsole-3.0', 'AceTimer-3.0')
local AccountSearchFrame = CreateFrame('Frame', 'BagnonAccountSearchFrame', UIParent);
AccountSearchFrame:Hide()
Bagnon.AccountSearchFrame = AccountSearchFrame

BINDING_NAME_BAGNON_ACCSEARCH = "Account Search";

local MAX_GUILDBANK_SLOTS_PER_TAB =98
local MAX_BAG_SLOTS =80
local CONST_BAG_NR_GUILDBANK=1012
local CONST_BAG_NR_VAULT=1013
local MAX_VAULT_SLOTS=100
local currentRealm = GetRealmName() --what currentRealm we're on

local guildBankTimer

local OrigBST
local OrigBSFU
local OrigBFOH
local OrigBDS

function Bagnon_AccountSearch:OnInitialize()
	if (not AccountSearchFrameSaveGlobal) then
		AccountSearchFrameSaveGlobal = {}		
		AccountSearchFrameSaveGlobal.guilds = {};
	end	
	if (not AccountSearchFrameSave) then
		AccountSearchFrameSave = {}		
		AccountSearchFrameSave.attachPosition = 1;
	end
	--AccountSearchFrameSave.debugLvl = 5;
	if (Bagnon) and (Bagnon.SearchToggle) then
		OrigBST = Bagnon.SearchToggle.OnClick;
		AccountSearchFrame:Print("Onclick",1);
		Bagnon.SearchToggle.OnClick = function(...)
			if (IsAltKeyDown()) then				
				AccountSearchFrame:GuildBankToggle();				
			elseif (IsControlKeyDown()) then				
				AccountSearchFrame:AttachToggle();				
			elseif (IsShiftKeyDown() or AccountSearchFrameSave.simpleMode) then				
				AccountSearchFrame:AccountSearch_Toggle();				
			else
				return OrigBST(...);
			end
		end
	end
	if (Bagnon) and (Bagnon.SearchFrame) then
		OrigBSFU = Bagnon.SearchFrame.OnTextChanged;
		Bagnon.SearchFrame.OnTextChanged = function(...)
			local a,b,c,d,e,f,g = OrigBSFU(...);
			AccountSearchFrame:BagSearch_OnUpdate();
			return a,b,c,d,e,f,g;
		end
	end		
	
	if (Bagnon) and (Bagnon.Frame.OnHide) then
		OrigBFOH = Bagnon.Frame.OnHide;
		Bagnon.Frame.OnHide = function(...)
			local a,b,c,d,e,f,g = OrigBFOH(...);
			AccountSearchFrame:UpdateVisibility();
			return a,b,c,d,e,f,g;
		end
	end			
	
	if (Bagnon) and (Bagnon.SearchFrame.DisableSearch) then
		OrigBDS = Bagnon.SearchFrame.DisableSearch;
		Bagnon.SearchFrame.DisableSearch = function(...)
			local a,b,c,d,e,f,g = OrigBDS(...);
			AccountSearchFrame.visible = nil;
			AccountSearchFrame:Hide();
			return a,b,c,d,e,f,g;
		end
	end				
	
	Bagnon.AccountSearchFrame:New()
	AccountSearchFrame.items = nil;
	AccountSearchFrame.items = {};	
	AccountSearchFrame.minFrameSearchStringLength =2;
	
	if (not AccountSearchFrameSave.guildBankTabs) then		
		AccountSearchFrameSave.guildBankTabs = {};
	end	
	
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')	
	--self:RegisterEvent('GUILD_BANK_UPDATE_TABS')	
end

--returns the full item link only for items that have enchants/suffixes, otherwise returns the item's ID
local function ToShortLink(link)
	if link then
		local a,b,c,d,e,f,g,h = link:match('(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+)')
		if(b == '0' and b == c and c == d and d == e and e == f and f == g) then
			return a
		end
		return format('item:%s:%s:%s:%s:%s:%s:%s:%s', a, b, c, d, e, f, g, h)
	end
end

function AccountSearchFrame:GuildBankToggle()
	if (not AccountSearchFrameSave.guildBankSearchRestricted) then
		AccountSearchFrameSave.guildBankSearchRestricted = 1;		
		self:Print("Not Showing Restricted Items.",0)		
	else
		AccountSearchFrameSave.guildBankSearchRestricted = nil;		
		self:Print("Showing Restricted Items as well.",0)
	end
	AccountSearchFrame:UpdateVisibility();
	AccountSearchFrame:BagSearch_OnUpdate();
end

function AccountSearchFrame:AttachToggle()
	AccountSearchFrameSave.attachPosition = AccountSearchFrameSave.attachPosition +1;
	if (AccountSearchFrameSave.attachPosition > 4) then
		AccountSearchFrameSave.attachPosition = 1;
	end
	self:UpdateVisibility();
end

function AccountSearchFrame:AccountSearch_Toggle()
	if (self.visible) then
		self.visible = nil;
		self:Hide();
		if (not self.bagnonFrameLink) then
			self:GetBagnonVariableLinks();
		end
		if (self.bagnonFrameLink) then		
			self.bagnonFrameLink:DisableTextSearch()
		else
			self:Print("Bagnon frame link not found",1)
		end
	else
		self:UpdateVisibility()
		self:BagSearch_OnUpdate(); -- update the search results
		if (not self.bagnonFrameLink) then
			self:GetBagnonVariableLinks();
		end		
		if (self.bagnonFrameLink) then		
			self.bagnonFrameLink:EnableTextSearch();
		else
			self:Print("Bagnon frame link not found",1)			
		end
	end	
end

function AccountSearchFrame:BagSearch_OnUpdate()
	local search = Bagnon.Settings.textSearch;
	if (not search) or (string.len(search) == 0) then
		search = Bagnon.SearchFrame:GetText();		
	end
	if (search) and (string.len(search) > 0) then
		self:UpdateItems(search);
	end
end

function AccountSearchFrame:IsBankSlot(bag)
	if (bag == -1) or (bag >= 5) then
		return true;
	else
		return false;
	end
end

function AccountSearchFrame:SetFrameLayer(layer)
	local strata, topLevel = nil, false

	if layer == 'TOPLEVEL' then
		strata = 'HIGH'
		topLevel = true
	elseif layer == 'MEDIUMLOW' then
		strata = 'LOW'
		topLevel = true
	elseif layer == 'MEDIUMHIGH' then
		strata = 'MEDIUM'
		topLevel = true
	else
		strata = layer
		topLevel = false
	end
	self:SetFrameStrata(strata)
	self:SetToplevel(topLevel)
end

function AccountSearchFrame:GetBagnonVariableLinks()
	self.bagnonFrameLink = nil;
	self.bagnonFrameID = nil;
	if (Bagnon.FrameSettings.objects.inventory) and (Bagnon.FrameSettings.objects.inventory.shown > 0) then
		self.bagnonFrameLink = Bagnon.FrameSettings.objects.inventory;
		self.bagnonFrameID = BagnonFrameinventory;
		self:Print("Inv attach",1)
		self.attachTo = 1;		
	elseif (Bagnon.FrameSettings.objects.bank) and (Bagnon.FrameSettings.objects.bank.shown > 0) then
		self.bagnonFrameLink = Bagnon.FrameSettings.objects.bank;
		self.bagnonFrameID = BagnonFramebank;
		self.attachTo = 2;
		self:Print("Bank attach",1)
	end	
	self:SetParent(self.bagnonFrameID);
	if (not self.bagnonFrameLink) then
		self.attachTo = nil;
		return;
	end
	self.bagnonFrameDB = self.bagnonFrameLink.db.frameDB;
end

function AccountSearchFrame:UpdateVisibility()
	self:GetBagnonVariableLinks();
	
	self:Hide();
	if (not self.attachTo) then
		self.visible = nil;
		return;
	end
	-- now the frame can be shown
	self:ClearAllPoints();			
	self.visible = 1;
	
	if (AccountSearchFrameSave.attachPosition == 1) then
		self:SetPoint('TOPLEFT', self.bagnonFrameID , 'BOTTOMLEFT', 0, 0)	
	elseif (AccountSearchFrameSave.attachPosition == 2) then
		self:SetPoint('BOTTOMLEFT', self.bagnonFrameID , 'TOPLEFT', 0, 0)	
	elseif (AccountSearchFrameSave.attachPosition == 3) then
		self:SetPoint('TOPLEFT', self.bagnonFrameID , 'TOPRIGHT', 0, 0)	
	else		
		self:SetPoint('TOPRIGHT', self.bagnonFrameID , 'TOPLEFT', 0, 0)	
	end
	self:SetScale(self.bagnonFrameDB.scale);
	self:SetAlpha(self.bagnonFrameDB.opacity);
	self:SetBackdropColor(self.bagnonFrameDB.frameColor[1],self.bagnonFrameDB.frameColor[2],self.bagnonFrameDB.frameColor[3],self.bagnonFrameDB.frameColor[4])	
	self:SetFrameLayer(self.bagnonFrameDB.frameLayer);	
	
	--self:SetBackdropBorderColor(self.bagnonFrameDB.frameBorderColor[1],self.bagnonFrameDB.frameBorderColor[2],self.bagnonFrameDB.frameBorderColor[3],self.bagnonFrameDB.frameBorderColor[4]);
	if (not AccountSearchFrameSave.guildBankSearchRestricted) then
		self:SetBackdropBorderColor(0,1,0,1);
	else
		self:SetBackdropBorderColor(1,0,0,1);
	end
	

	self:Show();
end

function AccountSearchFrame:Resize()	
	local columns = self.bagnonFrameDB.itemFrameColumns;
	local spacing = self.bagnonFrameDB.itemFrameSpacing;
	local neededRows = math.ceil(self.shownSlots / columns);
	if (neededRows == 0) then
		neededRows = 1;
	end			
	local effItemSize = Bagnon.ItemFrame.ITEM_SIZE + spacing;
	local width = effItemSize * columns - spacing;
	local height = effItemSize * neededRows - spacing;
	self:SetWidth(width+14) -- to compensate for itemframe calc
	self:SetHeight(height+9)
end

function AccountSearchFrame:AddItemName(itemName,player,bag,cnt,restricted)	
	if (not self.shownItems[itemName]) then
		self.shownItems[itemName] = {};
		self.shownItems[itemName].count = 0;
		if (not self.shownItems[itemName].guilds) then
			self.shownItems[itemName].guilds = {};
		end
	end
	if (not cnt) then
		cnt =1;
	end
	local insString
	if (bag == CONST_BAG_NR_VAULT) then
		insString = player..":v";
		if (not self.shownItems[itemName].vault) then
			self.shownItems[itemName].vault = {};
		end
		self.shownItems[itemName].vault[player] = 1
	elseif (bag == CONST_BAG_NR_GUILDBANK) then
		-- player is guild name if bag number is a guild bank bag
		insString = player..":g";
		if (not self.shownItems[itemName].guilds[player]) then
			self.shownItems[itemName].guilds[player] = {};
			self.shownItems[itemName].guilds[player].count = 0;
			self.shownItems[itemName].guilds[player].resCount = 0;
		end		
		if (not restricted) then
			self.shownItems[itemName].guilds[player].count = self.shownItems[itemName].guilds[player].count + cnt;
		else
			self.shownItems[itemName].guilds[player].resCount = self.shownItems[itemName].guilds[player].resCount + cnt;
		end
	elseif (self:IsBankSlot(bag)) then
		insString = player..":b";
	else
		insString = player;
	end
	self.shownItems[itemName].count = self.shownItems[itemName].count + cnt;
	for i in pairs(self.shownItems[itemName]) do
		if (self.shownItems[itemName][i] == insString) then
			return;
		end
	end
	table.insert(self.shownItems[itemName],insString);
end

function AccountSearchFrame:UpdateItems(ss)	
	if (not self:IsShown()) or (not ss) then
		return nil;
	end
	if BrotherBags and (BrotherBags[currentRealm]) then		
		local slotNr = 1;		
		self.shownSlots = 0;
		if (string.len(ss) > self.minFrameSearchStringLength) then
			ss = string.lower(ss);			
			self.shownItems = nil;
			self.shownItems = {};
			for player in pairs(BrotherBags[currentRealm]) do
				AccountSearchFrame:Print("Searching Players "..player,1)
				for bag = BANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
					local bagLink = BrotherBags[currentRealm][player][bag];
					if (bagLink) then
						for slot = 1, MAX_BAG_SLOTS do	
							if (bagLink[slot]) then
								local link, count = strsplit(';', bagLink[slot])
								link = 'item:' .. link;
								local itemName, hyperLink, quality = GetItemInfo(link);
								local texture = GetItemIcon(link);																																
								if (hyperLink) and (itemName) and (texture) then									
									itemName = string.lower(itemName);
									quality = tonumber(quality);
									count = tonumber(count);									
									if (string.find(itemName,ss)) then									
										if (not self.shownItems[itemName]) then										
											self:AddItemName(itemName, player, bag,count,nil);
											local slot = self:CreateItemSlot(slotNr);
											slot.hasItem = hyperLink or nil
											slot.hyperLink = hyperLink;
											slot.nr = slotNr;
											slot.itemName = itemName;										
											SetItemButtonTexture(slot, texture);
											if (quality) and (quality > 1) then
												local r, g, b = GetItemQualityColor(quality)
												slot.border:SetVertexColor(r, g, b, 1)
												slot.border:Show()										
											end
											slot:Show();										
											self.shownSlots = slotNr;													
											slotNr = slotNr+1;										
										else
											self:AddItemName(itemName, player, bag,count,nil);
										end
									end
								end
							end
						end
					end
				end
				if(BrotherBags[currentRealm][player].vault) then
					AccountSearchFrame:Print("Player has vault items "..player,1)
					local vaultItems = BrotherBags[currentRealm][player].vault;
					for slot = 1, MAX_VAULT_SLOTS do	
						if (vaultItems[slot]) then								
							link = 'item:' .. vaultItems[slot];
							local itemName, hyperLink, quality = GetItemInfo(link);							
							local texture = GetItemIcon(link);							
							if (hyperLink) and (itemName) and (texture) then									
								itemName = string.lower(itemName);
								quality = tonumber(quality);
								if (string.find(itemName,ss)) then									
									if (not self.shownItems[itemName]) then										
										self:AddItemName(itemName, player, CONST_BAG_NR_VAULT,1,nil);
										local slot = self:CreateItemSlot(slotNr);
										slot.hasItem = hyperLink or nil
										slot.hyperLink = hyperLink;
										slot.nr = slotNr;
										slot.itemName = itemName;										
										SetItemButtonTexture(slot, texture);
										if (quality) and (quality > 1) then
											local r, g, b = GetItemQualityColor(quality)
											slot.border:SetVertexColor(r, g, b, 1)
											slot.border:Show()										
										end
										slot:Show();										
										self.shownSlots = slotNr;													
										slotNr = slotNr+1;										
									else
										self:AddItemName(itemName, player, CONST_BAG_NR_VAULT,1,nil);
									end
								end
							end
						end
					end
				end
			end			
			local myGuild = GetGuildInfo("player");
			local player = UnitName("player");
			local pRealm = GetRealmName();
			local pFaction = UnitFactionGroup("player");						
			if (myGuild) and (pRealm) and (pFaction)  then
				for guild in pairs(AccountSearchFrameSaveGlobal.guilds) do					
					if (AccountSearchFrameSaveGlobal.guilds[guild].realm) then
						local searchGuild = nil;
						if (AccountSearchFrameSaveGlobal.guilds[guild].realm == pRealm) then
							if (myGuild == guild) then
								searchGuild = 1;
							elseif (not AccountSearchFrameSave.gBankGuild) then
								if (not AccountSearchFrameSave.gBankFaction) then
									searchGuild = 1;
								elseif (AccountSearchFrameSaveGlobal.guilds[guild].faction == pFaction) then
									searchGuild = 1;
								end
							end
						end		
						if (searchGuild) then
							AccountSearchFrame:Print("Searching Guild bank "..guild.." - "..player,1)								
							if (AccountSearchFrameSaveGlobal.guilds[guild]) and (AccountSearchFrameSaveGlobal.guilds[guild].guildTabs) then
								for tab = 1, AccountSearchFrameSaveGlobal.guilds[guild].guildTabs do
									if (not AccountSearchFrameSave.guildBankTabs[tab]) then
										AccountSearchFrameSave.guildBankTabs[tab] = 0;
									end
									if (not AccountSearchFrameSave.guildBankSearchRestricted) or (AccountSearchFrameSave.guildBankTabs[tab] > 0 ) then
										local restricted = nil;
										if (AccountSearchFrameSave.guildBankTabs[tab] == 0) then
											restricted = 1;
										end						
										AccountSearchFrame:Print("Searching Guild bank "..guild.." - "..player.." - "..tab,1)
										if (AccountSearchFrameSaveGlobal.guilds[guild][tab]) then
											for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
												local itemInfo = AccountSearchFrameSaveGlobal.guilds[guild][tab][slot];								
												if itemInfo then
													local link, count = strsplit(',', itemInfo)								
													if link then
														local texture = GetItemIcon(link);
														local hyperLink, quality = select(2, GetItemInfo(link))
														--local texture, count, locked, quality, readable, lootable, hyperLink = Bagnon.ItemSlotInfo:GetItemInfo(player,bag,slot)
														if (hyperLink) and (texture) then
															itemName = GetItemInfo(hyperLink);								
															itemName = string.lower(itemName);
															if (not count) then count=1 end
															if (itemName) and (string.find(itemName,ss)) then																			
																if (not self.shownItems[itemName]) then										
																	self:AddItemName(itemName, guild, CONST_BAG_NR_GUILDBANK ,count,restricted);
																	local slot = self:CreateItemSlot(slotNr);
																	slot.hasItem = hyperLink or nil												
																	slot.hyperLink = hyperLink;
																	slot.nr = slotNr;
																	slot.itemName = itemName;										
																	SetItemButtonTexture(slot, texture);
																	if (quality) and (quality > 1) then
																		local r, g, b = GetItemQualityColor(quality)
																		slot.border:SetVertexColor(r, g, b, 1)
																		slot.border:Show()										
																	end
																	slot:Show();										
																	self.shownSlots = slotNr;													
																	slotNr = slotNr+1;										
																else
																	self:AddItemName(itemName, guild, CONST_BAG_NR_GUILDBANK ,count,restricted);
																end
															end
														end					
													end
												end
											end
										end
									end
								end				
							end			
						end
					end
				end
			end
		end		
		while (self.items[slotNr]) do			
			self.items[slotNr]:Hide();
			self.items[slotNr].hasItem = nil;
			self.items[slotNr].hyperLink = nil;
			self.items[slotNr].border:Hide()										
			slotNr = slotNr +1;			
			--if (Bagnon.SavedSettings.db.showEmptyItemSlotTexture == true) then
		--		SetItemButtonTexture(self.items[slotNr], [[Interface\PaperDoll\UI-Backpack-EmptySlot]]);
			--else
				--SetItemButtonTexture(self.items[slotNr], nil);
			--end
		end
	end
	-- set the count values now
	slotNr = 1;
	while (self.items[slotNr]) do			
		if (self.items[slotNr].itemName) and (self.shownItems[self.items[slotNr].itemName]) then
			if (self.shownItems[self.items[slotNr].itemName].count > 9999) then
				SetItemButtonCount(self.items[slotNr], 9999);
			else			
				SetItemButtonCount(self.items[slotNr], self.shownItems[self.items[slotNr].itemName].count);
			end
		end
		slotNr = slotNr +1;			
	end	
	self:Resize();
end	

function AccountSearchFrame:New()
	self:Hide();
	self:ClearAllPoints();
	self:SetClampedToScreen(true)
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)	

	self:SetBackdrop{
	  bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	  edgeSize = 16,
	  tile = true, tileSize = 16,
	  insets = {left = 4, right = 4, top = 4, bottom = 4}
	}
	self:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', -10, -10)
	return self
end

local function GetColor(class)
	if class then
		local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
		local color = colors[class]
		return color.r , color.g , color.b;		
	else
		return 0,1,0.5;
	end
end

local function Slot_OnEnter(self)	
	if (AccountSearchFrame.items[self.nr]) and (AccountSearchFrame.items[self.nr].hyperLink) then
		if AccountSearchFrame.items[self.nr]:GetRight() >= (GetScreenWidth() / 2) then
			GameTooltip:SetOwner(AccountSearchFrame.items[self.nr], 'ANCHOR_LEFT')
		else
			GameTooltip:SetOwner(AccountSearchFrame.items[self.nr], 'ANCHOR_RIGHT')
		end	
		GameTooltip:SetHyperlink(AccountSearchFrame.items[self.nr].hyperLink)		
		if (AccountSearchFrame.shownItems[self.itemName].vault) then
			for player in pairs(AccountSearchFrame.shownItems[self.itemName].vault) do		
				local r,g,b = GetColor(BrotherBags[currentRealm][player].class);
				GameTooltip:AddDoubleLine(player,"(Vault: 1)",r,g,b,1,0,1);				
			end
		end
		for guild in pairs(AccountSearchFrame.shownItems[self.itemName].guilds) do							
			local gCount = AccountSearchFrame.shownItems[self.itemName].guilds[guild].count;		
			if (gCount > 0) then
				AccountSearchFrame:Print("Items in guild bank : "..gCount,2);			
				GameTooltip:AddDoubleLine(guild,"(Avail: "..gCount..")",0,1,0,0,1,0);
			end		
			local gCountR = AccountSearchFrame.shownItems[self.itemName].guilds[guild].resCount;		
			if (gCountR > 0) then
				AccountSearchFrame:Print("Items in guild bank : "..gCountR,2);			
				GameTooltip:AddDoubleLine(guild,"(Unavail: "..gCountR..")",1,0,0,1,0,0);
			end	
		end
		GameTooltip:Show()
		CursorUpdate(self)	
	end
end

local function Slot_OnLeave(self)
	GameTooltip:Hide()
end

local function Slot_OnClick(self)
	if (AccountSearchFrame.lastItemClicked ~= self.nr) then
		AccountSearchFrame.clickNr = 1;
	end
	AccountSearchFrame.lastItemClicked = self.nr;
	local ss
	if (AccountSearchFrame.shownItems[self.itemName]) then
		if (AccountSearchFrame.shownItems[self.itemName][AccountSearchFrame.clickNr]) then			
		elseif (AccountSearchFrame.clickNr > 1) then
			AccountSearchFrame.clickNr = 1;			
		else
			return;
		end
		ss = AccountSearchFrame.shownItems[self.itemName][AccountSearchFrame.clickNr];		
		local pos = string.find(ss,":v") -- is in Vault
		if (pos) then -- is in guild bank
			local playerName = string.sub(ss,1,pos-1);
			AccountSearchFrame:Print(playerName.. " - Vault",0);
		else
			pos = string.find(ss,":g");
			if (pos) then -- is in guild bank
				local guildName = string.sub(ss,1,pos-1);			
				if (AccountSearchFrame.shownItems[self.itemName].guilds[guildName]) then
					AccountSearchFrame:Print(guildName.. " - "..AccountSearchFrame.shownItems[self.itemName].guilds[guildName].count,3);
					--[[
					if (AccountSearchFrame.shownItems[self.itemName].guilds[guildName].count > 0) then
						guildName = guildName.." - "..AccountSearchFrame.shownItems[self.itemName].guilds[guildName].count.." (avail)";
					end
					if (AccountSearchFrame.shownItems[self.itemName].guilds[guildName].resCount > 0) then
						guildName = guildName.." - "..AccountSearchFrame.shownItems[self.itemName].guilds[guildName].resCount.." (unavail)";
					end	
]]--					
					AccountSearchFrame:Print("In Guild Bank : - "..guildName,0);
				end
			else
				pos = string.find(ss,":b");
				if (pos) then -- is in bank bags
					if (not Bagnon.FrameSettings.objects.bank) or (Bagnon.FrameSettings.objects.bank.shown == 0) then
						Bagnon:ToggleFrame('bank');
					end
					local charName = string.sub(ss,1,pos-1);
					Bagnon.FrameSettings.objects.bank:SetPlayerFilter(charName);
				else
					Bagnon.FrameSettings.objects.inventory:SetPlayerFilter(ss);
				end
			end
		end
		--local clickString = AccountSearchFrame.shownItems[self.itemName][AccountSearchFrame.clickNr]
	end
	AccountSearchFrame.clickNr = AccountSearchFrame.clickNr+1;
end

function AccountSearchFrame:CreateItemSlot(slotNr,hyperLink,itemName,texture,quality)

	if (not slotNr) or (not self:IsShown()) then
		return nil;
	end
	if self.items[slotNr] then
		return self.items[slotNr];
	end
	local item = CreateFrame('Button', 'BagnonACCSItemSlot' .. slotNr, BagnonAccountSearchFrame, 'ContainerFrameItemButtonTemplate')
	item:Hide()

	--add a quality border texture
	item.questBorder = _G[item:GetName() .. 'IconQuestTexture']
	
	local border = item:CreateTexture(nil, 'OVERLAY')
	border:SetWidth(67)
	border:SetHeight(67)
	border:SetPoint('CENTER', item)
	border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
	border:SetBlendMode('ADD')
	border:Hide()
	item.border = border
	

	--get rid of any registered frame events, and use my own
	item:SetScript('OnEvent', nil)
	item:SetScript('OnEnter', Slot_OnEnter)
	item:SetScript('OnLeave', Slot_OnLeave)
	item:SetScript('OnShow', nil)
	item:SetScript('OnHide', nil)
	item:SetScript('PostClick', nil)
	item:SetScript('OnClick', Slot_OnClick)
	item:SetScript('OnDragStart', nil)	
	item:SetScript('OnDragStop', nil)	
	item:SetScript('OnReceiveDrag', nil)	
	item:SetScript('OnMouseDown', nil)	
	item:SetScript('OnMouseUp', nil)	
	item.UpdateTooltip = nil
	
	--item:SetScale(1);
	--item:SetAlpha(0.5);
	
	local columns = self.bagnonFrameDB.itemFrameColumns;
	local spacing = self.bagnonFrameDB.itemFrameSpacing;
	local effItemSize = Bagnon.ItemFrame.ITEM_SIZE + spacing;
	local row = (slotNr-1) % columns;
	local col = math.ceil(slotNr / columns) -1;
	item:ClearAllPoints()
	item:SetPoint('TOPLEFT', BagnonAccountSearchFrame, 'TOPLEFT', 8+ effItemSize * row, -5 - effItemSize * col)
		
--[[	item.hasItem = hyperLink or nil
	item.hyperLink = hyperLink;
	item.nr = slotNr;
	item.itemName = itemName;										
	SetItemButtonTexture(item, texture);
	if (quality) and (quality > 1) then
		local r, g, b = GetItemQualityColor(quality)
		item.border:SetVertexColor(r, g, b, 1)
		item.border:Show()										
	end
	item:Show();	]]--
	
	self.items[slotNr] = item;
	self.items[slotNr].slot = 0;

	return item
end

function AccountSearchFrame:ShowSearch()
	if (not Bagnon.FrameSettings.objects.inventory) or (Bagnon.FrameSettings.objects.inventory.shown == 0) then
		if (not Bagnon.FrameSettings.objects.bank) or (Bagnon.FrameSettings.objects.bank.shown == 0) then
			Bagnon:ToggleFrame('inventory');
		end
	end
	if (not self.bagnonFrameLink) then
		self:GetBagnonVariableLinks();
	end	
	if (self.bagnonFrameLink) then
		self:UpdateVisibility();	
		self.bagnonFrameLink:EnableTextSearch();	
	end
end

function AccountSearchFrame:Print(msg, dLvl)
	if (not AccountSearchFrameSave.debugLvl) then
		AccountSearchFrameSave.debugLvl = 0;
	end		
	if (dLvl == 0) and (AccountSearchFrameSave.debugLvl >= 0) then
		DEFAULT_CHAT_FRAME:AddMessage("Bagnon ACS : "..msg); 		
	elseif (dLvl <= AccountSearchFrameSave.debugLvl) then
		DEFAULT_CHAT_FRAME:AddMessage("Bagnon ACS (debug) : "..msg); 		
	end
end

SLASH_BAGNONACCOUNTSEARCH1, SLASH_BAGNONACCOUNTSEARCH2 = '/bas', '/bacc'; 
function SlashCmdList.BAGNONACCOUNTSEARCH(msg, editbox) -- 4.
	if (msg == "help") then
	   AccountSearchFrame:Print("Shift+Click the Bagnon Search Button to start Account wide search",0);
	   AccountSearchFrame:Print("CTRL+Click the Bagnon Search Button to change the position of the Account-Search-Frame",0);
	   AccountSearchFrame:Print("Alt+Click the Bagnon Search Button to change wether to search non accessible Guild Bank tabs",0);
	   AccountSearchFrame:Print("Green Border = Only Accesible Tabs / Red Border = All Tabs even if there is no access",0);
	   AccountSearchFrame:Print("",0);
	   AccountSearchFrame:Print("Command line options :",0);
	   AccountSearchFrame:Print("simple - if on you don't need to shift click the button to search account wide",0);	   
	   AccountSearchFrame:Print("guild  - change setting of searching all guild banks or only your own",0);	   
	   AccountSearchFrame:Print("faction - if searching all guilds, chose if both factions or only yours",0);	   
	elseif (msg == "debug") then
		if (not AccountSearchFrameSave.debugLvl) then
			AccountSearchFrameSave.debugLvl = 0;
		end		
		if (AccountSearchFrameSave.debugLvl == 5) then
			AccountSearchFrameSave.debugLvl = 0;
		else
			AccountSearchFrameSave.debugLvl = 5;
		end
		AccountSearchFrame:Print("Debug Lvl set to "..AccountSearchFrameSave.debugLvl,0)		
	elseif (msg == "simple") then
		if (not AccountSearchFrameSave.simpleMode) then
			AccountSearchFrameSave.simpleMode = 1;
			AccountSearchFrame:Print("Simple Mode On",0)				
		else
			AccountSearchFrameSave.simpleMode = nil;
			AccountSearchFrame:Print("Simple Mode Off",0)				
		end		
	elseif (msg == "faction") then
		if (not AccountSearchFrameSave.gBankFaction) then
			AccountSearchFrameSave.gBankFaction = 1;
			AccountSearchFrame:Print("Guild Bank must be from same faction.",0)				
		else
			AccountSearchFrameSave.gBankFaction = nil;
			AccountSearchFrame:Print("Guild Banks from both factions will be searched.",0)				
		end		
	elseif (msg == "guild") then
		if (not AccountSearchFrameSave.gBankGuild) then
			AccountSearchFrameSave.gBankGuild = 1;
			AccountSearchFrame:Print("Only your guilds Guild Bank will be searched.",0)				
		else
			AccountSearchFrameSave.gBankGuild = nil;
			AccountSearchFrame:Print("Other Guild banks than those of your guild may be searched.",0)				
			if (not AccountSearchFrameSave.gBankFaction) then				
				AccountSearchFrame:Print("Guild Banks from both factions will be searched.",0)				
			else
				AccountSearchFrame:Print("Guild Bank must be from same faction.",0)								
			end					
		end				
	else
		AccountSearchFrame:ShowSearch();
	end	
end

function Bagnon_AccountSearch:guildBankTabHasItems(tab)
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local texture = GetGuildBankItemInfo(tab,slot)
		if texture then
			return 1;
		end
	end
	return nil;
end


function Bagnon_AccountSearch:GUILDBANKFRAME_OPENED()
	self.lastGuildTab = GetCurrentGuildBankTab();
	if (not guildBankTimer) then
		guildBankTimer = self:ScheduleRepeatingTimer("GuildBankUpdate", 1);
	end
	
	local myGuild = GetGuildInfo("player");
	if (not AccountSearchFrameSaveGlobal.guilds[myGuild]) then
		AccountSearchFrameSaveGlobal.guilds[myGuild] = {};
	end
	local tabCount = GetNumGuildBankTabs();
	AccountSearchFrameSaveGlobal.guilds[myGuild].guildTabs = tabCount;
	AccountSearchFrameSaveGlobal.guilds[myGuild].realm = GetRealmName();
	AccountSearchFrameSaveGlobal.guilds[myGuild].faction = UnitFactionGroup("player");
	AccountSearchFrame:Print("Guild Bank Opened "..tabCount,1);
	for tab = 1, tabCount do		
		local numWithdrawals = 0;
		if (self:guildBankTabHasItems(tab)) or (tab == GetCurrentGuildBankTab()) then
			if (not AccountSearchFrameSaveGlobal.guilds[myGuild][tab]) then
				AccountSearchFrameSaveGlobal.guilds[myGuild][tab] = {};
			end			
			name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tab)
			if (isViewable) then
				AccountSearchFrame:Print("Guild Bank Opened "..tab.." - "..numWithdrawals,2);
				for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
					local texture, count, locked = GetGuildBankItemInfo(tab,slot)
					local item = GetGuildBankItemLink(tab, slot)						
					if texture then
						AccountSearchFrame:Print("Item "..tab.."-"..slot.." - "..count,5);
						local link = ToShortLink(item);
						count = count > 1 and count or nil
						if(link and count) then
							AccountSearchFrameSaveGlobal.guilds[myGuild][tab][slot] = format('%s,%d', link, count)
						else
							AccountSearchFrameSaveGlobal.guilds[myGuild][tab][slot] = link
						end
					else
						AccountSearchFrameSaveGlobal.guilds[myGuild][tab][slot] = nil
					end						
				end			
			else
				AccountSearchFrame:Print("Guild Bank Opened "..tab.." - No Access",2);
			end
			AccountSearchFrameSave.guildBankTabs[tab] = numWithdrawals;
		end
		if (IsGuildLeader(UnitName("player"))) then
		   numWithdrawals = 1000;
		   AccountSearchFrame:Print("Guild Leader",2);
		end		
	end	
end

function Bagnon_AccountSearch:GuildBankUpdate()
	AccountSearchFrame:Print("Guild Bank Tab Check",1);
	presentTab = GetCurrentGuildBankTab();
	if (not (presentTab == self.lastGuildTab)) then
		Bagnon_AccountSearch:GUILDBANKFRAME_OPENED();
	end
	self.lastGuildTab = presentTab;	
end


function Bagnon_AccountSearch:GUILDBANKFRAME_CLOSED()
	AccountSearchFrame:Print("Guild Bank Closed",1);
	self:CancelTimer(guildBankTimer);
	guildBankTimer = nil;
end

--DEFAULT_CHAT_FRAME:AddMessage(ss); 		
--[[
Copyright 2008-2012 João Cardoso
Scrap is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Scrap.

Scrap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Scrap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Scrap. If not, see <http://www.gnu.org/licenses/>.
--]]


local MONEY_TYPES = {'Gold', 'Silver', 'Copper'}
local HasPawn = IsAddOnLoaded('Pawn_Scrap')
local Background, Icon, Border
local L = Scrap_Locals


--[[ Startup ]]--

function Scrap:StartupMerchant()
	-- Regions --
	Background = self:CreateTexture(nil, 'BORDER')
	Background:SetHeight(27) Background:SetWidth(27)
	Background:SetPoint('CENTER', -0.5, -1.2)
	Background:SetTexture(0, 0, 0)
	
	Icon = self:CreateTexture(self:GetName()..'Icon')
	Icon:SetTexture('Interface\\Addons\\Scrap\\Art\\Enabled Box')
	Icon:SetHeight(33) Icon:SetWidth(33)
	Icon:SetPoint('CENTER')
	
	Border = self:CreateTexture(self:GetName() .. 'Border', 'OVERLAY')
	Border:SetTexture('Interface\\Addons\\Scrap\\Art\\Merchant Border')
	Border:SetHeight(35.9) Border:SetWidth(35.9)
	Border:SetPoint('CENTER')
	
	-- Appearance --
	self:SetHighlightTexture('Interface/Buttons/ButtonHilight-Square', 'ADD')
	self:SetPushedTexture('Interface/Buttons/UI-Quickslot-Depress')
	self:SetSize(37, 37)
	
	-- Scripts --
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:SetScript('OnReceiveDrag', function() self:OnReceiveDrag() end)
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	self:SetScript('OnClick', self.OnClick)
	
	-- Misc --
	self:RegisterEvent('MERCHANT_CLOSED')
	self:UpdateButtonPosition()
	self.StartupMerchant = nil

	-- Hooks --
	hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
		self:UpdateButtonPosition()
	end)
	
	hooksecurefunc(Scrap, 'ToggleJunk', function()
   		self:UpdateButtonState()
  	end)

	hooksecurefunc('UseContainerItem', function(...)
		self:OnItemSold(...)
	end)
	
	local buyBack = BuybackItem
	BuybackItem = function(...)
		self:OnItemRefund(...)
		return buyBack(...)
	end
	
	-- Visualizer Tab
	if select(5, GetAddOnInfo('Scrap_Visualizer')) then
		local tab = TabAppender_New(MerchantFrame)
		tab:SetText('Scrap')
		tab.OnClick = function()
			MerchantFrame_UpdateBuybackInfo()
		
			if LoadAddOn('Scrap_Visualizer') then
				ScrapVisualizer:Show()
			end
		end
		
		self.tab = tab
	end
end


--[[ Events ]]--

function Scrap:MERCHANT_SHOW()
	if Scrap_AutoSell then
		if MerchantFrame:IsShown() then
			self:SellJunk()
			self:SetScript('OnUpdate', nil)
		else
			self:SetScript('OnUpdate', self.MERCHANT_SHOW) -- Keep trying
		end
	else
		self:UpdateButtonState()
	end
	
	if not Scrap_Tut or Scrap_Tut < 5 then
		if LoadAddOn('Scrap_Options') then
			self:BlastTutorials()
		end
	end
	
	self:RegisterEvent('BAG_UPDATE')
end

function Scrap:MERCHANT_CLOSED()
	self:UnregisterEvent('BAG_UPDATE')
	self:SetScript('OnUpdate', nil)
end

function Scrap:BAG_UPDATE()
	self:UpdateButtonState()
end


--[[ Tooltip ]]--

function Scrap:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	self:OnTooltipShow()
	GameTooltip:Show()
end

function Scrap:OnTooltipShow(title)
	local infoType, itemID = GetCursorInfo()
	if infoType == 'item' then
		if not self:HasPrice(itemID) then
			GameTooltip:SetText(L.NoValue, 1, .1, .1)
		elseif self:IsJunk(itemID) then
			GameTooltip:SetText(L.Remove, 1, 1, 1)
		else
			GameTooltip:SetText(L.Add, 1, 1, 1)
		end
	else
		local value = self:GetJunkValue()
		local counters = {}
		
		if value > 0 then
			GameTooltip:SetText(title or L.SellJunk)
			
			for _,_, id in self:IterateJunk() do
				local quality = select(3, GetItemInfo(id))
				counters[quality] = (counters[quality] or 0) + 1
			end
	
			for qual, count in pairs(counters) do
				local r,g,b = GetItemQualityColor(qual)
				GameTooltip:AddDoubleLine(_G['ITEM_QUALITY' .. qual .. '_DESC'], count, r,g,b, r,g,b) 
			end
			
			SetTooltipMoney(GameTooltip, value)
		end
	end
end

function Scrap:OnLeave()
	GameTooltip:Hide()
end


--[[ Interaction ]]--

function Scrap:OnClick(button, ...)
	if button == 'LeftButton' then
		if not self:ToggleCursorJunk() then
			self:SellJunk()
		end
	elseif button == 'RightButton' then
		if LoadAddOn('Scrap_Options') then
			ScrapDropdown:Toggle(...)
		end
	end
	self:GetScript('OnLeave')()
end

function Scrap:OnReceiveDrag()
	self:ToggleCursorJunk()
end


--[[ Button ]]--

function Scrap:UpdateButtonState()
	local disabled = self:GetJunkValue() == 0
	Border:SetDesaturated(disabled)
	Icon:SetDesaturated(disabled)
end

function Scrap:UpdateButtonPosition()
	if CanMerchantRepair() then
		local off, scale
		if CanGuildBankRepair() then
			off, scale = -3.5, 0.9
			MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, 'BOTTOMLEFT', 120, 35)
		else
			off, scale = -1.5, 1
		end
		
		self:SetPoint('RIGHT', MerchantRepairItemButton, 'LEFT', off, 0)
		self:SetScale(scale)
	else
		self:SetPoint('RIGHT', MerchantBuyBackItem, 'LEFT', -17, 0.5)
		self:SetScale(1.1)
	end
end


--[[ Junk ]]--

function Scrap:SellJunk ()
	self.selling = true
	
	local value = self:GetJunkValue()
	local count = 0

	for bag, slot, id in self:IterateJunk() do
		if Scrap_Safe and count == 12 then
			break
		end
		
		local value = select(11, GetItemInfo(id))
		if value > 0 then
			UseContainerItem(bag, slot)
			count = count + 1
		end	
	end
	
	value = value - self:GetJunkValue()
	if value > 0 then
		self:Print(L.SoldJunk, GetCoinTextureString(value), 'MONEY')
	end
	
	self:UpdateButtonState()
	self.selling = nil
end

function Scrap:ToggleCursorJunk ()
	local type, id = GetCursorInfo()
	
	if type == 'item' then
		GameTooltip:Hide()
		ClearCursor()
	
		self:ToggleJunk(id)
		return true
	end
end

function Scrap:GetJunkValue ()
	local value = 0
	
	for bag, slot, id in self:IterateJunk() do
		local stack, locked = select(2, GetContainerItemInfo(bag, slot))
		local itemValue = select(11, GetItemInfo(id))
    	
		if not locked and itemValue then
			value = value + itemValue * stack
		end
	end
	
	return value
end


--[[ AI ]]--

function Scrap:OnItemSold (...)
	if Scrap_Learn and self:IsVisible() and not self.selling then
		local id = GetContainerItemID(...)
		if not id or Scrap_Junk[id] ~= nil or Scrap_AI[id] or self:CheckFilters(id, ...) then
			return
		end
			
		local stack = select(2, GetContainerItemInfo(...))
		if GetItemCount(id, true) == stack then
			local link = GetContainerItemLink(...)
			local maxStack = select(8, GetItemInfo(id))
			local stack = self:GetBuypackStack(link) + stack
			
			local old = Scrap_AI[id] or 0
			local new = old + stack / maxStack
				
			if old < 2 and new >= 2 then
				self:Print(L.Added, link, 'LOOT')
			end
			
			Scrap_AI[id] = new
		end
	end
end

function Scrap:OnItemRefund (index)
	if Scrap_Learn then
		local link = GetBuybackItemLink(index)
		local id = self:GetID(link)
		local old = Scrap_AI[id]
		
		if old then
			local maxStack = select(8, GetItemInfo(id))
			local stack = self:GetBuypackStack(link)
			
			local new = old - stack / maxStack
			if old >= 2 and new < 2 then
				self:Print(L.Removed, link, 'LOOT')
			end
			
			if new <= 0 then
				Scrap_AI[id] = nil
			else
				Scrap_AI[id] = new
			end
		end
	end
end

function Scrap:GetBuypackStack (link)
	local stack = 0
	for i = 1, GetNumBuybackItems() do
		if GetBuybackItemLink(i) == link then
			stack = stack + select(4, GetBuybackItemInfo(i))
		end
	end
	return stack
end

MerchantRepairText:SetAlpha(0)
Scrap:StartupMerchant()
SatchelQueue = LibStub("AceAddon-3.0"):NewAddon("SatchelQueue", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local SatchelQueue = SatchelQueue

local BUTTON_TEXT = "Satchel"
local BUTTON_QUEUED = "Cancel"

local timer = nil

local sound_all = nil
local sound_bg = nil

local should_auto_loot = false

function SatchelQueue:OnInitialize()
    local defaults = {
        global = {
            icon = true,
            tooltip = false,
            requeue = false,
            prevent_auto_loot = true,
            fake_auto_loot = false,
            prioritise = false,
            exclusive = false,
            flash_enable = false,
            sound_enable = true,
            sound_force = false,
            sound_file = "Sound/Spells/Clearcasting_Impact_Chest.wav",
            
            saved_uids = {},
            items = {},
            count = 0,
            coin_min = -1,
            coin_max = -1,
            coin_total = 0
        }
    }
    self.db = LibStub("AceDB-3.0"):New("SatchelQueueDB", defaults, true)
    
    local option_table = {
        type = "group",
        set = function(info, val) self.db.global[info[#info]] = val end,
        get = function(info) return self.db.global[info[#info]] end,
        args = {
            header_queueing = {
                order = 0,
                type = "header",
                name = "Queueing"
            },
            prioritise = {
                order = 1,
                type = "toggle",
                width = "double",
                name = "Prioritise newer dungeons"
            },
            exclusive = {
                order = 2,
                type = "toggle",
                name = "Exclusively",
                desc = "Oueue exclusively for the newer dungeons when prioritised",
                disabled = function(info) return not self.db.global.prioritise end
            },
            requeue = {
                order = 3,
                type = "toggle",
                width = "full",
                name = "Requeue after leaving"
            },
            icon = {
                order = 4,
                type = "toggle",
                width = "full",
                name = "Enable LFG minimap icon while waiting"
            },
            header_satchel = {
                order = 5,
                type = "header",
                name = "Satchels"
            },
            prevent_auto_loot = {
                order = 6,
                type = "toggle",
                width = "double",
                name = "Prevent auto loot"
            },
            fake_auto_loot = {
                order = 7,
                type = "toggle",
                name = "Only protect BoP items",
                desc = "Non-BoP items will still be looted",
                disabled = function(info) return not self.db.global.prevent_auto_loot end
            },
            tooltip = {
                order = 8,
                type = "toggle",
                width = "double",
                name = "Enable contents in tooltip"
            },
            header_notification = {
                order = 9,
                type = "header",
                name = "Notification"
            },
            flash_enable = {
                order = 10,
                type = "toggle",
                width = "full",
                name = "Enable Screen Flash"
            },
            sound_enable = {
                order = 11,
                type = "toggle",
                width = "double",
                name = "Enable Sound"
            },
            sound_force = {
                order = 12,
                type = "toggle",
                name = "Force unmute for alert",
                disabled = function(info) return not self.db.global.sound_enable end
            },
            sound_file = {
                order = 13,
                type = "input",
                width = "full",
                name = "Sound File",
                disabled = function(info) return not self.db.global.sound_enable end
            }
        }
    }
    local stats_table = {
        type = "group",
        args = {
            text = {
                type = "input",
                name = "Statistics",
                width = "full",
                multiline = 24,
                get = function(info)
                    local s = "total satchels: " .. self.db.global.count .. "\n"
                    if self.db.global.coin_min > 0 then
                        s = s .. "\ntotal gold: " .. GetMoneyString(self.db.global.coin_total)
                        s = s .. "\nmin: " .. GetMoneyString(self.db.global.coin_min)
                        s = s .. "\nmax: " .. GetMoneyString(self.db.global.coin_max)
                        s = s .. "\navg: " .. GetMoneyString(self.db.global.coin_total / self.db.global.count) .. "\n"
                    end
                    s = s .. "\nitems:"
                    local items = {}
                    for k, v in pairs(self.db.global.items) do
                        table.insert(items, { id = k, count = v })
                    end
                    table.sort(items, function(a, b) return a.count > b.count end)
                    for i = 1, #items do
                        s = s .. "\n" .. (GetItemInfo(items[i].id) or "<item not cached>")  .. ": " .. items[i].count
                    end
                    return s
                end,
                set = nil
            },
            reset = {
                type = "execute",
                name = "reload",
                width = "full",
                func = function(info)
                    LibStub("AceConfigRegistry-3.0"):NotifyChange("Statistics")
                end
            }
        }
    }
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SatchelQueue", option_table)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Statistics", stats_table)
    local option_frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SatchelQueue", "SatchelQueue")
    local stats_frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Statistics", "Stats", "SatchelQueue")
    self:RegisterChatCommand("satchel", function(...) InterfaceOptionsFrame_OpenToCategory(option_frame) end)
    self:RegisterChatCommand("satchelstats", function(...) InterfaceOptionsFrame_OpenToCategory(stats_frame) end)
end

local function SatchelID(link)
	if not link then
		return nil
	end
    return select(3, string.find(link, "|Hitem:69903:0:0:0:0:0:0:(%d+):")) or select(3, string.find(link, "|Hitem:90818:0:0:0:0:0:0:(%d+):")) or nil
end

local function Satchel_OnLeave(self, motion)
    SatchelQueue:Unhook(self, "OnLeave")
    SatchelQueue:Unhook(self, "PreClick")
    SatchelQueue:Unhook(self, "PostClick")
end

local toggle_loot, default_loot = nil, nil
local function Satchel_PreClick(self, button)
    if button == "RightButton" and GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        should_auto_loot = true
        toggle_loot, default_loot = true, GetCVarBool("autoLootDefault")
        SetCVar("autoLootDefault", default_loot and 0 or 1)
    end
end

local function Satchel_PostClick(self, button)
    if toggle_loot then
        toggle_loot = false
        SetCVar("autoLootDefault", default_loot)
    end
end

local function Satchel_OnEnter(self, motion)
    if SatchelQueue.db.global.prevent_auto_loot and not SatchelQueue:IsHooked(self, "OnLeave") and SatchelID(GetContainerItemLink(self:GetParent():GetID(), self:GetID())) then
        SatchelQueue:HookScript(self, "OnLeave", Satchel_OnLeave)
        SatchelQueue:HookScript(self, "PreClick", Satchel_PreClick)
        SatchelQueue:HookScript(self, "PostClick", Satchel_PostClick)
    end
end

local function Satchel_TooltipText(self)
    local _, link = self:GetItem()
    local id = link and SatchelID(link) or nil
    if id and SatchelQueue.db.global.tooltip then
        if type(SatchelQueue.db.global.saved_uids[id]) == "table" then
            self:AddLine(" ")
            for slot = 1, #SatchelQueue.db.global.saved_uids[id] do
                local content = SatchelQueue.db.global.saved_uids[id][slot]
                if content < 0 then
                    self:AddLine("|cffffffff" .. GetCoinTextureString(-content) .. "|r")
                else
                    local name, _, quality = GetItemInfo(content)
                    if name then
                        local r, g, b = GetItemQualityColor(quality)
                        self:AddLine(name, r, g, b)
                    end
                end
            end
        end
    end
end

function SatchelQueue:OnEnable()
    self:Hook("ContainerFrameItemButton_OnEnter", Satchel_OnEnter, true)
    self:HookScript(GameTooltip, "OnTooltipSetItem", Satchel_TooltipText)
    self:SecureHook("QueueStatusFrame_Update", "UpdateStatus")
    self:RegisterEvent("LOOT_OPENED")
    self:RegisterEvent("LOOT_SLOT_CLEARED")
    SatchelQueue_Button:Show()
end

function SatchelQueue:OnDisable()
    self:UnregisterEvent("LOOT_OPENED")
    self:UnregisterEvent("LOOT_SLOT_CLEARED")
    self:TimerStop()
    SatchelQueue_Button:Hide()
    self:UnhookAll()
end

function SatchelQueue:Toggle()
    if timer then
        self:TimerStop()
    else
        self:TimerStart()
    end
    self:UpdateStatus(QueueStatusFrame)
end

function SatchelQueue:TimerStart()
    if not timer then
        self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
        timer = self:ScheduleRepeatingTimer(RequestLFDPlayerLockInfo, LFD_STATISTIC_CHANGE_TIME)
        SatchelQueue_Button:SetText(BUTTON_QUEUED)
        RequestLFDPlayerLockInfo()
    end
end

local function ResetSound()
    if sound_all then
        SetCVar("Sound_EnableAllSound", sound_all)
        SetCVar("Sound_EnableSoundWhenGameIsInBG", sound_bg)
        
        sound_all = nil
        sound_bg = nil
    end
end

function SatchelQueue:TimerStop()
    if timer then
        self:UnregisterEvent("LFG_UPDATE_RANDOM_INFO")
        self:CancelTimer(timer, true)
        timer = nil;
        SatchelQueue_Button:SetText(BUTTON_TEXT)
        ResetSound()
    end
end

-- code copied from Blizzard's QueueStatusFrame_Update, may be it can be hooked somehow instead?
function SatchelQueue:UpdateStatus(self)
    local showMinimapButton, animateEye;

    local nextEntry = 1;

    local totalHeight = 4; --Add some buffer height

    --Try each LFG type
    for i=1, NUM_LE_LFG_CATEGORYS do
        local mode, submode = GetLFGMode(i);
        if ( mode ) then
            local entry = QueueStatusFrame_GetEntry(self, nextEntry);
            QueueStatusEntry_SetUpLFG(entry, i);
            entry:Show();
            totalHeight = totalHeight + entry:GetHeight();
            nextEntry = nextEntry + 1;

            showMinimapButton = true;
            if ( mode == "queued" ) then
                animateEye = true;
            end
        end
    end

    --Try all PvP queues
    for i=1, GetMaxBattlefieldID() do
        local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch, eligibleInQueue, waitingOnOtherActivity = GetBattlefieldStatus(i);
        if ( status and status ~= "none" ) then
            local entry = QueueStatusFrame_GetEntry(self, nextEntry);
            QueueStatusEntry_SetUpBattlefield(entry, i);
            entry:Show();
            totalHeight = totalHeight + entry:GetHeight();
            nextEntry = nextEntry + 1;

            showMinimapButton = true;
            if ( status == "queued" ) then
                animateEye = true;
            end
        end
    end

    --Try all World PvP queues
    for i=1, MAX_WORLD_PVP_QUEUES do
        local status, mapName, queueID = GetWorldPVPQueueStatus(i);
        if ( status and status ~= "none" ) then
            local entry = QueueStatusFrame_GetEntry(self, nextEntry);
            QueueStatusEntry_SetUpWorldPvP(entry, i);
            entry:Show();
            totalHeight = totalHeight + entry:GetHeight();
            nextEntry = nextEntry + 1;

            showMinimapButton = true;
            if ( status == "queued" ) then
                animateEye = true;
            end
        end
    end

    --World PvP areas we're currently in
    if ( CanHearthAndResurrectFromArea() ) then
        local entry = QueueStatusFrame_GetEntry(self, nextEntry);
        QueueStatusEntry_SetUpActiveWorldPVP(entry);
        entry:Show();
        totalHeight = totalHeight + entry:GetHeight();
        nextEntry = nextEntry + 1;

        showMinimapButton = true;
    end

    --Pet Battle PvP Queue
    local pbStatus = C_PetBattles.GetPVPMatchmakingInfo();
    if ( pbStatus ) then
        local entry = QueueStatusFrame_GetEntry(self, nextEntry);
        QueueStatusEntry_SetUpPetBattlePvP(entry);
        entry:Show();
        totalHeight = totalHeight + entry:GetHeight();
        nextEntry = nextEntry + 1;

        showMinimapButton = true;
        if ( pbStatus == "queued" ) then
            animateEye = true;
        end
    end

    --Satchel Queue
    if SatchelQueue.db.global.icon then
        local mode = GetLFGMode(LE_LFG_CATEGORY_LFD)
        if not mode and timer then
            local entry = QueueStatusFrame_GetEntry(self, nextEntry);
            QueueStatusEntry_SetMinimalDisplay(entry, "SatchelQueue", QUEUED_STATUS_QUEUED);
            entry:Show();
            totalHeight = totalHeight + entry:GetHeight();
            nextEntry = nextEntry + 1;

            showMinimapButton = true;
            animateEye = true;
        end
    end

    --Hide all remaining entries.
    for i=nextEntry, #self.StatusEntries do
        self.StatusEntries[i]:Hide();
    end

    --Update the size of this frame to fit everything
    self:SetHeight(totalHeight);

    --Update the minimap icon
    if ( showMinimapButton ) then
        QueueStatusMinimapButton:Show();
    else
        QueueStatusMinimapButton:Hide();
    end

    if ( animateEye ) then
        EyeTemplate_StartAnimating(QueueStatusMinimapButton.Eye);
    else
        EyeTemplate_StopAnimating(QueueStatusMinimapButton.Eye);
    end
end

local function CheckQueueReward(dungeonID)
    local leaderChecked, tankChecked, healerChecked, damageChecked = LFDQueueFrame_GetRoles()
    local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(dungeonID, LFG_ROLE_SHORTAGE_RARE)
    return eligible and itemCount > 0 and ((tankChecked and forTank) or (healerChecked and forHealer) or (damageChecked and forDamage))
end

local function CheckQueuePopReward(dungeonID, role)
    local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(dungeonID, LFG_ROLE_SHORTAGE_RARE)
    return eligible and itemCount > 0 and ((role == "TANK" and forTank) or (role == "HEALER" and forHealer) or (role == "DAMAGER" and forDamage))
end

function SatchelQueue:LFG_UPDATE_RANDOM_INFO()
    if not timer then
        return
    end
    
    ResetSound()
    
    local mode, submode = GetLFGMode(LE_LFG_CATEGORY_LFD)
    
    if not mode then
        local first, last, step = 1, GetNumRandomDungeons(), 1
        if self.db.global.prioritise then
            first, last, step = last, first, -1
            
            if self.db.global.exclusive then
                last = first
            end
        end
        
        for i = first, last, step do
            local id = GetLFGRandomDungeonInfo(i)
            if IsLFGDungeonJoinable(id) and CheckQueueReward(id) then
                SetLFGDungeon(LE_LFG_CATEGORY_LFD, id)
                JoinLFG(LE_LFG_CATEGORY_LFD)
                return
            end
        end
    elseif mode == "proposal" then
        if submode == "unaccepted" then
            local _, dungeonID, _, _, _, _, role = GetLFGProposal()
            if CheckQueuePopReward(dungeonID, role) then
                if self.db.global.sound_enable then
                    if self.db.global.sound_force then
                        if not sound_all then
                            sound_all = GetCVar("Sound_EnableAllSound")
                            sound_bg = GetCVar("Sound_EnableSoundWhenGameIsInBG")
                        end
                        
                        SetCVar("Sound_EnableAllSound", "1")
                        SetCVar("Sound_EnableSoundWhenGameIsInBG", "1")
                    end
                    PlaySoundFile(self.db.global.sound_file, "MASTER")
                end
                if self.db.global.flash_enable then
                    UIFrameFlash(SatchelQueue_Flash, 0.5, 0.5, 10.0, false, 0.0, 0.0)
                end
            elseif GetNumSubgroupMembers() == 0 then
                RejectProposal()
            end
        end
    elseif mode == "lfgparty" then
        if not self.db.global.requeue then
            self:TimerStop()
        end
    end
end

--hack: if item is locked, it is being used. only check satchels
local function GuessOpenSatchel()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
            if locked and lootable then
                local uid = SatchelID(GetContainerItemLink(bag, slot))
                if uid then
                    return uid
                end
            end
        end
    end
    return nil
end

--gold parsing liberated from Wowhead Looter (http://www.wowhead.com/client)
local WL_CURRENCY = {
	["1"] = COPPER_AMOUNT:gsub("%%d ", ""),
	["100"] = SILVER_AMOUNT:gsub("%%d ", ""),
	["10000"] = GOLD_AMOUNT:gsub("%%d ", ""),
};

local function wlParseCoin(strCoin)
	local coin = 0;
	for k, v in pairs(WL_CURRENCY) do
		local found, _, a = strCoin:find("(%d+) "..v);
		if found then
			coin = coin + a * tonumber(k);
		end
	end

	return coin;
end

local function IsBindOnPickup(link)
    SatchelQueue_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    SatchelQueue_Tooltip:SetHyperlink(link)
    
    for _,region in ipairs({SatchelQueue_Tooltip:GetRegions()}) do
        if region and region:GetObjectType() == "FontString" then
            if region:GetText() == ITEM_BIND_ON_PICKUP then
                return 1
            end
        end
    end
    return nil
end

function SatchelQueue:LOOT_OPENED()
    local uid = GuessOpenSatchel()
    if uid then
        if not self.db.global.saved_uids[uid] then
            self.db.global.count = self.db.global.count + 1
            
            for slot = 1, GetNumLootItems() do
				local slotType = GetLootSlotType(slot)
                local texture, item, quantity, quality, locked = GetLootSlotInfo(slot)
                
                if slotType == LOOT_SLOT_MONEY then
                    local coin = wlParseCoin(item)
                    self.db.global.coin_total = self.db.global.coin_total + coin
                    
                    if self.db.global.coin_min == -1 then
                        self.db.global.coin_min = coin
                        self.db.global.coin_max = coin
                    else
                        self.db.global.coin_min = min(self.db.global.coin_min, coin)
                        self.db.global.coin_max = max(self.db.global.coin_max, coin)
                    end
                elseif slotType == LOOT_SLOT_ITEM then
                    local _, _, id = string.find(GetLootSlotLink(slot), "|Hitem:(%d+):")
                    self.db.global.items[id] = (self.db.global.items[id] or 0) + quantity
                end
            end
        end
    
        local closing = nil
        if self.db.global.prevent_auto_loot and self.db.global.fake_auto_loot and should_auto_loot then
            should_auto_loot = false
            closing = true
            
            for slot = 1, GetNumLootItems() do
                if GetLootSlotType(slot) == LOOT_SLOT_MONEY or not IsBindOnPickup(GetLootSlotLink(slot)) then
                    LootSlot(slot)
                end
            end
            if GetNumLootItems() == 0 then
                self.db.global.saved_uids[uid] = nil
            end
        end
        
        --rebuild stored items
        if GetNumLootItems() > 0 then
            self.db.global.saved_uids[uid] = {}
            for slot = 1, GetNumLootItems() do
                local _, item = GetLootSlotInfo(slot)
                if item then --we havent just looted the slot
                    self.db.global.saved_uids[uid][slot] = GetLootSlotType(slot) == LOOT_SLOT_MONEY and -wlParseCoin(item) or tonumber(select(3, string.find(GetLootSlotLink(slot), "|Hitem:(%d+):")))
                end
            end
        end
        
        if closing then
            CloseLoot()
        end
    end
end

function SatchelQueue:LOOT_SLOT_CLEARED()
    local uid = GuessOpenSatchel()
    if uid then
        if GetNumLootItems() == 1 and not GetLootSlotInfo(1) then
            self.db.global.saved_uids[uid] = nil
        end
    end
end

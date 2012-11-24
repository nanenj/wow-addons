-- Adapted from idQuestAutomation
local DGV = DugisGuideViewer
if not DGV then return end

local AutoQuestAccept = {}
DGV.AutoQuestAccept = AutoQuestAccept

AutoQuestAccept.Frame = CreateFrame('Frame')
AutoQuestAccept.completed_quests = {}
AutoQuestAccept.incomplete_quests = {}
local _

function AutoQuestAccept:canAutomate ()
	if IsShiftKeyDown() or not DugisGuideViewer:UserSetting(DGV_AUTOQUESTACCEPT) then
		return false
	else
		return true
	end
end

function AutoQuestAccept:strip_text (text)
	if not text then return end
	text = text:gsub('|c%x%x%x%x%x%x%x%x(.-)|r','%1')
	text = text:gsub('%[.*%]%s*','')
	text = text:gsub('(.+) %(.+%)', '%1')
	text = text:trim()
	return text
end

function AutoQuestAccept:QUEST_PROGRESS ()
	DebugPrint("###QUEST_PROGRESS")
	if not self:canAutomate() then return end
	if IsQuestCompletable() then
		CompleteQuest()
	end
end

function AutoQuestAccept:QUEST_LOG_UPDATE ()
	if not self:canAutomate() then return end
	local start_entry = GetQuestLogSelection()
	local num_entries = GetNumQuestLogEntries()
	local title
	local is_complete
	local no_objectives

	self.completed_quests = {}
	self.incomplete_quests = {}

	if num_entries > 0 then
	for i = 1, num_entries do
		SelectQuestLogEntry(i)
		title, _, _, _, _, _, is_complete = GetQuestLogTitle(i)
		no_objectives = GetNumQuestLeaderBoards(i) == 0
		if title then
			if is_complete or no_objectives then
			 self.completed_quests[title] = true
			else
			  self.incomplete_quests[title] = true
			end
		end
	end
	end

	SelectQuestLogEntry(start_entry)
end

function AutoQuestAccept:GOSSIP_SHOW ()
	DebugPrint("###GOSSIP_SHOW")
	
	if not self:canAutomate() then return end

	local button
	local text
	local i
	
	for i = 1, 32 do
	button = _G['GossipTitleButton' .. i]
		if button:IsVisible() then
		  text = self:strip_text(button:GetText())
			if button.type == 'Available' then
				button:Click()
			elseif button.type == 'Active' then
				if self.completed_quests[text] then
					button:Click()
				end
			end
		end
	end
	
end

function AutoQuestAccept:QUEST_DETAIL ()
	DebugPrint("###QUEST_DETAIL")

	if not self:canAutomate() then return end
	QuestInfoDescriptionText:SetAlphaGradient(0, math.huge)
	if ( QuestGetAutoAccept() ) then
		CloseQuest()
	else
		AcceptQuest()
	end
end

function AutoQuestAccept:QUEST_COMPLETE (event)
	DebugPrint("###QUEST_COMPLETE")
	if not self:canAutomate() then return end
	if GetNumQuestChoices() <= 1 then
		GetQuestReward(GetNumQuestChoices()) --Completes the quest with the specified quest reward. 
		DugisGuideViewer:CompleteQuest()
	end
end


function AutoQuestAccept:QUEST_GREETING (...)
	DebugPrint("###QUEST_GREETING")
	if not self:canAutomate() then return end

	local button
	local text
	local i
	
	for i = 1, 32 do
		button = _G['QuestTitleButton' .. i]
		if button:IsVisible() then
			text = self:strip_text(button:GetText())
			if self.completed_quests[text] then
				button:Click()
			elseif not self.incomplete_quests[text] then
				button:Click()
			end
		end
	end
end

function AutoQuestAccept.Frame.onevent (self, event, ...)
	if AutoQuestAccept[event] then
		AutoQuestAccept[event](AutoQuestAccept, ...)
	end
end

function AutoQuestAccept:Enable( )
	enabled = true
	AutoQuestAccept.Frame:SetScript('OnEvent', AutoQuestAccept.Frame.onevent)
	AutoQuestAccept.Frame:RegisterEvent('GOSSIP_SHOW') --Fired when you talk to an npc, lists quests
	AutoQuestAccept.Frame:RegisterEvent('QUEST_COMPLETE') --Fired after the player hits the "Continue" button in the quest-information page, before the "Complete Quest" button.
	AutoQuestAccept.Frame:RegisterEvent('QUEST_DETAIL') --Fired when the player is given a more detailed view of his quest.
	AutoQuestAccept.Frame:RegisterEvent('QUEST_GREETING') --Fired when talking to an NPC that offers or accepts more than one quest, i.e. has more than one active or available quest. turn in and accept
	AutoQuestAccept.Frame:RegisterEvent('QUEST_LOG_UPDATE')
	AutoQuestAccept.Frame:RegisterEvent('QUEST_PROGRESS')--Fired when a player is talking to an NPC about the status of a quest and has not yet clicked the complete button.
end

function AutoQuestAccept:Disable( )
	enabled = false
	AutoQuestAccept.Frame:UnregisterAllEvents()
end






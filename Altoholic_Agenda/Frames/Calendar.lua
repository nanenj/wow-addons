local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local parent = "AltoholicFrameCalendar"

local WHITE		= "|cFFFFFFFF"
local TEAL		= "|cFF00FF9A"

-- Weekday constants
local CALENDAR_WEEKDAY_NORMALIZED_TEX_LEFT	= 0.0;
local CALENDAR_WEEKDAY_NORMALIZED_TEX_TOP		= 180 / 256;
local CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH	= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_WEEKDAY_NORMALIZED_TEX_HEIGHT	= 28 / 256 - 0.001; -- fudge factor to prevent texture seams

local CALENDAR_MAX_DAYS_PER_MONTH			= 42;		-- 6 weeks
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH	= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT	= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA		= 0.5;
local DAY_BUTTON = "AltoCalendarDayButton"

local CALENDAR_MONTH_NAMES = { CalendarGetMonthNames() };
local CALENDAR_WEEKDAY_NAMES = { CalendarGetWeekdayNames() };

local CALENDAR_FULLDATE_MONTH_NAMES = {
	-- month names show up differently for full date displays in some languages
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
};

local CONNECTMMO_LINE = 4

addon.Calendar = {}

local ns = addon.Calendar		-- ns = namespace

local view
local isViewValid
local EVENT_DATE = 1
local EVENT_INFO = 2
local NUM_EVENTLINES = 14

local function BuildView()
	view = view or {}
	wipe(view)
	
	-- the following list of events : 10/05, 10/05, 12/05, 14/05, 14/05
	-- turns into this view : 
	-- 	"10/05"
	--	event 1
	--	event 2
	--	"12/05"
	--	event 1
	-- 	"14/05"
	--	event 1
	--	event 2
	
	
	addon.Events:BuildList()
	
	local eventDate = ""
	for k, v in pairs(addon.Events:GetList()) do
		if eventDate ~= v.eventDate then
			table.insert(view, { linetype = EVENT_DATE, eventDate = v.eventDate })
			eventDate = v.eventDate
		end
		table.insert(view, { linetype = EVENT_INFO, parentID = k })
	end
	
	isViewValid = true
end

local function InitDay(index)
	local button = _G[DAY_BUTTON..index]
	button:SetID(index)
	
	-- set anchors
	button:ClearAllPoints();
	if ( index == 1 ) then
		button:SetPoint("TOPLEFT", AltoholicFrameCalendar, "TOPLEFT", 285, -1);
	elseif ( mod(index, 7) == 1 ) then
		button:SetPoint("TOPLEFT", _G[DAY_BUTTON..(index - 7)], "BOTTOMLEFT", 0, 0);
	else
		button:SetPoint("TOPLEFT", _G[DAY_BUTTON..(index - 1)], "TOPRIGHT", 0, 0);
	end

	-- set the normal texture to be the background
	local tex = button:GetNormalTexture();
	tex:SetDrawLayer("BACKGROUND");
	local texLeft = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
	local texRight = texLeft + CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
	local texTop = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	local texBottom = texTop + CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	tex:SetTexCoord(texLeft, texRight, texTop, texBottom);
	
	-- adjust the highlight texture layer
	tex = button:GetHighlightTexture();
	tex:SetAlpha(CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA);
end

function ns:OnLoad()
	addon.Tabs.Agenda:RegisterChildPane(ns)

	-- by default, the week starts on Sunday, adjust first day of the week if necessary
	if addon:GetOption("WeekStartsMonday") == 1 then
		addon:SetFirstDayOfWeek(2)
	end
	
	local band = bit.band;
	
	-- initialize weekdays
	for i = 1, 7 do
		local bg = _G["AltoholicFrameCalendarWeekday"..i.."Background"]
		local left = (band(i, 1) * CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH) + CALENDAR_WEEKDAY_NORMALIZED_TEX_LEFT;		-- mod(index, 2) * width
		local right = left + CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH;
		local top = CALENDAR_WEEKDAY_NORMALIZED_TEX_TOP;
		local bottom = top + CALENDAR_WEEKDAY_NORMALIZED_TEX_HEIGHT;
		bg:SetTexCoord(left, right, top, bottom);
	end
	
	-- initialize day buttons
	for i = 1, CALENDAR_MAX_DAYS_PER_MONTH do
		CreateFrame("Button", DAY_BUTTON..i, AltoholicFrameCalendar, "AltoCalendarDayButtonTemplate");
		InitDay(i)
	end
	
	addon.Tabs.Agenda:MenuItem_OnClick(1)	-- show this pane by default in the tab, best place to call this is here.
end

function ns:InvalidateView()
	isViewValid = nil
	if _G[ parent ]:IsVisible() then
		ns:Update()
	end
end

local function GetWeekdayIndex(index)
	-- GetWeekdayIndex takes an index in the range [1, n] and maps it to a weekday starting
	-- at CALENDAR_FIRST_WEEKDAY. For example,
	-- CALENDAR_FIRST_WEEKDAY = 1 => [SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY]
	-- CALENDAR_FIRST_WEEKDAY = 2 => [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY]
	-- CALENDAR_FIRST_WEEKDAY = 6 => [FRIDAY, SATURDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY]
	
	-- the expanded form for the left input to mod() is:
	-- (index - 1) + (CALENDAR_FIRST_WEEKDAY - 1)
	-- why the - 1 and then + 1 before return? because lua has 1-based indexes! awesome!
	return mod(index - 2 + addon:GetFirstDayOfWeek(), 7) + 1;
end

local function GetFullDate(weekday, month, day, year)
	local weekdayName = CALENDAR_WEEKDAY_NAMES[weekday];
	local monthName = CALENDAR_FULLDATE_MONTH_NAMES[month];
	return weekdayName, monthName, day, year, month;
end

local function GetDay(fullday)
	-- full day = a date as YYYY-MM-DD
	-- this function is actually different than the one in Blizzard_Calendar.lua, since weekday can't necessarily be determined from a UI button
	local refDate = {}		-- let's use the 1st of current month as reference date
	local refMonthFirstDay
	local _
	
	refDate.month, refDate.year, _, refMonthFirstDay = CalendarGetMonth()
	refDate.day = 1

	local t = {}
	local year, month, day = strsplit("-", fullday)
	t.year = tonumber(year)
	t.month = tonumber(month)
	t.day = tonumber(day)

	local numDays = floor(difftime(time(t), time(refDate)) / 86400)
	local weekday = mod(refMonthFirstDay + numDays, 7)
	
	-- at this point, weekday might be negative or 0, simply add 7 to keep it in the proper range
	weekday = (weekday <= 0) and (weekday+7) or weekday
	
	return t.year, t.month, t.day, weekday
end

local function GetEventLineIndex(year, month, day)
	local eventDate = format("%04d-%02d-%02d", year, month, day)
	for k, v in pairs(view) do
		if v.linetype == EVENT_DATE and v.eventDate == eventDate then
			-- if the date line is found, return its index
			return k
		end
	end
end

local function SetEventLineOffset(offset)
	-- if the view has less entries than can be displayed, don't change the offset
	if #view <= NUM_EVENTLINES then return end

	if offset <= 0 then
		offset = 0
	elseif offset > (#view - NUM_EVENTLINES) then
		offset = (#view - NUM_EVENTLINES)
	end
	FauxScrollFrame_SetOffset( AltoholicFrameCalendarScrollFrame, offset )
	AltoholicFrameCalendarScrollFrameScrollBar:SetValue(offset * 18)
end

-- *** Update ***
local function UpdateDay(index, day, month, year, isDarkened)
	local button = _G[DAY_BUTTON..index]
	local buttonName = button:GetName();
	
	button.day = day
	button.month = month
	button.year = year
	
	-- set date
	local dateLabel = _G[buttonName.."Date"];
	local tex = button:GetNormalTexture();

	dateLabel:SetText(day);
	if isDarkened then
		tex:SetVertexColor(0.4, 0.4, 0.4)
	else
		tex:SetVertexColor(1.0, 1.0, 1.0)
	end
	
	-- set count
	local countLabel = _G[buttonName.."Count"];
	local count = addon.Events:GetDayCount(year, month, day)
	
	if count == 0 then
		countLabel:Hide()
	else
		countLabel:SetText(count)
		countLabel:Show()
	end
end

function ns:Update()
	-- taken from CalendarFrame_Update() in Blizzard_Calendar.lua, adjusted for my needs.
	if not isViewValid then
		BuildView()
	end
	
	local presentWeekday, presentMonth, presentDay, presentYear = CalendarGetDate();
	local prevMonth, prevYear, prevNumDays = CalendarGetMonth(-1);
	local nextMonth, nextYear, nextNumDays = CalendarGetMonth(1);
	local month, year, numDays, firstWeekday = CalendarGetMonth();

	-- set title
	AltoholicFrameCalendar_MonthYear:SetText(CALENDAR_MONTH_NAMES[month] .. " ".. year)
	
	-- initialize weekdays
	for i = 1, 7 do
		_G["AltoholicFrameCalendarWeekday"..i.."Name"]:SetText(string.sub(CALENDAR_WEEKDAY_NAMES[GetWeekdayIndex(i)], 1, 3));
	end

	local buttonIndex = 1;
	local isDarkened = true
	local day;

	-- set the previous month's days before the first day of the week
	local viewablePrevMonthDays = mod((firstWeekday - addon:GetFirstDayOfWeek() - 1) + 7, 7);
	day = prevNumDays - viewablePrevMonthDays;

	while ( GetWeekdayIndex(buttonIndex) ~= firstWeekday ) do
		UpdateDay(buttonIndex, day, prevMonth, prevYear, isDarkened)
		day = day + 1;
		buttonIndex = buttonIndex + 1;
	end

	-- set the days of this month
	day = 1;
	isDarkened = false
	while ( day <= numDays ) do
		UpdateDay(buttonIndex, day, month, year, isDarkened)
		day = day + 1;
		buttonIndex = buttonIndex + 1;
	end
	
	-- set the first days of the next month
	day = 1;
	isDarkened = true
	while ( buttonIndex <= CALENDAR_MAX_DAYS_PER_MONTH ) do
		UpdateDay(buttonIndex, day, nextMonth, nextYear, isDarkened)

		day = day + 1;
		buttonIndex = buttonIndex + 1;
	end
	
	ns:UpdateEvents()
end

function ns:UpdateEvents()

	local VisibleLines = NUM_EVENTLINES
	local frame = "AltoholicFrameCalendar"
	local entry = frame.."Entry"

	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );

	for i=1, VisibleLines do
		local line = i + offset
		if line <= #view then
			local s = view[line]

			if s.linetype == EVENT_DATE then
				local year, month, day, weekday = GetDay(s.eventDate)
				_G[ entry..i.."Date" ]:SetText(format(FULLDATE, GetFullDate(weekday, month, day, year)))
				_G[ entry..i.."Date" ]:Show()
				
				_G[ entry..i.."Hour" ]:Hide()
				_G[ entry..i.."Character" ]:Hide()
				_G[ entry..i.."Title" ]:Hide()
				_G[ entry..i.."_Background"]:Show()
				
			elseif s.linetype == EVENT_INFO then
				local char, eventTime, title = addon.Events:GetInfo(s.parentID)

				_G[ entry..i.."Hour" ]:SetText(eventTime)
				_G[ entry..i.."Character" ]:SetText(char)
				_G[ entry..i.."Title" ]:SetText(title)
				
				_G[ entry..i.."Hour" ]:Show()
				_G[ entry..i.."Character" ]:Show()
				_G[ entry..i.."Title" ]:Show()

				_G[ entry..i.."Date" ]:Hide()
				_G[ entry..i.."_Background"]:Hide()
			end

			_G[ entry..i ]:SetID(line)
			_G[ entry..i ]:Show()
		else
			_G[ entry..i ]:Hide()
		end
	end
	
	local last = (#view < VisibleLines) and VisibleLines or #view
	FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], last, VisibleLines, 18);
end

-- *** Mouse events ***
function ns:Day_OnClick(frame, button)
	if addon.Events:GetDayCount(frame.year, frame.month, frame.day) == 0 then	
		return	-- no events on that day ? exit
	end	
	
	local index = GetEventLineIndex(frame.year, frame.month, frame.day)
	if index then
		SetEventLineOffset(index - 1)	-- if the date is the 4th line, offset is 3
		ns:UpdateEvents()
	end
end

function ns:Day_OnEnter(frame)
	if addon.Events:GetDayCount(frame.year, frame.month, frame.day) == 0 then
		return	-- no events on that day ? exit
	end
	
	AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
	AltoTooltip:ClearLines();
	local eventDate = format("%04d-%02d-%02d", frame.year, frame.month, frame.day)
	local weekday = GetWeekdayIndex(mod(frame:GetID(), 7)) 
	weekday = (weekday == 0) and 7 or weekday
	
	AltoTooltip:AddLine(TEAL..format(FULLDATE, GetFullDate(weekday, frame.month, frame.day, frame.year)));

	for k, v in pairs(addon.Events:GetList()) do
		if v.eventDate == eventDate then
			local char, eventTime, title = addon.Events:GetInfo(k)
			AltoTooltip:AddDoubleLine(format("%s %s", WHITE..eventTime, char), title);
		end
	end
	AltoTooltip:Show();
end

function ns:Event_OnEnter(frame)
	local s = view[frame:GetID()]
	if not s or s.linetype == EVENT_DATE then return end
	
	AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	AltoTooltip:ClearLines();
	-- local eventDate = format("%04d-%02d-%02d", self.year, self.month, self.day)
	-- local weekday = GetWeekdayIndex(mod(self:GetID(), 7))
	-- AltoTooltip:AddLine(TEAL..format(FULLDATE, GetFullDate(weekday, self.month, self.day, self.year)));
	
	local char, eventTime, title, desc = addon.Events:GetInfo(s.parentID)
	AltoTooltip:AddDoubleLine(format("%s %s", WHITE..eventTime, char), title);
	if desc then
		AltoTooltip:AddLine(" ")
		AltoTooltip:AddLine(desc)
	end
	AltoTooltip:Show();
end

function ns:Event_OnClick(frame, button)
	-- if an event is left-clicked, try to invite attendees. ConnectMMO events only
	
	local s = view[frame:GetID()]
	if not s or s.linetype == EVENT_DATE then return end		-- date line ? exit
	
	local e = addon.Events:Get(s.parentID)		-- dereference event
	-- not a connectmmo event ? or wrong realm ? exit
	if not e or e.eventType ~= CONNECTMMO_LINE or e.realm ~= GetRealmName() then return end	
	
	local c = addon:GetCharacterTable(e.char, e.realm)
	if not c then return end	-- invalid char table ? exit
	
	local _, _, _, _, _, attendees = strsplit("|", c.ConnectMMO[e.parentID])

	-- TODO, add support for raid groups
	for _, name in pairs({ strsplit(",", attendees) }) do
		if name ~= UnitName("player") then
			InviteUnit(name) 
		end
	end
end

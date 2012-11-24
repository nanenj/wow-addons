-- Always initialise enGB, as it's the default
local L = mrp.L

-- Default locale-dependent options

L["option_HeightUnit"] = 2 -- 0 = centimetres, 1 = metres, 2 = feet/inches
L["option_WeightUnit"] = 2 -- 0 = kilograms, 1 = pounds, 2 = stone/pounds

-- The title of the profile editor tab
L["tabtitle"] = "MyRolePlay"

-- Appears below MyRolePlay in the options panel, describes what the addon does
L["mrp_addon_notes"] = GetAddOnMetadata( "MyRolePlay", "Notes" )

-- Field formats
L["mo_format"] = [[“%s”]]
L["ni_format"] = [[“%s”]]
L["nh_format"] = "of %s"
-- Height
L["cm_format"] = "%dcm"
L["cm_format_name"] = "Centimetres (170cm)"
L["m_format"] = "%.2fm"
L["m_format_name"] = "Metres (1.70m)"
L["ftin_format"] = [[%d'%d"]]
L["ftin_format_name"] = [[Feet & Inches (5'6")]]
-- Weight
L["kg_format"] = "%dkg"
L["kg_format_name"] = "Kilograms (60kg)"
L["lb_format"] = "%dlb"
L["lb_format_name"] = "Pounds (132lb)"
L["stlb_format"] = "%dst %dlb"
L["stlb_format_name"] = "Stones & Pounds (9st 6lb)"

-- Tooltip style names
L["ttstyle_0_name"] = "|cffc0c0c0Blizzard Default (no enhancement)|r"
L["ttstyle_1_name"] = "Light"
L["ttstyle_2_name"] = "Enhanced"
L["ttstyle_3_name"] = "Enhanced |cff90c0c0(no Guild Rank)|r"
L["ttstyle_4_name"] = "Compact"
L["ttstyle_5_name"] = "Compact |cff90c0c0(no Guild Rank)|r"
L["ttstyle_6_name"] = "Flag-style"

-- Preset roleplaying styles
L["FR0"] = "(Style not set)"
L["FR0t"] = "Not yet set"
L["FR0d"] = [[Please choose your roleplaying style.]]
L["FR1"] = "Normal roleplayer"
L["FR1t"] = "Normal"
L["FR1d"] = [[Your roleplaying style is conventional.

You are usually in character, but sometimes revert to
out–of–character communication (for example in
instances, or when game mechanics demand it). ]]
L["FR2"] = "Casual roleplayer"
L["FR2t"] = "Casual"
L["FR2d"] = [[Your roleplaying style is casual.

You are often in character, but frequently revert to
out–of–character communication when it is more
convenient to do so. ]]
L["FR3"] = "Full–time roleplayer"
L["FR3t"] = "Full–time"
L["FR3d"] = [[Your roleplaying style is full–time.

You are almost always in character, and strive for
maximum immersion where possible. ]]
L["FR4"] = "Beginner roleplayer"
L["FR4t"] = "Beginner"
L["FR4d"] = [[Your roleplaying style is beginner.

You are new to roleplaying, or still getting a feel for
this character or the World of Warcraft setting.

Other players are requested to be forgiving of any
mistakes.]]
L["FRc"] = "(Custom)"
L["FRct"] = "Custom"
L["FRcd"] = [[Define a roleplaying style of your own not listed above.]]


-- Preset character statuses
L["FC0"] = "(Status not set)"
L["FC0t"] = "Not yet set"
L["FC0d"] = [[Please select your current status.]]
L["FC1"] = "Out Of Character"
L["FC1t"] = "Out Of Character (OOC)"
L["FC1d"] = [[You are currently out of character, playing the game rather
than playing as your character.

Anything you do while in this status should not be taken as
literally being done by your character.

Please remember that no out of character or non–fantasy
related dialogue should take place in /say, /emote, or /yell.]]
L["FC2"] = "In Character"
L["FC2t"] = "In Character (IC)"
L["FC2d"] = [[You are currently in character, talking and behaving however
your character would normally act.

In–character actions should yield in–character consequences.
Other characters may interact with your character.]]
L["FC3"] = "Looking For Contact"
L["FC3t"] = "Looking For Contact (LFC)"
L["FC3d"] = [[You are currently in character, talking and behaving however
your character would normally act.

In–character actions should yield in–character consequences.
Other characters are explicitly invited and encouraged to
interact with your character.]]
L["FC4"] = "Storyteller"
L["FC4t"] = "Storyteller"
L["FC4d"] = [[You are currently in character, talking and behaving however
your character would normally act.

You are currently leading a storyline in which other characters
may choose to participate.]]
L["FCc"] = "(Custom)"
L["FCct"] = "Custom"
L["FCcd"] = [[Define a character status of your own not listed above.]]

-- Field names and tooltip descriptions for the profile editor
L["NA"] = "Name"
L["efNA"] = [[The name of your character, as you like it to be displayed.

You can put a second name in here,
or change it however you wish.]]
--
L["NI"] = "Nickname"
L["efNI"] = [[Your character’s nickname, if they have one.

A name they’re commonly known by to friends, perhaps.]]
--
L["NT"] = "Title"
L["efNT"] = [[Your character’s title; what appears below their name.

Often a one-line description or synopsis.]]
--
L["NH"] = "House"
L["efNH"] = [[Your character’s “house name”, if applicable;
only a few races would have these.]]
--
L["AE"] = "Eyes"
L["efAE"] = [[The eye colour of your character, as appropriate.]]
--
L["RA"] = "Race"
L["efRA"] = [[Your character’s race (if not as it appears in–game).

|cffff5533Warning:|r playing as rare or exotic races is not
recommended for the beginner; it may be challenging
to convincingly roleplay as some races within
the World of Warcraft setting.

(Not everyone can, or should, be half–elves!)

You are advised extreme caution with this field.

Leave this blank to keep your race as it appears in–game.]]
--
L["AH"] = "Height"
L["efAH"] = [[How tall (or short) your character is.

Either put:—
 · a specific height:
    (enter as a number in centimetres without units, e.g. 175); or,
 · a brief relative description (Tall, Short, Average…)]]
--
L["AW"] = "Weight"
L["efAW"] = [[How much your character appears to weigh.

Either put:—
 · a specific weight:
    (enter as a number in kilograms without units, e.g. 60.5); or,
 · a brief relative description (Slim, Bulky, Heavy-set…)]]
--
L["AG"] = "Age"
L["efAG"] = [[How old your character is.

Either put:—
 · A specific age:
    (in years, without units, e.g. 45); or,
 · a brief description (Young, Old, Middle-Aged…)

Bear in mind that if you put a specific age in years,
that races have wildly differing rates of aging.
(e.g. a 300–year–old night elf is just barely an adult…)]]
--
L["CU"] = "Currently"
L["efCU"] = [[If someone glances at your character right now: 
what’s the very first thing they notice?

Is your character happy? Sad? Tired? Suspicious?
Holding something? Covered in blood? Shopping? Preoccupied?

This field is deliberately intended to be very brief. 
Only a few words may be displayed: try to make them count!]]
--
L["DE"] = "Description"
L["efDE"] = [[Describe the appearance of your character, as someone
looking at them would immediately see them.

Think of how a text adventure or a book might
describe them.

Please |cffff5533avoid|r the following:—
 · outlining the history of your character; put that in
   History if you wish;
 · specifying how other characters react to them
   (controlling other characters is best left to their
     respective players);
 · anything that doesn’t relate to how your character looks;
 · anything that would breach the rules or realm policies.

Remember that ONLY appearance descriptions go here.]]
--
L["HH"] = "Home"
L["efHH"] = [[The place your character currently lives, if any.]]
--
L["HB"] = "Birthplace"
L["efHB"] = [[Where your character was born.]]
--
L["MO"] = "Motto"
L["efMO"] = [[Either:—

 · the character’s motto;
 · how they would sum up their outlook on life; or,
 · something they say frequently that you
   think sums up their character.]]
--
L["HI"] = "History"
L["efHI"] = [[You may, if you wish, outline some of your character’s
history and background here.

Rather than a full biography, players may wish to
limit this information to only things that are known
publically about your character (rumours, perhaps)—as
many players prefer to discover this kind of thing
through actually interacting with you.

Try giving them a taste, instead of the whole pie!]]
--
L["FR"] = "Roleplaying Style"
L["efFR"] = [[Your preferred style of roleplaying for this character.]]
--
L["FC"] = "Character Status"
L["efFC"] = [[Whether you’re currently in or out of character,
looking for contact, or a storyteller.]]

-- Command usage

L["commandusage"] = [[Usage: |cff99ffff/mrp|r |cffaaaa00<command>|r
Commands are as follows:
    |cff99ffffshow|r - Show target’s RP profile, if appropriate
    |cff99ffffshow|r |cffaaaa00<charactername>|r - Show someone’s RP profile, if appropriate
    |cff99ffffbrowser reset|r - Reset the profile browser to the default size & position
    |cff99ffffprofile|r |cffaaaa00<profile name>|r - Switch to another profile (by name)
    |cff99ffffedit|r - Show the profile editor
    |cff99ffffoptions|r - Show the options panel
    |cff99ffffbutton on|r/|cff99ffffoff|r - Show/hide an “MRP” button by the target frame, to browse their RP profile
    |cff99ffffbutton reset|r - Resets the MRP button to the default position by the target frame
    |cff99fffftooltip on|r/|cff99ffffoff|r - Control whether MRP shows enhanced tooltips for players including profile information
    |cff99ffffenable|r/|cff99ffffdisable|r - Completely enable/disable MyRolePlay
    |cff99ffffversion|r - Show version information]]

-- Options Panel

L["opt_enable"] = "Enable"
L["opt_enable_tt"] = [[Turn MyRolePlay on or off completely.]]
L["opt_tt"] = "Enhanced Tooltips"
L["opt_tt_tt"] = [[Enhance player tooltips with roleplaying information.

Can be very useful, but can be disabled in case you dislike
the style, or if it interferes with other AddOns that also
modify player tooltips.]]
L["opt_mrpbutton"] = "Show MRP Button"
L["opt_mrpbutton_tt"]= [[Show an “MRP” button near the target frame when targeting players with a compatible AddOn.

Left-click it to browse the character profile.
Right-click it to lock/unlock it to drag it around to another place.]]
--
L["opt_rpchatname"] = "Show RP Names in /say, /emote & /yell"
L["opt_rpchatname_tt"]= [[Shows RP names in the chat channel windows for RP channels, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_disp_header"] = "Profile Display"
L["opt_biog"] = "Show biographical information"
L["opt_biog_tt"] = [[Whether to show or hide the Biography tab in the profile browser.

Enable if you prefer more information.
Disable if you prefer discovering characters’ background information through interaction.]]
L["opt_ahunit"] = "Show height in…"
L["opt_awunit"] = "Show weight in…"
--
L["opt_ac_header"] = "Automatically change profile on…"
--
L["opt_formac"] = "Shapeshifting"

L["opt_formac_tt"] = [[Automatically changes to another profile when you change form.
]]
L["opt_formac_tt_disabled"] = L["opt_formac_tt"] .. [[
(This character has no form changes available, so this does nothing.)]]
L["opt_formac_tt_enabled1"] = L["opt_formac_tt"] .. [[

Name the profile exactly after the form, as follows:—
]]
L["opt_formac_tt_suffix"] = [[  (|cffff9090do not|r include the quotes; profile names are |cffff9090case-sensitive|r!)

Changing back to your original form changes back to your original profile.

For non-Default profiles, use “|cffffff00Profilename:Form|r”: (e.g.)
· Select “|cffffff00Tuxedo|r” -> turn Worgen -> it tries to autochange to “|cffffff00Tuxedo:Worgen|r”
   (…tailor repair fees not included. Results May Vary™.)
]]

L["opt_formac_tt_worgensuffix"] = [[

|cffffa0a0Note: |rAlas, Human/Worgen detection is imperfect (due to a Blizzard oversight).
Cast |cff80c0c0Darkflight|r, |cff80c0c0Running Wild|r, or |cff80c0c0enter combat|r to try to fix.]]

L["opt_formac_tt_worgen"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…set up whichever form you feel is not the “Default”; you only need one)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_worgendruid"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one)
· “|cffffff00Cat|r”;
· “|cffffff00Bear|r”;
· “|cffffff00Travel|r” (or “|cffffff00Cheetah|r”);
· “|cffffff00Flight|r” (or “|cffffff00Bird|r”);
· “|cffffff00Aquatic|r” (or “|cffffff00Seal|r” or “|cffffff00Sealion|r”);
· “|cffffff00Moonkin|r” (or “|cffffff00Owlkin|r”) (where appropriate); and,
· “|cffffff00Tree|r” (where appropriate).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_druid"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Cat|r”;
· “|cffffff00Bear|r”;
· “|cffffff00Travel|r” (or “|cffffff00Cheetah|r”);
· “|cffffff00Flight|r” (or “|cffffff00Bird|r”);
· “|cffffff00Aquatic|r” (or “|cffffff00Seal|r” or “|cffffff00Sealion|r”);
· “|cffffff00Moonkin|r” (or “|cffffff00Owlkin|r”) (where appropriate); and,
· “|cffffff00Tree|r” (where appropriate).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_shaman"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Ghost Wolf|r” (or just “|cffffff00Wolf|r”).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_priest"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Shadow|r”.
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenpriest"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one); and,
· “|cffffff00Shadow|r”.
(Note: You may also wish to have “|cffffff00Shadow:Human|r” and/or “|cffffff00Shadow:Worgen|r”
            (or the other way around), because you can be in Shadow form
            AND a Human/Worgen at the same time…)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_warlock"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Demon|r” (where appropriate for your specialisation).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenwarlock"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one); and,
· “|cffffff00Demon|r” (where appropriate for your specialisation).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]
--
L["opt_equipac"] = "Changing equipment set"
L["opt_equipac_tt"] = [[Changes to another profile automatically when you change equipment set.

Name the profile after the equipment set (|cffff9090case–sensitive|r).

Great for changing your description in different RP outfits.

Works with Blizzard’s /equipset, ItemRack and Outfitter.]]

-- Races - overrides for RaceEn, second return from UnitRace(), to localise them
L["NightElf"] = "Night Elf"
L["Scourge"] = "Forsaken"

-- All other strings for enGB are as hardcoded
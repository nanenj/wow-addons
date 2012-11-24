--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	ID.lua - A list of users to specially identify i.e. debug/beta/dev users
]]

local L = mrp.L

-- ['guid'] = { "Realm-REGION", "identification" }
mrp.id = {
	-- Etarna Moonshyne, Author of MyRolePlay 4.x <etarna@moonshyne.org>
	['0x01800000035FF50E'] = { "Argent Dawn-EU", L["(( MyRolePlay Author ))"] }, -- Etarna
	['0x0180000002CBBA59'] = { "Argent Dawn-EU", L["(( MyRolePlay Author ))"] }, -- Dulcamara
	['0x0180000002B99E68'] = { "Argent Dawn-EU", L["(( MyRolePlay Author ))"] }, -- Mimetia
	['0x018000000345322E'] = { "Argent Dawn-EU", L["(( MyRolePlay Author ))"] }, -- Mornington
	['0x0500000000254624'] = { "Ravenholdt-EU", L["(( MyRolePlay Author ))"] }, -- Elandru
	-- The beta testers of <Bittersweet>, Argent Dawn-EU
	['0x0180000003042AB4'] = { "Argent Dawn-EU", L["(( MRP Beta Tester ))"] },
	['0x0180000002C52CEE'] = { "Argent Dawn-EU", L["(( MRP Beta Tester ))"] },
	['0x0180000002A8235E'] = { "Argent Dawn-EU", L["(( MRP Beta Tester ))"] },
	-- Other beta testers
	['0x0180000003537355'] = { "Argent Dawn-EU", L["(( MRP Beta Tester ))"] },
}
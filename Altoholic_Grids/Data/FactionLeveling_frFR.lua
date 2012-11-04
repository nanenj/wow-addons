if GetLocale() ~= "frFR" then return end		-- ** French translation by Laumac **

local addonName = "Altoholic"
local addon = _G[addonName]

local BF = LibStub("LibBabble-Faction-3.0"):GetLookupTable()

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"


addon.FactionLeveling = {

	-- Reputation levels
	-- -42000 = "Haï"
	-- -6000 = "Hostile"
	-- -3000 = "Inamical"
	-- 0 = "Neutre"
	-- 3000 = "Amical"
	-- 9000 = "Honor\195\169"
	-- 21000 = "R\195\169v\195\169r\195\169"
	-- 42000 = "Exalt\195\169"

	-- Outland factions: source: http://www.mmo-champion.com/
	[BF["The Aldor"]] = {
		[0] = WHITE .. "[Glande \195\160 venin de croc-d'effroi]|r +250 rep\n\n"
				.. YELLOW .. "R\195\180deuse croc-d'effroi,\nVeuve croc-d'effroi\n"
				.. WHITE .. "(For\195\170t de Terrokar)",
		[9000] = WHITE .. "[Marque de Kil'jaeden]|r\n+25 rep",
		[42000] = WHITE .. "[Marque de Sargeras]|r +25 rep par marque\n"
				.. GREEN .. "[Arme gangren\195\169e]|r +350 rep (+1 [Poussi\195\168re sacr\195\169e])"
	},
	[BF["The Scryers"]] = {
		[0] = WHITE .. "[Oeil de basilic tremp\195\169caille]|r +250 rep\n\n"
				.. YELLOW .. "P\195\169trificateur Echine-de-fer,\nD\195\169voreur Tremp\195\169caille,\nBasilic Tremp\195\169caille\n"
				.. WHITE .. "(For\195\170t de Terrokar)",
		[9000] = WHITE .. "[Chevali\195\168re Aile-de-feu]|r\n+25 rep",
		[42000] = WHITE .. "[Chevali\195\168re Solfurie]|r +25 rep par chevali\195\168re\n"
				.. GREEN .. "[Tome des arcanes]|r +350 rep (+1 [Rune des arcanes])"
	},
	[BF["Netherwing"]] = {
		[3000] = "\n"
				.. YELLOW .. "Une mort lente (Journali\195\168re)|r 250 rep\n"
				.. YELLOW .. "Du pollen de pruin\195\169ante (Journali\195\168re)|r 250 rep\n"
				.. YELLOW .. "Les cristaux de l'Aile-du-N\195\169ant (Journali\195\168re)|r 250 rep\n"
				.. YELLOW .. "Les cieux pas si cl\195\169ments... (Journali\195\168re)\n"
				.. YELLOW .. "La ru\195\169e vers les oeufs de l'Aile-du-N\195\169ant (R\195\169p\195\169table)|r 250 rep",
		[9000] = "r\195\169p\195\169ter ces qu\195\170tes:\n\n"
				.. YELLOW .. "\195\170tre surveillant : savoir faire les bons choix|r 350 rep\n"
				.. YELLOW .. "Le botterang : un traitement pour les p\195\169ons bons \195\160 rien (Journali\195\168re)|r 350 rep\n"
				.. YELLOW .. "Ramasser les morceaux... (Journali\195\168re)|r 350 rep\n"
				.. YELLOW .. "Les dragons sont les derniers de nos soucis (Journali\195\168re)|r 350 rep\n"
				.. YELLOW .. "Affol\195\169s et perturb\195\169s|r 350 rep\n",
		[21000] = "r\195\169p\195\169ter ces qu\195\170tes:\n\n"
				.. YELLOW .. "Dominer le Dominateur|r 500 rep\n"
				.. YELLOW .. "Perturber la Porte du cr\195\169puscule (Journali\195\168re)|r 500 rep\n"
				.. YELLOW .. "Qu\195\170tes de course de drake: 500 chacune \navec 5 pour la 1\195\168re , et 1000 pour la 6\195\168me",
		[42000] = "r\195\169p\195\169ter cette qu\195\170te:\n\n"
				.. YELLOW .. "Le plus mortel des pi\195\168ges (Journali\195\168re) (groupe de 3)|r 500 rep"
	},
	[BF["Honor Hold"]] = {
		[9000] = "\n" 
				.. YELLOW .. "Qu\195\170tes de la p\195\169ninsule des flammes infernales\n"
				.. GREEN .. "Faire l'instance : Remparts des flammes infernales |r(Normal)\n"
				.. GREEN .. "Faire l'instance : La fournaise du sang |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Faire l'instance : Les salles bris\195\169es |r(Normal et H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : Remparts des flammes infernales |r(H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : La fournaise du sang |r(H\195\169roïque)"
	},
	[BF["Thrallmar"]] = {
		[9000] = "\n" 
				.. YELLOW .. "Qu\195\170tes de la p\195\169ninsule des flammes infernales\n"
				.. GREEN .. "Faire l'instance : Remparts des flammes infernales |r(Normal)\n"
				.. GREEN .. "Faire l'instance : La fournaise du sang |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Faire l'instance : Les salles bris\195\169es |r(Normal et H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : Remparts des flammes infernales |r(H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : La fournaise du sang |r(H\195\169roïque)"
	},
	[BF["Cenarion Expedition"]] = {
		[3000] = "\n" 
				.. WHITE .. "Tuer les Nagas Sombrecr\195\170te et Ecaille-sanglante (+5 rep)\n"
				.. YELLOW .. "Qu\195\170tes dans le Mar\195\169cage de Zangar\n"
				.. "Faire n'importe quelle instance du " .. GREEN .. "R\195\169servoir de Glissecroc|r\n\n"
				.. WHITE .. "Garder les [Morceaux de plantes non identifi\195\169es] pour passer honor\195\169",
		[9000] = "\n" 
				.. WHITE .. "Rendre les [Morceaux de plantes non identifi\195\169es] x240\n"
				.. YELLOW .. "Qu\195\170tes dans le Mar\195\169cage de Zangar\n"
				.. "Faire n'importe quelle instance du " .. GREEN .. "R\195\169servoir de Glissecroc|r",
		[42000] = "\n" 
				.. WHITE .. "Rendre les [Armes de Glissecroc] +75 rep\n\n"
				.. GREEN .. "Faire l'instance : Les enclos aux esclaves |r(Normal)\n"
				.. "Faire n'importe quelle instance du " .. GREEN .. "R\195\169servoir de Glissecroc|r (H\195\169roïque)"
	},
	[BF["Keepers of Time"]] = {
		[42000] = "\n" 
				.. "|rFaire les instances " .. GREEN .. "Les Contreforts d'Hautebrande d'antan|r et " .. GREEN .. "Le noir mar\195\169cage\n\n"
				.. YELLOW .. "Garder les qu\195\170tes pour le plus tard possible:\n s\195\169rie de qu\195\170tes du Hautebrande d'antan = 5000 rep\ns\195\169rie de qu\195\170tes du noir mar\195\169cage = 8000 rep"
	},
	[BF["The Sha'tar"]] = {
		[42000] = "\n" 
				.. GREEN .. "Faire l'instance : La Botanica |r(Normal et H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : Le Mechanar |r(Normal et H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : L'Arcatraz |r(Normal et H\195\169roïque)\n"
	}, 
	[BF["Lower City"]] = {
		[9000] = "\n" 
				.. WHITE .. "Rendre les [Plume d'Arakkoa] x30 (+250 rep)\n"
				.. GREEN .. "Faire l'instance : Labyrinthe des ombres |r(Normal)\n"
				.. GREEN .. "Faire l'instance : Cryptes Auchenai |r(Normal)\n"
				.. GREEN .. "Faire l'instance : Les salles de Sethekk |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Faire l'instance : Labyrinthe des ombres |r(Normal et H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : Cryptes Auchenai |r(H\195\169roïque)\n"
				.. GREEN .. "Faire l'instance : Les salles de Sethekk |r(H\195\169roïque)"
	}, 
	[BF["The Consortium"]] = {
		[3000] = "\n" 
				.. "|rRendre les [Fragment de cristal d'Oshu'gun] +250 rep\n"
				.. "Rendre les [Paire de d\195\169fenses d'ivoire] +250 rep\n\n"
				.. GREEN .. "Faire l'instance : Tombes-mana |r(Normal)",
		[9000] = "\n" 
				.. "|rRendre les [Perles de guerre d'obsidienne] +250 rep\n\n"
				.. GREEN .. "Faire l'instance : Tombes-mana |r(Normal)",
		[42000] = "\n" 
				.. "|rRendre les [Insigne de Zaxxis] +250 rep\n"
				.. "|rRendre les [Perles de guerre d'obsidienne] +250 rep\n\n"
				.. GREEN .. "Faire l'instance : Tombes-mana |r(H\195\169roïque)"
	}
}

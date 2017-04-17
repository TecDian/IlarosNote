----------------------------------------------------------------------------
-- IlarosNote
-- Modul für englische Texte
----------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("IlarosNote", "enUS", true)


L["IlarosNote"] = true

L["Enable IlarosNote"] = true
L["Enable or disable IlarosNote"] = true

L["Overall settings"] = true
L["Overall settings that affect every database"] = true
L["These settings control the look and feel of IlarosNote globally. The icon's scale and alpha here are multiplied with the plugin's scale and alpha."] = true
L["World Map Icon Scale"] = true
L["The overall scale of the icons on the World Map"] = true
L["World Map Icon Alpha"] = true
L["The overall alpha transparency of the icons on the World Map"] = true
L["Minimap Icon Scale"] = true
L["The overall scale of the icons on the Minimap"] = true
L["Minimap Icon Alpha"] = true
L["The overall alpha transparency of the icons on the Minimap"] = true

L["Plugins"] = true
L["Plugin databases"] = true
L["Configuration for each individual plugin database."] = true
L["Show the following plugins on the map"] = true

L["Add Handy Note"] = true
L["Edit Handy Note"] = true
L["Delete Handy Note"] = true
L["Title"] = true
L["Description/Notes:"] = true
L["Show on continent map"] = true
L["Add this location to Cartographer_Waypoints"] = true
L["Add this location to IlarosNavi waypoints"] = true
L["|cFF00FF00Hint: |cffeda55fCtrl+Shift+LeftDrag|cFF00FF00 to move a note"] = true

L["These settings control the look and feel of the IlarosNote icons."] = true
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true

L["\nAlt+Right Click To Add a IlarosNote"] = true
L["ERROR_CREATE_NOTE1"] = "IlarosNote cannot create a note here as it is unable to obtain your current location. Usually this is because there is no map for the zone you are in."

L["Portal"] = true
L["(No Title)"] = true

-- Modul IlarosNote_Flight
-- Tooltip descriptions on mouseover
L["Alliance FlightMaster"] = true
L["Horde FlightMaster"] = true
L["Neutral FlightMaster"] = true
L["Druid FlightMaster"] = true
L["PvP FlightMaster"] = true
L["Aldor FlightMaster"] = true
L["Scryer FlightMaster"] = true
L["Skyguard FlightMaster"] = true
L["Death Knight FlightMaster"] = true

-- Configuration menus
L["FlightMasters"] = true
L["These settings control the look and feel of the FlightMaster icons."] = true
L["FlightMaster Icons"] = true
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true
L["Show both factions"] = true
L["Show all flightmasters instead of only those that you can use"] = true
L["Show on continent maps"] = true
L["Show flightmasters on continent level maps as well"] = true
L["Flight path lines"] = true
L["Show flight path lines"] = true
L["Show flight path lines on the world map"] = true
L["Show in zones"] = true
L["Show flight path lines on the zone maps as well"] = true

-- Menu
L["IlarosNote - FlightMasters"] = true
L["Create waypoint"] = true

-- Modul IlarosNote_City
L["CityGuide"] = true
-- Optionsdialog
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true
L["These settings control the look and feel of the CityGuide icons."] = true
-- Optionenfilter
L["Filters"] = true
L["TYPE_Auctioneer"] = "Auctioneer"
L["TYPE_Banker"] = "Banker"
L["TYPE_BattleMaster"] = "Battle Master"
L["TYPE_StableMaster"] = "Stable Master"
L["TYPE_SpiritHealer"] = "Spirit Healer"
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - CityGuide"] = true   -- title for the right-click menu
L["Delete note"] = true
L["Create waypoint"] = true      -- only available with IlarosNavi or Cartoghrapher_Waypoints installed
L["Close"] = true

-- Modul IlarosNote_Death
L["Charon"] = "Deathblow"
L["Death"] = "Death"
L["Spirit Healer"] = "Spirit Healer"
L["Graveyard"] = "Graveyard"
-- Options dialog
L["These settings control the look and feel of the Deathblow icons."] = true
L["Spirit Healer icons"] = true
L["Death icons"] = true
-- Optionenfilter
L["Filters"] = true
L["World Map Filter"] = true
L["Minimap Filter"] = true
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Deathblow"] = true   -- title for the right-click menu
-- Death types
L["DEATH_ERROR"] = "Error"
L["DEATH_UNKNOWN"] = "Death"
L["DEATH_SWING"] = "Melee Death"
L["DEATH_RANGE"] = "Range Death"
L["DEATH_SPELL"] = "Spell Death"
L["DEATH_SPELL_PERIODIC"] = "Periodic Spell Death"
L["DEATH_ENVIRONMENTAL"] = "Environmental Death"
L["DEATH_ENVIRONMENTAL_DROWNING"] = "Drowned"
L["DEATH_ENVIRONMENTAL_FALLING"] = "Fallen to death"
L["DEATH_ENVIRONMENTAL_FATIGUE"] = "Drowned from fatigue"
L["DEATH_ENVIRONMENTAL_FIRE"] = "Burnt"
L["DEATH_ENVIRONMENTAL_LAVA"] = "Burnt in lava"
L["DEATH_ENVIRONMENTAL_SLIME"] = "Drowned in slime"

-- Modul IlarosNote_Mail
L["Mailbox"] = true
L["Mailboxes"] = true
-- Optionsdialog
L["These settings control the look and feel of the Mailbox icon."] = true
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Mailbox"] = true
L["Delete mailbox"] = true

-- Modul IlarosNote_Vendor
L["Vendor"] = true
L["Vendors"] = true
-- Optionsdialog
L["These settings control the look and feel of the Vendors icons."] = true
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Vendors"] = true   -- title for the right-click menu
L["Delete vendor"] = true
-- Optionenfilter
L["TYPE_Vendor"] = "Vendor"
L["TYPE_Repair"] = "Armorer"
L["TYPE_Innkeeper"] = "Innkeeper"

-- Modul IlarosNote_Trainer
L["Trainer"] = true
L["Trainers"] = true
-- Optionsdialog
L["These settings control the look and feel of the Trainers icons."] = true
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Trainers"] = true    -- title for the right-click menu
L["Delete trainer"] = true
-- Klassenlehrer
L["Deathknight Trainer"] = true
L["Deathknight Trainer - Female"] = "Deathknight Trainer"
L["Druid Trainer"] = true
L["Druid Trainer - Female"] = "Druid Trainer"
L["Hunter Trainer"] = true
L["Hunter Trainer - Female"] = "Hunter Trainer"
L["Mage Trainer"] = true
L["Mage Trainer - Female"] = "Mage Trainer"
L["Paladin Trainer"] = true
L["Paladin Trainer - Female"] = "Paladin Trainer"
L["Priest Trainer"] = true
L["Priest Trainer - Female"] = "Priest Trainer"
L["Rogue Trainer"] = true
L["Rogue Trainer - Female"] = "Rogue Trainer"
L["Shaman Trainer"] = true
L["Shaman Trainer - Female"] = "Shaman Trainer"
L["Warlock Trainer"] = true
L["Warlock Trainer - Female"] = "Warlock Trainer"
L["Warrior Trainer"] = true
L["Warrior Trainer - Female"] = "Warrior Trainer"
-- Berufslehrer Hauptberufe
L["Alchemy"]        = true
L["Blacksmithing"]  = true
L["Enchanting"]     = true
L["Engineering"]    = true
L["Inscription"]    = true
L["Jewelcrafting"]  = true
L["Leatherworking"] = true
L["Tailoring"]      = true
-- Berufslehrer Sammelberufe
L["Herbalism"]      = true
L["Mining"]         = true
L["Skinning"]       = true
-- Berufslehrer Nebenberufe
L["Cooking"]        = true
L["First Aid"]      = true
L["Fishing"]        = true
-- Lehrer Spezialfertigkeiten
L["Weapon Master"] = true
L["Weapon Master - Female"] = "Weapon Master"
L["Riding Trainer"] = true
L["Riding Trainer - Female"] = "Riding Trainer"
L["Cold Weather Flying Trainer"] = true   -- WoTLK
L["Cold Weather Flying Trainer - Female"] = "Cold Weather Flying Trainer"
L["Portal Trainer"] = true
L["Portal Trainer - Female"] = "Portal Trainer"
L["Pet Trainer"] = true
L["Pet Trainer - Female"] = "Pet Trainer"
-- Ungenutzt
L["Demon Trainer"] = true
-- Sonstige
L["Mechanostrider Pilot"] = true    -- Binjy Featherwhistle - Riding Trainer in Dun Morogh
L["Mechanostrider Pilot - Female"] = "Mechanostrider Pilot"
-- TODO: Berufslehrer Spezialisten
L["Goblin Engineering Trainer"] = true
L["Goblin Engineering Trainer - Female"] = "Goblin Engineering Trainer"

-- Modul IlarosNote_Guild
L["Guildmembers"] = "Guild members"

-- Modul IlarosNote_Direct
L["Directions"] = true
L["IlarosNote - Directions"] = "IlarosNote - Landmark"
L["These settings control the look and feel of the landmark icon."] = true
L["Delete landmark"] = true
L["Profession Trainer"] = true
L["A profession trainer"] = true
L["Class Trainer"] = true
L["A class trainer"] = true
L["Trainer: "] = true
L["Alliance Battlemasters"] = true
L[": Alliance"] = true
L["Horde Battlemasters"] = true
L[": Horde"] = true
L["To the east."] = true
L["To the west."] = true
L["The east."] = true
L["The west."] = true
L[": East"] = true
L[": West"] = true

    -- Chat-Benachrichtigungen
    NoteText_FName       = "|cffffff00IlarosNote for Tec's Ilaros WoW|r"
    NoteText_FVer        = "|cffffff00Version %s|r"
    -- Chat-Hilfetexte
    NoteText_SLASH  = "|cffff38ffIlarosNote Commands:|r"
    NoteText_VER    = "|cffffff78/Note v|r - Version information"
    NoteText_OPT    = "|cffffff78/Note k|r - Show configuration window"
    NoteText_NOTE1  = "|cffffff78/Note h|r - Add a note at current position"
    NoteText_NOTE2  = "|cffffff78/Note <x> <y>|r - Add a note at x,y"
    NoteText_USLASH = "|cffff1f1fThis command is unknown.|r"

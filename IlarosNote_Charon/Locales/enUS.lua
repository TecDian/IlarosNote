local L = LibStub("AceLocale-3.0"):NewLocale("IlarosNote_Charon", "enUS", true)
if not L then return end

-- Options dialog
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true
L["These settings control the look and feel of the Charon icons."] = true
L["Spirit Healer icons"] = true
L["Death icons"] = true

-- Options - Filters
L["Filters"] = true
L["World Map Filter"] = true
L["Minimap Filter"] = true

-- Right click menu on note on WorldMap
L["IlarosNote - Charon"] = true   -- title for the right-click menu
L["Delete note"] = true
L["Create waypoint"] = true      -- only available with IlarosNavi or Cartoghrapher_Waypoints installed
L["Close"] = true

-- Currently unused
L["Charon"] = true

-- General Notes
L["Death"] = "Death"
L["Spirit Healer"] = "Spirit Healer"
L["Graveyard"] = "Graveyard"

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

-- These are NPC "guilds"
-- no guild names currently needed
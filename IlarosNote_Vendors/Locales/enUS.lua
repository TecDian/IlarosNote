local L = LibStub("AceLocale-3.0"):NewLocale("IlarosNote_Vendors", "enUS", true)
if not L then return end

-- Options dialog
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true
L["These settings control the look and feel of the Vendors icons."] = true

-- Options - Filters
L["Filters"] = true
L["World Map Filter"] = true
L["Minimap Filter"] = true
L["TYPE_Vendor"] = "Vendor"
L["TYPE_Repair"] = "Armorer"
L["TYPE_Innkeeper"] = "Innkeeper"

-- Right click menu on note on WorldMap
L["IlarosNote - Vendors"] = true   -- title for the right-click menu
L["Delete vendor"] = true
L["Create waypoint"] = true      -- only available with IlarosNavi or Cartoghrapher_Waypoints installed
L["Close"] = true

-- Currently unused
L["Vendor"] = true

-- These are NPC "guilds"
-- no guild names currently needed
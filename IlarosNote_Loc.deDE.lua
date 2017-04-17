----------------------------------------------------------------------------
-- IlarosNote
-- Modul für deutsche Texte
----------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("IlarosNote", "deDE")
if not L then return end

L["Add Handy Note"] = "Notiz hinzufügen"
L["Add this location to Cartographer_Waypoints"] = "Wegpunkt erstellen"
L["Add this location to IlarosNavi waypoints"] = "Wegpunkt erstellen"
L[ [=[
Alt+Right Click To Add a IlarosNote]=] ] = [=[
Alt+Rechtsklick um ein IlarosNote hinzuzufügen]=]
L["|cFF00FF00Hint: |cffeda55fCtrl+Shift+LeftDrag|cFF00FF00 to move a note"] = "|cFF00FF00Hinweis: |cffeda55fStrg+Shift+Linksklick,|cFF00FF00 um eine Notiz zu bewegen"
L["Configuration for each individual plugin database."] = "Konfiguration für jede Plugin Datenbank."
L["Delete Handy Note"] = "Notiz löschen"
L["Description/Notes:"] = "Beschreibung/Notizen:"
L["Edit Handy Note"] = "Notiz bearbeiten"
L["Enable IlarosNote"] = "IlarosNote aktivieren"
L["Enable or disable IlarosNote"] = "IlarosNote aktivieren oder deaktivieren"
L["ERROR_CREATE_NOTE1"] = "IlarosNote konnte hier keine Notiz erstellen, da es nicht möglich ist, deine momentane Position zu ermitteln. Gewöhnlich ist dies der Fall, wenn es keine Karte für die momentane Zone gibt."
L["IlarosNote"] = "Notizen"
L["Icon Alpha"] = "Symboltransparenz"
L["Icon Scale"] = "Symbolgröße"
L["Minimap Icon Alpha"] = "Transparenz der Minikartensymbole"
L["Minimap Icon Scale"] = "Größe der Minikartensymbole"
L["(No Title)"] = "(Kein Titel)"
L["Overall settings"] = "Allgemeine Einstellungen"
L["Overall settings that affect every database"] = "Allgemeine Einstellungen für jede Datenbank"
L["Plugin databases"] = "Plugin Datenbanken"
L["Plugins"] = "Plugins"
L["Portal"] = "Portal"
L["Show on continent map"] = "Auf Kontinentalkarte zeigen"
L["Show the following plugins on the map"] = "Zeige die folgenden Plugins auf der Karte"
L["The alpha transparency of the icons"] = "Die Transparenz der Symbole"
L["The overall alpha transparency of the icons on the Minimap"] = "Die allgemeine Transparenz der Symbole auf der Minikarte."
L["The overall alpha transparency of the icons on the World Map"] = "Die allgemeine Transparenz der Symbole auf der Weltkarte."
L["The overall scale of the icons on the Minimap"] = "Die allgemeine Größe der Symbole auf der Minikarte."
L["The overall scale of the icons on the World Map"] = "Die allgemeine Größe der Symbole auf der Weltkarte."
L["The scale of the icons"] = "Die Größe der Symbole"
L["These settings control the look and feel of IlarosNote globally. The icon's scale and alpha here are multiplied with the plugin's scale and alpha."] = "Diese Einstellungen legen das allgemeine Aussehen der IlarosNote fest. Die Größe und Transparenz der Symbole werden mit der Größe und Transparenz der Plugin Einstellungen multipliziert."
L["These settings control the look and feel of the IlarosNote icons."] = "Diese Einstellungen legen das Aussehen der IlarosNote Symbole fest."
L["Title"] = "Titel"
L["World Map Icon Alpha"] = "Transparenz der Weltkartensymbole"
L["World Map Icon Scale"] = "Größe der Weltkartensymbole"

-- Modul IlarosNote_Flight
L["Aldor FlightMaster"] = "Aldor-Flugmeister"
L["Alliance FlightMaster"] = "Allianz-Flugmeister"
L["Create waypoint"] = "Wegpunkt erstellen"
L["Druid FlightMaster"] = "Druiden-Flugmeister"
L["FlightMaster Icons"] = "Flugmeister-Symbole"
L["FlightMasters"] = "Flugmeister"
L["Flight path lines"] = "Fluglinien"
L["IlarosNote - FlightMasters"] = "IlarosNote - Flugmeister"
L["Horde FlightMaster"] = "Horde-Flugmeister"
L["Icon Alpha"] = "Symboltransparenz"
L["Icon Scale"] = "Symbolgröße"
L["Neutral FlightMaster"] = "Neutraler Flugmeister"
L["PvP FlightMaster"] = "PvP-Flugmeister"
L["Scryer FlightMaster"] = "Seher-Flugmeister"
L["Show all flightmasters instead of only those that you can use"] = "Zeigt alle Flugmeister, statt nur diejenigen, die Du benutzen kannst."
L["Show both factions"] = "Beide Fraktionen"
L["Show flightmasters on continent level maps as well"] = "Zeigt Flugmeister auch auf Kontinentkarten an."
L["Show flight path lines"] = "Fluglinien anzeigen"
L["Show flight path lines on the world map"] = "Zeigt Fluglinien auf der Weltkarte an."
L["Show flight path lines on the zone maps as well"] = "Zeigt Fluglinien auf der Zonenkarte an."
L["Show in zones"] = "In Zonen anzeigen"
L["Show on continent maps"] = "Auf Kontinentkarten"
L["Skyguard FlightMaster"] = "Himmelswache Flugmeister"
L["The alpha transparency of the icons"] = "Die Transparenz der Symbole."
L["The scale of the icons"] = "Die Größe der Symbole."
L["These settings control the look and feel of the FlightMaster icons."] = "Einstellungen für FlightMaster."

-- Modul IlarosNote_City
L["CityGuide"] = "Stadtführer"
-- Optionsdialog
L["Icon Scale"] = "Icon-Skalierung"
L["The scale of the icons"] = "Die Skalierung der Icons"
L["Icon Alpha"] = "Icon-Transparenz"
L["The alpha transparency of the icons"] = "Die Transparenz der Icons"
L["These settings control the look and feel of the CityGuide icons."] = "Diese Einstellungen steuern das Aussehen der Stadtführer-Icons."
-- Optionenfilter
L["Filters"] = "Was soll angezeigt werden?"
L["TYPE_Auctioneer"] = "Auktionator"
L["TYPE_Banker"] = "Bankier"
L["TYPE_BattleMaster"] = "Kampfmeister"
L["TYPE_SpiritHealer"] = "Geistheiler"
L["TYPE_StableMaster"] = "Stallmeister"
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - CityGuide"] = "IlarosNote - CityGuide"
L["Delete note"] = "Notiz löschen"
L["Create waypoint"] = "Wegpunkt erstellen"
L["Close"] = "Schließen"

-- Modul IlarosNote_Death
L["Charon"] = "Todesfall"
L["Death"] = "Tod"
L["Spirit Healer"] = "Geistheiler"
L["Graveyard"] = "Friedhof"
-- Optionsdialog
L["These settings control the look and feel of the Charon icons."] = "Diese Einstellungen steuern das Aussehen der Todesfall-Icons."
L["Spirit Healer icons"] = "Geistheiler-Icons"
L["Death icons"] = "Todes-Icons"
-- Optionenfilter
L["Filters"] = "Filter"
L["World Map Filter"] = "Weltkarten-Filter"
L["Minimap Filter"] = "Minikarten-Filter"
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Charon"] = "IlarosNote - Todesfall"   -- title for the right-click menu
-- Death types
L["DEATH_ERROR"] = "Fehler"
L["DEATH_UNKNOWN"] = "Tod"
L["DEATH_SWING"] = "Nahkampftod"
L["DEATH_RANGE"] = "Fernkampftod"
L["DEATH_SPELL"] = "Zaubertod"
L["DEATH_SPELL_PERIODIC"] = "Periodischer Zaubertod"
L["DEATH_ENVIRONMENTAL"] = "Umgebungstod"
L["DEATH_ENVIRONMENTAL_DROWNING"] = "Ertrunken"
L["DEATH_ENVIRONMENTAL_FALLING"] = "Zu Tode gestürzt"
L["DEATH_ENVIRONMENTAL_FATIGUE"] = "Ertrunken durch Ermüdung"
L["DEATH_ENVIRONMENTAL_FIRE"] = "Verbrannt"
L["DEATH_ENVIRONMENTAL_LAVA"] = "Verbrannt in Lava"
L["DEATH_ENVIRONMENTAL_SLIME"] = "Ertrunken in Schleim"

-- Modul IlarosNote_Mail
L["Mailbox"] = "Briefkasten"
L["Mailboxes"] = "Briefkästen"
-- Optionsdialog
L["These settings control the look and feel of the Mailbox icon."] = "Diese Einstellungen steuern das Aussehen der Briefkasten-Icons."
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Mailbox"] = "IlarosNote - Breifkasten"
L["Delete mailbox"] = "Breifkasten löschen"

-- Modul IlarosNote_Vendor
L["Vendor"] = "Händler"
L["Vendors"] = "Händler"
-- Optionsdialog
L["These settings control the look and feel of the Vendors icons."] = "Diese Einstellungungen steuern das Aussehen der Händler-Icons."
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Vendors"] = "IlarosNote - Händler"
L["Delete vendor"] = "Händler löschen"
-- Optionenfilter
L["TYPE_Innkeeper"] = "Gastwirt"
L["TYPE_Repair"] = "Ausrüster"
L["TYPE_Vendor"] = "Verkäufer"

-- Modul IlarosNote_Trainer
L["Trainer"] = "Lehrer"
L["Trainers"] = "Lehrer"
-- Optionsdialog
L["These settings control the look and feel of the Trainers icons."] = "Diese Einstellungungen steuern das Aussehen der Lehrer-Icons."
-- Kontextmenü an Notiz auf der Weltkarte
L["IlarosNote - Trainers"] = "IlarosNote - Lehrer"
L["Delete trainer"] = "Lehrer löschen"
-- Klassenlehrer
L["Deathknight Trainer"] = "Todesritterlehrer"
L["Deathknight Trainer - Female"] = "Todesritterlehrerin"
L["Druid Trainer"] = "Druidenlehrer"
L["Druid Trainer - Female"] = "Druidenlehrerin"
L["Hunter Trainer"] = "Jägerlehrer"
L["Hunter Trainer - Female"] = "Jägerlehrerin"
L["Warrior Trainer"] = "Kriegerlehrer"
L["Warrior Trainer - Female"] = "Kriegerlehrerin"
L["Mage Trainer"] = "Magierlehrer"
L["Mage Trainer - Female"] = "Magierlehrerin"
L["Paladin Trainer"] = "Paladinlehrer"
L["Paladin Trainer - Female"] = "Paladinlehrerin"
L["Priest Trainer"] = "Priesterlehrer"
L["Priest Trainer - Female"] = "Priesterlehrerin"
L["Rogue Trainer"] = "Schurkenlehrer"
L["Rogue Trainer - Female"] = "Schurkenlehrerin"
L["Shaman Trainer"] = "Schamanenlehrer"
L["Shaman Trainer - Female"] = "Schamanenlehrerin"
L["Warlock Trainer"] = "Hexenmeisterlehrer"
L["Warlock Trainer - Female"] = "Hexenmeisterlehrerin"
-- Berufslehrer Hauptberufe
L["Alchemy"] = "Alchimie"
L["Engineering"] = "Ingenieurskunst"
L["Blacksmithing"] = "Schmiedekunst"
L["Enchanting"] = "Verzauberkunst"
L["Inscription"] = "Inschriftenkunde"
L["Jewelcrafting"] = "Juwelenschleifen"
L["Leatherworking"] = "Lederverarbeitung"
L["Tailoring"] = "Schneiderei"
-- Berufslehrer Sammelberufe
L["Herbalism"] = "Kräuterkunde"
L["Mining"] = "Bergbau"
L["Skinning"] = "Kürschnerei"
-- Berufslehrer Nebenberufe
L["Cooking"] = "Kochkunst"
L["First Aid"] = "Erste Hilfe"
L["Fishing"] = "Angeln"
-- Lehrer Spezialfertigkeiten
L["Weapon Master"] = "Waffenmeister"
L["Weapon Master - Female"] = "Waffenmeisterin"
L["Riding Trainer"] = "Reitlehrer"
L["Riding Trainer - Female"] = "Reitlehrerin"
L["Cold Weather Flying Trainer"] = "Lehrer für Kaltwetterflug"
L["Cold Weather Flying Trainer - Female"] = "Lehrerin für Kaltwetterflug"
L["Portal Trainer"] = "Portallehrer"
L["Portal Trainer - Female"] = "Portallehrerin"
L["Pet Trainer"] = "Tierausbilder"
L["Pet Trainer - Female"] = "Tierausbilderin"
-- Ungenutzt
L["Demon Trainer"] = "Dämonenlehrer"
-- Sonstige
L["Mechanostrider Pilot"] = "Roboschreiterpilot"
L["Mechanostrider Pilot - Female"] = "Roboschreiterpilotin"
-- TODO: Berufslehrer Spezialisten
L["Goblin Engineering Trainer"] = "Gobliningenieurskunst"
L["Goblin Engineering Trainer - Female"] = "Gobliningenieurskunst"

-- Modul IlarosNote_Guild
L["Guildmembers"] = "Gildenmitglieder"

-- Modul IlarosNote_Direct
L["Directions"] = "Orientierungspunkte"
L["IlarosNote - Directions"] = "IlarosNote - Orientierungspunkt"
L["Delete landmark"] = "Orientierungpunkt löschen"
L["These settings control the look and feel of the landmark icon."] = "Diese Einstellungungen steuern das Aussehen der Orientierungspunkt-Icons."
L["Profession Trainer"] = "Berufslehrer"
L["A profession trainer"] = "Ein Berufslehrer"
L["Class Trainer"] = "Klassenlehrer"
L["A class trainer"] = "Ein Klassenlehrer"
L["Trainer: "] = "Lehrer"
L["Alliance Battlemasters"] = "Allianz-Kampfmeister"
L[": Alliance"] = ": Allianz"
L["Horde Battlemasters"] = "Horde-Kampfmeister"
L[": Horde"] = ": Horde"
L["To the east."] = "Nach Osten."
L["To the west."] = "Nach Westen."
L["The east."] = "Der Osten."
L["The west."] = "Der Westen"
L[": East"] = ": Ost"
L[": West"] = ": West"

if ( GetLocale() == "deDE" ) then
    -- Chat-Benachrichtigungen
    NoteText_FName  = "|cffffff00IlarosNote für Tec's Ilaros WoW|r"
    NoteText_FVer   = "|cffffff00Version %s|r"
    -- Chat-Hilfetexte
    NoteText_SLASH  = "|cffff38ffIlarosNote-Kommandos:|r"
    NoteText_VER    = "|cffffff78/Note v|r - Versionsinformation"
    NoteText_OPT    = "|cffffff78/Note k|r - Konfigurationsfenster öffnen"
    NoteText_NOTE1  = "|cffffff78/Note h|r - Notiz am aktuellen Ort erzeugen"
    NoteText_NOTE2  = "|cffffff78/Note <x> <y>|r - Notiz bei x,y erzeugen"
    NoteText_USLASH = "|cffff1f1fDieses Kommando ist unbekannt.|r"
end
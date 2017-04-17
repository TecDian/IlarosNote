----------------------------------------------------------------------------
-- IlarosNote
-- Modul für die Kartenpunkte
----------------------------------------------------------------------------

-- Modul-Deklaration
local IlarosNote = LibStub("AceAddon-3.0"):GetAddon("IlarosNote")
local HN = IlarosNote:NewModule("IlarosNote", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("IlarosNote", false)


---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local dbdata
local defaults = {
    global = {
        ["*"] = {},  -- ["mapFile"] = {[coord] = {note data}, [coord] = {note data}}
    },
    profile = {
        icon_scale         = 1.0,
        icon_alpha         = 1.0,
    },
}


---------------------------------------------------------
-- Localize some globals
local next = next
local wipe = wipe
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip


---------------------------------------------------------
-- Constants
-- An addon can replace this table or add to it directly, but keep in mind
-- notes are currently stored with the index number of the chosen icon.
HN.icons = {
    [1] = UnitPopupButtons.RAID_TARGET_1, -- Star
    [2] = UnitPopupButtons.RAID_TARGET_2, -- Circle
    [3] = UnitPopupButtons.RAID_TARGET_3, -- Diamond
    [4] = UnitPopupButtons.RAID_TARGET_4, -- Triangle
    [5] = UnitPopupButtons.RAID_TARGET_5, -- Moon
    [6] = UnitPopupButtons.RAID_TARGET_6, -- Square
    [7] = UnitPopupButtons.RAID_TARGET_7, -- Cross
    [8] = UnitPopupButtons.RAID_TARGET_8, -- Skull
    [9] = {text = MINIMAP_TRACKING_AUCTIONEER, icon = "Interface\\Minimap\\Tracking\\Auctioneer"},
    [10] = {text = MINIMAP_TRACKING_BANKER, icon = "Interface\\Minimap\\Tracking\\Banker"},
    [11] = {text = MINIMAP_TRACKING_BATTLEMASTER, icon = "Interface\\Minimap\\Tracking\\BattleMaster"},
    [12] = {text = MINIMAP_TRACKING_FLIGHTMASTER, icon = "Interface\\Minimap\\Tracking\\FlightMaster"},
    [13] = {text = MINIMAP_TRACKING_INNKEEPER, icon = "Interface\\Minimap\\Tracking\\Innkeeper"},
    [14] = {text = MINIMAP_TRACKING_MAILBOX, icon = "Interface\\Minimap\\Tracking\\Mailbox"},
    [15] = {text = MINIMAP_TRACKING_REPAIR, icon = "Interface\\Minimap\\Tracking\\Repair"},
    [16] = {text = MINIMAP_TRACKING_STABLEMASTER, icon = "Interface\\Minimap\\Tracking\\StableMaster"},
    [17] = {text = MINIMAP_TRACKING_TRAINER_CLASS, icon = "Interface\\Minimap\\Tracking\\Class"},
    [18] = {text = MINIMAP_TRACKING_TRAINER_PROFESSION, icon = "Interface\\Minimap\\Tracking\\Profession"},
    [19] = {text = MINIMAP_TRACKING_TRIVIAL_QUESTS, icon = "Interface\\Minimap\\Tracking\\TrivialQuests"},
    [20] = {text = MINIMAP_TRACKING_VENDOR_AMMO, icon = "Interface\\Minimap\\Tracking\\Ammunition"},
    [21] = {text = MINIMAP_TRACKING_VENDOR_FOOD, icon = "Interface\\Minimap\\Tracking\\Food"},
    [22] = {text = MINIMAP_TRACKING_VENDOR_POISON, icon = "Interface\\Minimap\\Tracking\\Poisons"},
    [23] = {text = MINIMAP_TRACKING_VENDOR_REAGENT, icon = "Interface\\Minimap\\Tracking\\Reagents"},
    [24] = {text = FACTION_ALLIANCE, icon = "Interface\\TargetingFrame\\UI-PVP-Alliance",
        tCoordLeft = 0.05, tCoordRight = 0.65, tCoordTop = 0, tCoordBottom = 0.6},
    [25] = {text = FACTION_HORDE, icon = "Interface\\TargetingFrame\\UI-PVP-Horde",
        tCoordLeft = 0.05, tCoordRight = 0.65, tCoordTop = 0, tCoordBottom = 0.6},
    [26] = {text = FACTION_STANDING_LABEL4, icon = "Interface\\TargetingFrame\\UI-PVP-FFA",
        tCoordLeft = 0.05, tCoordRight = 0.65, tCoordTop = 0, tCoordBottom = 0.6},
    [27] = {text = ARENA, icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon"},
    [28] = {text = L["Portal"], icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran"},
}


---------------------------------------------------------
-- Plugin Handlers to IlarosNote

local HNHandler = {}

function HNHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
    if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local title = dbdata[mapFile][coord].title
    local desc = dbdata[mapFile][coord].desc
    if title == "" and desc == "" then title = L["(No Title)"] end
    if title == "" and desc ~= "" then title = desc  desc = nil end
    tooltip:SetText(title)
    tooltip:AddLine(desc, nil, nil, nil, true)
    tooltip:Show()
end

function HNHandler:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local function deletePin(button, mapFile, coord)
    local HNEditFrame = HN.HNEditFrame
    if HNEditFrame.coord == coord and HNEditFrame.mapFile == mapFile then
        HNEditFrame:Hide()
    end
    dbdata[mapFile][coord] = nil
    HN:SendMessage("IlarosNote_NotifyUpdate", "IlarosNote")
end

local function editPin(button, mapFile, coord)
    local HNEditFrame = HN.HNEditFrame
    HNEditFrame.x, HNEditFrame.y = IlarosNote:getXY(coord)
    HNEditFrame.coord = coord
    HNEditFrame.mapFile = mapFile
    HNEditFrame.level = dbdata[mapFile][coord].level
    HN:FillDungeonLevelData()
    HNEditFrame:Hide() -- Hide first to trigger the OnShow handler
    HNEditFrame:Show()
end

local function addCartWaypoint(button, mapFile, coord)
    if Cartographer and Cartographer.HasModule and Cartographer:HasModule("Waypoints") and Cartographer:IsModuleActive("Waypoints") then
        local x, y = IlarosNote:getXY(coord)
        local cartCoordID = floor(x*10000 + 0.5) + floor(y*10000 + 0.5)*10001
        local BZR = LibStub("LibBabble-Zone-3.0"):GetReverseLookupTable()
        local zone = IlarosNote:GetCZToZone(IlarosNote:GetCZ(mapFile))
        if zone then
            Cartographer_Waypoints:AddRoutesWaypoint(BZR[zone], cartCoordID, dbdata[mapFile][coord].title)
        end
    end
end

local function addIlarosNaviWaypoint(button, mapFile, coord)
    if IlarosNavi then
        local c, z = IlarosNote:GetCZ(mapFile)
        local x, y = IlarosNote:getXY(coord)
        IlarosNavi:AddZWaypoint(c, z, x*100, y*100, dbdata[mapFile][coord].title, nil, true, true)
    end
end

do
    local isMoving = false
    local info = {}
    local clickedMapFile = nil
    local clickedZone = nil
    local function generateMenu(button, level)
        if (not level) then return end
        for k in pairs(info) do info[k] = nil end
        if (level == 1) then
            -- Create the title of the menu
            info.isTitle      = 1
            info.text         = L["IlarosNote"]
            info.notCheckable = 1
            local t = HN.icons[dbdata[clickedMapFile][clickedCoord].icon]
            info.icon         = t.icon
            info.tCoordLeft   = t.tCoordLeft
            info.tCoordRight  = t.tCoordRight
            info.tCoordTop    = t.tCoordTop
            info.tCoordBottom = t.tCoordBottom
            UIDropDownMenu_AddButton(info, level)

            -- Edit menu item
            info.disabled     = nil
            info.isTitle      = nil
            info.notCheckable = nil
            info.icon         = nil
            info.tCoordLeft   = nil
            info.tCoordRight  = nil
            info.tCoordTop    = nil
            info.tCoordBottom = nil
            info.text = L["Edit Handy Note"]
            info.icon = icon
            info.func = editPin
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)

            -- Delete menu item
            info.text = L["Delete Handy Note"]
            info.icon = icon
            info.func = deletePin
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)

            -- Cartographer_Waypoints menu item
            if Cartographer and Cartographer.HasModule and Cartographer:HasModule("Waypoints") and Cartographer:IsModuleActive("Waypoints") then
                if IlarosNote:GetCZToZone(IlarosNote:GetCZ(clickedMapFile)) then -- Only if this is in a mapzone
                    info.text = L["Add this location to Cartographer_Waypoints"]
                    info.icon = nil
                    info.func = addCartWaypoint
                    info.arg1 = clickedMapFile
                    info.arg2 = clickedCoord
                    UIDropDownMenu_AddButton(info, level)
                end
            end

            if IlarosNavi then
                info.text = L["Add this location to IlarosNavi waypoints"]
                info.icon = nil
                info.func = addIlarosNaviWaypoint
                info.arg1 = clickedMapFile
                info.arg2 = clickedCoord
                UIDropDownMenu_AddButton(info, level)
            end

            -- Close menu item
            info.text         = CLOSE
            info.icon         = nil
            info.func         = function() CloseDropDownMenus() end
            info.arg1         = nil
            info.arg2         = nil
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)

            -- Add the dragging hint
            info.isTitle      = 1
            info.func         = nil
            info.text         = L["|cFF00FF00Hint: |cffeda55fCtrl+Shift+LeftDrag|cFF00FF00 to move a note"]
            UIDropDownMenu_AddButton(info, level)
        end
    end
    local IlarosNote_IlarosNoteDropdownMenu = CreateFrame("Frame", "IlarosNote_IlarosNoteDropdownMenu")
    IlarosNote_IlarosNoteDropdownMenu.displayMode = "MENU"
    IlarosNote_IlarosNoteDropdownMenu.initialize = generateMenu

    function HNHandler:OnClick(button, down, mapFile, coord)
        if button == "RightButton" and not down then
            clickedMapFile = mapFile
            clickedCoord = coord
            ToggleDropDownMenu(1, nil, IlarosNote_IlarosNoteDropdownMenu, self, 0, 0)
        elseif button == "LeftButton" and down and IsControlKeyDown() and IsShiftKeyDown() then
            -- Only move if we're viewing the same map as the icon's map
            if mapFile == GetMapInfo() or mapFile == "World" or mapFile == "Cosmic" then
                isMoving = true
                self:StartMoving()
            end
        elseif isMoving and not down then
            isMoving = false
            self:StopMovingOrSizing()
            -- Get the new coordinate
            local x, y = self:GetCenter()
            x = (x - WorldMapButton:GetLeft()) / WorldMapButton:GetWidth()
            y = (WorldMapButton:GetTop() - y) / WorldMapButton:GetHeight()
            -- Move the button back into the map if it was dragged outside
            if x < 0.001 then x = 0.001 end
            if x > 0.999 then x = 0.999 end
            if y < 0.001 then y = 0.001 end
            if y > 0.999 then y = 0.999 end
            local newCoord = IlarosNote:getCoord(x, y)
            -- Search in 4 directions till we find an unused coord
            local count = 0
            local zoneData = dbdata[mapFile]
            while true do
                if not zoneData[newCoord + count] then
                    zoneData[newCoord + count] = zoneData[coord]
                    break
                elseif not zoneData[newCoord - count] then
                    zoneData[newCoord - count] = zoneData[coord]
                    break
                elseif not zoneData[newCoord + count * 10000] then
                    zoneData[newCoord + count*10000] = zoneData[coord]
                    break
                elseif not zoneData[newCoord - count * 10000] then
                    zoneData[newCoord - count*10000] = zoneData[coord]
                    break
                end
                count = count + 1
            end
            dbdata[mapFile][coord] = nil
            HN:SendMessage("IlarosNote_NotifyUpdate", "IlarosNote")
        end
    end
end

do
    local emptyTbl = {}
    local tablepool = setmetatable({}, {__mode = 'k'})
    local continentMapFile = {
        ["Kalimdor"]    = {[0] = "Kalimdor",    __index = Astrolabe.ContinentList[1]},
        ["Azeroth"]     = {[0] = "Azeroth",     __index = Astrolabe.ContinentList[2]},
        ["Expansion01"] = {[0] = "Expansion01", __index = Astrolabe.ContinentList[3]},
        ["Northrend"]   = {[0] = "Northrend",   __index = Astrolabe.ContinentList[4]},
    }
    for k, v in pairs(continentMapFile) do
        setmetatable(v, v)
    end

    -- This is a custom iterator we use to iterate over every node in a given zone
    local function iter(t, prestate)
        if not t then return end
        local data = t.data
        local level = t.L
        local state, value = next(data, prestate)
        if value then
            while value do -- Have we reached the end of this zone?
                -- Map has no dungeon levels or dungeon level matches
                if not value.level or level == 0 or level == value.level then
                    return state, nil, HN.icons[value.icon], db.icon_scale, db.icon_alpha
                end
                state, value = next(data, state) -- Get next data
            end
        end
        wipe(t)
        tablepool[t] = true
    end

    -- This is a funky custom iterator we use to iterate over every zone's nodes
    -- in a given continent + the continent itself
    local function iterCont(t, prestate)
        if not t then return end
        local zone = t.Z
        local mapFile = t.C[zone]
        local data = dbdata[mapFile]
        local state, value
        while mapFile do
            if data then -- Only if there is data for this zone
                state, value = next(data, prestate)
                while state do -- Have we reached the end of this zone?
                    if value.cont or zone == 0 then -- Show on continent?
                        return state, mapFile, HN.icons[value.icon], db.icon_scale, db.icon_alpha
                    end
                    state, value = next(data, state) -- Get next data
                end
            end
            -- Get next zone
            zone = zone + 1
            t.Z = zone
            mapFile = t.C[zone]
            data = dbdata[mapFile]
            prestate = nil
        end
        wipe(t)
        tablepool[t] = true
    end

    function HNHandler:GetNodes(mapFile, minimap, dungeonLevel)
        local C = continentMapFile[mapFile] -- Is this a continent?
        if C then
            local tbl = next(tablepool) or {}
            tablepool[tbl] = nil
            tbl.C = C
            tbl.Z = 0
            return iterCont, tbl, nil
        else -- It is a zone
            local tbl = next(tablepool) or {}
            tablepool[tbl] = nil
            tbl.data = dbdata[mapFile]
            tbl.L = dungeonLevel
            return iter, tbl, nil
        end
    end
end


---------------------------------------------------------
-- IlarosNote core

-- Hooked function on clicking the world map
-- button is guaranteed to be passed in with the WorldMapButton frame
function HN:WorldMapButton_OnClick(button, mouseButton, ...)
    if mouseButton == "RightButton" and IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown() then
        local C, Z, L = GetCurrentMapContinent(), GetCurrentMapZone(), GetCurrentMapDungeonLevel()
        local mapFile = GetMapInfo() or IlarosNote:GetMapFile(C, Z) -- Fallback for "Cosmic" and "World"

        -- Get the coordinate clicked on
        local x, y = GetCursorPosition()
        local scale = button:GetEffectiveScale()
        x = (x/scale - button:GetLeft()) / button:GetWidth()
        y = (button:GetTop() - y/scale) / button:GetHeight()
        local coord = IlarosNote:getCoord(x, y)
        x, y = IlarosNote:getXY(coord)

        -- Pass the data to the edit note frame
        local HNEditFrame = self.HNEditFrame
        HNEditFrame.x = x
        HNEditFrame.y = y
        HNEditFrame.coord = coord
        HNEditFrame.mapFile = mapFile
        HNEditFrame.level = L
        self:FillDungeonLevelData()
        HNEditFrame:Hide() -- Hide first to trigger the OnShow handler
        HNEditFrame:Show()
    else
        return self.hooks[button].OnMouseUp(button, mouseButton, ...)
    end
end

-- Function to create a note where the player is
function HN:CreateNoteHere(arg1)
    local c, z, x, y
    -- Parameter wurde übergeben, also auswerten
    if arg1 ~= "" then
        -- Parameter als Koordinaten behandeln
        x, y = string.match(strtrim(arg1), "([%d.]+)[, ]+([%d.]+)")
        x, y = tonumber(x), tonumber(y)
        if x and y and x > 1 and x < 100 and y > 1 and y < 100 then
            -- Normalize coordinates to between 0 and 1
            x, y = x/100, y/100
        end
        -- Parameter sind keine Koordinaten, dann als Befehl behandeln
        if not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1 then
            if (string.lower(arg1) == "h") then
                c, z, x, y = Astrolabe:GetCurrentPlayerPosition()
            elseif (string.lower(arg1) == "v") then
                DEFAULT_CHAT_FRAME:AddMessage(NoteText_FName, 1, 1, 1)
                DEFAULT_CHAT_FRAME:AddMessage(string.format(NaviText_FVer,GetAddOnMetadata("IlarosNote", "Version")), 1, 1, 1)
                return
            elseif (string.lower(arg1) == "k") then
                LibStub("AceConfigDialog-3.0"):Open("IlarosNote")
                return
            else
                DEFAULT_CHAT_FRAME:AddMessage(NoteText_USLASH, 1, 1, 1)
                return
            end
        -- Parameter sind Koordinaten, dann ergänzen
        else
            c, z = Astrolabe:GetCurrentPlayerPosition()
        end
    -- kein Parameter wurde übergeben, also Kommandos auflisten
    else
        DEFAULT_CHAT_FRAME:AddMessage(NoteText_SLASH, 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage(NoteText_VER, 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage(NoteText_OPT, 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage(NoteText_NOTE1, 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage(NoteText_NOTE2, 1, 1, 1)
        return
    end

    if c and z and x and y then
        local coord = IlarosNote:getCoord(x, y)
        x, y = IlarosNote:getXY(coord)

        -- Pass the data to the edit note frame
        local HNEditFrame = self.HNEditFrame
        HNEditFrame.x = x
        HNEditFrame.y = y
        HNEditFrame.coord = coord
        HNEditFrame.mapFile = GetMapInfo() or IlarosNote:GetMapFile(c, z) -- Fallback for "Cosmic" and "World"
        HNEditFrame.level = GetCurrentMapDungeonLevel()
        self:FillDungeonLevelData()
        HNEditFrame:Hide() -- Hide first to trigger the OnShow handler
        HNEditFrame:Show()
    else
        self:Print(L["ERROR_CREATE_NOTE1"])
    end
end

function HN:FillDungeonLevelData()
    wipe(HNEditFrame.leveldata)
    local mapname = strupper(GetMapInfo() or "")
    local usesTerrainMap = DungeonUsesTerrainMap() and 1 or 0
    for i= 1, GetNumDungeonMapLevels() do
        local floorNum = i - usesTerrainMap
        local floorname =_G["DUNGEON_FLOOR_" .. mapname .. floorNum]
        HNEditFrame.leveldata[i] = floorname or string.format(FLOOR_NUMBER, i)
    end
end


---------------------------------------------------------
-- Options table
local options = {
    type = "group",
    name = L["IlarosNote"],
    desc = L["IlarosNote"],
    get = function(info) return db[info.arg] end,
    set = function(info, v)
        db[info.arg] = v
        HN:SendMessage("IlarosNote_NotifyUpdate", "IlarosNote")
    end,
    args = {
        desc = {
            name = L["These settings control the look and feel of the IlarosNote icons."],
            type = "description",
            order = 0,
        },
        icon_scale = {
            type = "range",
            name = L["Icon Scale"],
            desc = L["The scale of the icons"],
            min = 0.25, max = 2, step = 0.01,
            arg = "icon_scale",
            order = 10,
        },
        icon_alpha = {
            type = "range",
            name = L["Icon Alpha"],
            desc = L["The alpha transparency of the icons"],
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha",
            order = 20,
        },
    },
}


---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HN:OnInitialize()
    -- Set up our database
    self.db = LibStub("AceDB-3.0"):New("NoteMarks", defaults)
    db = self.db.profile
    dbdata = self.db.global

    -- Initialize our database with IlarosNote
    IlarosNote:RegisterPluginDB("IlarosNote", HNHandler, options)

    WorldMapMagnifyingGlassButton:SetText(WorldMapMagnifyingGlassButton:GetText() .. L["\nAlt+Right Click To Add a IlarosNote"])

    -- Slash command
    self:RegisterChatCommand("note", "CreateNoteHere")
end

function HN:OnEnable()
    self:RawHookScript(WorldMapButton, "OnMouseUp", "WorldMapButton_OnClick")
end

function HN:OnDisable()
end


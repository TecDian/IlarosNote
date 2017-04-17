----------------------------------------------------------------------------
-- IlarosNote
-- Modul für Orientierungspunkte in Städten
----------------------------------------------------------------------------

-- Modul-Deklaration
IlarosNote_Direct = LibStub("AceAddon-3.0"):NewAddon("IlarosNote_Direct","AceEvent-3.0","AceHook-3.0")
local HD = IlarosNote_Direct
local IlarosNote = LibStub("AceAddon-3.0"):GetAddon("IlarosNote")
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("IlarosNote", true)

---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
    global = {
        landmarks = {
            ["*"] = {},  -- [mapFile] = {[coord] = "name", [coord] = "name"}
        },
    },
    profile = {
        icon_scale         = 1.0,
        icon_alpha         = 1.0,
    },
}

---------------------------------------------------------
-- Localize some globals
local next = next
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local IlarosNote = IlarosNote

---------------------------------------------------------
-- Constants

local function setupLandmarkIcon(texture, left, right, top, bottom)
    return {
        icon = texture,
        tCoordLeft = left,
        tCoordRight = right,
        tCoordTop = top,
        tCoordBottom = bottom,
    }
end

local icon = setupLandmarkIcon([[Interface\Minimap\POIIcons]], WorldMap_GetPOITextureCoords(7)) -- the cute lil' flag

---------------------------------------------------------
-- Plugin Handlers to IlarosNote
local HDHandler = {}
local info = {}
local clickedLandmark = nil
local clickedLandmarkZone = nil
local lastGossip = nil

function HDHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
    if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    tooltip:SetText(HD.db.global.landmarks[mapFile][coord])
    tooltip:Show()
    clickedLandmark = nil
    clickedLandmarkZone = nil
end

local function deletePin(button, mapFile, coord)
    HD.db.global.landmarks[mapFile][coord] = nil
    HD:SendMessage("IlarosNote_NotifyUpdate", "Directions")
end

local function createWaypoint(button, mapFile, coord)
    local c, z = IlarosNote:GetCZ(mapFile)
    local x, y = IlarosNote:getXY(coord)
    local name = HD.db.global.landmarks[mapFile][coord]
    if IlarosNavi then
        local persistent, minimap, world
        if temporary then
            persistent = true
            minimap = false
            world = false
        end
        IlarosNavi:AddZWaypoint(c, z, x*100, y*100, name, persistent, minimap, world)
    elseif Cartographer_Waypoints then
        Cartographer_Waypoints:AddWaypoint(NotePoint:new(IlarosNote:GetCZToZone(c, z), x, y, name))
    end
end

local function generateMenu(button, level)
    if (not level) then return end
    for k in pairs(info) do info[k] = nil end
    if (level == 1) then
        -- Create the title of the menu
        info.isTitle      = 1
        info.text         = L["IlarosNote - Directions"]
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        if IlarosNavi or Cartographer_Waypoints then
            -- Waypoint menu item
            info.disabled     = nil
            info.isTitle      = nil
            info.notCheckable = nil
            info.text = L["Create waypoint"]
            info.icon = nil
            info.func = createWaypoint
            info.arg1 = clickedLandmarkZone
            info.arg2 = clickedLandmark
            UIDropDownMenu_AddButton(info, level);
        end

        -- Delete menu item
        info.disabled     = nil
        info.isTitle      = nil
        info.notCheckable = nil
        info.text = L["Delete landmark"]
        info.icon = icon
        info.func = deletePin
        info.arg1 = clickedLandmarkZone
        info.arg2 = clickedLandmark
        UIDropDownMenu_AddButton(info, level);

        -- Close menu item
        info.text         = L["Close"]
        info.icon         = nil
        info.func         = function() CloseDropDownMenus() end
        info.arg1         = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level);
    end
end
local HD_Dropdown = CreateFrame("Frame", "IlarosNote_DirectDropdownMenu")
HD_Dropdown.displayMode = "MENU"
HD_Dropdown.initialize = generateMenu

function HDHandler:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and not down then
        clickedLandmarkZone = mapFile
        clickedLandmark = coord
        ToggleDropDownMenu(1, nil, HD_Dropdown, self, 0, 0)
    end
end

function HDHandler:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

do
    -- This is a custom iterator we use to iterate over every node in a given zone
    local function iter(t, prestate)
        if not t then return nil end
        local state, value = next(t, prestate)
        while state do -- Have we reached the end of this zone?
            if value then
                return state, nil, icon, db.icon_scale, db.icon_alpha
            end
            state, value = next(t, state) -- Get next data
        end
        return nil, nil, nil, nil
    end
    function HDHandler:GetNodes(mapFile)
        return iter, HD.db.global.landmarks[mapFile], nil
    end
end


---------------------------------------------------------
-- Core functions

local alreadyAdded = {}
function HD:CheckForLandmarks()
    if not lastGossip then return end
    for mark = 1, GetNumMapLandmarks(), 1 do
        local name, _, tex, x, y = GetMapLandmarkInfo(mark)
        if tex == 7 and not alreadyAdded[name] then
            alreadyAdded[name] = true
            self:AddLandmark(x, y, lastGossip)
        end
    end
end

function HD:AddLandmark(x, y, name)
    local c,z = Astrolabe:GetCurrentPlayerPosition()
    if not c then return end
    local loc = IlarosNote:getCoord(x, y)
    local mapFile = IlarosNote:GetMapFile(c, z)
    if not mapFile then return end
    for coord,value in pairs(self.db.global.landmarks[mapFile]) do
        if value and value:match("^"..name) then
            return
        end
    end
    self.db.global.landmarks[mapFile][loc] = name
    self:SendMessage("IlarosNote_NotifyUpdate", "Directions")
    createWaypoint(nil, mapFile, loc)
end

local replacements = {
    [L["A profession trainer"]] = L["Trainer: "],
    [L["Profession Trainer"]] = L["Trainer: "],
    [L["A class trainer"]] = L["Trainer: "],
    [L["Class Trainer"]] = L["Trainer: "],
    [L["Alliance Battlemasters"]] = L[": Alliance"],
    [L["Horde Battlemasters"]] = L[": Horde"],
    [L["To the east."]] = L[": East"],
    [L["To the west."]] = L[": West"],
    [L["The east."]] = L[": East"],
    [L["The west."]] = L[": West"],
}
function HD:SelectGossipOption(index, ...)
    local selected = select((index * 2) - 1, GetGossipOptions())
    if not selected then return end
    if replacements[selected] then selected = replacements[selected] end
    if lastGossip then
        lastGossip = lastGossip .. selected
    else
        lastGossip = selected
    end
end

function HD:GOSSIP_CLOSED()
    lastGossip = nil
end

---------------------------------------------------------
-- Options table
local options = {
    type = "group",
    name = L["Directions"],
    desc = L["Directions"],
    get = function(info) return db[info.arg] end,
    set = function(info, v)
        db[info.arg] = v
        HD:SendMessage("IlarosNote_NotifyUpdate", "Directions")
    end,
    args = {
        desc = {
            name = L["These settings control the look and feel of the landmark icon."],
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

function HD:OnInitialize()
    -- Set up our database
    self.db = LibStub("AceDB-3.0"):New("NoteDirects", defaults)
    db = self.db.profile
    -- Initialize our database with IlarosNote
    IlarosNote:RegisterPluginDB("Directions", HDHandler, options)
end

function HD:OnEnable()
    self:RegisterEvent("WORLD_MAP_UPDATE", "CheckForLandmarks")
    self:RegisterEvent("GOSSIP_CLOSED")
    self:Hook("SelectGossipOption", true)
end


----------------------------------------------------------------------------
-- IlarosNote
-- Modul für Todesfälle und Geistheiler
----------------------------------------------------------------------------
--[[
TODO:
    - Icons
        http://wowcompares.com/03010805/FrameXML/WorldMapFrame.lua
        QUEST_ICON_TEXTURES[QUEST_ICON_KILL]                = "Interface\\WorldMap\\Skull_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_KILL_COLLECT]        = "Interface\\WorldMap\\GlowSkull_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_INTERACT]            = "Interface\\WorldMap\\Gear_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_TURN_IN]             = "Interface\\WorldMap\\QuestionMark_Gold_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_CHAT]                = "Interface\\WorldMap\\ChatBubble_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_X_MARK]              = "Interface\\WorldMap\\X_Mark_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_BIG_SKULL]           = "Interface\\WorldMap\\3DSkull_64"
        QUEST_ICON_TEXTURES[QUEST_ICON_BIG_SKULL_GEAR]      = "Interface\\WorldMap\\SkullGear_64"
    - Icon colors
    - Filters
    - Global death point to detect Graveyard influence area
    - Log monster
        - level,
        - type (Beast, Demon, ...),
        - class for Humanoids (paladin, rogue, ...)
        - rarity (normal, elite, boss, rare, rare-elite)
        - standing (friend, neutral, enemy)
    - Log Player state on death? (items, buffs, ...)
    - use Damage SourceFlags and try to determine if it was PVP or PVE
]]
---------------------------------------------------------
-- Addon declaration
IlarosNote_Death = LibStub("AceAddon-3.0"):NewAddon("IlarosNote_Death","AceEvent-3.0", "AceTimer-3.0")
local HC = IlarosNote_Death
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("IlarosNote")
local G = {}

---------------------------------------------------------
-- Our db upvalue and db defaults
local CURRENT_DB_VERSION = 2
local db
local CharDB

local defaults = {
    profile = {
        icon_scale = 1.0,
        icon_alpha = 1.0,
        filter = { ["*"] = true },
    },
    factionrealm = {
        dbversion = 0,
        nodes = {
            ["*"] = {},
        }
    },
}

---------------------------------------------------------
-- Localize some globals
local next = next
local select = select
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local IlarosNote = IlarosNote

local time = time

local strsub = strsub
local strsplit = strsplit
local strjoin = strjoin

local bit_and = bit.band
local bit_or = bit.bor

---------------------------------------------------------
-- Constants
local iconpath = "Interface\\AddOns\\IlarosNote\\images\\"


local defkey = {}
local iconDB = {
    ["M"] = iconpath .. "death",       -- Melee Death
    ["R"] = iconpath .. "death",       -- Range Death
    ["S"] = iconpath .. "death",       -- Spell Death
    ["P"] = iconpath .. "death",       -- Periodic Spell Death
    ["E"] = iconpath .. "death",       -- Environment Death

    ["H"] = iconpath .. "graveyard", -- SpiritHealer

    -- Default
    [defkey] = "Interface\\Minimap\\Tracking\\TrivialQuests", -- for DB errors??
        }

setmetatable(iconDB, {__index = function (t, k)
                    local v = t[defkey]
                    rawset(t, k, v) -- cache the value for next retrievals
                    return v
                end})

local EnvirnmentsTable = {
    ["DROWNING"] = L["DEATH_ENVIRONMENTAL_DROWNING"],
    ["FALLING"] = L["DEATH_ENVIRONMENTAL_FALLING"],
    ["FATIGUE"] = L["DEATH_ENVIRONMENTAL_FATIGUE"],
    ["FIRE"] = L["DEATH_ENVIRONMENTAL_FIRE"],
    ["LAVA"] = L["DEATH_ENVIRONMENTAL_LAVA"],
    ["SLIME"] = L["DEATH_ENVIRONMENTAL_SLIME"],
}

---------------------------------------------------------
-- Plugin Handlers to IlarosNote

local HCHandler = {}

local function deletePin(button, type_mapFile, coord)
    local type, mapFile = strsplit(":", type_mapFile)
    local x, y = IlarosNote:getXY(coord)

    if type == "char" then
        if CharDB.nodes[mapFile] then
            CharDB.nodes[mapFile][coord] = nil
        end
    elseif type == "factionrealm" then
        db.factionrealm.nodes[mapFile][coord] = nil
    else
        return
    end

    HC:SendMessage("IlarosNote_NotifyUpdate", "Charon")
end
local function createWaypoint(button, type_mapFile, coord)
    local type, mapFile = strsplit(":", type_mapFile)
    local c, z = IlarosNote:GetCZ(mapFile)
    local x, y = IlarosNote:getXY(coord)

    local vdata
    if type == "char" then
        if CharDB.nodes[mapFile] then
            vdata = CharDB.nodes[mapFile][coord]
        end
    elseif type == "factionrealm" then
        vdata = db.factionrealm.nodes[mapFile][coord]
    else
        return
    end

    if not vdata then
        return
    end

    local vType, vTime, vMonster, vSPCoord = strsplit(":", vdata)
    local vName = L["DEATH_ERROR"]
    if (vType == "H") then
        vName = L["Spirit Healer"]
    else
        if vMonster then
            vName = "Death by " .. vMonster
        else
            vName = "Death"
        end
    end

    if IlarosNavi then
        IlarosNavi:AddZWaypoint(c, z, x*100, y*100, vName)
    elseif Cartographer_Waypoints then
        Cartographer_Waypoints:AddWaypoint(NotePoint:new(IlarosNote:GetCZToZone(c, z), x, y, vName))
    end
end

local clickedNoteCoord, clickedNoteZone, clickedNoteType

local info = {}
local function generateMenu(button, level)
    if (not level) then return end
    for k in pairs(info) do info[k] = nil end
    if (level == 1) then
        -- Create the title of the menu
        info.isTitle      = 1
        info.text         = L["IlarosNote - Charon"]
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
            info.arg1 = clickedNoteType .. ":" .. clickedNoteZone
            info.arg2 = clickedNoteCoord
            UIDropDownMenu_AddButton(info, level);
        end

        -- Delete menu item
        info.disabled     = nil
        info.isTitle      = nil
        info.notCheckable = nil
        info.text = L["Delete note"]
        info.icon = nil
        info.func = deletePin
        info.arg1 = clickedNoteType .. ":" .. clickedNoteZone
        info.arg2 = clickedNoteCoord
        UIDropDownMenu_AddButton(info, level);

        -- Close menu item
        info.text         = L["Close"]
        info.icon         = nil
        info.func         = function() CloseDropDownMenus() end
        info.arg1         = nil
        info.arg2         = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level);
    end
end

local HC_Dropdown = CreateFrame("Frame", "IlarosNote_DeathDropdownMenu")
HC_Dropdown.displayMode = "MENU"
HC_Dropdown.initialize = generateMenu

function HCHandler:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and not down then
        if CharDB.nodes[mapFile] and CharDB.nodes[mapFile][coord] then
            clickedNoteType = "char"
        elseif db.factionrealm.nodes[mapFile][coord] then
            clickedNoteType = "factionrealm"
        else
            return
        end
        clickedNoteZone = mapFile
        clickedNoteCoord = coord
        ToggleDropDownMenu(1, nil, HC_Dropdown, self, 0, 0)
    end
end


---------------------------------------------------------
-- Line drawing helper functions

-- Function to get the intersection point of 2 lines (x1,y1)-(x2,y2) and (sx,sy)-(ex,ey)
-- If there is no intersection point, it returns (x2, y2)
local function GetIntersection(x1, y1, x2, y2, sx, sy, ex, ey)
    local dx = x2-x1
    local dy = y2-y1
    local numer = dx*(sy-y1) - dy*(sx-x1)
    local demon = dx*(sy-ey) + dy*(ex-sx)
    if demon ~= 0 and dx ~= 0 then
        local u = numer / demon
        local t = (sx + (ex-sx)*u - x1)/dx
        if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
            return sx + (ex-sx)*u, sy + (ey-sy)*u --return true
        end
    end
    return x2, y2 --return false
end

-- Function to draw a line between 2 coordinates on map (C,Z)
-- (x1,y1) is already translated to map (C,Z)
local function drawline(C, Z, x1, y1, x2, y2, color)
    --local x2, y2 = IlarosNote:getXY(coord2)
    x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 0, 0, 1)
    x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 0, 1, 0)
    x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 1, 1, 1)
    x2, y2 = GetIntersection(x1, y1, x2, y2, 1, 0, 1, 1)
    local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
    if (x1 == x2) and (y1 == y2) then
        return
    end
    G:DrawLine(WorldMapButton, x1*w, (1-y1)*h, x2*w, (1-y2)*h, 25, color, "OVERLAY")
end


function HCHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
    if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local data
    local dbg1
    if CharDB.nodes[mapFile] and CharDB.nodes[mapFile][coord] then
        data = CharDB.nodes[mapFile][coord]
        dbg1 = "NoteDeaths"
    elseif db.factionrealm.nodes[mapFile][coord] then
        data = db.factionrealm.nodes[mapFile][coord]
        dbg1 = "factionrealm"
    else
        return
    end

    local vType, vTime, vMonster, vSPCoord = strsplit(":", data)
    local vName = L["DEATH_ERROR"]
    local vDate = ""

    if vType == "H" then
        vName = L["Spirit Healer"]
    elseif vType == "M" then
        vName = L["DEATH_SWING"]
        vDate = date("%c", vTime)
    elseif vType == "R" then
        vName = L["DEATH_RANGE"]
        vDate = date("%c", vTime)
    elseif vType == "S" then
        vName = L["DEATH_SPELL"]
        vDate = date("%c", vTime)
    elseif vType == "P" then
        vName = L["DEATH_SPELL_PERIODIC"]
        vDate = date("%c", vTime)
    elseif vType == "E" then
        vName = L["DEATH_ENVIRONMENTAL"]
        vDate = date("%c", vTime)
        if vMonster then
            vMonster = EnvirnmentsTable[vMonster]
        end
    elseif vType == "U" then
        vName = L["DEATH_UNKNOWN"]
        vDate = date("%c", vTime)
    end

    tooltip:AddLine("|cffe0e0e0"..vName.."|r")
    if vDate and (vDate ~= "") then tooltip:AddLine(vDate) end
    if vMonster and (vMonster ~= "") then tooltip:AddLine(vMonster) end
    if self:GetParent() == WorldMapButton then
        if vSPCoord and (vSPCoord ~= "") then
            local x1, y1 = IlarosNote:getXY(coord)
            local x2, y2 = IlarosNote:getXY(vSPCoord)
            if IsShiftKeyDown() then
                tooltip:AddLine(format("%.1f, %.1f -> %.1f, %.1f", x1 * 100, y1 * 100, x2 * 100, y2 * 100))
            end

            local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()
            drawline(C, Z, x1, y1, x2, y2, {0, 0.5, 0, 1})
        end
    end
    if IsShiftKeyDown() and IsControlKeyDown() then
        tooltip:AddLine("Debug:")
        tooltip:AddLine(dbg1)
        tooltip:AddLine(mapFile .. ": " .. coord)
        tooltip:AddLine(data)
    end

--  tooltip:AddLine(L["Charon"])
    tooltip:Show()
end

function HCHandler:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
        G:HideLines(WorldMapButton)
    else
        GameTooltip:Hide()
    end
end

do
    -- This is a custom iterator we use to iterate over every node in a given zone
    local function multiiter(lparam, oldcoord)
        if not lparam then return nil end

        if not lparam.current then
            lparam.current = next(lparam.tables, lparam.current)
        end

        local coord, value = oldcoord, nil
        while lparam.current do
            local t = lparam.tables[lparam.current]
            coord, value = next(t, coord)
            while coord do
                if value then
                    --local vType = strsplit(":", value)
                    local vType = strsub(value, 1, 1)
                    if db.profile.filter[vType] then
                        local icon = iconDB[vType]
                        local scale = db.profile.icon_scale
                        if vType ~= "H" then -- deaths smaller
                            scale = scale * 0.75
                        end
                        return coord, nil, icon, scale, db.profile.icon_alpha
                    end
                end
                coord, value = next(t, coord)
            end
            lparam.current = next(lparam.tables, lparam.current)
        end
        return nil, nil, nil, nil
    end

    local lparam = {
        tables = { [0] = nil, [1] = nil },
        current = nil
    }
    local EmptyTab = {}
    function HCHandler:GetNodes(mapFile)
        --print("GetNodes()")
        --local lparam = {}
        --lparam.tables = {db.factionrealm.nodes[mapFile], CharDB.nodes[mapFile]}
        lparam.tables[0] = db.factionrealm.nodes[mapFile]
        lparam.tables[1] = CharDB.nodes[mapFile] or EmptyTab
        lparam.current = nil
        return multiiter, lparam, nil
    end
end


local function GetVFilters()
    local vnds = {
        }

    local res = {}
    for id, text in pairs(vnds) do
        res[id] = "|T"..iconDB[id]..":18|t "..text
    end
    return res
end

---------------------------------------------------------
-- Options table

local options = {
    type = "group",
    name = L["Charon"],
    desc = L["Charon"],
    get = function(info) return db.profile[info.arg] end,
    set = function(info, v)
        db.profile[info.arg] = v
        HC:SendMessage("IlarosNote_NotifyUpdate", "Charon")
    end,
    args = {
        desc = {
            name = L["These settings control the look and feel of the Charon icons."],
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
--[[        filters = {
            type = "multiselect",
            name = L["Filters"],
            desc = nil,
            order = 30,
            width = "full",
            get = function(info, k) return db.profile.filter[k] end,
            set = function(info, k, v)
                db.profile.filter[k] = v
                HC:SendMessage("IlarosNote_NotifyUpdate", "Charon")
            end,
            values = GetVFilters(),

        }, ]]
    },
}


---------------------------------------------------------
-- NPC info tracking - TT handling

local tt = CreateFrame("GameTooltip")
tt:SetOwner(UIParent, "ANCHOR_NONE")
tt.left = {}
tt.right = {}

for i = 1, 30 do
    tt.left[i] = tt:CreateFontString()
    tt.left[i]:SetFontObject(GameFontNormal)
    tt.right[i] = tt:CreateFontString()
    tt.right[i]:SetFontObject(GameFontNormal)
    tt:AddFontStrings(tt.left[i], tt.right[i])
end


local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local function FigureNPCGuild(unit)
    tt:ClearLines()
    tt:SetUnit(unit)
    if not tt:IsOwned(UIParent) then
        tt:SetOwner(UIParent, "ANCHOR_NONE")
    end
    local left_2 = tt.left[2]:GetText()
    if not left_2 or left_2:find(LEVEL_start) then
        return ""
    end
    return left_2
end

---------------------------------------------------------
-- Addon initialization, enabling and disabling


--local Sthres = 25 -- Spirit Healer threshold in yards
--local Cthres = 5 -- Corpse threshold in yards
--local time = time;

local STATE_NONE = -1
local STATE_ALIVE = 0
local STATE_DEAD = 1
local STATE_GHOST = 2

local QUALITY_NONE = 0
local QUALITY_LOC = 1 -- from player position
local QUALITY_DAT = 2 -- from already captured data (Spirit Healer only)
local QUALITY_API = 7 -- from its respective API

local LOC_MAX_RETRIES = 15 * 5 -- 15 seconds
local LOC_RETRY_DELAY = 0.2 -- one fifth of the second

local CharonData

local function NoteUpdateHelper(target)
    --print("NoteUpdateHelper: Spirit: " .. CharonData.Spirit.Quality .. " ? " .. CharonData.Spirit.NoteQuality .. " Corpse: " .. CharonData.Corpse.Quality .. " ? " .. CharonData.Corpse.NoteQuality .. " S: " .. CharonData.Corpse.SpiritQuality)
    local isUpdate = false
    if (CharonData.Spirit.Quality > CharonData.Spirit.NoteQuality) then
        --print("HC:UpdateSpiritNote")
        isUpdate = HC:UpdateSpiritNote(target) or isUpdate
    end
    if (CharonData.Corpse.Quality > CharonData.Corpse.NoteQuality) or ((CharonData.Spirit.Quality > CharonData.Corpse.SpiritQuality) and (CharonData.Corpse.Quality > QUALITY_NONE)) then
        --print("HC:UpdateCorpseNote")
        isUpdate = HC:UpdateCorpseNote(target) or isUpdate
    end
    if isUpdate then
        --print("NotifyIlarosNote!")
        HC:NotifyIlarosNote(target)
    end
    --print("NoteUpdateHelper END")
end

CharonData = {
    State = STATE_NONE,
    PlayerGuid = nil,
    DeadOnLogin = false, -- isn't STATE_ALIVE enough to ignore the death?
    Corpse = {
        Continent = -1,
        ZoneId = -1,
        Map = "",
        X = 0,
        Y = 0,
        Coords = 0,
        Quality = QUALITY_NONE,
        Func = GetCorpseMapPosition,
        FuncState = STATE_GHOST,
        RetryCount = 0,
        Name = "Corpse",
        NoteCoords = nil,
        NoteQuality = QUALITY_NONE,
        NoteUpdate = NoteUpdateHelper,
        SpiritQuality = QUALITY_NONE,
    },
    Spirit = {
        Continent = -1,
        ZoneId = -1,
        Map = "",
        X = 0,
        Y = 0,
        Coords = 0,
        Quality = QUALITY_NONE,
        Func = GetDeathReleasePosition,
        FuncState = STATE_DEAD,
        RetryCount = 0,
        Name = "Spirit Healer",
        NoteCoords = nil,
        NoteQuality = QUALITY_NONE,
        NoteUpdate = NoteUpdateHelper,
    },
    Event = {
        Time = 0,
        DeathTime = 0, -- backup, when COMBAT_EVENT_LOG fails :-(
        Type = "U",
        Source = "", --name of the creature who damaged the player OR environmental damage type
        SourceGuid = nil,
        SourceFlags = 0,
        Data = "", --string: "spellId\spellName\spellSchool\amount\overkill\school\resisted\blocked\absorbed\critical (1 or nil)\glancing (1 or nil)\crushing (1 or nil)"
    },
}

function HC:ClearCharonData()
    --print("ClearCharonData")
    CharonData.State = STATE_ALIVE

    --CharonData.Corpse.Continent = -1
    CharonData.Corpse.Quality = QUALITY_NONE
    CharonData.Corpse.NoteCoords = nil
    CharonData.Corpse.NoteQuality = QUALITY_NONE
    CharonData.Corpse.SpiritQuality = QUALITY_NONE
    CharonData.Corpse.RetryCount = 0

    --CharonData.Spirit.Continent = -1
    CharonData.Spirit.Quality = QUALITY_NONE
    CharonData.Spirit.NoteCoords = nil
    CharonData.Spirit.NoteQuality = QUALITY_NONE
    CharonData.Spirit.RetryCount = 0

    CharonData.Event.Time = nil
    CharonData.Event.DeathTime = 0
    CharonData.Event.Type = "U"
    CharonData.Event.Source = ""
    CharonData.Event.SourceGuid = nil
    CharonData.Event.Data = ""
    --print("ClearCharonData END")
end

function HC:SetCurrentPosition(target)

    if (target.Quality > QUALITY_LOC) then
        return true
    end

    local Ccontinent, Czone, Cx, Cy = Astrolabe:GetCurrentPlayerPosition()
    if not Ccontinent then
        return false
    end

    target.Quality = QUALITY_LOC
    target.Continent = Ccontinent
    target.ZoneId = Czone
    target.Map = IlarosNote:GetMapFile(Ccontinent, Czone)
    target.X = Cx
    target.Y = Cx
    target.Coords = IlarosNote:getCoord(Cx, Cy)

    target:NoteUpdate()
end

function HC:FindLocation(target)
    if CharonData.State ~= target.FuncState then
        self:print("Warning: Wrong state for finding location of " .. target.Name)
        return false
    end

    local Pcontinent, Pzone = GetCurrentMapContinent(), GetCurrentMapZone();

    target.Continent = self:GetLocContinent(target.Continent, Pcontinent, target.Func)

    if (target.Continent == -1) then
        -- no Spirit Healer, need to retry after a while
        --self:print("Location of " .. target.Name .. " not found, retrying")
        if (target.RetryCount < LOC_MAX_RETRIES) then
            self:ScheduleTimer("FindLocation", LOC_RETRY_DELAY, target)
        else
            self:print("Error: Location of " .. target.Name .. " not found! Timed out")
        end
        return false
    end

    local c, z, x, y = self:GetLocZone(target.Continent, target.ZoneId, Pzone, target.Func)

    target.Quality = QUALITY_API
    target.ZoneId = z
    target.Map = IlarosNote:GetMapFile(c, z)
    target.X = x
    target.Y = y
    target.Coords = IlarosNote:getCoord(x, y)

    local Zone = select(z, GetMapZones(c))
    --self:print("Location of " .. target.Name .. " found: " .. Zone .. " [" .. x .. ":" .. y .. "]")

    target:NoteUpdate()

    return true
end

-- STATE_ALIVE
function HC:PlayerAlive()
--  self:print("We are alive!")
    CharonData.State = STATE_ALIVE
    CharonData.DeadOnLogin = false
    self:ClearCharonData()
end

-- STATE_DEAD
function HC:PlayerDied()
-- GetDeathReleasePosition OK
-- GetCorpseMapPosition xx
--  self:print("We are dead!")
    CharonData.State = STATE_DEAD
    CharonData.Event.DeathTime = time()
    self:FindLocation(CharonData.Spirit)
    self:SetCurrentPosition(CharonData.Corpse)
end

-- STATE_GHOST
function HC:GhostReleased()
-- GetDeathReleasePosition xx
-- GetCorpseMapPosition OK
--  self:print("We are ghost!")
    CharonData.State = STATE_GHOST
    --self:SetCurrentPosition(CharonData.Spirit)
    if CharonData.Spirit.Quality ~= QUALITY_API then
        self:print("Error: Spirit Healer not found!");
    end
    self:FindLocation(CharonData.Corpse)
end

function HC:NotifyIlarosNote(target)
    self:SendMessage("IlarosNote_NotifyUpdate", "Charon")
end

function HC:UpdateSpiritNote(target)
    --self:print("UpdateSpiritNote");
    if (CharonData.Spirit.Quality <= CharonData.Spirit.NoteQuality) then
        self:print("Error: UpdateSpiritNote failed!");
        return false
    end

    local Smap = CharonData.Spirit.Map
    if (not Smap) then
        self:print("Error: Map file of Spirit Healer not found!");
        return false
    end

    if (CharonData.Spirit.NoteCoords ~= nil) and (CharonData.Spirit.NoteCoords ~= CharonData.Spirit.Coords) then
        -- TODO: analyze the old note
        --self:print("UpdateSpiritNote MOVE");
        db.factionrealm.nodes[Smap][CharonData.Spirit.NoteCoords] = nil
    end

    CharonData.Spirit.NoteCoords = CharonData.Spirit.Coords
    CharonData.Spirit.NoteQuality = CharonData.Spirit.Quality

    --self:print("SpiritNote: " .. Smap .. "[" .. CharonData.Spirit.NoteCoords .. "]: " .. "H")
    db.factionrealm.nodes[Smap][CharonData.Spirit.NoteCoords] = "H"

    return true
end

function HC:UpdateCorpseNote(target)
    --self:print("UpdateCorpseNote");
    if (CharonData.Corpse.Quality <= CharonData.Corpse.NoteQuality) and (CharonData.Spirit.Quality <= CharonData.Corpse.SpiritQuality) then
        self:print("Error: UpdateCorpseNote failed!");
        return false
    end

    if (CharonData.Corpse.Quality <= QUALITY_NONE) then
        self:print("Error: Corpse not yet detected!");
        return false
    end

    local Cmap = CharonData.Corpse.Map

    if (not Cmap) or (Cmap == "") then
        self:print("Error: Map file of Corpse not found!");
        return false
    end

    if (not CharDB.nodes[Cmap]) then
        CharDB.nodes[Cmap] = {}
    end

    if (CharonData.Corpse.NoteCoords ~= nil) and (CharonData.Corpse.NoteCoords ~= CharonData.Corpse.Coords) then
        -- TODO: analyze the old note
        --self:print("UpdateCorpseNote MOVE");
        CharDB.nodes[Cmap][CharonData.Corpse.NoteCoords] = nil
    end

    local SpiritCoords
    if (CharonData.Spirit.Quality > QUALITY_NONE) then

        if CharonData.Corpse.Continent ~= CharonData.Spirit.Continent then
            self:print("Error: Spirit healer on different continent: '" .. (select(CharonData.Spirit.Continent, GetMapContinents()) or "nil") .. "' from corpse: '" .. (select(CharonData.Corpse.Continent, GetMapContinents()) or "nil") .. "'");
            return false
        end

        if (CharonData.Corpse.ZoneId ~= CharonData.Spirit.ZoneId) then
            local Tx, Ty = Astrolabe:TranslateWorldMapPosition(CharonData.Spirit.Continent, CharonData.Spirit.ZoneId, CharonData.Spirit.X, CharonData.Spirit.Y, CharonData.Corpse.Continent, CharonData.Corpse.ZoneId)
            if not Tx then
                self:print("Error: Spirit healer coordinates translation failed!");
                --return false
                SpiritCoords = nil
            else
                SpiritCoords = IlarosNote:getCoord(Tx, Ty)
            end
        else
            SpiritCoords = CharonData.Spirit.Coords
        end

    end

    local SourceFlags = bit_and(CharonData.Event.SourceFlags, 0xffff)
    local deathtime = CharonData.Event.Time or CharonData.Event.DeathTime
    local CInfo = CharonData.Event.Type .. ":" .. deathtime .. ":" .. CharonData.Event.Source .. ":" .. (SpiritCoords or "").. ":" .. (CharonData.Event.SourceGuid or "") .. ":" .. SourceFlags .. ":" .. (CharonData.Event.Data or "")

    CharonData.Corpse.NoteCoords = CharonData.Corpse.Coords
    CharonData.Corpse.NoteQuality = CharonData.Corpse.Quality
    CharonData.Corpse.SpiritQuality = CharonData.Spirit.Quality

    --self:print("CorpseNote: " .. Cmap .. "[" .. CharonData.Corpse.NoteCoords .. "]: " .. CInfo)
    CharDB.nodes[Cmap][CharonData.Corpse.NoteCoords] = CInfo

    return true
end


function HC:OnInitialize()
    -- Set up our database
    db = LibStub("AceDB-3.0"):New("NoteGhosts", defaults)
    self.db = db
    self.data = CharonData

    if not NoteDeaths then
        NoteDeaths = {
            dbversion = CURRENT_DB_VERSION,
            nodes = {}
        }
    end
    CharDB = NoteDeaths


    if (db.factionrealm.dbversion > CURRENT_DB_VERSION) or (CharDB.dbversion > CURRENT_DB_VERSION) then
        print("|cff6fafffIlarosNote_Death:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
        print("|cff6fafffIlarosNote_Death:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
        self:Disable()
        return
    end

    if db.factionrealm.dbversion ~= CURRENT_DB_VERSION then
        if db.factionrealm.dbversion == 0 then
            -- addon was just installed
            db.factionrealm.dbversion = CURRENT_DB_VERSION
        end
    end


    local log = {}
    self.log = log

    if CharDB.dbversion ~= CURRENT_DB_VERSION then
        if CharDB.dbversion == 0 then
            -- addon was just installed
            CharDB.dbversion = CURRENT_DB_VERSION
        end
        if CharDB.dbversion == 1 then
            -- add SourceFlags
            self:print("Starting DB upgrade to version 2")
            tinsert(log, "Starting DB upgrade to version 2")
            -- upgrade code removed in commit 29 as nobody but me used the version 1 DB
            CharDB.dbversion = 2
            self:print("Upgrade to DB version 2 complete");
            tinsert(log, "Upgrade to DB version 2 complete");
        end
    end



    db.factionrealm.dbversion = CURRENT_DB_VERSION
    CharDB.dbversion = CURRENT_DB_VERSION

    -- Initialize our database with IlarosNote
    IlarosNote:RegisterPluginDB("Charon", HCHandler, options)
end



function HC:OnEnable()

    CharonData.PlayerGuid = UnitGUID("player")
    CharonData.DeadOnLogin = UnitIsDeadOrGhost("player")

    self:ClearCharonData()

--  self:RegisterEvent("AREA_SPIRIT_HEALER_IN_RANGE")     -- ??
--  self:RegisterEvent("AREA_SPIRIT_HEALER_OUT_OF_RANGE") -- ??
--  self:RegisterEvent("CONFIRM_XP_LOSS")      -- triggered when you ask Spirit Healer to resurect you
--  self:RegisterEvent("CORPSE_IN_INSTANCE")   -- triggered when corpse is in instance and you are near the instance entrance. It is used for displaying small help window.
--  self:RegisterEvent("CORPSE_IN_RANGE")      -- triggered when your corpse is in 40yeards radius and you can resurect
--  self:RegisterEvent("CORPSE_OUT_OF_RANGE")  -- triggered when you leave the 40yards radius and you can no longer resurect
--  self:RegisterEvent("RESURRECT_REQUEST")    -- ??

    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("PLAYER_ALIVE")
    self:RegisterEvent("PLAYER_UNGHOST")

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end


function HC:OnDisable()
    G:HideLines(WorldMapButton)
end


function HC:print(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff7fCharon: |r"..text)
    end
end

local function mystrjoin(delim, startIndex, ...)

    local res = (select(startIndex, ...) or "")

    for i = startIndex+1, select("#", ...) do
        res = res .. delim .. (select(i, ...) or "")
    end

    return res
end

function HC:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local type = select(2, ...)
    local destGuid = select(6, ...)

    if (destGuid ~= CharonData.PlayerGuid) then
        return;
    end


    if (type == "SWING_DAMAGE") then
        CharonData.Event.Time = select(1, ...)
        CharonData.Event.Type = "M"
        CharonData.Event.Source = select(4, ...)
        CharonData.Event.SourceGuid = select(3, ...)
        CharonData.Event.SourceFlags = select(5, ...)

    -- Let's make all the combat log events same:
    -- spellId = nil
    -- spallName = "Swing"
    -- spellSchool = 1 (PHYSICAL)

        CharonData.Event.Data = "\\Swing\\1\\" .. mystrjoin("\\", 9, ...)


    elseif (type == "RANGE_DAMAGE") or (type == "SPELL_DAMAGE") or (type == "SPELL_PERIODIC_DAMAGE") then
        CharonData.Event.Time = select(1, ...)

        if (type == "RANGE_DAMAGE") then
            CharonData.Event.Type = "R"
        elseif (type == "SPELL_DAMAGE") then
            CharonData.Event.Type = "S"
        elseif (type == "SPELL_PERIODIC_DAMAGE") then
            CharonData.Event.Type = "P"
        else
            CharonData.Event.Type = "U"
        end

        CharonData.Event.Source = select(4, ...)
        CharonData.Event.SourceGuid = select(3, ...)
        CharonData.Event.SourceFlags = select(5, ...)

    -- Let's make all the combat log events same:
    -- spellId = spellId (9th param)
    -- spallName = spallName (10th param)
    -- spellSchool = spellSchool (11th param)

        CharonData.Event.Data = mystrjoin("\\", 9, ...)


    elseif (type == "ENVIRONMENTAL_DAMAGE") then
        CharonData.Event.Time = select(1, ...)
        CharonData.Event.Type = "E"
        CharonData.Event.Source = select(9, ...)
        CharonData.Event.SourceGuid = select(3, ...)
        CharonData.Event.SourceFlags = select(5, ...)

    -- Let's make all the combat log events same:
    -- spellId = nil
    -- spallName = "Environmental"
    -- spellSchool = environmentalType (9th param)

        CharonData.Event.Data = "\\Environmental\\" .. mystrjoin("\\", 9, ...)
    else
        return;
    end
end


function HC:CONFIRM_XP_LOSS()
    self:print("CONFIRM_XP_LOSS")
end

function HC:AREA_SPIRIT_HEALER_IN_RANGE()
    self:print("AREA_SPIRIT_HEALER_IN_RANGE")
end

function HC:AREA_SPIRIT_HEALER_OUT_OF_RANGE()
    self:print("AREA_SPIRIT_HEALER_OUT_OF_RANGE")
end

function HC:CORPSE_IN_INSTANCE()
    self:print("CORPSE_IN_INSTANCE")
end

function HC:CORPSE_IN_RANGE()
    self:print("CORPSE_IN_RANGE")
end

function HC:CORPSE_OUT_OF_RANGE()
    self:print("CORPSE_OUT_OF_RANGE")
end

function HC:RESURRECT_REQUEST()
    self:print("RESURRECT_REQUEST")
end

function HC:PLAYER_DEAD()
--  self:print("PLAYER_DEAD")
    if UnitIsDeadOrGhost("player") and select(2, IsInInstance()) ~= "pvp" and not IsActiveBattlefieldArena() then
        self:PlayerDied()
    end
end

function HC:PLAYER_ALIVE()
--  self:print("PLAYER_ALIVE")
    if UnitIsDeadOrGhost("player") then
        if select(2, IsInInstance()) ~= "pvp" and not IsActiveBattlefieldArena() then
            if CharonData.DeadOnLogin then
                self:print("Dead on login... ignoring")
                return
            end
            self:GhostReleased()
        end
    else
        self:PlayerAlive()
    end
end

--[[
function HC:TestCorpseAdd()
    if UnitIsDeadOrGhost("player") and select(2, IsInInstance()) ~= "pvp" and not IsActiveBattlefieldArena() then
        self:print("We are dead.")
        self:RegisterCorpse()
        self:AddCorpseNote()
    end
end
]]

function HC:PLAYER_UNGHOST()
--  self:print("PLAYER_UNGHOST")
    self:PlayerAlive()
end



function HC:GetLocContinent(tip1, tip2, func)
    local c, x, y = -1, 0, 0

    c = GetCurrentMapContinent()
    local oc, oz = c, GetCurrentMapZone()
    x, y = func()  -- current zone
    if (x == 0) and (y == 0) then
        SetMapZoom(c)
        x, y = func()  -- current continent

        -- try tip1
        if (x == 0) and (y == 0) and (tip1 ~= -1) and (c ~= tip1) then
            SetMapZoom(tip1)
            x, y = func()
            if (x ~= 0) and (y ~= 0) then
                c = tip1
            end
        end

        -- try tip2
        if (x == 0) and (y == 0) and (tip2 ~= -1) and (c ~= tip2) and (tip1 ~= tip2) then
            SetMapZoom(tip2)
            x, y = func()
            if (x ~= 0) and (y ~= 0) then
                c = tip2
            end
        end

        -- still failed
        if (x == 0) and (y == 0) then
            c = -1
        end
    end

    if (c == -1) then
        for i=1,select("#",GetMapContinents()) do
            SetMapZoom(i) -- Cycle through the continents
            x, y = func()
            if (x ~= 0) and (y ~= 0) then
                c = i
                break
            end
        end
    end
    SetMapZoom(oc, oz)

    return c, x, y
end

function HC:GetLocZone(continent, tip1, tip2, func)
    local c, z, x, y = -1, 0, 0, 0

    c = GetCurrentMapContinent()
    local oc, oz = c, GetCurrentMapZone()
    if (c ~= continent) then
        c = continent
        --z = 0
    else
        z = GetCurrentMapZone()
    end

    if (z > 0) then
        x, y = func()  -- current zone
    end

    if (x == 0) and (y == 0) then
        -- try tip1
        if (z ~= tip1) and (tip1 > 0) then
            SetMapZoom(c, tip1)
            x, y = func()
            if (x ~= 0) and (y ~= 0) then
                z = tip1
            end
        end

        -- try tip2
        if (x == 0) and (y == 0) and (tip2 > -1) and (z ~= tip2) and (tip1 ~= tip2) then
            SetMapZoom(c, tip2)
            x, y = func()
            if (x ~= 0) and (y ~= 0) then
                z = tip2
            end
        end

        -- still failed
        if (x == 0) and (y == 0) then
            z = 0
        end
    end

    if (z <= 0) then
        for i=1,select("#", GetMapZones(c)) do
            SetMapZoom(c, i)
            x, y = func()

            if (x ~= 0) and (y ~= 0) then
                return c, i, x, y
            end
        end
    end
    SetMapZoom(oc, oz)

    return c, z, x, y
end


------------------------------------------------------------------------------------------------------
-- The following function is from Daniel Stephens <iriel@vigilance-committee.org>
-- with reference to TaxiFrame.lua in Blizzard's UI and Graph-1.0 Ace2 library (by Cryect)
local TAXIROUTE_LINEFACTOR = 128/126; -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2; -- Half of that

-- T        - Texture
-- C        - Canvas Frame (for anchoring)
-- sx,sy    - Coordinate of start of line
-- ex,ey    - Coordinate of end of line
-- w        - Width of line
-- relPoint - Relative point on canvas to interpret coords (Default BOTTOMLEFT)
function G:DrawLine(C, sx, sy, ex, ey, w, color, layer)
    local relPoint = "BOTTOMLEFT"

    if not C.IlarosNoteCh_Lines then
        C.IlarosNoteCh_Lines = {}
        C.IlarosNoteCh_Lines_Used = {}
    end

    local T = tremove(C.IlarosNoteCh_Lines) or C:CreateTexture(nil, "ARTWORK")
    T:SetTexture("Interface\\AddOns\\IlarosNote\\images\\line")
    tinsert(C.IlarosNoteCh_Lines_Used,T)

    T:SetDrawLayer(layer or "ARTWORK")

    T:SetVertexColor(color[1],color[2],color[3],color[4]);
    -- Determine dimensions and center point of line
    local dx,dy = ex - sx, ey - sy;
    local cx,cy = (sx + ex) / 2, (sy + ey) / 2;

    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy;
    end

    -- Calculate actual length of line
    local l = ((dx * dx) + (dy * dy)) ^ 0.5;

    -- Sin and Cosine of rotation, and combination (for later)
    local s,c = -dy / l, dx / l;
    local sc = s * c;

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
    if (dy >= 0) then
        Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2;
        Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2;
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc;
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx;
        TRy = BRx;
    else
        Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2;
        Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2;
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc;
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy;
        TRx = TLy;
    end

    -- Thanks Blizzard for adding (-)10000 as a hard-cap and throwing errors!
    -- The cap was added in 3.1.0 and I think it was upped in 3.1.1
    --  (way less chance to get the error)
    if TLx > 10000 then TLx = 10000 elseif TLx < -10000 then TLx = -10000 end
    if TLy > 10000 then TLy = 10000 elseif TLy < -10000 then TLy = -10000 end
    if BLx > 10000 then BLx = 10000 elseif BLx < -10000 then BLx = -10000 end
    if BLy > 10000 then BLy = 10000 elseif BLy < -10000 then BLy = -10000 end
    if TRx > 10000 then TRx = 10000 elseif TRx < -10000 then TRx = -10000 end
    if TRy > 10000 then TRy = 10000 elseif TRy < -10000 then TRy = -10000 end
    if BRx > 10000 then BRx = 10000 elseif BRx < -10000 then BRx = -10000 end
    if BRy > 10000 then BRy = 10000 elseif BRy < -10000 then BRy = -10000 end

    -- Set texture coordinates and anchors
    T:ClearAllPoints();
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt);
    T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt);
    T:Show()
    return T
end

function G:HideLines(C)
    if C.IlarosNoteCh_Lines then
        for i = #C.IlarosNoteCh_Lines_Used, 1, -1 do
            C.IlarosNoteCh_Lines_Used[i]:Hide()
            tinsert(C.IlarosNoteCh_Lines, tremove(C.IlarosNoteCh_Lines_Used))
        end
    end
end
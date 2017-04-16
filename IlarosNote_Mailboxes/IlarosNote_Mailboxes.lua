---------------------------------------------------------
-- Addon declaration
IlarosNote_Mailboxes = LibStub("AceAddon-3.0"):NewAddon("IlarosNote_Mailboxes","AceEvent-3.0")
local HMB = IlarosNote_Mailboxes
local IlarosNote = LibStub("AceAddon-3.0"):GetAddon("IlarosNote")
local Astrolabe = DongleStub("Astrolabe-0.4")
local GameVersion = select(4, GetBuildInfo())
--local L = LibStub("AceLocale-3.0"):GetLocale("IlarosNote_Mailboxes", false)


---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
	global = {
		mailboxes = {
			["*"] = {},  -- [mapFile] = {[coord] = true, [coord] = true}
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
local icon = "Interface\\AddOns\\IlarosNote_Mailboxes\\Mail.tga"


---------------------------------------------------------
-- Plugin Handlers to IlarosNote
local HMBHandler = {}
local info = {}
local clickedMailbox = nil
local clickedMailboxZone = nil
local postman = (GetSpellInfo(67376))
function HMBHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	tooltip:SetText("Mailbox")
	tooltip:Show()
	clickedMailbox = nil
	clickedMailboxZone = nil
end

local function deletePin(button,mapFile,coord)
	if GameVersion < 30000 then
		coord = mapFile
		mapFile = button
	end
	HMB.db.global.mailboxes[mapFile][coord] = nil
	HMB:SendMessage("IlarosNote_NotifyUpdate", "Mailboxes")
end

local function createWaypoint(button,mapFile,coord)
	if GameVersion < 30000 then
		coord = mapFile
		mapFile = button
	end
	local c, z = IlarosNote:GetCZ(mapFile)
	local x, y = IlarosNote:getXY(coord)
	if IlarosNavi then
		IlarosNavi:AddZWaypoint(c, z, x*100, y*100, "Mailbox")
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint(NotePoint:new(IlarosNote:GetCZToZone(c, z), x, y, "Mailbox"))
	end
end

local function generateMenu(button, level)
	if GameVersion < 30000 then
		level = button
	end
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		info.isTitle      = 1
		info.text         = "IlarosNote - Mailboxes"
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		-- Delete menu item
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = "Delete mailbox"
		info.icon = icon
		info.func = deletePin
		info.arg1 = clickedMailboxZone
		info.arg2 = clickedMailbox
		UIDropDownMenu_AddButton(info, level);

		if IlarosNavi or Cartographer_Waypoints then
			-- Waypoint menu item
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = "Create waypoint"
			info.icon = nil
			info.func = createWaypoint
			info.arg1 = clickedMailboxZone
			info.arg2 = clickedMailbox
			UIDropDownMenu_AddButton(info, level);
		end

		-- Close menu item
		info.text         = "Close"
		info.icon         = nil
		info.func         = CloseDropDownMenus
		info.arg1         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level);
	end
end
local HMB_Dropdown = CreateFrame("Frame", "IlarosNote_MailboxesDropdownMenu")
HMB_Dropdown.displayMode = "MENU"
HMB_Dropdown.initialize = generateMenu

function HMBHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		clickedMailboxZone = mapFile
		clickedMailbox = coord
		ToggleDropDownMenu(1, nil, HMB_Dropdown, self, 0, 0)
	end
end

function HMBHandler:OnLeave(mapFile, coord)
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
	function HMBHandler:GetNodes(mapFile)
		return iter, HMB.db.global.mailboxes[mapFile], nil
	end
end


---------------------------------------------------------
-- Core functions

function HMB:AddMailBox()
	local c,z,x,y = Astrolabe:GetCurrentPlayerPosition()
	if not c then return end
	-- Dont bother in an instance, could be a portable mailbox or squire
	if IsInInstance() then return end
	-- portable mailbox check
	-- Mole-E 
	local startTime, duration, enable = GetItemCooldown(40768)
	-- less than 10 mins have elapsed on the cooldown
	if duration > 6600 then	return end
	-- Squire detection may be a little harder
	if self.usingSquire then return end	
	local loc = IlarosNote:getCoord(x, y)
	local mapFile = IlarosNote:GetMapFile(c, z)
	if not mapFile then return end
	for coord,value in pairs(self.db.global.mailboxes[mapFile]) do
		if value then
			local x2,y2 = IlarosNote:getXY(coord)
			if Astrolabe:ComputeDistance(c,z,x,y,c,z,x2,y2) < 15 then
				self.db.global.mailboxes[mapFile][coord] = nil
			end
		end
	end
	self.db.global.mailboxes[mapFile][loc] = true
	self:SendMessage("IlarosNote_NotifyUpdate", "Mailboxes")
end

function HMB:SquireCheck(event,arg1,arg2,arg3)
	if arg1 == "npc" and arg2 == postman then
		self.usingSquire = true
	end
end
function HMB:SquireCooldown(event,arg1)
	if arg1 == "CRITTER" then
		self.usingSquire = false
	end
end
---------------------------------------------------------
-- Options table
local options = {
	type = "group",
	name = "Mailboxes",
	desc = "Mailboxes",
	get = function(info) return db[info.arg] end,
	set = function(info, v)
		db[info.arg] = v
		HMB:SendMessage("IlarosNote_NotifyUpdate", "Mailboxes")
	end,
	args = {
		desc = {
			name = "These settings control the look and feel of the Mailbox icon. Note that IlarosNote_MailBoxes does not come with any precompiled data, when you visit mailboxes, it will automatically add the data into your database.",
			type = "description",
			order = 0,
		},
		icon_scale = {
			type = "range",
			name = "Icon Scale",
			desc = "The scale of the icons",
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 10,
		},
		icon_alpha = {
			type = "range",
			name = "Icon Alpha",
			desc = "The alpha transparency of the icons",
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 20,
		},
	},
}


---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HMB:OnInitialize()
	-- Set up our database
	self.db = LibStub("AceDB-3.0"):New("IlarosNote_MailboxesDB", defaults)
	db = self.db.profile
	self.usingSquire = false
	-- Initialize our database with IlarosNote
	IlarosNote:RegisterPluginDB("Mailboxes", HMBHandler, options)
end

function HMB:OnEnable()
	self:RegisterEvent("MAIL_CLOSED", "AddMailBox")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "SquireCheck")
	self:RegisterEvent("COMPANION_UPDATE","SquireCooldown")
end

function HMB:OnDisable()
end

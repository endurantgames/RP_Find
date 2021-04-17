-- rpFind
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

local addOnName, ns = ...;

-- libraries
local AceAddon          = LibStub("AceAddon-3.0");
local AceConfigDialog   = LibStub("AceConfigDialog-3.0");
local AceConfigDialog   = LibStub("AceConfigDialog-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceDB             = LibStub("AceDB-3.0");
local AceDBOptions      = LibStub("AceDBOptions-3.0");
local AceGUI            = LibStub("AceGUI-3.0");
local AceLocale         = LibStub("AceLocale-3.0");
local LibDBIcon         = LibStub("LibDBIcon-1.0");
local LibDataBroker     = LibStub("LibDataBroker-1.1");
local LibColor          = LibStub("LibColorManipulation-1.0");
local LibRealmInfo      = LibStub("LibRealmInfo");
local L                 = AceLocale:GetLocale(addOnName);

local MEMORY_WARN_MB      = 6;
local MEMORY_WARN_GB      = 1;
local MIN_BUTTON_BAR_SIZE = 8;
local MAX_BUTTON_BAR_SIZE = 64;
local BIG_STRING_LIMIT    = 30;
local MSP_FIELDS          = "RA RC IC FC AG AH AW CO CU FR NI NT PN PX VA TR GR GS GC"
local PLAYER_RECORD       = "RP_Find Player Record";
local ARROW_UP            = " |TInterface\\Buttons\\Arrow-Up-Up:0:0|t";
local ARROW_DOWN          = " |TInterface\\Buttons\\Arrow-Down-Up:0:0|t";
local SLASH               = "/rpfind|/lfrp";
local configDB            = "RP_Find_ConfigDB";
local finderDB            = "RP_FindDB";
local finderFrameName     = "RP_Find_Finder_Frame";
local addonChannel        = "xtensionxtooltip2";
local addonPrefix         = { trp3 = "RPB1", rpfind = "LFRP1", };

local col = {
  gray   = function(str) return   LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(str) end,
  orange = function(str) return LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(str) end,
  white  = function(str) return       WHITE_FONT_COLOR:WrapTextInColorCode(str) end,
  red    = function(str) return         RED_FONT_COLOR:WrapTextInColorCode(str) end,
  green  = function(str) return       GREEN_FONT_COLOR:WrapTextInColorCode(str) end,
  addon  = function(str) return     RP_FIND_FONT_COLOR:WrapTextInColorCode(str) end,
};

local addon = {};
for i = 1, GetNumAddOns()
do local name, _, _, enabled = GetAddOnInfo(i);
   if name then addon[name] = enabled; end;
end;

local questionMark = "Interface\\ICONS\\INV_Misc_QuestionMark";

local IC = -- icons
{ 
  spotlight = "Interface\\ICONS\\inv_misc_tolbaradsearchlight",
  question  = "Interface\\ICONS\\INV_Misc_QuestionMark",
  sendAd    = "Interface\\ICONS\\Inv_letter_18",
  editAd    = "Interface\\ICONS\\inv_inscription_inkcerulean01",
  previewAd = "Interface\\ICONS\\Inv_misc_notescript2b",
  readAds   = "Interface\\ICONS\\inv_letter_03",
  tools     = "Interface\\ICONS\\inv_engineering_90_toolbox_green",
  database  = "Interface\\ICONS\\Inv_misc_platnumdisks",
  prune     = "Interface\\ICONS\\inv_pet_broom",
  scan      = "Interface\\ICONS\\ability_hunter_snipertraining",
  scanResults = "Interface\\ICONS\\ability_hunter_snipershot",
  checkLFG  = "Interface\\ICONS\\inv_misc_grouplooking",
  sendLFG   = "Interface\\ICONS\\Inv_misc_groupneedmore",
  autosendStart = "Interface\\Icons\\inv_engineering_90_gizmo",
  autosendStop = "Interface\\Icons\\inv_mechagon_spareparts",
};
local textIC = -- icons for text
{ rpProfile  = "|A:profession:0:0|a",
  isIC       = "|TInterface\\COMMON\\Indicator-Green:0:0|t",
  isOOC      = "|TInterface\\COMMON\\Indicator-Red:0:0|t",
  hasAd      = "|A:mailbox:0:0|a",
  mapScan    = "|A:taxinode_continent_neutral:0:0|a",
  inSameZone = "|A:minimap-vignettearrow:0:0|a",
  isFriend   = "|TInterface\\COMMON\\friendship-heart:0:0|t",
  active     = "",
  horde      = "|A:hordesymbol:0:0|a",
  alliance   = "|A:alliancesymbol:0:0|a",
  looking    = "|A:questdaily:0:0|a",
  lgbt       = "|TInterface\\ICONS\\Achievement_DoubleRainbow:0:0:0:0:64:64:32:60:32:60|t",
  walkups    = "|A:flightmaster:0:0|a",
  trial      = "|TInterface\\ICONS\\NewPlayerHelp_Newcomer:0:0|t",
  rpFind     = "|T" .. IC.spotlight .. ":0:0:0:0:64:64:8:56:8:56:85:204:255|t",
}

local zoneList =
{ 1, 7, 10, 18, 21, 22, 23, 27, 37, 47, 49, 52, 57, 64, 71, 76, 80, 83, 84, 85, 87,
88, 89, 90, 94, 103, 110, 111, 199, 202, 210, 217, 224, 390, 1161, 1259, 1271, 1462,
1670, };

local pointsOfInterest =
{ [84] = 
  { { x = 48, y = 80, title = "The Mage Quarter", r = 6 },
    { x = 54, y = 51, title = "Cathedral Square", r = 6 },
    { x = 42, y = 64, title = "Lion's Rest", r = 8 },
    { x = 28, y = 36, title = "Stormwind Harbor", r = 16 },
    { x = 63, y = 70, title = "Trade District", r = 7 },
    { x = 74, y = 59, title = "Old Town", r = 6 },
    { x = 80, y = 37, title = "Stormwind Keep", r = 7 },
    { x = 66, y = 36, title = "The Dwarven District", r = 8 },
  },
  [37] =
  {
    { x = 42, y = 64, title = "Goldshire", r = 2 },
  },
  [85] =
  { { x = 70, y = 40, title = "Valley of Honor", r = 9 },
    { x = 53, y = 55, title = "The Drag", r = 8 },
    { x = 50, y = 75, title = "Valley of Strength", r = 8 },
    { x = 33, y = 73, title = "Valley of Spirits", r = 10 },
    { x = 37, y = 32, title = "Valley of Wisdom", r = 12 },
  },
  [110] = 
  { { x = 60, y = 70, title = "The Bazaar", r = 10 },
    { x = 76, y = 80, title = "Walk of Elders", r = 13 },
    { x = 90, y = 58, title = "The Royal Exchange", r = 10 },
    { x = 75, y = 49, title = "Murder Row", r = 7 },
    { x = 85, y = 25, title = "Farstriders' Square", r = 15 },
    { x = 68, y = 37, title = "Court of the Sun", r = 9 },
    { x = 55, y = 20, title = "Sunfury Spire", r = 12 },
  },
};


local zoneBacklink = {};

local menu =
{ notifySound =
  { [139868 ] = L["Sound Silent Trigger"   ], [18871  ] = L["Sound Alarm Clock 1"    ],
    [12867  ] = L["Sound Alarm Clock 2"    ], [12889  ] = L["Sound Alarm Clock 3"    ],
    [118460 ] = L["Sound Azerite Armor"    ], [18019  ] = L["Sound Bnet Login"       ],
    [5274   ] = L["Sound Auction Open"     ], [38326  ] = L["Sound Digsite Complete" ],
    [31578  ] = L["Sound Epic Loot"        ], [9378   ] = L["Sound Flag Taken"       ],
    [3332   ] = L["Sound Friend Login"     ], [3175   ] = L["Sound Map Ping"         ],
    [8959   ] = L["Sound Raid Warning"     ], [39516  ] = L["Sound Store Purchase"   ],
    [37881  ] = L["Sound Vignette Ping"    ], [111370 ] = L["Sound Voice Friend"     ],
    [110985 ] = L["Sound Voice Join"       ], [111368 ] = L["Sound Voice In"         ],
    [111367 ] = L["Sound Voice Out"        ],
  },
  notifySoundOrder = { 139868, 18871, 12867, 12889, 118460, 5274, 18019,  38326,  31578, 9378, 
                       3332,   3175, 8959,  39516, 37881, 111370, 110985, 111368, 111367 },
  zone = {},
  zoneOrder = {};
  perPage = {},
  perPageOrder = {},
  infoColumn =
  { ["Info Class"] = L["Info Class"],
    ["Info Race"] = L["Info Race"],
    ["Info Race Class"] = L["Info Race Class"],
    ["Info Age"] = L["Info Age"],
    ["Info Pronouns"] = L["Info Pronouns"],
    ["Info Zone"] = L["Info Zone"],
    ["Info Tags"] = L["Info Tags"],
    ["Info Status"] = L["Info Status"],
    ["Info Currently"] = L["Info Currently"],
    ["Info OOC Info"] = L["Info OOC Info"],
    ["Info Title"] = L["Info Title"],
    ["Info Data Timestamp"] = L["Info Data Timestamp"],
    ["Info Data First Seen"] = L["Info Data First Seen"],
    ["Info Server"] = L["Info Server"],
    ["Info Subzone"] = L["Info Subzone"],
    ["Info Zone Subzone"] = L["Info Zone Subzone"],

  },
  infoColumnOrder =
    { "Info Class", "Info Race", "Info Race Class", "Info Age", 
      "Info Pronouns", "Info Zone", "Info Zone Subzone",
      "Info Subzone", "Info Tags", "Info Status", 
      "Info Currently", "Info OOC Info", "Info Title", 
      "Info Data First Seen", "Info Server",
    },

  notifyChatType = 
    { ["COMBAT_MISC_INFO"] = COMBAT_MISC_INFO,
      ["SKILL"] = SKILLUPS,
      ["BN_INLINE_TOAST_ALERT"] = BN_INLINE_TOAST_ALERT,
      ["SYSTEM"] = SYSTEM_MESSAGES,
      ["TRADESKILLS"] = TRADESKILLS,
      ["CHANNEL"] = CHANNEL,
      ["SAY"] = SAY,
      ["MONSTER_SAY"] = SAY .. " (" .. CREATURE .. ")",
    },

  notifyChatTypeOrder =
    { "COMBAT_MISC_INFO", "SKILL", "BN_INLINE_TOAST_ALERT",
      "SYSTEM", "TRADESKILLS", "CHANNEL", "SAY", "MONSTER_SAY", }

};

local function sortNotifyChatType(a, b)
  return menu.notifyChatType[a] < menu.notifyChatType[b]
end;

table.sort(menu.notifyChatTypeOrder, sortNotifyChatType);

for i = 10, 30, 5 
do menu.perPage[tostring(i)] = tostring(i); 
   table.insert(menu.perPageOrder, tostring(i)) 
end;

local function sortInfo(a, b) return menu.infoColumn[a] < menu.infoColumn[b] end;

table.sort(menu.infoColumnOrder, sortInfo);

for i, mapID in ipairs(zoneList)
do  local info = C_Map.GetMapInfo(mapID);
    if not zoneBacklink[info.name]
    then menu.zone[mapID] = info.name;
         table.insert(menu.zoneOrder, mapID);
         zoneBacklink[info.name] = mapID;
    end;
end;

-- we can't just pre-define an order because it's going to vary from language to language
--
local function sortSounds(a, b) return menu.notifySound[a] < menu.notifySound[b]; end;
local function sortZones( a, b) return menu.zone[a       ] < menu.zone[b       ]; end;

table.sort(menu.zoneOrder, sortZones)
table.sort(menu.notifySound, sortSounds);

local function split(str, pat)
  local t = {};
  local fpat = "(.-)" .. pat;
  local last_end = 1;
  local s, e, cap = str:find(fpat, 1);
  while s 
  do    if s ~= 1 or cap ~= ""
        then table.insert(t, cap)
        end;
        last_end = e + 1;
        s, e, cap = str:find(fpat, last_end);
  end;
  if   last_end <= #str
  then cap = str:sub(last_end);
       table.insert(t, cap);
  end;
  return t;
end;

local function stripColor(text)
  local rrggbb, strippedText = text:match("|cff(%x%x%x%x%x%x)(.+)|r");
  if   rrggbb 
  then return strippedText:gsub("|cff%x%x%x%x%x%x",""):gsub("|r", ""), 
              rrggbb
  else return text
  end;
end;

local function calcVersion(version) -- takes a version string, returns a number
  local a, b, c, d, more = version:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)(.*)$");
  local sum =   tonumber(a) * 1000 * 100 * 100
              + tonumber(b) * 1000 * 100
              + tonumber(c) * 1000
              + tonumber(d);
  if   more == "" then sum = sum + 1 - 1 / (100 * 100);
  else local greek, e = more:match("^ ?(%a)%a+ ?(%d+)$");
       if   greek:lower() == "a"
       then sum = sum + tonumber(e) / (100 * 100);
       elseif greek:lower() == "b"
       then local num = tonumber(e) / ( 100) 
            sum = sum + num; -- tonumber(e) / (100 * 100)
       else sum = sum + 1 - 1 / (100 * 100)
       end;
  end;
  return sum;
end;

local order = 0;

local function source_order(reset) order = reset or (order + 1); return order; end;

-- info:
  -- anchor        "ANCHOR_<position>"
  -- title         text
  -- titleColor    { r, g, b }
  -- columns       { { text, text }, { text, text }, ... }
  -- color1        { r, g, b }
  -- color2        { r, g, b }
  -- lines         { text, text, ... }
  -- color         { r, g, b }
  --
local function showTooltip(frame, info)
  frame = frame.frame or frame;
  GameTooltip:ClearLines();
  GameTooltip:SetOwner(frame, info.anchor or "ANCHOR_BOTTOM");

  local r,  g,  b  = 1, 1, 0;
  local r2, g2, b2 = 1, 1, 1;

  if     info.titleColor then r, g, b = unpack(info.titleColor)
  elseif info.color      then r, g, b = unpack(info.color);
  end;

  if   info.title 
  then GameTooltip:AddLine(info.title, r, g, b, true);

       if   info.icon 
       then GameTooltip:AddTexture(
              GetFileIDFromPath(info.icon), 
              { width = 32, 
                height = 32 ,
                margin = { left = 0, right = 6, top = 0, bottom = 6 },
                anchor = Enum.TooltipTextureAnchor.LeftTop,
                region = Enum.TooltipTextureRelativeRegion.LeftLine,
              } 
            );
       end;


       GameTooltip:AddLine(" ");
  end;

  r,  g,  b  = 0, 1, 0;
  r2, g2, b2 = 1, 1, 0;

  if     info.color1 then r, g, b = unpack(info.color1);
  elseif info.color  then r, g, b = unpack(info.color);
  end;

  if     info.color2 then r2, g2, b2 = unpack(info.color2);
  elseif info.color  then r2, g2, b2 = unpack(info.color);
  end;
  
  if   info.columns
  then for _, row in ipairs(info.columns)
       do GameTooltip:AddDoubleLine(row[1], row[2], r, g, b, r2, g2, b2);
       end;
  end;

  r, g, b = 0, 1, 0;

  if info.color then r, g, b = unpack(info.color); end;

  if   type(info.lines) == "table"
  then for _, line in ipairs(info.lines)
       do   GameTooltip:AddLine(line, r, g, b, true);
       end;
  elseif type(info.lines) == "string"
  then   GameTooltip:AddLine(info.lines, r, g, b, true);
  end;

  GameTooltip:Show();
end;

local function hideTooltip() GameTooltip:Hide(); end;

local function colorize(text, timeValue)
  return text;
  --[[
  local color = 
    LibColor.hsv(
      120 * math.min(
              1, 
              ( SECONDS_PER_HOUR 
                - ( time() 
                    - (timeValue or 0)
                  )
              ) / SECONDS_PER_HOUR
            ),
      0.8, 
      1
    );
  return color:format("|cffrrggbb") .. text .. "|r";
  --]]
end;

local RP_Find = AceAddon:NewAddon(
  addOnName, 
  "AceConsole-3.0", 
  "AceEvent-3.0", 
  "AceTimer-3.0" , 
  "LibToast-1.0"
);

RP_Find.addOnName    = addOnName;
RP_Find.addOnTitle   = GetAddOnMetadata(addOnName, "Title");
RP_Find.addOnVersion = GetAddOnMetadata(addOnName, "Version");
RP_Find.addOnDesc    = GetAddOnMetadata(addOnName, "Notes");
RP_Find.addOnIcon    = IC.spotlight;
RP_Find.addOnToast   = "RP_Find_notify";
RP_Find.timers       = {};
RP_Find.addonList = addon;
RP_Find.mspFields = split(MSP_FIELDS, " ");

function RP_Find:GetLast(name)        return self.db.global.last[name]            end;
function RP_Find:ClearLast(name)      self.db.global.last[name] = nil;            end;
function RP_Find:SetLast(name, value) self.db.global.last[name] = value or time() end;
function RP_Find:Last(name, value)    return value and self:SetLast(name, value) 
                                          or self:GetLast(name)                   end;

function RP_Find:FixColor(text)
  if not self.db.profile.config.lightenColors then return text end;

  local strippedText, rrggbb = stripColor(text);
  if not rrggbb then return text end;

  local col = LibColor("#" .. rrggbb);
  local _, _, lightness = col:hsl();
  if lightness < 0.75 then col = col:lighten_to(0.75) end;
      
  return col:format("|cffrrggbb") .. strippedText .. "|r";
end;

function RP_Find:HasRPClient(addonToQuery)
  if addonToQuery
  then return self.addonList[addonToQuery];
  else return self.addonList["totalRP3"]
           or self.addonList["MyRolePlay"]
           or _G["msp"] ~= nil
  end;
end;

local popup =
  { deleteDBonLogin = "RP_FIND_DELETE_DB_ON_LOGIN_CONFIRMATION",
    deleteDBNow     = "RP_FIND_DELETE_DB_NOW_CONFIRMATION",
  };

local function fixPopup(self) self.text:SetJustifyH("LEFT"); self.text:SetSpacing(3); end;

StaticPopupDialogs[popup.deleteDBonLogin] =
{ 
  showAlert      = true,
  text           = L["Popup Delete DB on Login"],
  button1        = YES,
  button2        = NO,
  exclusive      = true,
  OnAccept       = function() RP_Find.db.profile.config.deleteDBonLogin = true end,
  OnCancel       = function() 
                     RP_Find:Notify(L["Notify Setting Cleared"]); 
                     RP_Find.db.profile.config.deleteDBonLogin = false
                   end,
  timeout        = 60,
  whileDead      = true,
  hideOnEscape   = true,
  hideOnCancel   = true,
  preferredIndex = 3,
  wide           = true,
  OnShow         = fixStaticPopup,
}

StaticPopupDialogs[popup.deleteDBNow] =
{ showAlert      = true,
  text           = L["Popup Delete DB Now"],
  button1        = YES,
  button2        = NO,
  exclusive      = true,
  OnAccept       = function() RP_Find:WipeDatabaseNow() end,
  OnCancel       = function() RP_Find:Notify(L["Database Deletion Aborted"]) end,
  timeout        = 60,
  whileDead      = true,
  hideOnEscape   = true,
  hideOnCancel   = true,
  preferredIndex = 3,
  wide           = true,
  OnShow         = fixStaticPopup,
}

function RP_Find:PurgePlayer(name)
  if name 
  then self.data.rolePlayers[name]  = nil;
       self.playerRecords[name]     = nil;
  end;
end;

function RP_Find:SoftlyPurgePlayer(name)
  if name then self.playerRecords[name] = nil;
  end
end;

function RP_Find:StartOrStopPruningTimer()
  if     self.timers.pruning and self.db.profile.config.repeatSmartPruning 
  then 
  elseif self.timers.pruning
  then   self:CancelTimer(self.timers.pruning);
         self.timers.pruning = nil;
  elseif self.db.profile.config.repeatSmartPruning -- and not self.pruningTimer
  then   self.timers.pruning = 
           self:ScheduleRepeatingTimer(
             "SmartPruneDatabase", 
             15 * SECONDS_PER_MIN );
  else   -- not self.timers.pruning and not repeatSmartPruning 
  end;
end;

function RP_Find:SmartPruneDatabase(interactive)
  if not self.db.profile.config.useSmartPruning then return end;

  self.Finder:Hide();
  local now = time();
  local count = 0;

  local function getTimestamp(playerData) return playerData.last and playerData.last.when or 0 end;

  local secs = math.exp(self.db.profile.config.smartPruningThreshold);
  for   playerName, playerData in pairs(self.data.rolePlayers)
  do    
        local delta = now - getTimestamp(playerData)

        if  playerName ~= self.me and delta > secs
        then self:PurgePlayer(playerName)
             count = count + 1; 
        end; 
  end;

  UpdateAddOnMemoryUsage();

  self:StartOrStopPruningTimer();

  if     interactive and count > 0 
  then   self:Notify(string.format(L["Format Smart Pruning Done"], count)); 
  elseif interactive
  then   self:Notify(L["Notify Smart Pruning Zero"]);
  end;
end;

function RP_Find:WipeDatabaseNow()
  self.preWipeMemory = GetAddOnMemoryUsage(self.addOnName);
  InterfaceOptionsFrame:Hide();
  self.Finder:Hide();
  initializeDatabase(true); -- true = wipe
  self:LoadSelfRecord();
  UpdateAddOnMemoryUsage();
  self:Notify(L["Notify Database Deleted"]);
end;

function RP_Find:InitializeToast()
  self:RegisterToast(self.addOnToast,
    function(toast, ...)
      toast:SetTitle(self.addOnTitle);
      toast:SetIconTexture(self.addOnIcon);
      toast:SetText(...);
    end);
end;

function RP_Find:SendToast(message) self:SpawnToast(self.addOnToast, message, true); end;

local function playNotifySound() 
  PlaySound(RP_Find.db.profile.config.notifySound); 
end;

function RP_Find:SendChatMessage(messageType, prefix, text)
  local frames = CHAT_FRAMES;
  for f, frameName in ipairs(CHAT_FRAMES)
  do  local frame = _G[frameName]
      for c, chatType in ipairs(frame.messageTypeList)
      do  if chatType == messageType
          then local info = ChatTypeInfo[messageType];
               frame:AddMessage(prefix .. text, info.r, info.g, info.b, info.id)
               _ = self.db.profile.config.notifyChatFlash and FCF_StartAlertFlash(frame);
               break;
          end;
      end;
  end;
end;

function RP_Find:Notify(forceChat, ...) 
  local soundPlayed;
  local dots = { ... };
  
  if     type(forceChat) == "boolean" and forceChat
  then   
         self:SendChatMessage(
           self.db.profile.config.notifyChatType, 
           "[" .. self.addOnTitle .. "] ",
           table.concat(dots, " ")
          )
  elseif type(forceChat) == "boolean" -- and not forceChat
  then   self:SendToast(table.concat(dots, " "))

  else   if   self.db.profile.config.notifyMethod == "chat"
         or   self.db.profile.config.notifyMethod == "both"
         then 
              self:SendChatMessage(
                self.db.profile.config.notifyChatType, 
                "[" .. self.addOnTitle .. "] ",
                forceChat .. " " .. table.concat(dots, " ")
               )
         end;

         if   self.db.profile.config.notifyMethod == "toast"
         or   self.db.profile.config.notifyMethod == "both"
         then self:SendToast(forceChat .. table.concat(dots, " "));
         end;

         if self.db.profile.config.notifyMethod ~= "none" then playNotifySound(); end;
  end;
end;

local function initializeDatabase(wipe)
  if   wipe 
    or RP_Find.db.profile.config.deleteDBonLogin
  then _G[finderDB]     = {};
  else _G[finderDB]     = _G[finderDB] or {};
  end;

  local database        = _G[finderDB];
  database.rolePlayers  = database.rolePlayers or {};
  RP_Find.data          = database;
  RP_Find.playerRecords = {};

end;

function RP_Find:NewPlayerRecord(playerName, server, playerData)
  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));

  local playerRecord = {}
  playerRecord.playerName = playerName;

  for   methodName, func in pairs(self.PlayerMethods)
  do    playerRecord[methodName] = func;
  end;

  playerRecord:Initialize();

  if playerData then for field, value in pairs(playerData) 
  do playerRecord:Set(field, value) end; 
  end;

  if not playerRecord:Get("First Seen") 
  then playerRecord:Set("First Seen", nil, true) 
  end;

  self.playerRecords[playerName] = playerRecord;
  return playerRecord;
end;

function RP_Find:GetPlayerRecord(playerName, server)
  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));
  return self.playerRecords[playerName] or self:NewPlayerRecord(playerName);
end;

  -- filters are a list of functions
  -- something has to pass all the functions -- if there
  -- are any -- to be returned
  --
function RP_Find:GetAllPlayerRecords(filters, searchPattern)
 
  local filteredCount = 0;
  local totalCount    = 0;

  filters = filters or {};
  searchPattern = searchPattern or "";

  local function nameMatch(playerRecord, pattern)
    pattern = pattern:lower();
    return playerRecord:GetRPNameStripped():lower():match(pattern)
        or playerRecord:GetPlayerName():lower():match(pattern)
  end;

  local list = {};
  for _, record in pairs(self.playerRecords) 
  do  local pass;
      local success, funcReturnValue = pcall(nameMatch, record, searchPattern);
      if success then pass = funcReturnValue else pass = true end;

      for filterID, func in pairs(filters)
      do  local result = func(record)
          pass = pass and result;
      end 

      if   pass 
      then filteredCount = filteredCount + 1;
           table.insert(list, record); 
      end
      
      totalCount = totalCount + 1;
  end;
               
  return list, filteredCount, totalCount;
end;

function RP_Find:GetAllPlayerData()
  return self.data.rolePlayers;
end;

function RP_Find:GetMemoryUsage(fmt) -- returns value, units, message, bytes
  local value, units, warn;
  local currentUsage = GetAddOnMemoryUsage(self.addOnName);
  local highMemoryLimitMB = 6;

  if     currentUsage < 1000
  then   value, units, warn = currentUsage, "KB", "";
  elseif currentUsage < 1000 * 1000
  then   value, units, warn = currentUsage / 1000, "MB", "";
         if value > MEMORY_WARN_MB then warn = L["Warning High Memory MB"] end;
  else   value, units, warn = currentUsage / 1000 * 1000, "GB";
         if value > MEMORY_WARN_GB then warn = L["Warning High Memory GB"] end;
  end;

  local message = string.format(fmt or L["Format Memory Usage"],
                    value, units, warn);
  return value, units, message, currentUsage;
end

function RP_Find:CountPlayerRecords()
  local count = 0;
  if self.playerRecords
  then for _, _ in pairs(self.playerRecords) do count = count + 1; end;
  end;
  return count;
end;

function RP_Find:CountPlayerData()
  local count = 0
  if self.data.rolePlayers
  then for _, _ in pairs(self.data.rolePlayers) do count = count + 1 end;
  end;
  return count;
end;

function RP_Find:CountLFGGroups()
  local count = 0;
  if self.groupData
  then for _, _ in pairs(self.groupData) do count = count + 1 end;
  end;
  return count;
end;

function RP_Find:ScanForAdultContent(text)
  if   not text then return false end;
  if   not self.badWords 
  then self.badWords = split(L["Adult Content Patterns"], "\n");
  end;

  text:gsub("%W+", " "):lower();
  text = " " .. text .. " ";

  for _, pattern in pairs(self.badWords)
  do  local isMatch = text:find("%s" .. pattern .. "%s")
      if isMatch then return true; end;
  end;

  return false;
end;

function RP_Find.OnMinimapButtonClick(frame, button, ...)
  if   button == "RightButton" 
    or button == "LeftButton" and IsControlKeyDown()
  then if InterfaceOptionsFrame:IsShown()
       then InterfaceOptionsFrame:Hide()
       else RP_Find:OpenOptions();
       end;
       RP_Find:HideFinder();
  else if     RP_Find.Finder:IsShown()
       then   RP_Find:HideFinder();
       else   RP_Find:ShowFinder();
       end
  end;
end;

function RP_Find.OnMinimapButtonEnter(frame)
  local tooltip =  
  { columns = 
    { { RP_Find.addOnTitle, RP_Find.addOnVersion },
      { " ", " " },
      { L["Button Left-Click"], L["Open Finder Window"], },
      { L["Button Right-Click"], L["Options"], },
    },
    color1 = { 0, 1, 1 },
    color2 = { 1, 1, 1 },
    anchor = "ANCHOR_BOTTOM",
  };
  
  if IsModifierKeyDown()
  then local _, _, memory = RP_Find:GetMemoryUsage("%3.2f %s");
       table.insert(tooltip.columns, { L["Memory Usage"], memory });
       table.insert(tooltip.columns, { L["Players Seen"], RP_Find:CountPlayerData() });
       table.insert(tooltip.columns, { L["Players Loaded"], RP_Find:CountPlayerRecords() });
  end;

  showTooltip(frame, tooltip);
  
  --]]
end;

RP_Find.OnMinimapButtonLeave = hideTooltip;

function RP_Find:SendWhisper(playerName, message, position)
  local delta = time() - (self:Last("sendWhisper") or 0) 
  if   delta <= 5 * SECONDS_PER_MIN
  then self:Notify(string.format(L["Format Send Whisper Failed"], 5, 5 * SECONDS_PER_MIN - delta));
  else local messageStart = "/tell " .. playerName .. " " .. (message or "");
       if   ChatEdit_GetActiveWindow()
       then ChatEdit_GetActiveWindow():ClearFocus();
       end;
       ChatFrame_OpenChat(messageStart, nil, position)
       self:SetLast("sendWhisper");
       self:Update("Display");
  end;
end;

function RP_Find:SendPing(player, interactive)
  local  pingSent = false;
  local  playerName, server = unpack(split(player, "-"));

  if     self:HasRPClient("totalRP3")
  then   TRP3_API.r.sendMSPQuery(player);
         TRP3_API.r.sendQuery(player);
         pingSent = "trp3";
  elseif self:HasRPClient()
  then   msp:Request(playerName, server, self.mspFields);
         pingSent = "msp";
  end;

  if     pingSent and not self.timers.sendPing
  then   self.timers.sendPing = self:ScheduleTimer("CheckPingResult", SECONDS_PER_MIN, playerName)
  end;

  if     pingSent and interactive
  then   RP_Find:Notify(string.format(L["Format Ping Sent"], playerName));
         RP_Find:SetLast("pingPlayer");
  end;
end;

function RP_Find:CheckPingResult(playerName)
  local playerRecord = self:GetPlayerRecord(playerName);
  if not playerRecord then self:SoftlyPurgePlayer(playerName); return; end;
  if time() - (playerRecord:GetTimestamp() or 0) > 2 * SECONDS_PER_MIN
  then self:SoftlyPurgePlayer(playerName); return;
  end;
  self.timers.sendPing = nil;
  RP_Find:Update("Display");
end;

function RP_Find:CheckAllPings()
  for _, playerRecord in ipairs(self:GetAllPlayerRecords())
  do  if time() - (playerRecord:GetTimestamp() or 0) > 2 * SECONDS_PER_MIN
      then self:PurgePlayer(playerRecord:GetPlayerName())
      end;
  end;
  self.timers.sendPing = nil;
  RP_Find:Update("Display");
end;

RP_Find.PlayerMethods =
{ 
  ["Initialize"] =
    function(self)
      RP_Find.data.rolePlayers[self.playerName] 
        = RP_Find.data.rolePlayers[self.playerName] or {};
      self.data            = RP_Find.data.rolePlayers[self.playerName];
      self.data.fields     = self.data.fields or {};
      self.data.last       = self.data.last or {};
      self.data.last.when  = time();
      self.cache           = {};
      self.cache.fields    = {};
      self.cache.last      = {};
      self.cache.last.when = time();
      self.type            = PLAYER_RECORD;
      return self;
    end,

  ["Set"] =
    function(self, field, value, permanent)
      self.cache.fields[field]       = self.cache.fields[field] or {};
      self.cache.fields[field].value = value;
      self.cache.fields[field].when  = time();
      self.cache.last.when           = time();

      if   permanent
      then self.data.fields[field]       = self.data.fields[field] or {};
           self.data.fields[field].value = value;
           self.data.fields[field].when  = time();
           self.data.last.when           = time();
      end;
      return self;
    end,

  ["SetGently"] = 
    function(self, field, value, permanent)
      if not self:Get(field, permanent)
      then   self:Set(field, value, permanent);
      end;
    end,
      
  ["SetCarefully"] =
    function(self, field, value, permanent)
      local current = self:Get(field, permanent);
      if   (not current or current == "")
           and 
           (value   and value ~= "")
      then self:Set(field, value, permanent);
      end;
    end,

  ["SetTimestamp"] =
    function(self, field, timeStamp, permanent)
      timeStamp = timeStamp or time();

      if not field
      then   self.cache.last.when = timeStamp
      elseif self.cache.fields[field]
      then   self.cache.fields[field].when = timeStamp;
      elseif type(field) == "string"
      then   self:Set(field, nil, { when = timeStamp });
      end;

      if permanent
      then 
        if not field
        then   self.data.last.when = timeStamp
        elseif self.data.fields[field]
        then   self.data.fields[field].when = timeStamp;
        elseif type(field) == "string"
        then   self:Set(field, nil, { when = timeStamp }, true);
        end;
      end;

      return self;

    end,

  ["Get"] =
    function(self, field)
      if            self.cache.fields[field] ~= nil
      then   return self.cache.fields[field].value
      elseif        self.data.fields[field]
      then   return self.data.fields[field].value
      else   return nil
      end;
    end,

  ["GetMSP"] = function(self, field) return self:Get("MSP-" .. field) end,

  ["GetRP"] = 
    function(self, field, mspField)
      return self:Get("rp_" .. field) 
          or self:GetMSP(mspField)    
          or self:Get(field) 
          or ""
    end,

  ["GetPlayerName"] = 
    function(self, omitServer) 
      return omitServer 
         and self.playerName:gsub("%-.+$", "") 
          or self.playerName 
    end,

  ["GetServer"] =
    function(self)
      if self.server then return self.server end;
      self.server = self.playerName:match("%-(.+)$"); 
      return self.server
    end,

  ["GetServerName"] = 
    function(self) 
      if self.serverName then return self.serverName end;
      local server = self:GetServer();
      _, self.serverName = LibRealmInfo:GetRealmInfo(server);
      return self.serverName;
    end,

  ["GetColorizedServerName"] =
    function(self)
      return colorize(self:GetServerName(), self:GetTimestamp());
    end,

  ["GetRPName"] = 
    function(self) 
      local name = self:GetRP("name", "NA");
      if name == "" then return self:GetPlayerName(true); else return name end
    end,
    
  ["GetRPNameStripped"] =
    function(self)
      local name = self:GetRPName();
      local rrggbb, strippedName = name:match("|cff(%x%x%x%x%x%x)(.+)|r");
      if   strippedName 
      then return strippedName, rrggbb
      else return name, nil 
      end;
    end,

  ["GetRPNameColorFixed"] = function(self) return RP_Find:FixColor(self:GetRPName()); end,

  ["GetColorizedRPName"] =
    function(self)
      return colorize(self:GetRPNameStripped(), self:GetTimestamp());
    end,

  -- we probably aren't going to use all of these
  ["GetRPClass"      ] = function(self) return self:GetRP("class",       "RC")   end,
  ["GetRPRace"       ] = function(self) return self:GetRP("race",        "RA")   end,
  ["GetRPIcon"       ] = function(self) return self:GetRP("icon",        "IC")   end,
  ["GetRPStatus"     ] = function(self) return self:GetRP("status",      "FC")   end,
  ["GetRPAge"        ] = function(self) return self:GetRP("age",         "AG")   end,
  ["GetRPEyeColor"   ] = function(self) return self:GetRP("eyecolor",    "AE")   end,
  ["GetRPHeight"     ] = function(self) return self:GetRP("height",      "AH")   end,
  ["GetRPWeight"     ] = function(self) return self:GetRP("weight",      "AW")   end,
  ["GetRPInfo"       ] = function(self) return self:GetRP("oocinfo",     "CO")   end,
  ["GetRPCurr"       ] = function(self) return self:GetRP("currently",   "CU")   end,
  ["GetRPStyle"      ] = function(self) return self:GetRP("style",       "FR")   end,
  ["GetRPBirthplace" ] = function(self) return self:GetRP("birthplace",  "HB")   end,
  ["GetRPHome"       ] = function(self) return self:GetRP("home",        "HH")   end,
  ["GetRPMotto"      ] = function(self) return self:GetRP("motto",       "MO")   end,
  ["GetRPHouse"      ] = function(self) return self:GetRP("house",       "NH")   end,
  ["GetRPNickname"   ] = function(self) return self:GetRP("nick",        "NI")   end,
  ["GetRPTitle"      ] = function(self) return self:GetRP("title",       "NT")   end,
  ["GetRPPronouns"   ] = function(self) return self:GetRP("pronouns",    "PN")   end,
  ["GetRPHonorific"  ] = function(self) return self:GetRP("honorific",   "PX")   end,
  ["GetRPAddon"      ] = function(self) return self:GetRP("addon",       "VA")   end,
  ["GetRPTrial"      ] = function(self) return self:GetRP("trial",       "TR")   end,
  ["IsSetIC"         ] = function(self) return tonumber(self:GetRPStatus()) == 2 end,
  ["IsTrial"         ] = function(self) return tonumber(self:GetRPTrial())  == 1 end,

  ["GetRPStatusWord" ] = 
    function(self)
      local  status = self:GetRPStatus()
      local  statusNum = tonumber(status);

      if     statusNum == 1 then return "Out of Character"
      elseif statusNum == 2 then return "In Character"
      elseif statusNum == 3 then return "Looking for Contact"
      elseif statusNum == 4 then return "Storyteller"
      elseif status then return status
      else return ""
      end;
    end,

  ["GetIcon"] =
    function(self)
      local rpIcon = self:GetRPIcon();
      if rpIcon ~= "" then return "Interface\\ICONS\\" .. rpIcon, true end;

      local gameRace = self:GetRP("gameRace", "GR");
      local gameSex  = self:GetRP("gameSex",  "GS");

      local genderHash = { ["2"] = "Male", ["3"] = "Female", };

      if   not genderHash[gameSex] or gameRace == ""
      then return "Interface\\CHARACTERFRAME\\TempPortrait", false
      else return "Interface\\CHARACTERFRAME\\" .. "TemporaryPortrait-" 
             .. genderHash[gameSex] .. "-" .. gameRace, false;
      end;
    end,

  ["GetFlags"] = 
    function(self) 
      local flags = {};
      for _, flag in ipairs(RP_Find.Finder.flagList)
      do  if flag.func(self) 
          then table.insert(flags, flag.icon)
          end;
      end;

      return table.concat(flags);
    end,

  ["GetFlagsTooltip"] =
    function(self)
      local flags = {};
      for _, flag in ipairs(RP_Find.Finder.flagList)
      do if flag.func(self)
         then table.insert(flags, { flag.icon, flag.title})
         end;
      end;

      return {}, flags;
    end,

  ["GetInfoColumnTitle"] =
    function(self)
      return L[RP_Find.db.profile.config.infoColumn or "Info Server"]
    end,
  
  ["GetInfoColumnTooltip"] =
    function(self)
      return 
        { L["Info Column Tooltip"] },
        { 
          { L["Display Header Name"], self:GetRPNameColorFixed(), },
          { L[RP_Find.db.profile.config.infoColumn or "Info Server"],
            self:GetInfoColumn(),
          },
        }
    end,

  ["GetInfoColumn"] = 
    function(self)
      local hash = 
      { 
        ["Info Class"          ] = function(self) return self:GetRPClass()    or "" end,
        ["Info Race"           ] = function(self) return self:GetRPRace()     or "" end,
        ["Info Age"            ] = function(self) return self:GetRPAge()      or "" end,
        ["Info Pronouns"       ] = function(self) return self:GetRPPronouns() or "" end,
        ["Info Title"          ] = function(self) return self:GetRPTitle()    or "" end,
        ["Info Currently"      ] = function(self) return self:GetRPCurr()     or "" end,
        ["Info OOC Info"       ] = function(self) return self:GetRPInfo()     or "" end,
        ["Info Zone"           ] = function(self) return self:GetZoneName()   or "" end,
        ["Info Server"         ] = function(self) return self:GetServerName() or "" end,

        ["Info Data Timestamp" ] = function(self) return self:GetTimestamp() end,
        ["Info Data First Seen"] = function(self) return self:GetTimestamp("First Seen") end,

        ["Info Race Class"] =
          function(self)
            local class = self:GetRPClass();
            local race = self:GetRPRace();
            return (race and (race .. " ") or "") .. (class or "");
          end,

        ["Info Status"] = function(self) return self:GetRPStatusWord() end,

        ["Info Tags"] = 
          function(self)
            if not addon.RP_Tags then return "" end;
            return RPTAGS.utils.tags.eval(
              RP_Find.db.profile.config.infoConfigTags,
              self.playerName, self.playerName);
          end,

        ["Info Game Race Class"] = 
          function(self)
            local class = self:Get("MSP-GC");
            local race = self:Get("MSP-GR");
            return (race and (race .. " ") or "") .. (class or "");
          end,

        ["Info Subzone"] = 
          function(self) 
            local zone = self:Get("zoneID");
            local subzone = self:GetSubzoneName()
            if subzone ~= ""
            then return colorize(subzone, 
                   self:GetTimestamp("zone" .. zone .. "x"));
            else return "";
            end
          end,
        ["Info Zone Subzone"] =
          function(self)
            local subzone = self:GetSubzoneName()
            if subzone == ""
            then return self:GetZoneName()
            else return self:GetZoneName() .. " (" ..  subzone .. ")"
            end
          end,
          
      };

      local func = hash[RP_Find.db.profile.config.infoColumn or "Info Server"];
      return func(self);
    end,
            
  ["GetNameTooltip"] = 
    function(self)
      local lines = {};
      local columns = {};

      if not RP_Find:HasRPClient() then return lines, column end;

      local function addCol(method, label)
        local value = self[method](self);
        if   value and value ~= ""
        then value = RP_Find:FixColor(value);
             table.insert(
               columns, 
               { label, 
                 value:len() < BIG_STRING_LIMIT and value or
                (value:sub(1, BIG_STRING_LIMIT) .. "...") 
               }
            );
        end;
      end;

      local fields = 
        { { id = "race",     method = "GetRPRace",       label = "Race",    },
          { id = "class",    method = "GetRPClass",      label = "Class",   },
          { id = "title",    method = "GetRPTitle",      label = "Title"    },
          { id = "status",   method = "GetRPStatusWord", label = "Status",  },
          { id = "pronouns", method = "GetRPPronouns",   label = "Pronouns" },
          { id = "zone",     method = "GetZoneName",     label = "Zone"     },
          { id = "age",      method = "GetRPAge",        label = "Age",     },
          { id = "height",   method = "GetRPHeight",     label = "Height"   },
          { id = "weight",   method = "GetRPWeight",     label = "Weight",  },
          { id = "addon",    method = "GetRPAddon",      label = "RP Addon" }, 
        };

      for _, item in ipairs(fields)
      do  if RP_Find.db.profile.config.nameTooltip[item.id]
          then addCol(item.method, item.label)
          end;
      end;

      if RP_Find.db.profile.config.nameTooltip.trial
      then local trialStatus = self:IsTrial();
           if trialStatus then table.insert(columns, { "Trial Status", "Trial" });
           end;
      end;

      if RP_Find.db.profile.config.nameTooltip.currently
      then local currently = self:GetRPCurr();
           if currently and currently ~= ""
           then table.insert(lines, " ");
                table.insert(lines, "Currently:");
                table.insert(lines, col.white(currently));
            end;
      end;

      if RP_Find.db.profile.config.nameTooltip.oocinfo
      then local oocinfo = self:GetRPInfo();
           if oocinfo and oocinfo ~= ""
           then table.insert(lines, " ");
                table.insert(lines, "OOC Info:");
                table.insert(lines, col.white(oocinfo));
            end;
      end;

      local icon, iconFound = self:GetIcon();

      return lines, 
             columns, 
             iconFound 
               and RP_Find.db.profile.config.nameTooltip.icon
               and icon 
               or nil;
    end,
      
  ["GetZoneName"] =
    function(self)
      local zoneID = self:Get("zoneID");
      local zoneInfo;

      if   zoneID 
      then zoneInfo = C_Map.GetMapInfo(zoneID);
           if zoneInfo and zoneInfo.name then return zoneInfo.name end;
      end;
      return nil;
    end,

  ["GetSubzoneName"] =
    function(self)
      local zoneID = self:Get("zoneID");

      if not zoneID then return "" end;
      if not pointsOfInterest[zoneID] then return "" end;

      local x = self:Get("zone" .. zoneID .. "x");
      local y = self:Get("zone" .. zoneID .. "y");
      if not x or not y then return "" end;

      for _, poi in ipairs(pointsOfInterest[zoneID])
      do  local dist = math.sqrt(
                         (poi.x - x) * (poi.x - x) +
                         (poi.y - y) * (poi.y - y))
          if dist < poi.r then return poi.title end;
      end;

      return "";

    end,
      
  ["LabelViewProfile" ] =
    function(self)
      return L["Label Open Profile"], not addon.MyRolePlay and not addon.totalRP3
    end,

  ["CmdViewProfile"] =
    function(self)
      if     addon.MyRolePlay
      then   SlashCmdList["MYROLEPLAY"]("show " .. self.playerName);
             RP_Find.Finder:Hide();
      elseif addon.totalRP3
      then   SlashCmdList["TOTALRP3"]("open " .. self.playerName);
             RP_Find.Finder:Hide();
      else   RP_Find:Notify(string.format(L["Format Open Profile Failed"], self.playerName));
      end;
    end,

  ["LabelSendPing"] = 
    function(self) 
      return L["Label Ping"], 
        not RP_Find:HasRPClient() or
        time() - (RP_Find:Last("pingPlayer") or 0) < SECONDS_PER_MIN
    end,

  ["CmdSendPing"] =
    function(self)
      RP_Find:SendPing(self.playerName, true); -- true == interactive
      RP_Find:Update("Display");
    end,

  ["LabelSendTell"] = 
    function(self) 
      return L["Label Whisper"], 
        time() - (RP_Find:Last("sendWhisper") or 0) < SECONDS_PER_MIN
    end,

  ["CmdSendTell"] = 
    function(self, event, ...) 
      RP_Find:SendWhisper(self.playerName, "((  ))", 3) -- 3 = in the middle of the OOC braces
      RP_Find:Update("Display");
    end,

  ["HaveLFRPAd"] = 
    function(self) 
      local ad = self:Get("ad"); 
      return ad and ad ~= ""; 
    end,

  ["GetLFRPAd"] = 
    function(self)
      local ad = self:HaveLFRPAd()
      if not ad then return nil end;
      return { title = self:Get("ad_title"),
               body = self:Get("ad_body"),
               adult     = self:Get("ad_adult"),
               timestamp = self:GetTimestamp("ad") }
    end,             

  ["LabelReadAd"]   = 
    function(self) 
      local ad = self:GetLFRPAd();
      return ad and colorize(L["Label Read Ad"], ad.timestamp) or L["Label Read Ad"],
        not ad or add == {}
        -- or self.playerName == RP_Find.me 
    end,

  ["CmdReadAd"] = 
    function(self) 
      if self:Get("ad")
      then RP_Find.adFrame:SetPlayerRecord(self); 
           RP_Find.adFrame:Show(); 
      end;
    end,

  ["LabelInvite"]   = 
    function(self) 
      return L["Label Invite"], 
        time() - (RP_Find:Last("sendInvite") or 0) < SECONDS_PER_MIN
    end,

  ["CmdInvite"] =
    function(self)
      C_PartyInfo.InviteUnit(self.playerName)
      RP_Find:SetLast("sendInvite");
      RP_Find:Update("Display");
    end,

  ["HaveTRP3Data" ] = function(self) return self:Get("have_trp3Data");                end,
  ["HaveMSPData"  ] = function(self) return self:Get("have_mspData")                  end,
  ["HaveRPProfile"] = 
    function(self) 
      return self:HaveTRP3Data() 
          or self:HaveMSPData() 
      end,

  ["UnpackMSPData"] =
    function(self)
      if not RP_Find:HasRPClient() then return nil end;
      local  mspData = _G["msp"].char[self.playerName];
      if not mspData then return end;
      if     mspData.field and mspData.field.VA -- the minimum we need to be valid msp data
      then   for field, value in pairs(mspData.field) 
             do  self:SetGently("MSP-" .. field, value); 
             end;
      end;
      self:SetCarefully("have_mspData", true);
      RP_Find:Update("Display");
    end,

  ["UnpackTRP3Data"] =
    function(self)
      if not RP_Find:HasRPClient("totalRP3") then return end;

      local profile = TRP3_API.register.getUnitIDCurrentProfileSafe(self.playerName);

      local ristics = profile.characteristics;

      -- as with :GetRP, we're probably not going to use all of these
      --
      local char    = profile.character;
      if   char
      then self:SetCarefully("MSP-FC", char.RP)
           self:SetCarefully("MSP-CO", char.CO);
           self:SetCarefully("MSP-CU", char.CU);
           self:SetCarefully("MSP-FR", char.RP);
      end;

      if ristics
      then self:SetCarefully("MSP-NA", ristics.FN);
           self:SetCarefully("MSP-RC", ristics.CL);
           self:SetCarefully("MSP-RA", ristics.RA);
           self:SetCarefully("MSP-IC", ristics.IC);
           self:SetCarefully("MSP-AG", ristics.AG);
           self:SetCarefully("MSP-AE", ristics.EC);
           self:SetCarefully("MSP-AH", ristics.HE);
           self:SetCarefully("MSP-AW", ristics.WE);
           self:SetCarefully("MSP-HB", ristics.BP);
           self:SetCarefully("MSP-HH", ristics.RE);
           self:SetCarefully("MSP-PX", ristics.TI);
           self:SetCarefully("MSP-RS", ristics.RS);
           self:SetCarefully("MSP-NT", ristics.FT);
      
           if   ristics.MI
           then local miscRistics = {}
                for i, item in ipairs(ristics.MI)
                do miscRistics[item.NA:lower()] = item.VA;
                end;
                self:SetCarefully("MSP-MO", miscRistics.motto);
                self:SetCarefully("MSP-NH", miscRistics["house name"]);
                self:SetCarefully("MSP-NI", miscRistics.nickname);
                self:SetCarefully("MSP-PN", miscRistics.pronouns);
           end;
      end;

      self:Set("have_trp3Data", true);

      RP_Find:Update("Display");
    end,

  ["GetTimestamp"] =
    function(self, field, permanent)
      if     not field and permanent
      then   return self.data.last.when or time()
      elseif not field
      then   return self.cache.last.when or time()
      elseif self.data.fields[field]  and permanent
      then   return self.data.fields[field].when or time()
      elseif self.cache.fields[field]
      then   return self.cache.fields[field].when or time()
      else   return time()
      end;
    end,

  ["GetHumanReadableTimestamp"] =
    function(self, field, format)
      local now              = time();
      local integerTimestamp = self:GetTimestamp(field);
      local delta            = now - integerTimestamp;

      if     format 
      then   return date(format, integerTimestamp)
      elseif delta > 24 * 60 * 60
      then   return date("%x", integerTimestamp);
      elseif delta > 60 * 60
      then   return date("%X", integerTimestamp);
      elseif delta > 10
      then   return string.format(L["Format X Minutes Ago"], math.ceil(delta / 60));
      else   return string.format(L["Format <1 Minute Ago"], delta);
      end
    end,

  ["GetColorizedTimestamp"] =
    function(self, field, format)
      return colorize(
               self:GetHumanReadableTimestamp(field, format), 
               self:GetTimestamp(field)
             )
    end,

};

RP_Find.addOnDataBroker = 
  LibDataBroker:NewDataObject(
    RP_Find.addOnTitle,
    { icon    = RP_Find.addOnIcon,
      iconR   = RP_FIND_FONT_COLOR.r,
      iconG   = RP_FIND_FONT_COLOR.g,
      iconB   = RP_FIND_FONT_COLOR.b,
      iconA   = 0.5,
      label   = RP_Find.addOnTitle,
      OnClick = RP_Find.OnMinimapButtonClick,
      OnEnter = RP_Find.OnMinimapButtonEnter,
      OnLeave = RP_Find.OnMinimapButtonLeave,
      text    = RP_Find.addOnTitle,
      type    = "data source",
    }
  );
        
RP_Find.defaults =
{ profile =
  { config =
    { notifyMethod       = "toast",
      loginMessage       = false,
      finderTooltips     = true,
      autoSendPing       = false,
      monitorMSP         = true,
      monitorTRP3        = true,
      alertTRP3Scan      = false,
      alertAllTRP3Scan   = false,
      alertTRP3Connect   = false,
      notifySound        = 37881,
      deleteDBonLogin    = false,
      useSmartPruning    = false,
      repeatSmartPruning = false,
      smartPruningThreshold = 7,
      notifyLFRP         = true,
      seeAdultAds        = false,
      rowsPerPage        = 10,
      buttonBarSize      = 28,
      infoColumn         = "Info Server",
      infoColumnTags     = "[rp:gender] [rp:race] [rp:class]",
      showColorBar       = false,
      notifyChatType     = "SAY",
      notifyChatFlash    = true,
      versionCheck       = true,
      lightenColors      = true,
      nameTooltip        = 
      { 
        icon             = true,
        class            = true,
        race             = true,
        pronouns         = false,
        zone             = true,
        age              = false,
        status           = false,
        addon            = false,
        trial            = false,
        title            = false,
        height           = false,
        weight           = false,
        oocinfo          = false,
        currently        = false,
      },
    },
    ad                   = 
    { title              = "",
      body               = "",
      adult              = false,
      autoSend           = false,
    },
    minimapbutton        = {}, 
    finder               = {},
  },
  global                 =
  { last                 = {}
  },
};

local Finder = AceGUI:Create("Window");
Finder.myname = "Finder";
RP_Find.myname = "RP_Find";

function RP_Find:Update(...) self.Finder:Update(...); end

function Finder:SetDimensions()
  self:ClearAllPoints();
  if   RP_Find.db.profile.finder.left
  and  RP_Find.db.profile.finder.bottom
  then self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
         RP_Find.db.profile.finder.left,
         RP_Find.db.profile.finder.bottom)
  else self:SetPoint("CENTER", UIParent, "CENTER");
  end;

  if   RP_Find.db.profile.finder.width
  and   RP_Find.db.profile.finder.height
  then self:SetWidth(RP_Find.db.profile.finder.width);
       self:SetHeight(RP_Find.db.profile.finder.height);
  else self:SetWidth(700);
       self:SetHeight(500);
  end;
  self.frame:SetMinResize(650, 300);
end;

-- local finderWidth  = math.min(700, UIParent:GetWidth()  * 0.4);
-- local finderHeight = math.min(500, UIParent:GetHeight() * 0.5);
-- Finder:SetWidth(finderWidth);
-- Finder:SetHeight(finderHeight);
--
Finder:SetLayout("Flow");

Finder:SetCallback("OnClose",
  function(self, event, ...)
    local cancelTimers = { "playerList" };
    for _, t in ipairs(cancelTimers)
    do local timer = RP_Find.timers[t];
       if   timer 
       then RP_Find:CancelTimer(timer);
            RP_Find.timers[t] = nil;
       end;
    end;
  end);

_G[finderFrameName] = Finder.frame;
table.insert(UISpecialFrames, finderFrameName);

function Finder:DisableUpdates(value) self.updatesDisabled = value; end;

local function dontBreakOnResize()
  Finder:DisableUpdates(true);
  Finder:PauseLayout();
end;

local function restoreOnResize() 
  if   RP_Find and RP_Find.db
  then RP_Find.db.profile.finder.left,
       RP_Find.db.profile.finder.bottom,
       RP_Find.db.profile.finder.width,
       RP_Find.db.profile.finder.height =
         Finder.frame:GetRect();
  end;
  Finder:DisableUpdates(false);
  Finder:ResumeLayout();
  Finder:Update();
end;


hooksecurefunc(Finder.frame, "StartSizing",        dontBreakOnResize);
hooksecurefunc(Finder.frame, "StopMovingOrSizing", restoreOnResize);

Finder.frame:SetClampedToScreen(true);

Finder.content:ClearAllPoints();
Finder.content:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 50);
Finder.content:SetPoint("TOPRIGHT",   Finder.frame, "TOPRIGHT", -20, -30);

Finder.TabList = 
{ 
  { value = "Display", text = "Database", },
  { value = "Ads", text = "Your Ad", },
  -- { value = "LFG", text = "Looking for Group" },
  { value = "Tools", text = "Tools", },
};

Finder.TabListSub50 = -- currently the same as TabList
{ 
  { value = "Display", text = "Database", },
  { value = "Ads",     text = "Your Ad", },
  -- { value = "LFG",     text = "LFG (Disabled)" },
  { value = "Tools",   text = "Tools", },
};

function Finder:CreateButtonBar()
  local buttonSize = RP_Find.db.profile.config.buttonBarSize;

  local buttonBar = AceGUI:Create("SimpleGroup");
  buttonBar:SetLayout("Flow");
  buttonBar:SetRelativeWidth(0.5);
  self:AddChild(buttonBar);

  local buttonInfo =
  { 
    { title   = L["Button Toolbar Database"],
      icon    = IC.database,
      id      = "database",
      tooltip = L["Button Toolbar Database Tooltip"],
      func    = function(self, event, button) 
                  Finder:LoadTab("Display"); 
                end,
      enable  = function() return Finder.currentTab ~= "Display" end,
    },

    { title   = L["Button Toolbar Read Ads"],
      icon    = IC.readAds,
      id      = "readAds",
      tooltip = L["Button Toolbar Read Ads Tooltip"],
      func    = function(self, even, button)
                  for filterID, filterInfo in pairs(Finder.filterList)
                  do  filterInfo.enabled = (filterID == "HaveAd");
                  end;
                  Finder:LoadTab("Display");
                end,
       enable = 
         function() 
           local function haveAd(playerRecord) return playerRecord:HaveLFRPAd() end;
           local _, count = RP_Find:GetAllPlayerRecords({ haveAd });
           return count > 0
         end,
    },

    { title   = L["Button Toolbar Prune"],
      icon    = IC.prune,
      id      = "prune",
      tooltip = L["Button Toolbar Prune Tooltip"],
      func    = function(self, event, button) 
                  RP_Find:SmartPruneDatabase(true); 
                end,
      enable = function() return RP_Find.db.profile.config.useSmartPruning end,
    },

    { title   = L["Button Toolbar Edit Ad"],
      icon    = IC.editAd,
      id      = "editAd",
      tooltip = L["Button Toolbar Edit Ad Tooltip"],
      func    = function(self, event, button) 
                  Finder:LoadTab("Ads"); 
                end,
      enable  = function() return Finder.currentTab ~= "Ads" end,
    },

    { title   = L["Button Toolbar Preview Ad"],
      icon    = IC.previewAd,
      id      = "previewAd",
      tooltip = L["Button Toolbar Preview Ad Tooltip"],
      func    = function(self, event, button) 
                  if   RP_Find.adFrame:IsShown()
                  then RP_Find.adFrame:Hide()
                  else Finder:LoadTab("Ads"); 
                       RP_Find:ShowPreview();
                  end;
                end,
       enable = function() return true end,
    },

    { title   = L["Button Toolbar Send Ad"],
      icon    = IC.sendAd,
      id      = "sendAd",
      tooltip = L["Button Toolbar Send Ad Tooltip"],
      func    = function(self, event, button) 
                  RP_Find:SendLFRPAd(true);  -- true = interactive
                end,
      enable  = function() return not RP_Find:ShouldSendAdBeDisabled() end,
    },

    { title = L["Button Toolbar Autosend Start"],
      icon = IC.autosendStart,
      id = "autosendStart",
      tooltip = L["Button Toolbar Autosend Start Tooltip"],
      func = function(self, event, button)
               RP_Find.db.profile.ad.autoSend = true;
               RP_Find:Notify("Starting autosend.");
               RP_Find:StartOrStopAutoSend();
             end,
      enable = function() return not RP_Find:ShouldSendAdBeDisabled() end,
    },

    { title = L["Button Toolbar Autosend Stop"],
      icon = IC.autosendStop,
      id = "autosendStop",
      tooltip = L["Button Toolbar Autosend Stop Tooltip"],
      func = function(self, event, button)
               RP_Find.db.profile.ad.autoSend = false;
               RP_Find:Notify("Autosend stopped.");
               RP_Find:StartOrStopAutoSend();
             end,
      enable = function() return RP_Find.timers.autoSend end,
    },

    { title   = L["Button Toolbar Tools"],
      icon    = IC.tools,
      id      = "tools",
      tooltip = L["Button Toolbar Tools Tooltip"],
      func    = function(self, event, button) 
                  Finder:LoadTab("Tools"); 
                end,
      enable = function() return Finder.currentTab ~= "Tools"; end,
    },

    { title   = L["Button Toolbar Scan"],
      icon    = IC.scan,
      id      = "scan",
      tooltip = L["Button Toolbar Scan Tooltip"],
      func    = function(self, event, button)
                  Finder:LoadTab("Tools"); -- otherwise super spammy
                  RP_Find:SendTRP3Scan(C_Map.GetBestMapForUnit("player"))
                end,
      enable = function() 
                 return RP_Find.db.profile.config.monitorTRP3 
                    and time() - (RP_Find:Last("mapScan") or 0) > SECONDS_PER_MIN
                end,
    },

    { title = L["Button Toolbar Scan Results"],
      icon = IC.scanResults,
      id = "scanResults",
      tooltip = L["Button Toolbar Scan Results Tooltip"],
      func = function()
               for filterID, filterInfo in pairs(Finder.filterList)
               do  filterInfo.enabled = (filterID == "MatchesLastMapScan");
               end;
               Finder:LoadTab("Display");
             end,
      enable = function() 
                 return RP_Find.db.profile.config.monitorTRP3 
                    and time() - (RP_Find:Last("mapScan") or 0) < SECONDS_PER_HOUR
                end,
    },

    --[[
    { title = L["Button Toolbar Check LFG"],
      icon = IC.checkLFG,
      func = function(self, event, button)
             end,
      tooltip = L["Button Toolbar Check LFG Tooltip"],
      enable = function() return UnitLevel("player") >= 50 end,
    },

    { title = L["Button Toolbar Send LFG"],
      icon = IC.sendLFG,
      func = function(self, event, button)
             end,
      tooltip = L["Button Toolbar Send LFG Tooltip"],
      enable = function() return UnitLevel("player") >= 50 end,
    },
    --]]
      --
  };

  self.buttons = {}

  for i, info in ipairs(buttonInfo)
  do  local button = AceGUI:Create("Icon");
      button:SetImage(info.icon);
      button:SetImageSize(buttonSize, buttonSize);
      button:SetWidth(buttonSize);
      button:SetCallback("OnEnter",
        function(self, event)
          showTooltip(self.frame, 
            { title = info.title,
              lines = { "", info.tooltip },
              anchor = "ANCHOR_TOP",
            });
        end);
      button:SetCallback("OnLeave", hideTooltip);
      button:SetCallback("OnClick", info.func);

      local spacer = AceGUI:Create("Label");
      spacer:SetText(" ");
      spacer:SetWidth(2); -- an absolute value not relative

      buttonBar:AddChild(button);
      buttonBar:AddChild(spacer);
      button:SetDisabled(not info.enable());
      button.info = info;
      self.buttons[info.id] = button;
  end;

  local function updateButtonBar()
    for id, button in pairs(self.buttons)
    do  button:SetDisabled(not button.info.enable());
    end;
  end;

  RP_Find:RegisterMessage("RP_FIND_CHANGE_AD",             updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_SEND_AD",               updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_SEND_AD_STATUS_CHANGE", updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_AUTOSEND_START",        updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_AUTOSEND_STOP",         updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_TAB_CHANGE",            updateButtonBar);
  RP_Find:RegisterMessage("RP_FIND_MAP_SCAN_SENT",         updateButtonBar);

end;

function Finder:ResizeButtonBar(value)
  value = value or RP_Find.db.profile.config.buttonBarSize;
  for id, btn in pairs(Finder.buttons)
  do  
     self:PauseLayout();
     btn:SetWidth(value)
     btn:SetHeight(value)
     btn:SetImageSize(value, value)
     self:ResumeLayout()
     self:DoLayout();
   end;
end;

function Finder:CreateProfileButton()
  local profileButton = AceGUI:Create("InteractiveLabel");
  profileButton:ClearAllPoints();
  profileButton:SetWidth(200);
  profileButton:SetFontObject(GameFontNormal);
  profileButton:SetPoint("BOTTOMRIGHT", self.TabGroup.frame, "TOPRIGHT", -10, -25);
  profileButton:SetJustifyH("RIGHT");
  profileButton:SetColor(0.5, 0.5, 0.5);
  profileButton:SetText(RP_Find.db:GetCurrentProfile());
  profileButton.frame:SetParent(self.frame);
  profileButton.frame:Show();
  profileButton.frame:Raise();

  profileButton:SetCallback("OnEnter",
    function(self, event, ...)
      self:SetColor(1, 1, 0);
      showTooltip(self, { title = "Current Profile",
        lines = { "Click to change the current profile." } });
    end);
  profileButton:SetCallback("OnLeave",
    function(self, event, ...)
      self:SetColor(0.5, 0.5, 0.5);
      hideTooltip();
    end);
  profileButton:SetCallback("OnClick",
    function(self, event, button)
      if   self.window 
      then AceGUI:Release(self.window); 
           self.window = nil;
           return;
      end;

      local currentProfile = RP_Find.db:GetCurrentProfile();
      local window = AceGUI:Create("SimpleGroup");
      self.window = window;
      window:SetWidth(300);
      window:ClearAllPoints();
      window:SetPoint("TOPLEFT", self.frame, "TOPRIGHT", 30, 25);
      window:SetLayout("Flow");
      window.frame:SetParent(self.frame);
      window.frame:Show();
      
      local inline = AceGUI:Create("InlineGroup");
      inline:SetLayout("Flow");
      inline:SetFullWidth(true);
      inline:SetFullHeight(true);
      window:AddChild(inline);

      local check = "|TInterface\\COMMON\\Indicator-Green:0:0|t";
      local blank = "|TInterface\\Store\\ServicesAtlas:0::0:0:1024:1024:1023:1024:1023:1024|t";
      local profileList = RP_Find.db:GetProfiles();
      for _, profileName in ipairs(profileList)
      do  
          local button = AceGUI:Create("InteractiveLabel")

          if   profileName == currentProfile 
          then button:SetText(check .. profileName);
          else button:SetText(blank .. profileName);
          end;
      
          button:SetFontObject(GameFontNormal);
          button:SetCallback("OnClick",
            function(self, event, button)
              RP_Find.db:SetProfile(profileName);
              window.frame:Hide();
              profileButton.window = nil;
              AceGUI:Release(window);
            end);
          button:SetCallback("OnEnter",
            function(self, event, ...)
              self:SetColor(1, 1, 0);
              showTooltip(self, { title = profileName, lines = { "Click to set this as the active profile." } });
            end);
          button:SetCallback("OnLeave",
            function(self, event, ...)
              self:SetColor(1, 1, 1);
              hideTooltip()
            end);
          button:SetFullWidth(true);

          inline:AddChild(button);
      end;

    end);

  self.profileButton = profileButton;
end;

function Finder:ResetProfileButton()
  self.profileButton:SetText(RP_Find.db:GetCurrentProfile());
end;
  
function Finder:CreateTabGroup()
  local tabGroup = AceGUI:Create("TabGroup");
  tabGroup:SetFullWidth(true);
  tabGroup:SetFullHeight(true);
  tabGroup:SetLayout("Flow");

  if UnitLevel("player") >= 50 then tabGroup:SetTabs(self.TabList);
  else tabGroup:SetTabs(self.TabListSub50);
  end;

  function tabGroup:LoadTab(tab)
    tab = tab or Finder.currentTab;
    if   RP_Find.timers.playerList 
    then RP_Find:CancelTimer(RP_Find.timers.playerList) 
         RP_Find.timers.playerList = nil; 
    end;
    self:ReleaseChildren();

    local scrollContainer = AceGUI:Create("SimpleGroup");
          scrollContainer:SetFullWidth(true);
          scrollContainer:SetFullHeight(true);
          scrollContainer:SetLayout("Fill");
    self.scrollContainer = scrollContainer;
    self:AddChild(scrollContainer);

    local scrollFrame = AceGUI:Create("ScrollFrame");
          scrollFrame:SetLayout("Flow");
          scrollContainer:AddChild(scrollFrame);
    self.scrollFrame = scrollFrame;
    local panelFrame = Finder.MakeFunc[tab](Finder);
    scrollFrame:AddChild(panelFrame);
    self.current = panelFrame;
    Finder.currentTab = tab;

    RP_Find:SendMessage("RP_FIND_TAB_CHANGE");

    if self:IsShown() then Finder:Update() end;
  end;

  tabGroup:SetCallback("OnGroupSelected", 
    function(self, event, group) 
      self:LoadTab(group); 
    end);

  function self:LoadTab(...) tabGroup:LoadTab(...) end; 

  self:AddChild(tabGroup);
  self.TabGroup = tabGroup;

end;

Finder.MakeFunc = {}

Finder.flagList = 
{
  { title = "Your Friend",
    icon = textIC.isFriend,
    func = function(self) 
             local fullName = self:GetPlayerName();
             local name = self:GetPlayerName(true);
             if C_FriendList.GetFriendInfo(name) then return true end;
             if not BNConnected() then return false end;
             RP_Find.bnetFriendList = RP_Find.bnetFriendList or {};
             if   time() - (RP_Find:Last("bnetFriendList") or 0) > 2 * SECONDS_PER_MIN
             then RP_Find.bnetFriendList = {};
                  local _, count, _, _ = BNGetNumFriends()
                  for i = 1, count, 1
                  do  local numAccounts = C_BattleNet.GetFriendNumGameAccounts(i);
                      for j = 1, numAccounts, 1
                      do  local friendData = C_BattleNet.GetFriendGameAccountInfo(i, j)
                          if friendData.clientProgram == BNET_CLIENT_WOW
                             and friendData.characterName
                             and friendData.realmName
                          then RP_Find.bnetFriendList[
                                 friendData.characterName .. "-" ..
                                 friendData.realmName] = true;
                          end;
                      end;
                  end;
                  RP_Find:SetLast("bnetFriendList");
             end;
             return RP_Find.bnetFriendList[fullName];
           end,
  },

  { 
    title  = "Have RP Profile",
    icon = textIC.rpProfile,
    func   = function(self) return self:HaveRPProfile() end,
  },

  { title  = "In Character",
    icon = textIC.isIC,
    func   = function(self) return self:IsSetIC() end,
  },

  { title = "Out of Character",
    icon = textIC.isOOC,
    func = function(self) local status = self:GetRPStatus(); return status and status == 1 end,
  },

  { title = "Trial Account",
    icon = textIC.trial,
    func = function(self) return self:IsTrial() end,
  },

  { title = "Sent LFRP Ad",
    icon = textIC.hasAd,
    func = function(self) return self:HaveLFRPAd() end,
  },

  { title = "Did Map Scan",
    icon = textIC.mapScan,
    func = function(self) return self:Get("mapScan") end,
  },

  { title = "LGBTQIA+ Friendly",
    func = function(self)
             local pat = "lgbtq?i?a?%+?";
             local curr = self:GetRPCurr();
             local oocinfo = self:GetRPInfo();
             return (curr and curr:lower():match(pat)
                     or oocinfo and oocinfo:lower():match(pat))
            end,
    icon = textIC.lgbt,
  },

  { title = "Walkups Welcome",
    icon = textIC.walkups,
    func = function(self)
             local pat = "walk%-? ?ups?";
             local curr = self:GetRPCurr();
             local oocinfo = self:GetRPInfo();
             return (curr and curr:lower():match(pat)
                     or oocinfo and oocinfo:lower():match(pat))
            end,
  },
  { title = RP_Find.addOnTitle .. " User",
    icon = textIC.rpFind,
    func = function(self) return self:Get("rpFindUser") end,
  },
};

Finder.filterList =
{ 
  ["OnThisServer"] =
    { title   = L["Filter On This Server"],
      enabled = false,
      func    = function(playerRecord)
                  return playerRecord.server == RP_Find.realm
                end,
    },

  ["IsSetIC"] =
    { 
      title   = L["Filter Is Set IC"],
      enabled = false,
      func    = function(playerRecord)
                  return playerRecord:GetRPStatus() == 2 or
                         playerRecord:GetRPStatus() == "2"
                end,
    },

  ["InfoColumnNotEmpty"] =
    { func =
        function(playerRecord)
          local info = playerRecord:GetInfoColumn()
          return info and info ~= "^%s&$"
        end,
      title = L["Filter Info Not Empty"],
      enabled = false,
    },

  ["MatchesLastMapScan"] =
    { func =
        function(playerRecord)
          local  zoneID = playerRecord:Get("zoneID")
          return zoneID and RP_Find:Last("mapScanZone")
             and time() - (RP_Find:Last("mapScan") or 0) < SECONDS_PER_HOUR
             and zoneID == RP_Find:Last("mapScanZone")
        end,
      title  = L["Filter Match Map Scan"],
      enabled = false,
    },

  ["ContactInLastHour"] =
    { func =
        function(playerRecord)
          return time() - playerRecord:GetTimestamp() < SECONDS_PER_HOUR
        end,
      title = L["Filter Active Last Hour"],
      enabled = false,
    },

  ["SentMapScan"] =
    { func =
        function(playerRecord)
          local  didMapScan = playerRecord:Get("mapScan");
          return playerRecord:Get("mapScan")
                 and time() - playerRecord:GetTimestamp("mapScan") < SECONDS_PER_HOUR;
        end,
      title = L["Filter Sent Map Scan"],
      enabled = false,
    },

  ["HaveAd"] =
    { func = function(playerRecord) return playerRecord:HaveLFRPAd() end,
      title = L["Filter Have LFRP Ad"],
      enabled = false,
    },

  ["HaveRPProfile"] =
    { func = function(playerRecord) return playerRecord:HaveRPProfile() end,
      title = L["Filter RP Profile Loaded"],
      enabled = false,
    },

  ["ClearAllFilters"] = 
    { func = function(playerRecord) return true end,
      title = L["Filter Clear All Filters"],
      enabled = false,
    },
};

local function sortFilters(a, b)
  return Finder.filterList[a].title < Finder.filterList[b].title
end;

Finder.filterListOrder = { "ContactInLastHour",
  "SentMapScan", "InfoColumnNotEmpty", "IsSetIC",
  "MatchesLastMapScan", "OnThisServer", 
  "HaveRPProfile", "HaveAd", };

table.sort(Finder.filterListOrder, sortFilters);
table.insert(Finder.filterListOrder, "ClearAllFilters");

function Finder.MakeFunc.Display(self)

  local searchPattern = "";
  local activeFilters = {};

  local panelFrame = AceGUI:Create("SimpleGroup");
        panelFrame:SetFullWidth(true);
        panelFrame:SetLayout("Flow");
  
  local searchBar = AceGUI:Create("EditBox");
        searchBar:SetRelativeWidth(0.38)
        searchBar.editbox:SetTextColor(0.5, 0.5, 0.5);
        searchBar:DisableButton(true);

        searchBar:SetCallback("OnTextChanged",
          function(self, event, text)
            searchPattern = text;
            Finder.searchPattern = searchPattern;
            Finder:Update("Display"); 
          end);
        searchBar:SetCallback("OnEnter",
          function(self, event)
            showTooltip(self.frame, 
            { anchor = "ANCHOR_BOTTOM",
              title = L["Display Search"],
              lines = { L["Display Search Tooltip"] } 
            });
        end);
        searchBar:SetCallback("OnLeave", hideTooltip);

  panelFrame:AddChild(searchBar);

  local space1 = AceGUI:Create("Label"); 
  space1:SetRelativeWidth(0.01); 
  panelFrame:AddChild(space1);

  local filterSelector = AceGUI:Create("Dropdown");
        filterSelector:SetMultiselect(true);
        filterSelector:SetRelativeWidth(0.38);
  
  for _, filterID in ipairs(self.filterListOrder)
  do  local filterData = self.filterList[filterID];
      filterSelector:AddItem(filterID, filterData.title);
  end;

  local function setActiveFilters()

    local count = 0;
   
    for filterID, filterData in pairs(self.filterList)
    do  if   filterData.enabled
        then activeFilters[filterID] = filterData.func
             filterSelector:SetItemValue(filterID, true);
             count = count + 1;
        else filterSelector:SetItemValue(filterID, false);
             activeFilters[filterID] = nil;
        end;
    end;

    if   count == 0 
    then filterSelector:SetText(L["Display Filters"]);
    else filterSelector:SetText(
           string.format(
             L["Format Display Filters"], 
             count
           )
         );
    end;
    RP_Find.Finder.activeFilters = activeFilters;
  end;

  filterSelector:SetCallback("OnValueChanged",
    function(self, event, key, checked)
      Finder.filterList[key].enabled = checked;
      if key == "ClearAllFilters"
      then for filterID, filterData in pairs(Finder.filterList)
           do  filterData.enabled = false;
           end;
           RP_Find:Notify(L["Notify Filters Cleared"]);
      end;
      setActiveFilters();
      Finder:Update("Display");
    end);

  filterSelector:SetCallback("OnEnter",
    function(self, event)
      local tooltip = 
        { title = L["Display Active Filters"], 
          lines = {},
          anchor = "ANCHOR_BOTTOM" 
        };

      local filtersFound;

      for filterID, func in pairs(activeFilters)
      do  table.insert(tooltip.lines, Finder.filterList[filterID].title)
          filtersFound = true;
      end;
      
      if not filtersFound then table.insert(tooltip.lines, "none") end;

      showTooltip(self, tooltip);
    end);

  filterSelector:SetCallback("OnLeave", hideTooltip);

  panelFrame:AddChild(filterSelector);

  local space2 = AceGUI:Create("Label"); 
        space2:SetRelativeWidth(0.01); 
  panelFrame:AddChild(space2);

  local perPageSelector = AceGUI:Create("Dropdown");
        perPageSelector:SetList(menu.perPage, menu.perPageOrder);

        perPageSelector:SetText(
          string.format(
            L["Format Per Page"],
            RP_Find.db.profile.config.rowsPerPage
          )
        );

        perPageSelector:SetRelativeWidth(0.20);

        perPageSelector:SetCallback("OnValueChanged",
          function(self, event, value)
            local old = RP_Find.db.profile.config.rowsPerPage;

            local start = (Finder.pos or 0) * old + 1;
            Finder.pos = math.floor(start / value);

            RP_Find.db.profile.config.rowsPerPage = value;
            RP_Find:Update("Display");
          end);
        perPageSelector:SetCallback("OnEnter",
          function(self, event)
            showTooltip(self, { title = "Entries per Page",
              lines = { "Set the number of players per page in the database viewer." },
            });
          end);
        perPageSelector:SetCallback("OnLeave", hideTooltip);

  panelFrame:AddChild(perPageSelector);

  local headers = AceGUI:Create("SimpleGroup");
        headers:SetLayout("Flow");
        headers:SetFullWidth(true);
  panelFrame:AddChild(headers);
 
  headers.list = {};
  
  local columns   =
  { { 
      title       = L["Display Header Name"],
      method      = "GetRPNameColorFixed",
      sorting     = "GetRPNameStripped",
      ttMethod    = "GetNameTooltip",
      ttTitleMethod = "GetRPNameColorFixed",
      width       = 0.25,
    },
    { 
      title       = L["Display Header Info"],
      method      = "GetInfoColumn",
      ttMethod    = "GetInfoColumnTooltip",
      ttTitle     = L["Display Header Info"],
      width       = 0.17,
    },
    { 
      title       = L["Display Header Flags"],
      method      = "GetFlags",
      ttMethod    = "GetFlagsTooltip",
      ttTitle     = L["Display Header Flags"],
      width       = 0.18,
    },
    {
      title       = L["Display Header Tools"],
      ttTitle     = L["Display Column Title Profile"],
      method      = "LabelViewProfile",
      callback    = "CmdViewProfile",
      tooltip     = L["Display View Profile Tooltip"],
      disableSort = true,
      width       = 0.08,
    },
    { 
      ttTitle     = L["Display Column Title Whisper"],
      title       = "",
      method      = "LabelSendTell",
      callback    = "CmdSendTell",
      disableSort = true,
      tooltip     = L["Display Send Tell Tooltip"],
      width       = 0.09,
    },
    { 
      ttTitle     = L["Display Column Title Ping"],
      title       = "",
      method      = "LabelSendPing",
      callback    = "CmdSendPing",
      tooltip     = L["Display Send Ping Tooltip"],
      disableSort = true,
      width       = 0.06,
    },
    { 
      ttTitle     = L["Display Column Title Ad"],
      title       = "",
      method      = "LabelReadAd",
      callback    = "CmdReadAd",
      tooltip     = L["Display Read Ad Tooltip"],
      disableSort = true,
      width       = 0.09,
    },
    { 
      ttTitle     = L["Display Column Title Invite"],
      title       = "",
      method      = "LabelInvite",
      callback    = "CmdInvite",
      tooltip     = L["Display Send Invite Tooltip"],
      disableSort = true,
      width       = 0.08,
    },
  };

  local recordSortField        = "GetRPNameStripped";
  local recordSortFieldReverse = false;
  
  local function sortPlayerRecords(a, b)

    local function helper(booleanValue)
      if recordSortFieldReverse
      then return not booleanValue
      else return     booleanValue
      end;
    end;
  
    if a[recordSortField] and b[recordSortField]
    then return a[recordSortField](a)  <  b[recordSortField](b)
    end;
  
  end;

  local function ListHeader_SetRecordSortField(self, event, button)
    recordSortField = self.recordSortField;
    for headerName, header in pairs(headers.list)
    do  if     recordSortField == self.recordSortField 
           and recordSortFieldReverse 
           and header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = false;
               header:SetText(header.baseText .. ARROW_UP);
        elseif recordSortField == self.recordSortField 
           and header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = true;
               header:SetText(header.baseText .. ARROW_DOWN);
        elseif header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = false;
        else   header:SetText(header.baseText)
        end;
    end;
    Finder:UpdateTitle("Display");
  end;
   
  local currentCol = 1;

  local function makeListHeader(info)
    local newHeader    = AceGUI:Create("InteractiveLabel");
    newHeader.info     = info;
    newHeader.col      = currentCol;
    currentCol         = currentCol + 1;
    newHeader.baseText = info.title;
    newHeader:SetRelativeWidth(info.width);

    if     recordSortField == info.method 
       and recordSortFieldReverse
    then   newHeader:SetText(info.title .. ARROW_UP);
    elseif recordSortField == info.method 
    then   newHeader:SetText(info.title .. ARROW_DOWN);
    else   newHeader:SetText(info.title);
    end;

    
    newHeader:SetFont("Fonts\\ARIALN.TTF", 14);
    -- newHeader:SetFontObject(GameFontNormal);
    newHeader:SetColor(1, 1, 0);
    newHeader.recordSortField = info.sorting or info.method;
    newHeader:SetCallback("OnClick", ListHeader_SetRecordSortField);
    headers:AddChild(newHeader);
    headers.list[info.title] = newHeader;

    return newHeader;
  end;
 
  for i, info in ipairs(columns) do makeListHeader(info); end;

  local function buildLineFromPlayerRecord(playerRecord)
    local line = AceGUI:Create("SimpleGroup");
          line:SetFullWidth(true);
          line:SetLayout("Flow");
          line.playerName = playerName;

    for i, info in ipairs(columns)
    do  
        local field = AceGUI:Create("InteractiveLabel")
        field:SetRelativeWidth(info.width)
        field:SetFont("Fonts\\ARIALN.TTF", 14);
        -- field:SetFontObject(GameFontNormal);

        local valueFunc = playerRecord[info.method]
        local text, disabled = valueFunc(playerRecord);

        field:SetText(text);
        field:SetDisabled(disabled);

        if     info.tooltip
        then   field:SetCallback("OnEnter",
                 function(this, ...)
                   showTooltip(this,
                     { anchor = "ANCHOR_BOTTOM", 
                       lines = { info.tooltip },
                       title = info.ttTitleMethod 
                                 and playerRecord[info.ttTitleMethod](playerRecord)
                                  or info.ttTitle
                                  or info.title,
                     }
                   );
                 end);
               field:SetCallback("OnLeave", hideTooltip);
        elseif info.ttMethod and playerRecord[info.ttMethod]
        then   field:SetCallback("OnEnter",
                 function(this, ...)
                   local tooltip = 
                         { 
                           title = info.ttTitleMethod 
                                    and playerRecord[info.ttTitleMethod](playerRecord)
                                     or info.ttTitle,
                           anchor = "ANCHOR_TITLE",
                         };
                   tooltip.lines, tooltip.columns, tooltip.icon = 
                     playerRecord[info.ttMethod](playerRecord);
                   showTooltip(this, tooltip);
                 end);
               field:SetCallback("OnLeave", hideTooltip);
        end;

        if   info.callback and RP_Find.PlayerMethods[info.callback]
        then 
             field:SetCallback("OnClick", 
               function(self, ...) 
                 local callback = playerRecord[info.callback]; 
                 callback(playerRecord, ...); 
                end);
        end;

        line:AddChild(field)
    end;

    return line;
  end;

  local playerList = AceGUI:Create("SimpleGroup");
  playerList:SetFullWidth(true);
  playerList:SetFullHeight(true);
  playerList:SetLayout("Flow");
  panelFrame:AddChild(playerList);

  local function playerList_Update(playerList)
    playerList:ReleaseChildren();

    local function buildNavbar(count, pos)
      if count == 0 then return end;

      local function buildNavbutton(num)
        local btn = AceGUI:Create("InteractiveLabel");
        btn:SetText(tostring(num + 1))
        btn.num = num;
        btn:SetWidth(20);
        btn:SetFontObject(GameFontColor);
        btn:SetColor(GREEN_FONT_COLOR:GetRGBA())
        btn:SetCallback("OnClick",
          function(self, event, button)
            Finder.pos = self.num;
            RP_Find:Update("Display")
          end);
        return btn;
      end;

      local navbar = AceGUI:Create("InlineGroup");
            navbar:SetFullWidth(true);
            navbar:SetLayout("Flow");

      local labelGroup = AceGUI:Create("SimpleGroup");
            labelGroup:SetRelativeWidth(0.1);
            labelGroup:SetLayout("Flow");
      navbar:AddChild(labelGroup);

      local label = AceGUI:Create("Label");
            label:SetText("Page");
            label:SetFullWidth(true);
            label:SetFontObject(GameFontNormal);
      labelGroup:AddChild(label);

      local buttonGroup = AceGUI:Create("SimpleGroup");
            buttonGroup:SetLayout("Flow");
            buttonGroup:SetRelativeWidth(0.88);
      navbar:AddChild(buttonGroup);

      for i = 0, count, 1
      do  local btn = buildNavbutton(i);
          if i == pos then btn:SetDisabled(true); end;
          buttonGroup:AddChild(btn);
      end;

      playerList:AddChild(navbar);
    end;

    local totalCount = 0;
    local playerRecordList;

    playerRecordList, filteredCount, totalCount = 
      RP_Find:GetAllPlayerRecords(
        activeFilters, 
        searchPattern
      );

    if   filteredCount == 0
    then local nothingFound = AceGUI:Create("Label");
               nothingFound:SetFullWidth(true);
               nothingFound:SetText(L["Display Nothing Found"]);
         playerList:AddChild(nothingFound);
         return 
    end;

    table.sort(playerRecordList, sortPlayerRecords);
  
    Finder.pos = Finder.pos or 0;

    local stop;
    local size      = RP_Find.db.profile.config.rowsPerPage or 15;
    local shift     = Finder.pos * size;
    local div = math.floor(filteredCount/size);
    local mod = filteredCount % size;

    if mod == 0          then div  = div - 1;  mod = size; end;
    if div == Finder.pos then stop = mod else stop = size; end;

    for i = 1, stop, 1
    do  local index = i + shift;
        local playerRecord = playerRecordList[index];
        playerList:AddChild(
          buildLineFromPlayerRecord(playerRecord)
        );
    end;

    if not RP_Find.timers.playerList
    then   RP_Find.timers.playerList = 
             RP_Find:ScheduleRepeatingTimer("Update", 10); 
    end;

    buildNavbar(div, Finder.pos);

  end;

  function panelFrame:Update(...) 
    setActiveFilters();
    RP_Find.Finder:UpdateTitle();
    playerList_Update(playerList, ...) 
  end;

  return panelFrame;
end;

Finder.TitleFunc = {};
Finder.UpdateFunc= {};

function Finder.TitleFunc.Display(self, ...)
  local _, filteredCount, totalCount = 
    RP_Find:GetAllPlayerRecords(self.activeFilters, self.searchPattern);
 
  if filteredCount ~= totalCount
  then self:SetTitle(
         string.format(
           L["Format Finder Title Display Filtered"], 
           totalCount,
           filteredCount
         )
       );
  else self:SetTitle(
         string.format(
           L["Format Finder Title Display"], 
           totalCount
         )
       );
  end;
end;

function Finder.TitleFunc.LFG(self, ...)
  if   UnitLevel("player") >= 50
  then self:SetTitle(
              string.format(
                L["Format Finder Title LFG"], 
                RP_Find:CountLFGGroups()
              )
            );
  else self:SetTitle(L["Format Finder Title LFG Disabled"]);
  end;
end;

function Finder.TitleFunc.Ads(self, ...) 
  self:SetTitle(RP_Find.addOnTitle .. "- Your Ad"); 
end;

function Finder.TitleFunc.Tools(self, ...) 
  self:SetTitle(L["Format Finder Title Tools"]); 
end;

function Finder.UpdateFunc.Display(self, ...) 
  self.TabGroup.current:Update(); 
end;

function Finder.UpdateFunc.LFG(self, ...)     
  self.TabGroup.current:Update();
end;

function Finder.UpdateFunc.Tools(self, ...)   
  self.TabGroup.current:Update(); 
end;

function Finder.UpdateFunc.Ads(self, ...)     
  self.TabGroup.current:Update(); 
end;

function Finder:UpdateTitle(event, ...)
  if self.updatesDisabled then return end;
  local title = self.TitleFunc[self.currentTab]
  if title then title(self) end;
end;

function Finder:UpdateContent(event, ...)
  if self.updatesDisabled then return end;
  self:PauseLayout();
  local update = self.UpdateFunc[self.currentTab]
  if update then update(self) end;
  self:ResumeLayout();
  self:DoLayout();
end;

function Finder:Update(tab)
  if self.updatesDisabled then return end;
  if not self:IsShown()   then return end; -- only update if we're shown
  if not tab or self.currentTab == tab
  then self:UpdateContent();
       self:UpdateTitle();
  end;
end;

function RP_Find:IsAdIncomplete()
  return not (self.db.profile.ad.title ~= "")
     and not (self.db.profile.ad.body ~= "");
end;

function RP_Find:ShouldSendAdBeDisabled()
  return time() - (self:Last("sendAd") or 0) < 1 * SECONDS_PER_MIN
      or self.timers.autoSend
      or self.db.profile.autoSend
      or self:IsAdIncomplete();
end;

function Finder.MakeFunc.Ads(self)
  local panelFrame = AceGUI:Create("SimpleGroup");
  panelFrame:SetFullWidth(true);
  panelFrame:SetLayout("Flow");
  
  local sendAdButton        = AceGUI:Create("Button");
  local clearAdButton       = AceGUI:Create("Button");
  local previewAdButton     = AceGUI:Create("Button");
  local autoSendStartButton = AceGUI:Create("Button");
  local autoSendStopButton  = AceGUI:Create("Button");
  local adultToggle         = AceGUI:Create("CheckBox");
  local titleField          = AceGUI:Create("EditBox");
  local bodyField           = AceGUI:Create("MultiLineEditBox");
  local spacer1             = AceGUI:Create("Label");
  local spacer2             = AceGUI:Create("Label");
  local spacer3             = AceGUI:Create("Label");
  local spacer4             = AceGUI:Create("Label");
  local spacer5             = AceGUI:Create("Label");

  spacer1:SetRelativeWidth(0.02);
  spacer2:SetRelativeWidth(0.01);
  spacer3:SetRelativeWidth(0.01);
  spacer4:SetRelativeWidth(0.01);
  spacer5:SetRelativeWidth(0.01);

  local currentProfile;

  local function loadCurrentProfileAd()
    if   RP_Find.db:GetCurrentProfile() ~= currentProfile
    then adultToggle:SetValue(RP_Find.db.profile.ad.adult);
         titleField:SetText(RP_Find.db.profile.ad.title);
         bodyField:SetText(RP_Find.db.profile.ad.body);
         currentProfile = RP_Find.db:GetCurrentProfile();
    end;
  end;

  local function showPreview(self, event, button)
    if RP_Find.adFrame:IsShown() and RP_Find.adFrame:GetPlayerName() == RP_Find.me
    then RP_Find.adFrame:Hide(); return
    end;

    local myRecord = RP_Find:LoadSelfRecord();
    myRecord:UnpackMSPData();
    myRecord:UnpackTRP3Data();

    local race = myRecord:GetRPRace();
    if race == "" then race, _, _ = UnitRace("player"); myRecord:Set("MSP-RA", race); end;

    local class = myRecord:GetRPClass();
    if class == "" then class, _, _ = UnitClass("player"); myRecord:Set("MSP-RC", class); end;

    myRecord:Set("ad_title", RP_Find.db.profile.ad.title);
    myRecord:Set("ad_body",  RP_Find.db.profile.ad.body);
    myRecord:Set("ad_adult", RP_Find.db.profile.ad.adult);
    RP_Find.adFrame:SetPlayerRecord(myRecord);
    RP_Find.adFrame:Show();
  end;

  RP_Find.ShowPreview = showPreview;

  clearAdButton:SetText(L["Button Clear Ad"]);
  clearAdButton:SetRelativeWidth(0.19);
  clearAdButton:SetCallback("OnClick",
    function(Self, event, ...)
      titleField:ResetValue();
      bodyField:ResetValue();
      adultToggle:ResetValue();
      RP_Find:Notify(L["Notify Ad Cleared"]);
      RP_Find:SendMessage("RP_FIND_CHANGE_AD");
      panelFrame:Update("Ads");
    end);

  clearAdButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(
        self, 
        { title = L["Button Clear Ad"], 
          lines = 
          { "Click to clear your ad.", 
            "Warning: This can't be undone." 
          },
        }
      );
    end);
  clearAdButton:SetCallback("OnLeave", hideTooltip);

  previewAdButton:SetText(L["Button Preview Ad"]);
  previewAdButton:SetRelativeWidth(0.19);
  previewAdButton:SetCallback("OnClick", showPreview);

  previewAdButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Button Preview Ad"], lines = { "Preview your ad." } });
    end);

  previewAdButton:SetCallback("OnLeave", hideTooltip);
    
  sendAdButton:SetText(L["Button Send Ad"]);
  sendAdButton:SetRelativeWidth(0.19);
  sendAdButton:SetCallback("OnClick", 
    function(self, event, ...) 
      RP_Find:SendLFRPAd(true) -- true = interactive
    end);

  sendAdButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(
        self, 
        { title = L["Button Send Ad"], 
          lines = 
          { "Click this to send your ad.", 
            "You can send an ad only once per minute." 
          } 
        }
      )
    end);
  sendAdButton:SetCallback("OnLeave", hideTooltip);

  autoSendStartButton:SetText("Autosend Ad");
  autoSendStartButton:SetRelativeWidth(0.19);
  autoSendStartButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find.db.profile.ad.autoSend = true;
      RP_Find:Notify("Starting autosend.");
      RP_Find:StartOrStopAutoSend();
    end);
  autoSendStartButton:SetCallback("OnEnter",
    function(self, event, button)
      showTooltip(self, { title = "Autosend Ad", lines = { "Click to start sending your ad once per hour." } })
    end);
  autoSendStartButton:SetCallback("OnLeave", hideTooltip)

  autoSendStopButton:SetText("Stop Autosend");
  autoSendStopButton:SetRelativeWidth(0.19);
  autoSendStopButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find.db.profile.ad.autoSend = false;
      RP_Find:Notify("Autosend cancelled.");
      RP_Find:StartOrStopAutoSend();
    end);
  autoSendStopButton:SetCallback("OnEnter",
    function(self, event, button)
      showTooltip(self, { title = "Cancel Autosend", lines = { "Click to cancel your ad that is currently autosent every hour." } });
    end);
  autoSendStopButton:SetCallback("OnLeave", hideTooltip);

  titleField:SetLabel(L["Field Ad Title"]);
  titleField:SetText(RP_Find.db.profile.ad.title);
  titleField:SetRelativeWidth(0.60);
  titleField:DisableButton(true);
  titleField:SetMaxLetters(128);
  titleField:SetCallback("OnTextChanged",
    function(self, event, value)
      RP_Find.db.profile.ad.title = value;
      RP_Find:SendMessage("RP_FIND_CHANGE_AD");
      panelFrame:Update("Ads");
    end);

  function titleField:ResetValue()
     RP_Find.db.profile.ad.title = RP_Find.defaults.profile.ad.title;
     self:SetText(RP_Find.defaults.profile.ad.title);
  end;

  titleField:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Field Ad Title"], lines = { "Enter a title for your ad." } });
    end);
  titleField:SetCallback("OnLeave", hideTooltip);

  adultToggle:SetLabel(L["Field Adult Ad"]);
  adultToggle:SetRelativeWidth(0.38);
  adultToggle:SetValue(RP_Find.db.profile.ad.adult)
  adultToggle:SetCallback("OnValueChanged",
    function(self, event, value)
      RP_Find.db.profile.ad.adult = value;
      panelFrame:Update("Ads");
    end);

  function adultToggle:ResetValue()
     RP_Find.db.profile.ad.adult = RP_Find.defaults.profile.ad.adult;
     self:SetValue(RP_Find.defaults.profile.ad.adult);
  end;

  adultToggle:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = "Adult Ad", lines = { "Check this button to show that your ad is an adult ad.", "If your ad contains certain keywords, it will automatically be set as an adult ad, regardless of this setting." } });
    end);
  adultToggle:SetCallback("OnLeave", hideTooltip);

  bodyField:DisableButton(true);
  bodyField:SetNumLines(10);
  bodyField:SetMaxLetters(1024);
  bodyField:SetCallback("OnTextChanged",
    function(self, event, value)
      RP_Find.db.profile.ad.body = value;
      RP_Find:SendMessage("RP_FIND_CHANGE_AD");
      panelFrame:Update("Ads");
    end);

  function bodyField:ResetValue()
     RP_Find.db.profile.ad.body = RP_Find.defaults.profile.ad.body;
     self:SetText(RP_Find.defaults.profile.ad.body);
  end; 

  bodyField:SetLabel(L["Field Ad Text"]);
  bodyField:SetText(RP_Find.db.profile.ad.body);
  bodyField:SetFullWidth(true);

  bodyField:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Field Ad Text"], lines = { "Set the body of your ad." } });
    end);
  bodyField:SetCallback("OnLeave", hideTooltip);

  RP_Find:RegisterMessage("RP_FIND_AUTOSEND_START",
    function(self, message)
      _ = bodyField and bodyField:SetDisabled(true);
      _ = titleField and titleField:SetDisabled(true);
      _ = adultToggle and adultToggle:SetDisabled(true);
      _ = sendAdButton and sendAdButton:SetDisabled(true);
      _ = clearAdButton and clearAdButton:SetDisabled(true);
      _ = autoSendStopButton and autoSendStopButton:SetDisabled(false);
      _ = autoSendStartButton and autoSendStartButton:SetDisabled(true);
    end);

  RP_Find:RegisterMessage("RP_FIND_AUTOSEND_STOP",
    function(self, message)
      _ = bodyField and bodyField:SetDisabled(false);
      _ = titleField and titleField:SetDisabled(false);
      _ = adultToggle and adultToggle:SetDisabled(false);
      _ = sendAdButton and sendAdButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
      _ = clearAdButton and clearAdButton:SetDisabled(false);
      _ = autoSendStopButton and autoSendStopButton:SetDisabled(true);
      _ = autoSendStartButton and autoSendStartButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
    end);

  local function sendAdStatusChange()
    bodyField:SetDisabled(RP_Find.timers.autoSend);
    titleField:SetDisabled(RP_Find.timers.autoSend);
    adultToggle:SetDisabled(RP_Find.timers.autoSend);
    clearAdButton:SetDisabled(RP_Find.timers.autoSend);
    sendAdButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
    autoSendStartButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
    autoSendStopButton:SetDisabled(not RP_Find.timers.autoSend);
  end;

  RP_Find:RegisterMessage("RP_FIND_SEND_AD",               sendAdStatusChange);
  RP_Find:RegisterMessage("RP_FIND_SEND_AD_STATUS_CHANGE", sendAdStatusChange);

  RP_Find:RegisterMessage("RP_FIND_CHANGE_AD",
    function(self, message)
      local adult = RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.text)
                    or RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.body);
      if adult
      then RP_Find.db.profile.ad.adult = true;
           adultToggle:SetValue(true);
      end;
      sendAdButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
      autoSendStartButton:SetDisabled(RP_Find:ShouldSendAdBeDisabled());
    end);

  function panelFrame:Update() 
    sendAdStatusChange();
    loadCurrentProfileAd();

    -- clearAdButton:SetDisabled(isAdIncomplete());
    -- previewAdButton:SetDisabled(isAdIncomplete());
    -- enableOrDisableSendAd();
    -- if   not RP_Find.db.profile.ad.adult and 
    --      (RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.title)
    --       or RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.body)
    --       )
    -- then RP_Find.db.profile.ad.adult = true;
    --      adultToggle:SetValue(true);
    -- end;
  end;

  -- this order determines what order they're shown in
  --
  panelFrame:AddChild(titleField);
  panelFrame:AddChild(spacer1);
  panelFrame:AddChild(adultToggle);
  panelFrame:AddChild(bodyField);
  panelFrame:AddChild(clearAdButton);
  panelFrame:AddChild(spacer2);
  panelFrame:AddChild(previewAdButton);
  panelFrame:AddChild(spacer3);
  panelFrame:AddChild(sendAdButton);
  panelFrame:AddChild(spacer4);
  panelFrame:AddChild(autoSendStartButton);
  panelFrame:AddChild(spacer5);
  panelFrame:AddChild(autoSendStopButton);

  return panelFrame;
end;

function RP_Find.enableOrDisableSendAd()
  RP_Find:SendMessage("RP_FIND_SEND_AD_STATUS_CHANGE");
end;

function Finder.MakeFunc.LFG(self)
  local panelFrame = AceGUI:Create("SimpleGroup");
  panelFrame:SetFullWidth(true);
  panelFrame:SetLayout("Flow");

  local headline = AceGUI:Create("Heading");
  headline:SetFullWidth(true);
  headline:SetText(L["Tab Looking for Group"]);

  panelFrame:AddChild(headline);

  local explainSub50 = AceGUI:Create("Label");
  explainSub50:SetFullWidth(true);
  explainSub50:SetText(L["Explain LFG Disabled"]);

  panelFrame:AddChild(explainSub50);

  panelFrame.lower = AceGUI:Create("SimpleGroup");
  panelFrame.lower:SetFullWidth(true);
  panelFrame.lower:SetLayout("Flow");

  panelFrame:AddChild(panelFrame.lower);

  panelFrame.left = AceGUI:Create("InlineGroup");
  panelFrame.left:SetRelativeWidth(0.5);
  panelFrame.left:SetLayout("Flow");
  panelFrame.left:SetTitle(L["Label LFG Search"]);
  panelFrame.lower:AddChild(panelFrame.left);

  panelFrame.right = AceGUI:Create("InlineGroup");
  panelFrame.right:SetLayout("Flow");
  panelFrame.right:SetRelativeWidth(0.5);
  panelFrame.right:SetTitle(L["Label List Your Group"]);
  panelFrame.lower:AddChild(panelFrame.right);

  local searchButton = AceGUI:Create("Button");
        searchButton:SetText("Search");
        searchButton:SetFullWidth(true);
        panelFrame.left:AddChild(searchButton);

  local searchFilter = AceGUI:Create("EditBox");
        searchFilter:SetLabel(L["Field LFG Filter"]);
        searchFilter:SetFullWidth(true);
  panelFrame.left:AddChild(searchFilter);

  local newGroupTitle = AceGUI:Create("EditBox");
        newGroupTitle:SetLabel(L["Field LFG Title"]);
        newGroupTitle:SetFullWidth(true);
  
  panelFrame.right:AddChild(newGroupTitle);

  local newGroupDetails = AceGUI:Create("MultiLineEditBox");
        newGroupDetails:SetFullWidth(true);
        newGroupDetails:SetLabel(L["Field LFG Details"]);
        newGroupDetails:SetNumLines(6);
        newGroupDetails:DisableButton(true);

  panelFrame.right:AddChild(newGroupDetails);

  local listGroupButton = AceGUI:Create("Button");
        listGroupButton:SetText(L["Button List Group"]);
        listGroupButton:SetFullWidth(true);

  panelFrame.right:AddChild(listGroupButton);
  
  if UnitLevel("player") < 50
  then searchButton:SetDisabled(true);
       searchFilter:SetDisabled(true);
       newGroupTitle:SetDisabled(true);
       newGroupDetails:SetDisabled(true);
       listGroupButton:SetDisabled(true);
  else explainSub50:SetText();
  end;

  function panelFrame:Update() return end;
  return panelFrame;

end;

function Finder.MakeFunc.Tools(self)
  local panelFrame = AceGUI:Create("SimpleGroup");
        panelFrame:SetFullWidth(true);
        panelFrame:SetLayout("Flow");

  local trp3MapScan = AceGUI:Create("InlineGroup");
        trp3MapScan:SetFullWidth(true);
        trp3MapScan:SetLayout("Flow");
        trp3MapScan:SetTitle(L["Tool TRP3 Map Scan"]);
  panelFrame:AddChild(trp3MapScan);

  local zoneID = C_Map.GetBestMapForUnit("player")
 
  if   not menu.zone[zoneID] and UnitFactionGroup("player") == "Alliance"
  then zoneID = 84
  elseif not menu.zone[zoneID]
  then zoneID = 85;
  end;

  Finder.scanZone = zoneID;

  local zoneInfo = C_Map.GetMapInfo(zoneID);

  local trp3MapScanZone          = AceGUI:Create("Dropdown");
  local trp3MapScanButton        = AceGUI:Create("Button");
  local trp3MapScanResultsButton = AceGUI:Create("Button");
  local spacer                   = AceGUI:Create("Label");
  local spacer2                  = AceGUI:Create("Label");

  local function updateTrp3MapScan()
    if   time() - (RP_Find:Last("mapScan") or 0) >= 60
         and trp3MapScanButton
         and trp3MapScanZone
    then trp3MapScanButton:SetDisabled(false);
         trp3MapScanZone:SetDisabled(  false);
         Finder.buttons.scan:SetDisabled(false);
    else trp3MapScanButton:SetDisabled( true);
         trp3MapScanZone:SetDisabled(   true);
         Finder.buttons.scan:SetDisabled(true);
    end;

    if   RP_Find:Last("mapScanZone")
         and time() - (RP_Find:Last("mapScan") or 0) < 5 * SECONDS_PER_MIN
         and trp3MapScanResultsButton
    then trp3MapScanResultsButton:SetDisabled(false)
    else trp3MapScanResultsButton:SetDisabled( true)
    end;
  end;

  trp3MapScanZone:SetLabel(L["Field Zone to Scan"]);
  trp3MapScanZone:SetRelativeWidth(0.40);
  trp3MapScanZone:SetList(menu.zone, menu.zoneOrder);
  trp3MapScanZone:SetValue(zoneID);
  trp3MapScanZone:SetText(zoneInfo.name);
  trp3MapScanZone:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Field Zone to Scan"], 
        lines = { "Select a zone that you want to a TRP3 map scan request to." } });
    end)
  trp3MapScanZone:SetCallback("OnLeave", hideTooltip);
  trp3MapScanZone:SetCallback("OnValueChanged",
    function(self, event, value, checked)
      trp3MapScanResultsButton:SetDisabled(true);
      RP_Find.Finder.scanZone = value;
    end);

  spacer:SetRelativeWidth(0.01);

  trp3MapScanButton:SetRelativeWidth(0.20);
  trp3MapScanButton:SetText(L["Button Scan Now"]);
  trp3MapScanButton:SetCallback("OnEnter",
    function(self, event, ...)
      local zoneInfo = C_Map.GetMapInfo(RP_Find.Finder.scanZone);
      showTooltip(self, { title = L["Button Scan Now"],
        lines = { "This will send a (silent) map scan request to all players in " ..
                  zoneInfo.name .. " who use TRP3.",
                  " ", 
                  "Players whose TRP3 addons respond to the map scan request will be added to your database." },
        });
    end);
  trp3MapScanButton:SetCallback("OnLeave", hideTooltip);
  trp3MapScanButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find:SendTRP3Scan(RP_Find.Finder.scanZone)
      RP_Find:ScheduleTimer(updateTrp3MapScan, 60); -- one-shot timer
      updateTrp3MapScan()
    end);

  spacer2:SetRelativeWidth(0.01);

  trp3MapScanResultsButton:SetRelativeWidth(0.20);
  trp3MapScanResultsButton:SetText(L["Button Scan Results"]);
  trp3MapScanResultsButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Button Scan Results"], 
         lines = { "Click this button to switch to the database tab.",
                   " ",
                   "Your filter will be set to show players who responded to your last map scan." } });
    end);
  trp3MapScanResultsButton:SetCallback("OnLeave", hideTooltip);
  trp3MapScanResultsButton:SetCallback("OnClick",
    function(self, event, button)
      for filterID, filterInfo in pairs(Finder.filterList)
      do  filterInfo.enabled = (filterID == "MatchesLastMapScan");
      end;
      Finder:LoadTab("Display");
    end);

  trp3MapScan:AddChild(trp3MapScanZone)
  trp3MapScan:AddChild(spacer);
  trp3MapScan:AddChild(trp3MapScanButton);
  trp3MapScan:AddChild(spacer2);
  trp3MapScan:AddChild(trp3MapScanResultsButton);

  local massPing = AceGUI:Create("InlineGroup");
  massPing:SetFullWidth(true);
  massPing:SetTitle("Mass Ping Tool");
  panelFrame:AddChild(massPing);

  local pingAllButton = AceGUI:Create("Button");
  pingAllButton:SetText("Ping All");
  pingAllButton:SetRelativeWidth(0.20);
  pingAllButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = "Ping All", 
        lines = { "This tool will send a ping request to all players in your database.",
                  " ",
                  "Players who don't autorespond within a minute will be removed from your database.",
                  " ",
                  "You have to wait 60 minutes before sending a new mass ping." } });
    end);
  pingAllButton:SetCallback("OnLeave", hideTooltip);
  pingAllButton:SetCallback("OnClick",
    function(self, event, button)
      self:SetDisabled(true);
      RP_Find:Notify("Pings sent to all loaded players; anyone who doesn't respond within a minute will be removed from your database.");
      RP_Find:PingAll();
    end);

  local function updatePingAllButton()
    if time() - (RP_Find:Last("pingAll") or 0) > SECONDS_PER_HOUR
    then pingAllButton:SetDisabled(false)
    else pingAllButton:SetDisabled(true)
    end;
  end;

  massPing:AddChild(pingAllButton);
  RP_Find:RegisterMessage("RP_FIND_PING_ALL", updatePingAllButton);

  function panelFrame:Update() 
    updateTrp3MapScan(); 
    updatePingAllButton();
  end;

  return panelFrame;
end;

function RP_Find:PingAll()
  if   time() - ( self:Last("pingAll") or 0) > SECONDS_PER_HOUR
  then 
  self:SetLast("pingAll");
       if self.timers.sendPing
       then self:CancelTimer(self.timers.sendPing);
       end;
       self.timers.sendPing = self:ScheduleTimer("CheckAllPings", SECONDS_PER_MIN);
       for _, playerRecord in ipairs(self:GetAllPlayerRecords())
       do  self:SendPing(playerRecord:GetPlayerName())
       end;
       RP_Find:SendMessage("RP_FIND_PING_ALL");
  end;
end;

Finder:Hide();
RP_Find.Finder = Finder;

function RP_Find:LoadSelfRecord() 
  self.my = self:GetPlayerRecord(self.me, self.realm); 
  if msp and self.msp then self.my:UnpackMSPData();  end;
  if addon.totalRP3   then self.my:UnpackTRP3Data(); end;
  self.my:Set("rpFindUser", true);
  return self.my;
end;

local function optionsSpacer(width)
  return 
  { type  = "description",
    name  = " ",
    width = width or 0.1,
    order = source_order()
  }
end

function RP_Find:RedoSetupOnProfileChange()
  self:LoadSelfRecord();
  self.Finder:SetDimensions();
  self.Finder:ResizeButtonBar();
  self.Finder:ResetProfileButton();
  self.Finder:Update(self.Finder.currentTab);
end;

function RP_Find:OnInitialize()

  self.db = AceDB:New(configDB, self.defaults);
  self.db.RegisterCallback(self, "OnProfileChanged", "RedoSetupOnProfileChange");
  self.db.RegisterCallback(self, "OnProfileCopied",  "RedoSetupOnProfileChange");
  self.db.RegisterCallback(self, "OnProfileReset",   "RedoSetupOnProfileChange");
  
  self.options             =
  { type                   = "group",
    name                   = RP_Find.addOnTitle,
    order                  = source_order(),
    args                   =
    { versionInfo          =
      { type               = "description",
        name               = L["Version Info"],
        order              = source_order(),
        fontSize           = "medium",
        width              = "full",
        hidden             = function() UpdateAddOnMemoryUsage() return false end,
      },
      configOptions        =
      { type               = "group",
        name               = L["Config Options"],
        order              = source_order(),
        args               =
        {
          showIcon         =
          { name           = L["Config Show Icon"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config Show Icon Tooltip"],
            get            = function() return not self.db.profile.minimapbutton.hide end,
            set            = function(info, value) 
                                self.db.profile.minimapbutton.hide = not value 
                                self:ShowOrHideMinimapButton(); 
                             end,
            width          = "full",
          },
          monitorMSP       =
          { name           = L["Config Monitor MSP"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config Monitor MSP Tooltip"],
            get            = function()     return self.db.profile.config.monitorMSP         end,
            set            = function(info, value) self.db.profile.config.monitorMSP = value end,
            disabled       = function() return not msp end,
            width          = "full",
          },
          monitorTRP3      =
          { name           = L["Config Monitor TRP3"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config Monitor TRP3 Tooltip"],
            get            = function() return self.db.profile.config.monitorTRP3 end,
            set            = function(info, value) self.db.profile.config.monitorTRP3  = value end,
            width          = "full",
          },
          autoSendPing     =
          { name           = L["Config Auto Send Ping"],
            type           = "toggle",
            order          = source_order(),
            width          = "full",
            desc           = L["Config Auto Send Ping Tooltip"],
            get            = function() return self.db.profile.config.autoSendPing end,
            set            = function(info, value) self.db.profile.config.autoSendPing = value end,
            disabled       = function() return not self:HasRPClient() 
                                            or not self.db.profile.config.monitorTRP3 
                             end,
          },
          seeAdultAds =
          { name           = L["Config See Adult Ads"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config See Adult Ads Tooltip"],
            get            = function() return self.db.profile.config.seeAdultAds end,
            set            = function(info, value) self.db.profile.config.seeAdultAds = value end,
            width          = "full",
          },
          lightenColors =
          { type = "toggle",
            order = source_order(),
            width = "full",
            name = "Lighten Colors",
            desc = "Some players' RP names and classes contain color codes that are too dark to read." ..
                   " Check this box to automatically lighten the colors.",
            get = function() return self.db.profile.config.lightenColors end,
            set = function(info, value) self.db.profile.config.lightenColors = value
                    self.db.profile.config.infoColumn = value 
                    if   self.Finder:IsShown() 
                    and  self.Finder.currentTab == "Display" 
                    then self.Finder:Update();
                    end
                  end,
          },

          infoColumn       =
          { type = "select",
            order = source_order(),
            name = L["Config Info Column"],
            desc = L["Config Info Column Tooltip"],
            get = function() return self.db.profile.config.infoColumn end,
            set = function(info, value) 
                    self.db.profile.config.infoColumn = value 
                    if   self.Finder:IsShown() 
                    and  self.Finder.currentTab == "Display" 
                    then self.Finder:Update();
                    end
                  end,
            sorting = menu.infoColumnOrder,
            width = 1,
            values = menu.infoColumn,
          },
          spacerInfoColumn = optionsSpacer(),
          infoColumnTags =
          { type = "input",
            order = source_order(),
            name = function()
                     if self.addonList.RP_Tags 
                     then return L["Config Info Column Tags"] 
                     else return L["Config Info Column Tags Disabled"]
                     end
                   end,
            desc = L["Config Info Column Tags Tooltip"],
            get = function() return self.db.profile.config.infoColumnTags end,
            set = function(info, value) self.db.profile.config.infoColumnTags = value end,
            width = 1,
            disabled = function() return not self.addonList.RP_Tags end,
          },
          nameTooltip =
          { name = "Name Column Tooltip",
            type = "group",
            inline = true,
            width = "full",
            order = source_order(),
            args =
            { 
              icon = 
              { name = "Icon",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's icon in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.icon end,
                set = function(info, value) self.db.profile.config.nameTooltip.trial = icon end,
                disabled = function() return not self:HasRPClient(); end,
              },

              status = 
              { name = "Status",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's IC/OOC status in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.status end,
                set = function(info, value) self.db.profile.config.nameTooltip.status = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              class = 
              { name = "Class",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's class in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.class end,
                set = function(info, value) self.db.profile.config.nameTooltip.class = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              race = 
              { name = "Race",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's race in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.race end,
                set = function(info, value) self.db.profile.config.nameTooltip.race = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              pronouns = 
              { name = "Pronouns",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's pronouns in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.pronouns end,
                set = function(info, value) self.db.profile.config.nameTooltip.pronouns = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              title = 
              { name = "Title",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's title in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.title end,
                set = function(info, value) self.db.profile.config.nameTooltip.title = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              age = 
              { name = "Age",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's age in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.age end,
                set = function(info, value) self.db.profile.config.nameTooltip.age = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              zone = 
              { name = "Zone",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's current zone in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.zone end,
                set = function(info, value) self.db.profile.config.nameTooltip.zone = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              height = 
              { name = "Height",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's height in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.height end,
                set = function(info, value) self.db.profile.config.nameTooltip.height = value end,
                disabled = function() return not self:HasRPClient(); end,
              },
              weight = 
              { name = "Weight",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's weight in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.weight end,
                set = function(info, value) self.db.profile.config.nameTooltip.weight = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              trial = 
              { name = "Trial",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's trial status in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.trial end,
                set = function(info, value) self.db.profile.config.nameTooltip.trial = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              addon = 
              { name = "Addon",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's RP addon in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.addon end,
                set = function(info, value) self.db.profile.config.nameTooltip.addon = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              currently =
              { name = "Currently",
                type = "toggle",
                width = 1,
                order = source_order(),
                desc = "Display the character's currently in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.currently end,
                set = function(info, value) self.db.profile.config.nameTooltip.currently = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

              oocinfo =
              { name = "OOC Info",
                type = "toggle",
                width = 1,
                order = source_order(),
                desc = "Display the character's OOC info in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.oocinfo end,
                set = function(info, value) self.db.profile.config.nameTooltip.oocinfo = value end,
                disabled = function() return not self:HasRPClient(); end,
              },

            },
          },
          buttonBarSize    =
          { name           = L["Config Button Bar Size"],
            type           = "range",
            order          = source_order(),
            desc           = L["Config Button Bar Size Tooltip"],
            width          = 2.1,
            min            = MIN_BUTTON_BAR_SIZE,
            max            = MAX_BUTTON_BAR_SIZE,
            step           = 2,
            get            = function() return self.db.profile.config.buttonBarSize end,
            set            = function(info, value) 
                               self.db.profile.config.buttonBarSize = value 
                               Finder:ResizeButtonBar(value)
                             end,
          },
          trp3Group        =
          { name           = L["Config TRP3"],
            type           = "group",
            inline         = true,
            order          = source_order(),
            args           =
            {
              instructTRP3 =
              { name       = L["Instruct TRP3"],
                type       = "description",
                order      = source_order(),
                width      = "full"
              },
              alertTRP3Scan =
              { name        = L["Config Alert TRP3 Scan"],
                type        = "toggle",
                order       = source_order(),
                desc        = L["Config Alert TRP3 Scan Tooltip"],
                get         = function() return self.db.profile.config.alertTRP3Scan end,
                set         = function(info, value) self.db.profile.config.alertTRP3Scan    = value end,
                disabled    = function() return not self.db.profile.config.monitorTRP3 
                                         or self.db.profile.config.notifyMethod == "none" end,
                width       = "full",
              },
              spacer1          = optionsSpacer(),
              alertAllTRP3Scan =
              { name           = L["Config Alert All TRP3 Scan"],
                type           = "toggle",
                order          = source_order(),
                desc           = L["Config Alert All TRP3 Scan Tooltip"],
                get            = function() return self.db.profile.config.alertAllTRP3Scan end,
                set            = function(info, value) self.db.profile.config.alertAllTRP3Scan   = value end,
                disabled       = function() return not self.db.profile.config.alertTRP3Scan 
                                            or not self.db.profile.config.alertTRP3Scan
                                            or self.db.profile.config.notifyMethod == "none"
                                            end,
                width          = 1.5,
              },
              alertTRP3Connect =
              { name           = L["Config Alert TRP3 Connect"],
                type           = "toggle",
                order          = source_order(),
                desc           = L["Config Alert TRP3 Connect Tooltip"],
                get            = function() return self.db.profile.config.alertTRP3Connect end,
                set            = function(info, value) self.db.profile.config.alertTRP3Connect  = value end,
                disabled       = function() return not self.db.profile.config.monitorTRP3 
                                                    or self.db.profile.config.notifyMethod == "none"
                                                    end,
                width          = "full",
              },
            },
          }, -- here
        },
      },
      notifyOptions    =
      { type           = "group",
        name           = L["Config Notify"],
        order          = source_order(),
        args           = 
        {
          notifyLFRP       =
          { name           = L["Config Notify LFRP"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config Notify LFRP Tooltip"],
            get            = function() return self.db.profile.config.notifyLFRP end,
            set            = function(info, value) self.db.profile.config.notifyLFRP = value end,
            width          = "full",
          },
          loginMessage     =
          { name           = L["Config Login Message"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config Login Message Tooltip"],
            get            = function() return self.db.profile.config.loginMessage end,
            set            = function(info, value) self.db.profile.config.loginMessage  = value end,
            width          = "full",
          },
          versionCheck =
          { name = "Version Check",
            type = "toggle",
            order = source_order(),
            desc = "Notify whenever there's a new version of " .. self.addOnTitle .. " available.",
            get = function() return self.db.profile.config.versionCheck end,
            set = function(info, value) self.db.profile.config.versionCheck = value end,
            width = "full",
          },
          notifyMethod =
          { name      = L["Config Notify Method"],
            type      = "select",
            order     = source_order(),
            desc      = L["Config Notify Method Tooltip"],
            get       = function() return self.db.profile.config.notifyMethod end,
            set       = function(info, value) self.db.profile.config.notifyMethod  = value end,
            sorting   = { "chat", "toast", "both", "none" },
            style     = "radio",
            width     = "full", 
            values    = { chat  = L["Menu Notify Method Chat"], 
                          toast = L["Menu Notify Method Toast"],
                          both  = L["Menu Notify Method Both"],
                          none  = L["Menu Notify Method None"], },
          },
          notifyChatType = 
          { name = L["Config Notify Chat Type"],
            type = "select",
            order = source_order(),
            desc = L["Config Notify Chat Type Tooltip"],
            get = function() return self.db.profile.config.notifyChatType end,
            set = function(info, value) self.db.profile.config.notifyChatType = value end,
            values = menu.notifyChatType,
            sorting = menu.notifyChatTypeOrder,
            disabled = function() return self.db.profile.config.notifyMethod ~= "both"
                                     and self.db.profile.config.notifyMethod ~= "chat"
                       end,
            width = 1,
          },
          spacer1     = optionsSpacer(),
          notifyChatFlash =
          { name = L["Config Notify Chat Flash"],
            type = "toggle",
            order = source_order(),
            desc = L["Config Notify Chat Flash Tooltip"],
            get = function() return self.db.profile.config.notifyChatFlash end,
            set = function(info, value) self.db.profile.config.notifyChatFlash = value end,
            disabled = function() return self.db.profile.config.notifyMethod ~= "both"
                                     and self.db.profile.config.notifyMethod ~= "chat"
                       end,
            width = 1,
          },
          notifySound =
          { name      = L["Config Notify Sound"],
            type      = "select",
            order     = source_order(),
            desc      = L["Config Notify Sound Tooltip"],
            get       = function() return self.db.profile.config.notifySound end,
            set       = function(info, value) self.db.profile.config.notifySound  = value; PlaySound(value); end,
            values    = menu.notifySound,
            sorting   = menu.notifySoundOrder,
            disabled  = function() return self.db.profile.config.notifyMethod == "none" end,
            width     = 1,
          },
          spacer2     = optionsSpacer(),
          -- spacer3     = optionsSpacer(),
          -- spacer4     = optionsSpacer(),
          testNotify  =
          { name      = L["Button Test Notify"],
            type      = "execute",
            order     = source_order(),
            desc      = L["Button Test Notify Tooltip"],
            func      = function() self:Notify(L["Notify Test"]); end,
            width     = 1,
            disabled  = function() return self.db.profile.config.notifyMethod == "none" end,
          },
        },
      },
      databaseConfig =
      { name  = function() 
                  local  currentUsage =  GetAddOnMemoryUsage(self.addOnName);
                  if     currentUsage >= MEMORY_WARN_GB * 1000 * 1000
                  then   return L["Config Database Warning GB"]
                  elseif currentUsage >= MEMORY_WARN_MB * 1000
                  then   return L["Config Database Warning MB"]
                  else   return L["Config Database"]
                  end
                end,
        type  = "group",
        order = source_order(),
        args  =
        { memoryUsageBlurb =
          { type           = "group",
            name           = L["Config Memory Usage"],
            order          = source_order(),
            width          = "full",
            inline         = true,
            args           =
            {
              header       =
              { name       = L["Config Database Counts"],
                order      = source_order(),
                type       = "description",
                fontSize   = "large",
                width      = 1.75,
              },
              updateButton =
              { name       = L["Config Database Stats Update"],
                order      = source_order(),
                type       = "execute",
                width      = 0.5,
                desc       = L["Config Database Stats Update Tooltip"],
              },
              counting     =
              { name       = function() 
                               return 
                                 string.format( 
                                   L["Format Database Counts"], 
                                   self:CountPlayerData(), 
                                   self:CountPlayerRecords()
                                 ) 
                             end,
                order    = source_order(),
                type     = "description",
                fontSize = "medium",
                width    = "full",
              },
              blurb      =
              { name     = function() 
                             local value, units, warn = self:GetMemoryUsage();
                             return warn;
                           end,
                type     = "description",
                fontSize = "medium",
                order    = source_order(),
                width    = "full",
                hidden   = function() return GetAddOnMemoryUsage(self.addOnName) == 0 end,
              },
            },
          },
          deleteDBonLogin =
          { name          = L["Config Delete DB on Login"],
            type          = "toggle",
            width         = 1.25,
            order         = source_order(),
            desc          = L["Config Delete DB on Login Tooltip"],
            get           = function() return self.db.profile.config.deleteDBonLogin end,
            set           = function(info, value) 
                              if not value 
                              then   self.db.profile.config.deleteDBonLogin = value 
                              else   StaticPopup_Show(popup.deleteDBonLogin) 
                              end
                            end,
          },
          deleteSpacer = optionsSpacer(),
          deleteDBnow =
          { name      = L["Button Delete DB Now"],
            type      = "execute",
            width     = 1,
            order     = source_order(),
            desc      = L["Button Delete DB Now Tooltip"],
            func      = function() StaticPopup_Show(popup.deleteDBNow) end,
          },
          configSmartPruning  =
          { name              = L["Config Smart Pruning"],
            type              = "group",
            width             = "full",
            order             = source_order(),
            inline            = true,
            args              =
            {
              useSmartPruning =
              { name          = L["Config Use Smart Pruning"],
                type          = "toggle",
                width         = 2/3,
                order         = source_order(),
                desc          = L["Config Use Smart Pruning Tooltip"],
                get           = function() return self.db.profile.config.useSmartPruning end,
                set           = function(info, value) self.db.profile.config.useSmartPruning  = value end,
                disabled      = function() return self.db.profile.config.deleteDBonLogin end,
              },
              spacer1          = optionsSpacer(),
              repeatSmartPruning =
              { name = L["Config Smart Pruning Repeat"],
                type = "toggle",
                width = 2/3,
                order = source_order(),
                desc = L["Config Smart Pruning Repeat Tooltip"],
                get = function() return self.db.profile.config.repeatSmartPruning end,
                set = function(info, value) 
                        self.db.profile.config.repeatSmartPruning = value; 
                        self:StartOrStopPruningTimer()
                      end,
                disabled = function() 
                             return self.db.profile.config.deleteDBonLogin 
                             or not self.db.profile.config.useSmartPruning 
                           end,
              },
              spacer2          = optionsSpacer(),
              smartPruneNow =
              { name        = L["Button Smart Prune Database"],
                type        = "execute",
                width       = 2/3,
                order       = source_order(),
                desc        = L["Button Smart Prune Database Tooltip"],
                func        = function() self:SmartPruneDatabase(true) end, -- true = interactive
                disabled    = function() return not self.db.profile.config.useSmartPruning end,
              },
              pruningThreshold =
              { name                = L["Config Smart Pruning Threshold"],
                type                = "range",
                dialogControl       = "Log_Slider",
                isPercent           = true,
                width               = "full",
                min                 = 0,
                softMin             = math.log(SECONDS_PER_HOUR / 4);
                softMax             = math.log(30 * SECONDS_PER_DAY);
                max                 = 20,
                step                = 0.01,
                order               = source_order(),
                get                 = function() 
                                        return 
                                          self.db.profile.config.smartPruningThreshold 
                                      end,
                set                 = function(info, value) 
                                        self.db.profile.config.smartPruningThreshold = value 
                                      end,
                disabled            = function() return not self.db.profile.config.useSmartPruning end,
              },
            },
          },
        },
      },
      credits             =
      { type            = "group",
        name            = L["Credits Header"],
        order           = source_order(),
        args            =
        { creditsHeader =
          { type        = "description",
            name        = "|cffffff00" .. L["Credits Header"] .. "|r",
            order       = source_order(),
            fontSize    = "medium",
          },
          creditsInfo =
          { type      = "description",
            name      = L["Credits Info"],
            order     = source_order(),
          },
        },
      },
      profiles = AceDBOptions:GetOptionsTable(self.db),
    },
  };
  
  self.addOnMinimapButton = 
    LibDBIcon:Register(
      self.addOnTitle, 
      self.addOnDataBroker, 
      self.db.profile.minimapbutton
  );

  AceConfigRegistry:RegisterOptionsTable(self.addOnName, self.options,   false);
  AceConfigDialog:AddToBlizOptions(      self.addOnName, self.addOnTitle      );

  initializeDatabase();

end;

-- Ad Display
--
local adFrame = CreateFrame("Frame", "RP_Find_AdDisplayFrame", 
                            UIParent, "PortraitFrameTemplate");
adFrame:SetMovable(true);
adFrame:EnableMouse(true);
adFrame:RegisterForDrag("LeftButton");
adFrame:SetScript("OnDragStart", adFrame.StartMoving);
adFrame:SetScript("OnDragStop",  adFrame.StopMovingOrSizing);

adFrame:SetPoint("RIGHT", Finder.frame, "LEFT", 0, 0);
table.insert(UISpecialFrames, "RP_Find_AdDisplayFrame");
adFrame:Hide();

RP_Find.adFrame = adFrame;

adFrame.subtitle = adFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
adFrame.subtitle:SetWordWrap(false);
adFrame.subtitle:SetJustifyV("TOP");
adFrame.subtitle:SetJustifyH("CENTER");
adFrame.subtitle:SetPoint("TOPLEFT", 70, -32);
adFrame.subtitle:SetWidth(200);

adFrame.body = adFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
adFrame.body:SetWordWrap(true);
adFrame.body:SetJustifyV("TOP");
adFrame.body:SetJustifyH("LEFT");

function adFrame:Reset()
  self.fieldMaxY  = 300;
  self.fieldX     = 15;
  self.fieldY     = 70;
  self.fieldWidth = 75;
  self.valueWidth = 220;
  self.vPadding   = 10;
  self.hPadding   = 10;
  self.fieldNum   = 0;
  self.fieldPool  = self.fieldPool or {};
  self.valuePool  = self.valuePool or {};
  for _, string in ipairs(self.fieldPool) do string:Hide(); end;
  for _, string in ipairs(self.valuePool) do string:Hide(); end;
end;

function adFrame:GetPlayerName() return self.playerName; end;

function adFrame:SetSubtitle(text, default) 
  if default and (text == "" or not text)
  then self.subtitle:SetText(default); 
  else self.subtitle:SetText(text);
  end;
end;

function adFrame:AddField(field, value, default)
  if self.fieldY > 300 then return end;
  local fieldString, valueString;
  self.fieldNum = self.fieldNum + 1;
  if self.fieldNum > #self.fieldPool
  then fieldString = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
       table.insert(self.fieldPool, fieldString);
       valueString = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
       table.insert(self.valuePool, valueString);
  else fieldString = self.fieldPool[self.fieldNum];
       valueString = self.valuePool[self.fieldNum];
  end;

  fieldString:Show();
  valueString:Show();

  fieldString:ClearAllPoints();
  valueString:ClearAllPoints();

  fieldString:SetJustifyH("LEFT");
  fieldString:SetJustifyV("TOP");
  valueString:SetJustifyH("LEFT");
  valueString:SetJustifyV("TOP");

  fieldString:SetPoint("TOPLEFT", self.fieldX, 0 - self.fieldY);
  fieldString:SetWidth(self.fieldWidth);
  valueString:SetPoint("TOPLEFT", self.fieldX + self.fieldWidth + self.hPadding, 0 - self.fieldY);
  valueString:SetWidth(self.valueWidth);

  fieldString:SetText(field);

  if   default and (value == "" or not value)
  then valueString:SetText(default)
  else valueString:SetText(value);
  end;

  self.fieldY = self.fieldY 
                + math.max(fieldString:GetHeight(), valueString:GetHeight())
                + self.vPadding;

end;

function adFrame:SetBodyText(text, default) 
  self.body:ClearAllPoints();
  self.body:SetPoint("TOPLEFT", self.fieldX, 0 - self.fieldY)
  self.body:SetPoint("BOTTOMRIGHT", -20, 16)
  if default and (text == "" or not text)
  then self.body:SetText(default)
  else self.body:SetText(text) 
  end;
end;

function adFrame:SetPlayerRecord(playerRecord)
  self:Reset();

  self.playerName = playerRecord:GetPlayerName();

  self:SetPortraitToAsset(playerRecord:GetIcon());
  self:SetTitle(playerRecord:GetRPName());

  self:SetSubtitle(
         playerRecord:Get("ad_title"),
         L["Field Title Blank"]
       );
  self:AddField(
         L["Field Race"],
         playerRecord:GetRPRace(),
         L["Field Blank"]
       );
  self:AddField(
         L["Field Class"],
         playerRecord:GetRPClass(),
         L["Field Blank"]
       );
  self:AddField(
         L["Field Pronouns"],
         playerRecord:GetRPPronouns(),
         L["Field Blank"]
       );
  self:SetBodyText(
         playerRecord:Get("ad_body"),
         L["Field Body Blank" ]
       );
end;

RP_Find:RegisterMessage("RP_FIND_CHANGE_AD",
  function(self, message)
    if   adFrame:IsShown() and adFrame:GetPlayerName() == self.me
    then adFrame:SetPlayerRecord(self.my);
    end;
  end);

function RP_Find:StartOrStopAutoSend()
  if     self.db.profile.ad.autoSend
   and   self.timers.autoSend
  then   -- all is running as it should be
  elseif self.db.profile.ad.autoSend
  then   self:SendLFRPAd();
         self.timers.autoSend = 
           self:ScheduleRepeatingTimer("SendLFRPAd", SECONDS_PER_HOUR);
               -- SECONDS_PER_MIN);
         self:SendMessage("RP_FIND_AUTOSEND_START");
  elseif self.timers.autoSend
  then   self:CancelTimer(self.timers.autoSend) 
         self.timers.autoSend = nil;
         self:SendMessage("RP_FIND_AUTOSEND_STOP");
  else -- all is as it should be
  end;
end;

-- data broker
--

function RP_Find:ShowOrHideMinimapButton()
  if     self.db.profile.minimapbutton.hide
  then   LibDBIcon:Hide(self.addOnTitle);
  else   LibDBIcon:Show(self.addOnTitle);
  end;
end;

function RP_Find:ShowFinder() self.Finder:Show(); self.Finder:Update(); end;

function RP_Find:HideFinder() self.Finder:Hide(); end;

function RP_Find:SendVersionCheck()
  local channelNum = GetChannelName(addonChannel);
  RP_Find:SendSmartAddonMessage(
      addonPrefix.rpfind,
      addonPrefix.rpfind .. ":HELO|||version=" .. RP_Find.addOnVersion .. "|||")
end;

function RP_Find:OnEnable()
  self.realm = GetNormalizedRealmName() 
               or GetRealmName():gsub("[%-%s]","");
  self.me    = UnitName("player") .. "-" .. RP_Find.realm;

  self:InitializeToast();
  self:LoadSelfRecord();

  self:SmartPruneDatabase(false); -- false = not interactive

  self:RegisterMspReceived();
  self:RegisterTRP3Received();
  self:RegisterAddonChannel();

  self:SendVersionCheck();

  if self.db.profile.config.loginMessage 
  then self:Notify(L["Notify Login Message"]); 
  end;

  self:ShowOrHideMinimapButton();
  self.Finder:SetDimensions();
  self.Finder:CreateButtonBar();
  self.Finder:CreateTabGroup();
  self.Finder:CreateProfileButton();
  self.enableOrDisableSendAd();
  -- self.colorBar:Update();
  self.Finder:LoadTab("Display");
  self:StartOrStopAutoSend();

end;

if addon.totalRP3
then TRP3_API.module.registerModule(
    { ["name"       ] = RP_Find.addOnTitle,
      ["description"] = RP_Find.addOnDesc,
      ["version"    ] = RP_Find.addOnVersion,
      ["id"         ] = RP_Find.addOnName,
      ["autoEnable" ] = true,
    });
end;

function RP_Find:RegisterTRP3Received()
  if not addon.totalRP3 then return end;

  TRP3_API.Events.registerCallback(
    TRP3_API.events.REGISTER_DATA_UPDATED,
    function(unitID, profile, dataType)
      if unitID
      then local playerRecord = RP_Find:GetPlayerRecord(unitID);
           playerRecord:UnpackTRP3Data();
      end;
    end
  );

  TRP3_API.Events.registerCallback(
    TRP3_API.events.REGISTER_PROFILES_LOADED,
    function(profileStructure)
      self.my:UnpackTRP3Data();
    end);

  TRP3_API.Events.registerCallback(
    TRP3_API.events.REGISTER_PROFILE_DELETED,
    function(profileStructure)
      self.my:UnpackTRP3Data()
    end);
end;

function RP_Find:RegisterMspReceived()
  if not msp then return end;

  table.insert(msp.callback.received, 
    function(playerName) 
      if   self.db.profile.config.monitorMSP 
      then 
           local playerRecord = self:GetPlayerRecord(playerName);
                 playerRecord:UnpackMSPData();
           if   self.db.profile.config.autoSendPing
           then self:SendPing(playerName)
           end;
           self.Finder:Update("Display");
      end;
    end);
end;

local function haveJoinedChannel(channel)
  local chanData  = { GetChannelList() };
  local chanList  = {};
  local chanCount = 0;
  while #chanData > 0
  do    local  chanId       = table.remove(chanData, 1);
        local  chanName     = table.remove(chanData, 1);
        local  chanDisabled = table.remove(chanData, 1);
        if not chanDisabled 
        then   chanList[chanName] = chanId;
               chanCount = chanCount + 1;
        end;
  end;
  return chanList[channel] ~= nil, chanCount;
end;

function RP_Find:SendAddonMessage(prefix, text)
  local channelNum = GetChannelName(addonChannel);
  AddOn_Chomp.SendAddonMessage(
                prefix, 
                text, 
                "CHANNEL", 
                channelNum
              );
end;
  
function RP_Find:SendSmartAddonMessage(prefix, data)
  local channelNum = GetChannelName(addonChannel);
  AddOn_Chomp.SmartAddonMessage(
                prefix, 
                data, 
                "CHANNEL", 
                channelNum, 
                { serialize = true }
              );
end;

RP_Find.AddonMessageReceived = {};

function RP_Find.AddonMessageReceived.trp3(prefix, text, channelType, sender, channelname, ...)
  if     not RP_Find.db.profile.config.monitorTRP3
  then   return
  elseif sender == RP_Find.me
  then   return
  elseif text:find("^RPB1~TRP3HI")
  then   local playerRecord = RP_Find:GetPlayerRecord(sender, nil);
         if   RP_Find.db.profile.config.autoSendPing
          and not playerRecord:HaveRPProfile()
         then RP_Find:SendPing(sender)
              -- playerRecord:UnpackTRP3Data();
         end;
         
         RP_Find.Finder:Update("Display");

         if   RP_Find.db.profile.config.alertTRP3Connect
         then RP_Find:Notify(string.format(L["Format Alert TRP3 Connect"], sender));
         end;
  elseif text:find("^RPB1~C_SCAN~")
  then   local playerRecord = RP_Find:GetPlayerRecord(sender, nil);
         local zoneID = tonumber(text:match("~(%d+)$"));

         playerRecord:Set("mapScan", zoneID);

         if   RP_Find.db.profile.config.autoSendPing
          and not playerRecord:HaveRPProfile()
         then RP_Find:SendPing(sender)
              -- playerRecord:UnpackTRP3Data();
         end;
         
         if   RP_Find.db.profile.config.alertTRP3Scan
         and  (RP_Find.db.profile.config.alertAllTrp3Scan 
               or text:find("~" .. C_Map.GetBestMapForUnit("player") .. "$")
              )
         then RP_Find:Notify(
                string.format(L["Format Alert TRP3 Scan"], sender, 
                  C_Map.GetMapInfo(zoneID).name
                )
              );
         end;
  elseif text:find("^C_SCAN~%d+%.%d+~%d+%.%d+")
  then   local playerRecord = RP_Find:GetPlayerRecord(sender, nil);

         local zoneID = RP_Find:Last("mapScanZone");
         local x, y = text:match("^C_SCAN~(%d+%.%d+)~(%d+%.%d+)")

         if   RP_Find.db.profile.config.autoSendPing
          and not playerRecord:HaveRPProfile()
         then RP_Find:SendPing(sender)
              -- playerRecord:UnpackTRP3Data();
         end;
         
         if time() - (RP_Find:Last("mapScan") or 0) < 60
         then playerRecord:Set("zoneID", RP_Find:Last("mapScanZone"))
              playerRecord:Set("zone" .. zoneID .. "x", x * 100);
              playerRecord:Set("zone" .. zoneID .. "y", y * 100);
         end;
  end;
end;

function RP_Find.AddonMessageReceived.rpfind(prefix, text, channelType, sender, channelname, ...)
  if   text:match(addonPrefix.rpfind .. ":AD")
  then local count = 0;
       local ad = {};
       for _, rawData in ipairs(split(text, "|||"))
       do  local field, value = rawData:match("(.-)=(.+)")
           if   field 
           then ad[field] = value:gsub("%^|%^|%^|%^", "|||");
                count = count + 1;
           end;
       end;
       local playerRecord = RP_Find:GetPlayerRecord(sender);
       playerRecord:Set("rpFindUser", true);
       if count > 0
       then 
            playerRecord:Set("ad", true)
            for field, value in pairs(ad)
            do if field:match("^rp_") or field:match("^MSP-")
               then playerRecord:Set(field, value)
               else playerRecord:Set("ad_" .. field, value)
               end;
            end;

            if   RP_Find.db.profile.config.notifyLFRP and
                 (not ad.adult or RP_Find.db.profile.config.seeAdultAds)
            then RP_Find:Notify((ad.name or sender) .. " sent an ad" ..
                   (ad.title and (": " .. ad.title) or "") .. ".");
            end;
            RP_Find.Finder:Update("Display");
       end;
  elseif text:match(addonPrefix.rpfind .. ":HELO") and
         RP_Find.db.profile.config.versionCheck and
         not RP_Find.versionCheck
  then   local version = text:match(":HELO|||version=(.-)|||")

         local playerRecord = RP_Find:GetPlayerRecord(sender);
         playerRecord:Set("rpFindUser", true);

         if   calcVersion(version) > calcVersion(RP_Find.addOnVersion)
         then RP_Find:Notify(string.format(L["Format New Version Available"], version))
              RP_Find.versionCheck = true;
         end;
  end;
end;

function RP_Find:MoveAddonChannelToEndOfList()
  for chanNum = 1, MAX_WOW_CHAT_CHANNELS, 1
  do  local _, chanName = GetChannelName(chanNum);
      if chanName == addonChannel
      then C_ChatInfo.SwapChatChannelsByChannelIndex(chanNum, chanNum + 1)
      end;
  end;
end;

function RP_Find:RegisterAddonChannel()
  for addon, prefix in pairs(addonPrefix)
  do  AddOn_Chomp.RegisterAddonPrefix(
                    prefix, 
                    self.AddonMessageReceived[addon]
                  );
  end;

  local  haveJoinedAddonChannel, channelCount = haveJoinedChannel(addonChannel);
  if not haveJoinedAddonChannel and channelCount < 10
  then   JoinTemporaryChannel(addonChannel);
  end;

  self:MoveAddonChannelToEndOfList();

end;

function RP_Find:SendTRP3Scan(zoneNum)
  if   time() - (self:Last("mapScan") or 0) < 60
  then self:Notify(string.format(L["Format TRP3 Scan Failed"], 60));
  else zoneNum = zoneNum or C_Map.GetBestMapForUnit("player");
       local message = addonPrefix.trp3 .. "~C_SCAN~" .. zoneNum;
       self:SendAddonMessage(addonPrefix.trp3, message);
       self:SetLast("mapScan");
       self:SetLast("mapScanZone", zoneNum);
       self.Finder:Update("Tools");
       self:SendMessage("RP_FIND_MAP_SCAN_SENT");
       self:Notify(L["Notify TRP3 Scan Sent"]);
  end;
end;

function RP_Find:ComposeAd()

  local text = addonPrefix.rpfind .. ":AD";

  local function add(f, v) 
    text = text .. "|||" .. (f or "") .. "=" .. (v or ""); 
  end;

  self.my:UnpackMSPData();
  self.my:UnpackTRP3Data();

  add("MSP-NA",      self.my:GetRPName())

  local race = self.my:GetRPRace();
  if race == "" then race, _, _ = UnitRace("player"); end;
  add("MSP-RA", race);

  local class = self.my:GetRPClass();
  if class == "" then class, _, _ = UnitClass("player") end;
  add("MSP-RC", class);

  add("MSP-NT",     self.my:GetRPTitle());
  add("MSP-PN",  self.my:GetRPPronouns());
  add("MSP-AG",       self.my:GetRPAge());
  add("MSP-VA",     self.my:GetRPAddon());

  local trial = self.my:GetRPTrial();
  if trial == "" then trial = IsTrialAccount() and "1" or "0" end;

  add("MSP-TR", trial);

  add("title",        self.db.profile.ad.title);
  add("body",         self.db.profile.ad.body);
  add("adult",        self.db.profile.ad.adult);

  return text;
end;

function RP_Find:SendLFRPAd(interactive)
  local message = self:ComposeAd();
  if   time() - (self:Last("sendAd") or 0) < 60
  then if interactive then self:Notify(string.format(L["Format Send Ad Failed"], 60)); end;
  else self:SendSmartAddonMessage(addonPrefix.rpfind, message);
       self:SetLast("sendAd");
       if interactive then self:Notify(L["Notify Send Ad"]); end;
       RP_Find:SendMessage("RP_FIND_SEND_AD");
       RP_Find:ScheduleTimer(RP_Find.enableOrDisableSendAd, 60); -- one-shot timer
  end;
end;

-- buttons at the bottom
--
local buttonSize = 85;

RP_Find.closeButton  = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.closeButton:SetText(L["Button Close"]);
RP_Find.closeButton:ClearAllPoints();
RP_Find.closeButton:SetPoint("BOTTOMRIGHT", Finder.frame, "BOTTOMRIGHT", -20, 20);
RP_Find.closeButton:SetWidth(buttonSize);
RP_Find.closeButton:SetScript("OnClick", 
  function(self, button) 
    Finder:Hide(); 
end);
RP_Find.closeButton:SetScript("OnEnter",
  function(self)
    showTooltip(self, { title = L["Button Close"],
      lines = { "Click to close the " .. RP_Find.addOnTitle .. " Finder window." } });
  end);
RP_Find.closeButton:SetScript("OnLeave", hideTooltip);

RP_Find.configButton = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.configButton:SetText(L["Button Config"]);
RP_Find.configButton:ClearAllPoints();
RP_Find.configButton:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 20);
RP_Find.configButton:SetWidth(buttonSize);
RP_Find.configButton:SetScript("OnClick", 
  function(self, button) 
    if not IsModifierKeyDown() then RP_Find.Finder:Hide(); end
    RP_Find:OpenOptions(); 
  end);
RP_Find.configButton:SetScript("OnEnter",
  function(self)
    showTooltip(self, { title = L["Button Config"],
      lines = { "Click to close the " .. RP_Find.addOnTitle .. " Finder window and open the " ..
                RP_Find.addOnTitle .. " options menu.",
                " ",
                "Shift-Click or Control-Click to open the options menu without closing the Finder window." }
      });
  end);
RP_Find.configButton:SetScript("OnLeave", hideTooltip);

local function makeColorBar()
  local frameWidth = 240;
  local height = 16;
  local colorBar = CreateFrame("Frame", nil, Finder.frame);

  local checkbox = CreateFrame("CheckButton", nil, 
                     Finder.frame, "ChatConfigCheckButtonTemplate");

  function colorBar:Update()
    checkbox:SetChecked(RP_Find.db.profile.config.showColorBar);
    self:SetShown(RP_Find.db.profile.config.showColorBar);
  end;
    
  checkbox:SetSize(height + 4, height + 4);
  checkbox:SetPoint("TOPRIGHT", Finder.frame, "TOPRIGHT", -20, -40);
  checkbox:HookScript("OnClick",
    function(self, button, down)
      local value = self:GetChecked();
      RP_Find.db.profile.config.showColorBar = value;
      colorBar:SetShown(value)
    end);

  checkbox:HookScript("OnEnter",
    function(self)
      showTooltip(self, 
        { title = "Time Color Bar",
          lines = { "Check to hide or show the time color bar.",
                    "",
                    "This bar shows how the color changes to show how 'old' information shown is." 
                  }
        });
      end);
  checkbox:HookScript("OnLeave", hideTooltip);

  colorBar:SetPoint("RIGHT", checkbox, "LEFT", -5, 0);
  colorBar:SetSize(frameWidth, height);

  local border = colorBar:CreateTexture(nil, "OVERLAY");
  border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border");
  border:SetPoint("BOTTOMLEFT", -4, -4);
  border:SetPoint("TOPRIGHT", 4, 4);

  local num = 30;
  local step = 120 / num;
  local width = frameWidth / num;
  for i = 1, num
  do  local swatch = colorBar:CreateTexture()
      swatch:SetTexture("Interface\\Buttons\\WHITE8X8");
      local hue = step * (num - i);
      local col = LibColor.hsv(hue, 1, 1)
      local r, g, b = col:rgb();
      swatch:SetVertexColor(r, g, b, 0.25);
      swatch:SetPoint("LEFT", (i - 1) * width, 0);
      swatch:SetHeight(height);
      swatch:SetWidth(width);

  end;

  num = 6;
  width = frameWidth / num;
  for i = 1, num
  do
      local text = colorBar:CreateFontString();
      text:SetFont("Fonts\\ARIALN.TTF", 10);
      text:SetWidth(width);
      text:SetTextColor(1, 1, 1, 1);
      text:SetPoint("LEFT", (i - 1) * width, 0);
      text:SetText(i * 60 / num .. " min");
  end;

  return colorBar;
end;

-- RP_Find.colorBar = makeColorBar();

for i, slash in ipairs(split(SLASH, "|"))
do _G["SLASH_RP_FIND" .. i] = slash;
end;

function RP_Find:OpenOptions()
  InterfaceOptionsFrame:Show();
  InterfaceOptionsFrame_OpenToCategory(self.addOnTitle);
end;

function RP_Find:HelpCommand()
  self:Notify(true, L["Slash Commands"]);
  self:Notify(true, L["Slash Options" ]);
end;

SlashCmdList["RP_FIND"] = 
  function(a)
    local  param = { strsplit(" ", a); };
    local  cmd = table.remove(param, 1);
    if     cmd == "" or cmd == "help"                   
    then   RP_Find:HelpCommand();
    elseif cmd:match("^option") or cmd:match("^config") 
    then   RP_Find:OpenOptions();
    else   RP_Find:HelpCommand();
    end;
  end;

_G[addOnName] = RP_Find;

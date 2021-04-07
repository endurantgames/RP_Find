-- rpFind
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
--
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
local L                 = AceLocale:GetLocale(addOnName);

local MEMORY_WARN_MB = 1000 * 3;
local MEMORY_WARN_GB = 1000 * 1000;
local PLAYER_RECORD  = "RP_Find Player Record";
local ARROW_UP       = " |TInterface\\Buttons\\Arrow-Up-Up:0:0|t";
local ARROW_DOWN     = " |TInterface\\Buttons\\Arrow-Down-Up:0:0|t";
local SLASH          = "/rpfind";
local configDB       = "RP_Find_ConfigDB";
local finderDB       = "RP_FindDB";
local finderFrameName = "RP_Find_Finder_Frame";
local addonChannel   = "xtensionxtooltip2";
local addonPrefix    = { trp3 = "RPB1", rpfind = "LFRP1" };

local col = {
  gray   = function(str) return   LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(str) end,
  orange = function(str) return LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(str) end,
  white  = function(str) return       WHITE_FONT_COLOR:WrapTextInColorCode(str) end,
  red    = function(str) return         RED_FONT_COLOR:WrapTextInColorCode(str) end,
  green  = function(str) return       GREEN_FONT_COLOR:WrapTextInColorCode(str) end,
  addon  = function(str) return     RP_FIND_FONT_COLOR:WrapTextInColorCode(str) end,
};

local zoneList =
{ 1,     7,     10,    14,    15,    17,    18,    21,
  22,    23,    25,    26,    27,    32,    36,    37,
  42,    47,    48,    49,    50,    51,    52,    56,
  57,    62,    63,    64,    65,    66,    69,    70,
  71,    76,    77,    78,    80,    81,    83,    84,
  85,    87,    88,    89,    90,    94,    95,    97,
  100,   102,   103,   104,   105,   106,   107,   108,
  109,   110,   111,   114,   115,   116,   117,   118,
  119,   120,   121,   122,   123,   127,   170,   174,
  194,   198,   199,   201,   202,   203,   204,   205,
  207,   210,   217,   224,   241,   244,   245,   249,
  276,   371,   376,   379,   388,   390,   418,   422,
  425,   433,   460,   461,   462,   463,   465,   467,
  468,   469,   504,   507,   525,   534,   535,   539,
  542,   543,   550,   554,   588,   630,   634,   641,
  646,   650,   680,   739,   790,   830,   862,   863,
  864,   882,   885,   895,   896,   942,   997,   998,
  1010,  1022,  1032,  1033,  1034,  1035,  1036,  1037,
  1039,  1041,  1158,  1161,  1165,  1169,  1170,  1187,
  1188,  1189,  1190,  1191,  1192,  1193,  1194,  1195,
  1196,  1197,  1198,  1244,  1245,  1246,  1247,  1248,
  1249,  1250,  1251,  1252,  1253,  1254,  1255,  1256,
  1257,  1258,  1259,  1260,  1261,  1262,  1263,  1264,
  1265,  1266,  1267,  1268,  1269,  1270,  1271,  1272,
  1273,  1274,  1275,  1276,  1277,  1305,  1306,  1307,
  1308,  1309,  1310,  1311,  1312,  1313,  1314,  1315,
  1316,  1317,  1318,  1319,  1320,  1321,  1322,  1323,
  1324,  1325,  1326,  1327,  1328,  1329,  1330,  1331,
  1334,  1335,  1336,  1337,  1339,  1347,  1355,  1362,
         1396,  1397,  1398,  1399,  1400,  1401,  1402,
  1403,  1404,  1405,  1406,  1408,  1462,  1523,  1525,
  1527,  1530,  1533,  1536,  1543,  1565,  1569,  1577,
  1643,  1740,  1741,  1742,
};
local zoneEquiv = {};
local zoneBacklink = {};

local function getZoneFromMapID(mapID)

  local function passThrough(mapID, info) return mapID, nil end;
  local function checkParent(mapID, info) 
    if   info.parentMapId ~= 0 
    then return nil, info.parentMapId 
    else return mapID, nil 
    end 
  end;

  local hash =
  { [Enum.UIMapType.Cosmic]    = passThrough,
    [Enum.UIMapType.World]     = passThrough,
    [Enum.UIMapType.Continent] = passThrough,
    [Enum.UIMapType.Zone]      = passThrough,
    [Enum.UIMapType.Micro]     = checkParent,
    [Enum.UIMapType.Dungeon]   = checkParent,
    [Enum.UIMapType.Orphan]    = checkParent,
  };

  local zone, info

  while not zone do 
    info = C_Map.GetMapInfo(mapID);
    zone, mapID = hash[info.mapType](mapID, info);
  end;

  return zone, info;
end;

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
};

for i, mapID in ipairs(zoneList)
do  local info = C_Map.GetMapInfo(mapID);
    if not zoneBacklink[info.name]
    then menu.zone[mapID] = info.name;
         table.insert(menu.zoneOrder, mapID);
         zoneBacklink[info.name] = mapID;
    else zoneEquiv[mapID] = zoneBacklink[info.name]
    end;
end;

local function sortZones(a, b)
  local nameA = menu.zone[a];
  local nameB = menu.zone[b];
  return nameA < nameB;
end;

table.sort(menu.zoneOrder, sortZones)

local RP_Find = AceAddon:NewAddon(
                  addOnName, 
                  "AceConsole-3.0", "AceEvent-3.0", 
                  "AceTimer-3.0" , "LibToast-1.0");

RP_Find.addOnName    = addOnName;
RP_Find.addOnTitle   = GetAddOnMetadata(addOnName, "Title");
RP_Find.addOnVersion = GetAddOnMetadata(addOnName, "Version");
RP_Find.addOnIcon    = "Interface\\ICONS\\inv_misc_tolbaradsearchlight";
RP_Find.addOnToast   = "RP_Find_notify";

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
                     RP_Find:Notify("Setting cleared."); 
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
  OnCancel       = function() RP_Find:Notify("Database deletion aborted.") end,
  timeout        = 60,
  whileDead      = true,
  hideOnEscape   = true,
  hideOnCancel   = true,
  preferredIndex = 3,
  wide           = true,
  OnShow         = fixStaticPopup,
}

function RP_Find:PurgePlayer(name)
  self.data.rolePlayers[name] = nil;
  self.playerRecords[name]    = nil;
end;

function RP_Find:StartOrStopPruningTimer()
  if     self.pruningTimer and self.db.profile.config.repeatSmartPruning 
  then 
  elseif self.pruningTimer
  then   self:CancelTimer(self.pruningTimer);
         self.pruningTimer = nil;
  elseif self.db.profile.config.repeatSmartPruning -- and not self.pruningTimer
  then   self.pruningTimer = 
           self:ScheduleRepeatingTimer(
             "SmartPruneDatabase", 
             15 * SECONDS_PER_MIN );
  else   -- not self.pruningTimer and not repeatSmartPruning 
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
  self:Notify("Database deleted.");
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

function RP_Find:Notify(forceChat, ...) 
  local soundPlayed;
  local  dots = { ... };

  if     type(forceChat) == "boolean" and forceChat
  then   print("[" .. self.addOnTitle .. "]", unpack(dots));

  elseif type(forceChat) == "boolean" -- and not forceChat
  then   self:SendToast(table.concat(dots, " "))

  else   if   self.db.profile.config.notifyMethod == "chat"
         or   self.db.profile.config.notifyMethod == "both"
         then print("[" .. self.addOnTitle .. "]", forceChat, unpack(dots));
         end;

         if   self.db.profile.config.notifyMethod == "toast"
         or   self.db.profile.config.notifyMethod == "both"
         then self:SendToast(forceChat .. table.concat(dots, " "));
         end;

         if self.db.profile.config.notifyMethod ~= "none" then playNotifySound(); end;
  end;
end;

local function initializeDatabase(wipe)
  if   wipe or RP_Find.db.profile.config.deleteDBonLogin
  then _G[finderDB] = {};
  else _G[finderDB] = _G[finderDB] or {};
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
  for   methodName, func in pairs(self.PlayerMethods)
  do    playerRecord[methodName] = func;
  end;

  playerRecord.playerName = playerName;
  playerRecord:Initialize();

  if playerData then for field, value in pairs(playerData) do playerRecord:Set(field, value) end; end;
  if not playerRecord:Get("First Seen") then playerRecord:Set("First Seen", nil) end;

  self.playerRecords[playerName] = playerRecord;
  return playerRecord;
end;

function RP_Find:GetPlayerRecord(playerName, server)
  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));

  if   self.playerRecords[playerName]
  then return self.playerRecords[playerName]
  else return self:NewPlayerRecord(playerName)
  end;

end;

function RP_Find:GetAllPlayerRecords() 
  local list = {};
  for _, record in pairs(self.playerRecords) do table.insert(list, record); end;
  return list;
end;

function RP_Find:GetAllPlayerData()
  local list = {};
  for _, data in pairs(self.data.rolePlayers) do table.insert(list, data) end;
  return list;
end;

function RP_Find:GetMemoryUsage(fmt) -- returns value, units, message, bytes
  local value, units, warn;
  local currentUsage = GetAddOnMemoryUsage(self.addOnName);

  if     currentUsage < 1000
  then   value, units, warn = currentUsage, "KB", "";
  elseif currentUsage < 1000 * 1000
  then   value, units, warn = currentUsage / 1000, "MB", "";
  if     value > 2 then warn = L["Warning High Memory MB"] end;
  else   value, units, warn = currentUsage / 1000 * 1000, "GB",
         L["Warning High Memory GB"];
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

function RP_Find.OnMinimapButtonClick(frame, button, ...)
  if   button == "RightButton" 
    or button == "LeftButton" and IsControlKeyDown()
  then if InterfaceOptionsFrame:IsShown()
       then InterfaceOptionsFrame:Hide()
       else RP_Find:OpenOptions();
       end;
       RP_Find:HideFinder();
  else if RP_Find.Finder:IsShown()
       then   RP_Find:HideFinder();
       else   RP_Find:ShowFinder();
       end
  end;
end;

function RP_Find.OnMinimapButtonEnter(frame)
  GameTooltip:ClearLines();
  GameTooltip:SetOwner(frame, "ANCHOR_BOTTOM");
  -- GameTooltip:SetOwner(RP_Find.Finder.frame, "ANCHOR_CURSOR");
  -- GameTooltip:SetOwner(RP_Find.Finder.frame, "ANCHOR_PRESERVE");
  GameTooltip:AddDoubleLine(RP_Find.addOnTitle, RP_Find.addOnVersion);
  GameTooltip:AddLine(" ");
  GameTooltip:AddDoubleLine("Left-Click", "Open Finder Window", 0, 1, 1, 1, 1, 1);
  GameTooltip:AddDoubleLine("Right-Click", RP_Find.addOnTitle .. " Options", 0, 1, 1, 1, 1, 1);
  if IsModifierKeyDown()
  then local _, _, memory, _ = RP_Find:GetMemoryUsage("%3.2f %s");
       GameTooltip:AddLine(" ");
       GameTooltip:AddDoubleLine("Memory Usage", memory, 1, 1, 0, 1, 1, 1);
       GameTooltip:AddDoubleLine("Players Seen", RP_Find:CountPlayerData(), 1, 1, 0, 1, 1, 1);
       GameTooltip:AddDoubleLine("Players Loaded", RP_Find:CountPlayerRecords(), 1, 1, 0, 1, 1, 1);
  end;
  GameTooltip:Show();
end;

function RP_Find.OnMinimapButtonLeave(frame) GameTooltip:Hide(); end;
RP_Find.PlayerMethods =
{ 
  ["Initialize"] =
    function(self)
      RP_Find.data.rolePlayers[self.playerName] 
        = RP_Find.data.rolePlayers[self.playerName] or {};
      self.data           = RP_Find.data.rolePlayers[self.playerName];
      self.data.fields    = self.data.fields or {};
      self.data.last      = self.data.last or {};
      self.data.last.when = time();
      self.type           = PLAYER_RECORD;
      return self;
    end,

  ["Set"] =
    function(self, field, value)
      self.data.fields[field]       = self.data.fields[field] or {};
      self.data.fields[field].value = value;
      self.data.fields[field].when  = time();
      self.data.last.when           = time();
      return self;
    end,

  ["SetTimestamp"] =
    function(self, field, timeStamp)
      timeStamp = timeStamp or time();
      if not field
      then   self.data.last.when = timeStamp
      elseif self.data.fields[field]
      then   self.data.fields[field].when = timeStamp;
      elseif type(field) == "string"
      then   self:Set(field, nil, { when = timeStamp });
      end;
      return self;
    end,

  ["GetPlayerName"] = function(self) return self.playerName; end,

  ["Get"] =
    function(self, field)
      if   self.data.fields[field]
      then return self.data.fields[field].value
      else return nil
      end;
    end,

  ["GetTimestamp"] =
    function(self, field)
      if     not field 
      then   return self.data.last.when or time()
      elseif self.data.fields[field] 
      then   return self.data.fields[field].when or time()
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
      then   return string.format("%i |4minute:minutes; ago", math.ceil(delta / 60));
      else   return string.format("<1 minute ago", delta);
      end
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
    { notifyMethod     = "toast",
      loginMessage     = false,
      finderTooltips   = true,
      monitorMSP       = true,
      monitorTRP3      = true,
      alertTRP3Scan    = false,
      alertAllTRP3Scan = false,
      alertTRP3Connect = false,
      notifySound      = 37881,
      deleteDBonLogin  = false,
      useSmartPruning  = false,
      repeatSmartPruning = false,
    },
    minimapbutton      = {}, 
  },
};

local recordSortField        = "playerName";
local recordSortFieldReverse = false;

local function sortPlayerRecords(a, b)
  local function helper(booleanValue)
    if recordSortFieldReverse
    then return not booleanValue
    else return     booleanValue
    end;
  end;

  if          recordSortField == "playerName"
  then return helper( a:GetPlayerName() < b:GetPlayerName() );
  elseif      recordSortField == "timestamp"
  then return helper( a:GetTimestamp() < b:GetTimestamp() )
  else return helper( a:Get(recordSortField) < b:Get(recordSortField) )
  end;

end;

local Finder = AceGUI:Create("Window");

function RP_Find:Update(...) self.Finder:Update(...); end

Finder.col   = { 0.35, 0.25 };

Finder:SetWidth(500);
Finder:SetHeight(300);
Finder:SetLayout("Fill");

Finder:SetCallback("OnClose",
  function(self, event, ...)
    if self.timer then RP_Find:CancelTimer(self.timer) self.timer = nil; end;
  end);

_G[finderFrameName] = Finder.frame;

Finder.title:SetIgnoreParentAlpha(true);
Finder.titletext:SetIgnoreParentAlpha(true);

table.insert(UISpecialFrames, finderFrameName);

Finder.content:ClearAllPoints();
Finder.content:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 50);
Finder.content:SetPoint("TOPRIGHT",   Finder.frame, "TOPRIGHT", -20, -30);

Finder.TabList = 
{ { value = "Display", text = "Database", },
  { value = "Ads", text = "Ads", },
  { value = "LFG", text = "Looking for Group" },
  { value = "Tools", text = "Tools", },
};

Finder.TabListSub50 =
{ { value = "Display", text = "Database", },
  { value = "Ads", text = "Ads", },
  { value = "LFG", text = "LFG (Disabled)" },
  { value = "Tools", text = "Tools", },
};

function Finder:CreateTabGroup()
  local tabGroup = AceGUI:Create("TabGroup");
  tabGroup:SetFullWidth(true);
  tabGroup:SetFullHeight(true);
  tabGroup:SetLayout("Flow");

  if UnitLevel("player") >= 50 then tabGroup:SetTabs(self.TabList);
  else tabGroup:SetTabs(self.TabListSub50);
  end;

  function tabGroup:LoadTab(tab)
    if Finder.timer then RP_Find:CancelTimer(Finder.timer) Finder.timer = nil; end;
    _ = self.current and self.current:ReleaseChildren(); 
    _ = self.scrollFrame and self.scrollFrame:ReleaseChildren();
    _ = self.scrollContainer and self.scrollContainer:ReleaseChildren();
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
    -- scrollFrame:SetFullHeight(true);
    local panelFrame = Finder.MakeFunc[tab](Finder);
    scrollFrame:AddChild(panelFrame);
    self.current = panelFrame;
    Finder.currentTab = tab;
    Finder:UpdateTitle();

  end;

  tabGroup:SetCallback("OnGroupSelected",
    function(self, event, group)
      self:LoadTab(group);
    end);

  self:AddChild(tabGroup);
  self.TabGroup = tabGroup;

end;

Finder.MakeFunc = {}

function Finder.MakeFunc.Display(self)

  local panelFrame = AceGUI:Create("InlineGroup");
        panelFrame:SetFullWidth(true);
        panelFrame:SetLayout("Flow");
  
  local headers = AceGUI:Create("SimpleGroup");
        headers:SetLayout("Flow");
        headers:SetFullWidth(true);
  panelFrame:AddChild(headers);
  
  headers.list = {};
  
  local function ListHeader_SetRecordSortField(self, event, button)
    recordSortField = self.recordSortField;
    for headerName, header in pairs(headers.list)
    do  if     recordSortField == self.recordSortField 
           and recordSortFieldReverse 
           and header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = false;
               header:SetText(header.baseText .. ARROW_UP);
        elseif recordSortField == self.recordSortField and header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = true;
               header:SetText(header.baseText .. ARROW_DOWN);
        elseif header.recordSortField == self.recordSortField
        then   recordSortFieldReverse = false;
        else   header:SetText(header.baseText)
        end;
    end;
    Finder.TitleFunc[tab]();
  end;
    
  local currentCol = 1;

  local function makeListHeader(baseText, sortField)
    local newHeader = AceGUI:Create("InteractiveLabel");
    newHeader:SetRelativeWidth(Finder.col[currentCol]);
    currentCol = currentCol + 1;
    newHeader.baseText = baseText;
    if     recordSortField == sortField and recordSortFieldReverse
    then   newHeader:SetText(baseText .. ARROW_UP);
    elseif recordSortField == sortField
    then   newHeader:SetText(baseText .. ARROW_DOWN);
    else   newHeader:SetText(baseText);
    end;
    newHeader:SetColor(1, 1, 0);
    newHeader.recordSortField = sortField;
    newHeader:SetCallback("OnClick", ListHeader_SetRecordSortField);
    headers:AddChild(newHeader);
    headers.list[baseText] = newHeader;
    return newHeader;
   end;
  
  makeListHeader("Name",      "playerName");
  makeListHeader("Last Seen", "timestamp" );
  
  playerListFrame = AceGUI:Create("SimpleGroup");
  playerListFrame:SetFullWidth(true);
  playerListFrame:SetFullHeight(true);
  playerListFrame:SetLayout("Flow");

  panelFrame:AddChild(playerListFrame);

  local scrollContainer = AceGUI:Create("SimpleGroup");
        scrollContainer:SetFullWidth(true);
        scrollContainer:SetFullHeight(true);
        scrollContainer:SetLayout("Fill");
  
  function scrollContainer:Update()
    self:ReleaseChildren();
    local scrollFrame = AceGUI:Create("ScrollFrame");
          scrollFrame:SetLayout("Fill");
          self:AddChild(scrollFrame);

    local playerRecordList = RP_Find:GetAllPlayerRecords();
    table.sort(playerRecordList, sortPlayerRecords);
  
    for _, playerRecord in ipairs(playerRecordList)
    do  local line = AceGUI:Create("SimpleGroup");
              line:SetFullWidth(true);
              line:SetLayout("Flow");
              line.playerName = playerName;
    
        local nameField = AceGUI:Create("Label");
              nameField:SetFontObject(GameFontNormalSmall);
              nameField:SetText(playerRecord:GetPlayerName():gsub("-" .. RP_Find.realm, ""));
              nameField:SetRelativeWidth(Finder.col[1]);
    
        local lastSeenField = AceGUI:Create("Label");
              lastSeenField:SetFontObject(GameFontNormalSmall);
              lastSeenField:SetText(playerRecord:GetHumanReadableTimestamp());
              lastSeenField:SetRelativeWidth(Finder.col[2]);
    
        line:AddChild(nameField);
        line:AddChild(lastSeenField);
        scrollFrame:AddChild(line);
    end;
    return scrollFrame;
  end;

  function panelFrame:Update(...) scrollContainer:Update(...); end;

  if self:IsShown() then self.timer = RP_Find:ScheduleRepeatingTimer("Update", 10); end;
  return panelFrame;
end;

Finder.TitleFunc = {};
Finder.UpdateFunc= {};

function Finder.TitleFunc.Display(self, ...)
   self:SetTitle(string.format(L["Format Finder Title Display"], RP_Find:CountPlayerRecords()));
end;

function Finder.TitleFunc.LFG(self, ...)
  if UnitLevel("player") >= 50
  then self:SetTitle(string.format(L["Format Finder Title LFG"], RP_Find:CountLFGGroups()));
  else self:SetTitle(L["Format Finder Title LFG Disabled"]);
  end;
end;

function Finder.TitleFunc.Ads(self, ...)
  self:SetTitle(RP_Find.addOnTitle .. "- Ads"); 
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
  local title = self.TitleFunc[self.currentTab]
  if title then title(self) end;
end;

function Finder:UpdateContent(event, ...)
  local update = self.UpdateFunc[self.currentTab]
  if update then update(self) end;
end;

function Finder:Update(event, ...)
  if not self:IsShown() then return end; -- only update if we're shown
  self:UpdateContent();
  self:UpdateTitle();
end;

function Finder.MakeFunc.Ads(self)
  local panelFrame = AceGUI:Create("SimpleGroup");
  panelFrame:SetFullWidth(true);
  panelFrame:SetLayout("Flow");
  
  local headline = AceGUI:Create("Heading");
  headline:SetFullWidth(true);
  headline:SetText("Ads");
  panelFrame:AddChild(headline);

  local sendAdButton = AceGUI:Create("Button");

  local function reEnableSendAd()
    if time() - (RP_Find.Finder.lastAdTime or 0) >= 60
       and trp3MapScanButton
       and trp3MapScanZone
    then sendAdButton:SetDisabled(false);
    end;
  end;

  reEnableSendAd();

  sendAdButton:SetText("Send Ad");
  sendAdButton:SetRelativeWidth(0.25);
  sendAdButton:SetCallback("OnClick", 
    function(self, event, ...) 
      self:SetDisabled(true);
      RP_Find:ScheduleTimer(reEnableSendAd, 60); -- one-shot timer
      RP_Find:SendLFRPAd(...) 
    end);

  panelFrame:AddChild(sendAdButton);

  function panelFrame:Update() return end;

  return panelFrame;
end;

function Finder.MakeFunc.LFG(self)
  local panelFrame = AceGUI:Create("SimpleGroup");
  panelFrame:SetFullWidth(true);
  panelFrame:SetLayout("Flow");

  local headline = AceGUI:Create("Heading");
  headline:SetFullWidth(true);
  headline:SetText("Looking for Group");

  panelFrame:AddChild(headline);

  local explainSub50 = AceGUI:Create("Label");
  explainSub50:SetFullWidth(true);
  explainSub50:SetText("These options are disabled because you are lower than level 50. This is a restriction set by Blizzard as of WoW 9.0.");

  panelFrame:AddChild(explainSub50);

  panelFrame.lower = AceGUI:Create("SimpleGroup");
  panelFrame.lower:SetFullWidth(true);
  panelFrame.lower:SetLayout("Flow");

  panelFrame:AddChild(panelFrame.lower);

  panelFrame.left = AceGUI:Create("InlineGroup");
  panelFrame.left:SetRelativeWidth(0.5);
  panelFrame.left:SetLayout("Flow");
  panelFrame.left:SetTitle("Search");
  panelFrame.lower:AddChild(panelFrame.left);

  panelFrame.right = AceGUI:Create("InlineGroup");
  panelFrame.right:SetLayout("Flow");
  panelFrame.right:SetRelativeWidth(0.5);
  panelFrame.right:SetTitle("List Your Group");
  panelFrame.lower:AddChild(panelFrame.right);

  local searchButton = AceGUI:Create("Button");
  searchButton:SetText("Search");
  searchButton:SetFullWidth(true);
  panelFrame.left:AddChild(searchButton);

  local searchFilter = AceGUI:Create("EditBox");
  searchFilter:SetLabel("Filter (optional)");
  searchFilter:SetFullWidth(true);
  panelFrame.left:AddChild(searchFilter);

  local newGroupTitle = AceGUI:Create("EditBox");
  newGroupTitle:SetLabel("Title");
  newGroupTitle:SetFullWidth(true);
  
  panelFrame.right:AddChild(newGroupTitle);

  local newGroupDetails = AceGUI:Create("MultiLineEditBox");
  newGroupDetails:SetFullWidth(true);
  newGroupDetails:SetLabel("Details");
  newGroupDetails:SetNumLines(6);
  newGroupDetails:DisableButton(true);

  panelFrame.right:AddChild(newGroupDetails);

  local listGroupButton = AceGUI:Create("Button");
  listGroupButton:SetText("List Group");
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
  trp3MapScan:SetTitle("TRP3 Map Scan");
  panelFrame:AddChild(trp3MapScan);

  local zoneID, zoneInfo = 
    getZoneFromMapID(
      RP_Find.Finder.scanZone or
      C_Map.GetBestMapForUnit("player")
    );

  local trp3MapScanZone = AceGUI:Create("Dropdown");
  trp3MapScanZone:SetLabel("Zone to Scan");
  trp3MapScanZone:SetRelativeWidth(0.60);
  trp3MapScanZone:SetList(menu.zone, menu.zoneOrder);
  trp3MapScanZone:SetValue(zoneID);
  trp3MapScanZone:SetText(zoneInfo.name);
  trp3MapScanZone:SetCallback("OnValueChanged",
    function(self, event, value, checked)
      RP_Find.Finder.scanZone = value;
    end);
  trp3MapScan:AddChild(trp3MapScanZone)

  local spacer = AceGUI:Create("Label");
  spacer:SetRelativeWidth(0.05);
  spacer:SetText(" ");
  trp3MapScan:AddChild(spacer);

  local trp3MapScanButton = AceGUI:Create("Button");

  local function reEnableMapScan()
    if time() - (RP_Find.Finder.lastScanTime or 0) >= 60
       and trp3MapScanButton
       and trp3MapScanZone
    then trp3MapScanButton:SetDisabled(false);
         trp3MapScanZone:SetDisabled(false);
    end;
  end;

  reEnableMapScan();  -- this is in case something happened in that minute
                      -- and we weren't able to catch it then
  
  trp3MapScanButton:SetRelativeWidth(0.35);
  trp3MapScanButton:SetText("Scan Now");
  trp3MapScanButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find:SendTRP3Scan(RP_Find.Finder.scanZone)
      trp3MapScanButton:SetDisabled(true);
      trp3MapScanZone:SetDisabled(true);
      RP_Find:ScheduleTimer(reEnableMapScan, 60); -- one-shot timer
    end);

  trp3MapScan:AddChild(trp3MapScanButton);

  function panelFrame:Update() return end;

  return panelFrame;
end;

Finder:CreateTabGroup();
Finder.TabGroup:LoadTab(Finder.TabList[1].value);
Finder:Hide();

RP_Find.Finder = Finder;

function RP_Find:LoadSelfRecord() 
  self.my = self:GetPlayerRecord(self.me, self.realm); 
end;

local function Spacer(info)
  return 
  { type  = "description",
    name  = " ",
    width = info and info.width or 0.1,
    order = info and info.order or 10,
  }
end

function RP_Find:OnInitialize()

  self.db = AceDB:New(configDB, self.defaults);
  self.db.RegisterCallback(self, "OnProfileChanged", "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileCopied",  "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileReset",   "LoadSelfRecord");
  
  self.options               =
  { type          = "group",
    name          = RP_Find.addOnTitle,
    order         = 1,
    args          =
    { versionInfo =
      { type      = "description",
        name      = L["Version Info"],
        order     = 1,
        fontSize  = "medium",
        width     = "full",
        hidden    = function() UpdateAddOnMemoryUsage() return false end,
      },
      configOptions =
      { type        = "group",
        name        = L["Config Options"],
        order       = 1,
        args        =
        {
          showIcon  =
          { name    = L["Config Show Icon"],
            type    = "toggle",
            order   = 20,
            desc    = L["Config Show Icon Tooltip"],
            get     = function() return not self.db.profile.minimapbutton.hide end,
            set     = function(info, value) 
                        self.db.profile.minimapbutton.hide = not value 
                        self:ShowOrHideMinimapButton(); 
                      end,
            width   = "full",
          },
          loginMessage =
          { name       = L["Config Login Message"],
            type       = "toggle",
            order      = 25,
            desc       = L["Config Login Message Tooltip"],
            get        = function() return self.db.profile.config.loginMessage end,
            set        = function(info, value) self.db.profile.config.loginMessage  = value end,
            width      = "full",
          },
          monitorMSP =
          { name     = L["Config Monitor MSP"],
            type     = "toggle",
            order    = 30,
            desc     = L["Config Monitor MSP Tooltip"],
            get      = function() return self.db.profile.config.monitorMSP end,
            set      = function(info, value) self.db.profile.config.monitorMSP  = value end,
            disabled = function() return not msp end,
            width    = "full",
          },
          monitorTRP3 =
          { name      = L["Config Monitor TRP3"],
            type      = "toggle",
            order     = 40,
            desc      = L["Config Monitor TRP3 Tooltip"],
            get       = function() return self.db.profile.config.monitorTRP3 end,
            set       = function(info, value) self.db.profile.config.monitorTRP3  = value end,
            width     = "full",
          },
          --[[
        },
      },

      notifyOptions =
      { type = "group",
        name = L["Config Notify"],
        order = 2,
        args = 
        {
          --]]
          notifyOptions =
          { type = "group",
            inline = true,
            name = L["Config Notify"],
            order = 50,
            args = 
            { notifyMethod =
              { name       = L["Config Notify Method"],
                type       = "select",
                order      = 1020,
                desc       = L["Config Notify Method Tooltip"],
                get        = function() return self.db.profile.config.notifyMethod end,
                set        = function(info, value) self.db.profile.config.notifyMethod  = value end,
                sorting    = { "chat", "toast", "both", "none" },
                width      = 2/4,
                values     = { chat  = L["Menu Notify Method Chat"], 
                               toast = L["Menu Notify Method Toast"],
                               both  = L["Menu Notify Method Both"],
                               none  = L["Menu Notify Method None"], },
              },
              spacer1 = Spacer({ order = 1021 }),
              notifySound =
              { name      = L["Config Notify Sound"],
                type      = "select",
                order     = 1030,
                desc      = L["Config Notify Sound Tooltip"],
                get       = function() return self.db.profile.config.notifySound end,
                set       = function(info, value) self.db.profile.config.notifySound  = value; PlaySound(value); end,
                values    = menu.notifySound,
                sorting   = menu.notifySoundOrder,
                disabled  = function() return self.db.profile.config.notifyMethod == "none" end,
                width     = 4/4,
              },
              spacer2 = Spacer({ order = 1031 }),
              testNotifyMethod =
              { name           = L["Button Test Notify"],
                type           = "execute",
                order          = 1040,
                desc           = L["Button Test Notify Tooltip"],
                func           = function() 
                                   self:Notify(L["Notify Test"]);
                                   end,
                width          = 2/4,
                disabled  = function() return self.db.profile.config.notifyMethod == "none" end,
              },
            },
          },
          trp3Group        =
          { name           = L["Config TRP3"],
            type           = "group",
            inline         = true,
            order          = 1050,
            args           =
            {
              instructTRP3 =
              { name       = L["Instruct TRP3"],
                type       = "description",
                order      = 1060,
                width      = "full"
              },
              alertTRP3Scan =
              { name        = L["Config Alert TRP3 Scan"],
                type        = "toggle",
                order       = 1070,
                desc        = L["Config Alert TRP3 Scan Tooltip"],
                get         = function() return self.db.profile.config.alertTRP3Scan end,
                set         = function(info, value) self.db.profile.config.alertTRP3Scan    = value end,
                disabled    = function() return not self.db.profile.config.monitorTRP3 
                                         or self.db.profile.config.notifyMethod == "none" end,
                width       = "full",
              },
              spacer1          = Spacer({ order = 1080 }),
              alertAllTRP3Scan =
              { name           = L["Config Alert All TRP3 Scan"],
                type           = "toggle",
                order          = 1090,
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
                order          = 1100,
                desc           = L["Config Alert TRP3 Connect Tooltip"],
                get            = function() return self.db.profile.config.alertTRP3Connect end,
                set            = function(info, value) self.db.profile.config.alertTRP3Connect  = value end,
                disabled       = function() return not self.db.profile.config.monitorTRP3 
                                                    or self.db.profile.config.notifyMethod == "none"
                                                    end,
                width          = "full",
              },
            },
          },
        },
      },
      databaseConfig =
      { name  = function() 
                  local  currentUsage =  GetAddOnMemoryUsage(self.addOnName);
                  if     currentUsage >= MEMORY_WARN_GB
                  then   return L["Config Database Warning GB"]
                  elseif currentUsage >= MEMORY_WARN_MB
                  then   return L["Config Database Warning MB"]
                  else   return L["Config Database"]
                  end
                end,
        type  = "group",
        order = 50,
        args  =
        { memoryUsageBlurb =
          { type           = "group",
            name           = L["Config Memory Usage"],
            order          = 55,
            width          = "full",
            inline         = true,
            args           =
            {
              header       =
              { name       = L["Config Database Counts"],
                order      = 58,
                type       = "description",
                fontSize   = "large",
                width      = 1.75,
              },
              updateButton =
              { name       = L["Config Database Stats Update"],
                order      = 59,
                type  = "execute",
                width = 0.5,
                desc = L["Config Database Stats Update Tooltip"],
              },
              counting   =
              { name     = function() 
                             return 
                               string.format( 
                                 L["Format Database Counts"], 
                                 self:CountPlayerData(), 
                                 self:CountPlayerRecords()
                               ) 
                           end,
                order    = 60,
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
                order    = 65,
                width    = "full",
                hidden   = function() return GetAddOnMemoryUsage(self.addOnName) == 0 end,
              },
            },
          },
          deleteDBonLogin =
          { name          = L["Config Delete DB on Login"],
            type          = "toggle",
            width         = 1.25,
            order         = 80,
            desc          = L["Config Delete DB on Login Tooltip"],
            get           = function() return self.db.profile.config.deleteDBonLogin end,
            set           = function(info, value) 
                              if not value 
                              then   self.db.profile.config.deleteDBonLogin = value 
                              else   StaticPopup_Show(popup.deleteDBonLogin) 
                              end
                            end,
          },
          deleteSpacer = Spacer({ order = 81 });
          deleteDBnow =
          { name      = L["Button Delete DB Now"],
            type      = "execute",
            width     = 1,
            order     = 85,
            desc      = L["Button Delete DB Now Tooltip"],
            func      = function() StaticPopup_Show(popup.deleteDBNow) end,
          },
          configSmartPruning  =
          { name              = L["Config Smart Pruning"],
            type              = "group",
            width             = "full",
            order             = 90,
            inline            = true,
            args              =
            {
              useSmartPruning =
              { name          = L["Config Use Smart Pruning"],
                type          = "toggle",
                width         = 2/3,
                order         = 95,
                desc          = L["Config Use Smart Pruning Tooltip"],
                get           = function() return self.db.profile.config.useSmartPruning end,
                set           = function(info, value) self.db.profile.config.useSmartPruning  = value end,
                disabled      = function() return self.db.profile.config.deleteDBonLogin end,
              },
              spacer1          = Spacer({ order = 99 }),
              repeatSmartPruning =
              { name = L["Config Smart Pruning Repeat"],
                type = "toggle",
                width = 2/3,
                order = 100,
                desc = L["Config Smart Pruning Repeat Tooltip"],
                get = function() return self.db.profile.config.repeatSmartPruning end,
                set = function(info, value) self.db.profile.config.repeatSmartPruning = value; 
                                        self:StartOrStopPruningTimer()
                end,
                disabled = function() return self.db.profile.config.deleteDBonLogin or not self.db.profile.config.useSmartPruning end,
              },
              spacer2          = Spacer({ order = 101 }),
              smartPruneNow =
              { name        = L["Button Smart Prune Database"],
                type        = "execute",
                width       = 2/3,
                order       = 110,
                desc        = L["Button Smart Prune Database Tooltip"],
                func        = function() self:SmartPruneDatabase(true) end, -- true = interactive
                disabled    = function() return not self.db.profile.config.useSmartPruning end,
              },
              smartPruningThreshold =
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
                order               = 120,
                get                 = function() return self.db.profile.config.smartPruningThreshold end,
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
        order           = 9998,
        args            =
        { creditsHeader =
          { type        = "description",
            name        = "|cffffff00" .. L["Credits Header"] .. "|r",
            order       = 10,
            fontSize    = "medium",
          },
          creditsInfo =
          { type      = "description",
            name      = L["Credits Info"],
            order     = 20,
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

-- data broker
--

function RP_Find:ShowOrHideMinimapButton()
  if     self.db.profile.minimapbutton.hide
  then   LibDBIcon:Hide(self.addOnTitle);
  else   LibDBIcon:Show(self.addOnTitle);
  end;
end;

function RP_Find:ShowFinder()
  self.Finder:Show();
  self.Finder:Update();
end;

function RP_Find:HideFinder()
  self.Finder:Hide();
end;

function RP_Find:OnEnable()
  self.realm = GetNormalizedRealmName() or GetRealmName():gsub("[%-%s]","");
  self.me    = UnitName("player") .. "-" .. RP_Find.realm;

  self:InitializeToast();
  self:LoadSelfRecord();

  self:SmartPruneDatabase(false); -- false = not interactive

  self:RegisterMspReceived();
  self:RegisterAddonChannel();

  if   self.db.profile.config.loginMessage 
  then self:Notify(L["Notify Login Message"]); 
  end;

  self:ShowOrHideMinimapButton();
end;

function RP_Find:RegisterPlayer(playerName, server)
  local  playerRecord = self:GetPlayerRecord(playerName, server);
end;

function RP_Find:RegisterMspReceived()
  if not msp then self.db.profile.config.monitorMSP = false; return end;
  tinsert(msp.callback.received, 
    function(playerName) 
      if   self.db.profile.config.monitorMSP and playerName ~= self.me
      then self:GetPlayerRecord(playerName, server);
           if   self.Finder.currentTab == "Display"
           then self.Finder:Update();
           end;
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
  AddOn_Chomp.SendAddonMessage(prefix, text, "CHANNEL", channelNum);
end;
  
function RP_Find:RegisterAddonChannel()
  for _, prefix in pairs(addonPrefix)
  do AddOn_Chomp.RegisterAddonPrefix(prefix, function(...) self:AddonMessageReceived(...) end);
  end;

  local  haveJoinedAddonChannel, channelCount = haveJoinedChannel(addonChannel);
  if not haveJoinedAddonChannel and channelCount < 10
  then   JoinTemporaryChannel(addonChannel);
  end;
end;

function RP_Find:AddonMessageReceived(prefix, text, channelType, sender, channelName, ...)
  if   self.db.profile.config.monitorTRP3 
   and prefix == addonPrefix.trp3 
   and sender ~= self.me
  then if     text:find("^RPB1~TRP3HI")
       then   self:GetPlayerRecord(sender, nil);
              if self.Finder.currentTab == "Display" then self.Finder:Update(); end;

              if   self.db.profile.config.alertTRP3Connect
              then self:Notify(string.format(L["Format Alert TRP3 Connect"], sender));
              end;
       elseif text:find("^RPB1~C_SCAN~")
       then   self:GetPlayerRecord(sender, nil);
              if   self.db.profile.config.alertTRP3Scan
              and  (self.db.profile.config.alertAllTrp3Scan 
                    or text:find("~" .. C_Map.GetBestMapForUnit("player") .. "$")
                   )
              then self:Notify(
                     string.format(L["Format Alert TRP3 Scan"], sender, 
                       C_Map.GetMapInfo(tonumber(text:match("~(%d+)$"))).name
                     )
                   );
              end;
       elseif text:find("^C_SCAN~%d+%.%d+~%d+%.%d+")
       then   local playerRecord = self:GetPlayerRecord(sender, nil);
              if time() - (self.Finder.lastScanTime or 0) < 60
              then playerRecord:Set("ZoneID", self.Finder.lastScanZone)
              end;
       end;
  elseif prefix == addonPrefix.rpfind
     and sender ~= self.me
  then   print("message received", sender, text)
         --[[
         if text:find("^LFRP1~AD~")
         then 
         end;
         --]]
  end;
end;

function RP_Find:SendTRP3Scan(zoneNum)
  if   time() - (self.Finder.lastScanTime or 0) < 60
  then self:Notify("You can only send a scan once every 60 seconds.");
  else zoneNum = zoneNum or C_Map.GetBestMapForUnit("player");
       local message = addonPrefix.trp3 .. "~C_SCAN~" .. zoneNum;
       self:SendAddonMessage(addonPrefix.trp3, message);
       self.Finder.lastScanTime = time();
       self.Finder.lastScanZone = zoneNum;
       self:Notify("Scan message sent. Replying characters will be added to the database.");
  end;
end;

function RP_Find:SendLFRPAd()
  if time() - (self.Finder.lastAdTime or 0) < 60
  then self:Notify("You can only send an ad once every 60 seconds.");
  else self:SendAddonMessage(addonPrefix.rpfind, "This is a test.");
       self.Finder.lastAdTime = time();
       self:Notify("Ad send. Good luck!");
  end;
end;

-- RP_Find:RegisterEvent("CHAT_MSG_ADDON",        "AddonMessageReceived");
-- RP_Find:RegisterEvent("BN_CHAT_MSG_ADDON",     "AddonMessageReceived");
-- RP_Find:RegisterEvent("CHAT_MSG_ADDON_LOGGED", "AddonMessageReceived");

-- menu data
--
local buttonSize = 85;

RP_Find.closeButton  = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.closeButton:SetText(L["Button Close"]);
RP_Find.closeButton:ClearAllPoints();
RP_Find.closeButton:SetPoint("BOTTOMRIGHT", Finder.frame, "BOTTOMRIGHT", -20, 20);
RP_Find.closeButton:SetWidth(buttonSize);
RP_Find.closeButton:SetScript("OnClick", function(self) Finder:Hide(); end);

RP_Find.configButton = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.configButton:SetText(L["Button Config"]);
RP_Find.configButton:ClearAllPoints();
RP_Find.configButton:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 20);
RP_Find.configButton:SetWidth(buttonSize);
RP_Find.configButton:SetScript("OnClick", function() RP_Find.Finder:Hide(); RP_Find:OpenOptions(); end);

_G["SLASH_RP_FIND1"] = SLASH;

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

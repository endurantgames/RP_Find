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
local addonChannel   = "xtensionxtooltip2";
local addonPrefix    = { trp3 = "RPB1" };

local col = {
  gray   = function(str) return   LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(str) end,
  orange = function(str) return LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(str) end,
  white  = function(str) return       WHITE_FONT_COLOR:WrapTextInColorCode(str) end,
  red    = function(str) return         RED_FONT_COLOR:WrapTextInColorCode(str) end,
  green  = function(str) return       GREEN_FONT_COLOR:WrapTextInColorCode(str) end,
  addon  = function(str) return     RP_FIND_FONT_COLOR:WrapTextInColorCode(str) end,
};

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
  notifySoundOrder = { 139868, 1887, 12867, 12889, 118460, 5274,   38326,  31578, 9378, 
                       3332,   3175, 8959,  39516, 111370, 110985, 111368, 111367 },
};
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

function RP_Find:SmartPruneDatabase(interactive)
  if not self.db.profile.config.useSmartPruning then return end;
  self.Finder:Hide();
  InterfaceOptionsFrame:Hide();
  local now = time();
  local count = 0;

  local function getTimestamp(playerData) return playerData.last and playerData.last.when or 0 end;

  local secs = math.exp(self.db.profile.config.smartPruningThreshold);
  for   playerName, playerData in pairs(self.data.rolePlayers)
  do    if   now - getTimestamp(playerData) > secs and playerName ~= self.me
        then -- self:PurgePlayer(name)
             count = count + 1; 
        end; 
  end;

  UpdateAddOnMemoryUsage();

  if   interactive and count > 0 
  then self:Notify(string.format(L["Format Smart Pruning Done"], count)); 
  else self:Notify(L["Notify Smart Pruning Zero"]);
  end;
end;

function RP_Find:WipeDatabaseNow()
  self.preWipeMemory = GetAddOnMemoryUsage(self.addOnName);
  InterfaceOptionsFrame:Hide();
  self.Finder:Hide();
  self.Finder:LetTheChildrenGo();
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

local function playNotifySound() PlaySound(RP_Find.db.profile.config.notifySound); end;

function RP_Find:Notify(forceChat, ...) 
  local  dots = { ... };
  if     type(forceChat) == "boolean" and forceChat
  then   print("[" .. self.addOnTitle .. "]", unpack(dots));
  elseif type(forceChat) == "boolean" -- and not forceChat
  then   self:SendToast(table.concat(dots, " "))
  elseif self.db.profile.config.notifyMethod == "chat"
  then   print("[" .. self.addOnTitle .. "]", forceChat, unpack(dots));
         playNotifySound();
  else   self:SendToast(forceChat .. table.concat(dots, " "));
         playNotifySound();
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

function RP_Find:CountPlayerRecords()
  local count = 0;
  for _, _ in pairs(self.playerRecords) do count = count + 1; end;
  return count;
end;

function RP_Find:CountPlayerData()
  local count = 0
  for _, _ in pairs(self.data.rolePlayers) do count = count + 1 end;
  return count;
end;

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
      OnClick = function() RP_Find.OnMinimapButtonClick() end,
      OnEnter = function() RP_Find.OnMinimapButtonEnter() end,
      OnLeave = function() RP_Find.OnMinimapButtonLeave() end,
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
      tintAlpha        = 2/3,
      tintHue          = 198,
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
Finder.col   = { 0.35, 0.25 };

Finder:SetWidth(500);
Finder:SetHeight(300);
Finder:SetLayout("Flow");
Finder:Hide();
function Finder:SetTint(r, g, b, a)
  self.r, self.g, self.b, self.a = 
    r or self.r, g or self.g, b or self.b, a or self.a;
end;
function Finder:TintMyRide(r, g, b, a)
  r, g, b, a = r or self.r, g or self.g, b or self.b, a or self.a;
  self.regionList = { self.frame:GetRegions() };

  for _, region in ipairs(self.regionList)
  do  region:SetVertexColor(r, g, b, a);
  end;

  for _, side in ipairs({"Left", "Right", "Middle"})
  do for _, button in ipairs({"closeButton", "configButton"})
     do RP_Find[button][side]:SetDesaturated(true);
        RP_Find[button][side]:SetVertexColor(r, g, b, a);
     end;
  end;

  self.r, self.g, self.b, self.a = r, g, b, a
end;
Finder:SetTint(RP_FIND_FONT_COLOR:GetRGBA());
Finder:SetTint(nil, nil, nil, 2/3);

function Finder:AutoTint()
  self.addOnColor = LibColor.rgb(self.r, self.g, self.b, self.a);

  self.h, self.s, self.L, self.a = self.addOnColor:hsla();
  self.h = RP_Find.db.profile.config.tintHue;

  self.addOnColor = LibColor.hsl(
    RP_Find.db.profile.config.tintHue, 
    self.s, self.L, self.a
  );

  self.addOnColor = self.addOnColor:lighten_to(0.25);
  self.addOnColor = self.addOnColor:desaturate_to(0.75);

  self.r, self.g, self.b, self.a = self.addOnColor:rgba();
  self:TintMyRide();
end;

Finder.content:ClearAllPoints();
Finder.content:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 50);
Finder.content:SetPoint("TOPRIGHT", Finder.frame, "TOPRIGHT", -20, -50);

local displayFrame = AceGUI:Create("InlineGroup");
      displayFrame:SetFullWidth(true);
      displayFrame:SetFullHeight(true);
      displayFrame:SetLayout("Flow");
Finder:AddChild(displayFrame);

local headers = AceGUI:Create("SimpleGroup");
      headers:SetLayout("Flow");
      headers:SetFullWidth(true);
displayFrame:AddChild(headers);

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
  Finder:UpdateDisplay();
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

Finder.playerListFrame = AceGUI:Create("SimpleGroup");
Finder.playerListFrame:SetFullWidth(true);
Finder.playerListFrame:SetFullHeight(true);
Finder.playerListFrame:SetLayout("Flow");
displayFrame:AddChild(Finder.playerListFrame);

function Finder:UpdateTitle(event, ...)
  self:SetTitle(RP_Find:CountPlayerRecords() .. " Player Records");
end;

function Finder:UpdateDisplay(event, ...)
  if not self:IsShown() then return end;

  self:UpdateTitle(); 

  local scrollContainer = AceGUI:Create("SimpleGroup");
        scrollContainer:SetFullWidth(true);
        scrollContainer:SetFullHeight(true);
        scrollContainer:SetLayout("Fill");

  self.playerListFrame:AddChild(scrollContainer);

  local scrollFrame = AceGUI:Create("ScrollFrame");
        scrollFrame:SetLayout("Flow");
        scrollContainer:AddChild(scrollFrame);

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

end;

function Finder:LetTheChildrenGo(event) self.playerListFrame:ReleaseChildren(); end;

Finder:SetCallback("OnShow",  "UpdateDisplay"   );
Finder:SetCallback("OnClose", "LetTheChildrenGo");

function RP_Find:UpdateDisplay(...) self.Finder:UpdateDisplay(...); end

RP_Find.timer = RP_Find:ScheduleRepeatingTimer("UpdateDisplay", 10);

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
          tintHue =
          { name = "Tint Hue",
            type = "range",
            order = 50,
            min = 0,
            max = 360,
            step = 1,
            get = function() return self.db.profile.config.tintHue end,
            set = function(info, value) 
                    self.Finder.frame:Show();
                    self.Finder.frame:Lower();
                    self.db.profile.config.tintHue = value
                    self.Finder:AutoTint()
                  end,
            width = "full",
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
                width      = "full",
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
                             local value, units, warn;
                             local currentUsage = GetAddOnMemoryUsage(self.addOnName);

                             if     currentUsage < 1000
                             then   value, units, warn = currentUsage, "KB", "";
                             elseif currentUsage < 1000 * 1000
                             then   value, units, warn = currentUsage / 1000, "MB", "";
                                    if value > 2 then warn = L["Warning High Memory MB"] end;
                             else   value, units, warn = currentUsage / 1000 * 1000, "GB",
                                    L["Warning High Memory GB"];
                             end;
                             return string.format(L["Format Memory Usage"], value, units, warn);
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
            width         = "full",
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
          deleteDBnow =
          { name      = L["Button Delete DB Now"],
            type      = "execute",
            width     = "full",
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
                width         = "full",
                order         = 95,
                desc          = L["Config Use Smart Pruning Tooltip"],
                get           = function() return self.db.profile.config.useSmartPruning end,
                set           = function(info, value) self.db.profile.config.useSmartPruning  = value end,
                disabled      = function() return self.db.profile.config.deleteDBonLogin end,
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
                order               = 105,
                get                 = function() return self.db.profile.config.smartPruningThreshold end,
                set                 = function(info, value) self.db.profile.config.smartPruningThreshold  = value end,
                disabled            = function() return not self.db.profile.config.useSmartPruning end,
              },
              smartPruneNow =
              { name        = L["Button Smart Prune Database"],
                type        = "execute",
                width       = "full",
                order       = 110,
                desc        = L["Button Smart Prune Database Tooltip"],
                func        = function() self:SmartPruneDatabase(true) end, -- true = interactive
                disabled    = function() return not self.db.profile.config.useSmartPruning end,
              },
            },
          },
        },
      },
      notifyOptions =
      { type = "group",
        name = L["Config Notify"],
        order = 2,
        args = 
        {
          loginMessage =
          { name       = L["Config Login Message"],
            type       = "toggle",
            order      = 10,
            desc       = L["Config Login Message Tooltip"],
            get        = function() return self.db.profile.config.loginMessage end,
            set        = function(info, value) self.db.profile.config.loginMessage  = value end,
            width      = "full",
          },
          notifyMethod =
          { name       = L["Config Notify Method"],
            type       = "select",
            order      = 20,
            desc       = L["Config Notify Method Tooltip"],
            get        = function() return self.db.profile.config.notifyMethod end,
            set        = function(info, value) self.db.profile.config.notifyMethod  = value end,
            sorting    = { "chat", "toast" },
            width      = 1,
            values     = { chat = L["Menu Notify Method Chat"], toast = L["Menu Notify Method Toast"] },
          },
          spacer1 = Spacer({ order = 21 }),
          notifySound =
          { name      = L["Config Notify Sound"],
            type      = "select",
            order     = 30,
            desc      = L["Config Notify Sound Tooltip"],
            get       = function() return self.db.profile.config.notifySound end,
            set       = function(info, value) self.db.profile.config.notifySound  = value; PlaySound(value); end,
            values    = menu.notifySound,
            sorting   = menu.notifySoundOrder,
            width     = 1,
          },
          testNotifyMethod =
          { name           = L["Button Test Notify"],
            type           = "execute",
            order          = 40,
            desc           = L["Button Test Notify Tooltip"],
            func           = function() 
                               local chat = self.db.profile.config.notifyMethod == "chat" 
                               self:Notify(L[chat and "Notify Test Chat" 
                                                   or "Notify Test Toast"]) 
                               end,
            width          = 2.1,
          },
          trp3Group        =
          { name           = L["Config TRP3"],
            type           = "group",
            inline         = true,
            order          = 50,
            args           =
            {
              instructTRP3 =
              { name       = L["Instruct TRP3"],
                type       = "description",
                order      = 60,
                width      = "full"
              },
              alertTRP3Scan =
              { name        = L["Config Alert TRP3 Scan"],
                type        = "toggle",
                order       = 70,
                desc        = L["Config Alert TRP3 Scan Tooltip"],
                get         = function() return self.db.profile.config.alertTRP3Scan end,
                set         = function(info, value) self.db.profile.config.alertTRP3Scan    = value end,
                disabled    = function() return not self.db.profile.config.monitorTRP3 end,
                width       = "full",
              },
              spacer1          = Spacer({ order = 80 }),
              alertAllTRP3Scan =
              { name           = L["Config Alert All TRP3 Scan"],
                type           = "toggle",
                order          = 90,
                desc           = L["Config Alert All TRP3 Scan Tooltip"],
                get            = function() return self.db.profile.config.alertAllTRP3Scan end,
                set            = function(info, value) self.db.profile.config.alertAllTRP3Scan   = value end,
                disabled       = function() return not self.db.profile.config.alertTRP3Scan end,
                width          = 1.5,
              },
              alertTRP3Connect =
              { name           = L["Config Alert TRP3 Connect"],
                type           = "toggle",
                order          = 100,
                desc           = L["Config Alert TRP3 Connect Tooltip"],
                get            = function() return self.db.profile.config.alertTRP3Connect end,
                set            = function(info, value) self.db.profile.config.alertTRP3Connect  = value end,
                disabled       = function() return not self.db.profile.config.monitorTRP3 end,
                width          = "full",
              },
            },
          },
        },
      },
      credits             =
      { type            = "group",
        name            = L["Credits Header"],
        order           = 10,
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

function RP_Find.OnMinimapButtonClick(frame, button)
  if     button == "RightButton"
  then   RP_Find:OpenOptions();
  elseif RP_Find.Finder:IsShown()
  then   RP_Find.Finder:Hide();
  else   RP_Find.Finder:Show();
  end;
end;

function RP_Find.OnMinimapButtonEnter(frame)
  GameTooltip:ClearLines();
  GameTooltip:SetOwner(RP_Find.Finder.frame, "ANCHOR_CURSOR");
  GameTooltip:SetOwner(RP_Find.Finder.frame, "ANCHOR_PRESERVE");
  GameTooltip:AddLine(RP_Find.addOnTitle);
  GameTooltip:AddDoubleLine("Left-Click", "Open Finder Window");
  GameTooltip:AddDoubleLine("Right-Click", RP_Find.addOnTitle .. " Options");
  GameTooltip:Show();
end;

function RP_Find.OnMinimapButtonLeave(frame) GameTooltip:Hide(); end;

function RP_Find:OnEnable()
  self.realm = GetNormalizedRealmName() or GetRealmName():gsub("[%-%s]","");
  self.me    = UnitName("player") .. "-" .. RP_Find.realm;

  self:InitializeToast();
  self:LoadSelfRecord();

  self:SmartPruneDatabase(false); -- false = not interactive

  self:RegisterMspReceived();
  self:RegisterTrp3Channel();

  if   self.db.profile.config.loginMessage 
  then self:Notify(L["Notify Login Message"]); 
  end;

  self.Finder:AutoTint();
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
      then self:GetPlayerRecord(playerName, server, "MSP_CALLBACK");
           self.Finder:UpdateDisplay();
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

function RP_Find:RegisterTrp3Channel()
  if not C_ChatInfo.IsAddonMessagePrefixRegistered(addonPrefix.trp3)
  then   RP_Find.trp3ChannelRegistered = 
           C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix.trp3);
  end;

  local  haveJoinedAddonChannel, channelCount = haveJoinedChannel(addonChannel);
  if not haveJoinedAddonChannel and channelCount < 10
  then   JoinTemporaryChannel(addonChannel);
  end;
end;

function RP_Find:AddonMessageReceived(event, prefix, text, channel, sender)
  if   self.db.profile.config.monitorTRP3 
   and prefix == addonPrefix.trp3 
   and sender ~= self.me
  then if     text:find("^RPB1~TRP3HI")
       then   self:GetPlayerRecord(sender, nil);
              self.Finder:UpdateDisplay();

              if   self.db.profile.config.alertTRP3Connect
              then self:Notify(L["Format Alert TRP3 Connect"], sender);
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
       end;
  end;
end;

RP_Find:RegisterEvent("CHAT_MSG_ADDON",        "AddonMessageReceived");
RP_Find:RegisterEvent("BN_CHAT_MSG_ADDON",     "AddonMessageReceived");
RP_Find:RegisterEvent("CHAT_MSG_ADDON_LOGGED", "AddonMessageReceived");

-- menu data
--
local buttonSize = 85;

--[[
RP_Find.resetButton  = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.resetButton:SetText(L["Button Clear"]);
RP_Find.resetButton:ClearAllPoints();
RP_Find.resetButton:SetPoint("BOTTOMRIGHT", Finder.frame, "BOTTOMRIGHT", -20 - buttonSize * 1 - 5 * 1, 20);
RP_Find.resetButton:SetWidth(buttonSize);
RP_Find.resetButton:SetScript("OnClick", function(self) StaticPopup_Show(POPUP_CLEAR); end);

RP_Find.cancelButton  = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.cancelButton:SetText( L["Button Cancel"]);
RP_Find.cancelButton:ClearAllPoints();
RP_Find.cancelButton:SetPoint("BOTTOMRIGHT", Finder.frame, "BOTTOMRIGHT",  -20, 20);
RP_Find.cancelButton:SetWidth(buttonSize);
RP_Find.cancelButton:SetScript("OnClick", function(self) Finder:ClearPending(); Finder:Hide() end);

RP_Find.saveButton  = CreateFrame("Button", nil, Finder.frame, "UIPanelButtonTemplate");
RP_Find.saveButton:SetText(L["Button Save"]);
RP_Find.saveButton:ClearAllPoints();
RP_Find.saveButton:SetPoint("BOTTOMRIGHT", Finder.frame, "BOTTOMRIGHT", -20 - buttonSize * 2 - 5 * 2, 20);
RP_Find.saveButton:SetWidth(buttonSize);
RP_Find.saveButton:SetScript("OnClick", function(self) Finder:ApplyPending(); Finder:Hide(); end);
--]]

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

--[[
local finderTooltipsCheckbox = CreateFrame("Checkbutton", nil, Finder.frame, "ChatConfigCheckButtonTemplate");
finderTooltipsCheckbox:ClearAllPoints();
finderTooltipsCheckbox:SetSize(20,20);
finderTooltipsCheckbox:SetPoint("TOPRIGHT", Finder.frame, "TOPRIGHT", -72, -28);

local function finderTooltipsTooltip()
  if not RP_Find.db.profile.config.finderTooltips then return end;
  GameTooltip:ClearLines();
  GameTooltip:SetOwner(finderTooltipsCheckbox, "ANCHOR_TOP");
  GameTooltip:AddLine(L["Config Finder Tooltips"]);
  GameTooltip:AddLine(L["Config Finder Tooltips Tooltip"], 1, 1, 1, true);
  GameTooltip:Show();
end;

finderTooltipsCheckbox:SetScript("OnEnter", finderTooltipsTooltip);
finderTooltipsCheckbox:SetScript("OnLeave", hideTooltip);
finderTooltipsCheckbox:SetScript("OnShow", 
  function(self)
    self:SetChecked(RP_Find.db.profile.config.finderTooltips);
  end);
finderTooltipsCheckbox:SetScript("OnClick",
  function(self)
    RP_Find.db.profile.config.finderTooltips = self:GetChecked();
    self:SetChecked(RP_Find.db.profile.config.finderTooltips);
  end);

local finderTooltipsLabel = Finder.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalGraySmall");
finderTooltipsLabel:SetText(L["Label Finder Tooltips"]);
finderTooltipsLabel:SetPoint("LEFT", finderTooltipsCheckbox, "RIGHT", 2, 0);
--]]

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

-- rpFind
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
--
-- This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

local addOnName, ns = ...;

local function notify(...) print("[" .. RP_Find.addOnTitle .. "]", ...) end;

local RP_Find = LibStub("AceAddon-3.0"):NewAddon( 
        addOnName, 
        "AceConsole-3.0", 
        "AceEvent-3.0",
        "AceTimer-3.0"
      );

RP_Find.addOnName    = addOnName;
RP_Find.addOnTitle   = GetAddOnMetadata(addOnName, "Title");
RP_Find.addOnVersion = GetAddOnMetadata(addOnName, "Version");
RP_Find.addOnIcon    = "Interface\\ICONS\\inv_misc_tolbaradsearchlight";
RP_Find.addOnColor   = { 221 / 255, 255 / 255, 51 / 255, 1 };

local L = LibStub("AceLocale-3.0"):GetLocale(addOnName);
local AceGUI = LibStub("AceGUI-3.0");

local configDB = "RP_Find_ConfigDB";
local finderDB = "RP_FindDB";

local addonChannel = "xtensionxtooltip2";
local addonPrefix = { trp3 = "RPB1" };
local PLAYER_RECORD = "RP_Find Player Record";

local function initializeDatabase()
  _G[finderDB] = _G[finderDB] or {};
  local database = _G[finderDB];

  database.rolePlayers = database.rolePlayers or {};
  RP_Find.data = database;
  
  RP_Find.playerRecords = {};
end;

function RP_Find:NewPlayerRecord(playerName, server, sourceID, playerData)

  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));

  local playerRecord = {}
  for   methodName, func in pairs(self.PlayerMethods)
  do    playerRecord[methodName] = func;
  end;

  playerRecord.playerName = playerName;
  playerRecord:Initialize();

  if   playerData
  then for field, value in pairs(playerData)
       do   playerRecord:Set(field, value, sourceID or "UNKNOWN");
       end;
  end;

  if not playerRecord:Get("First Seen") then playerRecord:Set("First Seen", nil) end;

  self.playerRecords[playerName] = playerRecord;
  return playerRecord;
end;

function RP_Find:GetPlayerRecord(playerName, server, sourceID)
  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));
  if   self.playerRecords[playerName]
  then return self.playerRecords[playerName]
  else return self:NewPlayerRecord(playerName, nil, sourceID);
  end;
end;

function RP_Find:GetAllPlayerRecords() 
  local list = {};
  for playerName, playerRecord in pairs(self.playerRecords)
  do table.insert(list, playerRecord)
  end;
  return list;
end;

function RP_Find:CountPlayerRecords()
  local count = 0;
  for playerName, _ in pairs(self.playerRecords) do count = count + 1; end;
  return count;
end;

function RP_Find:CountPlayerData()
  local count = 0
  for playerName, _ in pairs(self.data.rolePlayers) do count = count + 1 end;
  return count;
end;

RP_Find.PlayerMethods =
{ 
  ["Initialize"] =
    function(self)
      RP_Find.data.rolePlayers[self.playerName] 
        = RP_Find.data.rolePlayers[self.playerName] or {};
      self.data        = RP_Find.data.rolePlayers[self.playerName];
      self.data.fields = self.data.fields or {};
      self.data.last   = self.data.last or {};
      self.data.last.when = time();
      self.type        = PLAYER_RECORD;
      return self;
    end,

  ["Set"] =
    function(self, field, value, sourceID)
      self.data.fields[field] = self.data.fields[field] or {};
      self.data.fields[field].value = value;
      self.data.fields[field].sourceID = sourceID;
      self.data.fields[field].when = time();
      self.data.last.when = time();
      return self;
    end,

  ["SetTimestamp"] =
    function(self, field, timeStamp, sourceID)
      timeStamp = timeStamp or time();
      if not field
      then   self.data.last.when = timeStamp
      elseif self.data.fields[field]
      then   self.data.fields[field].when = timeStamp;
      elseif type(field) == "string"
      then   self:Set(field, nil, sourceID, { when = timeStamp });
      end;
      return self;
    end,

  ["GetPlayerName"] = function(self) return self.playerName; end,

  ["Get"] =
    function(self, field)
      if self.data.fields[field]
      then return self.data.fields[field].value
      else return nil
      end;
    end,

  ["GetTimestamp"] =
    function(self, field)
      if     not field then return self.data.last.when or time()
      elseif self.data.fields[field] 
      then   return self.data.fields[field].when or time()
      else   return time()
      end;
    end,

  ["GetHumanReadableTimestamp"] =
    function(self, field, format)
      local now = time();
      local integerTimestamp = self:GetTimestamp(field);
      local delta = now - integerTimestamp;
      if   format 
      then return date(format, integerTimestamp)
      elseif delta > 24 * 60 * 60
      then return date("%x", integerTimestamp);
      elseif delta > 60 * 60
      then return date("%X", integerTimestamp);
      elseif delta > 10
      then return string.format("%i |4minute:minutes; ago", math.ceil(delta / 60));
      else return string.format("<1 minute ago", delta);
      end
    end,

  ["GetSource"] = 
    function(self, field)
      if not field then return self.data.last.sourceID
      elseif self.data.fields[field]
      then   return self.data.fields[field].sourceID
      else   return "UNKNOWN"
      end
    end,

  ["GetAll"] =
    function(self, field)
      if not field then return self.data.fields
      elseif self.data.fields[field]
      then   return self.data.fields[field].value, 
                    self.data.fields[field].when, 
                    self.data.fields[field].sourceID
      else   return nil, time(), "UNKNOWN", {}
      end
    end,
};

local col = {};
function col.gray(text)   return LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(text) end;
function col.orange(text) return LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(text)    end;
function col.white(text)  return WHITE_FONT_COLOR:WrapTextInColorCode(text) end;

local ORANGE = LEGENDARY_ORANGE_COLOR:GenerateHexColor();
local WHITE  = WHITE_FONT_COLOR:GenerateHexColor();

local myDataBroker = 
  LibStub("LibDataBroker-1.1"):NewDataObject(
    RP_Find.addOnTitle,
    { type    = "data source",
    text    = RP_Find.addOnTitle,
    icon    = RP_Find.addOnIcon,
    OnClick = function() RP_Find:ToggleFinderFrame() end,
    }
 );
        
local myDBicon = LibStub("LibDBIcon-1.0");

local myDefaults =
{ profile =
  { config =
    { showIcon       = true,
      finderTooltips = true,
      monitorMSP     = true,
      monitorTRP3    = true,
      alertTRP3Scan  = false,
    },
  },
};

local recordSortField = "playerName";
local recordSortFieldReverse = false;

local function sortPlayerRecords(a, b)
  local function helper(booleanValue)
    if recordSortFieldReverse
    then return not booleanValue
    else return booleanValue
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

Finder:SetWidth(500);
Finder:SetHeight(300);
Finder:SetLayout("Flow");
Finder.content:ClearAllPoints();
Finder.content:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 50);
Finder.content:SetPoint("TOPRIGHT", Finder.frame, "TOPRIGHT", -20, -50);
Finder:Hide();

local col = { 0.35, 0.25 };

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

local ARROW_UP   = " |TInterface\\Buttons\\Arrow-Up-Up:0:0|t";
local ARROW_DOWN = " |TInterface\\Buttons\\Arrow-Down-Up:0:0|t";
local function ListHeader_SetRecordSortField(self, event, button)
  recordSortField = self.recordSortField;
  for headerName, header in pairs(headers.list)
  do  if recordSortField == self.recordSortField and recordSortFieldReverse and header.recordSortField == self.recordSortField
      then recordSortFieldReverse = false;
           header:SetText(header.baseText .. ARROW_UP);
      elseif recordSortField == self.recordSortField and header.recordSortField == self.recordSortField
      then recordSortFieldReverse = true;
           header:SetText(header.baseText .. ARROW_DOWN);
      elseif header.recordSortField == self.recordSortField
      then recordSortFieldReverse = false;
      else header:SetText(header.baseText)
      end;
  end;
  Finder:UpdateDisplay();
end;

local currentCol = 1;

local function makeListHeader(baseText, sortField)
  local newHeader = AceGUI:Create("InteractiveLabel");
  newHeader:SetRelativeWidth(col[currentCol]);
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

--[===[
local nameHeader = AceGUI:Create("InteractiveLabel");
nameHeader:SetRelativeWidth(col[1]);
nameHeader:SetFontObject(GameFontHighlightSmall);
nameHeader.baseText = "Name";
nameHeader:SetText(nameHeader.baseText);
nameHeader:SetColor(1, 1, 0);
nameHeader.recordSortField = "playerName";
nameHeader:SetCallback("OnClick", ListHeader_SetRecordSortField)
headers:AddChild(nameHeader);

local lastHeader = AceGUI:Create("InteractiveLabel");
lastHeader:SetRelativeWidth(col[2]);
lastHeader:SetFontObject(GameFontHighlightSmall);
lastHeader.baseText = "Last Seen";
lastHeader:SetText(lastHeader.baseText);
lastHeader:SetColor(1, 1, 0);
lastHeader.recordSortField = "timestamp";
lastHeader:SetCallback("OnClick", ListHeader_SetRecordSortField)
headers:AddChild(lastHeader);
--]===]


makeListHeader("Name",      "playerName");
makeListHeader("Last Seen", "timestamp" );

Finder.playerListFrame = AceGUI:Create("SimpleGroup");
Finder.playerListFrame:SetFullWidth(true);
Finder.playerListFrame:SetFullHeight(true);
Finder.playerListFrame:SetLayout("Flow");
displayFrame:AddChild(Finder.playerListFrame);

function Finder:UpdateTitle(event, ...)
  self:SetTitle(RP_Find.addOnTitle .. " - " 
             .. RP_Find:CountPlayerData() 
             .. " players known ("
             .. RP_Find:CountPlayerRecords() 
             .. " loaded)");
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
      nameField:SetRelativeWidth(col[1]);
      line:AddChild(nameField);

      lastSeenField = AceGUI:Create("Label");
      lastSeenField:SetFontObject(GameFontNormalSmall);
      lastSeenField:SetText(playerRecord:GetHumanReadableTimestamp());
      lastSeenField:SetRelativeWidth(col[2]);
      line:AddChild(lastSeenField);

      scrollFrame:AddChild(line);
  end;

end;

function Finder:LetTheChildrenGo(event)
  self.playerListFrame:ReleaseChildren();
end;

Finder:SetCallback("OnShow", "UpdateDisplay");
Finder:SetCallback("OnClose", "LetTheChildrenGo");


function RP_Find:UpdateDisplay(...) self.Finder:UpdateDisplay(...); end

RP_Find.timer = RP_Find:ScheduleRepeatingTimer("UpdateDisplay", 10);

RP_Find.Finder = Finder;

function RP_Find:LoadSelfRecord()
  self.my = self:GetPlayerRecord(self.me, self.realm);
end;

function RP_Find:OnInitialize()

  self.db = LibStub("AceDB-3.0"):New(configDB, myDefaults);
    
  self.db.RegisterCallback(self, "OnProfileChanged", "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileCopied",  "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileReset",   "LoadSelfRecord");
  
  self.options               =
  { type                     = "group",
    name                     = RP_Find.addOnTitle,
    order                    = 1,
    args                     =
    { versionInfo            =
      { type                 = "description",
        name                 = L["Version Info"],
        order                = 1,
      },
      configOptions          =
      { type                 = "group",
        name                 = L["Config Options"],
        order                = 1,
        args                 =
        { showIcon           =
          { name             = L["Config Show Icon"],
            type             = "toggle",
            order            = 1,
            desc             = L["Config Show Icon Tooltip"],
            get              = function() return self.db.profile.config.showIcon end,
            set              = "ToggleMinimapIcon",
            width            = 1.5,
          },
          monitorMSP         =
          { name             = L["Config Monitor MSP"],
            type             = "toggle",
            order            = 2,
            desc             = L["Config Monitor MSP Tooltip"],
            get              = function() return self.db.profile.config.monitorMSP end,
            set              = function(info, value) self.db.profile.config.monitorMSP = value end,
            disabled         = function() return not msp end,
          },
          monitorTRP3        =
          { name             = L["Config Monitor TRP3"],
            type             = "toggle",
            order            = 3,
            desc             = L["Config Monitor TRP3 Tooltip"],
            get              = function() return self.db.profile.config.monitorTRP3 end,
            set              = function(info, value) self.db.profile.config.monitorTRP3 = value end,
          },
          alertTRP3Scan      =
          { name             = L["Config Alert TRP3 Scan"],
            type             = "toggle",
            order            = 4,
            desc             = L["Config Alert TRP3 Scan Tooltip"],
            get              = function() return self.db.profile.config.alertTRP3Scan end,
            set              = function(info, value) self.db.profile.config.alertTRP3Scan = value end,
            disabled         = function() return not self.db.profile.config.monitorTRP3 end,
          },
          alertAllTRP3Scan   = 
          { name             = L["Config Alert All TRP3 Scan"],
            type             = "toggle",
            order            = 5,
            desc             = L["Config Alert All TRP3 Scan Tooltip"],
            get              = function() return self.db.profile.config.alertAllTRP3Scan end,
            set              = function(info, value) self.db.profile.config.alertAllTRP3Scan = value end,
            disabled         = function() return not self.db.profile.config.alertTRP3Scan end,
            hidden           = function() return not self.db.profile.config.monitorTRP3 end,
          },
        },
      },
      profiles               = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
      credits                =
        { type               = "group",
          name               = L["Credits Header"],
          order              = 10,
          args               =
          {
            creditsHeader    =
            { type           = "description",
              name           = "|cffffff00" .. L["Credits Header"] .. "|r",
              order          = 2,
              fontSize       = "medium",
            },
            creditsInfo      =
            { type           = "description",
              name           = L["Credits Info"],
              order          = 3,
            },
         },
       },
    },
  };

  myDBicon:Register(RP_Find.addOnTitle, myDataBroker, RP_Find.db.profile.config.ShowIcon);
  self:RegisterChatCommand("rpidicon", "ToggleMinimapIcon");

  LibStub("AceConfig-3.0"):RegisterOptionsTable( self.addOnName, self.options);
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.addOnName, self.addOnTitle, self.options);

  initializeDatabase();

end;

-- data broker
--
function RP_Find:ToggleMinimapIcon()
  self.db.profile.config.showIcon = not self.db.profile.config.showIcon;
  if self.db.profile.config.showIcon then myDBicon:Show() else myDBicon:Hide(); end;
end;

function RP_Find:ToggleFinderFrame() 
  if self.Finder
  then if self.Finder:IsShown() then self.Finder:Hide() else self.Finder:Show(); end;
  end;
end;

_G[addOnName] = RP_Find;

function RP_Find:OnEnable()
    self.realm = GetNormalizedRealmName() or GetRealmName():gsub("[%-%s]","");
    self.me = UnitName("player") .. "-" .. RP_Find.realm;
    self:LoadSelfRecord();
    self:RegisterMspReceived();
    self:RegisterTrp3Channel();
  end;

function RP_Find:RegisterPlayer(playerName, server)
  local playerRecord = self:GetPlayerRecord(playerName, server);
end;

function RP_Find:RegisterMspReceived()
  if not msp then self.db.profile.config.monitorMSP = false; return end;
  tinsert(msp.callback.received, 
    function(playerName) 
      if   self.db.profile.config.monitorMSP and playerName ~= self.me
      then local playerRecord = self:GetPlayerRecord(playerName, server, "MSP_CALLBACK");
           self.Finder:UpdateDisplay();
      end;
    end);
end;

local function haveJoinedChannel(channel)
  local channelData = { GetChannelList() };
  local channelList = {};
  local channelCount = 0;
  while #channelData > 0
  do local channelId = table.remove(channelData, 1);
     local channelName = table.remove(channelData, 1);
     local channelDisabled = table.remove(channelData, 1);
     if not channelDisabled 
     then channelList[channelName] = channelId;
          channelCount = channelCount + 1;
     end;
  end;
  return channelList[channel] ~= nil, channelCount;
end;
function RP_Find:RegisterTrp3Channel()
  if not C_ChatInfo.IsAddonMessagePrefixRegistered(addonPrefix.trp3)
  then   RP_Find.trp3ChannelRegistered = C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix.trp3);
  end;
  local haveJoinedAddonChannel, channelCount = haveJoinedChannel(addonChannel);
  if not haveJoinedAddonChannel and channelCount < 10
  then JoinTemporaryChannel(addonChannel);
  end;
end;

function RP_Find:AddonMessageReceived(event, prefix, text, channel, sender)
  if   self.db.profile.config.monitorTRP3 and prefix == addonPrefix.trp3 
       and sender ~= self.me
  then 
       print(text);
       if     text:find("^RPB1~TRP3HI")
       then   self:GetPlayerRecord(sender, nil);
              self.Finder:UpdateDisplay();
       elseif text:find("^RPB1~C_SCAN~")
       then   self:GetPlayerRecord(sender, nil);
              if   self.db.profile.config.alertTRP3Scan
                   and (self.db.profile.config.alertAllTrp3Scan 
                       or
                       text:find("~" .. C_Map.GetBestMapForUnit("player") .. "$")
                   )
              then notify(
                    string.format(
                      L["Format Alert TRP3 Scan"],
                      sender, 
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
local menu =
{ 
};

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
RP_Find.configButton:SetScript("OnClick", function() RP_Find:OpenOptions() end);

--[[
  RP_Find.configButton:SetScript("OnShow",
  function()
    local autoSave = RP_Find.db.profile.config.autoSave;
    RP_Find.cancelButton:SetShown(not autoSave);
    RP_Find.saveButton:SetShown(not autoSave);
    RP_Find.closeButton:SetShown(autoSave);
  end);
--]]
--
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

local SLASH = "/rpfind";
_G["SLASH_RP_FIND1"] = SLASH;

function RP_Find:HelpCommand()
  notify(L["Slash Commands"]);
  notify(L["Slash Options"]);
end;

SlashCmdList["RP_FIND"] = 
  function(a)
    local  param = { strsplit(" ", a); };
    local  cmd = table.remove(param, 1);

    if     cmd == "" or cmd == "help"                   then RP_Find:HelpCommand();
    elseif cmd:match("^option") or cmd:match("^config") then RP_Find:OpenOptions();
    else   RP_Find:HelpCommand();
    end;
  end;

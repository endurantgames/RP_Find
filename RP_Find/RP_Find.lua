-- rpFind
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
--
-- This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

local addOnName, ns = ...;

local RP_Find = LibStub("AceAddon-3.0"):NewAddon( 
        addOnName, 
        "AceConsole-3.0", 
        "AceEvent-3.0"
        "AceTimer-3.0"
      );

RP_Find.addOnName    = addOnName;
RP_Find.addOnTitle   = GetAddOnMetadata(addOnName, "Title");
RP_Find.addOnVersion = GetAddOnMetadata(addOnName, "Version");
RP_Find.addOnIcon    = "Interface\\ICONS\\inv_misc_tolbaradsearchlight";
RP_Find.addOnColor   = { 221 / 255, 255 / 255, 51 / 255, 1 };

local me, realm;

local L = LibStub("AceLocale-3.0"):GetLocale(addOnName);
local AceGUI = LibStub("AceGUI-3.0");

local configDB = "RP_Find_ConfigDB";
local finderDB = "RP_FindDB";

local PLAYER_RECORD = "RP_Find Player Record";

local function initializeDatabase()
  if not _G[finderDB] then _G[finderDB] = {};
  local database = _G[finderDB];

  database.rolePlayers = database.rolePlayers or {};
  RP_Find.data = database;
  
  RP_Find.playerRecords = {};
end;

function RP_Find:NewPlayerRecord(playerName, server, sourceID, playerData)
  server     = server or realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));

  local playerRecord = {}
  for   methodName, func in pairs(self.PlayerMethods)
  do    playerRecord[methodName] = func;
  end;

  playerRecord:Initialize();

  playerRecord:Log(nil, "Player Record Created", sourceID);

  if   playerData
  then for field, value in pairs(playerData)
       do   playerRecord:Set(field, value, sourceID or "Player Record Created");
       end;
  end;

  self.playerRecords[playerName] = playerRecord;
  return playerRecord;
end;

function RP_Find:GetPlayerRecord(playerName, server)
  server     = server or realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));
  if   self.playerRecords[playerName]
  then return self.playerRecords[playerName]
  else return self:NewPlayerRecord(playerName, nil, AUTOCREATE)
  end;
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
      self.data.log    = self.data.log or {};
      self.data.fields = self.data.fields or {};
      self.data.last   = self.data.last or {};
      self.type        = PLAYER_RECORD;
      return self;
    end,

  ["Log"] =
    function(self, logData, logType, sourceID)
      local now = time();
      self.data.log[now] = self.data.log[now] or {};
      logData = logData or {};
      logData.logType = logData.logType or logType;
      logData.sourceID = logData.sourceId or sourceID or UNKNOWN;
      table.add(self.data.log[now], logData)
      self.data.last.when = now;
      self.data.last.sourceID = sourceID or UNKNOWN;
      return self;
    end,

  ["Set"] =
    function(self, field, value, sourceID, metaData)
      self.data.fields[field].value    = value;
      self.data.fields[field].sourceID = sourceID;
      self.data.fields[field].metaData = metaData;
      self.data.fields[field].when = time();
      self:Log({ field = field, value = value or "nil", }, sourceID, "set");
      return self;
    end,

  ["SetTimestamp"] =
    function(self, field, timeStamp, sourceID)
      timeStamp = timeStamp or time();
      if not field
      then self.data.last.when = timeStamp
           self:Log({ global = true, value = timeStamp }, sourceID, "setTimestamp")
      elseif self.data.fields[field]
      then   self.data.fields[field].when = timeStamp;
             self:Log({ field = field, value = timeStamp }, sourceID, "setTimestamp")
      elseif type(field) == "string"
      then   self:Set(field, nil, sourceID, metaData = { when = timeStamp });
      end;
      return self;
    end,

  ["Get"] =
    function(self, field)
      return self.data.fields[field] and self.data.fields[field].value or nil;
      end,

  ["GetTimestamp"] =
    function(self, field)
      if not field then return self.data.last.when
      elseif self.data.fields[field] 
      then   return self.data.fields[field].when
      else   time()
      end;
    end,

  ["GetSource"] = 
    function(self, field)
      if not field then return self.data.last.sourceID
      elseif self.data.fields[field]
      then   return self.data.fields[field].sourceID
      else   UNKNOWN
      end
    end,

  ["GetMetaData"] =
    function(self, field)
      if not field then return {}
      elseif self.data.fields[field]
      then   return self.data.fields[field].metaData
      else return {}
      end
    end,

  ["GetAll"] =
    function(self, field)
      if not field then return self.data.fields
      elseif self.data.fields[field]
      then   return self.data.fields[field].value, 
                    self.data.fields[field].when, 
                    self.data.fields[field].sourceID,
                    self.data.fields[field].metaData
      else return nil, time(), UNKNOWN, {}
      end,
    end,
};

local function notify(...) print("[" .. RP_Find.addOnTitle .. "]", ...) end;

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
    { showIcon             = true,
      finderTooltips       = true,
    },
  },
};

local Finder = AceGUI:Create("Window");

Finder:SetTitle(addOnName);
Finder:SetSize(500, 300);
Finder.container:SetPoint("BOTTOMLEFT", 20, 50);
Finder.container:SetPoint("TOPLEFT", -20, -50);
Finder:SetCallback("OnShow",
  function(self, event, ...)
    self:SetTitle(addOnName .. " - " .. RP_Find:CountPlayerData() .. " players known ("
      .. RP_Find:CountPlayerRecords() .. " loaded)");
  end);

RP_Find.Finder = Finder;

function RP_Find:LoadSelfRecord()
  self.my = self:GetPlayerRecord(me, realm);
end;

function RP_Find:OnInitialize()
    
  self.db = LibStub("AceDB-3.0"):New(configDB, myDefaults);
    
  self.db.RegisterCallback(self, "OnProfileChanged", "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileCopied",  "LoadSelfRecord");
  self.db.RegisterCallback(self, "OnProfileReset",   "LoadSelfRecord");
  
  self.my = self:GetPlayerRecord(me, realm);

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
  return self.Finder 
     and (self.Finder:IsShown() 
            and self.Finder:Hide()
            or  self.Finder:Show()
         );
end;

_G[addOnName] = RP_Find;

function RP_Find:OnLoad() 
end;

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
RP_Find.closeButton:Hide();

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

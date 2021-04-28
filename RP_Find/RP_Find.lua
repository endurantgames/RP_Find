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
local LibMarkdown       = LibStub("LibMarkdown-1.0");
local LibScrollingTable = LibStub("ScrollingTable");
local L                 = AceLocale:GetLocale(addOnName);

local MEMORY_WARN_MB      = 10;
local MIN_BUTTON_BAR_SIZE = 8;
local MAX_BUTTON_BAR_SIZE = 64;
local BIG_STRING_LIMIT    = 30;
local UPDATE_CYCLE_TIME   = 3;
local MIN_FINDER_WIDTH    = 675;
local MIN_FINDER_HEIGHT   = 345;
local DEFAULT_FINDER_WIDTH = 700;
local DEFAULT_FINDER_HEIGHT = 500;
local HAVE_MSP_DATA       = "have_mspData";
local HAVE_TRP3_DATA      = "have_trp3Data";
local MSP_FIELDS          = { "RA", "RC", "IC", "FC", "AG", "AH", "AW", "CO", "CU", 
                              "FR", "NI", "NT", "PN", "PX", "VA", "TR", "GR", "GS", 
                              "GC" };
local ARROW_UP            = " |TInterface\\Buttons\\Arrow-Up-Up:0:0|t";
local ARROW_DOWN          = " |TInterface\\Buttons\\Arrow-Down-Up:0:0|t";
local SLASH               = "/rpfind|/lfrp|/rpfi";
local configDB            = "RP_Find_ConfigDB";
local finderDB            = "RP_FindDB";
local finderFrameName     = "RP_Find_Finder_Frame";
local addonChannel        = "xtensionxtooltip2";
local chompPrefix         = { rpfind = "LFRP1", }; -- handled by chomp
local addonPrefix         = { trp3   = "RPB1",  }; -- handled by native code
local addOnTitle          = GetAddOnMetadata(addOnName, "Title");
local msp                 = _G["msp"];

local col = {
  gray   = function(str) return   LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(str) end,
  orange = function(str) return LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(str) end,
  white  = function(str) return       WHITE_FONT_COLOR:WrapTextInColorCode(str) end,
  red    = function(str) return         RED_FONT_COLOR:WrapTextInColorCode(str) end,
  green  = function(str) return       GREEN_FONT_COLOR:WrapTextInColorCode(str) end,
  addon  = function(str) return     RP_FIND_FONT_COLOR:WrapTextInColorCode(str) end,
};

-- scan the list of enabled addons
local addon = {};
for i = 1, GetNumAddOns()
do  local name, _, _, enabled = GetAddOnInfo(i); if name then addon[name] = enabled; end;
end;

local IC = -- icons
{ 
  spotlight     = "Interface\\ICONS\\inv_misc_tolbaradsearchlight",
  question      = "Interface\\ICONS\\INV_Misc_QuestionMark",
  sendAd        = "Interface\\ICONS\\Inv_letter_18",
  editAd        = "Interface\\ICONS\\inv_inscription_inkcerulean01",
  previewAd     = "Interface\\ICONS\\Inv_misc_notescript2b",
  readAds       = "Interface\\ICONS\\inv_letter_03",
  tools         = "Interface\\ICONS\\inv_engineering_90_toolbox_green",
  database      = "Interface\\ICONS\\Inv_misc_platnumdisks",
  prune         = "Interface\\ICONS\\inv_pet_broom",
  scan          = "Interface\\ICONS\\ability_hunter_snipertraining",
  scanResults   = "Interface\\ICONS\\ability_hunter_snipershot",
  autosendStart = "Interface\\Icons\\inv_engineering_90_gizmo",
  autosendStop  = "Interface\\Icons\\inv_mechagon_spareparts",
};

local textIC   = -- icons for text
{ rpProfile     = "|A:profession:0:0|a",
  isIC          = "|TInterface\\COMMON\\Indicator-Green:0:0|t",
  isOOC         = "|TInterface\\COMMON\\Indicator-Red:0:0|t",
  isLooking     = "|TInterface\\COMMON\\Indicator-Yellow:0:0|t",
  isStoryteller = "|TInterface\\COMMON\\Indicator-Gray:0:0|t",
  hasAd         = "|A:mailbox:0:0|a",
  mapScan       = "|A:taxinode_continent_neutral:0:0|a",
  isFriend      = "|TInterface\\COMMON\\friendship-heart:0:0|t",
  lgbt          = "|TInterface\\ICONS\\Achievement_DoubleRainbow:0:0:0:0:64:64:32:60:32:60|t",
  walkups       = "|A:flightmaster:0:0|a",
  trial         = "|TInterface\\ICONS\\NewPlayerHelp_Newcomer:0:0|t",
  rpFind        = "|T" .. IC.spotlight .. ":0:0:0:0:64:64:8:56:8:56:85:204:255|t",
  check         = "|TInterface\\COMMON\\Indicator-Green:0:0|t",
  blank         = "|TInterface\\Store\\ServicesAtlas:0::0:0:1024:1024:1023:1024:1023:1024|t",
--[[
  inSameZone    = "|A:minimap-vignettearrow:0:0|a",
  active        = "",
  horde         = "|A:hordesymbol:0:0|a",
  alliance      = "|A:alliancesymbol:0:0|a",
  looking       = "|A:questdaily:0:0|a",
--]]
};

local htmlCodes   =
  { ["blockquote"]  = "<br /><p>" .. textIC.blank .. "|cffff00ff",
    ["/blockquote"] = "|r</p><br />",
    ["/p"]          = "</p><br />",
    ["pre"]         = "<br /><p>" .. textIC.blank .. "|cff00ffff",
    ["/pre"]        = "|r</p><br />",
    ["h2"]          = "<br /><h2>",
    ["h3"]          = "<br /><h3>",
    ["ul"]          = "<br />",
    ["/ul"]         = "<br />",
    ["li"]          = "<p>", --  .. textIC.blank,
    ["/li"]         = "</p><br />",
    ["list_marker"] = "|TInterface\\COMMON\\Indicator-Yellow.PNG:0|t",
  };

for k, v in pairs(htmlCodes) do ACEMARKDOWNWIDGET_CONFIG.LibMarkdownConfig[k] = v; end;

ACEMARKDOWNWIDGET_CONFIG.HtmlStyles.Normal.Spacing = 2;
ACEMARKDOWNWIDGET_CONFIG.HtmlStyles.Normal.red     = 1;
ACEMARKDOWNWIDGET_CONFIG.HtmlStyles.Normal.green   = 1;
ACEMARKDOWNWIDGET_CONFIG.HtmlStyles.Normal.blue    = 1;
ACEMARKDOWNWIDGET_CONFIG.LinkProtocols.default.Popup =
  { Text = L["Link Text Default"],
    PrefixText = addOnTitle .. "\n\n",
    ButtonText = L["Button Got It"], 
  };
ACEMARKDOWNWIDGET_CONFIG.LinkProtocols.http.Popup =
  { Text = L["Link Text HTTP"],
    PrefixText = addOnTitle .. "\n\n",
    ButtonText = L["Button Got It"], 
  };
ACEMARKDOWNWIDGET_CONFIG.LinkProtocols.https.Popup =
  { Text = L["Link Text HTTPS"],
    PrefixText = addOnTitle .. "\n\n",
    ButtonText = L["Button Got It"], 
  };
ACEMARKDOWNWIDGET_CONFIG.LinkProtocols.mailto.Popup =
  { Text = L["Link Text Mailto"],
    PrefixText = addOnTitle .. "\n\n",
    ButtonText = L["Button Got It"], 
  };
 
local zoneList =
{ 1, 7, 10, 18, 21, 22, 23, 27, 37, 47, 49, 52, 57, 64, 71, 76, 80, 83, 84, 85, 87,
  88, 89, 90, 94, 103, 110, 111, 199, 202, 210, 217, 224, 390, 1161, 1259, 1271, 1462,
  1670, };

local pointsOfInterest =
{ [84] = -- Stormwind
  { { x = 48, y = 80, title = L["Subzone The Mage Quarter"     ], r  =  6 },
    { x = 54, y = 51, title = L["Subzone Cathedral Square"     ], r  =  6 },
    { x = 42, y = 64, title = L["Subzone Lion's Rest"          ], r  =  8 },
    { x = 28, y = 36, title = L["Subzone Stormwind Harbor"     ], r  = 16 },
    { x = 63, y = 70, title = L["Subzone Trade District"       ], r  =  7 },
    { x = 74, y = 59, title = L["Subzone Old Town"             ], r  =  6 },
    { x = 80, y = 37, title = L["Subzone Stormwind Keep"       ], r  =  7 },
    { x = 66, y = 36, title = L["Subzone The Dwarven District" ], r  =  8 }, },
  [37] = -- Elwynn Forest
  { { x = 42, y = 64, title = L["Subzone Goldshire"            ], r  =  2 }, },
  [85] = -- Orgrimmar
  { { x = 70, y = 40, title = L["Subzone Valley of Honor"      ], r  =  9 },
    { x = 53, y = 55, title = L["Subzone The Drag"             ], r  =  8 },
    { x = 50, y = 75, title = L["Subzone Valley of Strength"   ], r  =  8 },
    { x = 33, y = 73, title = L["Subzone Valley of Spirits"    ], r  = 10 },
    { x = 37, y = 32, title = L["Subzone Valley of Wisdom"     ], r  = 12 }, },
  [110] = -- Silvermoon City
  { { x = 60, y = 70, title = L["Subzone The Bazaar"           ], r  = 10 },
    { x = 76, y = 80, title = L["Subzone Walk of Elders"       ], r  = 13 },
    { x = 90, y = 58, title = L["Subzone The Royal Exchange"   ], r  = 10 },
    { x = 75, y = 49, title = L["Subzone Murder Row"           ], r  =  7 },
    { x = 85, y = 25, title = L["Subzone Farstriders' Square"  ], r  = 15 },
    { x = 68, y = 37, title = L["Subzone Court of the Sun"     ], r  =  9 },
    { x = 55, y = 20, title = L["Subzone Sunfury Spire"        ], r  = 12 }, },
  [87] = -- Ironforge
  { { x = 70, y = 49, title = L["Subzone Tinkertown"           ], r  = 11 },
    { x = 68, y = 19, title = L["Subzone Hall of Explorers"    ], r  = 17 },
    { x = 49, y = 11, title = L["Subzone The Forlorn Cavern"   ], r  =  8 },
    { x = 38, y = 18, title = L["Subzone The Mystic Ward"      ], r  = 14 },
    { x = 48, y = 49, title = L["Subzone The Great Forge"      ], r  = 25 },
    { x = 17, y = 83, title = L["Subzone Gates of Ironforge"   ], r  = 10 },
    { x = 70, y = 88, title = L["Subzone The Military Ward"    ], r  = 18 },
    { x =  1, y = 75, title = L["Subzone The Commons"          ], r  = 50 }, },
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
  notifySoundOrder = 
  { 139868, 18871, 12867, 12889, 118460, 5274, 18019,  38326,  31578, 9378, 
    3332,   3175, 8959,  39516, 37881, 111370, 110985, 111368, 111367 },
  infoColumn =
  { ["Info Class"           ] = L["Info Class"           ],
    ["Info Race"            ] = L["Info Race"            ],
    ["Info Race Class"      ] = L["Info Race Class"      ],
    ["Info Age"             ] = L["Info Age"             ],
    ["Info Pronouns"        ] = L["Info Pronouns"        ],
    ["Info Height Weight"   ] = L["Info Height Weight"   ],
    ["Info Zone"            ] = L["Info Zone"            ],
    ["Info Status"          ] = L["Info Status"          ],
    ["Info Currently"       ] = L["Info Currently"       ],
    ["Info OOC Info"        ] = L["Info OOC Info"        ],
    ["Info Title"           ] = L["Info Title"           ],
    ["Info Data Timestamp"  ] = L["Info Data Timestamp"  ],
    ["Info Server"          ] = L["Info Server"          ],
    ["Info Subzone"         ] = L["Info Subzone"         ],
    ["Info Zone Subzone"    ] = L["Info Zone Subzone"    ],
    ["Info User ID"         ] = L["Info User ID"         ], },
    -- ["Info Tags"            ] = L["Info Tags"            ],
  infoColumnOrder =
  { "Info Class", "Info Race", "Info Race Class", "Info Age", 
    "Info Pronouns", "Info Zone", "Info Zone Subzone",
    "Info Subzone", "Info Status", "Info Currently", "Info OOC Info", 
    "Info Title", "Info Server", "Info User ID" }, -- "Info Tags", 

  notifyChatType = 
  { ["COMBAT_MISC_INFO"]      = COMBAT_MISC_INFO,
    ["SKILL"]                 = SKILLUPS,
    ["BN_INLINE_TOAST_ALERT"] = BN_INLINE_TOAST_ALERT,
    ["SYSTEM"]                = SYSTEM_MESSAGES,
    ["TRADESKILLS"]           = TRADESKILLS,
    ["CHANNEL"]               = CHANNEL,
    ["SAY"]                   = SAY,
    ["MONSTER_SAY"]           = SAY .. " (" .. CREATURE .. ")",
  },

  notifyChatTypeOrder =
  { "COMBAT_MISC_INFO", "SKILL", "BN_INLINE_TOAST_ALERT",
    "SYSTEM", "TRADESKILLS", "CHANNEL", "SAY", "MONSTER_SAY", },
  zone         = {},
  zoneOrder    = {};
  perPage      = {},
  perPageOrder = {},

};

for i = 10, 30, 5 do menu.perPage[tostring(i)] = tostring(i); table.insert(menu.perPageOrder, tostring(i)) end;

-- we can't just pre-define an order because it's going to vary from language to language
--
local function sortNotifyChatType(a, b) return menu.notifyChatType[a] < menu.notifyChatType[b] end;
local function sortInfo(a, b)           return menu.infoColumn[a]     < menu.infoColumn[b]     end;
local function sortSounds(a, b)         return menu.notifySound[a]    < menu.notifySound[b];   end;
local function sortZones( a, b)         return menu.zone[a       ]    < menu.zone[b       ];   end;

table.sort(menu.notifyChatTypeOrder ,  sortNotifyChatType );
table.sort(menu.infoColumnOrder     ,  sortInfo           );
table.sort(menu.zoneOrder           ,  sortZones          );
table.sort(menu.notifySound         ,  sortSounds         );

for i, mapID in ipairs(zoneList)
do  local info = C_Map.GetMapInfo(mapID);
    if not zoneBacklink[info.name]
    then   menu.zone[mapID] = info.name;
           table.insert(menu.zoneOrder, mapID);
           zoneBacklink[info.name] = mapID;
    end;
end;

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
  if   last_end <= #str then cap = str:sub(last_end); table.insert(t, cap); end;
  str, pat, fpat, last_end, s, e, cap = nil, nil, nil, nil, nil, nil, nil
  return t;
end;

local function getMSPFieldByPlayerName(playerName, field)
  return msp 
     and msp.char 
     and msp.char[playerName] 
     and msp.char[playerName].field
     and msp.char[playerName].field[field]
     and msp.char[playerName].field[field] ~= ""
     and msp.char[playerName].field[field]
     or nil;
         
end;

local function stripColor(text)
  local rrggbb, strippedText = text:match("|cff(%x%x%x%x%x%x)(.+)");
  if    rrggbb 
  then  return strippedText:gsub("|cff%x%x%x%x%x%x",""):gsub("|r", ""), 
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

--[[ info:
  anchor        "ANCHOR_<position>"
  title         text
  titleColor    { r, g, b }
  columns       { { text, text }, { text, text }, ... }
  color1        { r, g, b }
  color2        { r, g, b }
  lines         { text, text, ... }
  color         { r, g, b }
--]]
local function showTooltip(frame, info)
  frame = frame.frame or frame;
  GameTooltip:ClearLines();
  GameTooltip:SetOwner(frame, info.anchor or "ANCHOR_BOTTOM");
  if info.anchorPreserve then GameTooltip:SetOwner(frame, "ANCHOR_PRESERVE"); end;

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
  r, g, b, r2, g2, b2 = nil, nil, nil, nil, nil, nil;
end;

local function hideTooltip() GameTooltip:Hide(); end;

local function colorize(text, timeValue) return text end;
  --[[
local function colorize(text, timeValue)
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
end;
  --]]

local RP_Find = AceAddon:NewAddon(
  addOnName, 
  "AceEvent-3.0", 
  "AceTimer-3.0" , 
  "LibToast-1.0"
);

local function respondToPlayerFlagsChanged(event, unit)
  if   unit ~= "player" then return end;
  if   UnitIsAFK(unit)
  then RP_Find.Finder:DisableUpdates(true)
  else RP_Find.Finder:DisableUpdates(false);
  end;
end;

RP_Find:RegisterEvent("PLAYER_FLAGS_CHANGED", respondToPlayerFlagsChanged);

RP_Find.addOnName    = addOnName;
RP_Find.addOnTitle   = GetAddOnMetadata(addOnName, "Title");
RP_Find.addOnVersion = GetAddOnMetadata(addOnName, "Version");
RP_Find.addOnDesc    = GetAddOnMetadata(addOnName, "Notes");
RP_Find.addOnIcon    = IC.spotlight;
RP_Find.addOnToast   = "RP_Find_notify";
RP_Find.addOnTimers  = {};
RP_Find.addonList    = addon;
RP_Find.mspFields    = MSP_FIELDS;

-- Last counters
function RP_Find:ClearLast(name)               self.db.global.last[name] = nil;                      end;
function RP_Find:SetLast(name, value)          self.db.global.last[name] = value or time()           end;
function RP_Find:GetLast(name)                 return self.db.global.last[name]                      end;
function RP_Find:LastElapsed(name)             return time() - (self:GetLast(name) or 0);            end;
function RP_Find:LastSince(name, value, units) return self:LastElapsed(name) < value * (units or 1); end;
RP_Find.Last = RP_Find.GetLast;

-- timer management
function RP_Find:ClearTimer(name)
  if self.addOnTimers[name]
  then self:CancelTimer(self.addOnTimers[name]);
       self.addOnTimers[name] = nil;
  end;
end;

function RP_Find:SaveTimer(name, value)
  if not self.addOnTimers[name]
  then self.addOnTimers[name] = value
  end;
end;

function RP_Find:HaveTimer(name) return self.addOnTimers[name] end;

function RP_Find:FixColor(text)
  if not self.db.profile.config.lightenColors then return text end;

  local strippedText, rrggbb = stripColor(text);
  if not rrggbb then return text end;

  local col = LibColor("#" .. rrggbb);
  local _, _, lightness = col:hsl();
  if lightness < 0.75 then col = col:lighten_to(0.75) end;
      
  return col:format("|cffrrggbb") .. strippedText .. "|r";
end;

function RP_Find:HaveRPClient(addonToQuery)
  if   addonToQuery
  then return self.addonList[addonToQuery];
  elseif _G["msp"]
  then return true
  end
end;

local popup =
  { -- deleteDBonLogin = "RP_FIND_DELETE_DB_ON_LOGIN_CONFIRMATION",
    deleteDBNow     = "RP_FIND_DELETE_DB_NOW_CONFIRMATION",
  };

local function fixPopup(self) self.text:SetJustifyH("LEFT"); self.text:SetSpacing(3); end;

StaticPopupDialogs[popup.deleteDBNow] =
{ showAlert      = true,
  text           = L["Popup Delete DB Now"],
  button1        = YES,
  button2        = NO,
  exclusive      = true,
  OnAccept       = function() RP_Find:WipeDatabaseNow() end,
  OnCancel       = function() RP_Find:Notify(L["Notify Database Deletion Aborted"]) end,
  timeout        = 60,
  whileDead      = true,
  hideOnEscape   = true,
  hideOnCancel   = true,
  preferredIndex = 3,
  wide           = true,
  OnShow         = fixStaticPopup,
}

function RP_Find:PurgePlayer(name) self.playerRecords[name] = nil; end;

function RP_Find:StartOrStopPruningTimer()
  if     self:HaveTimer("pruning") and self.db.profile.config.useSmartPruning 
  then   -- all is running as expected
  elseif self:HaveTimer("pruning")
  then   self:ClearTimer("pruning");
  elseif self.db.profile.config.useSmartPruning -- and not self.pruningTimer
  then   self:SaveTimer("pruning", self:ScheduleRepeatingTimer("SmartPruneDatabase", 15 * SECONDS_PER_MIN));
  else   -- not self.timers.pruning and not useSmartPruning 
  end;
end;

function RP_Find:SmartPruneDatabase(interactive)
  if not self.db.profile.config.useSmartPruning then return end;

  self.Finder:Hide();
  local now = time();
  local count = 0;

  local function getTimestamp(playerData) return playerData.last and playerData.last.when or 0 
  end;

  local secs = math.exp(self.db.profile.config.smartPruningThreshold);
  for   playerName, playerData in pairs(self.playerRecords)
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

local function initializeDatabase(wipe)
  _G[finderDB] = nil;  -- clear out the previous db
  RP_Find.playerRecords = {};
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
  then   self:SendChatMessage(
           self.db.profile.config.notifyChatType, 
           "[" .. self.addOnTitle .. "] ",
           table.concat(dots, " ")
          )
  elseif type(forceChat) == "boolean" -- and not forceChat
  then   self:SendToast(table.concat(dots, " "))
  else   if   self.db.profile.config.notifyMethod == "chat"
         or   self.db.profile.config.notifyMethod == "both"
         then self:SendChatMessage(
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


function RP_Find:NewPlayerRecord(playerName, server)
  server     = server or self.realm;
  playerName = playerName .. (playerName:match("%-") and "" or ("-" .. server));

  local playerRecord = {}
  playerRecord.playerName = playerName;

  function playerRecord:M(method, ...)
    local func = RP_Find.playerRecordMethods[method]
    if func then return func(self, ...)
    else return print("missing method", method) and nil;
    end;
  end;

  --[[
  for   methodName, _ in pairs(RP_Find.playerRecordMethods)
  do    playerRecord[methodName] 
          = function(self, ...) 
              return RP_Find.playerRecordMethods[methodName](self, ...)
            end;
  end;
  --]]

  playerRecord:M("Initialize");

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
function RP_Find:GetAllPlayerNames(filters, searchPattern)
 
  local filteredCount = 0;
  local totalCount    = 0;

  filters = filters or {};
  searchPattern = searchPattern or "";

  local function nameMatch(playerRecord, pattern)
    pattern = pattern:lower();
    return playerRecord:M("GetRPNameStripped"):lower():match(pattern)
        or playerRecord:M("GetPlayerName"):lower():match(pattern)
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
           table.insert(list, record:M("GetPlayerName")); 
      end
      
      totalCount = totalCount + 1;
  end;
               
  return list, filteredCount, totalCount;
end;

function RP_Find:GetAllPlayerRecords() return self.playerRecords; end;

function RP_Find:OldGetAllPlayerRecords(filters, searchPattern)
 
  local filteredCount = 0;
  local totalCount    = 0;

  filters = filters or {};
  searchPattern = searchPattern or "";

  local function nameMatch(playerRecord, pattern)
    pattern = pattern:lower();
    return playerRecord:M("GetRPNameStripped"):lower():match(pattern)
        or playerRecord:M("GetPlayerName"):lower():match(pattern)
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

function RP_Find:GetMemoryUsage(fmt) -- returns value, units, message, bytes
  local value, units, warn;
  local currentUsage = GetAddOnMemoryUsage(self.addOnName);
  local highMemoryLimitMB = 6;

  if     currentUsage < 1000
  then   value, units, warn = currentUsage, "KB", "";
  elseif currentUsage < 1000 * 1000
  then   value, units, warn = currentUsage / 1000, "MB", "";
         if value > MEMORY_WARN_MB then warn = L["Warning High Memory MB"] end;
  else   value, units, warn = currentUsage / 1000 * 1000, "GB", L["Warning High Memory GB"]
  end;

  local message = string.format(fmt or L["Format Memory Usage"],
                    value, units, warn);
  return value, units, message, currentUsage;
end

function RP_Find:CountPlayerRecords()
  local count = 0;
  for _, _ in pairs(self.playerRecords) do count = count + 1; end;
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
       table.insert(tooltip.columns, { L["Players Loaded"], RP_Find:CountPlayerRecords() });
  end;

  showTooltip(frame, tooltip);
  
  --]]
end;

RP_Find.OnMinimapButtonLeave = hideTooltip;

function RP_Find:SendWhisper(playerName, message, position)
  -- local delta = time() - (self:Last("sendWhisper") or 0) 
  -- delta <= 5 * SECONDS_PER_MIN
  --
  if   self:LastSince("sendWhisper", 5, SECONDS_PER_MIN)
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
  local pingSent = false;

  if     self:HaveRPClient("totalRP3")
  then   TRP3_API.r.sendMSPQuery(player);
         TRP3_API.r.sendQuery(player);
         pingSent = "trp3";
  elseif self:HaveRPClient()
  then   
         pingSent= msp:Request(player, self.mspFields) and msp or false
  end;

  if     pingSent and interactive
  then   RP_Find:Notify(string.format(L["Format Ping Sent"], playerName));
         RP_Find:SetLast("pingPlayer");
  elseif interactive
  then   RP_Find:Notify("Unable to send profile request to " .. player .. ".");
  end;
end;

local nameTooltipFields = 
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

local trp3FieldHash   =
{ status     = { "character",       "RP" },
  curr       = { "character",       "CU" },
  oocinfo    = { "character",       "CO" },
  name       = { "characteristics", "NA" },
  class      = { "characteristics", "CL" },
  race       = { "characteristics", "RA" },
  icon       = { "characteristics", "IC" },
  age        = { "characteristics", "AG" },
  height     = { "characteristics", "HE" },
  weight     = { "characteristics", "WE" },
  title      = { "characteristics", "FT" },
  -- eyecolor   = { "characteristics", "EC" },
  -- birthplace = { "characteristics", "BP" },
  -- home       = { "characteristics", "RE" },
  -- honorific  = { "characteristics", "TI" },
};

local genderHash = { ["2"] = "Male", ["3"] = "Female", };

local infoColumnFunctionHash = 
{ 
  ["Info Class"          ] = function(self) return self:M("GetRPClass")    or "" end,
  ["Info Race"           ] = function(self) return self:M("GetRPRace")     or "" end,
  ["Info Age"            ] = function(self) return self:M("GetRPAge")      or "" end,
  ["Info Pronouns"       ] = function(self) return self:M("GetRPPronouns") or "" end,
  ["Info Title"          ] = function(self) return self:M("GetRPTitle")    or "" end,
  ["Info Currently"      ] = 
    function(self, tooltip) 
      local curr = self:M("GetRPCurr");
      if   tooltip then return curr or ""
      else return curr and menu.infoColumn["Info Currently"] or ""
      end;
    end,
  ["Info OOC Info"       ] = 
    function(self, tooltip) 
      local oocinfo = self:M("GetRPInfo")
      if   tooltip then return oocinfo or ""
      else return oocinfo and menu.infoColumn["Info OOC Info"] or ""
      end;
    end,
  ["Info Zone"           ] = function(self) return self:M("GetZoneName")   or "" end,
  ["Info Server"         ] = function(self) return self:M("GetServerName") or "" end,
  ["Info User ID"        ] = function(self) return self.playerName         or "" end,

  ["Info Data Timestamp" ] = function(self) return self:M("GetTimestamp") end,

  ["Info Race Class"] =
    function(self)
      local class = self:M("GetRPClass");
      local race = self:M("GetRPRace");
      return (race and (race .. " ") or "") .. (class or "");
    end,

  ["Info Status"] = function(self) return self:M("GetRPStatusWord") end,

  ["Info Height Weight"] =
    function(self)
      local height = self:M("GetRPHeight");
      local weight = self:M("GetRPWeight");
      if height and weight
      then return height .. ", " .. weight
      elseif height then return height
      elseif weight then return weight
      else return ""
      end;
    end,

  ["Info Game Race Class"] = 
    function(self)
      local class = self:M("Get", "MSP-GC");
      local race = self:M("Get", "MSP-GR");
      return (race and (race .. " ") or "") .. (class or "");
    end,

  ["Info Subzone"] = 
    function(self, tooltip) 
      if   tooltip 
      then local zone, subzone = self:M("GetZoneName"), self:M("GetSubzoneName");
           if     zone ~= "" and subzone ~= ""
           then   return self:M("GetZoneName") .. " (" .. self:M("GetSubzoneName") .. ")"
           elseif zone ~= ""
           then   return zone
           end;
      else return self:M("GetSubzoneName") 
      end;
    end,

  ["Info Zone Subzone"] =
    function(self)
      local subzone = self:M("GetSubzoneName")
      if    subzone == ""
      then return self:M("GetZoneName")
      else return self:M("GetZoneName") .. " (" ..  subzone .. ")"
      end
    end,
    
};

RP_Find.playerRecordMethods =
{ 
  ["Initialize"] =
    function(self)
      self.cache           = {};
      self.cache.fields    = {};
      self.cache.last      = {};
      self.cache.last.when = time();
      return self;
    end,

  ["Set"] =
    function(self, field, value)
      self.cache.fields[field]       = self.cache.fields[field] or {};
      self.cache.fields[field].value = value;
      self.cache.fields[field].when  = time();
      self.cache.last.when           = time();
    end,

  ["SetTimestamp"] =
    function(self, field, timeStamp)
      timeStamp = timeStamp or time();

      if not field
      then   self.cache.last.when = timeStamp
      elseif self.cache.fields[field]
      then   self.cache.fields[field].when = timeStamp;
      elseif type(field) == "string"
      then   self:M("Set", field, nil, { when = timeStamp });
      end;

    end,

  ["Get"] =
    function(self, field)
      if          self.cache.fields[field] ~= nil
      then return self.cache.fields[field].value
      else return nil
      end;
    end,

  ["GetTRP3"] =
    function(self, field, mspField)
      if not RP_Find:HaveRPClient("totalRP3") then return end;
      local profile = TRP3_API.register.getUnitIDCurrentProfileSafe(self.playerName);

      if   profile ~= {}
      then 
           if field == "pronouns" and profile.charactistics and profile.characteristics.MI
           then for _, item in pairs(profile.characteristics.MI)
                do if item.NA:lower() == "pronouns" 
                   then profile = nil;
                        self:M("Set", "rp_pronouns", item.VA);
                        return item.VA end;
                end;
           end;

           local path = trp3FieldHash[field]
           if path
           then local a, b = unpack(path);
                local v = profile[a] and profile[a][b] or nil;
                if    v 
                then  profile = nil; 
                      return v 
                end;
           end;
      end;

      profile = nil;
      return nil;
    end,

  ["GetMSP"] = 
    function(self, field, mspField) 
      return getMSPFieldByPlayerName(self.playerName, mspField);
    end,

  ["GetRP"] = 
    function(self, field, mspField)
      local rp   = self:M("Get", "rp_" .. field);
      local trp3 = self:M("GetTRP3", field, mspField);
      local msp  = self:M("GetMSP", field, mspField);
      return rp or trp3 or msp 
    end,

  ["GetRPStatus"] =
    function(self)
      if     RP_Find:HaveRPClient("totalRP3")
      then   return 3 - tonumber(self:M("GetTRP3", "status") or 3)
      elseif RP_Find:HaveRPClient()
      then   return tonumber(self:M("GetMSP", "status", "FC"))
      else   return 0
      end;
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
      local server = self:M("GetServer");
      _, self.serverName = LibRealmInfo:GetRealmInfo(server);
      return self.serverName;
    end,

  ["GetRPName"] = 
    function(self) 
      local name = self:M("GetRP", "name", "NA")
      return (not name or name == "") and self:M("GetPlayerName", true) or name;
    end,
    
  ["GetRPNameStripped"] =
    function(self)
      local  name = self:M("GetRPName");
      local  stripped, color = stripColor(name);
      return stripped;
    end,

  ["GetRPNameColorFixed"] = function(self) return RP_Find:FixColor(self:M("GetRPName")); end,

  -- we probably aren't going to use all of these
  ["GetRPClass"      ] = function(self) return self:M("GetRP", "class",       "RC")   end,
  ["GetRPRace"       ] = function(self) return self:M("GetRP", "race",        "RA")   end,
  ["GetRPIcon"       ] = function(self) return self:M("GetRP", "icon",        "IC")   end,
  ["GetRPAge"        ] = function(self) return self:M("GetRP", "age",         "AG")   end,
  ["GetRPHeight"     ] = function(self) return self:M("GetRP", "height",      "AH")   end,
  ["GetRPWeight"     ] = function(self) return self:M("GetRP", "weight",      "AW")   end,
  ["GetRPInfo"       ] = function(self) return self:M("GetRP", "oocinfo",     "CO")   end,
  ["GetRPCurr"       ] = function(self) return self:M("GetRP", "currently",   "CU")   end,
  ["GetRPTitle"      ] = function(self) return self:M("GetRP", "title",       "NT")   end,
  ["GetRPPronouns"   ] = function(self) return self:M("GetRP", "pronouns",    "PN")   end,
  ["GetRPAddon"      ] = function(self) return self:M("GetRP", "addon",       "VA")   end,
  ["GetRPTrial"      ] = function(self) return self:M("GetRP", "trial",       "TR")   end,
  ["IsSetIC"         ] = function(self) return tonumber(self:M("GetRPStatus") or 0) == 2 end,
  ["IsSetOOC"        ] = function(self) return tonumber(self:M("GetRPStatus") or 0) == 1 end,
  ["IsSetLooking"    ] = function(self) return tonumber(self:M("GetRPStatus") or 0) == 3 end,
  ["IsSetStoryteller"] = function(self) return tonumber(self:M("GetRPStatus") or 0) == 4 end,
  ["IsTrial"         ] = function(self) return tonumber(self:M("GetRPTrial")  or 0) == 1 end,
  -- ["GetRPHonorific"  ] = function(self) return self:M("GetRP", "honorific",   "PX")   end,
  -- ["GetRPStatus"     ] = function(self) return self:M("GetRP", "status",      "FC")   end,
  -- ["GetRPEyeColor"   ] = function(self) return self:M("GetRP", "eyecolor",    "AE")   end,
  -- ["GetRPStyle"      ] = function(self) return self:M("GetRP", "style",       "FR")   end,
  -- ["GetRPBirthplace" ] = function(self) return self:M("GetRP", "birthplace",  "HB")   end,
  -- ["GetRPHome"       ] = function(self) return self:M("GetRP", "home",        "HH")   end,
  -- ["GetRPMotto"      ] = function(self) return self:M("GetRP", "motto",       "MO")   end,
  -- ["GetRPHouse"      ] = function(self) return self:M("GetRP", "house",       "NH")   end,
  -- ["GetRPNickname"   ] = function(self) return self:M("GetRP", "nick",        "NI")   end,

  ["IsLGBTFriendly"] =
    function(self)
      local pat = L["Pattern LGBT Friendly"];
      local curr = self:M("GetRPCurr");
      local oocinfo = self:M("GetRPInfo");
      return (curr and curr:lower():match(pat)
              or oocinfo and oocinfo:lower():match(pat))
    end,

  ["WelcomesWalkups"] = 
    function(self)
      local pat = "walk%-? ?ups?";
      local curr = self:M("GetRPCurr");
      local oocinfo = self:M("GetRPInfo");
      return (curr and curr:lower():match(pat)
              or oocinfo and oocinfo:lower():match(pat))
    end,

  ["SentMapScan"]  = function(self) return self:M("Get", "mapScan") ~= nil end,
  ["IsRPFindUser"] = function(self) return self:M("Get", "rpFindUser")     end,

  ["IsFriendOfPlayer"] =
    function(self) 
      local fullName = self:M("GetPlayerName");
      local name = self:M("GetPlayerName", true);
      if C_FriendList.GetFriendInfo(name) then return true end;
      if not BNConnected() then return false end;
      RP_Find.bnetFriendList = RP_Find.bnetFriendList or {};
      if   not RP_Find:LastSince("bnetFriendList", 2, SECONDS_PER_MIN) 
        -- time() - (RP_Find:Last("bnetFriendList") or 0) > 2 * SECONDS_PER_MIN
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

  ["GetRPStatusWord" ] = 
    function(self)
      local  status = self:M("GetRPStatus")
      local  statusNum = tonumber(status);

      if     statusNum == 1 then return "Out of Character"
      elseif statusNum == 2 then return "In Character"
      elseif statusNum == 3 then return "Looking for Contact"
      elseif statusNum == 4 then return "Storyteller"
      elseif statusNum == 0 then return ""
      elseif status == nil then return ""
      else   return status;
      end;
    end,

  ["GetIcon"] =
    function(self)
      local rpIcon = self:M("GetRPIcon");
      if rpIcon and rpIcon ~= "" then return "Interface\\ICONS\\" .. rpIcon, true end;

      local gameRace = self:M("GetRP", "gameRace", "GR");
      local gameSex  = self:M("GetRP", "gameSex",  "GS");

      if   not genderHash[gameSex] or gameRace == ""
      then return "Interface\\CHARACTERFRAME\\TempPortrait", false
      else return "Interface\\CHARACTERFRAME\\" .. "TemporaryPortrait-" 
             .. genderHash[gameSex] .. "-" .. gameRace, false;
      end;
    end,

  ["GetFlagString"] =
    function(self)
      local flags = {};
      for _, flag in ipairs(RP_Find.Finder.flagList)
      do  if self:M(flag.method) then table.insert(flags, flag.icon) end;
      end;

      return table.concat(flags)
    end,

  ["GetFlags"] = 
    function(self) 
      local flagString = self:M("Get", "flagString");
      if    flagString and time() - self:M("GetTimestamp", "flagString") < UPDATE_CYCLE_TIME
      then  return flagString 
      else  flagString = self:M("GetFlagString");
            self:M("Set", "flagString", flagString);
            return flagString;
      end;
    end,

  ["GetFlagsTooltip"] =
    function(self)
      local flags = {};
      for _, flag in ipairs(RP_Find.Finder.flagList)
      do if self:M(flag.method) then table.insert(flags, { flag.icon, flag.title}) end;
      end;

      return {}, flags;
    end,

  ["GetInfoColumnTitle"] = function(self) return L[RP_Find.db.profile.config.infoColumn] 
    end,

  ["GetInfoColumnTooltip"] = function(self) return { self:M("GetInfoColumn", true) } end,

  ["GetInfoColumn"] = 
    function(self, tooltip)
      local  func = infoColumnFunctionHash[RP_Find.db.profile.config.infoColumn];
      return func(self, tooltip);
    end,
            
  ["GetNameTooltip"] = 
    function(self)
      local lines   = {};
      local columns = {};
      local temp;

      local function addCol(method, label)
        local value = self:M(method);
        if    value and value ~= ""
        then  value = RP_Find:FixColor(value);
              table.insert(
                columns, 
                { label, 
                  value:len() < BIG_STRING_LIMIT and value or
                 (value:sub(1, BIG_STRING_LIMIT) .. "...") 
                }
              );
        end;
        value = nil;
      end;

      for _, item in ipairs(nameTooltipFields)
      do  if RP_Find.db.profile.config.nameTooltip[item.id]
          then addCol(item.method, item.label)
          end;
      end;

      if RP_Find.db.profile.config.nameTooltip.trial
      then temp = self:M("IsTrial");
           if temp then table.insert(columns, { "Trial Status", "Trial" });
           end;
      end;

      if RP_Find.db.profile.config.nameTooltip.currently
      then temp = self:M("GetRPCurr");
           if temp and temp ~= ""
           then table.insert(lines, " ");
                table.insert(lines, "Currently:");
                table.insert(lines, col.white(temp));
            end;
            currently = nil;
      end;

      if RP_Find.db.profile.config.nameTooltip.oocinfo
      then temp = self:M("GetRPInfo");
           if temp and temp ~= ""
           then table.insert(lines, " ");
                table.insert(lines, "OOC Info:");
                table.insert(lines, col.white(temp));
            end;
      end;

      local icon, iconFound = self:M("GetIcon");

      temp = nil;

      return lines, 
             columns, 
             iconFound 
               and RP_Find.db.profile.config.nameTooltip.icon
               and icon 
               or nil;
    end,
      
  ["GetSubzone"] =
    function(self, zoneID, x, y)

      if not zoneID or not x or not y then return nil end;
      if not pointsOfInterest[zoneID] then return nil end;

      for _, poi in ipairs(pointsOfInterest[zoneID])
      do  local dist = math.sqrt(
                         (poi.x - x) * (poi.x - x) +
                         (poi.y - y) * (poi.y - y))
          if dist < poi.r then return poi.title end;
      end;

      return nil;
    end,

  ["SetZone"] =
    function(self, zoneID, x, y)

      local zoneInfo = C_Map.GetMapInfo(zoneID);

      self:M("Set", "zone", 
            { id = zoneID,
              name = zoneInfo.name,
              x = x,
              y = y,
              subzone = self:M("GetSubzone", zoneID, x, y)
            });
                
    end,

  ["GetZoneID"     ] = function(self) local zone = self:M("Get", "zone"); return zone and zone.id      or nil end,
  ["GetZoneName"   ] = function(self) local zone = self:M("Get", "zone"); return zone and zone.name    or ""; end,
  ["GetSubzoneName"] = function(self) local zone = self:M("Get", "zone"); return zone and zone.subzone or ""; end,
      
  ["LabelViewProfile" ] =
    function(self)
      return L["Label Open Profile"], 
         not RP_Find:HaveRPClient("MyRolePlay") and 
         not RP_Find:HaveRPClient("totalRP3");
    end,

  ["CmdViewProfile"] =
    function(self)
      if     RP_Find:HaveRPClient("MyRolePlay")
      then   SlashCmdList["MYROLEPLAY"]("show " .. self.playerName);
             RP_Find.Finder:Hide();
      elseif RP_Find:HaveRPClient("totalRP3")
      then   SlashCmdList["TOTALRP3"]("open " .. self.playerName);
             RP_Find.Finder:Hide();
      else   RP_Find:Notify(string.format(L["Format Open Profile Failed"], self.playerName));
      end;
    end,

  ["LabelSendTell"] = 
    function(self) 
      return L["Label Whisper"], 
        self.playerName == RP_Find.me or
        RP_Find:LastSince("sendWhisper", 1, SECONDS_PER_MIN);
    end,

  ["CmdSendTell"] = 
    function(self, event, ...) 
      RP_Find:SendWhisper(self.playerName, "((  ))", 3) -- 3 = in the middle of the OOC braces
      RP_Find:Update("Display");
    end,

  ["HaveLFRPAd"] = function(self) local ad = self:M("Get", "ad"); return ad and ad ~= {}; end,

  ["GetLFRPAd"] = 
    function(self)
      local  ad = self:M("HaveLFRPAd")
      if not ad then return nil end;
      return { title = self:M("Get", "ad_title"),
               body = self:M("Get", "ad_body"),
               adult     = self:M("Get", "ad_adult"),
               timestamp = self:M("GetTimestamp", "ad") }
    end,             

  ["LabelReadAd"] = function(self) return L["Label Read Ad"], not self:M("HaveLFRPAd"); end,

  ["CmdReadAd"] = function(self) 
      if self:M("Get", "ad") then RP_Find.adFrame:SetPlayerRecord(self); RP_Find.adFrame:Show(); end;
    end,

  ["LabelInvite"] = function(self) 
    return L["Label Invite"], 
      self.playerName == RP_Find.me or 
      RP_Find:LastSince("sendInvite", 1, SECONDS_PER_MIN) end,

  ["CmdInvite"] =
    function(self)
      C_PartyInfo.InviteUnit(self.playerName)
      RP_Find:SetLast("sendInvite");
      RP_Find:Update("Display");
    end,

  ["HaveTRP3Data"] = 
    function(self) 
      return RP_Find:HaveRPClient("totalRP3") 
         and TRP3_API.register.getUnitIDCurrentProfileSafe(self.playerName).character
    end,

  ["HaveMSPData"]   = function(self) return getMSPFieldByPlayerName(self.playerName, "VA") end,
  ["HaveRPProfile"] = function(self) return self:M("HaveTRP3Data") or self:M("HaveMSPData")      end, 

  ["GetTimestamp"] =
    function(self, field)
      if     not field
      then   return self.cache.last.when or time()
      elseif self.cache.fields[field]
      then   return self.cache.fields[field].when or time()
      else   return time()
      end;
    end,

  ["GetHumanReadableTimestamp"] =
    function(self, field, format)
      local now              = time();
      local integerTimestamp = self:M("GetTimestamp", field);
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
      useSmartPruning    = true,
      smartPruningThreshold = 10,
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
  then self:SetPoint(
         "BOTTOMLEFT", 
         UIParent, 
         "BOTTOMLEFT",
         RP_Find.db.profile.finder.left,
         RP_Find.db.profile.finder.bottom
       )
  else self:SetPoint("CENTER", UIParent, "CENTER");
  end;

  local UIParent_Width = UIParent:GetWidth();
  local UIParent_Height = UIParent:GetHeight();
  if   RP_Find.db.profile.finder.width
  and  RP_Find.db.profile.finder.height
  then self:SetWidth(math.min(math.max(RP_Find.db.profile.finder.width, MIN_FINDER_WIDTH), UIParent_Width));
       self:SetHeight(math.min(math.max(RP_Find.db.profile.finder.height, MIN_FINDER_HEIGHT), UIParent_Height));
  else self:SetWidth(DEFAULT_FINDER_WIDTH);
       self:SetHeight(DEFAULT_FINDER_HEIGHT);
  end;

  self.frame:SetMinResize(MIN_FINDER_WIDTH, MIN_FINDER_HEIGHT);
  self.frame:SetMaxResize(UIParent_Width, UIParent_Height);

end;

Finder:SetLayout("Flow");

Finder:SetCallback("OnClose",
  function(self, event, ...)
    if RP_Find.playerList then RP_Find.playerList:SetData({}); end;
    local cancelTimers = { "playerList" };
    for _, t in ipairs(cancelTimers) do RP_Find:CancelTimer(t); end;
    
  end);

_G[finderFrameName] = Finder.frame;
table.insert(UISpecialFrames, finderFrameName);

function Finder:DisableUpdates(value) 
  if   self.updatesDisabled and not value
  then self.updatesDisabled = value;
       self:Update();
  else self.updatesDisabled = value; 
  end;
end;

local function dontBreakOnResize()
  Finder:DisableUpdates(true);
  Finder:PauseLayout();
  if RP_Find.playerList then RP_Find.playerList:Hide() end;
end;

local function restoreOnResize() 
  if   RP_Find and RP_Find.db
  then RP_Find.db.profile.finder.left,
       RP_Find.db.profile.finder.bottom,
       RP_Find.db.profile.finder.width,
       RP_Find.db.profile.finder.height =
         Finder.frame:GetRect();
  end;
  Finder:ResumeLayout();
  Finder:DisableUpdates(false);
  if   RP_Find.playerList
  then RP_Find:RecalculateColumnWidths(Finder.TabGroup);
       if Finder.currentTab == "Display"
       then RP_Find.playerList:Show()
       end;
  end;
end;

hooksecurefunc(Finder.frame, "StartSizing",        dontBreakOnResize);
hooksecurefunc(Finder.frame, "StopMovingOrSizing", restoreOnResize);

Finder.frame:SetClampedToScreen(true);

Finder.content:ClearAllPoints();
Finder.content:SetPoint("BOTTOMLEFT", Finder.frame, "BOTTOMLEFT", 20, 50);
Finder.content:SetPoint("TOPRIGHT",   Finder.frame, "TOPRIGHT", -20, -30);

Finder.TabList = 
{ { value = "Display", text = L["Tab Display"], },
  { value = "Ads",     text = L["Tab Ads"    ], },
  { value = "Tools",   text = L["Tab Tools"  ], },
};

function Finder:CreateButtonBar()
  local buttonSize = RP_Find.db.profile.config.buttonBarSize;

  local buttonBar = AceGUI:Create("SimpleGroup");
  buttonBar:SetLayout("Flow");
  buttonBar:SetFullWidth(true);
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
           local function haveAd(playerRecord) return playerRecord:M("HaveLFRPAd") end;
           local _, count = RP_Find:GetAllPlayerNames({ haveAd });
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
      func    = function(self, event, button) Finder:LoadTab("Ads"); end,
      enable  = function() return Finder.currentTab ~= "Ads" end,
    },

    { title   = L["Button Toolbar Preview Ad"],
      icon    = IC.previewAd,
      id      = "previewAd",
      tooltip = L["Button Toolbar Preview Ad Tooltip"],
      func    = function(self, event, button) 
                  if   RP_Find.adFrame:IsShown() 
                   and RP_Find.adFrame:M("GetPlayerName") == RP_Find.me
                  then RP_Find.adFrame:Hide()
                  else Finder:LoadTab("Ads"); 
                       RP_Find.adFrame.ShowPreview();
                  end;
                end,
       enable = function() return true end,
    },

    { title   = L["Button Toolbar Send Ad"],
      icon    = IC.sendAd,
      id      = "sendAd",
      tooltip = L["Button Toolbar Send Ad Tooltip"],
      func    = function(self, event, button) RP_Find:SendLFRPAd(true); end, -- true = interactive
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
      enable = function() 
                 return not RP_Find:ShouldSendAdBeDisabled();
               end,
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
      enable = function() return RP_Find:HaveTimer("autoSend") and RP_Find.db.profile.ad.autoSend end,
    },

    { title   = L["Button Toolbar Tools"],
      icon    = IC.tools,
      id      = "tools",
      tooltip = L["Button Toolbar Tools Tooltip"],
      func    = function(self, event, button) Finder:LoadTab("Tools"); end,
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
                    and not RP_Find:LastSince("mapScan", 1, SECONDS_PER_MIN)
                    -- and time() - (RP_Find:Last("mapScan") or 0) > SECONDS_PER_MIN
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
                    and RP_Find:LastSince("mapScan", 1, SECONDS_PER_HOUR)
                    -- and time() - (RP_Find:Last("mapScan") or 0) < SECONDS_PER_HOUR
                end,
    },

  };

  self.buttons = {}

  for i, info in ipairs(buttonInfo)
  do  local button = AceGUI:Create("Icon");
      button:SetImage(info.icon);
      button:SetImageSize(buttonSize, buttonSize);
      button:SetWidth(buttonSize + 1);
      button:SetCallback("OnEnter",
        function(self, event)
          showTooltip(self.frame, 
            { title = info.title,
              lines = { "", info.tooltip },
              anchor = "ANCHOR_TOP",
            });
        end);
      button.info = info;
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

  local fontFile, _, _ = GameFontNormal:GetFont();

  local sendAdCountdownContainer = AceGUI:Create("SimpleGroup");
  sendAdCountdownContainer:ClearAllPoints();
  sendAdCountdownContainer.frame:SetParent(self.buttons.sendAd.frame);
  sendAdCountdownContainer:SetPoint("CENTER", self.buttons.sendAd.frame, "CENTER");
  sendAdCountdownContainer:SetLayout("Flow");
  sendAdCountdownContainer:SetWidth(buttonSize);
  
  local sendAdCountdown = AceGUI:Create("InteractiveLabel");
  sendAdCountdown:SetFullWidth(true);
  sendAdCountdown:SetDisabled(true);
  sendAdCountdown:SetJustifyH("CENTER");
  sendAdCountdown:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, 
        { title = "Send Ad Timer", 
          lines = { "This timer shows how long until you can send your next ad." } });
    end);
  sendAdCountdown:SetCallback("OnLeave", hideTooltip);
  sendAdCountdown:SetFont(fontFile, buttonSize / 3);
  sendAdCountdownContainer:AddChild(sendAdCountdown);

  self.sendAdCountdownContainer = sendAdCountdownContainer;
  self.sendAdCountdown = sendAdCountdown;
end;

function RP_Find:StartSendAdCountdown()
  self:SaveTimer(
         "sendAdCountdown", 
         self:ScheduleRepeatingTimer("UpdateSendAdCountdown", 0.5)
       );
end;

function RP_Find:UpdateSendAdCountdown()
  local remaining = SECONDS_PER_MIN - (time() - (RP_Find:Last("sendAd")));
  if   remaining <= 0 or self:HaveTimer("autoSend")
  then self.Finder.sendAdCountdown:SetText();
       self.Finder.sendAdCountdown:SetDisabled(true);
       self:ClearTimer("sendAdCountdown");
       self.Finder:UpdateButtonBar();
  else self.Finder.sendAdCountdown:SetText(string.format("0:%02d", remaining));
       self.Finder.sendAdCountdown:SetDisabled(false);
  end;
end;

function Finder:UpdateButtonBar()
  for id, button in pairs(self.buttons)
  do button:SetDisabled(not button.info.enable());
  end;
end;

function Finder:ResizeButtonBar(value)
  value = value or RP_Find.db.profile.config.buttonBarSize;
  self:PauseLayout();
  self.sendAdCountdownContainer:PauseLayout();
  for id, btn in pairs(Finder.buttons)
  do btn:SetWidth(value)
     btn:SetHeight(value)
     btn:SetImageSize(value, value)
  end;
  self.sendAdCountdownContainer:SetWidth(value);
  local fontFile = GameFontNormal:GetFont();
  self.sendAdCountdown:SetFont(fontFile, value / 3);
  self.sendAdCountdownContainer:ResumeLayout();
  elf.sendAdCountdownContainer:DoLayout();
  self:ResumeLayout()
  self:DoLayout();
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
      if   self.window then AceGUI:Release(self.window); self.window = nil; return; end;

      local currentProfile = RP_Find.db:GetCurrentProfile();
      local window = AceGUI:Create("SimpleGroup");
      self.window = window;
      window:SetWidth(225);
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

      local profileList = RP_Find.db:GetProfiles();
      for _, profileName in ipairs(profileList)
      do  
          local button = AceGUI:Create("InteractiveLabel")

          if   profileName == currentProfile 
          then button:SetText(textIC.check .. profileName);
          else button:SetText(textIC.blank .. profileName);
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
      local label = AceGUI:Create("Label")
      label:SetText(" ");
      inline:AddChild(label);

      local close = AceGUI:Create("InteractiveLabel");
      close:SetText("Close");
      close:SetColor(0, 1, 0);
      close:SetFontObject(GameFontNormal);
      close:SetJustifyH("RIGHT");
      close:SetCallback("OnClick",
        function(self, event, button)
          window.frame:Hide();
          profileButton.window = nil;
          AceGUI:Release(window);
        end)
      close:SetCallback("OnEnter",
        function(self, event, ...)
          showTooltip(self, { title = "Close", 
            lines = { "Close this window without changing the active profile." } } );
        end);
      close:SetCallback("OnLeave", hideTooltip);

      inline:AddChild(close);

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
  tabGroup:SetTabs(self.TabList);

  function tabGroup:LoadTab(tab)
    tab = tab or Finder.currentTab;
    RP_Find:ClearTimer("playerList");
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

    if     RP_Find.playerList and tab == "Display"
    then   RP_Find.playerList:Show()
    elseif RP_Find.playerList
    then   RP_Find.playerList:Hide();
    end;
    if self:IsShown() then Finder:Update() end;
  end;

  tabGroup:SetCallback("OnGroupSelected", function(self, event, group) self:LoadTab(group); end);

  function self:LoadTab(...) 
    _ = RP_Find.playerList and RP_Find.playerList:Hide();
    tabGroup:LoadTab(...) 
  end; 

  self:AddChild(tabGroup);
  self.TabGroup = tabGroup;

end;

Finder.MakeFunc = {};

Finder.flagList = 
{
  { title = L["Flag Your Friend"],        icon = textIC.isFriend,      method = "IsFriendOfPlayer", },
  { title = L["Flag Have RP Profile"],    icon = textIC.rpProfile,     method = "HaveRPProfile",    },
  { title = L["Flag Is Set IC"],          icon = textIC.isIC,          method = "IsSetIC",          },
  { title = L["Flag Is Set OOC"],         icon = textIC.isOOC,         method = "IsSetOOC"          },
  { title = L["Flag Is Set Looking"],     icon = textIC.isLooking,     method = "IsSetLooking"      },
  { title = L["Flag Is Set Storyteller"], icon = textIC.isStoryteller, method = "IsSetStoryteller"  },
  { title = L["Flag Is Trial"],           icon = textIC.trial,         method = "IsTrial"           },
  { title = L["Flag Have Ad"],            icon = textIC.hasAd,         method = "HaveLFRPAd"        },
  { title = L["Flag Map Scan"],           icon = textIC.mapScan,       method = "SentMapScan"       },
  { title = L["Flag LGBT Friendly"],      icon = textIC.lgbt,          method = "IsLGBTFriendly",   },
  { title = L["Flag Walkups"],            icon = textIC.walkups,       method = "WelcomesWalkups",  },
  { title = L["Flag rpFind User"],        icon = textIC.rpFind,        method = "IsRPFindUser",     },
};

Finder.filterList =
{ 
  ["OnThisServer"] =
    { title   = L["Filter On This Server"],
      enabled = false,
      func    = function(playerRecord) return playerRecord:M("GetServer") == RP_Find.realm end,
    },

  ["IsSetIC"] =
    { 
      title   = L["Filter Is Set IC"],
      enabled = false,
      func    = function(playerRecord)
                  return playerRecord:M("GetRPStatus") == 2 or
                         playerRecord:M("GetRPStatus") == "2"
                end,
    },

  ["InfoColumnNotEmpty"] =
    { func =
        function(playerRecord)
          local info = playerRecord:M("GetInfoColumn")
          return info and info ~= "^%s&$"
        end,
      title = L["Filter Info Not Empty"],
      enabled = false,
    },

  ["MatchesLastMapScan"] =
    { func =
        function(playerRecord)
          local  zoneID = playerRecord:M("GetZoneID")
          return zoneID and RP_Find:Last("mapScanZone")
             and RP_Find:LastSince("mapScan", 1, SECONDS_PER_HOUR)
             -- time() - (RP_Find:Last("mapScan") or 0) < SECONDS_PER_HOUR
             and zoneID == RP_Find:Last("mapScanZone")
        end,
      title  = L["Filter Match Map Scan"],
      enabled = false,
    },

  ["ContactInLastHour"] =
    { func =
        function(playerRecord)
          return time() - playerRecord:M("GetTimestamp") < SECONDS_PER_HOUR
        end,
      title = L["Filter Active Last Hour"],
      enabled = false,
    },

  ["SentMapScan"] =
    { func =
        function(playerRecord)
          return playerRecord:M("SentMapScan");
        end,
      title = L["Filter Sent Map Scan"],
      enabled = false,
    },

  ["HaveAd"] =
    { func = function(playerRecord) return playerRecord:M("HaveLFRPAd") end,
      title = L["Filter Have LFRP Ad"],
      enabled = false,
    },

  ["HaveRPProfile"] =
    { func = function(playerRecord) return playerRecord:M("HaveRPProfile") end,
      title = L["Filter RP Profile Loaded"],
      enabled = false,
    },

  ["UsesRpFind"] =
    { func = function(playerRecord) return playerRecord:M("IsRPFindUser") end,
      title = RP_Find.addOnTitle .. " User",
      enabled = false,
    },

  ["FlagsColumnNotEmpty"] =
    { func = function(playerRecord)
               local flags = playerRecord:M("GetFlags");
               return flags and flags ~= ""
             end,
      title = "Flags Column Not Empty",
      enabled = false,
    },

  ["ClearAllFilters"] = 
    { func = function(playerRecord) return true end,
      title = L["Filter Clear All Filters"],
      enabled = false,
    },
};

local function sortFilters(a, b) return Finder.filterList[a].title < Finder.filterList[b].title end;

Finder.filterListOrder = { 
  "ContactInLastHour",  "SentMapScan", 
  "InfoColumnNotEmpty", "IsSetIC",
  "MatchesLastMapScan", "OnThisServer", 
  "HaveRPProfile",      "HaveAd", 
  "UsesRpFind",         "FlagsColumnNotEmpty",
};

table.sort(Finder.filterListOrder, sortFilters);
table.insert(Finder.filterListOrder, "ClearAllFilters");
 
local displayColumns = 
{ {   title       = "",
      method      = "GetPlayerName",
      id          = "unitid",
      sorting     = "GetRPNameStripped",
      initialSort = false,
      width       = 0.0001, -- has to be non-zero or the entire table won't display
    },
    
    { title       = L["Display Header Name"],
      method      = "GetRPNameColorFixed",
      sorting     = "GetRPNameStripped",
      ttMethod    = "GetNameTooltip",
      ttTitleMethod = "GetRPNameColorFixed",
      width       = 0.25,
      initialSort = true,
      id          = "name",
    },
    { title       = L["Display Header Info"],
      titleFunc   = function() return menu.infoColumn[RP_Find.db.profile.config.infoColumn]; end,
      method      = "GetInfoColumn",
      ttMethod    = "GetInfoColumnTooltip",
      ttTitleMethod = "GetInfoColumnTitle",
      width       = 0.22,
      id          = "info",
    },
    { title       = L["Display Header Flags"],
      method      = "GetFlags",
      ttMethod    = "GetFlagsTooltip",
      ttTitle     = L["Display Header Flags"],
      width       = 0.19,
      id          = "flags",
    },
    { title       = L["Display Header Tools"],
      ttTitle     = L["Display Column Title Profile"],
      method      = "LabelViewProfile",
      callback    = "CmdViewProfile",
      tooltip     = L["Display View Profile Tooltip"],
      disableSort = true,
      width       = 0.08,
      id          = "profile",
    },
    { ttTitle     = L["Display Column Title Whisper"],
      title       = "",
      method      = "LabelSendTell",
      callback    = "CmdSendTell",
      disableSort = true,
      tooltip     = L["Display Send Tell Tooltip"],
      width       = 0.09,
      id          = "whisper",
    },
    { ttTitle     = L["Display Column Title Ad"],
      title       = "",
      method      = "LabelReadAd",
      callback    = "CmdReadAd",
      tooltip     = L["Display Read Ad Tooltip"],
      disableSort = true,
      width       = 0.09,
      id          = "ad",
    },
    { ttTitle     = L["Display Column Title Invite"],
      title       = "",
      method      = "LabelInvite",
      callback    = "CmdInvite",
      tooltip     = L["Display Send Invite Tooltip"],
      disableSort = true,
      width       = 0.08,
      id          = "invite",
    },
  }; -- here

RP_Find.DisplayColumns = displayColumns;
    

  function RP_Find:MakePlayerList(parentFrame)
    parentFrame = parentFrame.frame or parentFrame;
    if   self.playerList 
    then self.playerList.frame:SetParent(parentFrame);
         return 
    end;

    self.stColumns = {};
    local baseWidth = 600;

    local function sortPlayerRecords(self, rowA, rowB, sortbycol)

      local valA, valB;
      local column = self.cols[sortbycol];
      local info   = displayColumns[sortbycol];

      if   info.sorting and RP_Find.playerRecordMethods[info.sorting]
      then func = RP_Find.playerRecordMethods[info.sorting]
      else func = RP_Find.playerRecordMethods[info.method];
      end;

      local useridA = self:GetCell(rowA, 1).value;
      local useridB = self:GetCell(rowB, 1).value;
      local recordA = RP_Find:GetPlayerRecord(useridA);
      local recordB = RP_Find:GetPlayerRecord(useridB);
      valA = func(recordA) or "";
      valB = func(recordB) or "";

      local result = valA:lower():gsub("[^%a ]+","") < valB:lower():gsub("[^%a ]+","")

      local direction = column.sort or column.defaultsort or LibScrollingTable.SORT_DSC;
      if    direction == LibScrollingTable.SORT_ASC
      then  return     result
      else  return not result
      end;
    end;

    for i, info in ipairs(displayColumns)
    do local column  =
       { name        = info.titleFunc and info.titleFunc() or info.title,
         width       = info.width * baseWidth,
         align       = "LEFT",
         color       = { r = 1, g = 1, b = 1, a = 0 },
         bgcolor     = { r = 0, g = 0, b = 0, a = 0 },
         defaultsort = "dsc",
         comparesort = info.sorting and sortPlayerRecords or LibScrollingTable.CompareSort,
       };
     table.insert(self.stColumns, column);
  end;

  self.playerList = LibScrollingTable:CreateST(
      self.stColumns, 
      10,  -- initial columns
      nil, -- column height
      { r = 0, g = 0, b = 0, a = 0 }, 
      parentFrame
  );

  self.playerList.frame:SetFrameLevel(100);

  local cellMethods =
  { ["OnEnter"] =
      function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
        if not realrow or not column then return end;
        local unitid = data[realrow].cols[1].value;
        local info = displayColumns[column];
        local  playerRecord = RP_Find:GetPlayerRecord(unitid);
        if     info.tooltip
        then   local tooltip = 
               { anchor = "ANCHOR_BOTTOM", 
                 lines = { info.tooltip },
                 title = info.ttTitleMethod 
                         and playerRecord:M(info.ttTitleMethod)
                          or info.ttTitle
                          or info.title,
               }
               showTooltip(cellFrame, tooltip);
               tooltip = nil;
        elseif info.ttMethod and RP_Find.playerRecordMethods[info.ttMethod]
        then   local tooltip = 
               { title = info.ttTitleMethod 
                         and playerRecord:M(info.ttTitleMethod)
                          or info.ttTitle,
                 anchor = "ANCHOR_BOTTOM",
               };
               tooltip.lines, tooltip.columns, tooltip.icon = playerRecord:M(info.ttMethod);
               showTooltip(cellFrame, tooltip);
               tooltip = nil;
        end;
      end,
    ["OnLeave"] = hideTooltip,
    ["OnClick"] =
      function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button, ...)
        if not realrow or not column then return end;
        local unitid = data[realrow].cols[1].value;
        local info = displayColumns[column];
        local playerRecord = RP_Find:GetPlayerRecord(unitid);
        if   info.callback and RP_Find.playerRecordMethods[info.callback]
        then playerRecord:M(info.callback);
        end;
      end,
  };

  self.playerList.frame:SetBackdropColor(      0,   0,   0,   0);
  self.playerList.frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

  self.playerList.cols[2].sort = LibScrollingTable.SORT_ASC;
  self.playerList:RegisterEvents(cellMethods);

end;

function RP_Find:RecalculateColumnWidths(parentFrame, rowsPerPage)
  local  baseWidth;
  if     type(parentFrame) == "number" 
  then   baseWidth = parentFrame
  elseif type(parentFrame) == "table" and parentFrame.frame
  then   baseWidth = parentFrame.frame:GetWidth()
         baseHeight = parentFrame.frame:GetHeight();
  elseif type(parentFrame) == "table"
  then   baseWidth = parentFrame:GetWidth()
         baseHeight = parentFrame:GetHeight();
  end;

  baseWidth = baseWidth - 55;
  if   not rowsPerPage and baseHeight
  then rowsPerPage = math.floor((baseHeight - 120) / 15)
       self.playerList:SetDisplayRows(math.max(1, rowsPerPage), 15);
  end;

  for i, col in ipairs(displayColumns)
  do  self.stColumns[i].width = col.width * baseWidth;
  end;

  self.playerList:SetDisplayCols(self.stColumns);
end;

function Finder.MakeFunc.Display(self)

  local searchPattern = "";
  local activeFilters = {};

  local panelFrame = AceGUI:Create("SimpleGroup");
        panelFrame:SetFullWidth(true);
        panelFrame:SetLayout("Flow");
  
  local function applyCurrentFilters(self, row)
    if not RP_Find.playerList or not row then return end;

    local function nameMatch(playerRecord, pattern)
      pattern = pattern:lower();
      return playerRecord:M("GetRPNameStripped"):lower():match(pattern)
          or playerRecord:M("GetPlayerName"):lower():match(pattern)
    end;

    local unitid = row.cols[1].value;
    if not unitid then return end;
    local record = RP_Find:GetPlayerRecord(unitid);

    local pass;

    local success, funcReturnValue = pcall(nameMatch, record, searchPattern);
    if success then pass = funcReturnValue else pass = true end;

    for filterID, func in pairs(activeFilters)
    do local result = func(record)
       pass = pass and result;
    end 

    return pass;
  end;

  local searchBarReset = AceGUI:Create("InteractiveLabel");
  local searchBar = AceGUI:Create("EditBox");
        searchBar:SetRelativeWidth(0.38)
        searchBar.editbox:SetTextColor(0.5, 0.5, 0.5);
        searchBar:DisableButton(true);

        searchBar:SetCallback("OnTextChanged",
          function(self, event, text)
            searchPattern = text;
            Finder.searchPattern = searchPattern;
            -- applyCurrentFilters()
            Finder:Update("Display"); 
            searchBarReset:SetDisabled(text == "");
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

        searchBarReset:SetRelativeWidth(0.10);
        searchBarReset:SetText("  " .. RESET);
        searchBarReset:SetCallback("OnClick",
          function(self, event, button)
            searchPattern = "";
            searchBar:SetText("");
            Finder.searchPattern = "";
            Finder:Update();
          end);
  searchBarReset:SetDisabled(true);

  panelFrame:AddChild(searchBarReset);
  local space1 = AceGUI:Create("Label"); 
  space1:SetRelativeWidth(0.01); 
  panelFrame:AddChild(space1);

  local filterSelectorReset = AceGUI:Create("InteractiveLabel");
  local filterSelector = AceGUI:Create("Dropdown");
        filterSelector:SetMultiselect(true);
        filterSelector:SetRelativeWidth(0.38);
  
  for _, filterID in ipairs(self.filterListOrder)
  do  local filterData = self.filterList[filterID];
      filterSelector:AddItem(filterID, filterData.title);
  end;

  Finder.SetActiveFilters = Finder.SetActiveFilters or
  function()
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
    filterSelectorReset:SetDisabled(count == 0);
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
      Finder:SetActiveFilters();
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

  filterSelectorReset:SetText("  " .. RESET)
  filterSelectorReset:SetRelativeWidth(0.1);
  filterSelectorReset:SetCallback("OnClick",
    function(self, event, button)
      for filterID, filterData in pairs(Finder.filterList)
      do filterData.enabled = false;
      end;
      RP_Find:Notify(L["Notify Filters Cleared"]);
      Finder:SetActiveFilters();
      Finder:Update("Display");
    end
  );

  panelFrame:AddChild(filterSelector);
  panelFrame:AddChild(filterSelectorReset);


  local function PlayerList_UpdatePlayerList(playerList)
    RP_Find:MakePlayerList(Finder);
    RP_Find:RecalculateColumnWidths(Finder.TabGroup)

    RP_Find.playerList.frame:ClearAllPoints();
    RP_Find.playerList.frame:SetPoint("TOPLEFT",     searchBar.frame, "BOTTOMLEFT", 0, -30 );

    Finder.totalCount = 0;

    local playerRecordsList = RP_Find:GetAllPlayerRecords();

    local data = {}
    for playerName, playerRecord in pairs(playerRecordsList)
    do  
        Finder.totalCount = Finder.totalCount + 1;
        local columns = {};
        for _, col in ipairs(displayColumns)
        do  local cell = {};
            local valueFunc      = RP_Find.playerRecordMethods[col.method];
            local text, disabled = valueFunc(playerRecord);
            cell.value = text or "";
            if disabled then cell.color = { r = 0.5, g = 0.5, b = 0.5, a = 1 }
                        else cell.color = { r = 1,   g = 1,   b = 1,   a = 1 }
            end;
            table.insert(columns, cell);
        end;
        local row = {
          cols = columns,
          color = { r = 0, g = 0, b = 0, a = 1 },
        };
        table.insert(data, row);
    end;

    RP_Find.playerList:SetData(data);
    RP_Find.playerList:SetFilter(applyCurrentFilters);

    if not RP_Find:HaveTimer("playerList")
    then   RP_Find:SaveTimer("playerList", RP_Find:ScheduleRepeatingTimer("Update", UPDATE_CYCLE_TIME)); 
    end;

    playerRecordsList = nil;

  end;

  function panelFrame:Update(...) 
    Finder.SetActiveFilters();
    PlayerList_UpdatePlayerList(playerList, ...);
    self:DoLayout();
    Finder:UpdateTitle();
  end;

  return panelFrame;
end;

Finder.TitleFunc = {};
Finder.UpdateFunc= {};

function Finder.TitleFunc.Display(self, ...)
  self:SetTitle(string.format(L["Format Finder Title Display"], self.totalCount or 0));
end;

function Finder.TitleFunc.Ads(self,      ...) self:SetTitle(RP_Find.addOnTitle .. "- Your Ad"); end;
function Finder.TitleFunc.Tools(self,    ...) self:SetTitle(L["Format Finder Title Tools"]);    end;
function Finder.UpdateFunc.Display(self, ...) self.TabGroup.current:Update(...);                end;
function Finder.UpdateFunc.Tools(self,   ...) self.TabGroup.current:Update(...);                end;
function Finder.UpdateFunc.Ads(self,     ...) self.TabGroup.current:Update(...);                end;

function Finder:UpdateTitle(event, ...)
  if    not self:IsShown() or self.updatesDisabled then return end;
  local title = self.TitleFunc[self.currentTab]
  if    title then title(self) end;
end;

function Finder:UpdateContent(...)
  if not self:IsShown() or self.updatesDisabled then return end;
  self.UpdateFunc[self.currentTab](self, ...);
end;

function Finder:Update(tab, ...)
  if not self:IsShown() or self.updatesDisabled then return end;
  if not tab or self.currentTab == tab
  then self:UpdateContent(...);
       self:UpdateTitle(...);
  end;
end;

function RP_Find:IsAdIncomplete()
  return not (self.db.profile.ad.title ~= "")
     and not (self.db.profile.ad.body ~= "");
end;

function RP_Find:ShouldSendAdBeDisabled()
  -- local elapsedTime = time() - (self:Last("sendAd") or 0);
  return self:LastSince("sendAd", 1, SECONDS_PER_MIN)
      -- elapsedTime < 1 * SECONDS_PER_MIN 
      or (self:HaveTimer("autoSend") and self.db.profile.ad.autoSend)
      or self:IsAdIncomplete()
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

  local function updatePreviewIfShown()
    if RP_Find.adFrame:IsShown() and RP_Find.adFrame:GetPlayerName() == RP_Find.me
    then RP_Find.adFrame:UpdatePreview() 
    end;
  end;

  local function enableOrDisableButtons(dontUpdateButtonBar)
    local autoSendActive = RP_Find:HaveTimer("autoSend") and RP_Find.db.profile.ad.autoSend;
    local disableSend = RP_Find:ShouldSendAdBeDisabled();
    local incomplete = RP_Find:IsAdIncomplete();
    
    _ = autoSendStopButton and autoSendStopButton:SetDisabled(not autoSendActive);
    _ = autoSendStartButton and autoSendStartButton:SetDisabled(disableSend);
    _ = sendAdButton and sendAdButton:SetDisabled(disableSend);
    _ = bodyField and bodyField:SetDisabled(autoSendActive);
    _ = titleField and titleField:SetDisabled(autoSendActive);
    _ = adultToggle and adultToggle:SetDisabled(autoSendActive);
    _ = clearAdButton:SetDisabled(
          autoSendActive
          or (RP_Find.db.profile.ad.title == ""
              and RP_Find.db.profile.ad.body == "")

        );

    if not dontUpdateButtonBar then RP_Find.Finder:UpdateButtonBar(); end;

  end;

  local function adultContentCheck()
    local adult = RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.text)
                  or RP_Find:ScanForAdultContent(RP_Find.db.profile.ad.body);
    if   adult 
    then RP_Find.db.profile.ad.adult = true; adultToggle:SetValue(true); 
         updatePreviewIfShown();
    end;
  end;

  local function loadCurrentProfileAd()
    if   RP_Find.db:GetCurrentProfile() ~= currentProfile
    then adultToggle:SetValue(RP_Find.db.profile.ad.adult);
         titleField:SetText(RP_Find.db.profile.ad.title);
         bodyField:SetText(RP_Find.db.profile.ad.body);

         adultContentCheck();
         enableOrDisableButtons();
         currentProfile = RP_Find.db:GetCurrentProfile();
         updatePreviewIfShown();
    end;
  end;

  clearAdButton:SetText(L["Button Clear Ad"]);
  clearAdButton:SetRelativeWidth(0.19);
  clearAdButton:SetCallback("OnClick",
    function(Self, event, ...)
      titleField:ResetValue();
      bodyField:ResetValue();
      adultToggle:ResetValue();
      enableOrDisableButtons();
      updatePreviewIfShown();
      RP_Find:Notify(L["Notify Ad Cleared"]);
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
  previewAdButton:SetCallback("OnClick", RP_Find.adFrame.ShowPreview);

  previewAdButton:SetCallback("OnEnter",
    function(self, event, ...)
      showTooltip(self, { title = L["Button Preview Ad"], lines = { "Preview your ad." } });
    end);

  previewAdButton:SetCallback("OnLeave", hideTooltip);
    
  sendAdButton:SetText(L["Button Send Ad"]);
  sendAdButton:SetRelativeWidth(0.19);
  sendAdButton:SetCallback("OnClick", 
    function(self, event, ...) 
      RP_Find:SendLFRPAd(true) 
      enableOrDisableButtons();
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

  autoSendStartButton:SetText(L["Button Toolbar Autosend Start"]);
  autoSendStartButton:SetRelativeWidth(0.19);
  autoSendStartButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find.db.profile.ad.autoSend = true;
      RP_Find:StartOrStopAutoSend(true);
      enableOrDisableButtons();
    end);
  autoSendStartButton:SetCallback("OnEnter",
    function(self, event, button)
      showTooltip(self, { title = L["Button Toolbar Autosend Start"], lines = { L["Button Toolbar Autosend Start Tooltip"] } })
    end);
  autoSendStartButton:SetCallback("OnLeave", hideTooltip)

  autoSendStopButton:SetText("Stop Autosend");
  autoSendStopButton:SetRelativeWidth(0.19);
  autoSendStopButton:SetCallback("OnClick",
    function(self, event, button)
      RP_Find.db.profile.ad.autoSend = false;
      RP_Find:StartOrStopAutoSend(true);
      enableOrDisableButtons();
    end);

  autoSendStopButton:SetCallback("OnEnter",
    function(self, event, button)
      showTooltip(self, 
        { title = "Cancel Autosend", 
          lines = { L["Button Toolbar Autosend Stop Tooltip"] } 
        }
      );
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
      adultContentCheck();
      enableOrDisableButtons();
      updatePreviewIfShown();
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
      updatePreviewIfShown();
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
      adultContentCheck();
      enableOrDisableButtons();
      updatePreviewIfShown();
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

  function panelFrame:Update()
    loadCurrentProfileAd();
    enableOrDisableButtons(true);
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

function RP_Find:SendAdTimerFinish()
  RP_Find:ClearTimer("sendAd");
  RP_Find.Finder:UpdateButtonBar();
  RP_Find.Finder:Update("Ads");
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

  local zoneID   = C_Map.GetBestMapForUnit("player")
  local zoneInfo = C_Map.GetMapInfo(zoneID);
 
  if not menu.zone[zoneID] then menu.zone[zoneID] = zoneInfo.name; end;

  Finder.scanZone = zoneID;

  local trp3MapScanZone          = AceGUI:Create("Dropdown");
  local trp3MapScanButton        = AceGUI:Create("Button");
  local trp3MapScanResultsButton = AceGUI:Create("Button");
  local spacer                   = AceGUI:Create("Label");
  local spacer2                  = AceGUI:Create("Label");

  local function updateTrp3MapScan()
    if   not RP_Find:LastSince("mapScan", 1, SECONDS_PER_MIN)
         -- time() - (RP_Find:Last("mapScan") or 0) >= 60
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
         and RP_Find:LastSince("mapScan", 5, SECONDS_PER_MIN)
         -- time() - (RP_Find:Last("mapScan") or 0) < 5 * SECONDS_PER_MIN
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

  function panelFrame:Update() updateTrp3MapScan(); end;

  return panelFrame;
end;

Finder:Hide();
RP_Find.Finder = Finder;

function RP_Find:LoadSelfRecord() 
  self.my = self:GetPlayerRecord(self.me, self.realm); 
  self.my:M("Set", "rpFindUser", true);
  return self.my;
end;

local function optionsSpacer(width)
  return { type  = "description", name  = " ", width = width or 0.1, order = source_order() }
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
      openFinder           = 
      { type = "execute",
        name = L["Open Finder Window"],
        order = source_order(),
        width = 1,
        desc = L["Open Finder Window Tooltip"],
        func = function() InterfaceOptionsFrame:Hide() RP_Find:ShowFinder(); end,
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
            disabled       = function() return not self:HaveRPClient() 
                                            or not self.db.profile.config.monitorTRP3 
                             end,
          },
          seeAdultAds =
          { name           = L["Config See Adult Ads"],
            type           = "toggle",
            order          = source_order(),
            desc           = L["Config See Adult Ads Tooltip"],
            get            = function() return self.db.profile.config.seeAdultAds end,
            set            = function(info, value) 
                               self.db.profile.config.seeAdultAds = value 
                               if self.adFrame:IsShown()
                               then self.adFrame:SetPlayerRecord(
                                      self:GetPlayerRecord( self.adFrame:M("GetPlayerName") ));
                               end;
                             end,
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
            set = function(info, value) 
                    self.db.profile.config.lightenColors = value
                    self.Finder:Update("Display");
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
                    self:Update("Display");
                  end,
            sorting = menu.infoColumnOrder,
            width = 1,
            values = menu.infoColumn,
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
                disabled = function() return not self:HaveRPClient(); end,
              },

              status = 
              { name = "Status",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's IC/OOC status in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.status end,
                set = function(info, value) self.db.profile.config.nameTooltip.status = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              class = 
              { name = "Class",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's class in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.class end,
                set = function(info, value) self.db.profile.config.nameTooltip.class = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              race = 
              { name = "Race",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's race in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.race end,
                set = function(info, value) self.db.profile.config.nameTooltip.race = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              pronouns = 
              { name = "Pronouns",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's pronouns in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.pronouns end,
                set = function(info, value) self.db.profile.config.nameTooltip.pronouns = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              title = 
              { name = "Title",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's title in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.title end,
                set = function(info, value) self.db.profile.config.nameTooltip.title = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              age = 
              { name = "Age",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's age in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.age end,
                set = function(info, value) self.db.profile.config.nameTooltip.age = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              zone = 
              { name = "Zone",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's current zone in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.zone end,
                set = function(info, value) self.db.profile.config.nameTooltip.zone = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              height = 
              { name = "Height",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's height in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.height end,
                set = function(info, value) self.db.profile.config.nameTooltip.height = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },
              weight = 
              { name = "Weight",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's weight in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.weight end,
                set = function(info, value) self.db.profile.config.nameTooltip.weight = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              trial = 
              { name = "Trial",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's trial status in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.trial end,
                set = function(info, value) self.db.profile.config.nameTooltip.trial = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              addon = 
              { name = "Addon",
                type = "toggle",
                width = 0.5,
                order = source_order(),
                desc = "Display the character's RP addon in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.addon end,
                set = function(info, value) self.db.profile.config.nameTooltip.addon = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              currently =
              { name = "Currently",
                type = "toggle",
                width = 1,
                order = source_order(),
                desc = "Display the character's currently in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.currently end,
                set = function(info, value) self.db.profile.config.nameTooltip.currently = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

              oocinfo =
              { name = "OOC Info",
                type = "toggle",
                width = 1,
                order = source_order(),
                desc = "Display the character's OOC info in the tooltip.",
                get = function() return self.db.profile.config.nameTooltip.oocinfo end,
                set = function(info, value) self.db.profile.config.nameTooltip.oocinfo = value end,
                disabled = function() return not self:HaveRPClient(); end,
              },

            },
          },
          buttonBarSize    =
          { name           = L["Config Button Bar Size"],
            type           = "range",
            order          = source_order(),
            desc           = L["Config Button Bar Size Tooltip"],
            width          = "full",
            min            = MIN_BUTTON_BAR_SIZE,
            max            = MAX_BUTTON_BAR_SIZE,
            step           = 2,
            get            = function() return self.db.profile.config.buttonBarSize end,
            set            = function(info, value) 
                               self.db.profile.config.buttonBarSize = value 
                               Finder:ResizeButtonBar(value)
                             end,
          },
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
          testNotify  =
          { name      = L["Button Test Notify"],
            type      = "execute",
            order     = source_order(),
            desc      = L["Button Test Notify Tooltip"],
            func      = function() self:Notify(L["Notify Test"]); end,
            width     = 1,
            disabled  = function() return self.db.profile.config.notifyMethod == "none" end,
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
          },        },
      },
      databaseConfig =
      { name  = function() 
                  local  currentUsage =  GetAddOnMemoryUsage(self.addOnName);
                  if   currentUsage >= MEMORY_WARN_MB * 1000
                  then return L["Config Database Warning MB"]
                  else return L["Config Database"]
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
                width         = "full",
                order         = source_order(),
                desc          = L["Config Use Smart Pruning Tooltip"],
                get           = function() return self.db.profile.config.useSmartPruning end,
                set           = function(info, value) 
                                  self.db.profile.config.useSmartPruning  = value 
                                  self:StartOrStopPruningTimer();
                                end,
              },
              pruningThreshold =
              { name                = L["Config Smart Pruning Threshold"],
                type                = "range",
                dialogControl       = "Log_Slider",
                isPercent           = true,
                width               = "full",
                min                 = 0,
                softMin             = math.log(SECONDS_PER_HOUR / 4);
                softMax             = math.log(1  * SECONDS_PER_DAY);
                max                 = math.log(30 * SECONDS_PER_DAY);
                step                = 0.001,
                order               = source_order(),
                get                 = function() return self.db.profile.config.smartPruningThreshold end,
                set                 = function(info, value) self.db.profile.config.smartPruningThreshold = value end,
                disabled            = function() return not self.db.profile.config.useSmartPruning end,
              },
            },
          },
          smartPruneNow =
          { name        = L["Button Smart Prune Database"],
            type        = "execute",
            width       = 1,
            order       = source_order(),
            desc        = L["Button Smart Prune Database Tooltip"],
            func        = function() self:SmartPruneDatabase(true) end, -- true = interactive
            disabled    = function() return not self.db.profile.config.useSmartPruning end,
          },
          deleteDBnow =
          { name      = L["Button Delete DB Now"],
            type      = "execute",
            width     = 1,
            order     = source_order(),
            desc      = L["Button Delete DB Now Tooltip"],
            func      = function() StaticPopup_Show(popup.deleteDBNow) end,
          },
        },
      },
      help =
      { type       = "group",
        name       = L["Help and Credits Header"],
        order       = source_order(),
        -- childGroups = "tab",
        args =
        { 
          intro =
          { type = "description",
            name = L["Help Intro"],
            order = source_order(),
            dialogControl = "LMD30_Description",
            fontSize = "small",
          },
          finder =
          { type = "group",
            name = L["Help Finder Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Finder"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          display =
          { type = "group",
            name = L["Help Display Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Display"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          ads =
          { type = "group",
            name = L["Help Ads Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Ads"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          tools =
          { type = "group",
            name = L["Help Tools Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Tools"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          options =
          { type = "group",
            name = L["Help Options Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Options"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          etiquette =
          { type = "group",
            name = L["Help Etiquette Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Etiquette"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
          credits =
          { type = "group",
            name = L["Help Credits Header"],
            order = source_order(),
            args = 
            { markdown =
              { type = "description",
                name = L["Help Credits"],
                order = source_order(),
                dialogControl = "LMD30_Description",
                fontSize = "small",
              },
            },
          },
        },
      },
      profiles = AceDBOptions:GetOptionsTable(self.db),
    },
  };
  
  self.addOnMinimapButton = LibDBIcon:Register(
                              self.addOnTitle, 
                              self.addOnDataBroker, 
                              self.db.profile.minimapbutton
  );

  AceConfigRegistry:RegisterOptionsTable(self.addOnName, self.options,   false);
  AceConfigDialog:AddToBlizOptions(      self.addOnName, self.addOnTitle      );

  self.options = nil;

  initializeDatabase();

end;

-- Ad Display
--
local adFrame = CreateFrame("Frame", "RP_Find_AdDisplayFrame", UIParent, "PortraitFrameTemplate");

adFrame:SetMovable(true);
adFrame:EnableMouse(true);
adFrame:RegisterForDrag("LeftButton");
adFrame:SetScript("OnDragStart", adFrame.StartMoving);
adFrame:SetScript("OnDragStop",  adFrame.StopMovingOrSizing);
adFrame:SetClampedToScreen(true);

adFrame:SetPoint("RIGHT", Finder.frame, "LEFT", 0, 0);
table.insert(UISpecialFrames, "RP_Find_AdDisplayFrame");
adFrame:Hide();

RP_Find.adFrame = adFrame;

adFrame.backdrop = RP_Find_AdDisplayFrameBg;

adFrame.pictureOverlay = CreateFrame("Frame", nil, adFrame);
adFrame.pictureOverlay:SetPoint("TOPLEFT", adFrame, "TOPLEFT", -4, 8);
adFrame.pictureOverlay:SetPoint("BOTTOMRIGHT", adFrame, "TOPLEFT", 54, -52);

adFrame.pictureOverlay:SetScript("OnEnter",
  function(self)
    local playerRecord = RP_Find:GetPlayerRecord(adFrame(GetPlayerName));
    local _, columns = playerRecord:M("GetFlagsTooltip"); 
    showTooltip(self, 
      { title   = playerRecord:M("GetFlags"),
        columns = columns
      });
  end);
adFrame.pictureOverlay:SetScript("OnLeave", hideTooltip);
        
adFrame.titleOverlay = CreateFrame("Frame", nil, adFrame);
adFrame.titleOverlay:SetPoint("TOPLEFT", adFrame, "TOPLEFT", 60, 0);
adFrame.titleOverlay:SetPoint("BOTTOMRIGHT", adFrame, "TOPRIGHT", -20, -20);
adFrame.titleOverlay:EnableMouse(true);
adFrame.titleOverlay:SetScript("OnMouseDown", function() adFrame:StartMoving() end);
adFrame.titleOverlay:SetScript("OnMouseUp", function() adFrame:StopMovingOrSizing() end);

adFrame.titleOverlay:SetScript("OnEnter",
  function(self)
    local playerRecord = RP_Find:GetPlayerRecord(adFrame:GetPlayerName());
    local lines, columns, _ = playerRecord:M("GetNameTooltip"); -- don't need to show the icon
    showTooltip(self, 
      { title   = playerRecord:M("GetRPNameColorFixed"),
        columns = columns, 
        lines   = lines, }
    );
  end);
adFrame.titleOverlay:SetScript("OnLeave", hideTooltip);

adFrame.subtitle = CreateFrame("Frame", nil, adFrame)
adFrame.subtitle:SetPoint("TOPLEFT", adFrame, "TOPLEFT", 65, -32);
adFrame.subtitle:SetWidth(265);
adFrame.subtitle:SetHeight(30);
adFrame.subtitle:SetScript("OnEnter", 
    function(self) 
      showTooltip(self, { title = "Ad Title", lines = { self.text:GetText() } }) 
    end);
adFrame.subtitle:SetScript("OnLeave", hideTooltip);

adFrame.subtitle.text = adFrame.subtitle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
adFrame.subtitle.text:SetWordWrap(false);
adFrame.subtitle.text:SetJustifyV("TOP");
adFrame.subtitle.text:SetJustifyH("CENTER");
adFrame.subtitle.text:SetAllPoints();
adFrame.subtitle.text:SetTextColor(1, 1, 1, 1);

adFrame.body = CreateFrame("Frame", nil, adFrame);
adFrame.body.text = adFrame.body:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
adFrame.body.text:SetWordWrap(true);
adFrame.body.text:SetJustifyV("TOP");
adFrame.body.text:SetJustifyH("LEFT");
adFrame.body.text:SetAllPoints();
adFrame.body.text:SetTextColor(1, 1, 1, 1);
adFrame.body:SetScript("OnEnter",
  function(self)
    showTooltip(self, { anchor = "ANCHOR_CURSOR", anchorPreserve = true, 
                        title = "Ad Body", lines = { self.text:GetText() } })
  end);
adFrame.body:SetScript("OnLeave", hideTooltip);

function adFrame:Reset()
  self.fieldMaxY  = 300;
  self.fieldX     = 15;
  self.fieldY     = 70;
  self.fieldWidth = 75;
  self.valueWidth = 220;
  self.vPadding   = 5;
  self.hPadding   = 10;
  self.fieldNum   = 0;
  self.fieldPool  = self.fieldPool or {};
  self.valuePool  = self.valuePool or {};
  self.isAdult    = false;
  for _, field in ipairs(self.fieldPool) do field:Hide(); end;
  for _, value in ipairs(self.valuePool) do value:Hide(); end;
  self.backdrop:SetVertexColor(0, 0, 0, 2/3);
end;

function adFrame:GetPlayerName() return self.playerName; end;

function adFrame:SetSubtitle(text, default) 
  if   default and (text == "" or not text)
  then self.subtitle.text:SetSubtitle(default); 
  else self.subtitle.text:SetText(text);
  end;
end;

function adFrame.UpdatePreview()
  local myRecord = RP_Find:LoadSelfRecord();

  local race = myRecord:M("GetRPRace");
  if race == "" then race, _, _ = UnitRace("player"); myRecord:M("Set", "MSP-RA", race); end;

  local class = myRecord:M("GetRPClass");
  if class == "" then class, _, _ = UnitClass("player"); myRecord:M("Set", "MSP-RC", class); end;

  myRecord:M("Set", "ad_title", RP_Find.db.profile.ad.title);
  myRecord:M("Set", "ad_body",  RP_Find.db.profile.ad.body);
  myRecord:M("Set", "ad_adult", RP_Find.db.profile.ad.adult);
  RP_Find.adFrame:SetPlayerRecord(myRecord);
  RP_Find.adFrame:Show();
end;

function adFrame.ShowPreview()
  if RP_Find.adFrame:IsShown() and RP_Find.adFrame:GetPlayerName() == RP_Find.me
  then RP_Find.adFrame:Hide();
  else adFrame:UpdatePreview()
  end;
end;

function adFrame:CreatePanels()
  local field = CreateFrame("Frame", nil, self);
  field:SetHeight(20);
  field:SetWidth(self.fieldWidth);
  field.text = field:CreateFontString(nil, "OVERLAY", "GameFontNormal");
  field.text:SetTextColor(1, 1, 1, 1);
  field.text:SetJustifyH("LEFT");
  field.text:SetJustifyV("TOP");
  field.text:SetAllPoints();

  function field:SetText(text) 
    self.text:SetText(text); 
    self:SetHeight(self.text:GetHeight()); 
  end;
  function field:GetText() return self.text:GetText(); end;

  local value = CreateFrame("Frame", nil, self);
  value.text = value:CreateFontString(nil, "OVERLAY", "GameFontNormal");
  value:SetHeight(20);
  value:SetWidth(self.valueWidth);
  value.text = value:CreateFontString(nil, "OVERLAY", "GameFontNormal");
  value.text:SetJustifyH("LEFT");
  value.text:SetJustifyV("TOP");
  value.text:SetAllPoints();
  function value:SetText(text) 
    self.text:SetText(text); 
    self:SetHeight(self.text:GetHeight()); 
  end;
  function value:GetText() return self.text:GetText(); end;
  
  field.value = value;
  field.field = field;
  value.value = value;
  value.field = field;

  local function tooltip(self)
    showTooltip(self.field, { anchor = "ANCHOR_BOTTOMRIGHT", title = self.field:GetText(), lines = { self.value:GetText() } });
  end;

  field:SetScript("OnEnter", tooltip);
  field:SetScript("OnLeave", hideTooltip);
  value:SetScript("OnEnter", tooltip);
  value:SetScript("OnLeave", hideTooltip);

  return field, value;
end;

function adFrame:AddField(field, value, default)
  if    self.fieldY > 300 then return end;
  local fieldPanel, valuePanel;
  self.fieldNum = self.fieldNum + 1;

  if   self.fieldNum > #self.fieldPool
  then fieldPanel, valuePanel = self:CreatePanels();
       table.insert(self.fieldPool, fieldPanel);
       table.insert(self.valuePool, valuePanel);
  else fieldPanel = self.fieldPool[self.fieldNum];
       valuePanel = self.valuePool[self.fieldNum];
  end;

  fieldPanel:Show();
  valuePanel:Show();

  fieldPanel:ClearAllPoints();
  valuePanel:ClearAllPoints();

  fieldPanel:SetPoint("TOPLEFT", self.fieldX, 0 - self.fieldY);
  fieldPanel:SetWidth(self.fieldWidth);
  valuePanel:SetPoint("TOPLEFT", self.fieldX + self.fieldWidth + self.hPadding, 0 - self.fieldY);
  valuePanel:SetWidth(self.valueWidth);

  fieldPanel:SetText(field);

  if   default and (value == "" or not value)
  then valuePanel:SetText(default)
  else valuePanel:SetText(value);
  end;

  self.fieldY = self.fieldY 
              + math.max(fieldPanel:GetHeight(), valuePanel:GetHeight())
              + self.vPadding;

end;

function adFrame:SetBodyText(text, default) 
  self.body:ClearAllPoints();
  self.body:SetPoint("TOPLEFT", self.fieldX, 0 - self.fieldY)
  self.body:SetPoint("BOTTOMRIGHT", -20, 16)
  if   default and (text == "" or not text)
  then self.body.text:SetText(default)
  else self.body.text:SetText(text) 
  end;
end;

function adFrame:SetPlayerRecord(playerRecord)
  self:Reset();

  self.playerName = playerRecord:M("GetPlayerName");

  self:SetPortraitToAsset(playerRecord:M("GetIcon"));
  self:SetTitle(RP_Find:FixColor(playerRecord:M("GetRPName")));

  local class = playerRecord:M("GetRPClass");
  if class then class = RP_Find:FixColor(class); end;

  self:AddField(L["Field Race"    ], playerRecord:M("GetRPRace"),     L["Field Blank"]);
  self:AddField(L["Field Class"   ], class,                        L["Field Blank"]);
  self:AddField(L["Field Pronouns"], playerRecord:M("GetRPPronouns"), L["Field Blank"]);
  if self.playerName ~= RP_Find.me
  then self:AddField(L["Field Timestamp"], playerRecord:M("GetHumanReadableTimestamp", "ad"), L["Field Blank"]);
  end;

  if   playerRecord:M("Get", "ad_adult") 
  then self.backdrop:SetVertexColor(1, 0, 0, 2/3);
       self.isAdult = true;
       if   RP_Find.db.profile.config.seeAdultAds
            or self.playerName == RP_Find.me 
       then self:SetBodyText(playerRecord:M("Get", "ad_body"), L["Field Body Blank" ]);
            self:SetSubtitle(playerRecord:M("Get", "ad_title"), L["Field Title Blank"]);
       else self:SetBodyText(L["Field Body Adult Hidden"]);
            self:SetSubtitle(L["Field Title Adult Hidden"]);
       end;
  else self.isAdult = false;
       self:SetBodyText(playerRecord:M("Get", "ad_body"), L["Field Body Blank" ]);
       self:SetSubtitle(playerRecord:M("Get", "ad_title"), L["Field Title Blank"]);
  end;
end;

function RP_Find:StartOrStopAutoSend(interactive)
  if     self.db.profile.ad.autoSend and self:HaveTimer("autoSend")
  then   -- all is running as it should be
  elseif self.db.profile.ad.autoSend
  then   self:SendLFRPAd(false);
         if   interactive then self:Notify(L["Notify Auto Send Start"]); end;
         self:SaveTimer("autoSend", self:ScheduleRepeatingTimer("SendLFRPAd", SECONDS_PER_HOUR));
         self.Finder:UpdateButtonBar();
         self.Finder:Update("Ads");
  elseif self:HaveTimer("autoSend")
  then   self:ClearTimer("autoSend")
         self.db.profile.ad.autoSend = false;
         self:StartSendAdCountdown();
         self.Finder:UpdateButtonBar();
         self.Finder:Update("Ads");
         if interactive then self:Notify(L["Notify Auto Send Stop"]); end;
  else -- all is as it should be
  end;
end;

-- data broker
--

function RP_Find:ShowOrHideMinimapButton()
  if   self.db.profile.minimapbutton.hide
  then LibDBIcon:Hide(self.addOnTitle);
  else LibDBIcon:Show(self.addOnTitle);
  end;
end;

function RP_Find:ShowFinder() self.Finder:Show(); self.Finder:Update(); end;
function RP_Find:HideFinder() self.Finder:Hide(); end;

function RP_Find:SendVersionCheck()
  local channelNum = GetChannelName(addonChannel);
  RP_Find:SendSmartAddonMessage(
      chompPrefix.rpfind,
      chompPrefix.rpfind .. ":HELO|||version=" .. RP_Find.addOnVersion .. "|||")
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
  self:InitAddonChannel();

  self:SendVersionCheck();

  if   self.db.profile.config.loginMessage 
  then self:Notify(L["Notify Login Message"]); 
  end;

  self:ShowOrHideMinimapButton();
  self.Finder:SetDimensions();
  self.Finder:CreateButtonBar();
  self.Finder:CreateTabGroup();
  self.Finder:CreateProfileButton();
  self.Finder:UpdateButtonBar();
  -- self.colorBar:Update();
  self.Finder:LoadTab("Display");
  self:StartOrStopAutoSend();
  self:StartSendAdCountdown();

end;

if RP_Find:HaveRPClient("totalRP3")
then TRP3_API.module.registerModule(
    { ["name"       ] = RP_Find.addOnTitle,
      ["description"] = RP_Find.addOnDesc,
      ["version"    ] = RP_Find.addOnVersion,
      ["id"         ] = RP_Find.addOnName,
      ["autoEnable" ] = true,
    });
end;

function RP_Find:RegisterTRP3Received()
  if not RP_Find:HaveRPClient("totalRP3") then return end;

  TRP3_API.Events.registerCallback(
    TRP3_API.events.REGISTER_DATA_UPDATED,
    function(unitID, profile, dataType)
      if unitID
      then local playerRecord = RP_Find:GetPlayerRecord(unitID);
           if not playerRecord:M("Get", "flagString")
           then playerRecord:M("Set", "flagString", playerRecord:M("GetFlagString"));
           end;
      end;
    end
  );

end;

function RP_Find:RegisterMspReceived()
  if not _G["msp"] then return end;

  table.insert(_G["msp"].callback.received, 
    function(playerName) 
      if   RP_Find.db.profile.config.monitorMSP 
      then local playerRecord = self:GetPlayerRecord(playerName);
           if   RP_Find.db.profile.config.autoSendPing
           and  not playerRecord:M("HaveRPProfile")
           then RP_Find:SendPing(playerName)
           end;

           RP_Find.Finder:Update("Display");
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
  
function RP_Find:SendSmartAddonMessage(prefix, data)
  local channelNum = GetChannelName(addonChannel);
  AddOn_Chomp.SmartAddonMessage(prefix, data, "CHANNEL", channelNum, { serialize = true });
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
          and not playerRecord:M("HaveRPProfile")
         then RP_Find:SendPing(sender)
         end;
         
         RP_Find.Finder:Update("Display");

         if   RP_Find.db.profile.config.alertTRP3Connect
         then RP_Find:Notify(string.format(L["Format Alert TRP3 Connect"], sender));
         end;
  elseif text:find("^RPB1~C_SCAN~")
  then   local playerRecord = RP_Find:GetPlayerRecord(sender, nil);
         local zoneID = tonumber(text:match("~(%d+)$"));

         playerRecord:M("Set", "mapScan", zoneID);

         if   RP_Find.db.profile.config.autoSendPing
          and not playerRecord:M("HaveRPProfile")
         then RP_Find:SendPing(sender)
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
          and not playerRecord:M("HaveRPProfile")
         then RP_Find:SendPing(sender)
         end;
         
         if RP_Find:LastSince("mapScan", 1, SECONDS_PER_MIN)
         -- time() - (RP_Find:Last("mapScan") or 0) < 60
         then playerRecord:M("SetZone", RP_Find:Last("mapScanZone"), x * 100, y * 100)
         end;
  end;
end;

function RP_Find.AddonMessageReceived.rpfind(prefix, text, channelType, sender, channelname, ...)
  if   text:match(chompPrefix.rpfind .. ":AD")
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
       playerRecord:M("Set", "rpFindUser", true);
       if count > 0
       then 
            playerRecord:M("Set", "ad", true)
            for field, value in pairs(ad)
            do if field:match("^rp_") or field:match("^MSP-")
               then playerRecord:M("Set", field, value)
               else playerRecord:M("Set", "ad_" .. field, value)
               end;
            end;

            if   RP_Find.db.profile.config.notifyLFRP and
                 (not ad.adult or RP_Find.db.profile.config.seeAdultAds)
            then RP_Find:Notify((ad.name or sender) .. " sent an ad" ..
                   (ad.title and (": " .. ad.title) or "") .. ".");
            end;
            RP_Find.Finder:Update("Display");
       end;
  elseif text:match(chompPrefix.rpfind .. ":HELO") 
         and RP_Find.db.profile.config.versionCheck 
         and not RP_Find.versionCheck
  then   local receivedVersion = text:match(":HELO|||version=(.-)|||")

         local playerRecord = RP_Find:GetPlayerRecord(sender);
         playerRecord:M("Set", "rpFindUser", true);

         if   calcVersion(receivedVersion) > calcVersion(RP_Find.addOnVersion)
         then RP_Find:Notify(string.format(L["Format New Version Available"], receivedVersion))
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

local chatMsgAddonEventRegistered = false;
local chatMsgAddonHandlers = {};

function RP_Find:RegisterAddonPrefix(prefix, callback)
  local success = C_ChatInfo.RegisterAddonMessagePrefix(prefix);
  if   success 
  then 
       if not chatMsgAddonEventRegistered
       then self:RegisterEvent("CHAT_MSG_ADDON", "AddonMessageReceivedNoChomp")
       end;
       
       chatMsgAddonHandlers[prefix] = callback;
       chatMsgAddonEventRegistered = true;
  end;
end;

function RP_Find:AddonMessageReceivedNoChomp(event, prefix, ...)
  if chatMsgAddonHandlers[prefix] then chatMsgAddonHandlers[prefix](prefix, ...) end;
end;

function RP_Find:InitAddonChannel()
  for addon, prefix in pairs(chompPrefix)
  do  AddOn_Chomp.RegisterAddonPrefix(prefix, self.AddonMessageReceived[addon]);
  end;

  for addon, prefix in pairs(addonPrefix)
  do  self:RegisterAddonPrefix(prefix, self.AddonMessageReceived[addon]);
  end;

  local  haveJoinedAddonChannel, channelCount = haveJoinedChannel(addonChannel);
  if not haveJoinedAddonChannel and channelCount < 10
  then   JoinTemporaryChannel(addonChannel);
  end;

  self:ScheduleTimer("MoveAddonChannelToEndOfList", 5);
  -- self:MoveAddonChannelToEndOfList();

end;

function RP_Find:SendTRP3Scan(zoneNum)
  if   self:LastSince("mapScan", 1, SECONDS_PER_MIN)
    -- time() - (self:Last("mapScan") or 0) < 60
  then self:Notify(string.format(L["Format TRP3 Scan Failed"], 60));
  else zoneNum = zoneNum or C_Map.GetBestMapForUnit("player");
       local message = addonPrefix.trp3 .. "~C_SCAN~" .. zoneNum;
       self:SendAddonMessage(addonPrefix.trp3, message);
       self:SetLast("mapScan");
       self:SetLast("mapScanZone", zoneNum);
       self.Finder:UpdateButtonBar();
       self.Finder:Update("Tools");
       self:Notify(L["Notify TRP3 Scan Sent"]);
  end;
end;

function RP_Find:ComposeAd()

  local text = chompPrefix.rpfind .. ":AD";
  local function add(f, v) 
    text = text .. "|||" 
           .. (f or "") 
           .. "=" 
           .. (v or ""); 
    end;

  -- if  self:HaveRPClient("totalRP3") then self.my:SetHaveTRP3Data(true); end;

  add("rp_name", self.my:M("GetRPName"))

  local race = self.my:M("GetRPRace");
  if race == "" then race, _, _ = UnitRace("player"); end;
  add("rp_race", race);

  local class = self.my:M("GetRPClass");
  if class == "" then class, _, _ = UnitClass("player") end;
  add("rp_class", class);

  add("rp_title",    self.my:M("GetRPTitle"));
  add("rp_pronouns", self.my:M("GetRPPronouns"));
  add("rp_age",      self.my:M("GetRPAge"));
  add("rp_addon",    self.my:M("GetRPAddon"));

  local trial = self.my:M("GetRPTrial");
  if trial == "" then trial = IsTrialAccount() and "1" or "0" end;

  add("rp_trial", trial);

  add("title", self.db.profile.ad.title);
  add("body",  self.db.profile.ad.body);
  add("adult", self.db.profile.ad.adult and "1" or "");

  return text;
end;

function RP_Find:SendLFRPAd(interactive)
  local message = self:ComposeAd();
  if   self:LastSince("sendAd", 1, SECONDS_PER_MIN)
       -- time() - (self:Last("sendAd") or 0) < 60
  then if   interactive 
       then self:Notify(string.format(L["Format Send Ad Failed"], 60)); 
       end;
  else self:SendSmartAddonMessage(chompPrefix.rpfind, message);
       self:SetLast("sendAd");
       if   interactive 
       then self:Notify(L["Notify Send Ad"]); 
            self:StartSendAdCountdown();
       end;
       RP_Find.Finder:UpdateButtonBar();
       RP_Find.Finder:Update("Ads");
       if   not self:HaveTimer("sendAd")
       then self:SaveTimer("sendAd", RP_Find:ScheduleTimer("SendAdTimerFinish", SECONDS_PER_MIN));
       end;
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
RP_Find.closeButton:SetScript("OnClick", function(self, button) Finder:Hide(); end);

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

--[[
  local function makeColorBar()
  local frameWidth = 240;
  local height = 16;
  local colorBar = CreateFrame("Frame", nil, Finder.frame);

  local checkbox = CreateFrame("CheckButton", nil, Finder.frame, "ChatConfigCheckButtonTemplate");

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

RP_Find.colorBar = makeColorBar();
--]]

-- slash commands
--
for i, slash in ipairs(split(SLASH, "|")) do _G["SLASH_RP_FIND" .. i] = slash; end;

function RP_Find:OpenOptions()
  InterfaceOptionsFrame:Show();
  InterfaceOptionsFrame_OpenToCategory(self.addOnTitle);
end;

function RP_Find:HelpCommand()
  self:Notify(true, L["Slash Commands"]);
  self:Notify(true, L["Slash Toggle"  ]);
  self:Notify(true, L["Slash Show"    ]);
  self:Notify(true, L["Slash Hide"    ]);
  self:Notify(true, L["Slash Display" ]);
  self:Notify(true, L["Slash Ads"     ]);
  self:Notify(true, L["Slash Tools"   ]);
  self:Notify(true, L["Slash Send Ad" ]);
  self:Notify(true, L["Slash Map Scan"]);
  self:Notify(true, L["Slash Options" ]);
end;

SlashCmdList["RP_FIND"] = 
  function(a)
    local  param = { strsplit(" ", a); };
    local  cmd = table.remove(param, 1);

    if     cmd == ""              or cmd:match("^help")   then RP_Find:HelpCommand();
    elseif cmd:match("^option")   or cmd:match("^config") then RP_Find:OpenOptions();
    elseif cmd:match("^toggle")                           then if RP_Find.Finder:IsShown() then RP_Find:HideFinder() else RP_Find:ShowFinder() end;
    elseif cmd:match("^open")     or cmd:match("^show")   then RP_Find:ShowFinder();
    elseif cmd:match("^close")    or cmd:match("^hide")   then RP_Find:HideFinder();
    elseif cmd:match("^database") or cmd:match("^db")     then Finder:LoadTab("Display"); RP_Find:ShowFinder();
    elseif cmd:match("^ad")                               then Finder:LoadTab("Ads"); RP_Find:ShowFinder();
    elseif cmd:match("^tool")                             then Finder:LoadTab("Tools"); RP_Find:ShowFinder();
    elseif cmd:match("^map")      or cmd:match("^scan")   then RP_Find:SendTRP3Scan();
    elseif cmd:match("^send")                             then RP_Find:SendLFRPAd();
                                                          else RP_Find:HelpCommand();
    end;
  end;

_G["BINDING_HEADER_RP_FIND"        ] = L["Binding Group rpFind"  ];
_G["BINDING_NAME_RP_FIND_SHOW"     ] = L["Binding Show Finder"   ];
_G["BINDING_NAME_RP_FIND_HIDE"     ] = L["Binding Hide Finder"   ];
_G["BINDING_NAME_RP_FIND_TOGGLE"   ] = L["Binding Toggle Finder" ];
_G["BINDING_NAME_RP_FIND_SEND_AD"  ] = L["Binding Send Ad"       ];
_G["BINDING_NAME_RP_FIND_DISPLAY"  ] = L["Binding Display"       ];
_G["BINDING_NAME_RP_FIND_ADS"      ] = L["Binding Ads"           ];
_G["BINDING_NAME_RP_FIND_TOOLS"    ] = L["Binding Tools"         ];
_G["BINDING_NAME_RP_FIND_MAP_SCAN" ] = L["Binding Send Map Scan" ];



_G[addOnName] = RP_Find;

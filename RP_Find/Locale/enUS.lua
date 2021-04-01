local addOnName, ns = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addOnName, "enUS", true);

local addOnTitle = GetAddOnMetadata(addOnName, "Title");
local addOnVersion = GetAddOnMetadata(addOnName, "Version");
local addOnDate = GetAddOnMetadata(addOnName, "X-VersionDate");
  
local SLASH                = "|cff00ffff/rpfind|r ";

L["Config Show Icon Tooltip"             ] = "Show or hide the minimap icon.";
L["Config Show Icon"                     ] = "Show Icon";
L["Credits Header"                       ] = "Credits";
L["Slash Commands"                       ] = "Slash Commands";
L["Slash Options"                        ] = SLASH .. "|cffffff00options|r - Open the options panel";
L["Version Info"                         ] = "You're running " .. addOnTitle .. " version " .. addOnVersion .. " (" .. addOnDate .. ").";

-- long entries ------------------------------------------------------------------------
--
L["Credits Info" ] =
[===[
The coding was done by |cffff33ffOraibi-MoonGuard|r. 

]===];

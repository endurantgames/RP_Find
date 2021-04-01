local addOnName, ns = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addOnName, "enUS", true);

local addOnTitle = GetAddOnMetadata(addOnName, "Title");
local addOnVersion = GetAddOnMetadata(addOnName, "Version");
local addOnDate = GetAddOnMetadata(addOnName, "X-VersionDate");
  
local SLASH                = "|cff00ffff/rpfind|r ";

L["Config Options"                       ] = "Configuration Options";
L["Config Show Icon Tooltip"             ] = "Show or hide the minimap icon.";
L["Config Show Icon"                     ] = "Show Icon";
L["Config Finder Tooltips"               ] = "Show Finder Tooltips";
L["Config Finder Tooltips Tooltip"       ] = "Show tooltips in the Finder screen.";
L["Config Monitor MSP"                   ] = "Monitor MSP";
L["Config Monitor MSP Tooltip"           ] = "Look for changes to the MSP (Mary Sue Protocol) database; i.e. when you receive a new profile in an RP addon.";
L["Config Monitor TRP3"                  ] = "Monitor Total RP 3";
L["Config Monitor TRP3 Tooltip"          ] = "Look for messages sent by Total RP 3. |cff00ff00Note:|r You don't need to have Total RP 3 installed to turn this on.";
L["Config Alert TRP3 Scan"               ] = "Alert Local TRP3 Scans";
L["Config Alert TRP3 Scan Tooltip"       ] = "Check this to be notified when someone in your zone does a TRP3 map scan.";
L["Config Alert All TRP3 Scan"           ] = "Alert All TRP3 Scans";
L["Config Alert All TRP3 Scan Tooltip"   ] = "Check this to be notified when someone in any zone does a TRP3 map scan.";
L["Format Alert TRP3 Scan"               ] = "%s scanned for players in %s.";
L["Label Finder Tooltips"                ] = "Tooltips";
L["Button Config"                        ] = "Options";
L["Button Close"                         ] = "Close";
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

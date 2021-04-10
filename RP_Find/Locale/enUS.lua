local addOnName, ns  = ...;
local L              = LibStub("AceLocale-3.0"):NewLocale(addOnName, "enUS", true);
local addOnTitle     = GetAddOnMetadata(addOnName, "Title");
local addOnVersion   = GetAddOnMetadata(addOnName, "Version");
local addOnDate      = GetAddOnMetadata(addOnName, "X-VersionDate");
local addOnColor     = addOnTitle:match(".+|c(ff%x%x%x%x%x%x)");
local addOnColorName = addOnName:upper() .. "_FONT_COLOR";
_G[addOnColorName]   = CreateColorFromHexString(addOnColor);
_G.ORAIBI_FONT_COLOR = CreateColorFromHexString("FFBB00BB");

local col = {};
function col.red(str)    return        RED_FONT_COLOR:WrapTextInColorCode(str) end;
function col.green(str)  return      GREEN_FONT_COLOR:WrapTextInColorCode(str) end;
function col.white(str)  return      WHITE_FONT_COLOR:WrapTextInColorCode(str) end;
function col.yellow(str) return     YELLOW_FONT_COLOR:WrapTextInColorCode(str) end;
function col.blue(str)   return BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(str) end;
function col.addon(str)  return    _G[addOnColorName]:WrapTextInColorCode(str) end;
function col.ora(str)    return     ORAIBI_FONT_COLOR:WrapTextInColorCode(str) end;

local SLASH = col.addon("/rpfind");

L["Button Close"                       ] = "Close";
L["Button Config"                      ] = "Options";
L["Button Delete DB Now Tooltip"       ] = "You can immediately clear up memory by pressing this button, which will wipe your database of saved players. Your configuration options " .. col.green("will") .. " be preserved.";
L["Button Delete DB Now"               ] = "Delete Now";
L["Button Test Notify Tooltip"         ] = "Send yourself a test notification.";
L["Button Test Notify"                 ] = "Test";
L["Config Alert All TRP3 Scan Tooltip" ] = "Check this to be notified when someone in any zone does a TRP3 map scan.";
L["Config Alert All TRP3 Scan"         ] = "Alert All TRP3 Scans";
L["Config Alert TRP3 Connect Tooltip"  ] = "Check this to be notified whenever anyone using TRP3 logs on your server.";
L["Config Alert TRP3 Connect"          ] = "Alert TRP3 Logins";
L["Config Alert TRP3 Scan Tooltip"     ] = "Check this to be notified when someone in your zone does a TRP3 map scan.";
L["Config Alert TRP3 Scan"             ] = "Alert Local TRP3 Scans";
L["Config Database Counts"             ] = col.green("Database Stats");
L["Config Database Stats Update"       ] = "Update";
L["Config Database Stats Update Tooltip"] = "Update this display to show the current statistics, if they've changed since you opened the page.";
L["Format Database Counts"             ] = "\n\n" .. col.white("Player Data Records") .. col.yellow(" %s players seen\n") .. col.white("Player Records Loaded") .. col.yellow(" %s records loaded\n");
L["Config Database Warning GB"         ] = "Database - " .. col.red("Warning!");
L["Config Database Warning MB"         ] = "Database - " .. col.white("Warning!");
L["Config Database"                    ] = "Database";
L["Config Delete DB on Login Tooltip"  ] = addOnTitle .. " stores a record of players you've seen before. You can save memory and CPU by checking this box. The changes won't happen until your next login. Your configuration options " .. col.green("will") .. " be preserved.";
L["Config Delete DB on Login"          ] = "Delete Database on Login";
L["Config Finder Tooltips Tooltip"     ] = "Show tooltips in the Finder screen.";
L["Config Finder Tooltips"             ] = "Show Finder Tooltips";
L["Config Lock Icon Tooltip"           ] = "Check to lock the icon in its current position.";
L["Config Lock Icon"                   ] = "Lock Icon";
L["Config Login Message Tooltip"       ] = "Show a login message from " .. addOnTitle .. " when you connect to WoW.";
L["Config Login Message"               ] = "Login Notification";
L["Config Memory Usage"                ] = "Memory Usage";
L["Config Monitor MSP Tooltip"         ] = "Look for changes to the MSP (Mary Sue Protocol) database; i.e. when you receive a new profile in an RP addon.";
L["Config Monitor MSP"                 ] = "Monitor MSP";
L["Config Monitor TRP3 Tooltip"        ] = "Look for messages sent by Total RP 3. " .. col.green("Note:") .. "You don't need to have Total RP 3 installed to turn this on.";
L["Config Monitor TRP3"                ] = "Monitor Total RP 3";
L["Config Notify Method Tooltip"       ] = "Choose how you want to receive notifications from " .. addOnTitle .. ".";
L["Config Notify Method"               ] = "Method";
L["Config Notify Sound Tooltip"        ] = "Choose a sound to play when a notification is sent.";
L["Config Notify Sound"                ] = "Sound";
L["Config Notify"                      ] = "Notifications";
L["Config Options"                     ] = "General";
L["Config Notify LFRP"                 ] = "Notify " .. addOnTitle .. " Ads";
L["Config Notify LFRP Tooltip"         ] = "Choose whether you get notified whenever an " .. addOnTitle .. " ad is received.";
L["Config Show Icon Tooltip"           ] = "Show or hide the minimap icon.";
L["Config Show Icon"                   ] = "Show Icon";
L["Config TRP3"                        ] = "Total RP 3 Options";
L["Config Smart Pruning"               ] = "Smart Pruning";
L["Config See Adult Ads"               ] = "See Adult Ads";
L["Display View Profile Tooltip"] = "Click to open the player's profile in your RP addon.";
L["Display Send Tell Tooltip"] = "Click to open the chat window to send an OOC message to this player.";
L["Display Send Ping Tooltip"] = "Click to send a silent request to the player's RP addon, asking to refresh their profile.";
L["Display Read Ad Tooltip"] = "Click to view the player's LFRP ad.";
L["Display Send Invite Tooltip"] = "Click to invite the player to join your party or raid.";
L["Config See Adult Ads Tooltip"       ] = "Some ads may be inappropriate for a younger audience. Check this box to see any ads marked as such.";
L["Adult Content Patterns"             ] = "fuck%S*|%S*shit";
-- L["Config Use Smart Pruning"           ] = "Use Smart Pruning";
L["Config Use Smart Pruning"           ] = "Use";

L["Config Use Smart Pruning Tooltip"   ] = "Smart pruning is one way to keep the database size managable. You can choosse the " .. col.blue("Smart Pruning Threshold") .. " to fine-tune memory management.";
L["Config Smart Pruning Threshold"     ] = "Smart Pruning Threshold";
L["Config Smart Pruning Threshold Tooltip" ] = "Anything older than your chosen threshold will be deleted each time you log on.";
L["Config Smart Pruning Repeat"        ] = "Cycling";
-- L["Config Smart Pruning Repeat"        ] = "Continually Prune";
L["Config Smart Pruning Repeat Tooltip" ] = addOnTitle .. " can check every 15 minutes and silently prune entries that are older than your smart pruning threshold.";
L["Button Smart Prune Database"        ] = "Prune Now";
L["Button Smart Prune Database Tooltip" ] = "Your " .. col.blue("Smart Pruning Threshold") .. " will be applied next time you log on, but you can manually clear out older entries now if you wish.";
L["Credits Header"                     ] = "Credits";
L["Credits Info"                       ] = "\n\nThe coding was done by " .. col.ora("Oraibi-MoonGuard") .. ".";
L["Format Smart Pruning Done"          ] = "Smart Pruning has been completed; %d database entries were pruned";
L["Notify Smart Pruning Zero"          ] = "Smart Pruning has been completed, but no database entries were pruned.";
L["Format Alert TRP3 Connect"          ] = "%s logged on.";
L["Format Alert TRP3 Scan"             ] = "%s scanned for players in %s.";
L["Format Memory Usage"                ] = addOnTitle .. " is currently using %3.2f %s of memory. %s";
L["Format Finder Title Display"        ] = addOnTitle .. " - %s Players Known";
L["Format Finder Title LFG"            ] = addOnTitle .. " - %s Groups Listed";
L["Format Finder Title LFG Disabled"   ] = addOnTitle .. " - LFG (Disabled)";
L["Format Finder Title Tools"          ] = addOnTitle .. " - Tools";
L["Instruct TRP3"                      ] = "To enable these options, check the General option to |cff00ffffMonitor TRP3|r. You don't have to be running Total RP 3 yourself to use these options.";
L["Label Finder Tooltips"              ] = "Tooltips";
L["Menu Notify Method Chat"            ] = "Chat Window";
L["Menu Notify Method Toast"           ] = "Toast";
L["Menu Notify Method Both"            ] = "Chat Window " .. col.blue("and") .. " Toast";
L["Menu Notify Method None"            ] = "Disable Notifications";
L["Notify Login Message"               ] = "AddOn loaded. Type " .. SLASH .. " for help and options.";
L["Notify Test"                        ] = "This is a sample notification.";
L["Popup Delete DB Now"                ] = col.red("Warning") .. "\n\nYou've pressed the button to delete " .. addOnTitle .. "'s saved player database immediately. This can't be undone. Are you sure this what you want to do?";
L["Popup Delete DB on Login"           ] = col.yellow("Warning:") .. "\n\nYou've checked the option to delete " .. addOnTitle .. "'s saved player database the next time you log in. Once you log in again (or reload your UI), this can't be undone. Are you sure this what you want to do?";
L["Slash Commands"                     ] = "Slash Commands";
L["Slash Options"                      ] = SLASH .. col.yellow(" options") .. " - Open the options panel";
L["Sound Alarm Clock 1"                ] = "Alarm Clock 1";
L["Sound Alarm Clock 2"                ] = "Alarm Clock 2";
L["Sound Alarm Clock 3"                ] = "Alarm Clock 3";
L["Sound Auction Open"                 ] = "Auction Open";
L["Sound Azerite Armor"                ] = "Azerite Armor";
L["Sound Bnet Login"                   ] = "Bnet Login";
L["Sound Digsite Complete"             ] = "Digsite Complete";
L["Sound Epic Loot"                    ] = "Epic Loot";
L["Sound Flag Taken"                   ] = "Flag Taken";
L["Sound Friend Login"                 ] = "Friend Login";
L["Sound Map Ping"                     ] = "Map Ping";
L["Sound Raid Warning"                 ] = "Raid Warning";
L["Sound Silent Trigger"               ] = "|cff00ffff(none)|r";
L["Sound Store Purchase"               ] = "Store Purchase";
L["Sound Vignette Ping"                ] = "Vignette Ping";
L["Sound Voice Friend"                 ] = "Voice Friend";
L["Sound Voice In"                     ] = "Voice In";
L["Sound Voice Join"                   ] = "Voice Join";
L["Sound Voice Out"                    ] = "Voice Out";
L["Version Info"                       ] = "You're running " .. addOnTitle .. " version " .. col.blue(addOnVersion) .. " (" .. addOnDate .. ").\n\n";
L["Warning High Memory GB"             ] = "\n\n" .. col.red("Warning:") .. " This is an " .. col.red("extremely") .. " high amount of memory. You should choose one of the options here to adjust your memory usage.";
L["Warning High Memory MB"             ] = "\n\n" .. col.yellow("Warning:") .. " This is a high amount, and you should consider using one of the options here to adjust your memory usage.";

--[[
  
  NSFW: This space deliberately kept blank






































--]]

L["Adult Content Patterns"] = 
[===[
%S*bitch%S*
%S*cocks?
%S*cuck%S*
%S*cunts?
%S*faggot%S*
%S*fags?
%S*fucks?
%S*gasms?
%S*jizz%S*
%S*naked
%S*nipple%S*
%S*penis%S*
%S*pussy%S*
%S*sacks?
%S*slave%S*
%S*slaves?
%S*slut%S*
%S*vores?
%S*whore%S*
%S+philia
age ?play
anal
anilingus
anuse?s?
arseholes?
asse?s?
assholes?
assmunch%S*
balls?
bareback%S*
bastards?
bbcs?
bbws?
bdsm
beavers?
bestiality
big black
bimbos?
bjs?
blow ?jobs?
bollocks?
bondage
boners?
boobs?
booty ?call
breasts?
bred
breed%S*
bukk?akk?e
bung ?hole
buttcheeks?
buttholes?
butts?
camel ?toe%S*
clit%S*
cock%S*
condoms?
coons?
corn ?holes
corrupt%S*
creampie
crotch
cumming
cums?
cunnilingus
cunt%S*
darknest
deep ?throat%S*
degred%S*
dick%S*
dildo
dingle ?ber%S*
dingleberry
dog%S* ?style
dolcett
dombreak%S*
dominants?
domination
dominatrix
dommes?
doms?
dongs?
double pene%S*
ejacul%S*
equine
eroti%S*
erpin%S*
erps?
escorts?
eunuchs?
f ?list
fecal
fellatio
felt?ch
femboys?
femdom%S*
fetish%S*
findom%S*
fingerbang
fingering
fisting
foot ?jobs?
frotting
fuck%S*
fudge ?packer
futa%S*
g ?spot
gang ?bang
genitals?
goatcx
goatse
gores?
grope%S*
guro%S*
hand ?jobs
hard ?core
hentai
herma%s*
herms?
hookers?
humpings?
humps?
hung
hypno%S*
impreg%S*
incest%S*
jack ?off%S*
jail ?bait
jerk%S+
jerkalts?
jerkbait
jerki%S
jerkoffs?
jug+s?
kink%S*
knobbing
knott%S*
lewds?
loin cloths?
lolis?
lolit%S*
mastur%S*
milfs?
missionary position
mocha
motherfuck%S*
muff ?div%S*
muffdiving
musk%S*
nambla
nawashi
nsfws?
nubs?
nudes?
nudity
nutbutter
nympho%S*
omorashi
oral
orgies
orgy
paedo%S*
paki
panties
panty
paypig%S*
pedo%S*
pegging
piss%S*
pole ?smokers?
pony ?play
poofs?
poon%S*
poop ?chute
porno?%S*
preggers?
pregna%S*
prostit%S*
pubes?
pubic
que[ea]fs?
quims?
rapes?
raping
rapists?
rectums?
rim ?jobs?
rimming
sadis%S*
santorum
scat
schlongs?
scissoring
semen
sex
sex%S*
sexo
shags?
she ?bulls?
sheaths?
shemale%S*
shibari
shit%S*
shotas?
sissie%S*
sissy
smut
snatch%S*
snuffs?
sodom%S*
spank%S*
spitroasts?
spl?ooge%S*
spunk
strap ?ons?
studs?
subby
submissives?
subs?
sucks?
swastikas?
taboo
tea ?bag%S*
thongs?
throating
ti[td][td]ies
ti[td][td]y
tied up
tits?
toilet%S*
topless
tosser
tranny
tribadism
tushy
twat%S*
twink%S*
undress%S*
upskirt
urethra%S*
vaginas?
vibrators?
vore%S*
voyeur%S*
vulvas?
wank%S*
xxx?
yaoi
yiff%S*
]===];

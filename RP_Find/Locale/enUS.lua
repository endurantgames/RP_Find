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
function col.gray(str)   return   DISABLED_FONT_COLOR:WrapTextInColorCode(str) end;
function col.addon(str)  return    _G[addOnColorName]:WrapTextInColorCode(str) end;
function col.ora(str)    return     ORAIBI_FONT_COLOR:WrapTextInColorCode(str) end;

local addOnSlash = col.addon("/rpfind");

L["Binding Show Finder"                    ] = "Open Finder";
L["Binding Hide Finder"                    ] = "Close Finder";
L["Binding Toggle Finder"                  ] = "Toggle Finder";
L["Binding Group rpFind"                   ] = addOnTitle;
L["Binding Send Ad"                        ] = "Send Ad";
L["Binding Display"                        ] = "Open Database Tab";
L["Binding Ads"                            ] = "Open Ad Tab";
L["Binding Tools"                          ] = "Open Tools Tab";
L["Binding Send Map Scan"                  ] = "Send Map Scan";
L["Subzone The Mage Quarter"               ] = "The Mage Quarter";         -- Stormwind
L["Subzone Cathedral Square"               ] = "Cathedral Square";         -- Stormwind
L["Subzone Lion's Rest"                    ] = "Lion's Rest";              -- Stormwind
L["Subzone Stormwind Harbor"               ] = "Stormwind Harbor";         -- Stormwind
L["Subzone Trade District"                 ] = "Trade District";           -- Stormwind
L["Subzone Old Town"                       ] = "Old Town";                 -- Stormwind
L["Subzone Stormwind Keep"                 ] = "Stormwind Keep";           -- Stormwind
L["Subzone The Dwarven District"           ] = "The Dwarven District";     -- Stormwind
L["Subzone Goldshire"                      ] = "Goldshire";                -- Elwynn Forest
L["Subzone Valley of Honor"                ] = "Valley of Honor";          -- Orgrimmar
L["Subzone The Drag"                       ] = "The Drag";                 -- Orgrimmar
L["Subzone Valley of Strength"             ] = "Valley of Strength";       -- Orgrimmar
L["Subzone Valley of Spirits"              ] = "Valley of Spirits";        -- Orgrimmar
L["Subzone Valley of Wisdom"               ] = "Valley of Wisdom";         -- Orgrimmar
L["Subzone The Bazaar"                     ] = "The Bazaar";               -- Silvermoon City
L["Subzone Walk of Elders"                 ] = "Walk of Elders";           -- Silvermoon City
L["Subzone The Royal Exchange"             ] = "The Royal Exchange";       -- Silvermoon City
L["Subzone Murder Row"                     ] = "Murder Row";               -- Silvermoon City
L["Subzone Farstriders' Square"            ] = "Farstriders' Square";      -- Silvermoon City
L["Subzone Court of the Sun"               ] = "Court of the Sun";         -- Silvermoon City
L["Subzone Sunfury Spire"                  ] = "Sunfury Spire";            -- Silvermoon City
L["Button Clear Ad"                        ] = "Clear Ad";
L["Button Got It"                          ] = "Got It";
L["Button Close"                           ] = "Close";
L["Button Config"                          ] = "Options";
L["Button Delete DB Now Tooltip"           ] = "You can immediately clear up memory by pressing this button, which will wipe your database of saved players. Your configuration options " .. col.green("will") .. " be preserved.";
L["Button Delete DB Now"                   ] = "Delete Now";
L["Button Left-Click"                      ] = "Left-Click";
L["Button List Group"                      ] = "List Group";
L["Button Preview Ad"                      ] = "Preview Ad";
L["Button Right-Click"                     ] = "Right-Click";
L["Button Scan Now"                        ] = "Scan Now";
L["Button Scan Results"                    ] = "Scan Results";
L["Button Search"                          ] = "Search";
L["Button Send Ad"                         ] = "Send Ad";
L["Button Smart Prune Database Tooltip"    ] = "Your " .. col.blue("Smart Pruning Threshold") .. " will be applied next time you log on, but you can manually clear out older entries now if you wish.";
L["Button Smart Prune Database"            ] = "Prune Now";
L["Button Test Notify Tooltip"             ] = "Send yourself a test notification.";
L["Button Test Notify"                     ] = "Test";
L["Button Toolbar Tools"                   ] = "Tools";
L["Button Toolbar Check LFG"               ] = "Check LFG";
L["Button Toolbar Database"                ] = "Database";
L["Button Toolbar Edit Ad"                 ] = "Edit Ad";
L["Button Toolbar Preview Ad"              ] = "Preview Ad";
L["Button Toolbar Prune"                   ] = "Prune";
L["Button Toolbar Read Ads"                ] = "Read Ads";
L["Button Toolbar Scan"                    ] = "Map Scan";
L["Button Toolbar Search"                  ] = "Search";
L["Button Toolbar Send Ad"                 ] = "Send Ad";
L["Button Toolbar Send LFG"                ] = "Send LFG";
L["Button Toolbar Autosend Start"          ] = "Autosend Ad";
L["Button Toolbar Autosend Stop"           ] = "Autosend Cancel";
L["Button Toolbar Scan Results"            ] = "Scan Results";
L["Button Toolbar Tools Tooltip"           ] = "Switch to the tools window.";
L["Button Toolbar Check LFG Tooltip"       ] = "Scan the LFG ads.";
L["Button Toolbar Database Tooltip"        ] = "Switch to the database window.";
L["Button Toolbar Edit Ad Tooltip"         ] = "Edit your LFRP ad.";
L["Button Toolbar Preview Ad Tooltip"      ] = "Preview your LFRP ad.";
L["Button Toolbar Prune Tooltip"           ] = "Auto-prune the database to reduce memory usage.";
L["Button Toolbar Read Ads Tooltip"        ] = "Read ads received.";
L["Button Toolbar Scan Tooltip"            ] = "Send a TRP3 map scan request.";
L["Button Toolbar Search Tooltip"          ] = "Search the database.";
L["Button Toolbar Send Ad Tooltip"         ] = "Send your LFRP ad.";
L["Button Toolbar Send LFG Tooltip"        ] = "Send your LFG ad.";
L["Button Toolbar Autosend Start Tooltip"  ] = "Start your LFRP ad auto-sending every hour.";
L["Button Toolbar Autosend Stop Tooltip"   ] = "Stop your LFRP ad from auto-sending every hour.";
L["Button Toolbar Scan Results Tooltip"    ] = "View the results of your most recent map scan.";
L["Config Alert All TRP3 Scan Tooltip"     ] = "Check this to be notified when someone in any zone does a TRP3 map scan.";
L["Config Alert All TRP3 Scan"             ] = "Alert All TRP3 Scans";
L["Config Alert TRP3 Connect Tooltip"      ] = "Check this to be notified whenever anyone using TRP3 logs on your server.";
L["Config Alert TRP3 Connect"              ] = "Alert TRP3 Logins";
L["Config Alert TRP3 Scan Tooltip"         ] = "Check this to be notified when someone in your zone does a TRP3 map scan.";
L["Config Alert TRP3 Scan"                 ] = "Alert Local TRP3 Scans";
L["Config Auto Send Ping Tooltip"          ] = "When you receive an update via MSP or TRP3, automatically request their full profile. The profile will be handled by your RP addon, not " .. addOnTitle .. ".";
L["Config Auto Send Ping"                  ] = "Auto-Request Profiles";
L["Config Database Counts"                 ] = col.green("Database Stats");
L["Config Database Stats Update Tooltip"   ] = "Update this display to show the current statistics, if they've changed since you opened the page.";
L["Config Database Stats Update"           ] = "Update";
L["Config Database Warning GB"             ] = "Database - " .. col.red("Warning!");
L["Config Database Warning MB"             ] = "Database - " .. col.white("Warning!");
L["Config Database"                        ] = "Database";
L["Config Delete DB on Login Tooltip"      ] = addOnTitle .. " stores a record of players you've seen before. You can save memory and CPU by checking this box. The changes won't happen until your next login. Your configuration options " .. col.green("will") .. " be preserved.";
L["Config Delete DB on Login"              ] = "Delete Database on Login";
L["Config Finder Tooltips Tooltip"         ] = "Show tooltips in the Finder screen.";
L["Config Finder Tooltips"                 ] = "Show Finder Tooltips";
L["Config Lock Icon Tooltip"               ] = "Check to lock the icon in its current position.";
L["Config Lock Icon"                       ] = "Lock Icon";
L["Config Login Message Tooltip"           ] = "Show a login message from " .. addOnTitle .. " when you connect to WoW.";
L["Config Login Message"                   ] = "Login Notification";
L["Config Memory Usage"                    ] = "Memory Usage";
L["Config Monitor MSP Tooltip"             ] = "Look for changes to the MSP (Mary Sue Protocol) database; i.e. when you receive a new profile in an RP addon.";
L["Config Monitor MSP"                     ] = "Monitor MSP";
L["Config Monitor TRP3 Tooltip"            ] = "Look for messages sent by Total RP 3. " .. col.green("Note:") .. "You don't need to have Total RP 3 installed to turn this on.";
L["Config Monitor TRP3"                    ] = "Monitor Total RP 3";
L["Config Notify LFRP Tooltip"             ] = "Choose whether you get notified whenever an " .. addOnTitle .. " ad is received.";
L["Config Notify LFRP"                     ] = "Notify " .. addOnTitle .. " Ads";
L["Config Notify Method Tooltip"           ] = "Choose how you want to receive notifications from " .. addOnTitle .. ".";
L["Config Notify Method"                   ] = "Method";
L["Config Notify Sound Tooltip"            ] = "Choose a sound to play when a notification is sent.";
L["Config Notify Sound"                    ] = "Sound";
L["Config Notify"                          ] = "Notifications";
L["Config Options"                         ] = "General";
L["Config See Adult Ads Tooltip"           ] = "Some ads may be inappropriate for a younger audience. Check this box to see any ads marked as such.";
L["Config See Adult Ads"                   ] = "See Adult Ads";
L["Config Show Icon Tooltip"               ] = "Show or hide the minimap icon.";
L["Config Show Icon"                       ] = "Show Icon";
L["Config Smart Pruning Repeat Tooltip"    ] = addOnTitle .. " can check every 15 minutes and silently prune entries that are older than your smart pruning threshold.";
L["Config Smart Pruning Repeat"            ] = "Cycling";
L["Config Smart Pruning Threshold Tooltip" ] = "Anything older than your chosen threshold will be deleted each time you log on.";
L["Config Smart Pruning Threshold"         ] = "Smart Pruning Threshold";
L["Config Smart Pruning"                   ] = "Smart Pruning";
L["Config TRP3"                            ] = "Total RP 3 Options";
L["Config Use Smart Pruning Tooltip"       ] = "Smart pruning is one way to keep the database size managable. You can choosse the " .. col.blue("Smart Pruning Threshold") .. " to fine-tune memory management.";
L["Config Use Smart Pruning"               ] = "Use Smart Pruning";
L["Config Notify Chat Type"                ] = "Chat Message Type";
L["Config Notify Chat Type Tooltip"        ] = "Choose the type of chat message that should be sent. This lets you customize your chat windows to send chat notifications wherever you want.";
L["Config Notify Chat Flash"               ] = "Flash Frame";
L["Config Notify Chat Flash Tooltip"       ] = "Check to make each chat frame that receives the notification flash/pulse.";
L["Credits Header"                         ] = "Credits";
L["Credits Info"                           ] = "\n\nThe coding was done by " .. col.ora("Oraibi-MoonGuard") .. ".";
L["Display Active Filters"                 ] = "Active Filters";
L["Display Column Title Ad"                ] = "Read LFRP Ad";
L["Display Column Title Invite"            ] = "Invite Player";
L["Display Column Title Ping"              ] = "Ping Player";
L["Display Column Title Profile"           ] = "Open Profile";
L["Display Column Title Whisper"           ] = "Send OOC Tell to Player";
L["Display Filters"                        ] = "Filters";
L["Display Header Flags"                   ] = "Flags";
L["Display Header Name"                    ] = "Name";
L["Display Header Server"                  ] = "Server";
L["Display Header Tools"                   ] = "Tools";
L["Display Nothing Found"                  ] = col.gray("\nNothing Found");
L["Display Read Ad Tooltip"                ] = "Click to view the player's LFRP ad.";
L["Display Search Tooltip"                 ] = "Enter a pattern to search for.\n\nYou can use lua patterns; for example, you can search for players whose names begin with A with this:\n\n" .. col.blue("^a");
L["Display Search"                         ] = "Search Pattern";
L["Display Send Invite Tooltip"            ] = "Click to invite the player to join your party or raid.";
L["Display Send Ping Tooltip"              ] = "Click to send a silent request to the player's RP addon, asking to refresh their profile.";
L["Display Send Tell Tooltip"              ] = "Click to open the chat window to send an OOC message to this player.";
L["Display View Profile Tooltip"           ] = "Click to open the player's profile in your RP addon.";
L["Explain LFG Disabled"                   ] = "These options are disabled because you are lower than level 50. As of WoW 9.0, Blizzard retricts LFG to levels 50+.";
L["Field Ad Text"                          ] = "Ad Text";
L["Field Ad Title"                         ] = "Ad Title";
L["Field Adult Ad"                         ] = "This ad contains adult material";
L["Field Blank"                            ] = "Not Set";
L["Field Body Blank"                       ] = "Ad Text Needed";
L["Field LFG Details"                      ] = "Details";
L["Field Race"                             ] = "Race";
L["Field Class"                            ] = "Class";
L["Field Pronouns"                         ] = "Pronouns";
L["Field LFG Filter"                       ] = "Filter (optional)";
L["Display Header Info"                    ] = "Info";
L["Info Column Tooltip"                    ] = "\n\nYou can configure this field to display whatever information you like, in Options.";
L["Config Info Column"                     ] = "Info Column";
L["Config Info Column Tooltip"             ] = "You can configure the info column to display specific information. If you have rpTags, you can use a tag sequence instead.";
L["Config Info Column Tags"                ] = "Tags";
L["Config Info Column Tags Disabled"       ] = "Tags (requires rpTags)";
L["Config Info Column Tags Tooltip"        ] = "Enter a string of tags that will be parsed by rpTags.";
L["Info Class"                             ] = "Character Class";
L["Info Race"                              ] = "Character Race";
L["Info Race Class"                        ] = "Race and Class";
L["Info Age"                               ] = "Character Age";
L["Info Pronouns"                          ] = "Pronouns";
L["Info Zone"                              ] =  "Zone";
L["Info Tags"                              ] =  "rpTags tags";
L["Info Status"                            ] =  "Status (IC/OOC)";
L["Info Currently"                         ] = "Currently";
L["Info OOC Info"                          ] =  "OOC Info";
L["Info Title"                             ] = "Character Title";
L["Info Game Race Class"                   ] = "Game Race, Class";
L["Info Data Timestamp"                    ] = "Timestamp";
L["Info Data First Seen"                   ] = "First Seen";
L["Info Server"                            ] = "Server";
L["Info Subzone"                           ] = "Subzone";
L["Pattern LGBT Friendly"                  ] = "lgbtq?i?a?%+?";
L["Flag Have RP Profile"                   ] = "Have RP Profile";
L["Flag Is Set IC"                         ] = "In Character";
L["Flag Is Set OOC"                        ] = "Out of Character";
L["Flag Is Set Looking"                    ] = "Looking for Contact";
L["Flag Is Set Storyteller"                ] = "Storyteller";
L["Flag Is Trial"                          ] = "Trial Account";
L["Flag Have Ad"                           ] = "Sent LFRP Ad";
L["Flag Map Scan"                          ] = "Sent a Map Scan";
L["Flag LGBT Friendly"                     ] = "LGBTQIA+ Friendly";
L["Flag Walkups"                           ] = "Walkups Welcome";
L["Flag rpFind User"                       ] = addOnTitle .. " User";
L["Flag Your Friend"                       ] = "Your Friend";
L["Info Zone Subzone"                      ] = "Zone and Subzone";
L["Config Button Bar Size"                 ] = "Button Size";
L["Config Button Bar Size Tooltip"         ] = "Set the size of the buttons on the toolbar.";
L["Field LFG Title"                        ] = "Title";
L["Field Title Blank"                      ] = "Title Needed";
L["Field Zone to Scan"                     ] = "Zone to Scan";
L["Filter Active Last Day"                 ] = "Active in the Last Day";
L["Filter Info Not Empty"                  ] = "Info Column Not Empty";
L["Filter Active Last Hour"                ] = "Active in the Last Hour";
L["Filter Have LFRP Ad"                    ] = "Sent an LFRP Ad";
L["Filter Is Set IC"                       ] = "Is Set In-Character";
L["Filter Match Map Scan"                  ] = "Matches Most Recent Map Scan";
L["Filter On This Server"                  ] = "On This Server";
L["Filter RP Profile Loaded"               ] = "RP Profile Loaded";
L["Filter Sent Map Scan"                   ] = "Did a Map Scan Recently";
L["Format <1 Minute Ago"                   ] = "<1 minute ago";
L["Format Alert TRP3 Connect"              ] = "%s logged on.";
L["Filter Clear All Filters"               ] = col.green("Clear all filters.");
L["Format Alert TRP3 Scan"                 ] = "%s scanned for players in %s.";
L["Format Database Counts"                 ] = "\n\n" .. col.yellow("%s |4player record:player records; loaded\n");
L["Format Display Filters"                 ] = "%d |4Filter:Filters;";
L["Format Finder Title Display"            ] = addOnTitle .. " - %s Players Known";
L["Format Finder Title Display Filtered"   ] = addOnTitle .. " - %s Players Known (%s displayed)";
L["Format Finder Title LFG Disabled"       ] = addOnTitle .. " - LFG (Disabled)";
L["Format Finder Title LFG"                ] = addOnTitle .. " - %s Groups Listed";
L["Format Finder Title Tools"              ] = addOnTitle .. " - Tools";
L["Format Memory Usage"                    ] = addOnTitle .. " is currently using %3.2f %s of memory. %s";
L["Format Open Profile Failed"             ] = "Unable to open profile for %s.";
L["Format Per Page"                        ] = "%d Per Page";
L["Format Ping Sent"                       ] = "Ping sent to %s.";
L["Format Send Ad Failed"                  ] = "You can only send an ad once every %d seconds.";
L["Format Send Whisper Failed"             ] = "Sorry, you can only send one whisper through " .. addOnTitle .. " every %d minutes. Please wait another %d seconds.";
L["Format Smart Pruning Done"              ] = "Smart Pruning has been completed; %d database entries were pruned";
L["Format TRP3 Scan Failed"                ] = "You can only send a scan once every %d seconds.";
L["Format X Minutes Ago"                   ] = "%i |4minute:minutes; ago";
L["Instruct TRP3"                          ] = "To enable these options, check the General option to |cff00ffffMonitor TRP3|r. You don't have to be running Total RP 3 yourself to use these options.";
L["Label Finder Tooltips"                  ] = "Tooltips";
L["Label LFG List Your Group"              ] = "List Your Group";
L["Label LFG Search"                       ] = "Search";
L["Label Read Ad"                          ] = "Read Ad";
L["Label Invite"                           ] = "Invite";
L["Label Whisper"                          ] = "Whisper";
L["Label Open Profile"                     ] = "Profile";
L["Label Ping"                             ] = "Ping";
L["Link Text Default"                      ] = "Copy the following, then close this window.";
L["Link Text HTTP"                         ] = "Copy the following URL for {text} and paste it into your browser, then close this window.";
L["Link Text HTTPS"                        ] = "Copy the following URL for {text} and paste it into your browser, then close this window.";
L["Link Text Mailto"                       ] = "Copy the following email address for {text}, then close this window.";
L["Memory Usage"                           ] = "Memory Usage";
L["Menu Notify Method Both"                ] = "Chat Window " .. col.blue("and") .. " Toast";
L["Menu Notify Method Chat"                ] = "Chat Window";
L["Menu Notify Method None"                ] = "Disable Notifications";
L["Menu Notify Method Toast"               ] = "Toast";
L["Notify Auto Send Start"                 ] = "Your ad will now be sent every 60 minutes.";
L["Notify Auto Send Stop"                  ] = "Autosend cancelled.";
L["Notify Filters Cleared"                 ] = "All filters cleared.";
L["Notify Ad Cleared"                      ] = "Your ad has been cleared.";
L["Format New Version Available"           ] = "A new version of " .. addOnTitle .. " (%s) " .. " is available.";
L["Notify Database Deleted"                ] = "Database deleted.";
L["Notify Database Deletion Aborted"       ] = "Database deletion aborted.";
L["Notify Login Message"                   ] = "AddOn loaded. Type " .. addOnSlash .. " for help and options.";
L["Notify Send Ad"                         ] = "Ad sent. Good luck!";
L["Notify Setting Cleared"                 ] = "Setting cleared.";
L["Notify Smart Pruning Zero"              ] = "Smart Pruning has been completed, but no database entries were pruned.";
L["Notify TRP3 Scan Sent"                  ] = "Scan message request sent. Replying characters will be added to the database.";
L["Notify Test"                            ] = "This is a sample notification.";
L["Open Finder Window"                     ] = "Open Finder Window";
L["Open Finder Window Tooltip"             ] = "Close options and open the " .. addOnTitle .. " Finder window.";
L["Options"                                ] = "Options";
L["Players Loaded"                         ] = "Players Loaded";
L["Players Seen"                           ] = "Players Seen";
L["Popup Delete DB Now"                    ] = col.red("Warning") .. "\n\nYou've pressed the button to delete " .. addOnTitle .. "'s saved player database immediately. This can't be undone. Are you sure this what you want to do?";
L["Popup Delete DB on Login"               ] = col.yellow("Warning:") .. "\n\nYou've checked the option to delete " .. addOnTitle .. "'s saved player database the next time you log in. Once you log in again (or reload your UI), this can't be undone. Are you sure this what you want to do?";
L["Slash Commands"                         ] = "Slash Commands:";
L["Slash Toggle"                           ] = addOnSlash .. col.yellow(" toggle") .. " - Toggle the Finder window";
L["Slash Show"                             ] = addOnSlash .. col.yellow(" open")   .. " - Open the Finder window";
L["Slash Hide"                             ] = addOnSlash .. col.yellow(" close")   .. " - Close the Finder window";
L["Slash Display"                          ] = addOnSlash .. col.yellow(" database") .. " - Open the database tab of the Finder";
L["Slash Ads"                              ] = addOnSlash .. col.yellow(" ad") .. " - Open the ad tab of the Finder";
L["Slash Tools"                            ] = addOnSlash .. col.yellow(" tools") .. " - Open the tools tab of the Finder";
L["Slash Options"                          ] = addOnSlash .. col.yellow(" options") .. " - Open the options panel";
L["Slash Map Scan"                         ] = addOnSlash .. col.yellow(" map scan") .. " - Send TRP3 Map Scan";
L["Slash Send Ad"                          ] = addOnSlash .. col.yellow(" send ad") .. " - Send your LFRP ad";
L["Sound Alarm Clock 1"                    ] = "Alarm Clock 1";
L["Sound Alarm Clock 2"                    ] = "Alarm Clock 2";
L["Sound Alarm Clock 3"                    ] = "Alarm Clock 3";
L["Sound Auction Open"                     ] = "Auction Open";
L["Sound Azerite Armor"                    ] = "Azerite Armor";
L["Sound Bnet Login"                       ] = "Bnet Login";
L["Sound Digsite Complete"                 ] = "Digsite Complete";
L["Sound Epic Loot"                        ] = "Epic Loot";
L["Sound Flag Taken"                       ] = "Flag Taken";
L["Sound Friend Login"                     ] = "Friend Login";
L["Sound Map Ping"                         ] = "Map Ping";
L["Sound Raid Warning"                     ] = "Raid Warning";
L["Sound Silent Trigger"                   ] = "|cff00ffff(none)|r";
L["Sound Store Purchase"                   ] = "Store Purchase";
L["Sound Vignette Ping"                    ] = "Vignette Ping";
L["Sound Voice Friend"                     ] = "Voice Friend";
L["Sound Voice In"                         ] = "Voice In";
L["Sound Voice Join"                       ] = "Voice Join";
L["Sound Voice Out"                        ] = "Voice Out";
L["Tab Looking For Group"                  ] = "Looking for Group";
L["Tab Display"                            ] = "Database";
L["Tab Ads"                                ] = "Your Ad";
L["Tab Tools"                              ] = "Tools";
L["Tool TRP3 Map Scan"                     ] = "TRP3 Map Scan";
L["Version Info"                           ] = "You're running " .. addOnTitle .. " version " .. col.blue(addOnVersion) .. " (" .. addOnDate .. ").\n\n";
L["Warning High Memory MB"                 ] = "\n\n" .. col.yellow("Warning:") .. " This is a high amount, and you should consider using one of the options here to adjust your memory usage.";

-- markdown

L["Help and Credits Header"] = "Help and Credits";
L["Help Intro Header"] = "Introduction";
L["Help Intro"] =
string.gsub([===[
rpFind is a tool to help roleplayers connect with each other on RP servers.

rpFind doesn't store or send any profile itself, so you will need an RP addon
such as [Total RP 3](https://www.curseforge.com/wow/addons/total-rp-3)
or [MyRolePlay](https://www.curseforge.com/wow/addons/my-role-play) to
get the most of out of rpFind.
]===], "rpFind", addOnTitle);

L["Help Finder Header"] = "The Finder";
L["Help Finder"] = 
string.gsub([===[
The rpFind Finder is the central window of the addon. From the Finder, you can review a
central database of roleplayers, compose and send an LFRP ad, or send out a request for 
player locations.

The top of the Finder has a row of buttons known as the **Toolbar**. These allow you quick access
to the various functions found in rpFind. You can configure the size of the Toolbar buttons
in options. Buttons that can't be used for whatever reason are greyed out -- for example, 
if you're already on the Database page, then the Database button is disabled.

The main body of the Finder is comprised of three tabs: **Database** displays the list of RPers
found since you logged on; **Your Ad** lets you compose a LFRP ("looking for roleplay") advertisement;
and **Tools** are miscellaneous tools for finding other RPers.

To the right of the tabs is the **Profile Switcher**, which shows the current rpFind profile you're using. 
You can create new profiles in options, and change between them by clicking on the Profile Switcher.
]===], "rpFind", addOnTitle);

L["Help Display Header"] = "Database";
L["Help Display"] =
string.gsub(
[===[
The database tab shows you all of the players who have been noticed by rpFind since you first logged on.

There are 4 columns in the database tab:

- The **Name** column shows the character's roleplaying name (if known) or the character's game name.
- The **Info Column** is a customizable field that you can set in options to display information of your own choosing.
- The **Flags** column shows icons to represent various information from the character's RP profile.
- The **Tools** column has a number of clickable sub-fields for interacting with the character being displayed.

Each column will also show you information when you mouse-over that column:

- The **Name Tooltip** shows the character's name, and various RP profile fields that you can configure in options.
- The **Info Column Tooltip** shows whatever information you've set it to show, in options.
- The **Flags Tooltip** gives an explanation of each displayed flag icon.
- The **Tools Tooltip** describes what each clickable tool does.

Note: due to the way WoW works, you can't be sure if a player in the database is currently logged on, without
trying to send them message or viewing their RP profile.
]===], "rpFind", addOnTitle);

L["Help Ads Header"] = "LFRP Ads";
L["Help Ads"] =

string.gsub([===[
You can use rpFind to compose and send ads that can be read by other rpFind users.

The "Your Ad" tab in the Finder lets you set the following fields:

- A **Title** for your ad, that briefly tells what you're looking for.
- The **Body** of your ad, where you more fully describe what you seek in roleplay.
- The **Adult Content flag**, where you can specify if your ad is not appropriate for younger players.

Once your ad is filled out, you can choose one of the following:

- **Clear Ad** to erase what you've written and start over.
- **Preview Ad** to see what your ad will look like to other players.
- **Send Ad** to send your ad to all rpFind-using players.
- **Autosend Ad** to send the ad immediately, and then schedule it to resent every hour afterward.
- **Stop Autosend** to cancel autosending of your ad.

You can only send your ad out once every 60 seconds. 

Your ad will be saved with your profile; if you want to make multiple ads for different purposes,
create a new profile (or copy your existing profile) in options.
]===], "rpFind", addOnTitle);

L["Help Tools Header"] = "Tools";
L["Help Tools"] =
string.gsub([===[
The Tools tab is a catch-all for various RP-related functions.

Currently there is one tool available:

## TRP3 Map Scan 

This lets you send out a (silent) request to all connected players who are using Total RP 3.
If they're set to reveal their map location, you'll receive back their zone and subzone,
which can then be shown in the database tab.

The controls for TRP3 Map Scan are:

- **Zone to Scan** lets you scan either your current zone, or another zone of your choice.
- **Scan Now** to send out a map scan request.
- **Scan Results** to set the database filter and switch to the database tab.

You don't have to have to Total RP 3 installed yourself to use the TRP3 Map Scan.
]===], "rpFind", addOnTitle);

L["Help Options Header"] = "Configuration Options";
L["Help Options"] =
string.gsub([===[
The configuration settings for rpFind are found in WoW's standard **options interface panel**. There
are five sections of rpFind options:

- **General Options** let you configure the appearance and basic functionality of the addon.
- **Notification Options** allow you to customize how and when you receive notifications from rpFind.
- **Database Options** give you control over the size of the database, so you can reduce the memory used by the addon.
- **Help and Credits** provides the help files you're viewing now, and tells you who to blame for rpFind.
- **Profiles** lets you create separate rpFind profiles with their own settings, and switch between those profiles.

Notification toasts can be further configured with the optional [Toaster addon](https://www.curseforge.com/wow/addons/toaster).
]===], "rpFind", addOnTitle);

L["Help Credits Header"] = "Credits";
L["Help Credits"] =
string.gsub([===[
rpFind was created by Oraibi on the Moon Guard-US server.

You can give feedback and bug reports at the [GitHub repository](https://github.com/caderaspindrift/RP_Find)
or the [rpAddOns discord server](https://discord.gg/dWwCtAmbp4).

rpFind uses a number of standard libraries, including:

- Ace3 (AceAddon, AceConfig, AceEvent, AceGUI, AceLocale, AceDB, AceDBOptions, AceTimer)
- CallbackHandler
- Chomp
- LibColorManipulation
- LibDataBroker
- LibDBIcon
- LibMarkdown, AceMarkdownWidget
- LibRealmInfo
- LibStub
- LibToast

]===], "rpFind", addOnTitle);

L["Help Etiquette Header"] = addOnTitle .. " Etiquette";
L["Help Etiquette"] =
string.gsub([===[
These are general guidelines on how to use rpFind responsibly:

- **Do tell your friends about rpFind.** The more people who know who about and use the addon, the more useful it is for everyone.
- **Don't spam your ads.** Try not to send out your ad every minute, even though you can. That can get obnoxious.
- **Do set your ad to autosend.** This lets you get the word out once an hour whenever you're connected.
- **Don't harass people.** This should go without saying, but don't pester people who don't want to hear from you.
- **Do be polite in OOC whispers.** The database tools let you send an OOC message to another player. Be nice!
- **Don't skirt the Adult Content setting.** It's not clever to force people to see your adult ad if they don't want to see adult ads.
- **Do check if someone wants contact.** If someone's IC in a public location, or if they have "walkups welcome" in the OOC info, then they might be looking for roleplay!

I reserve the right to further restrict rpFind functionality if I receive a large number of complaints about one of the uses of this addon.
]===], "rpFind", addOnTitle);

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

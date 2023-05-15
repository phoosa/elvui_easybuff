-- English localization file for enUS and enGB.
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI_EasyBuff", "enUS", true, true);

-- Messages
L["%s needs %s"] = true;
L["YOU HAVE %d UNWANTED BUFFS!"] = true;
L["Activity context changed to %s"] = true;
L["Talent Spec context changed to %s"] = true;
L["Announcements"] = true;

-- Config Table
L["General"] = true;
L["Enable"] = true;
L["Enables / disables the addon"] = true;
L["Active Spec"] = true;
L["All Talent Specs"] = true;
L["Primary Spec"] = true;
L["Secondary Spec"] = true;
L["Activity Context"] = true;
L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."] = true;
L["All Activities"] = true;
L["Talent Spec based Config"] = true;
L["Define different buff configuration rules to use when your Secondary Talent Spec is active."] = true;
L["Activity based Config"] = true;
L["Define different buff configuration rules for different activities: solo, party, raid, bg."] = true;
L["Monitoring"] = true;
L["Early Monitoring"] = true;
L["Auto-Remove before self-buff"] = true;
L["Automatically remove buff before applying new buff. Lesser buffs cannot overwrite greater, enabling this feature will ensure refreshing a buff doesn't error. This is only necessary with 'Early Monitoring' enabled."] = true;
L["Announce To"] = true;
L["How would you like to be notified of players missing Buffs?"] = true;
L["HUD is a moveable frame, click 'Toggle Anchors' and move the frame labeled:"] = true;
L["Chat Window"] = true;
L["HUD"] = true;
L["Select the Chat Window to display EasyBuff announcements in."] = true;
L["Announce Activity Context Change"] = true;
L["Enable / disable Activity Context Change announcements."] = true;
L["Announce Talent Spec Context Change"] = true;
L["Enable / disable Talent Spec Context Change announcements."] = true;
L["Keybinds"] = true;
L["Buff Casting bound to key:"] = true;
L["Change which key to use to apply buffs."] = true;
L["Buff Removal bound to key:"] = true;
L["Change which key to use to remove unwanted buffs."] = true;
L["Solo"] = true;
L["Party"] = true;
L["Raid"] = true;
L["Battleground"] = true;
L["Solo Activity"] = true;
L["Party Activity"] = true;
L["Raid Activity"] = true;
L["Battleground Activity"] = true;
L["Player Buffs"] = true;
L["Unwanted Buffs"] = true;
L["Add Unwanted Buff"] = true;
L["Insert Spell name or id"] = true;
L["Click to remove"] = true;
L["Any Role"] = true;
L["Tank"] = true;
L["Heal"] = true;
L["DPS"] = true;
L["Myself"] = true;
L["Configure which buffs you would like to monitor on yourself."] = true;
L["Configure which buffs you would like to monitor for this class."] = true;
L["Armor/Aura/Shield"] = true;
L["Linked buffs that a player may only have one of."] = true;
L["Available Buffs"] = true;
L["Disable when Resting"] = true;
L["Disable Monitoring when character is in a 'resting' area."] = true;
L["Instance Only"] = true;
L["Disable Monitoring when not in an instance."] = true;
L["Cast on self only"] = true;
L["Disables buff casting on players other than yourself. You will still be notified of other players needed buffs but you will have to manually buff them."] = true;
L["Copy Configuration From:"] = true;
L["Select another Activity Context to copy it's configuration into this Activity Context."] = true;
L["Tracking Ability"] = true;
L["Select only one."] = true;

-- Configuration Template
L["Use the field below to apply a preset 'Player Buff Monitoring' configuration for all Activity Contexts."] = true;
L["WARNING: Selecting a Template will erase your current 'Player Buff Monitoring' configuration for ALL Activity Contexts and the selected Talent Spec!"] = true;
L["Select a Template to load for your 'Primary Talent Spec':"] = true;
L["Select a Template to load for your 'Secondary Talent Spec':"] = true;
L["Unholy DPS"] = true;
L["Frost DPS"] = true;
L["Feral"] = true;
L["Not Feral"] = true;
L["Dragonhawk"] = true;
L["Hawk"] = true;
L["Monkey"] = true;
L["Molten Armor"] = true;
L["Mage Armor"] = true;
L["Ice Armor"] = true;
L["Holy"] = true;
L["Retribution"] = true;
L["Protection"] = true;
L["Holy"] = true;
L["Discipline"] = true;
L["Shadow"] = true;
L["Restoration"] = true;
L["Enhancement"] = true;
L["Elemental"] = true;
L["Fel Armor"] = true;
L["Demon Armor"] = true;

-- Weapon Buffs
L["Enable Weapon Buff Monitoring"] = true;
L["Rogue and Shaman classes maintain buffs on their weapons, enable this feature to configure and track weapon buff monitoring."] = true;
L["Weapon Buffs"] = true;
L["Weapon Buff bound to key:"] = true;
L["Change which key to use to buff your weapons."] = true;
L["Configure which buffs you would like to monitor on your weapons."] = true;
L["Main Hand"] = true;
L["Off Hand"] = true;
L["There are no trackable weapon buffs for your character at this time."] = true;
L["%s needs %s on Main Hand Weapon"] = true;
L["%s needs %s on Off Hand Weapon"] = true;

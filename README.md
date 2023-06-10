# About Easy Buff
Easy Buff was originally developed as an ElvUI plugin in Classic WoW to fill the void that SmartBuff used to fill in the old retail days.  EasyBuff lets players configure which buffs to track on themselves and their party/raid members, and a 1-click solution to casting those buffs on everyone.  With the addition of raid-roles and multiple talent specs, EasyBuff has evolved to provide class and role based buff monitoring as well as separate configuration sets for each of your talent specs.

## Features

### General Configuration

#### Early Monitoring

Announce and refresh buffs before they expire.  Early notification means the buff meets one of the following rules:

* Remaining time is 10% or less of the buffs original duration
* Stacking buff has 1/3 or fewer of it's original stacks

#### Auto-remove before self-buff

You cannot overwrite a buff with a weaker/lesser version of the same buff.  When "Early Monitoring" is enabled, this feature will instruct EasyBuff to automatically remove the existing buff on yourself when using EasyBuff to apply a fresh version of the buff.

#### Weapon-buff monitoring

Rogue and Shaman DPS relies heavily on keeping your weapons buffed.  Enabling this feature will instruct EasyBuff to track Buffs on the players Weapons.

#### Announcements

When a buff is missing or expiring, EasyBuff will display a messages for each character/buff that you need to cast.  These announcements can be written to one of your Chat Windows, or a moveable HUD. (Click "Toggle Anchors" at the bottom of the ElvUI Settings screen to see and move the "EasyBuff Announcements" window.)

#### Keybinds
EasyBuff provides three different keybinds for each of the actions it can perform:

* Wanted Buff Casting (default: MOUSEWHEEL-DOWN)
* Unwanted Buff Removal (default: CTRL-MOUSEHWHEEL-DOWN)
* Weapon Buff Casting (default: SHIFT-MOUSEWHEEL-DOWN)
* You can change any/all of these keybinds.

### Activity Context-based Configuration

You may want to apply different buffs when you're playing solo or in a battleground than when you're in a party/raid.  Buff monitoring is no longer global, you now have the ability to define different Buff monitoring options based on your current activity context:

* Solo (not in a group)
* Party
* Raid
* BG (in a Battleground)

### Talent spec based Configuration

Players may have different spells available to them for each Talent Spec, and/or have different buff preferences for each Talent Spec.  You now have the ability to define different Buff monitoring options based on your current Talent Spec:

* Primary
* Secondary

### Role-based Buff Monitoring

Need to keep "Thorns" on only the tank?  With role-based buff monitoring now you can!  In addition to class-based buff monitoring, you can now dive down a level deeper to only monitoring a buff based on a target players Role.  Just click the "Any Role" checkbox for a given class twice, and you'll see a set of role-based checkboxes.
Player buffs are applied with the Cast Wanted Buff keybind.

### Weapon Buff Monitoring

Configure which weapon-buffs to monitor and apply for each Activity, Talent Spec, and Role.  Weapon buffs are applied with the Cast Weapon Buff keybind.

### Tracking Ability Monitoring

Configure which Tracking Ability to monitor and apply for each Activity, Talent Spec, and Role.  Tracking Abilities are applied with the Cast Wanted Buff keybind.

### Unwanted Buff Monitoring

It's rare, but there are scenarios in which the player does not want a given buff cast on them.  You can configure which Unwanted Buffs to track by providing the ID or Name of the Spell you wish to monitor.  Unwanted Buffs are removed with the Remove UnWanted Buff keybind.

## Convenience Features

With the addition of Activity, Talent, and Role based configuration, it can be cumbersome to fully configure EasyBuff.  To save you some time, we've added a few convenience features to quicken the configuration process.

### Quick Setup

At the bottom of the General configuration screen is a Quick Setup section.  We've created a few bare-bones configurations for each Talent Spec of each Class, and you can apply these configurations for your Primary or Secondary Spec configurations with 1-click.

### Copy Configuration

Within each Activity Tab (Solo, Party, Raid, Battleground) is a simple dropdown that will Copy the entire configuration from another Activity into this one.

## Other Features

Within each Activity and Talent Spec configuration are the following options:

### Disable When Resting

If enabled, EasyBuff will not monitor for missing buffs when your character is "resting"

### Instance Only

If enabled, EasyBuff will not monitor for missing buffs unless your character is in an "instance" (Dungeon, Raid, Battleground, etc)

### Cast on self Only

If enabled, EasyBuff will notify you of missing buffs on other players, but your Buff-casting hotkey will not cast buffs on other players.

### Cast Greater Buffs

If enabled, EasyBuff will cast the "Greater" version of a buff if applicable.  For example, cast "Prayer of Fortitude" when a player is missing "Power Word: Fortitude"

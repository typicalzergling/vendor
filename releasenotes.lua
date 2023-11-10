local _, Addon = ...

Addon.ReleaseNotes = {
{
Release = "6.3 (November 6, 2023)",
Notes = [[
# Dragonflight 10.2 Support

This release fixes a few bugs found in the 10.2 Dragonflight client, has some back end
engineering improvements, and mainly delivers the much requested Chat Output feature.

# Chat Output (BETA)

You can now control which messages go to which chat frame. This has been a longtime request and
we've implemented this as a beta feature. To configure chat output, go to Settings and select
"Chat Output". We list your active chat channels and you can select which Vendor messages go
to which chat channels, or turn them all off. It's entirely up to you. This is a beta feature
so there's probably a few bugs with it, please let us know how it is working for you.

# AdiBags Integration (BETA)

Better AdiBags integraation

# Discord Server for Addon Support
We now have a discord server for Vendor where you can come ask us questions and share issues.
* https://discord.gg/BtqVg8KVDg


# Initialization load order changes

These changes are largely transparent to the typical Vendor enjoyer, but we experienced issues
with other addons and load order because we try to be smart and not load things all at once
and have delay loading on several things so your client isn't a slideshow when you log in.
Unfortunately we're one of the only addons who do this and delay load meant some other addons
that we plug into would not see us and get some errors. So we did a rather significant rework
of our intialization and loading code, which is all back end boring stuff for you. However,
what it means is that we may have some bugs lurking there, so please pay attention especially
to interactions with other addons like Adibags or CanIMogIt and lets us know if you have
problems. Feel free to use the above Discord for reporting issues or to ping us there.

# Item List Sort

The list tab now supports chaning the sort order of the items it can be set to etiher 
id, name, or quality.  The choosen sort is saved the profile and used for each list.


# Bugfixes

* Audit frame no longer has large totals truncated.
* Fixed import error in Wrath.
* The documentation for all of the functions has returned

]]
},
{
Release ="6.2 (May 1, 2023)",
Notes = [[
# Dragonflight 10.1 Support

This release only fixes Dragonflight 10.1 Support. Wrath is also supported, though scrollbars
are now rather ugly. This is because Blizzard changed how scrollbars work in 10.1 and have not
ported that change to Wrath.

# Known Issues

* Profiles created with previous version (6.1.3), which was a short release to enable wrath, had
a profile creation bug that may have created profiles with bad data. If you are experiencing
problems with any profiles created, we recommend deleting the affected profile and creating a
new one.
* The lists use item id to identify things to sell/keep, and that means if you put an item with
crafting quality on it in a list, it will match all qualities of that item since they share the
same item id. Use care when adding items that have a crafting quality to lists. We recommend
that you use rules for matching unwanted crafting items, or custom lists (example, make a custom
list, then use a rule with IsInList("mylist") and CraftingQuality < 5, or something similar). As
always, make sure you check the "matches" and check the tooltip over items you expect to sell or
keep after you create or enable a new rule.
]]},
{
Release ="6.1 (November 27, 2022)",
Notes = [[
# Wrath of the Lich King Classic now supported!

We have unified the code and going forward will have a much easier time supporting classic releases
along with retail, and bringing our new retail features into classic wherever possible.

Classic has all the supported features of Retail that are possible (and make sense) on Classic.

We are not maintaining other Classic releases, as we have already released versions of Vendor that
work on those releases, so those should have a working version. Moving forward, we will support the
current classic release and when a new Classic release comes out we will preserve the last best
version for the earlier releases.

The Same Vendor addon works for both Wrath Classic and Retail - you do not need to download separate
versions!


# New "Side-grade or Better" keep rule

A new built-in rule contains a "Side-grade or Better" keep rule that uses the new CurrentEquippedLevel()
function added in 6.0. This is a good sample rule to make sure you don't accidentally vendor or delete
something that is equal or better itemlevel than your currently equipped gear. This works on both
Classic and Retail versions, though the Classic version may match unequippable gear. This rule is
not enabled by default, but is available if you want it.


# Rule and List Context Menu

We've added a right-click menu for the rules lists. Previously right-click would go to
show or edit a rule. Now show/edit is one option but there are several others, including copy and
export! 


# Rule and List Import / Export

We have enabled a means to import and export rules and lists as strings for sharing with other
players. This works pretty much like Weakauras Import/Export. If you use the "export" button in
the rule or list editor you can copy the text and post it on discord or wherever to share your
rule or list with others!  When you import lists and rules they are not enabled by default so there
is no risk to adding them. You have to explicitly go enable a rule and add a rule for a list in the
case of lists.

We do not yet support chat-linking to share rules in-game like Weakauras but it is on our list of future
investments!


# Custom Rule Parameters

Custom Rules can now have Parameters like some of our built-in rules have. This is intended for
convenience so you dont need to change a rule to be useful to different profiles which may desire
slightly different parameters on what is otherwise the exact same rule. The Custom Rule Parameters
are also helpful for the above mentioned Import/Export functionality so people with which you share
your rules don't need to edit the rule settings in order to tweak the rule to do what they want.


# Copy Rules and Lists

You can now copy rules and lists, even default ones! Want to turn your Keep list on a profile into
a custom list so it can be shared across all your profiles? Now you can very easily by copying
the list. Want to modify a built-in rule slightly to your tastes? Easy to do now, just copy it and
the rule dialog comes up and you can save your modification as a new rule. Copying rules also copies
any parameters specified in the rules and their default states.


# Merchant Button is back and working great!

The merchant button, a long requested feature, is now available (again). Like the MiniMap Button,
the merchant button is an account-wide setting so you do not need to set it on every profile. In
addition to being a conveient way to trigger a sell, we also addded a Destroy button next to it for
any destroyable items for convenience. Also the Sell and Destroy buttons themselves have a count of
the number of items currently marked for auto-sell and destroy. If you mouseover the button, the
tooltip will show you exactly what items those are. In the case of the Destroy button, since destroy
is only 1 destroy per hardware event, each time you click the button one item will be destroyed.
The tooltip reflects the next item that will be destroyed when you click, in addition to the other
items also marked for destruction.


# Scanning Throttle Tuning when not-selling/destroying

Tuned the status-scanning throttles and made them far more backed-off. We believe that information about
what Vendor is going to sell is not critical information when you're out and about in the world, it's
just an FYI. We always do an immediate scan when selling or destroying because that is critical
information, but not when you're out gathering or questing or raiding. So we are treating it as
low-priority data that should in no way interfere with your activities or performance. What it does
mean is the minimap button and LibDataBroker consumers like ElvUI and Titan Panel will have delayed
Vendor status information, moreso than already. We still will not do any scanning in combat except
when the merchant window is open. If you feel the freshness is too delayed, let us know. If you
don't even notice until reading this, that's also good feedback that we have struck a good
balance. We are looking into adding an indicator to the tooltip when a refresh is pending but not
yet completed so you at least know that it isn't current.


# All Extensions moved to internal - no more separate folders

To allow us to add more extensions without cluttering up your addons folder, we have moved our extensions internally.
We still support external extensions, but the ones we will be directly contributing will be now built in
and will automatically work when one of the addons that extends it/us is installed. You can safely
delete any lingering Vendor_Extension folders in your Addons folder.

# CanIMogIt Extension Added!

A popular request was more robust transmog tracking, and we now support CanIMogIt. If you have CanIMogIt,
Vendor will have a new rule for you which captures unknown transmogs using the CanIMogIt APIs. There are
also several functions added which directly query the CanIMogIt APIs with which you can make your own
custom rules using CanIMogIt.

# Hidden rule feature being restored soon

We have the Hidden rule feature back, but there were a few significant bugs with it that we want to
iron out before we turn it on. We will release a patch that fixes this feature and...unhides it. :)


# Notable Bugfixes

* The "/vendor keys" command once again opens the Blizzard Keybindings page to Vendor. On Retail you
may need to expand the menu for "Vendor Addon" due to the quirkiness of that UI. On Classic we open
straight to the keybinds just like before.
* The minimap button will now preserve enabled state across reloads and logouts. For real this time!
* Slight tweak to the CurrentEquippedLevel() function to no longer check for Fury specialization and
instead have that functionality for all warriors. This is because 2H weapons will have an empty 2nd
slot if you can't Titan grip and so there's no reason not to check it. You shouldn't notice a difference
here.
* Removed a slight but noticable UI stutter when a background scan completed.


# Known Issues

* There may be bugs with custom parameters, we've had some gnarly UI bugs with it. Please report
what you find, we will fix them as soon as we can.
* You may get a "saved variables" lua error on Wrath Classic. We believe we have a workaround for this, but
if you do encounter it, just reload your UI again and it will go away. Sorry, there's a weird difference
addon load sequence in Wrath not present on Retail.
* If you are using AdiBags and you still have the old Vendor_AdiBags extension folder in your addons
that is enabled, you will get some lua errors coming out of AdiBags because we attempt to register
the extension twice. This is a harmless error and can be ignored, but you can also remove the offending
old Vendor_AdiBags folder. It is no longer needed.
* The Merchant Button does not work with TSM's Merchant UI, and probably others like ElveUI, only the 
default WoW merchant frame. We will address attaching our button frame to their frames in a later
release.
* Classic may have a few bugs. We have disabled Rule Hiding in Wrath due to unexpected behavior and
will re-enable rule hiding on Classic in a subsequent patch to Vendor.


]]},
{
Release ="6.0 (November 15, 2022)",
Notes = [[
# Vendor 6.0!

Another expansion, another major update for Vendor!

# Full 10.0.2 Support, focus on Performance, and Reliability

For us 10.0.2 was not something we scraped together to make it work in time for the expansion.
We've spent a lot of time on beta getting it right. A key focus of this release has been performance.
We don't want our addon to get in the way of your frames or game enjoyment. As such we have optimized
some of the most fundamental parts of the addon, and in many places it has significant rewrites. A key
part of this is making our 'status' updates of what we're going to sell in your bag delayed and happens
more as a background action. 

If you mouseover something or go to a merchant to autosell, the vendor evaluation is it is still immediate
in those scenarios, but when you're out and about, gathering, questing, leveling, etc and looking at the
libdatabroker Titan plugin or the mouseover on the Minimap button to see what Vendor will sell, that information
may be a little delayed by about 8-10 seconds. We don't think you really care whether or not our data
is immediately up to date, but we think you definitely care about an addon not robbing you of frames
or CPU unnecessarily. It can come 10 seconds later without disrupting your play.

As such, our libdatabroker plugin will be a little delayed between the
time you loot and the time it updates. This is not a bug; this is a performance feature! We've found
along the way that many other bag-scanning addons do so immediately and you will see a stutter in your
UI from them. When we turn everything else off, our addon has no such stutter.

Vendor is now also mindful of doing any work while you are in combat. We will not provide tooltip text
additions during combat, and any low-priority refresh of your bag data we are doing to keep the databroker
up to date will be halted immediately upon entering combat, with a delayed restart when you exit
combat. If you happen to use a merchant while in combat we will still do our normal priority scan
for auto-selling, and if you do an item delete hotkey we will do the same with that. Essentially we
will only do work you want us to do while you are in combat, otherwise we will stay out of the way!


# All New UI

As Blizzard keeps changing their UI every expansion and every classic release, we are perpetually
broken by trying to retain the Blizzard theming. So we're abandoning Blizzard UI theming and using
new primitives now that should work on any version. We strongly suspect this is why many popular
addons with configuration options choose to do this rather than adopt Blizzard's UI - they are too
inconsistent and break us too often and too easily to adopt their UI theme, so we will simply stop
trying. Sorry Blizzard, we'd like to keep the theme of your game but we just can't.

The New UI is wider than before, hopefully this will not cause problems for too many folks. We feel
this is necessary to have a better user experience in our addon.

# LibDataBroker & Retired Titan Plugin

We retired the Titan plugin since LibDataBroker support has replaced it. To access Vendor in Titan,
just right click the Titan bar and select the General category -> Vendor to enable it.

Any other consumers of LibDataBroker will also now have a Vendor plugin too, check it out!

# ElvUI DataTexts Support

ElvUI users can also now add a Vendor plugin to "DataTexts" bar at the bottom. In ElvUI options,
go to DataTexts -> Select a Datatext panel -> Select "Vendor" the DataTexts Dropdown menu.

Vendor is all the way at the bottom and not indicated that it is an addon, but it is there and has
the same information as the Titan Plugin.

# Custom Lists

You can now create custom lists and then build rules around your custom item lists. The goal in the
future is to allow sharing and for you to have sell or keep rules which target specific item lists
that you can turn on and off as you desire and give you more granular control over the lists.

An important thing to know about Custom Lists is that they are account-wide, while the normal
Sell/Keep/Destroy lists are profile based. This means you can now have a common list of things you
want to keeps shared across the account (in case you didn't want to use profiles.) To use a custom
list, we have a new rule function 
    
# IsInList() Function

Use this function to use your custom lists in rules. For example, you could make a list of all the
halloween candy item IDs, put them into a custom list named "HalloweenCandy" and then make a
destroy rule for them using: IsInList("HalloweenCandy"). This feature is a little late for
Halloween but it is just in time for all the winter holiday crap. IsInList() also works for the base
Keep, Sell, and Destroy lists, just put "keep", "sell" or "destroy" in for the list name. IsInList
also accepts multiple lists, so you can create rules that merge lists together. 

# New Item Properties

* CraftedQuality - The new quality introduced in Dragonflight for crafted gear and reagents.
* IsProfessionEquipment - Whether the item is the new profession equipment in Dragonflight.

These new properties support the new profession changes in Dragonflight. We will probably add more
here in the future.

# New Rule Functions

* PlayerSpecialization() - Your current spec name
* PlayerSpecializationId() - Numeric representation of your spec
* TotalItemCount() - Total number of the item you have in your inventory, can include bank and
charge/uses as parameters.
* CurrentEquippedLevel() - The item level of your currently equipped gear in that same slot options
as the item being evaluated. If multiple slots it returns the lower of the two equipped items.
* IsInList() - The new list-checking function mentioned above.

Documentation for all of these functions and the older ones is updated in the rule editor "help" tab
in-game!

# Minimap Button Fixed

The Minimap button has been fixed and now has a working toggle setting, which is acount-wide.
Its state and position on the minimap is also saved and is account-wide, so you don't need to set it
on every profile.

Right-clicking on the minimap button will also directly open profiles to make it more convenient
to swap profiles.

# Addon Extension Testing Status

We have tested all our plugins except TradeSkillMaster and AdiBags, which we think probably still
works. Probably.

# Other less interesting stuff

We made our packager strip out all of our debug messages and asserts so they won't even be loaded
into memory or executed, making the release version more lean. We did some significant refactoring
of our code to be more modular in the future. While not a big deal for you it is more memory
efficient this way. We also delay-load most of our features so you will have a very fast load time
with Vendor. Performance!

# Known Issues

* Sort order of rules is not bubbling up selected rules to the top. Elusive bug there preventing
us from enabling sorting.
* Sort order for item properties is also not working correctly, same issue as above.


Blizzard also introduced a lot of changes in this '.2' release. We had to fight through those changes
and squash a lot of random tainting and and similar issues with the API updates. We think we got them
all but please report any you do see and we will investigate.

]]},
{
Release ="5.3 (November 3, 2022)",
Notes = [[
# Dragonflight Pre-Patch Fixes

Blizzard has changed a lot of things in this expansion pre-patch, with more changes coming in the 10.0.2 revision (currently beta). The purpose of this update is to
enable Vendor to work during the pre-patch. It will not be pretty, as we have UI changes designed for the Beta where they have more significant changes that are incompatible
with the live version. So expect us to break again in 10.0.2 because they are changing C_Container and how tooltips work.

# Tabs extend off the side!

Yes, we know the tabs extend off to the side of the frame, its a bug with blizzard changing how frames work again, please bear with it for a few weeks. We didn't want to hold up our release on fixing this, as we have an entirely new UI in Beta and fixing this just for a few weeks in pre-patch is really not worth the time or delaying the update. We do not plan on fixing this for the pre-patch, sorry, please just...ignore it for a short time.

# Merchant Sell/Destroy Buttons

Those who use our addon have long requested a "button" on the merchant to do selling manually, and we have finally added this. The Functionality is new and the settings have not been hooked up in this version properly, but we have added both of them for convenience. In our next update you will be able to enable/disable both of these features. In the mean time please use them and give us feedback. :)

# Transmog Support Altered (may have bugs!)
We have had a bit of a complete rework around the Transmog items and are attempting to capture transmogs you might potentially want. This is particularly relevant
with the new (old?) group loot feature. Instead of scanning for tooltip we are using the Transmog APIs directly, but the transmog APIs are...strange. We think that "not IsCollected" is equivalent to the old "IsUncollectedAppearance" in functionality.
There may be bugs in the transmog feature. If you spot one please report it to us on Curseforge and we will investigate. Please note that Blizzard understands transmogs at the character level and whether a character can use an item seems to affect whether they consider it "collectable". As such it is difficult to identify a transmog item that you haven't collected which this character cannot use.

# IsUncollectedAppearance Removed
This property was removed and the built-in rule updated to use the new properties. You can now use "IsCollected" or the exact equivalent is '(not IsCollected)' if you have a rule that is now broken because of this.
We thought about keeping the other one for compatibility but we didn't want to crap up our properties. We will look at adding hidden equivalence for better back compat in the future. Apologies for this if your rule is now broken. If you used the built in Keep Uncollected Appearances you should be fine.

# Several New Properties

We've added item counts into the properties

* StackCount - Number of current items in this stack. In other words, the current stack size.
* Bag - The current bag number of the item in your inventory (or -1 if it isn't)
* Slot - The current slot number of the item in your inventory (or -1 if it isn't)
* IsCollectable - Is this a collectable appearance?
* IsCollected - Have you collected this appearance?

The intent here is that you can decide to keep any collectable appearance if you so desire so as not to miss out on. Do note that this is CHARACTER based, so if your character cannot equip an item then the appearance will show as not collectable. This is a Blizzard limitation, and we can't do much about it without book keeping every one of your other characters. We feel the best solution here is to add an extension to a popular Transmog addon and leverage their tracking of transmog data for rules. That will come at some point but for now just know that transmog equipment is a bit wonky.

# LibDataBroker Support Added

We added support for LibDataBroker for Vendor, which replaced the Vendor Titan plugin. If you were using Vendor Titan you can go add the new LibDataBroker one thorugh the interface. This will allow us to appear in many other places other than Titan. Since many addons support LibDataBroker you may now find Vendor icon and support in more of your addons! Hopefully this works well enough and we plan on improving this more to the point where it has the old titan plugin functionality (where you right-click and can destroy or change profiles).

# Minimap Button

We've added a minimap button but the setting do disable it is not yet hooked up. Apologies. In our 10.0.2 update you will be able to disable this. It uses LibDataBroker just like the new Titan plugin option.

# Notable Bug Fixes

Too many to name really, we've been doing a lot of reworking and hard to pin down exact bugs fixed along the way.

]]},
{
Release ="5.2 (June 29, 2021)",
Notes = [[
# Classic / TBC Compat updates

It appears as though Blizzard has advanced their Classic and TBC UI to no longer have some 
of the previous incompatibilites. So with some minor adjustments this version of Vendor should now 
work on TBC and Classic

Note: that we have not had heavy use of this version in Classic or TBC, so there may be some bugs still 
lurking. Please report these on the curseforge site for Vendor and we will investigate.

# Systems Improvements

While there are no outward features yet exposed related to improving the systems of Vendor, 
a fair bit has changed, which may mean new unexpected bugs. Features that use some of the new 
improvements will be forthcoming.

# Updated Item Property - IsCraftingReagent

Now uses the GetItemInfo property which tracks this instead of trying to read it from the tooltip

# Notable Bug Fixes

Audit panel will no longer break after 30 days.
]]},

{
Release="5.1 (November 23, 2020",
Notes = [[
# AdiBags Plugin

* one
* two
* three

Similar to the ArkInventory plugin, we now have an AdiBags plugin that adds categories for 
items Vendor will Sell or Destroy to AdiBags.

If you use AdiBags this should Just Work and you should see things starting to get filtered once 
you install this version.

# Audit Tab

All items Vendor sells or destroys in the last 30 days is now tracked and available for viewing in the 
new Audit tab.

If you think Vendor may have sold or destroyed something, check the Audit tab! If you need
to use Blizzard item restoration, this information can be very useful in locating when the item was
sold or destroyed. It will also tell you why it was sold/destroyed and what Vendor Rule was used to make that determination.

There are also new console commands for showing the Vendor History, under "/vendor history". 
You can reset the history for a character or all characters using "/vendor history clear" and "/vendor 
history clear all".

History is automatically pruned to the last 30 days on login, which is the max documented time frame in which an item can be restored by Blizzard item restoration.

# New Built-in Keep Rule - Potential Upgrades

This is a new rule that matches gear that is within 5 levels of the player's average itemlevel or 95% of it, whichever is greater. This is a great new keep rule and now enabled by default for new profiles.
This will ensure things like the pawn "not upgrade" sell rule won't match off-spec gear, or side-grades and other items which you probably don't want to sell and haven't added to an equipment set.

# Unsellable Items added to the Sell list

If you use the hotkey to mouseover and add toggle items on the Sell-list, or drag an unsellable item onto the Sell list, it will instead be placed into the Destroy list. Such items can never be sold so we will try to do the right thing here and put it into the Destroy list. A console message will print when this
happens so you know. We thought this better than giving you annoying pop-ups, but it may seem like the add 'didn't work' - it did, it just went into a different
list. If this proves confusing to users we will improve this experience. Existing unsellable items in the sell list are unchanged - you may have to move these manually.

# New Item Property - IsEquipped

This property matches true only if the item is currently equipped.

# Notable Bug Fixes:

Random Item GUID lua error fixed (thank you fuba82!) 

Pawn extension will no longer scare you by flagging the gear you are wearing as will be sold if it isn't an 'upgrade' per Pawn (It couldn't actually sell the items you are wearing, just to be clear).
Pawn extension will also no longer match unsellable gear for its sell rule.

Rules Help once again shows functions from extensions like TSM and Pawn.

Battle pets dragged into the rule editor's Item Info tab will no longer throw lua errors. We do not yet support Battle Pet properties, but will in the future. For now it won't cause errors.

#  Known Issues

Audit Tab tooltip with audit info is briefly shown, but then removed by ArkInventory. We are investigating this issue further, but it appears to only affect those using ArkInventory.
]]},

{
Release = "5.0 (November 17, 2020)",
Notes = [[
# Profiles

Vendor now supports profiles! When you log in with a character, a profile will be created for that character with previous settings so that character's settings will be as before.
After that you can change profiles for characters, copy profiles, or create new blank profiles as you wish! The Titan Plugin for Vendor also supports rapid profile switching in the
right-click menu on the Vendor Titan button. This makes it easy to swap between profiles that you create for everyday use vs farming old content or leveling, etc.

# New UI

As you've probably noticed, our User Interface has changed significantly. Gone are Scrap Rules and the custom rule definitions and that dangerous "defaults" button. With the addition
of Destroy rules and list, as well as this help panel and profiles panels, we wanted to make the UI more compact scalable. All the rules are in one tab, and all the lists in one tab,
with a selection menu on the left and the list of rules or items on the right. The "Create" button to create new rule has been renamed to "New Rule" and is now in the "Rules" tab.

# Destroy Rules and List

By popular request, we now support Destroy rules and a Destroy list. These are items that will not be sold, but rather will be deleted from your inventory.

We had automatic-destroy
working great whenever you visited a vendor, but with the 9.0.2 patch, Blizzard protected 'DeleteCursorItem()', which means it can only be executed from a hardware event. This means
you MUST press a key in order to destroy items. Fortunately you can still destroy multiple items and there is no confirmation required, so this still saves you a lot of hassle. To facilitate
making the item destruction as easy as possible, we have added a new hotkey to trigger item destruction, added it to our API, and also added it to the Vendor Titan Plugin's Right-Click
menu option under 'Run Destroy'.

We will still attempt to sell items marked for "destroy" if you are at a merchant prior to destroying them. However we do not yet have any
notice or correction if you place an unsellable item into the Sell list - the item will simply not be sold, nor destroyed.

# Updated Vendor Titan Plugin

The Vendor Titan plugin has a few new features, including now showing the exact list of items that will 
be sold by Vendor or deleted by Vendor. In addition, in the right-click menu there is now a
"Set Profile" flyout menu where you can change your profile quickly and easily without having to open 
up the main UX. This makes it easy to have more aggressive profiles for selling and
deleting old content loot and easily switch to and from them when you're doing that content.

# Notable Bug Fixes:

* Display of items in the Matches tab of the edit rule dialog now shows the exact item tooltips as in your 
inventory.
* Changed the hook for tooltip OnHide to a securehook to remove taint possibilities.
]]}

}
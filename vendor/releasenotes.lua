local AddonName, Addon = ...

Addon.ReleaseNotes = {
    {
        release="5.0",
        on="November 17, 2020",
        html=
[[<html>
<body>
<h1>Profiles</h1>
<p>Vendor now supports profiles! When you log in with a character, a profile will be created for that character with previous settings so that character's settings will be as before.
After that you can change profiles for characters, copy profiles, or create new blank profiles as you wish! The Titan Plugin for Vendor also supports rapid profile switching in the
right-click menu on the Vendor Titan button. This makes it easy to swap between profiles that you create for everyday use vs farming old content or leveling, etc.</p>
<br/>
<h1>New UI</h1>
<p>As you've probably noticed, our User Interface has changed significantly. Gone are Scrap Rules and the custom rule definitions and that dangerous "defaults" button. With the addition
of Destroy rules and list, as well as this help panel and profiles panels, we wanted to make the UI more compact scalable. All the rules are in one tab, and all the lists in one tab,
with a selection menu on the left and the list of rules or items on the right. The "Create" button to create new rule has been renamed to "New Rule" and is now in the "Rules" tab.</p>
<br/>
<h1>Destroy Rules and List</h1>
<p>By popular request, we now support Destroy rules and a Destroy list. These are items that will not be sold, but rather will be deleted from your inventory.
<br/><br/>
We had automatic-destroy
working great whenever you visited a vendor, but with the 9.0.2 patch, Blizzard protected 'DeleteCursorItem()', which means it can only be executed from a hardware event. This means
you MUST press a key in order to destroy items. Fortunately you can still destroy multiple items and there is no confirmation required, so this still saves you a lot of hassle. To facilitate
making the item destruction as easy as possible, we have added a new hotkey to trigger item destruction, added it to our API, and also added it to the Vendor Titan Plugin's Right-Click
menu option under 'Run Destroy'.
<br/><br/>
We will still attempt to sell items marked for "destroy" if you are at a merchant prior to destroying them. However we do not yet have any
notice or correction if you place an unsellable item into the Sell list - the item will simply not be sold, nor destroyed.
</p>
<br/>
<h1>Updated Vendor Titan Plugin</h1>
<p>The Vendor Titan plugin has a few new features, including now showing the exact list of items that will be sold by Vendor or deleted by Vendor. In addition, in the right-click menu there is now a
"Set Profile" flyout menu where you can change your profile quickly and easily without having to open up the main UX. This makes it easy to have more aggressive profiles for selling and
deleting old content loot and easily switch to and from them when you're doing that content.
</p>
<br/>
<h1>Notable Bug Fixes:</h1>
<p>Display of items in the Matches tab of the edit rule dialog now shows the exact item tooltips as in your inventory.</p>
<p>Changed the hook for tooltip OnHide to a securehook to remove taint possibilities.</p>
</body>
</html>]]
    },
}
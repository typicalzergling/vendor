local AddonName, Addon = ...

Addon.ReleaseNotes = {
	{
		release="5.0",
		on="November 15, 2020",
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
with a selection menu on the left and the list of rules or items on the right. The "Create" button still creates a new custom rule and is on the main UI page for convenience.</p>
<br/>
<h1>Destroy Rules and List</h1>
<p>By popular request, we now support Destroy rules and a Destroy list. These are items that will not be sold, but rather will be deleted from your inventory. Currently the destroy code
is executed whenever you visit a vendor after selling. We will expand and add new ways to trigger destroy rules, but for now since they are irreversible except for item restoration, we
wanted the trigger point to be very predictable. We will attempt to sell items marked for "destroy" if you are at a merchant prior to destroying them. However we do not yet have any
notice or correction if you place an unsellable item into the Sell list - the item will simply not be sold, nor deleted.
</p>
<br/>
<h1>Updated Vendor Titan Plugin</h1>
<p>The Vendor Titan plugin has a few new features, including now showing the exact list of items that will be sold by Vendor or deleted by Vendor. In addition, in the right-click menu there is now a
"Set Profile" flyout menu where you can change your profile quickly and easily without having to open up the main UX. This makes it easy to have more aggressive profiles for selling and
deleting old content loot and easily switch to and from them when you're doing that content.
</p>
<br/>
<h1>Fixes:</h1>
<p>Fix 1</p>
<p>Fix 2</p>
</body>
</html>]]
	},

	{
		release="4.1",
		on="October 15, 2020",
		html=
[[<html>
<body>
<h1>Titan Panel Plugin</h1>
<p>In Titan panel's <b>General</b> category you will find the Vendor plugin. The Vendor Titan plugin will display stats
and value of the items matching all of your sell rules. In addition, mousing over the Titan button will show a breakdown of
number of items to be sold, to be deleted, and the total sell value. Left-clicking the button will open the Vendor rules panel.
Right-clicking will bring up shortcuts to the rules panel, settings, and keybindings. In the future\
<br/>
</body>
</html>]]
	},	
}
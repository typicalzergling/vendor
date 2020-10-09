# Build instructions.

**The 'release.sh' file is a copy from the [BigWigs packager](https://github.com/BigWigsMods/packager) project. I did not see any license associated with it, so I assume it is OK to include. All credit for that packager goes to them.**

This is an offline builder for building and testing the addon's retail and classic versions as they appear when packaged and downloaded from Curseforge. It does not upload, but feel free to update the script to do that if you like.

1) Rename the .env-rename file to '.env'

2) Update any paths in the .env file for the WoW folder (the default should be correct for most).

3) Download the [Junction tool from Microsoft](https://docs.microsoft.com/en-us/sysinternals/downloads/junction). Put it wherever you want, but make sure the .env path is correct. Recommend putting it in c:\tools

4) You may need to chmod -x <scriptfile.sh> all the script files to make them executable. Don't forget the one in the root folder.

5) To build, open bash (git for windows comes with it), and then in the root folder type "./build.sh" to build retail and classic and junction the results into your addon folder. Use the '-d' option to enable dev mode instead, which will junction the repository directly intead for rapid iteration.


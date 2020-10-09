#!/bin/bash

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"
addons_folder="$WOW_PATH\_classic_\Interface\Addons\\"
addon_path="$addons_folder$ADDON_NAME"
echo "$addon_path"
addon_ark="$ADDON_NAME""_Ark"
addon_path_ark="$addons_folder$addon_ark"
echo "$addon_path_ark"

# Remove the junctions before removing the local folder.
$JUNCTION_TOOL -d "$addon_path"
$JUNCTION_TOOL -d "$addon_path_ark"

# Now recursively delete the old folder.
rm -rf ".release/classic"

# Build the classic addons. We are not publishing. Offline only.
./release.sh -dz -r ../.release/classic -m ./../.pkgmeta-classic

# Set new junctions.
$JUNCTION_TOOL "$addon_path" "classic\\$ADDON_NAME"
$JUNCTION_TOOL "$addon_path_ark" "classic\\$addon_ark"
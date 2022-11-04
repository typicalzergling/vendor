#!/bin/bash

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"
addons_folder="$WOW_PATH\_classic_\Interface\Addons\\"
addon_path="$addons_folder$ADDON_NAME"
echo "$addon_path"
addon_ark="$ADDON_NAME""_Ark"
addon_path_ark="$addons_folder$addon_ark"
echo "$addon_path_ark"
addon_pawn="$ADDON_NAME""_Pawn"
addon_path_pawn="$addons_folder$addon_pawn"
echo "$addon_path_pawn"
addon_tsm="$ADDON_NAME""_TSM"
addon_path_tsm="$addons_folder$addon_tsm"
echo "$addon_path_tsm"

# Remove the junctions before removing the local folder.
$JUNCTION_TOOL -d "$addon_path"
$JUNCTION_TOOL -d "$addon_path_ark"
$JUNCTION_TOOL -d "$addon_path_pawn"
$JUNCTION_TOOL -d "$addon_path_tsm"

# Now recursively delete the old folder.
rm -rf ".release/classic"

# Build the classic addons. We are not publishing. Offline only.
./release.sh -dz -r ../.release/classic -m ./../.pkgmeta-classic -g 1.13.2 -p 297511

# Set new junctions.
$JUNCTION_TOOL "$addon_path" "classic\\$ADDON_NAME"
$JUNCTION_TOOL "$addon_path_ark" "classic\\$addon_ark"
$JUNCTION_TOOL "$addon_path_pawn" "classic\\$addon_pawn"
$JUNCTION_TOOL "$addon_path_tsm" "classic\\$addon_tsm"

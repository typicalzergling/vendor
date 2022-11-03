#!/bin/bash

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"
addons_folder="$WOW_PATH\_retail_\Interface\Addons\\"
addon_path="$addons_folder$ADDON_NAME"
addon_rulepack="$ADDON_NAME""_RulePack"
addon_path_rulepack="$addons_folder$addon_rulepack"
addon_ark="$ADDON_NAME""_Ark"
addon_path_ark="$addons_folder$addon_ark"
addon_adi="$ADDON_NAME""_AdiBags"
addon_path_adi="$addons_folder$addon_adi"
addon_tsm="$ADDON_NAME""_TSM"
addon_path_tsm="$addons_folder$addon_tsm"
addon_pawn="$ADDON_NAME""_Pawn"
addon_path_pawn="$addons_folder$addon_pawn"

# Remove the junctions before removing the local folder.
$JUNCTION_TOOL -d "$addon_path"
$JUNCTION_TOOL -d "$addon_path_rulepack"
$JUNCTION_TOOL -d "$addon_path_ark"
$JUNCTION_TOOL -d "$addon_path_adi"
$JUNCTION_TOOL -d "$addon_path_tsm"
$JUNCTION_TOOL -d "$addon_path_pawn"

# Now recursively delete the old folder.
rm -rf ".release/retail"

# Build the retail addons. We are not publishing. Offline only.
./release.sh -dz -r ../.release/retail -m ./../.pkgmeta

# Set new junctions.
$JUNCTION_TOOL "$addon_path" "retail\\$ADDON_NAME"
$JUNCTION_TOOL "$addon_path_rulepack" "retail\\$addon_rulepack"
$JUNCTION_TOOL "$addon_path_ark" "retail\\$addon_ark"
$JUNCTION_TOOL "$addon_path_adi" "retail\\$addon_adi"
$JUNCTION_TOOL "$addon_path_tsm" "retail\\$addon_tsm"
$JUNCTION_TOOL "$addon_path_pawn" "retail\\$addon_pawn"

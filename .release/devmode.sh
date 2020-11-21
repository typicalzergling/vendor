#!/bin/bash

# This does not build the addon; instead it directly links from the repro to the Addons folder for rapid inner loop testing and access to debug tools.
# This assumes a mapping to the retail folder, not the classic folder.

# This expects a .env file to exist. Rename the .env-rename to .env.

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"
addons_folder="$WOW_PATH\_retail_\Interface\Addons\\"
addon_repo=".\..\\"
addon_ext="$addon_repo""Extensions\\"
addon_path="$addons_folder$ADDON_NAME"

# Rulepack
addon_rulepack="$ADDON_NAME""_RulePack"
addon_path_rulepack="$addons_folder$addon_rulepack"
addon_repo_rulepack="$addon_ext$addon_rulepack"

# Ark
addon_ark="$ADDON_NAME""_Ark"
addon_path_ark="$addons_folder$addon_ark"
addon_repo_ark="$addon_ext$addon_ark"

# AdiBags
addon_adi="$ADDON_NAME""_AdiBags"
addon_path_adi="$addons_folder$addon_adi"
addon_repo_adi="$addon_ext$addon_adi"

# TSM
addon_tsm="$ADDON_NAME""_TSM"
addon_path_tsm="$addons_folder$addon_tsm"
addon_repo_tsm="$addon_ext$addon_tsm"

# Pawn
addon_pawn="$ADDON_NAME""_Pawn"
addon_path_pawn="$addons_folder$addon_pawn"
addon_repo_pawn="$addon_ext$addon_pawn"

addon_titan="$ADDON_NAME""_Titan"
addon_path_titan="$addons_folder$addon_titan"
addon_repo_titan="$addon_ext$addon_titan"


# Remove existing junctions
$JUNCTION_TOOL -d "$addon_path"
$JUNCTION_TOOL -d "$addon_path_rulepack"
$JUNCTION_TOOL -d "$addon_path_ark"
$JUNCTION_TOOL -d "$addon_path_adi"
$JUNCTION_TOOL -d "$addon_path_tsm"
$JUNCTION_TOOL -d "$addon_path_pawn"
$JUNCTION_TOOL -d "$addon_path_titan"

# Set new retail junctions.
$JUNCTION_TOOL "$addon_path" "$addon_repo"
$JUNCTION_TOOL "$addon_path_rulepack" "$addon_repo_rulepack"
$JUNCTION_TOOL "$addon_path_ark" "$addon_repo_ark"
$JUNCTION_TOOL "$addon_path_adi" "$addon_repo_adi"
$JUNCTION_TOOL "$addon_path_tsm" "$addon_repo_tsm"
$JUNCTION_TOOL "$addon_path_pawn" "$addon_repo_pawn"
$JUNCTION_TOOL "$addon_path_titan" "$addon_repo_titan"


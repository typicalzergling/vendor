#!/bin/bash

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"

all_flavors="_retail_ _ptr_ _classic_ _beta_"

flavors=$all_flavors

for root in $flavors
do
    echo ""
    echo "======================"
    echo "Removing Junctions for $root"
    echo "======================"
    addons_folder="$WOW_PATH""\\$root\Interface\Addons\\"    
    echo "Addon Path: "$addons_folder

    addon_path="$addons_folder$ADDON_NAME"

    # Remove existing junction for main addon
    $JUNCTION_TOOL -d -nobanner "$addon_path"

done

# Now recursively delete the old folder.
rm -rf ".release/retail"

# Build the retail addons. We are not publishing. Offline only.
./release.sh -dz -r ../.release/retail -m ./../.pkgmeta

# Set new junctions.
for root in $flavors
do
    echo ""
    echo "======================"
    echo "Adding Junctions for $root"
    echo "======================"
    addons_folder="$WOW_PATH""\\$root\Interface\Addons\\"    
    echo "Addon Path: "$addons_folder

    addon_src="retail\\"
    addon_path="$addons_folder$ADDON_NAME"

    # Replace junction for main addon
    $JUNCTION_TOOL -nobanner "$addon_path" "$addon_src$ADDON_NAME"

done
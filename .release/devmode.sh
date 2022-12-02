#!/bin/bash

# This does not build the addon; instead it directly links from the repro to the Addons folder for rapid inner loop testing and access to debug tools.
# This assumes a mapping to the retail folder, not the classic folder.

# This expects a .env file to exist. Rename the .env-rename to .env.

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"

all_flavors="_retail_ _ptr_ _classic_ _beta_"

flavors=$all_flavors

for root in $flavors
do
    echo ""
    echo "======================"
    echo "Linking for $root"
    echo "======================"
    addons_folder="$WOW_PATH""\\$root\Interface\Addons\\"    
    echo "Addon Path: "$addons_folder

    addon_repo=".\..\\"
    addon_path="$addons_folder$ADDON_NAME"

    # Remove and replace existing junction for main addon
    $JUNCTION_TOOL -d -nobanner "$addon_path"
    $JUNCTION_TOOL -nobanner "$addon_path" "$addon_repo"
done


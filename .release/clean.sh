#!/bin/bash

# This removes hardlinking (undoes dev mode)

# This expects a .env file to exist. Rename the .env-rename to .env.

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"

all_flavors="_retail_ _ptr_ _xptr_ _classic_ _beta_"

flavors=$all_flavors

for root in $flavors
do
    echo ""
    echo "======================"
    echo "Removing for $root"
    echo "======================"
    addons_folder="$WOW_PATH""\\$root\Interface\Addons\\"    
    echo "Addon Path: "$addons_folder

    addon_repo=".\..\\"
    addon_path="$addons_folder$ADDON_NAME"

    # Remove and replace existing junction for main addon
    $JUNCTION_TOOL -d -nobanner "$addon_path"
done


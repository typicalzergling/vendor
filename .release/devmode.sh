#!/bin/bash

# This does not build the addon; instead it directly links from the repro to the Addons folder for rapid inner loop testing and access to debug tools.
# This assumes a mapping to the retail folder, not the classic folder.

# This expects a .env file to exist. Rename the .env-rename to .env.

# Load paths. We assume paths are in the .env file and that this is being executed from the addon's .release folder.
. ".env"

all_flavors="_retail_ _ptr_ _classic_ _beta_"
all_extensions="_RulePack _Ark _AdiBags _TSM _Pawn _OE"

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

    # Do the junctions for all extension addons
    addon_ext="$addon_repo""Extensions\\"
    for extension in $all_extensions
    do
        addon_extension="$ADDON_NAME$extension"
        addon_extensiondest="$addons_folder$addon_extension"
        addon_extensionrepo="$addon_ext$addon_extension"

        # Remove and replace junction
        $JUNCTION_TOOL -d -nobanner "$addon_extensiondest"
        $JUNCTION_TOOL -nobanner "$addon_extensiondest" "$addon_extensionrepo"
    done
done


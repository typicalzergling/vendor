#!/bin/bash
# Builds retail and classic, and then junctions the resulting files from .release to the respective wow folders.
# Paths to the junction tool and WoW folder specified in /.release/.env

# Process command-line options
usage() {
	echo "Usage: build.sh [-d]" >&2
	echo "  -d               Enable Dev mode. Doesn't build, hardlinks directly to retail." >&2
}

exit_code=0
while getopts ":d" opt; do
	case $opt in
	d)
		devmode="true"
		;;
	\?)
		if [ "$OPTARG" != "?" ] && [ "$OPTARG" != "h" ]; then
			echo "Unknown option \"-$OPTARG\"." >&2
		fi
		usage
		exit 1
		;;
	esac
done

if [ $devmode ]; then
    (cd .release; ./devmode.sh)
    echo
    echo "Dev mode enabled."
else
    (cd .release; ./build_retail.sh)
    (cd .release; ./build_classic.sh)
    echo
    echo "Build complete."
fi

exit $exit_code
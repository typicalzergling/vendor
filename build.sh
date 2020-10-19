#!/bin/bash
# Builds retail and classic, and then junctions the resulting files from .release to the respective wow folders.
# Paths to the junction tool and WoW folder specified in /.release/.env

# Process command-line options
usage() {
	echo "Usage: build.sh [-d]" >&2
	echo "  -c               Builds classic only and junctions into classic wow." >&2
	echo "  -d               Enable Dev mode. Doesn't build, junctions directly to retail." >&2
}

exit_code=0
while getopts ":cd" opt; do
	case $opt in
	c)
		classicOnly="true"
		;;
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
	if [ $classicOnly ]; then
		(cd .release; ./build_classic.sh)
	else
		(cd .release; ./build_retail.sh)
		#(cd .release; ./build_classic.sh) # Classic freezing for now.
	fi
    echo
    echo "Build complete."
fi

exit $exit_code
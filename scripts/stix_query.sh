#!/bin/env bash

set -eu

while getopts ":a:p:" opt; do
    case $opt in
        q) queries="$OPTARG"
            ;;
        i) stix_index="$OPTARG"
            ;;
        d) stix_db="$OPTARG"
            ;;
        t) threads="$OPTARG"
           ;;
        \?) "Invalid option -$OPTARG" >&2
            exit 1
            ;;
    esac

    case $OPTARG in
        -*) echo "Option $opt needs a valid argument"
        exit 1
        ;;
    esac
done

# TODO assumes gargs in the PATH, but could provide/download
# the binary instead with the snakemake pipeline.
cat $queries |
gargs -p $threads "echo -e {} && stix -d $stix_db -t {2} -s 500 -i $stix_index -l {0} -r {1}"

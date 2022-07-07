#!/bin/env bash

set -eu

while getopts ":q:p:i:d:t:" opt; do
    case $opt in
        q) queries="$OPTARG"
            ;;
        p) index_path="$OPTARG" # where the index lives
           ;;
        i) stix_index="$OPTARG" # no path, just filename for -i, -d options
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
    gargs -p $threads \
          "cd $index_path &&
           echo -e QUERY REGION: {}     &&
           stix -d $stix_db -t {2} -s 500 -i $stix_index -l {0} -r {1} &&
           echo ========================================================="

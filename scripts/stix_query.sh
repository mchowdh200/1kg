#!/bin/env bash

set -eu

while getopts ":p:d:i:t:l:r:" opt; do
    case $opt in
        p) index_path="$OPTARG"
           ;;
        d) stix_db="$OPTARG"
            ;;
        i) stix_index="$OPTARG"
           ;;
        t) svtype="$OPTARG"
            ;;
        l) left="$OPTARG"
            ;;
        r) right="$OPTARG"
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

hit=$(cd $index_path &&
      stix -d $stix_db -i $stix_index -t $svtype -l $left -r $right |
      tail -n+3 | # chomp the two header lines
      awk '{print $7+$8}' # columns with counts
   )
printf "$left\t$right\t$hit\n"

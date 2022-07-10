#!/bin/env bash

set -eu

print_header="false"
while getopts ":p:d:i:t:l:r:h" opt; do
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
        h) print_header="true"
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

# per sample hits for a given query region
result=$(cd $index_path &&
      stix -s 500 -d $stix_db -i $stix_index -t $svtype -l $left -r $right |
      tail -n+3 # chomp the two header lines
      awk 'BEGIN{OFS="\t"}{print $1,$7+$8}' # sample, paired+splits
      # awk '{s+=$1} END{print s}' # sum
   )

# take the list of samples and make into a single line separated by tab
samples=$(cut -f1 <<<$results | tr '\n' '\t')
hits=$(cut -f2 <<<$results | tr '\n' '\t')
[[ $print_header == true ]] && printf "\t\t\t\t$samples\n"
printf "$left\t$right\t$hits\n"

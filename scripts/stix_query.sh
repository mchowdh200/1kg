#!/bin/env bash

set -e

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
      tail -n+3 | # chomp the two header lines
      awk 'BEGIN{OFS="\t"}{print $2,$7+$8}' # sample, paired+splits
   )

# take the list of samples and make into a single line separated by tab
hits=$(cut -f2 <<<$result | tr '\n' '\t')
if [[ $print_header == "true" ]]; then
    samples=$(cut -f1 <<<$result | tr '\n' '\t')
    printf "\t\t\t\t$samples\n"
fi
printf "$left\t$right\t$hits\n"

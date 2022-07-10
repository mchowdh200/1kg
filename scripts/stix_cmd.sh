
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

# Do the first query with the header then the rest without.
# Yep this is kinda dumb but who cares...
head -1 $queries | gargs -p 1 "bash scripts/stix_query.sh \\
                               -p $index_path \\
                               -d $stix_db \\
                               -i $stix_index \\
                               -t {2} -l {0} -r {1} -h"

cat $queries | gargs -p $threads "bash scripts/stix_query.sh \\
                                  -p $index_path \\
                                  -d $stix_db \\
                                  -i $stix_index \\
                                  -t {2} -l {0} -r {1}"

#!/bin/env bash
bam=$1
fasta=$2
output=$3
excord=$4

# get insert-sizes of first 100k reads, to compute discordant distance
samtools view -f66 -T $fasta $bam | head -100000 |
    awk '{print sqrt($9^2)}' \
    > $bam.insert-sizes.txt
disc_dist=$(python3 scripts/get_disc_distance.py $bam.insert-sizes.txt)

echo "running excord with discordant distance = $disc_dist"
samtools view -b $bam |
    $excord --discordantdistance $disc_dist --fasta $fasta /dev/stdin |
    LC_ALL=C sort --buffer-size 2G -k1,1 -k2,2n -k3,3n |
    bgzip -c > $output

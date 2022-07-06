#!/bin/env bash
# get SVs of desired type and compute allele counts for all
# non ref alleles for each variant.
set -e

vcf=$1
svtype=$2
processes=$3

echo -e '#chr\tstart\tend\tcount:0|1\tcount:1|0\tcount:1|1'
bcftools query \
         -i "SVTYPE=\"$svtype\"" \
         -f '%CHROM\t%POS\t%INFO/END[\t%GT]\n' \
         $vcf |
    sed -e 's/|/\\|/g'| # escape the pipe symbol in genotypes
    gargs -p $processes 'echo -e {} | python get_allele_counts.py'

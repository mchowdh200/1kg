from types import SimpleNamespace
import sys

configfile: 'conf/stix_1kg_dels.smk'
config = SimpleNamespace(**config) # enable dot instead of dict style access

rule ConstructQueries:
    """
    for each line in vcf, take the genomic region and confidence intervals
    to create a stix query stored in a text file
    """
    input: config.vcf
    output: f'{outdir}/queries.txt'
    threads: workflow.cores
    conda: 'envs/bcftools.yaml'
    shell:
        'python scripts/construct_queries.py {input} > {output}'
        
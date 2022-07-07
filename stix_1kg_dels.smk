from types import SimpleNamespace
import sys

configfile: 'conf/stix_1kg_dels.yaml'
config = SimpleNamespace(**config) # enable dot instead of dict style access

rule All:
    input:
        f'{config.outdir}/query_results.txt'

rule ConstructQueries:
    """
    for each line in vcf, take the genomic region and confidence intervals
    to create a stix query stored in a text file
    """
    input: config.vcf
    output: f'{config.outdir}/queries.txt'
    threads: 1
    conda: 'envs/pysam.yaml'
    shell:
        'python scripts/construct_queries.py {input} DEL > {output}'
        

rule StixQuery:
    """
    TODO run on just a handfull of regions before kicking off the full job
    Parse the queries file with gargs to run stix queries in parallel
    """
    input: rules.ConstructQueries.output
    output: f'{config.outdir}/query_results.txt'
    threads: workflow.cores
    shell:
        f"""
        bash scripts/stix_cmd.sh \\
        -q {{input}} \\
        -p {config.stix_index_dir} \\
        -i {config.stix_index} \\
        -d {config.stix_db} \\
        -t {{threads}} \\
        > {{output}}
        """

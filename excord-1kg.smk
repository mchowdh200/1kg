from pathlib import Path
import numpy as np
import pandas as pd

outdir = config['outdir']
fasta = config['fasta']
fai = config['fai']
# TODO get list of crams/crais from the index
# 1. get list of urls
# 2. from urls get the sample name
# 3. create sample name -> url dict
onekg_index = pd.read_csv(
    '1000genomes.low_coverage.GRCh38DH.alignment.index',
    sep='\t', comment='#')
cram_urls = onekg_index.CRAM.to_list()
crai_urls = onekg_index.CRAI.to_list()

sample2url = {
    cram.split('/')[-1].split('.')[0] : (cram, crai)
    for cram, crai in zip(cram_urls, crai_urls)
}

# to get the sample name
# split('/')[-1].split('.')[0]


rule All:
    input:
        expand(f'{outdir}/{{sample}}.excord.bed.gz',
               sample=list(sample2url.keys()))

rule GetCram:
    output:
        cram = temp(f'{outdir}/{{sample}}.cram'),
        crai = temp(f'{outdir}/{{sample}}.cram.crai')

    run:
        cram_url = sample2url[wildcards.sample][0]
        crai_url = sample2url[wildcards.sample][1]
        shell(f'wget -O {output.cram} {cram_url}')
        shell(f'wget -O {output.crai} {crai_url}')

rule GetExcord:
    output:
        excord = f'{outdir}/excord'
    shell:
        """
        wget -O {output.excord} https://github.com/brentp/excord/releases/download/v0.2.2/excord_linux64
        chmod +x {output.excord}
        """

rule RunExcord:
    input:
        fasta = fasta,
        fai = fai,
        excord = rules.GetExcord.output.excord,
    output:
        cram = temp(rules.GetCram.output.cram),
        crai = temp(rules.GetCram.output.crai),
        bed = f'{outdir}/{{sample}}.excord.bed.gz'

    run:
        cram_url = sample2url[wildcards.sample][0]
        crai_url = sample2url[wildcards.sample][1]
        shell(f'wget -O {output.cram} {cram_url}')
        shell(f'wget -O {output.crai} {crai_url}')
        shell('bash scripts/excord_cmd.sh {output.cram} {input.fasta} {output.bed} {input.excord}')

    # shell:
    #     'bash scripts/excord_cmd.sh {input.cram} {input.fasta} {output} {input.excord} &> {log}'

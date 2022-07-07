"""
Construct the -l and -r region strings from the vcf
regions/confidence intervals separated by a tab.
"""
import sys
import pysam

for record in pysam.VariantFile(sys.argv[1], 'r'):
    if (svtype:=record.info['SVTYPE']) != sys.argv[2]: continue
    chrom = record.chrom
    pos = record.pos
    end = record.stop

    ci_pos = record.info.get('CIPOS', (0, 0)) # <= 0
    ci_end = record.info.get('CIEND', (0, 0)) # >= 0

    l = f'{chrom}:{pos+ci_pos[0]}-{pos+ci_pos[1]}'
    r = f'{chrom}:{end+ci_end[0]}-{end+ci_end[1]}'
    print(l, r, svtype, sep='\t')

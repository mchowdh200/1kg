import sys
import pysam

vcf = sys.argv[1]

for record in pysam.VariantFile(vcf, 'r'):
    # TODO no translocations yet
    chrom = record.chrom
    pos = record.pos
    end = record.stop

    # (x, y) where x <= 0, y >= 0
    ci_pos = record.info.get('CIPOS', (0, 0))
    ci_end = record.info.get('CIEND', (0, 0))

    query = '\t'.join(
        map(str, (chrom, pos+ci_pos[0], pos+ci_pos[1],
                    chrom, end+ci_end[0], end+ci_end[1])))
    print(query)

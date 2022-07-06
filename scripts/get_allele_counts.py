"""
Get non-ref allele counts for single variant with format:
chrom    pos    end    gt_0   ...   gt_n (tab separated)
"""
import sys
from collections import Counter

gt_count = Counter()

for line in sys.stdin:
    A = line.rstrip().split()
    print('\t'.join(A[:3]), end='\t')
    for gt in A[3:]:
        gt_count[gt] += 1
    print(gt_count['0|1'], gt_count['1|0'], gt_count['1|0'], sep='\t')

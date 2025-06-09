#!/usr/bin/env python3

import os
import argparse, sys
import pickle as pkl
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from pydeseq2.dds import DeseqDataSet
from pydeseq2.ds import DeseqStats

# 1. Parse arguments

parser = argparse.ArgumentParser(description='DE analysis using pyDESeq2.')

parser.add_argument('-i', '--input', help='Input count matrix path', required=True)
parser.add_argument('-o', '--output', help='Output file name', required=True)
parser.add_argument('-f', '--factor', help='Specify appropriate column of data/phenodata.csv to compare samples', required=True)
parser.add_argument('-t', '--threshold', help='Threshold for gene count filtering', required=False, default=10, type=int)
parser.add_argument('-s', '--post_shrinkage', help='Use this option for post shrinkage to reduce FP and visualize', required=False, default=False, action='store_true')

args = parser.parse_args()


# 2. Load data
# 2.1. Load count matrix and sample info into DataFrame
sample_info = pd.read_csv('./data/chrX_data/geuvadis_phenodata.csv', index_col=0)
counts = pd.read_csv(args.input, index_col=0).T

# 2.2. Filter lowly expressed genes
genes_to_keep = counts.columns[counts.sum(axis=0) > args.threshold]
counts_filtered = counts[genes_to_keep]

# 2.3. Read counts with DeseqDataSet
dds = DeseqDataSet(counts=counts_filtered, clinical=sample_info, design_factors=args.factor, refit_cooks=True, n_cpus=8)

# 3. Fit dispersions and LFCs
dds.deseq2()

# 4. Statistical analysis with DeseqStats class
# 4.1. compute p-values and adjusted p-values(FDRs)
stat_dds = DeseqStats(dds, n_cpus=8)
stat_dds.summary()

# 4.2. post-processing with LFC shrinkage. This step is optional but good for minimizing False Positive and visuzliation.
if args.post_shrinkage:
    stat_dds.lfc_shrink(coeff="condition_chem_vs_batch")

# 4.3. Save result dataframe as deseq2_results.csv
stat_df = stat_dds.results_df
stat_df.to_csv(args.output)
print(f"... Saved pyDEseq2 results to {args.output} ...")
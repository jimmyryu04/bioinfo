#!/usr/bin/env python3

import argparse
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# 1. Parse arguments

parser = argparse.ArgumentParser(description='Draw volcano plot for DE analysis')

parser.add_argument('-i', '--input', help='Input count matrix path', required=True)
parser.add_argument('-o', '--output', help='Output plot name e.g. result/name.png', required=True)
parser.add_argument('-c', '--color', help='Color significant genes in red(adjust p-value < 0.05)', required=False, default=False, action='store_true')
parser.add_argument('-x', '--x_axis', help='Specify x-axis of plot. Choose appropriate column name of pydeseq output file', required=True)
parser.add_argument('-y', '--y_axis', help='Specify y-axis of plot. Choose appropriate column name of pydeseq output file', required=True)
parser.add_argument('-t', '--threshold-padj', help='Threshold of adjusted p-value to color significant genes', required=False, default=0.05, type=float)

args = parser.parse_args()

def color_significant(df, mark = args.color):
    if not mark:
        return 'black'
    cols =[]
    for val in df['padj']:
        if val < args.threshold_padj:
            cols.append('red')
        else:
            cols.append('black')
    return cols

def make_volcano(deseq2_results):
    plt.figure(figsize=(7, 7), dpi=100)
    plt.grid(True)
    plt.scatter(x=deseq2_results[args.x_axis], y= -np.log10(deseq2_results[args.y_axis]), 
                    color=color_significant(deseq2_results, True), s=50, alpha=0.7)
    plt.xlim(-5, 5)
    plt.ylim(-0.1,10.1)
    plt.title('Volcano plot', fontsize=20)
    plt.xlabel(args.x_axis, fontsize=15)
    plt.ylabel('-log10(%s)' % args.y_axis, fontsize=15)
    plt.savefig(args.output)

if __name__ == "__main__":
    deseq2_results = pd.read_csv(args.input, index_col=0)
    make_volcano(deseq2_results)
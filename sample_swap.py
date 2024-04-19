#!/usr/bin/python3

import sys
import argparse
import os
import json
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('pairs', help='path to .pairs.tsv file produced by somalier')
parser.add_argument('benchling', help='path to json file containing benchling data')
parser.add_argument('outpath', help='path to output file')
parser.add_argument('--warn', action='store_true', help='Save a json file (called sample_swap_warning.json) to the same directory as the output file which can alert a watcher')

def save_warning_json(n, outpath, bad_pairs):
    d = {"text": ":rotating_light: We find %s sample pairs that have unexpected relatedness and could be sample swaps.\nProblematic pairs are:\n%s"%(n,bad_pairs)}
    with open(outpath, 'w') as f: 
        json.dump(d, f)
    
if __name__ == '__main__':
    args = parser.parse_args()
    
    # Load benchling data
    if not os.path.exists(args.benchling):
        raise FileNotFoundError(f'Benchling file {ars.benchling} does not exist')
    with open(args.benchling) as f:
        bench = json.load(f)

    # Load somalier pairs data 
    if not os.path.exists(args.pairs):
        raise FileNotFoundError(f'Somalier file {ars.pairs} does not exist')
    pairs = pd.read_csv(args.pairs, sep='\t')

    # Append benchling donor expections onto somalier data
    donor_a_col = []
    donor_b_col = []
    for a, b in zip(pairs['#sample_a'], pairs['sample_b']):
        donor_a = bench.get(a, {}).get('donor_id', None)
        donor_b = bench.get(b, {}).get('donor_id', None)
        donor_a_col.append(donor_a)
        donor_b_col.append(donor_b)
    pairs['donor_a'] = donor_a_col
    pairs['donor_b'] = donor_b_col
    pairs['expected_related'] = pairs['donor_a'] == pairs['donor_b']
    
    # Determine mismatches in relatedness
    pairs['observed_related'] = pairs['relatedness'] > 0.5
    pairs['sample_swap'] = pairs['expected_related'] != pairs['observed_related']

    # Create sample swap report 
    report = pairs[['#sample_a', 'sample_b', 'relatedness', 'donor_a', 'donor_b', 'expected_related', 'observed_related', 'sample_swap']]
    report.columns = ['sample_a', 'sample_b', 'relatedness', 'donor_a', 'donor_b', 'expected_related', 'observed_related', 'sample_swap']
    report = report.sort_values('sample_swap', ascending=False)
    report.to_csv(args.outpath, index=False, sep='\t')

    # Produce warning json
    n_swaps = report.sample_swap.sum()
    if args.warn and n_swaps > 0:
        bad_pairs = report[report['sample_swap'] == True][['sample_a','sample_b','donor_a','donor_b','observed_related','expected_related']].to_string(justify='center',index=False, col_space=15)
        warning_outpath = os.path.join(os.path.dirname(args.outpath), 'sample_swap_warning.json')
        save_warning_json(n_swaps, warning_outpath, bad_pairs)


        





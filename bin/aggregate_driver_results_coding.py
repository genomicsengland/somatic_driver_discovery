#!/usr/bin/env python3

### IMPORT DEPENDENCIES ###

import argparse
import pandas as pd

### MAIN ###

def main(args):

    # Convert each results file to pandas dataframe and harmonise gene_id columns
    dndscv_results = pd.read_csv(args.dndscv, sep='\t', header=0)
    dndscv_results = dndscv_results.rename(columns={"gene_name": "gene"})
    
    mutenricher_results = pd.read_csv(args.mutenricher, sep='\t', header=0)
    mutenricher_results = mutenricher_results.rename(columns={"Gene": "gene"})
    
    oncodrivefml_results = pd.read_csv(args.oncodrivefml, sep='\t', header=0)
    oncodrivefml_results = oncodrivefml_results.rename(columns={"SYMBOL": "gene", "GENE_ID": "gene_id"})
    
    # Merge dataframes
    merged_df = dndscv_results \
                        .merge(mutenricher_results, how='outer', left_on='gene', right_on='gene') \
                        .merge(oncodrivefml_results, how='outer', left_on='gene', right_on='gene') \
                        .sort_values(by=['gene'])
                        
    pval_df = merged_df[['gene', 'gene_id', 'pglobal_cv', 'qglobal_cv', 'Fisher_pval', 'Fisher_FDR', 'P_VALUE', 'Q_VALUE']] \
                .rename(columns={"pglobal_cv": "dndscv_pval", 'qglobal_cv': "dndscv_qval"}) \
                .rename(columns={"Fisher_pval": "mutenricher_fisher_pval", 'Fisher_FDR': "mutenricher_fisher_fdr_pval"}) \
                .rename(columns={"P_VALUE": "oncodrivefml_pval", 'Q_VALUE': "oncodrivefml_qval"})   
    
    # Filter by multi-test corrected pvals
    narrow_results = pval_df[(pval_df['dndscv_qval']<0.05) & (pval_df["mutenricher_fisher_fdr_pval"]<0.05) & (pval_df['oncodrivefml_qval']<0.05)]
    wide_results = pval_df[(pval_df['dndscv_qval']<0.05) | (pval_df["mutenricher_fisher_fdr_pval"]<0.05) | (pval_df['oncodrivefml_qval']<0.05)]
    
    narrow_results.to_csv('coding_narrow_results.tsv', sep='\t')
    wide_results.to_csv('coding_wide_results.tsv', sep='\t')

### RUN WITH ARGS ###

if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(
        prog='aggregate_driver_results.py',
        description='Combine results from dndscv, mutenricher, and oncodrivefml.',
    )
    
    parser.add_argument(
        '--dndscv',
        help='A tab-delimited dndscv results file',
    )
    
    parser.add_argument(
        '--mutenricher',
        help='A tab-delimited mutenricher results file',
    )
    
    parser.add_argument(
        '--oncodrivefml',
        help='A tab-delimited oncodrivefml results file',
    )

    args = parser.parse_args()
    main(args)
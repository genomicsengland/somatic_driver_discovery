#!/usr/bin/env python3

### IMPORT DEPENDENCIES ###

import argparse
import pandas as pd

### MAIN ###

def main(args):

	combined_df = pd.DataFrame()

	if args.dndscv is not None:
		dndscv_results = pd.read_csv(args.dndscv, sep='\t', header=0)
		dndscv_results = dndscv_results.rename(columns={"gene_name": "gene", 'pglobal_cv':'dndscv_pvalue', 'qglobal_cv':'dndscv_qvalue'})
		combined_df = dndscv_results if combined_df.empty else combined_df.merge(dndscv_results, on='gene', how='outer')

	if args.mutenricher is not None:
		mutenricher_results = pd.read_csv(args.mutenricher, sep='\t', header=0)
		mutenricher_results = mutenricher_results.rename(columns={"Gene": "gene", 'Fisher_pval':'mutenricher_fisher_pvalue', 'Fisher_FDR':'mutenricher_fisher_qvalue'})
		combined_df = mutenricher_results if combined_df.empty else combined_df.merge(mutenricher_results, on='gene', how='outer')

	if args.oncodrivefml is not None:
		oncodrivefml_results = pd.read_csv(args.oncodrivefml, sep='\t', header=0)
		oncodrivefml_results = oncodrivefml_results.rename(columns={"SYMBOL": "gene", "GENE_ID": "gene_id", 'P_VALUE':'oncodrivefml_pvalue', 'Q_VALUE': 'oncodrivefml_qvalue'})
		combined_df = oncodrivefml_results if combined_df.empty else combined_df.merge(oncodrivefml_results, on='gene', how='outer')

	pval_df = combined_df[['gene'] + combined_df.filter(regex='pvalue|qvalue').columns.tolist()]
	pval_df.to_csv('combined_significance_results.tsv', sep='\t', index=False)

	qvalue_columns = [col for col in pval_df.columns if 'qvalue' in col]
	narrow_results = pval_df[(pval_df[qvalue_columns] < 0.05).all(axis=1)]
	narrow_results.to_csv('narrow_significant_results.tsv', sep='\t', index=False)

	wide_results = pval_df[(pval_df[qvalue_columns] < 0.05).any(axis=1)]
	wide_results.to_csv('wide_significant_results.tsv', sep='\t', index=False)

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

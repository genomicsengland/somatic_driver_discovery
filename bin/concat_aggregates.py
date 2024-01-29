#!/usr/bin/env python3

import textwrap
import click
from pandas import read_csv, concat


@click.command()
@click.option('--mini_aggs')
@click.option('--symlinked_files')

def combine_aggs(csvs, output):
    # agg mini_aggs
    # big_agg=pd.DataFrame()
    big_agg = concat([read_csv(f) for f in csvs ], ignore_index=True)
    big_agg.to_csv(output, index=False, sep='\t')
    return (big_agg)

def main(
    mini_aggs,
    symlinked_files):
    combine_aggs(mini_aggs, 'full_aggregate.txt')
    combine_aggs(symlinked_files, 'all_symlinked_files.txt')

if __name__ == '__main__':
    main()

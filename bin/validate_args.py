#!/usr/bin/env python3

import textwrap
import click
from pandas import read_csv

@click.command()
@click.option('--variant-type')
@click.option('--sample-file')
@click.option('--region-file')
@click.option('--bed-file')
@click.option('--is-cloud')
# @click.option('--data-release')


def validate_args(
    variant_type,
    region_file,
    sample_file,
    bed_file,
    is_cloud,
    ):
    """
    validate arguments used in the workflow

    Args:
        input_type (str): Either coding or non-coding.
        sample_file (path): Path to table with vcf-paths and sample names.
        is_cloud (bool): Workflow being run on the cloud or on cluster.
    """
    check_variant_type_value(variant_type)
    check_is_cloud_value(is_cloud)
    check_sample_file_provided(sample_file)
    check_region_columns(region_file)
    check_bed_file(bed_file)
    check_chromosome_notation_in_bed(bed_file)
    print('----- Arguments validated -----')


def check_variant_type_value(variant_type):
    """
    Check input_type value is either 'coding' or 'non-coding'
    """
    if variant_type not in ['coding', 'non-coding']:
        error_message = textwrap.dedent(
            """
        Error:
        ! `input_type` must be either 'coding' or 'non-coding'
        """
        )
        print(error_message)
        exit(1)


def check_region_columns(region_file):
    """
    Check input_file for number of columns if bed file is provided
    """

    file_content = read_csv(region_file, sep='\t')
    cols = list(file_content.columns)

    if any([x not in cols for x in ['CHROMOSOME','START','END','SYMBOL']]):
        missing = [
            x for x in ['CHROMOSOME','START','END','SYMBOL'] 
                if x not in cols
                ]
        error_message = textwrap.dedent(
            f"""
        Error:
        ! `region_file` must tab-delimited file containing:
        (CHROMOSOME, START, STOP, SYMBOL).
        The `region_file` provided is missing: {~missing,}.
        Please run the workflow with the appropriate columns in the tab-delimited region file.
        """
        )
        print(error_message)
        exit(1)


def check_bed_file(bed_file):
    """
    Check input_file for number of columns if bed file is provided
    """

    file_content = read_csv(bed_file, sep='\t')
    n_cols = len(file_content.columns)

    if n_cols < 3:
        error_message = textwrap.dedent(
            f"""
        Error:
        ! `input_file` must be a 3-column tab-delimited bed file (chr, start, stop).
        The `input_file` provided has {n_cols} columns.
        Please run the workflow with a 4-column tab-delimited bed file.
        """
        )
        print(error_message)
        exit(1)



def check_chromosome_notation_in_bed(bed_file):
    """
    Check if chromosome notation used in input BED file
    is concordant with specified genome_build.
    """

    with open(bed_file) as bed:
        startwith_chr = [line.startswith('chr') for line in bed]

    if not all(startwith_chr):
        error_message = textwrap.dedent(
            """
        Error:
        ! genome_build `GRCh38` was requested, however, the BED file provided
            contains chromosome names without the prefix `chr`.
        Please add the `chr` prefix to the chromosome names in the BED file and resubmit the workflow.
        """
        )
        print(error_message)
        exit(1)


def check_sample_file_provided(sample_file):
    """
    Check that sample file is provided, and that it contains two columns.
    """
    if not bool(sample_file):
        error_message = textwrap.dedent(
            """
        Error:
        ! `sample_file` must be provided by the user when running the workflow.
        The `sample_file` is a two column tsv file without a header.
        Please provide a `sample_file`.
        """
        )
        print(error_message)
        exit(1)

    samps = read_csv(sample_file)
    if samps.shape[0] != 2:
        error_message = textwrap.dedent(
            """
        Error:
        ! `sample_file` must be provided by the user when running the workflow.
        The `sample_file` is a two column tsv file without a header.
        Please check the shape of `sample_file`.
        """
        )
        print(error_message)
        exit(1)


def check_is_cloud_value(is_cloud):
    """
    Check that is_cloud is either true or false
    """
    if is_cloud not in ['true', 'false']:
        error_message = textwrap.dedent(
            """
        Error:
        ! `is_cloud` must be 'true' or 'false'.
        """
        )
        print(error_message)
        exit(1)


if __name__ == '__main__':
    validate_args()

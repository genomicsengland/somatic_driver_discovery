
import click
@click.command()
@click.option('--')

@click.option('--build')

@click.option('--signature_method')
@click.option('--signature_path')
@click.option('--signature_column_ref')
@click.option('--signature_column_alt')
@click.option('--signature_column_prob')
@click.option('--signature_column_classifier')
@click.option('--signature_include_mnp')
@click.option('--signature_only_mapped')
@click.option('--signature_normalize_by_sites')


@click.option('--score_file')
@click.option('--score_format')
@click.option('--score_column_chr')
@click.option('--score_chr_prefix')
@click.option('--score_column_pos')
@click.option('--score_column_ref')
@click.option('--score_column_alt')
@click.option('--score_column_score')
@click.option('--score_column_element')
@click.option('--score_element_min_stops')
@click.option('--score_mean_stop_function')

@click.option('--statistic_method')
@click.option('--statistic_discard_mnp')
@click.option('--statistic_per_sample_analysis')
@click.option('--statistic_sampling')
@click.option('--statistic_sampling_max')
@click.option('--statistic_sampling_chunk')
@click.option('--statistic_min_obs')
@click.option('--statistic_min_stops')

@click.option('--indels_include')
@click.option('--indels_min_stops')
@click.option('--indels_method')
@click.option('--indels_max_consecutive')
@click.option('--indels_sim_with_signature')
@click.option('--indels_gene_exomic_frameshift_ratio')

@click.option('--settings_core') # remove.




if __name__ == '__main__':
    prase_toml()

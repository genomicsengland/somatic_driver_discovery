#!/usr/bin/env python3

import click
import toml
import os

@click.command()
@click.option('--build', type=str, default='hg38')

@click.option('--signature_method', type=str, default='full')
@click.option('--signature_path', type=str, default=None)
@click.option('--signature_column_ref', type=int, default=None)
@click.option('--signature_column_alt', type=int, default=None)
@click.option('--signature_column_prob', type=int, default=None)
@click.option('--signature_column_classifier', type=int, default=None)
@click.option('--signature_normalize_by_sites', type=str, default = 'whole_genome')

@click.option('--mutability_adjusting', is_flag=True, default=False)  # we have to consider how to deal with these flags.
@click.option('--mutability_file', type=str, default=None)
@click.option('--mutability_format', type=str, default='tabix')
@click.option('--mutability_chr', type=int, default=0)
@click.option('--mutability_chr_prefix', type=str, default='')
@click.option('--mutability_pos', type=int, default=1)
@click.option('--mutability_ref', type=int, default=2)
@click.option('--mutability_alt', type=int, default=3)
@click.option('--mutability_mutab', type=int, default=4)

@click.option('--depth_adjusting', is_flag=True, default=False)
@click.option('--depth_file', type=str, default=None)
@click.option('--depth_format', type=str, default='tabix')
@click.option('--depth_chr', type=int, default=0)
@click.option('--depth_chr_prefix', type=str, default='')
@click.option('--depth_pos', type=int, default=1)
@click.option('--depth_depth', type=int, default=2)

@click.option('--score_file', 
			  type=str,
			  default="/re_scratch/cb_onfml/oncodrivefml_resources/genomicscores/caddpack/1.6-20200324/whole_genome_SNVs.tsv.gz")
@click.option('--score_format', type=str, default='tabix')
@click.option('--score_chr', type=int, default=0)
@click.option('--score_chr_prefix', type=str, default='')
@click.option('--score_pos', type=int, default=1)
@click.option('--score_ref', type=int, default=2)
@click.option('--score_alt', type=int, default=3)
@click.option('--score_score', type=int, default=5)
@click.option('--score_element', type=int, default=None)

@click.option('--statistic_method', type=str, default='amean')
@click.option('--statistic_discard_mnp', is_flag=True, default=False )
@click.option('--statistic_per_sample_analysis', type=str, default=None)
@click.option('--statistic_sampling', type=int, default=100000)
@click.option('--statistic_sampling_max', type=int, default=1000000)
@click.option('--statistic_sampling_chunk', type=int, default=100)
@click.option('--statistic_sampling_min_obs', type=int, default= 10)

@click.option('--indels_include', is_flag=True, default=False)
@click.option('--indels_max_size', type=int, default=20)
@click.option('--indels_method', type=str, default='max')
@click.option('--indels_max_consecutive', type=int, default=7)
@click.option('--indels_gene_exomic_frameshift_ratio', is_flag=True, default=False)
@click.option('--indels_stops_function', type=str, default='mean')
@click.option('--indels_minimum_number_of_stops', type=int, default=None)

@click.option('--settings_core', type=int, default=None)
@click.option('--settings_seed', type=int, default=None)

@click.option(
	'--output', 
	type=str,
	default='./oncodrivefml_v2.conf')

def main(*args, **kwargs):
	print('someother print')
	param_dictionary = ingest_params(kwargs)
	print('Generated TOML configuration:', param_dictionary)

	clean_param_dict = clean_dictionary(param_dictionary)
	print('after_ingest TOML configuration:', clean_param_dict)
	touch(kwargs['output'])
	
	with open(kwargs['output'], 'w') as f:
		new_toml_string = toml.dump(clean_param_dict, f)


def ingest_params(kargs):
	toml_dictionary = {}

	toml_dictionary['genome'] = {'build':kargs['build']}

	toml_dictionary['signature'] = {
		'method':kargs['signature_method'],
		'path':kargs['signature_path'],
		'column_ref':kargs['signature_column_ref'],
		'column_alt':kargs['signature_column_alt'],
		'column_prob':kargs['signature_column_prob'],
		'column_classifier':kargs['signature_column_classifier'],
		'normalize_by_sites':kargs['signature_normalize_by_sites'],
	}

	toml_dictionary['mutability'] = {
		'adjusting':kargs['mutability_adjusting'],
		'file':kargs['mutability_file'],
		'format':kargs['mutability_format'],
		'chr':kargs['mutability_chr'],
		'chr_prefix':kargs['mutability_chr_prefix'],
		'pos':kargs['mutability_pos'],
		'ref':kargs['mutability_ref'],
		'alt':kargs['mutability_alt'],
		'mutab':kargs['mutability_mutab'],
	}

	toml_dictionary['depth'] = {
		'adjusting':kargs['depth_adjusting'],
		'file':kargs['depth_file'],
		'format':kargs['depth_format'],
		'chr':kargs['depth_chr'],
		'chr_prefix':kargs['depth_chr_prefix'],
		'pos':kargs['depth_pos'],
		'depth':kargs['depth_depth'],
	}

	toml_dictionary['score'] = {
		'file':kargs['score_file'],
		'format':kargs['score_format'],
		'chr':kargs['score_chr'],
		'chr_prefix':kargs['score_chr_prefix'],
		'pos':kargs['score_pos'],
		'ref':kargs['score_ref'],
		'alt':kargs['score_alt'],
		'score':kargs['score_score'],
		'element':kargs['score_element'],
	}

	toml_dictionary['statistic'] = {
		'method':kargs['statistic_method'],
		'discard_mnp':kargs['statistic_discard_mnp'],
		'per_sample_analysis':kargs['statistic_per_sample_analysis'],
		'sampling':kargs['statistic_sampling'],
		'sampling_max':kargs['statistic_sampling_max'],
		'sampling_chunk':kargs['statistic_sampling_chunk'],
		'sampling_min_obs':kargs['statistic_sampling_min_obs'],
	}

	toml_dictionary['indels'] = {
		'include':kargs['indels_include'],
		'max_size':kargs['indels_max_size'],
		'method':kargs['indels_method'],
		'max_consecutive':kargs['indels_max_consecutive'],
		'gene_exomic_frameshift_ratio':kargs['indels_gene_exomic_frameshift_ratio'],
		'stops_function':kargs['indels_stops_function'],
		'minimum_number_of_stops':kargs['indels_minimum_number_of_stops']
	}
	toml_dictionary['settings'] = {
		'cores':kargs['settings_core'],
		'seed':kargs['settings_seed'],
	}

	return toml_dictionary


def clean_dictionary(a_dict):
	new_dict = {}
	for k, v in a_dict.items():
		if isinstance(v, dict):
			v = clean_dictionary(v)
		if v is not None:
			new_dict[k] = v
	return new_dict or None

def touch(path):
    with open(path, 'a'):
        os.utime(path, None)


if __name__ == '__main__':

	main()
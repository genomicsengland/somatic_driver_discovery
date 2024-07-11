process INGEST_PARAMS {
    /*
        take oncodrivefml parameters and create TOML file named: oncodrivefml_v2.conf

    */
    // publishDir (
    //     "${params.outdir}",
    //     mode: 'copy',
    // )

    input:
    val(elements)
    val(build)
    val(signature_method)
    val(signature_path)
    val(signature_column_ref)
    val(signature_column_alt)
    val(signature_column_prob)
    val(signature_column_classifier)
    val(signature_normalise_by_sites)
    val(mutability_adjusting)
    val(mutability_path)
    val(mutability_format)
    val(mutability_chr)
    val(mutability_chr_prefix)
    val(mutability_pos)
    val(mutability_ref)
    val(mutability_alt)
    val(mutability_mutab)
    val(depth_adjusting)
    val(depth_file)
    val(depth_format)
    val(depth_chr)
    val(depth_chr_prefix)
    val(depth_pos)
    val(depth_depth)
    val(score_file)
    val(score_format)
    val(score_chr)
    val(score_chr_prefix)
    val(score_pos)
    val(score_ref)
    val(score_alt)
    val(score_score)
    val(score_element)
    val(statistic_method)
    val(statistic_discard_mnp)
    val(statitsic_per_sample_analysis)
    val(statistic_sampling)
    val(statistic_sampling_max)
    val(statistic_sampling_chunk)
    val(statistic_sampling_min_obs)
    val(indels_include)
    val(indels_max_size)
    val(indels_method)
    val(indels_max_consecutive)
    val(indels_gene_exomic_frameshift_ratio)
    val(indels_stops_function)
    val(indels_minimum_number_of_stops)
    val(settings_cores)
    val(settings_seed)


    output:
    path("./oncodrivefml_v2.conf"), emit: oncodrivefml_config

    script:
    """
    set -eoux pipefail

    ingest_ofml_parameters.py \
    --build ${build} \
    --elements ${elements} \
    --build ${build} \
    --signature_method ${signature_method} \
    --signature_path ${signature_path} \
    --signature_column_ref ${signature_column_ref} \
    --signature_column_alt ${signature_column_alt} \
    --signature_column_prob ${signature_column_prob} \
    --signature_column_classifier ${signature_column_classifier} \
    --signature_normalise_by_sites ${signature_normalise_by_sites} \
    --mutability_adjusting ${mutability_adjusting} \
    --mutability_path ${mutability_path} \
    --mutability_format ${mutability_format} \
    --mutability_chr ${mutability_chr} \
    --mutability_chr_prefix ${mutability_chr_prefix} \
    --mutability_pos ${mutability_pos} \
    --mutability_ref ${mutability_ref} \
    --mutability_alt ${mutability_alt} \
    --mutability_mutab ${mutability_mutab} \
    --depth_adjusting ${depth_adjusting} \
    --depth_file ${depth_file} \
    --depth_format ${depth_format} \
    --depth_chr ${depth_chr} \
    --depth_chr_prefix ${depth_chr_prefix} \
    --depth_pos ${depth_pos} \
    --depth_depth ${depth_depth} \
    --score_file ${score_file} \
    --score_format ${score_format} \
    --score_chr ${score_chr} \
    --score_chr_prefix ${score_chr_prefix} \
    --score_pos ${score_pos} \
    --score_ref ${score_ref} \
    --score_alt ${score_alt} \
    --score_score ${score_score} \
    --score_element ${score_element} \
    --statistic_method ${statistic_method} \
    --statistic_discard_mnp ${statistic_discard_mnp} \
    --statitsic_per_sample_analysis ${statitsic_per_sample_analysis} \
    --statistic_sampling ${statistic_sampling} \
    --statistic_sampling_max ${statistic_sampling_max} \
    --statistic_sampling_chunk ${statistic_sampling_chunk} \
    --statistic_sampling_min_obs ${statistic_sampling_min_obs} \
    --indels_include ${indels_include} \
    --indels_max_size ${indels_max_size} \
    --indels_method ${indels_method} \
    --indels_max_consecutive ${indels_max_consecutive} \
    --indels_gene_exomic_frameshift_ratio ${indels_gene_exomic_frameshift_ratio} \
    --indels_stops_function ${indels_stops_function} \
    --indels_minimum_number_of_stops ${indels_minimum_number_of_stops} \
    --settings_cores ${settings_cores} \
    --settings_seed ${settings_seed}

    cat <<-EOF > versions.yml
    "${task.process}":
      python: \$( python --version | head -n1 | cut -d' ' -f2 )
    EOF
    """
}
process INGEST_PARAM {
    /*
        take oncodrivefml parameters and create TOML file named: oncodrivefml_v2.conf

    */
    // publishDir (
    //     "${params.outdir}",
    //     mode: 'copy',
    // )

    input:
    val(build)
    val(signature_method)
    val(signature_path)
    val(signature_column_ref)
    val(signature_column_alt)
    val(signature_column_prob)
    val(signature_column_classifier)
    val(signature_normalise_by_sites)
    val(mutability_adjusting)
    val(mutability_file)
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
    val(statistic_per_sample_analysis)
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

    # Start building the command
    cmd="ofml_parameters.py"

    # Append each parameter only if it's non-empty
    [[ -n "${build}" ]] && cmd+=" --build ${build}"
    [[ -n "${signature_method}" ]] && cmd+=" --signature_method ${signature_method}"
    [[ -n "${signature_path}" ]] && cmd+=" --signature_path ${signature_path}"
    [[ -n "${signature_column_ref}" ]] && cmd+=" --signature_column_ref ${signature_column_ref}"
    [[ -n "${signature_column_alt}" ]] && cmd+=" --signature_column_alt ${signature_column_alt}"
    [[ -n "${signature_column_prob}" ]] && cmd+=" --signature_column_prob ${signature_column_prob}"
    [[ -n "${signature_column_classifier}" ]] && cmd+=" --signature_column_classifier ${signature_column_classifier}"
    [[ -n "${signature_normalise_by_sites}" ]] && cmd+=" --signature_normalise_by_sites ${signature_normalise_by_sites}"
    [[ -n "${mutability_adjusting}" ]] && cmd+=" --mutability_adjusting ${mutability_adjusting}"
    [[ -n "${mutability_file}" ]] && cmd+=" --mutability_file ${mutability_file}"
    [[ -n "${mutability_format}" ]] && cmd+=" --mutability_format ${mutability_format}"
    [[ -n "${mutability_chr}" ]] && cmd+=" --mutability_chr ${mutability_chr}"
    [[ -n "${mutability_chr_prefix}" ]] && cmd+=" --mutability_chr_prefix ${mutability_chr_prefix}"
    [[ -n "${mutability_pos}" ]] && cmd+=" --mutability_pos ${mutability_pos}"
    [[ -n "${mutability_ref}" ]] && cmd+=" --mutability_ref ${mutability_ref}"
    [[ -n "${mutability_alt}" ]] && cmd+=" --mutability_alt ${mutability_alt}"
    [[ -n "${mutability_mutab}" ]] && cmd+=" --mutability_mutab ${mutability_mutab}"
    [[ -n "${depth_adjusting}" ]] && cmd+=" --depth_adjusting ${depth_adjusting}"
    [[ -n "${depth_file}" ]] && cmd+=" --depth_file ${depth_file}"
    [[ -n "${depth_format}" ]] && cmd+=" --depth_format ${depth_format}"
    [[ -n "${depth_chr}" ]] && cmd+=" --depth_chr ${depth_chr}"
    [[ -n "${depth_chr_prefix}" ]] && cmd+=" --depth_chr_prefix ${depth_chr_prefix}"
    [[ -n "${depth_pos}" ]] && cmd+=" --depth_pos ${depth_pos}"
    [[ -n "${depth_depth}" ]] && cmd+=" --depth_depth ${depth_depth}"
    [[ -n "${score_file}" ]] && cmd+=" --score_file ${score_file}"
    [[ -n "${score_format}" ]] && cmd+=" --score_format ${score_format}"
    [[ -n "${score_chr}" ]] && cmd+=" --score_chr ${score_chr}"
    [[ -n "${score_chr_prefix}" ]] && cmd+=" --score_chr_prefix ${score_chr_prefix}"
    [[ -n "${score_pos}" ]] && cmd+=" --score_pos ${score_pos}"
    [[ -n "${score_ref}" ]] && cmd+=" --score_ref ${score_ref}"
    [[ -n "${score_alt}" ]] && cmd+=" --score_alt ${score_alt}"
    [[ -n "${score_score}" ]] && cmd+=" --score_score ${score_score}"
    [[ -n "${score_element}" ]] && cmd+=" --score_element ${score_element}"
    [[ -n "${statistic_method}" ]] && cmd+=" --statistic_method ${statistic_method}"
    [[ -n "${statistic_discard_mnp}" ]] && cmd+=" --statistic_discard_mnp ${statistic_discard_mnp}"
    [[ -n "${statistic_per_sample_analysis}" ]] && cmd+=" --statistic_per_sample_analysis ${statistic_per_sample_analysis}"
    [[ -n "${statistic_sampling}" ]] && cmd+=" --statistic_sampling ${statistic_sampling}"
    [[ -n "${statistic_sampling_max}" ]] && cmd+=" --statistic_sampling_max ${statistic_sampling_max}"
    [[ -n "${statistic_sampling_chunk}" ]] && cmd+=" --statistic_sampling_chunk ${statistic_sampling_chunk}"
    [[ -n "${statistic_sampling_min_obs}" ]] && cmd+=" --statistic_sampling_min_obs ${statistic_sampling_min_obs}"
    [[ -n "${indels_include}" ]] && cmd+=" --indels_include ${indels_include}"
    [[ -n "${indels_max_size}" ]] && cmd+=" --indels_max_size ${indels_max_size}"
    [[ -n "${indels_method}" ]] && cmd+=" --indels_method ${indels_method}"
    [[ -n "${indels_max_consecutive}" ]] && cmd+=" --indels_max_consecutive ${indels_max_consecutive}"
    [[ -n "${indels_gene_exomic_frameshift_ratio}" ]] && cmd+=" --indels_gene_exomic_frameshift_ratio ${indels_gene_exomic_frameshift_ratio}"
    [[ -n "${indels_stops_function}" ]] && cmd+=" --indels_stops_function ${indels_stops_function}"
    [[ -n "${indels_minimum_number_of_stops}" ]] && cmd+=" --indels_minimum_number_of_stops ${indels_minimum_number_of_stops}"
    [[ -n "${settings_cores}" ]] && cmd+=" --settings_cores ${settings_cores}"
    [[ -n "${settings_seed}" ]] && cmd+=" --settings_seed ${settings_seed}"

    \$cmd

    cat <<-EOF > versions.yml
    "${task.process}":
      python: \$( python --version | head -n1 | cut -d' ' -f2 )
    EOF
    """
}
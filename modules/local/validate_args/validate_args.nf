process VALIDATE_ARGS {
    /*
    Check the validity of parameter arguments
    */
    def s = params.sample_file == null ? "No input file. Default LabKey query" : params.sample_file
    def q = params.input_type == 'gene' ? 'gene' : 'region'
    tag "${q} file: ${input_file}, sample file: ${s}"

    input:
    val(variant_type)
    path(sample_file)
    path(region_file)
    val(is_cloud)
    // val(data_release)


    output:
    path "versions.yml", emit : ch_versions_validate_args

    script:
    """
    set -eoux pipefail

    validate_args.py \
    --variant-type ${variant_type} \
    --region-file ${region_file} \
    --sample-file ${sample_file} \
    --is-cloud ${is_cloud} 


    cat <<-EOF > versions.yml
    "${task.process}":
      python: \$( python --version | head -n1 | cut -d' ' -f2 )
    EOF
    """
}


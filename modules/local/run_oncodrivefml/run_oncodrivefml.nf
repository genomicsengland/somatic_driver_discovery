process RUN_ONCODRIVEFML {
    /*
        Run oncodriveFML, either looking at coding or non-coding variants.
    */
    
    publishDir (
        "${params.outdir}",
        mode: 'copy',
    )

    input:
    path(aggregate)
	val(region_file)

    output:
    path("oncodrivefml/*oncodrivefml.tsv.gz"), emit: onco_enrichments
    path("oncodrivefml/*oncodrivefml.png"), emit: onco_figure
    path("oncodrivefml/*oncodrivefml.html"), emit: onco_html

    script:
    """
    set -eoux pipefail

    export BGDATA_LOCAL=/re_scratch/cb_onfml/oncodrivefml_resources/
    export BGDATA_OFFLINE=YES
    export BGDATA_TAG=latest
    export JOB_SPOOL_DIR=/re_scratch/cb_onfml/.lsbatch
    export LANG=C.UTF-8
    
    # we can change the coding/non-coding function by changing -e.


    # mane at : /public_data_resources/ensembl_cds/MANE/v1.0/MANE.GRCh38.v1.0.ensembl_genomic.gtf.gz
    # oncodrive resources at: /public_data_resources/oncodrivefml_resources
    # /public_data_resources/oncodrivefml_resources/genomicscores/caddpack/1.0-20170217/

    oncodrivefml \
    -i ${aggregate} \
    -o oncodrivefml/ \
    -e ${region_file} \
    -c ${projectDir}/resources/oncodrivefml/oncodrivefml_v2.conf


    cat <<-EOF > versions.yml
    "${task.process}":
      python: \$( python --version | head -n1 | cut -d' ' -f2 )
    EOF
    """
}
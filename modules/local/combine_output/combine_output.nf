process COMBINE_OUTPUT_CODING {

    publishDir (
            "${params.outdir}",
            mode: "copy",
            saveAs: { file -> 'combined_results/' + file }
    )

    input:
    path(me_fisher_enrichments)
    path(onco_enrichments)
    path(dndscv_enrichments)

    output:
    path('narrow_significant_results.tsv')
    path('wide_significant_results.tsv')
    path('combined_significance_results.tsv')

    script:
    def args = []
    if (dndscv_enrichments) args << "--dndscv ${dndscv_enrichments}"
    if (me_fisher_enrichments) args << "--mutenricher ${me_fisher_enrichments}"
    if (onco_enrichments) args << "--oncodrivefml ${onco_enrichments}"
    """
    echo ${args}
    aggregate_driver_results_coding.py ${args.join(' ')}
    """
}

process COMBINE_OUTPUT_NONCODING {

    publishDir (
            "${params.outdir}",
            mode: "copy",
            saveAs: { file -> 'combined_results/' + file }
    )

    input:
    path(me_fisher_enrichments)
    path(onco_enrichments)

    output:
    path('noncoding_narrow_results.tsv')
    path('noncoding_wide_results.tsv')
    path('noncoding_complete_results.tsv')

    script:
    """
    aggregate_driver_results_noncoding.py \
        --mutenricher ${me_fisher_enrichments} \
        --oncodrivefml ${onco_enrichments}
    """
}

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
    path('coding_narrow_results.tsv')
    path('coding_wide_results.tsv')

    script:
    """
    aggregate_driver_results_coding.py \
        --dndscv ${dndscv_enrichments} \
        --mutenricher ${me_fisher_enrichments} \
        --oncodrivefml ${onco_enrichments}
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

    script:
    """
    aggregate_driver_results_noncoding.py \
        --mutenricher ${me_fisher_enrichments} \
        --oncodrivefml ${onco_enrichments}
    """
}

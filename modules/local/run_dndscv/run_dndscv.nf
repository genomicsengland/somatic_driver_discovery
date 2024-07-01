process RUN_DNDSCV {
    /*
        per chunk: aggregate variants to use in oncodrivefml and dndscv.

    */
    publishDir (
        "${params.outdir}",
        mode: 'copy',
    )

    input:
    path(aggregate)
    val(refdb)
    val(dndscv_gene_list)
    val(sm)
    val(kc)
    val(cv)
    val(max_muts_per_gene_per_sample)
    val(max_coding_muts_per_sample)
    val(use_indel_sites)
    val(min_indels)
    val(maxcovs)
    val(constrain_wnon_wspl)
    val(name)
    val(outp)
    val(numcode)
    val(mingenecovs)

    output:
    path("./dndscv/dndscv"), emit: dndscv_enrichments

    script:
    """
    set -eoux pipefail
   mkdir ./dndscv

    Rscript /usr/src/app/run_dndscv.R \
    --varagg ${aggregate} \
    ${dndscv_gene_list} \
    --ref ${refdb} \
    --subm ${sm} \
    ${kc} \
    --covariates ${cv} \
    --maxmuts ${max_muts_per_gene_per_sample} \
    --tmbmax ${max_coding_muts_per_sample} \
    ${use_indel_sites} \
    --mindels ${min_indels} \
    --amaxcov ${maxcovs} \
    ${constrain_wnon_wspl} \
    --loc_sv_type ${outp} \
    --gennum ${numcode} \
    --mingenecovs ${mingenecovs} \
    --out ./dndscv

    cat <<-EOF > versions.yml
    "${task.process}":
      R: \$( R --version | head -n1 | cut -d' ' -f3 )
    EOF
    """
}
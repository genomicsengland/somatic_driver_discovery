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

    output:
    path("./dndscv/dndscv"), emit: dndscv_enrichments

    script:
    """
    set -eoux pipefail
   mkdir ./dndscv

    Rscript /usr/src/app/run_dndscv.R \
    --ref /usr/src/app/data/RefCDS_human_GRCh38_GencodeV18_recommended.rda \
    --varagg "${aggregate}" \
    --out ./dndscv \
    --subm 192r_3w \
    --known_cancer_genes NULL \
    --covariates covariates_hg19_hg38_epigenome_pcawg.rda \
    --name dndscv \
    --indels \
    --maxmuts 3 \
    --tmbmax 5000 \
    --wnon_constrain



    cat <<-EOF > versions.yml
    "${task.process}":
      R: \$( R --version | head -n1 | cut -d' ' -f3 )
    EOF
    """
}
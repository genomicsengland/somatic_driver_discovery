process RUN_MUTENRICHER {
    /*
        Run Mutenricher, evaluate somatic hotspots of variants in the cohort.

    */
    publishDir (
        "${params.outdir}",
        mode: 'copy',
    )

    input:
    path(symlinked_files)
	val(variant_type)
    val(anno_type)
    val(gtf_gene_model_info)
    val(gene_list)
    val(covariates_file)
    val(weights)
    val(stat_type)
    val(background_mut_calc)
    val(min_clust_size)
    val(ap_iters)
    val(ap_convits)
    val(ap_algorithm)
    val(hotspot_distance)
    val(min_hs_vars)
    val(min_hs_samps)
    val(snps_only)
    val(blacklist)
    val(prefix)

    output:
    path("./mutenricher/test_gene_enrichments.txt"), emit: me_enrichments
	path("./mutenricher/test_gene_hotspot_Fisher_enrichments.txt"), emit: me_fisher_enrichments
	path("./mutenricher/test_hotspot.txt"), emit: me_hotspot

    script:
    """
    set -eoux pipefail

	python /usr/src/app/MutEnricher/mutEnricher.py ${variant_type} \
        ${gtf_gene_model_info} \
        ${symlinked_files} \
        ${background_mut_calc} \
        ${gene_list} \
        ${covariates_file} \
        ${weights} \
        ${blacklist} \
        --anno-type ${anno_type} \
        --stat-type ${stat_type} \
        --min-clust-size ${min_clust_size} \
        --ap-iters ${ap_iters} \
        --ap-convits ${ap_convits} \
        --ap-algorithm ${ap_algorithm} \
        --hotspot-distance ${hotspot_distance} \
        --min-hs-vars ${min_hs_vars} \
        --min-hs-samps ${min_hs_samps} \
        --snps-only ${snps_only} \
        --prefix ${prefix} \
        --gene-field gene_name \
        -o ./mutenricher

    cat <<-EOF > versions.yml
    "${task.process}":
		python: \$( python --version | head -n1 | cut -d' ' -f2 )
	EOF
    """
}
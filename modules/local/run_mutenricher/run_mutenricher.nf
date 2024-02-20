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

    output:
    path("./mutenricher/test_gene_enrichments.txt"), emit: me_enrichments
	path("./mutenricher/test_gene_hotspot_Fisher_enrichments.txt"), emit: me_fisher_enrichments
	path("./mutenricher/test_hotspot.txt"), emit: me_hotspot

    script:
    """
    set -eoux pipefail

	python /usr/src/app/MutEnricher/mutEnricher.py ${variant_type} \
	/mnt/v1.0/MANE.GRCh38.v1.0.ensembl_genomic.gtf.gz \
	${symlinked_files} \
	-o ./mutenricher \
	--prefix test \
	--anno-type cellbase \
	--use-local \
	--gene-field gene_name


    cat <<-EOF > versions.yml
    "${task.process}":
		python: \$( python --version | head -n1 | cut -d' ' -f2 )
	EOF
    """
}
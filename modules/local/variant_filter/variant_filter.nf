process VARIANT_FILTER {
    /*
        per chunk: select variants per chunk (creating mini-aggregates) to use in oncodrivefml and dndscv.

    */
    input:
    val(bed_file)
    path(symlinked_path)

    output:
    path("mini_aggregate_*.txt"), emit: mini_aggregates

    script:
    """
    set -eoux pipefail

    mini_aggregate.sh \
    --inputvcfs ${symlinked_path} \
    --chunkid "${task.index}" \
    --bedfile ${bed_file}
    
    cat <<-EOF > versions.yml
    "${task.process}":
      bcftools: \$(/bcftools/bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .\$//')
    EOF
    """
}
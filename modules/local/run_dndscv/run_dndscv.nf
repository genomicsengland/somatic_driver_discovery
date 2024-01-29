process RUN_DNDSCV {
    /*
        per chunk: aggregate variants to use in oncodrivefml and dndscv.

    */
    input:
    path(symlinked_files)
    path(mini_aggregates)

    output:
    path("full_aggregate.txt"), emit: full_aggregate
    path("all_sylinked_files.txt"), emit: all_symlinks

    script:
    """
    set -eoux pipefail
    # TAKE MINI-AGGREGATES AS INPUT AND COMBINE.

    concat_aggregates.py \
    --mini_aggs ${mini_aggregates} \
    --symlink_files ${symlinked_files}


    cat <<-EOF > versions.yml
    "${task.process}":
      python: \$( python --version | head -n1 | cut -d' ' -f2 )
    EOF
    """
}
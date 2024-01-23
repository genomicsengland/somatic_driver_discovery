process INDEX_VCFS {
    /*
    create a symlink on the vcfs, and index the vcf to improve filtering and aggregation.
    */

    // work {
    //     // Define the temporary directory path
    //     temp = "${params.tmpDir}"
    //     Channel.value(symlink_tmp_dir).set  { "${params.tmpdir}/${runId}/symlink_tmp" }
    // }
    input:
    val chunk

    output:
    path("symlink_filelist_*"), emit: symlinked_files
    path "versions.yml", emit : ch_versions_query_cnv
    
    // workDir "${params.tmpDir}/${runId}/"

    // is the swap to the workdir required if we already specified it above?
    // symlink to temp directory
    // create index of the symlinked file
    script:
    """
    set -eoux pipefail

    work_dir=/pgen_int_work/BRS/cancer_dev/discovery/testing/scratch/
    mkdir -p \${work_dir}
    echo -e '\${work_dir}'


    while IFS='|' read -r file_path sample_name
    do
        echo "${task.index} Processing: \$file_path with sample: \$sample_name"

        index_sl.sh \
        --vcf \$file_path \
        --samplename \$sample_name \
        --symdir \${work_dir} \
        --chunkid "${task.index}"

    done < <(echo -e "${chunk}")
    
    cat <<-EOF > versions.yml
    "${task.process}":
      bcftools: \$(/bcftools/bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .\$//')
    EOF
    """
}
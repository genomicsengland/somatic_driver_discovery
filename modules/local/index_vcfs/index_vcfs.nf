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
    tuple val(sample_path), val(sample_name) from ch_sample_file

    output:
    file "symlinked_files/*" into symlinked_files
    // do we need this? the index should just be in the same dir. But we aren't touching it. 
    
    workDir "${params.tmpDir}/${runId}/"

    // is the swap to the workdir required if we already specified it above?
    // symlink to temp directory
    // create index of the symlinked file
    script:
    """
    work_dir="${params.tmpDir}/${runId}/"
    mkdir -p ${work_dir}
    # Change into the work directory
    cd $work_dir
    
    # Extracting the filename without the path
    filename=$(basename "$sample_path")

    # Create symlink in the work directory
    ln -s $sample_path $filename

    bcftools index -t $filename
    """

}
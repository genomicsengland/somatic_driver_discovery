process INGEST_SAMPLEFILE {
    /*
    read the sample_file wich contains 2 columns: sample paths and sample namees. 
    return ch_samples which contains the information of both.
    */

    input:
    val(sample_file)

    output:
    tuple val(file_path), val(sample_name) into ch_samples
    
    script:
    """
    cat ${sample_file} | while read -r line; do
        file_path=$(echo $line | cut -f1)
        sample_name=$(echo $line | cut -f2)
        echo "$file_path\t$sample_name"
    done
    """
}
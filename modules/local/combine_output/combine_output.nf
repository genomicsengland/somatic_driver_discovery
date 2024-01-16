process COMBINE_OUTPUT {
    /*
        aggregate variants to use in oncodrivefml and dndscv.
    */

    // take the symlinked vcf from the previous process
    input:
    file(symlinked_path), val(sample_name) from symlinked_files

    output:


    script:
}
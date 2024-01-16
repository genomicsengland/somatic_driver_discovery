process AGGREGATE_INPUT {
    /*
        aggregate variants to use in oncodrivefml and dndscv.
    */

    // take the symlinked vcf from the previous process
    input:
    file(symlinked_path), val(sample_name) from symlinked_files

    output:


    script:
    """

    aggregatedir=/re_scratch/cb_ind/aggregates/
    mkdir -p ${aggregatedir}
    aggregatefile=${aggregatedir}/aggregate_${runId}.txt

    # no need as we already have an array with paths.

    # if our aggregate file does not exist, create it and add the required header.
    if [ ! -f "${aggregatefile}" ]; then
        echo -e "CHROM\tPOS\tREF\tALT\tSAMPLE" | cat - /re_scratch/cb_ind/tmp/file.txt > ${aggregatefile}
    fi

    ## Aggregate variants ##
    # the VCFs we are utulising do not have a lot of annotation applied though. Perhaps Ronnies efforts can expand here.

    # we don't have to loop as we aren't going in chunks.
    bcftools query -e 'FILTER="PASS"' \
    -R /pgen_int_work/BRS/christian/investigate/containers/oncodrivefml/in/hg38.bed \
    -f "%CHROM\t%POS\t%REF\t%ALT\t\${sample_name}\n" \$symlinked_path >> ${aggregatefile}

    # how do we send the aggregate file to the output?
    echo FINISHED AGGREGATE
    """
}
process AGGREGATE_INPUT {
    /*
        aggregate variants to use in oncodrivefml and dndscv.
    */

    // take the symlinked vcf from the previous process
    input:

    output:


    script:
    """

    aggregatedir=/re_scratch/cb_ind/aggregates/
    mkdir -p ${aggregatedir}
    aggregatefile=${aggregatedir}/aggregate_${runname}.txt
    
    """
}
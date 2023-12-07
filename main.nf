#!/usr/bin/env/ nextflow

nextflow.enable.dsl=2

def helpMessage() {
    println(
        """
        DESCRIPTION

        The somatic driver discovery workflow looks for somatic mutations that may drive the cancer phenotype from a collection of somatic variants. It applies and ultimately combines the output of several tools reflecting different stratigies: 
        
        1. OncodriveFML - selectes candidate driver genes based on the functional impact score.
        2. MutEnricher - selects candidate driver genes based on frequency of variants compared to the background mutation rate.
        3. dndsCV - selects candidate driver genes based on positive evolutionary pressure from the ratio of synonymous / non-synonymous variants in a region.

        USAGE

        bsub < submit.sh

        PARAMETERS

        Sample parameters:
        --input_file : a tab deliminted list with 2 columns, a path to the vcf and a tumour_clinical_sample name.
        
        Query type parameters
        --variant_type : determines if 'non-coding', 'coding' or 'both' variants should be queried. Defaults to 'coding'
        --region_file : a path to a headless four-column tab-delimited bed file (chr, start, stop, name) of query regions.
        """
    )
}


params.help = false
if (params.help){
    helpMessage()
    System.exit(0)
}



include { SOMATIC_DISCOVERY } from "./workflows/somatic_discovery.nf"
workflow {
    SOMATIC_DISCOVERY
}

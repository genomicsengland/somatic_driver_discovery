nextflow.enable.dsl=2

def sample_file = params.sample_file == null ? "No user-specified sample file." : params.sample_file

log.info """\

    S O M A T I C  D I S C O V E R Y
    ==================================
    pipeline version : 0.1
    data release     : ${params.data_version}
    sample file      : ${sample_file}
    variant type     : ${params.variant_type}
    output directory : ${params.outdir}
    command          : ${workflow.commandLine}


    """.stripIndent()


Channel.value(params.data_version).set { ch_data_version }

matcher = (params.data_version =~ /v(.+?)_/)
if (matcher.find()) {
    data_release = matcher.group(1)
}

Channel.value(data_release).set { ch_data_release }
Channel.value(params.variant_type).set { ch_variant_type }
Channel.value(params.is_cloud).set { ch_is_cloud }

Channel.value(params.region_file).set { ch_region_file }
ch_region_file = params.variant_type == 'coding' ? params.coding_file : params.non_coding_file
// ch_sample_file = params.sample_file ? Channel.fromFilePairs(params.sample_file, tuple(2)) : Channel.empty()



include { INGEST_SAMPLEFILE } from "../modules/local/ingest_samplefile/ingest_samplefile.nf"
include { VALIDATE_ARGS } from "../modules/local/validate_args/validate_args.nf"
include { INDEX_VCFS } from "../modules/local/index_vcfs/index_vcfs.nf"
// include { VARIANT_FILTER } from "../modules/local/variant_filter/variant_filter.nf"
include { AGGREGATE_INPUT } from "../modules/local/aggregate_input/aggregate_input.nf"
// include { RUN_TOOLS } from "../modules/local/run_tools/run_tools.nf"
// include { COMBINE_OUTPUT} from "../modules/local/combine_output/combine_output.nf"

workflow SOMATIC_DISCOVERY {
   

    // Print the value of a parameter
    println("Sample file parameter: ${params.sample_file}")

    // Assuming you have a variable 'sample_file'
    println("Sample file variable: ${sample_file}")

    // check if the paths and files are correctly provided.
    VALIDATE_ARGS(
        ch_variant_type,
        sample_file,
        ch_region_file,
        ch_is_cloud
    )
    log.info "Completed validation of arguments."


    
    // ingest the sample file.
        ch_samples = Channel
        .fromPath( ch_sample_file )
        .splitCsv(sep: '\t', header: false)
        .map { row -> tuple(row[0], row[1]) }
    // ch_samples = INGEST_SAMPLEFILE.out.ch_samples
    // Apply view for debugging
    ch_samples.view { item ->
        println("Sample item: $item")
    }
    log.info "Completed ingesting samples."

    grouped_samples = ch_samples.buffer(size: 50) // Group the ch_sample_file in chunks of 50 tuples
    // Use view operator for debugging
    grouped_samples.view { chunk ->
        println("Chunk size: ${chunk.size()}")
    }
    
    

    // index the vcf files for easy filtering.
    // loop over the vcf paths in the ch_sample_file.
    // symlink those to /re_scratch/ temp dir
    // Process each chunk of 50 tuples through INDEX_VCFS
    indexed_files = grouped_samplesForUse.map { chunk ->
        INDEX_VCFS(chunk)
    }.flatten()
    log.info "Completed indexing of vcf."
    // we can use this step to filter apply additional filtering / QC steps to variants / regions of interest
    // variants included.
    // VARIANT_FILTER(
    //     ch_variant_type,
    //     ch_sample_file,
    //     ch_region_file,
    //     ch_is_cloud,
    //     symlink_tmp_dir
    // )

    // create a mini-aggregate of the vcfs, used as input in oncodrive and dndscv.
    AGGREGATE_INPUT(
        sl_paths
    )

    // split different tools here? or one workflow that contains the three tools?
    //RUN_TOOLS()

    // combine the outputs of the different tools
    //COMBINE_OUTPUT()
}


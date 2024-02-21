nextflow.enable.dsl=2

def sample_file = params.sample_file == null ? "No user-specified sample file." : params.sample_file
// adding an chunk_id for each.

log.info """\

    S O M A T I C  D I S C O V E R Y
    ==================================
    pipeline version : 0.2
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
Channel.value(params.bed_file).set { ch_bed_file }  // TODO need to include a check if a different user specified file is provided.


Channel.value(params.region_file).set { ch_region_file }
ch_region_file = params.variant_type == 'coding' ? params.coding_file : params.non_coding_file
ch_sample_file = sample_file // bit of duplication here. remove?


include { VALIDATE_ARGS } from "../modules/local/validate_args/validate_args.nf"
include { INDEX_VCFS } from "../modules/local/index_vcfs/index_vcfs.nf"
include { VARIANT_FILTER } from "../modules/local/variant_filter/variant_filter.nf"
include { RUN_MUTENRICHER } from "../modules/local/run_mutenricher/run_mutenricher.nf"
include { RUN_ONCODRIVEFML } from "../modules/local/run_oncodrivefml/run_oncodrivefml.nf"
include { RUN_DNDSCV } from "../modules/local/run_dndscv/run_dndscv.nf"
// include { COMBINE_OUTPUT} from "../modules/local/combine_output/combine_output.nf"
include { CLEAN_SCRATCH } from "../modules/local/clean_scratch/clean_scratch.nf"

workflow SOMATIC_DISCOVERY {
   

    // check if the paths and files are correctly provided.
    VALIDATE_ARGS(
        ch_variant_type,
        sample_file,
        ch_region_file,
        ch_bed_file,
        ch_is_cloud
    )
    log.info "Completed validation of arguments."

    // ingest the sample file.
    ch_samples = Channel
    .fromPath( ch_sample_file )
    .splitCsv(sep: '\t', header: false)
    .map { row -> tuple(row[0], row[1]) }

    // Apply view for debugging
    ch_samples.view { item ->
        println("Sample item: $item")
    }
    log.info "Completed ingesting samples."
    
    // index the vcf files for easy filtering/aggregation.
    // loop over the vcf paths in the ch_sample_file.
    // symlink those to /re_scratch/ temp dir
    // Process each chunk of 50 tuples through INDEX_VCFS

    grouped_samples = ch_samples
        .buffer(size: 1, remainder: true)
        .map { batch -> 
            batch.collect { tuple -> tuple.join('|') }.join('\n')
        }
    // grouped_samples.view { chunk ->
    //     println("Chunk size: ${chunk.size()}")
    // }
    log.info "Completed chunking samples."
    
    // Group the ch_sample_file in chunks of 50 tuples
    INDEX_VCFS(grouped_samples)
    // symlinked_files is a channel of file-paths
    // INDEX_VCFS.out.symlinked_files.view { item ->
    //     println("Symlink file: $item")
    // }
    log.info "Completed indexing of vcf."


    // we can use this step to filter apply additional filtering / QC steps to variants / regions of interest
    // variants included.
    log.info "starting to aggregate variants in chunks."
    //create a mini-aggregate of the vcfs, used as input in oncodrive and dndscv.
    VARIANT_FILTER(
        ch_bed_file,
        INDEX_VCFS.out.symlinked_files
    )
    log.info "starting to aggregate variants in chunks."
    VARIANT_FILTER.out.mini_aggregates.view { item ->
        println("Symlink file: $item")
    }

    // gather and merge the chunks
    // creating the symlink file list and the somatic aggregate.
    ////////////////
    // TODO these should be routed to a tmp directory in /re_scratch/
    ////////////////
    INDEX_VCFS.out.symlinked_files
        .collectFile(name: 'sl_files.txt', newLine: false)
        .set { ch_symlinks }

    VARIANT_FILTER.out.mini_aggregates
        .collectFile(name: 'somatic_aggregate.txt', newLine: false, keepHeader: true, skip: 1)
        .set { ch_aggregate }

    log.info "completed aggregations."

    // Different paths if we have a coding or non-coding run.
    // mutenricher and oncodriveFML can handle both.
    // dNdScv can only handle coding variants.
    if ( params.variant_type == 'coding') {
        RUN_MUTENRICHER(
            ch_symlinks,
            params.variant_type
        )
        // oncodriveFML has some additional folder structure etc that needs to be accessed. Worth including those in the singularity container?
        // or we could migrate them to public_data_resources?
        // right now hosted in /re_scratch/ which doesn't seem like a long term solution.
        RUN_ONCODRIVEFML(
            ch_aggregate,
            ch_region_file,
        )
        RUN_DNDSCV(
            ch_aggregate
        )
    } else {
        RUN_MUTENRICHER(
            ch_symlinks,
            params.variant_type
        )
        RUN_ONCODRIVEFML(
            ch_aggregate
        )
    }
    log.info "Ran tools."

    CLEAN_SCRATCH(
        index_vcfs.sl_tmpdirs
    )
    // but we also need an aggregate of all symlinked files (for mutenricher input).
    // Lets take have another output from combine_aggregates where we join the symlinked files? 

    // split different tools here? or one workflow that contains the three tools?
    //RUN_TOOLS()

    // combine the outputs of the different tools
    //COMBINE_OUTPUT()
}


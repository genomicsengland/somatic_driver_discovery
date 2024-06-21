nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DEFINE FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
def sample_file = params.sample_file == null ? "No user-specified sample file." : params.sample_file

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SET LOGGING INFORMATION
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
log.info """\

    S O M A T I C  D I S C O V E R Y
    ==================================
    pipeline version : 0.2
    data release     : ${params.data_version}
    sample file      : ${params.sample_file}
    variant type     : ${params.variant_type}
    output directory : ${params.outdir}
    command          : ${workflow.commandLine}

    """.stripIndent()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DEFINE INPUT CHANNELS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
Channel.value(params.data_version).set { ch_data_version }
matcher = (params.data_version =~ /v(.+?)_/)
if (matcher.find()) {
    data_release = matcher.group(1)
}

Channel.value(data_release).set { ch_data_release }
Channel.value(params.variant_type).set { ch_variant_type }
Channel.value(params.is_cloud).set { ch_is_cloud }
Channel.value(params.bed_file).set { ch_bed_file }  // TODO need to include a check if a different user specified file is provided.
Channel.value(params.scratchdir).set { ch_tmpdir }
// Channel.value(params.user_tool_params).set { ch_toolparams }
Channel.value(params.region_file).set { ch_region_file }
ch_region_file = params.variant_type == 'coding' ? params.coding_file : params.non_coding_file
ch_sample_file = sample_file // bit of duplication here. remove?

log.info("$params.user_tool_params")

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { VALIDATE_ARGS } from "../modules/local/validate_args/validate_args.nf"
include { INDEX_VCFS } from "../modules/local/index_vcfs/index_vcfs.nf"
include { VARIANT_FILTER } from "../modules/local/variant_filter/variant_filter.nf"
include { RUN_MUTENRICHER } from "../modules/local/run_mutenricher/run_mutenricher.nf"
include { RUN_ONCODRIVEFML } from "../modules/local/run_oncodrivefml/run_oncodrivefml.nf"
include { RUN_DNDSCV } from "../modules/local/run_dndscv/run_dndscv.nf"
include { COMBINE_OUTPUT_CODING} from "../modules/local/combine_output/combine_output.nf"
// include { CLEAN_SCRATCH } from "../modules/local/clean_scratch/clean_scratch.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow SOMATIC_DISCOVERY {

    // 1. Check if the input paths and files are correctly provided.
    VALIDATE_ARGS(
        ch_variant_type,
        sample_file,
        ch_region_file,
        ch_bed_file,
        ch_is_cloud
    )
    log.info "Completed validation of arguments."

    // 2. Ingest the samplesheet file and view for debugging purposes.
    ch_samples = Channel
    .fromPath( ch_sample_file )
    .splitCsv(sep: '\t', header: false)
    .map { row -> tuple(row[0], row[1]) }

    ch_samples.view { item ->
        println("Sample item: $item")
    }
    log.info "Completed ingesting samples."

    // 3. Index the vcf files for easy filtering/aggregation.

    // 3a. Chunk samples to be fed through INDEX_VCFs.
    grouped_samples = ch_samples
        .buffer(size: 25, remainder: true)
        .map { batch ->
            batch.collect { tuple -> tuple.join('|') }.join('\n')
        }

    log.info "Completed chunking samples."

    // 3b. Create symlinks in scratch location and index VCFs.
    INDEX_VCFS(
        grouped_samples,
        ch_tmpdir
        )
    // symlinked_files is a channel of file-paths
    // INDEX_VCFS.out.symlinked_files.view { item ->
    //     println("Symlink file: $item")
    // }
    log.info "Completed indexing of vcf."


    // 4. Create a mini-aggregate of the vcfs, used as input in oncodrive and dndscv.
    log.info "starting to aggregate variants in chunks."
    VARIANT_FILTER(
        ch_bed_file,
        INDEX_VCFS.out.symlinked_files
    )
    VARIANT_FILTER.out.mini_aggregates.view { item ->
        println("Symlink file: $item")
    }

    // 5. Gather and merge the mini aggregate chunks
    // To do: Ensure these are routed to a tmp directory in /re_scratch/
    INDEX_VCFS.out.symlinked_files
        .collectFile(name: 'sl_files.txt', newLine: false)
        .set { ch_symlinks }

    VARIANT_FILTER.out.mini_aggregates
        .collectFile(name: 'somatic_aggregate.txt', newLine: false, keepHeader: true, skip: 1)
        .set { ch_aggregate }

    log.info "completed aggregations."

    // 6. Run tools and combine outputs.
    // Note: Tool selection is dependent on the user-specified "variant_type" parameter.
    // mutenricher and oncodriveFML can handle both.
    // dNdScv can only handle coding variants.
    if ( params.variant_type == 'coding') {
        if ( params.user_tool_params.run_mutenricher ){

            RUN_MUTENRICHER(
                ch_symlinks,
                params.variant_type,
                params.user_tool_params.anno_type,
                params.user_tool_params.gtf_gene_model_info,
                params.user_tool_params.gene_list ?: "",
                params.user_tool_params.covariates_file ?: "",
                params.user_tool_params.weights ?: "",
                params.user_tool_params.stat_type,
                params.user_tool_params.background_mut_calc,
                params.user_tool_params.min_clust_size,
                params.user_tool_params.ap_iters,
                params.user_tool_params.ap_convits,
                params.user_tool_params.ap_algorithm,
                params.user_tool_params.hotspot_distance,
                params.user_tool_params.min_hs_vars,
                params.user_tool_params.min_hs_samps,
                params.user_tool_params.snps_only ?: "",
                params.user_tool_params.blacklist ?: "",
                params.user_tool_params.mut_prefix
            )
        }

        // oncodriveFML has some additional folder structure etc that needs to be accessed. Worth including those in the singularity container?
        // or we could migrate them to public_data_resources?
        // right now hosted in /re_scratch/ which doesn't seem like a long term solution.
        if ( params.user_tool_params.run_oncodrivefml ){

            RUN_ONCODRIVEFML(
            ch_aggregate,
            ch_region_file
            )
        }

        if (  params.user_tool_params.run_dndscv ){

            RUN_DNDSCV(
            ch_aggregate
            )
        }

        // combine the outputs of the different tools
        COMBINE_OUTPUT_CODING(
            RUN_MUTENRICHER.out.me_fisher_enrichments,
            RUN_ONCODRIVEFML.out.onco_enrichments,
            RUN_DNDSCV.out.dndscv_enrichments
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

    // 7. Clean scratch for minimum memory footprint.
    // CLEAN_SCRATCH()

}

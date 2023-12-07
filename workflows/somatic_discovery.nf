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

    WARNING: Canvas CNV calls use Illumina-derived sex chromosome karyotype. In rare cases, we have found these to be inconsistent with GEL-derived coverage-based sex chromosome karyotype. When the sex chromosome karyotype is inconsistent, CNV calls on sex chromosomes will be wrong. See documentation for full details.

    """.stripIndent()


Channel.value(params.data_version).set { ch_data_version }

matcher = (params.data_version =~ /v(.+?)_/)
if (matcher.find()) {
    data_release = matcher.group(1)
}

Channel.value(data_release).set { ch_data_release }
Channel.value(params.variant_type).set { ch_variant_type }
Channel.value(params.is_cloud).set { ch_is_cloud }

ch_sample_file = params.sample_file ? Channel.fromPath(params.sample_file) : []

Channel.fromPath(params.region_file).set { ch_region_file }

include { VALIDATE_ARGS } from "../modules/local/validate_args/validate_args.nf"
include { VARIANT_FILTER } from "../modules/local/variant_filter/variant_filter.nf"
include { AGGREGATE_INPUT } from "../modules/local/aggregate_input/aggregate_input.nf"
include { RUN_TOOLS } from "../modules/local/run_tools/run_tools.nf"
include { COMBINE_OUTPUT} from "../modules/local/combine_output/combine_output.nf"

workflow SOMATIC_DISCOVERY {
    // check if the paths and files are correctly provided.
    VALIDATE_ARGS(
        ch_variant_type,
        ch_region_file,
        ch_sample_file,
        ch_is_cloud
        ch_data_release,

    )

    // index the vcf files for easy filtering.
    INDEX_VCFS(

    )

    // using the region file and variant type to limit the
    // variants included.
    VARIANT_FILTER(

    )

    // create a mini-aggregate of the vcfs, used as input in oncodrive and dndscv.
    AGGREGATE_INPUT(

    )

    // split different tools here? or one workflow that contains the three tools?
    RUN_TOOLS(

    )

    // combine the outputs of the different tools
    COMBINE_OUTPUT(

    )
}

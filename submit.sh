#!/bin/bash

#BSUB -P bio
#BSUB -q inter
#BSUB -J somatic_driver
#BSUB -o logs/%J_somatic_driver.stdout
#BSUB -e logs/%J_somatic_driver.stderr

LSF_JOB_ID=$LSB_JOBID
export NXF_DISABLE_CHECK_LATEST=true
export NXF_LOG_FILE="logs/${LSF_JOB_ID}_nextflow.log"

# LOAD MODULES
module purge
module load singularity/4.1.1 nextflow/23.10

# VARIABLES TO EDIT PRIOR TO SUBMISSION
driver_discovery='/pgen_int_work/BRS/aho/brsc/somatic_diver_wf_development/somatic_driver_discovery'
scratchdir='/re_scratch/aho'

# RUN WORKFLOW
nextflow run "${driver_discovery}"/main.nf \
    --sample_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/input/min_luad_vcf.txt" \
    --variant_type "coding" \
    --region_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/coding_CDS.tsv.gz" \
    --bed_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/hg38.bed" \
    --scratchdir ${scratchdir} \
    -profile cluster

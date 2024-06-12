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
DRIVER_DISCOVERY='/path/to/dir'
SCRATCHDIR='/re_scratch/path/to/dir'

# RUN WORKFLOW
cd $driver_discovery
nextflow run "${DRIVER_DISCOVERY}"./main.nf \
    --variant_type "coding" \
    --sample_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/input/min_luad_vcf.txt" \
    --region_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/coding_CDS.tsv.gz" \
    --scratchdir "${SCRATCHDIR}" \
    -c "${DRIVER_DISCOVERY}"/nextflow.config \
    -profile cluster

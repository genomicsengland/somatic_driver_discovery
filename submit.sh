#!/bin/bash

#BSUB -P <project_code>
#BSUB -q inter
#BSUB -J structural_variant
#BSUB -o logs/%J_structural_variant.stdout
#BSUB -e logs/%J_structural_variant.stderr


LSF_JOB_ID=$LSB_JOBID
export NXF_LOG_FILE="logs/${LSF_JOB_ID}_nextflow.log"

module purge
module load tools/singularity/3.8.3 bio/nextflow/22.10.5 lang/Java/17.0.2

driver_discovery='/Users/christianbouwens/Documents/Internal/workflows/somatic_driver_discovery/main'

nextflow run "${driver_discovery}"/main.nf \
    --sample_file '<path_to_input_file>' \
    --variant_type 'coding' \
    --region_file '<path_to_region_file>' \
    --profile cluster \
    --resume
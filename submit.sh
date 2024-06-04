#!/bin/bash

#BSUB -P bio
#BSUB -q inter
#BSUB -J params_test_ssd
#BSUB -o logs/%J_somatic_driver.stdout
#BSUB -e logs/%J_somatic_driver.stderr


LSF_JOB_ID=$LSB_JOBID
export NXF_DISABLE_CHECK_LATEST=true
export NXF_LOG_FILE="logs/${LSF_JOB_ID}_nextflow.log"

module purge
module load singularity/3.8.3 nextflow/22.10.5 java/17.0.2

driver_discovery='/pgen_int_work/BRS/rrodriguespereira/gelrrptickets/BRSC_430/somatic_driver_discovery'

cd $driver_discovery

chmod -R u+x ./bin

nextflow run ./main.nf \
    --variant_type "coding" \
    --sample_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/input/min_luad_vcf.txt" \
    --region_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/coding_CDS.tsv.gz" \
    --scratchdir "/nas/weka.gel.zone/re_scratch/rrodriguespereira/ssd" \
    -c nextflow.config \
    -profile cluster

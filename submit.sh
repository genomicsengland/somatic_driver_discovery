#!/bin/bash

#BSUB -P bio
#BSUB -q inter
#BSUB -J somatic_driver
#BSUB -o logs/%J_somatic_driver.stdout
#BSUB -e logs/%J_somatic_driver.stderr


LSF_JOB_ID=$LSB_JOBID
export NXF_DISABLE_CHECK_LATEST=true
export NXF_LOG_FILE="logs/${LSF_JOB_ID}_nextflow.log"

module purge
module load singularity/4.1.1 nextflow/23.10

driver_discovery='/pgen_int_work/BRS/aho/brsc/somatic_driver_discovery'

nextflow run "${driver_discovery}"/main.nf \
    --sample_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/input/min_luad_vcf.txt" \
    --variant_type "coding" \
    --region_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/coding_CDS.tsv.gz" \
    --bed_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/hg38.bed" \
    --scratchdir '/nas/weka.gel.zone/re_scratch/cb_ind/tmp' \
    -profile cluster
    # --scratchdir "/re_scratch/${LSB_JOBID}/" \  


#  --region_file '/public_data_resources/ensembl_cds/MANE/v1.0/MANE.GRCh38.v1.0.ensembl_genomic.gtf.gz' \

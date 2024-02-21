#!/bin/bash

#BSUB -P bio
#BSUB -q inter
#BSUB -J structural_variant
#BSUB -o logs/%J_structural_variant.stdout
#BSUB -e logs/%J_structural_variant.stderr


LSF_JOB_ID=$LSB_JOBID
export NXF_LOG_FILE="logs/${LSF_JOB_ID}_nextflow.log"

module purge
module load tools/singularity/3.8.3 bio/nextflow/22.10.5 lang/Java/17.0.2

driver_discovery='/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/'

nextflow run "${driver_discovery}"/main.nf \
    --sample_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/input/min_luad_vcf.txt" \
    --variant_type "coding" \
    --region_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/coding_CDS.tsv.gz" \
    --bed_file "/pgen_int_work/BRS/cancer_dev/discovery/somatic_driver_discovery/resources/global/hg38.bed" \
    --scratchdir '/nas/weka.gel.zone/re_scratch/cb_ind/tmp' \
    -profile cluster
    # once re_scratch issues are fixed use:
    # we do have to implement a step where we remove this dir again though.
    
    # --scratchdir "/re_scratch/${LSB_JOBID}/" \  

#    -resume
#  --region_file '/public_data_resources/ensembl_cds/MANE/v1.0/MANE.GRCh38.v1.0.ensembl_genomic.gtf.gz' \

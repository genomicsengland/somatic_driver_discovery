# Somatic Driver Discovery Workflow

The somatic driver discovery workflow (SDD) identifies potential somatic drivers based on a user defined cohort. The inference is done via three methodologies: MutEnricher, oncodriveFML and dNdScv.

## How to run the workflow
### Step 1 - Set up the analysis folder
Create a folder to store your analysis results and copy the file `submit.sh` to this location.

```
mkdir /pgen_int_work/BRS/jdoe/path/to/analysis_folder
cd /pgen_int_work/BRS/jdoe/path/to/analysis_folder
cp /pgen_int_work/BRS/somatic_discovery/submit.sh .

```

## Step 2 - Format the cohort file
Make a tab delimited file with your cohort of interest. This file should contain two columns and no header. The first column must have a VCF path while the second column the sample platekey. You can find an example here: `/pgen_int_work/BRS/somatic_discovery/example/luad_lusc_example_samples.txt`.

```
/path/to/VCF/sample_platekey_1.vcf.gz        sample_platekey_1
/path/to/VCF/sample_platekey_2.vcf.gz        sample_platekey_2
/path/to/VCF/sample_platekey_3.vcf.gz        sample_platekey_3
...
```

## Step 3 - Update submission script
Edit the file `submit.sh` to point to the workflow folder, a scratch directory and the cohort file.

1. Set the workflow folder in line 18 `DRIVER_DISCOVERY='/pgen_int_work/BRS/somatic_discovery'`. If you have not copied the workflow folder somewhere else, this should be pre-populated with the right path.
2. Set the path to a scratch folder in line 19 `SCRATCHDIR='/re_scratch/path/to/dir'`
3. Provide the path to the cohort samples in line 24 `--sample_file "/pgen_int_work/BRS/somatic_discovery/example/luad_lusc_example_samples.txt"`

Here are the relevant lines in the `submit.sh` file:

```bash
# VARIABLES TO EDIT PRIOR TO SUBMISSION
DRIVER_DISCOVERY='/pgen_int_work/BRS/somatic_discovery'
SCRATCHDIR='/re_scratch/path/to/dir'

# RUN WORKFLOW
nextflow run "${DRIVER_DISCOVERY}"/main.nf \
    --variant_type "coding" \
    --sample_file "/pgen_int_work/BRS/somatic_discovery/example/luad_lusc_example_samples.txt" \
    --region_file "/pgen_int_work/BRS/somatic_discovery/resources/global/coding_CDS.tsv.gz" \
    --scratchdir "${SCRATCHDIR}" \
    -c "${DRIVER_DISCOVERY}"/nextflow.config \
    -profile cluster

```

## Step 4 - Submit job to HPC cluster
Now, you only need to submit the analysis script to the cluster. You can do so from the analysis folder:

```bash
cd /pgen_int_work/BRS/jdoe/path/to/analysis_folder
bsub < submit.sh
```

# How to read the results
The results for each tool are available in the `results` folder created inside the analysis directory.

Here's an example of what the results folder looks like:
```bash
cd /pgen_int_work/BRS/jdoe/path/to/analysis_folder

tree results/

results/
├── dndscv
│   └── dndscv
├── mutenricher
│   ├── test_gene_enrichments.txt
│   ├── test_gene_hotspot_Fisher_enrichments.txt
│   └── test_hotspot.txt
└── pipeline_info
    ├── execution_report_2024-07-11_15-02-15.html
    ├── execution_timeline_2024-07-11_15-02-15.html
    ├── execution_trace_2024-07-11_15-02-15.txt
    └── pipeline_dag_2024-07-11_15-02-15.html
```

# Advanced use
If you'd like to customise a set of parameters, you can do so by editing the `conf/tools_params.config` file. However, you'll need to copy the workflow folder to an appropriate directory to be able to edit this file.

Running the workflow should be just as easy, provided you update the `DRIVER_DISCOVERY` variable in the `submit.sh` file with the new folder path.

Information on individual parameters can be found in the documentation for each tool, referenced below.

## References
These resources provide more information on individual tools and methods applied to the workflow.

| Tool         | Source | Repository |
| :----------- | :----- | :--------- |
| dNdScv       | http://www.cell.com/cell/fulltext/S0092-8674(17)31136-4 | https://github.com/im3sanger/dndscv |
| MutEnricher  | https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03695-z | https://github.com/asoltis/MutEnricher |
| oncodriveFML | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-016-0994-0 | https://bitbucket.org/bbglab/oncodrivefml/src/master/ |

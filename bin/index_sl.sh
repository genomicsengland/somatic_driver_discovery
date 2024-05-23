#!/usr/bin/env bash

help()
{
    echo "Usage: index_sl
                [ -v | --vcf            ]
                [ -s | --samplename     ]
                [ -y | --symdir         ]
                [ -c | --chunkid        ]
                [ -h | --help           ]"
    exit 2
}

SHORT=v:,s:,y:,c:,h
LONG=vcf:,samplename:,symdir:,chunkid:,help
OPTS=$(getopt -a -n index_sl --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$#

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
    help
fi


eval set -- "$OPTS"

while :
do
    case "$1" in
        -v | --vcf )
            vcf="$2"
            shift 2
            ;;
        -s | --samplename )
            samplename="$2"
            shift 2
            ;;
        -y | --symdir )
            symdir="$2"
            shift 2
            ;;
        -c | --chunkid )
            chunkid="$2"
            shift 2
            ;;
        -h | --help)
            help
            ;;
        --)
            shift;
            break
            ;;
        *)
            echo "Unexpected option: $1"
            help
            ;;
    esac
done

if [[ ${VALID_ARGUMENTS} -ne  8 ]]; then
    echo "$0: Not enough inputs provided. Please provide all required inputs."
    help
fi

OUT="symlink_filelist_${chunkid}.tsv"
touch "${OUT}"

# Now, file_path and sample_name contain individual elements of each tuple
echo "File path: $vcf, Sample name: $samplename"
filename=$(basename "$vcf")
echo "$filename"
symlinked_file="${symdir}/$filename"

# Create symlink in the work directory
ln -s "$vcf" "$symlinked_file"

# Index the symlinked file
bcftools index -t "$symlinked_file"

# Emit the sample name and symlinked file path
echo -e "${symlinked_file}\t${samplename}" >> ${OUT}

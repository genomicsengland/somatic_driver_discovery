#!/usr/bin/env bash

help()
{
    echo "Usage: mini_aggregate
                [ -v | --inputvcfs      ]
                [ -c | --chunkid        ]
                [ -b | --bedfile        ]
                [ -h | --help           ]"
    exit 2
}

SHORT=v:,c:,b:,h
LONG=inputvcfs:,chunkid:,bedfile:,help
OPTS=$(getopt -a -n index_sl --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$#

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
    help
fi


eval set -- "$OPTS"

while :
do
    case "$1" in
        -v | --inputvcfs )
            inputvcfs="$2"
            shift 2
            ;;
        -c | --chunkid )
            chunkid="$2"
            shift 2
            ;;
        -b | --bedfile )
            bedfile="$2"
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

if [[ ${VALID_ARGUMENTS} -ne  6 ]]; then
    echo "$0: Not enough inputs provided. Please provide all required inputs."
    help
fi

OUT="mini_aggregate_${chunkid}.txt"
# tmpfile="tmpfile.txt"
# if our aggregate file does not exist, create it and add the required header.
if [ ! -f "${OUT}" ]; then
    echo -e "CHROM\tPOS\tREF\tALT\tSAMPLE" > ${OUT}
fi

## Aggregate variants ##
# we don't have to loop as we aren't going in chunks.
# region file required here.
while IFS=$'\t' read -r vcf_path sample_name
do
    bcftools query -i 'FILTER="PASS"' \
    -R ${bedfile} \
    -f "%CHROM\t%POS\t%REF\t%ALT\t${sample_name}\n" $vcf_path >> ${OUT}
done < ${inputvcfs}

#/usr/bin/env bash

# Help text
usage="Usage: vfvs_pp_extract_bestposes.sh <compounds_file> <structure_dir> <output_dir>

Options:
    <compound_file>: column1: tranch_collection 
                     column2: compound ID
                     column3: minindex "

if [ "${1}" == "-h" ]; then
   echo -e "\n${usage}\n\n"
   exit 0 
fi

if [[ "$#" -ne "2" ]]; then
   echo -e "\nWrong number of arguments. Exiting.\n"
   echo -e "${usage}\n\n"
   exit 1
fi

# Standard error response 
error_response_nonstd() {
    echo "Error was trapped which is a nonstandard error."
    echo "Error in bash script $(basename ${BASH_SOURCE[0]})"
    echo "Error on line $1"
    echo
    exit 1
}
trap 'error_response_nonstd $LINENO' ERR

clean_exit() {
    pkill -P $$ || true
    sleep 3
    pkill -9 -P $$ || true
}
trap 'clean_exit' EXIT

index=0
while IFS= read -r line; do
    index=$((index+1))
   read -r -a array <<< "$line"
   collection=${array[0]}
   tranch=${array/_*}
   collection_id=${array/*_}
   zinc_id="${array[1]}"
   minindex="${array[2]}"
   echo "Extracting $tranch, $collection_id, $zinc_id, $minindex"
   cp $2/${tranch}/${collection_id}/${zinc_id}/replica-${minindex}/${zinc_id}.rank-1.pdb $3/${index}_${zinc_id}.pdb
   echo
done < $1

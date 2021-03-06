#!/usr/bin/env bash

usage="Usage: vfvs_pp_firstposes_extract_structures.sh <compounds_file> <structure_dir> <output_dir>"

# Standard error response
error_response_std() {
    echo "Error was trapped" 1>&2
    echo "Error in bash script $(basename ${BASH_SOURCE[0]})" 1>&2
    echo "Error on line $1" 1>&2
    echo "Exiting."
    exit 1
}
trap 'error_response_std $LINENO' ERR

# Checking the input paras
if [ "${1}" == "-h" ]; then
    echo -e "\n $usage\n\n"
    exit 0
fi
if [ "$#" -ne "3" ]; then
    echo -e "\nWrong number of arguments. Exiting.\n"
    echo -e "${usage}\n\n"
    exit 1
fi

mkdir -p ${3}

index=0
while IFS= read -r line; do
   index=$((index+1))
   read -r -a array <<< "$line"
   collection=${array[0]}
   if [ -z "${collection}" ]; then
       continue
   fi
   tranch=${array/_*}
   collection_id=${array/*_}
   zinc_id="${array[1]}"
   minindex="${array[2]}"
   echo "Extracting $tranch, $collection_id, $zinc_id, $minindex"
   cp $2/${tranch}/${collection_id}/${zinc_id}/replica-${minindex}/${zinc_id}.rank-1.pdb $3/${index}_${zinc_id}_rank1.pdb || true
   cp $2/${tranch}/${collection_id}/${zinc_id}/replica-${minindex}/docking.out.pdbqt $3/${index}_${zinc_id}.all.pdbqt || true
   if [ -f $2/${tranch}/${collection_id}/${zinc_id}/${zinc_id}_replica-${minindex}.flexres.pdb ]; then
       grep -B 1000000 -m 1 END $2/${tranch}/${collection_id}/${zinc_id}/${zinc_id}_replica-${minindex}.flexres.pdb > $3/${index}_${zinc_id}.all.flexres.pdb
   elif [ -f $2/${tranch}/${collection_id}/${zinc_id}/${collection_id}/${zinc_id}_replica-${minindex}.flexres.pdb ]; then
       grep -B 1000000 -m 1 END $2/${tranch}/${collection_id}/${zinc_id}/${collection_id}/${zinc_id}_replica-${minindex}.flexres.pdb > $3/${index}_${zinc_id}.all.flexres.pdb 
   fi
   echo
done < $1

#!/bin/bash

set -e

project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)
for proj in ${project_array[@]}
do
    cd $proj"_dir"
    if [ -d fuzz ]; then
        mv fuzz old_fuzz
    fi
    cd ..
done

# echo $1
# if [ 1 -ge $1 ] && [ 1 -le $2 ]; then
#     echo $1 $2
# fi

# project_array=(zstd curl lcms libpcap libxml2 libxml2_reader proj4 usrsctp binutils_cxx binutils_disass)

# for proj in ${project_array[@]}
# do

#     if [ 2 -ge $1 ] && [ 2 -le $2 ]; then
#         if [ "$proj" == "binutils_disass" ]
#         then
#             echo "yes"
#         else
#             echo "no"
#         fi
#         echo "result over!  ——————cmr"
#     fi
# done


# cd zstd_dir
# pwd
# rm "shell_copy"* -rf
# rm "shell_json"* -rf
# rm "shell_exec"* -rf
# cd ..

# shell_makefile="/home/cmr/my_codeql/project/shell_makefile/test_make.sh"
# $shell_makefile 
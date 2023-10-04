#!/bin/bash
  
set -e

# project_array=(binutils_disass)
project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)
# list_fuzz=(aflpp afl libfuzzer honggfuzz)
list_fuzz=(honggfuzz)

list_num=("1" "2" "3")


for proj in ${project_array[@]}
do
    proj_dir=$proj"_dir"
    cd $proj_dir
    (
        pwd

        # mv "new_honggfuzz_shell_exec_remove_"$proj "new_honggfuzz_shell_exec_remove4_"$proj

        # rm remove_honggfuzz1_fuzz -rf
        # mv remove_honggfuzz4_fuzz remove_honggfuzz1_fuzz
        
        # rm seed_fuzz -rf
        # mv "new_shell_json_remove_"$proj "new_json_remove_"$proj 
        # sudo cp "../../"$proj_dir"/seeds" ./ -r


        # for fuzz in ${list_fuzz[@]}
        # do
        #     (
        #         exec="../new_"$fuzz"_shell_exec_remove_"$proj
        #         for num in ${list_num[@]}
        #         do
        #             (
        #                 remove_fuzz="remove_"$fuzz$num"_fuzz"
        #                 rm $remove_fuzz -rf
        #                 mkdir $remove_fuzz
        #                 cd $remove_fuzz

        #                 pwd
        #                 cp $exec ./
        #                 mkdir out crashdir
        #                 cp ../seeds in -r

        #                 cd ..
        #             )
        #         done
        #     )
        # done
    )

    cd ..
done
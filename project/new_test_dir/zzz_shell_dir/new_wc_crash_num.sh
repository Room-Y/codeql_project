#!/bin/bash

set -e

# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

project_array=(binutils_cxx binutils_disass lcms curl libxml2 libxml2_reader proj4 libpcap usrsctp zstd)
list_fuzz=(aflpp afl libfuzzer honggfuzz)
count=$2


for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        if [[ $1 == 1 ]]; then
            ls "remove_aflpp"$count"_fuzz/out/default/crashes" -l | wc -l
            ls "remove_aflpp"$count"_fuzz/out/default/queue" -l | wc -l

        fi

        if [[ $1 == 2 ]]; then
            ls "remove_afl"$count"_fuzz/out/crashes" -l | wc -l
            ls "remove_afl"$count"_fuzz/out/queue" -l | wc -l
        fi
        
        if [[ $1 == 3 ]]; then
            ls "remove_libfuzzer"$count"_fuzz/crashdir" -l | wc -l
            ls "remove_libfuzzer"$count"_fuzz/out" -l | wc -l
        fi

        if [[ $1 == 4 ]]; then
            ls "remove_honggfuzz"$count"_fuzz/crashdir" -l | wc -l
            ls "remove_honggfuzz"$count"_fuzz/out" -l | wc -l
        fi


        # for fuzz in ${fuzz_array[@]}
        # do
        #     cp $fuzz"1_remove_fuzz" $fuzz"2_remove_fuzz" -r
        # done

        # if [[ $1 == 1 ]]; then
        #     ls "AFLPP"$count"_remove_fuzz/out/default/crashes" -l | wc -l
        #     #ls AFLPP1_remove_fuzz/out/default/crashes
        # fi

        # if [[ $1 == 2 ]]; then
        #     ls "AFL"$count"_remove_fuzz/out/crashes" -l | wc -l
        #     #ls AFL1_remove_fuzz/out/crashes 
        # fi

        # if [[ $1 == 3 ]]; then
        #     ls "fairfuzz"$count"_remove_fuzz/out/crashes" -l | wc -l
        #     #ls fairfuzz1_remove_fuzz/out/crashes 
        # fi

        # if [[ $1 == 4 ]]; then
        #     ls "libfuzzer"$count"_remove_fuzz/crashdir" -l | wc -l
        #     #ls libfuzzer1_remove_fuzz/crashdir 
        # fi

        # if [[ $1 == 5 ]]; then
        #     ls "honggfuzz"$count"_remove_fuzz/crashdir" -l | wc -l
        #     #ls honggfuzz1_remove_fuzz/crashdir 
        # fi
    )

    cd ..
done


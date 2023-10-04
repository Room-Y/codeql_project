#!/bin/bash

set -e


project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)
list_fuzz=(aflpp afl libfuzzer honggfuzz)
fuzz=libfuzzer
count=$1


for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        ls "remove_"$fuzz$count"_fuzz/out/default/crashes" -l | wc -l
        ls "remove_"$fuzz$count"_fuzz/out/crashes" -l | wc -l
        ls "remove_"$fuzz$count"_fuzz/crashdir" -l | wc -l
        if [[ $2 == 3 ]]; then
            ls "remove_"$fuzz$count"_fuzz/crashdir" -l | wc -l
        fi

        if [[ $2 == 4 ]]; then
            ls "remove_"$fuzz$count"_fuzz/crashdir" -l | wc -l
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


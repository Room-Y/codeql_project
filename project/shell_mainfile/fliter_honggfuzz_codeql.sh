#!/bin/bash

set -e

# /home/honggfuzz/honggfuzz -i in -o out -n 1 --crashdir crashdir -S --run_time 86401 -- ./honggfuzz_shell_exec_remove_binutils_cxx ___FILE___

CC="/home/honggfuzz/hfuzz_cc/hfuzz-cc"
CXX="/home/honggfuzz/hfuzz_cc/hfuzz-cc"
flags="-lstdc++ -fsanitize=undefined,address"

project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        # 数据准备
        pure_dir="/home/cmr/my_codeql/project/"$proj_dir"/"$proj"_pure"
        seeds="/home/cmr/my_codeql/project/"$proj_dir"/seeds"

        shell_copy="new_copy_"$proj
        shell_db="new_db_"$proj
        shell_result="new_results_"$proj

        shell_test_copy="new_copy_test_"$proj
        shell_test_json="new_json_test_"$proj
        shell_test_exec="new_exec_test_"$proj

        shell_test_all_copy="new_copy_all_test_"$proj
        shell_test_all_exec="new_exec_all_test_"$proj

        shell_seed_copy="new_copy_seed_"$proj
        shell_seed_json="new_json_seed_"$proj
        shell_seed_exec="new_exec_seed_"$proj     

        shell_remove_copy="new_honggfuzz_shell_copy_remove_"$proj
        shell_remove_json="new_shell_json_remove_"$proj
        shell_remove_exec="new_honggfuzz_shell_exec_remove_"$proj
        
        test_fuzz="test_fuzz"
        seed_fuzz="seed_fuzz"
        remove_fuzz1="remove_honggfuzz1_fuzz"
        remove_fuzz2="remove_honggfuzz2_fuzz"
        remove_fuzz3="remove_honggfuzz3_fuzz"

        shell_makefile="/home/cmr/my_codeql/project/shell_makefile/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        # 生成remove_fuzz1文件夹
        if [ 9 -ge $1 ] && [ 9 -le $2 ]; then
            rm $remove_fuzz1 -rf
            mkdir $remove_fuzz1 $remove_fuzz1"/out"
            cp $seeds $remove_fuzz1"/in" -r
            cp $shell_remove_exec $remove_fuzz1
            echo "remove_fuzz1 over! ——————cmr "
        fi

        # 生成remove_fuzz2文件夹
        if [ 10 -ge $1 ] && [ 10 -le $2 ]; then
            rm $remove_fuzz2 -rf
            mkdir $remove_fuzz2 $remove_fuzz2"/out"
            cp $seeds $remove_fuzz2"/in" -r
            cp $shell_remove_exec $remove_fuzz2
            echo "remove_fuzz2 over! ——————cmr "
        fi

        # 生成remove_fuzz3文件夹
        if [ 11 -ge $1 ] && [ 11 -le $2 ]; then
            rm $remove_fuzz3 -rf
            mkdir $remove_fuzz3 $remove_fuzz3"/out"
            cp $seeds $remove_fuzz3"/in" -r
            cp $shell_remove_exec $remove_fuzz3
            echo "remove_fuzz3 over! ——————cmr "
        fi
    )

    cd ..
done

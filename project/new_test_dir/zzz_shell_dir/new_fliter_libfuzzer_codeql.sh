#!/bin/bash

set -e

#timeout 24h ./libfuzzer_shell_exec_remove_proj4 -fork=1 -ignore_crashes=1 -ignore_ooms=1 -ignore_timeouts=1 -detect_leaks=0 -artifact_prefix=crashdir/ out in 


CC="clang"
CXX="clang++"
flags="-fsanitize=fuzzer,undefined,address"
# flags1="-g -O1 -fsanitize=fuzzer-no-link,undefined,address"

# project_array=(binutils_disass)
project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

for proj in ${project_array[@]}
do
    proj_dir=$proj"_dir"
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

        shell_remove_copy="new_libfuzzer_shell_copy_remove_"$proj
        shell_remove_json="new_json_remove_"$proj
        shell_remove_exec="new_libfuzzer_shell_exec_remove_"$proj
        
        test_fuzz="test_fuzz"
        seed_fuzz="seed_fuzz"
        remove_fuzz1="remove_libfuzzer1_fuzz"
        remove_fuzz2="remove_libfuzzer2_fuzz"
        remove_fuzz3="remove_libfuzzer3_fuzz"

        shell_makefile="/home/cmr/my_codeql/project/shell_makefile_libfuzzer/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        # 插入remove_copy && remove_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            rm $shell_remove_copy -rf
            rm $shell_remove_exec -rf
            cp $pure_dir $shell_remove_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_remove_json \
                            -s $shell_remove_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "remove_shell_remove_"$proj" over! ——————cmr "

            # 生成remove可执行脚本
            $shell_makefile $shell_makeway_afl $shell_remove_copy $shell_remove_exec $CC $CXX $flags
            echo "exec_remove_"$proj" over! ——————cmr "
        fi
    )

    cd ..
done
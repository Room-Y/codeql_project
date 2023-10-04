#!/bin/bash

set -e

#timeout 24h ./libfuzzer_shell_exec_remove_proj4 -fork=1 -ignore_crashes=1 -ignore_ooms=1 -ignore_timeouts=1 -detect_leaks=0 -artifact_prefix=crashdir/ out in 


CC="clang"
CXX="clang++"
flags="-fsanitize=fuzzer,undefined,address"
# flags1="-g -O1 -fsanitize=fuzzer-no-link,undefined,address"

# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)
project_array=(curl)

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        # 数据准备
        pure_dir=$proj"_pure"
        shell_copy="shell_copy_"$proj
        shell_db="shell_db_"$proj
        shell_result="shell_results_"$proj
        shell_test_copy="shell_copy_test_"$proj
        shell_test_json="shell_json_test_"$proj
        shell_test_exec="shell_exec_test_"$proj
        shell_test_all_copy="shell_copy_all_test_"$proj
        shell_test_all_exec="shell_exec_all_test_"$proj

        shell_remove_copy="libfuzzer2_shell_copy_remove_"$proj
        shell_remove_json="shell_json_remove_"$proj
        shell_remove_exec="libfuzzer2_shell_exec_remove_"$proj
        remove_fuzz="libfuzzer2_remove_fuzz"

        test_fuzz="libfuzzer_test_fuzz"
        shell_makefile="/home/cmr/my_codeql/project/shell_makefile_libfuzzer/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        # 插入remove_copy && remove_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            # rm $shell_remove_copy -rf
            # rm $shell_remove_exec -rf
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

        # 生成remove_fuzz文件夹
        if [ 9 -ge $1 ] && [ 9 -le $2 ]; then
            # rm $remove_fuzz -rf
            mkdir $remove_fuzz $remove_fuzz"/in" $remove_fuzz"/out" $remove_fuzz"/crashdir"
            cp seeds/* $remove_fuzz"/in" -r
            cp $shell_remove_exec $remove_fuzz
            echo "remove_fuzz"" over! ——————cmr "
        fi
    )

    cd ..
done
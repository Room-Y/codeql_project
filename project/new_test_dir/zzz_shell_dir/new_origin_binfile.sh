#!/bin/bash

set -e

# project_array=(zstd)

CC="gcc"
CXX="g++"
flags=""
# timeout 24h /home/afl/afl-fuzz -i in -o out -m none -d -- ./AFL_shell_exec_remove_zstd  @@
# project_array=(binutils_disass)
project_array=(lcms libpcap libxml2_reader libxml2 proj4 usrsctp zstd curl binutils_cxx binutils_disass)

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

        shell_remove_copy="new_afl_shell_copy_remove_"$proj
        shell_remove_json="new_json_remove_"$proj
        shell_remove_exec="new_afl_shell_exec_remove_"$proj
        
        shell_origin_copy="new_origin_copy_"$proj
        shell_origin_exec="new_origin_exec_"$proj
        
        test_fuzz="test_fuzz"
        seed_fuzz="seed_fuzz"
        remove_fuzz1="remove_afl1_fuzz"
        remove_fuzz2="remove_afl2_fuzz"
        remove_fuzz3="remove_afl3_fuzz"

        shell_makefile="/home/cmr/my_codeql/project/shell_makefile/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        # 拷贝origin_copy && 生成origin_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            rm $shell_origin_copy -rf
            rm $shell_origin_exec -rf
            cp $pure_dir $shell_origin_copy -r

            # 生成remove可执行脚本
            $shell_makefile $shell_makeway_gcc $shell_origin_copy $shell_origin_exec $CC $CXX $flags
            echo "exec_origin_"$proj" over! ——————cmr "
        fi

        du $shell_origin_exec -sh >> ../zzz_result_dir/origin_exec_size
        echo "" >> ../zzz_result_dir/origin_exec_size
    )

    cd ..
done


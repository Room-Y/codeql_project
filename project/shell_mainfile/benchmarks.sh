#!/bin/bash

set -e

# project_array=(zstd usrsctp proj4)
# project_array=(zstd usrsctp proj4 libxml2 libpcap)
project_array=(binutils_cxx binutils_disass)
# ./codeql_afl_enable.sh

# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        #删除遗留文件
        rm "bm_copy"* -rf
        rm "bm_exec"* -rf

        # 数据准备
        pure_dir=$proj"_pure"
        bm_copy="bm_copy_"$proj
        bm_exec="bm_exec_"$proj
        bm_makefile="/home/cmr/my_codeql/project/shell_bm_makefile/bm_"$proj".sh"

        # 生成patch文件
        cp $pure_dir $bm_copy -r

        # 执行脚本
        $bm_makefile $bm_copy $bm_exec
        echo "脚本执行 over! ——————cmr "

        # 生成bm_fuzz文件夹
        rm bm_fuzz* -rf
        mkdir bm_fuzz bm_fuzz/in bm_fuzz/out
        cp seeds/* bm_fuzz/in/ -r
        cp $bm_exec bm_fuzz/
        # /home/cmr/my_codeql/AFLplusplus/afl-fuzz -i in -o out -m none -d -- $shell_remove_exec  @@
        echo "bm "$proj" fuzz over! ——————cmr "
    )
    cd ..
done


# CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#      CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
#      LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#      CPPFLAGS=-fsanitize=undefined,address \
#      CFLAGS=-fsanitize=undefined,address \
#      CXXFLAGS=-fsanitize=undefined,address \
#      LDFLAGS=-fsanitize=undefined,address \
#      make -j16
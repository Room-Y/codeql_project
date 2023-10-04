#!/bin/bash

set -e

CC="/home/AFLplusplus/afl-clang-fast"
CXX="/home/AFLplusplus/afl-clang-fast++"
flags="-fsanitize=undefined,address"

# /home/cmr/my_codeql/project/shell_mainfile/codeql_afl_enable.shzstd

project_array=(binutils_cxx binutils_disass)
# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

# docker run -itd -v /share:/home/project --name c2 --privileged rooml/codeql_runenv /bin/zsh
# /home/AFLplusplus/afl-fuzz -i in -o out -V 86401 -m none -d -- ./AFLPP  @@

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        # 删除遗留文件
        # rm "shell_copy"* -rf
        # rm "shell_json"* -rf
        # rm "shell_exec"* -rf

        # 数据准备
        pure_dir=$proj"_pure"

        shell_test_json="time_shell_json_test_"$proj
        shell_test_exec="time_shell_exec_test_"$proj
        
        shell_remove_copy="time_fliter_seeds_copy_"$proj
        shell_remove_json="time_fliter_seeds_json_"$proj
        shell_remove_exec="time_fliter_seeds_exec_"$proj

        remove_fuzz="time_fliter_seeds_remove_fuzz"

        shell_makefile="/home/cmr/my_codeql/project/shell_makefile/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2


        # 生成remove_json文件
        if [ 7 -ge $1 ] && [ 7 -le $2 ]; then
            rm $shell_remove_json -rf
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/remove_seed_crash.py \
                            -b $shell_test_exec \
                            -s seeds \
                            -j $shell_test_json \
                            -o $shell_remove_json
            echo "remove_json_"$proj" over! ——————cmr "
        fi

        # 插入remove_copy && remove_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            rm $shell_remove_copy -rf
            rm $shell_remove_exec -rf
            cp $pure_dir $shell_remove_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_remove_json \
                            -s $shell_remove_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "remove_copy_"$proj" over! ——————cmr "

            # 生成remove可执行脚本
            $shell_makefile $shell_makeway_afl $shell_remove_copy $shell_remove_exec $CC $CXX $flags
            echo "exec_remove_"$proj" over! ——————cmr "
        fi

        # 生成remove_fuzz文件夹
        if [ 9 -ge $1 ] && [ 9 -le $2 ]; then
            rm $remove_fuzz -rf
            mkdir $remove_fuzz $remove_fuzz"/in" $remove_fuzz"/out"
            cp seeds/* $remove_fuzz"/in" -r
            cp $shell_remove_exec $remove_fuzz
            echo "remove_fuzz"" over! ——————cmr "
        fi
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

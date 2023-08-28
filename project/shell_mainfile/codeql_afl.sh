#!/bin/bash

set -e

# project_array=(binutils_disass)
# project_array=(zstd usrsctp proj4 libxml2 libpcap)
project_array=(proj4)
# project_array=(lcms)
/home/cmr/my_codeql/project/shell_mainfile/codeql_afl_enable.sh

# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        # 删除遗留文件
        rm "shell_copy"* -rf
        rm "shell_json"* -rf
        rm "shell_exec"* -rf

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
        shell_remove_copy="shell_copy_remove_"$proj
        shell_remove_json="shell_json_remove_"$proj
        shell_remove_exec="shell_exec_remove_"$proj
        shell_makefile="/home/cmr/my_codeql/project/shell_makefile/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        # 生成database文件
        if [ 1 -ge $1 ] && [ 1 -le $2 ]; then
            rm $shell_db -rf
            if [[ "$proj" == "binutils_disass" ]]
            then
                cp ../binutils_cxx_dir/shell_db_binutils_cxx $shell_db -r
            else
                cp $pure_dir $shell_copy -r
                /home/cmr/my_codeql/codeql_fixpattern/codeql/codeql-cli/codeql database create $shell_db --language=cpp --source-root=$shell_copy
                rm $shell_copy -rf
            fi
            echo $proj" db over!  ——————cmr"
        fi

        # 分析database生成result文件
        if [ 2 -ge $1 ] && [ 2 -le $2 ]; then
            if [[ "$proj" == "binutils_disass" ]]
            then
                cp ../binutils_cxx_dir/shell_results_binutils_cxx $shell_result
            else
                /home/cmr/my_codeql/codeql_fixpattern/codeql/codeql-cli/codeql database analyze --format=csv --rerun --output=$shell_result $shell_db codeql/cpp-queries:FixPattern
            fi

            if [[ "$proj" == "binutils_cxx" ]]
            then
                sed -i '/chew.c/d' $shell_result
            fi

            echo $proj" result over!  ——————cmr"
        fi

        # 生成test_json文件
        if [ 3 -ge $1 ] && [ 3 -le $2 ]; then
            cp $pure_dir $shell_test_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/process_codeql_results.py \
                            -p $shell_test_copy  \
                            -r $shell_result \
                            -o $shell_test_json 
            echo "test json "$proj" over!  ——————cmr"
        fi

        # 生成test_copy && test_exec 文件
        if [ 4 -ge $1 ] && [ 4 -le $2 ]; then
            # 生成test_copy
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_test_json \
                            -s $shell_test_copy \
                            -c -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1

            # 生成test可执行脚本
            $shell_makefile $shell_makeway_gcc $shell_test_copy $shell_test_exec
            # rm $shell_test_copy -rf
            echo "exec_test_"$proj" over! ——————cmr "
        fi



        # 插入test_all_copy && test_all_exec 文件
        if [ 5 -ge $1 ] && [ 5 -le $2 ]; then
            cp $pure_dir $shell_test_all_copy -r
            # 生成test_all_copy
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_test_json \
                            -s $shell_test_all_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1

            # 生成test_all可执行脚本
            $shell_makefile $shell_makeway_afl $shell_test_all_copy $shell_test_all_exec
            # rm $shell_test_copy -rf
            echo "exec_test_all_"$proj" over! ——————cmr "
        fi

        # afl执行test脚本 && 并挑选种子
        if [ 6 -ge $1 ] && [ 6 -le $2 ]; then
            rm test_fuzz -rf
            mkdir test_fuzz test_fuzz/in test_fuzz/out
            cp seeds/* test_fuzz/in/ -r
            cp $shell_test_exec test_fuzz/

            cd test_fuzz
            pwd
            /home/cmr/my_codeql/AFLplusplus/afl-fuzz -i in -o out -V 301 -m none -d -- './'$shell_test_exec  @@

            # 通过queue文件夹挑选初始种子
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/crashseed_from_aflqueue.py \
                -b '../'$shell_test_all_exec \
                -q out/default/queue \
                -o queue_seeds
            cd ..
            echo "remove_queue_to_seed_"$proj" over! ——————cmr "
        fi


        # 生成remove_json文件
        if [ 7 -ge $1 ] && [ 7 -le $2 ]; then
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/remove_seed_crash.py \
                            -b $shell_test_exec \
                            -s test_fuzz/queue_seeds \
                            -j $shell_test_json \
                            -o $shell_remove_json
            echo "remove_json_"$proj" over! ——————cmr "
        fi

        # 插入remove_copy && remove_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            cp $pure_dir $shell_remove_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_remove_json \
                            -s $shell_remove_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "remove_copy_"$proj" over! ——————cmr "

            # 生成remove可执行脚本
            $shell_makefile $shell_makeway_afl $shell_remove_copy $shell_remove_exec
            echo "exec_remove_"$proj" over! ——————cmr "
        fi

        # 生成remove_fuzz文件夹
        if [ 9 -ge $1 ] && [ 9 -le $2 ]; then
            rm remove_fuzz -rf
            mkdir remove_fuzz remove_fuzz/in remove_fuzz/out
            cp seeds/* remove_fuzz/in/ -r
            cp $shell_remove_exec remove_fuzz/
            # /home/cmr/my_codeql/AFLplusplus/afl-fuzz -i in -o out -m none -d -- $shell_remove_exec  @@
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
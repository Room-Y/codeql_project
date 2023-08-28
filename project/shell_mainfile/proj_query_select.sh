#!/bin/bash

set -e

array=(InconsistentCheckReturnNull StrncpyFlippedArgs NoSpaceForZeroTerminator \
    ImproperArrayIndexValidation OverflowDestination BadlyBoundedWrite MissingNullTest LateNegativeTest \
    SizeCheck ArithmeticTainted UnboundedWrite OverrunWrite DoubleFree UseAfterFree OverflowBuffer \
    SuspiciousCallToStrncat VeryLikelyOverrunWrite)

# array=(InconsistentCheckReturnNull StrncpyFlippedArgs)
# array=(NoSpaceForZeroTerminator ImproperArrayIndexValidation)
# array=(OverflowDestination BadlyBoundedWrite)
# array=(OverflowBuffer LateNegativeTest)
# array=(SizeCheck ArithmeticTainted)
# array=(UnboundedWrite OverrunWrite)
# array=(DoubleFree UseAfterFree)
# array=(SuspiciousCallToStrncat VeryLikelyOverrunWrite)
# array=(MissingNullTest1 MissingNullTest2)
array=(MissingNullTest1)

pwd

mkdir -p /home/cmr/my_codeql/project/proj4_dir/query_dir
cd /home/cmr/my_codeql/project/proj4_dir/query_dir
pwd

for proj in ${array[@]}
do
    # rm $proj"_dir" -rf
    mkdir -p $proj"_dir"
    cd $proj"_dir"
    (
        pwd
        cp ../../seeds ./ -rf
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        # 数据准备
        pure_dir="/home/cmr/my_codeql/project/proj4_dir/proj4_pure"
        query_result="results_"$proj

        query_test_copy="copy_test_"$proj
        query_test_json="json_test_"$proj
        query_test_exec="exec_test_"$proj
        query_remove_copy="copy_remove_"$proj
        query_remove_json="json_remove_"$proj
        query_remove_exec="exec_remove_"$proj
        query_makefile="/home/cmr/my_codeql/project/shell_makefile/make_proj4.sh"
        query_makeway_gcc=1
        query_makeway_afl=2

        query_type='"'$proj'"'
        echo $query_type

        # 生成query_result文件
        # sed -n "/^\\$query_type/p" ../../result_a > $query_result

        # 生成test_json文件
        if [ 3 -ge $1 ] && [ 3 -le $2 ]; then
            cp $pure_dir $query_test_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/process_codeql_results.py \
                            -p $query_test_copy  \
                            -r $query_result \
                            -o $query_test_json 
            echo "test json "$proj" over!  ——————cmr"
        fi

        # 插入test_copy文件
        if [ 4 -ge $1 ] && [ 4 -le $2 ]; then
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $query_test_json \
                            -s $query_test_copy \
                            -c -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "test file "$proj" insert over!  ——————cmr"
        fi

        # 生成test可执行脚本
        if [ 5 -ge $1 ] && [ 5 -le $2 ]; then
            $query_makefile $query_makeway_gcc $query_test_copy $query_test_exec
            # rm $shell_test_copy -rf
            echo "exec_test_"$proj" over! ——————cmr "
        fi

        # 生成remove_json文件
        if [ 6 -ge $1 ] && [ 6 -le $2 ]; then
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/remove_seed_crash.py \
                            -b $query_test_exec \
                            -s seeds \
                            -j $query_test_json \
                            -o $query_remove_json
            echo "remove_json_"$proj" over! ——————cmr "
        fi

        # 插入remove_copy文件
        if [ 7 -ge $1 ] && [ 7 -le $2 ]; then
            cp $pure_dir $query_remove_copy -r
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $query_remove_json \
                            -s $query_remove_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "remove_copy_"$proj" over! ——————cmr "
        fi

        # 生成remove可执行脚本
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            $query_makefile $query_makeway_afl $query_remove_copy $query_remove_exec
            # rm $shell_remove_copy -rf
            echo "exec_remove_"$proj" over! ——————cmr "
        fi

        # 生成fuzz文件夹
        if [ 9 -ge $1 ] && [ 9 -le $2 ]; then
            rm fuzz -rf
            mkdir fuzz fuzz/in fuzz/out
            cp seeds/* fuzz/in/ -r
            cp $query_remove_exec fuzz/
            # /home/cmr/my_codeql/AFLplusplus/afl-fuzz -i in -o out -m none -d -- $shell_remove_exec  @@
            echo "fuzz"" over! ——————cmr "
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
#!/bin/bash

set -e

CC="/home/aflpp/afl-clang-fast"
CXX="/home/aflpp/afl-clang-fast++"
flags="-fsanitize=undefined,address"

# /home/cmr/my_codeql/project/shell_mainfile/codeql_afl_enable.sh
project_array=(binutils_disass)
# project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

# docker run -itd -v /share:/home/project --name c2 --privileged rooml/codeql_runenv /bin/zsh
# /home/aflpp/afl-fuzz -i in -o out -V 86401 -m none -d -- ./AFLPP  @@

for proj in ${project_array[@]}
do
    proj_dir=$proj"_dir"
    mkdir -p $proj_dir

    cd $proj_dir
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

        shell_remove_copy="new_aflpp_shell_copy_remove_"$proj
        shell_remove_json="new_json_remove_"$proj
        shell_remove_exec="new_aflpp_shell_exec_remove_"$proj
        
        test_fuzz="test_fuzz"
        seed_fuzz="seed_fuzz"
        remove_fuzz1="remove_aflpp1_fuzz"
        remove_fuzz2="remove_aflpp2_fuzz"
        remove_fuzz3="remove_aflpp3_fuzz"

        shell_makefile="/home/cmr/my_codeql/project/shell_makefile/make_"$proj".sh"
        shell_makeway_gcc=1
        shell_makeway_afl=2

        time1=`date +%s`

        # 生成database文件
        if [ 1 -ge $1 ] && [ 1 -le $2 ]; then
            rm $shell_db -rf
            cp $pure_dir $shell_copy -r
            # cp aaa $shell_copy -r
            /home/cmr/my_codeql/codeql_fixpattern/codeql/codeql-cli/codeql database create $shell_db --language=cpp --source-root=$shell_copy
            rm $shell_copy -rf
            echo $proj" db over!  ——————cmr"
        fi

        # 分析database生成result文件
        if [ 2 -ge $1 ] && [ 2 -le $2 ]; then
            rm $shell_result -rf

            /home/cmr/my_codeql/codeql_fixpattern/codeql/codeql-cli/codeql database analyze --format=csv --rerun --output=$shell_result $shell_db codeql/cpp-queries:FixPattern

            if [[ "$proj" == "binutils_cxx" || "$proj" == "binutils_disass" ]]
            then
                sed -i '/chew.c/d' $shell_result
            fi

            echo $proj" result over!  ——————cmr"
        fi

        time2=`date +%s`

        # 生成test_json文件
        if [ 3 -ge $1 ] && [ 3 -le $2 ]; then
            rm $shell_test_json -rf
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/process_codeql_results.py \
                            -p $pure_dir  \
                            -r $shell_result \
                            -o $shell_test_json 
            echo "test json "$proj" over!  ——————cmr"
        fi

        # 生成test_copy && test_exec 文件
        if [ 4 -ge $1 ] && [ 4 -le $2 ]; then
            # 生成test_copy
            rm $shell_test_copy -rf
            rm $shell_test_exec -rf
            cp $pure_dir $shell_test_copy -r

            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_test_json \
                            -s $shell_test_copy \
                            -c -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1

            # 生成test可执行脚本
            $shell_makefile $shell_makeway_gcc $shell_test_copy $shell_test_exec $CC $CXX $flags
            echo "exec_test_"$proj" over! ——————cmr "
        fi



        # 插入test_all_copy && test_all_exec 文件
        if [ 5 -ge $1 ] && [ 5 -le $2 ]; then
            rm $shell_test_all_copy -rf
            rm $shell_test_all_exec -rf
            cp $pure_dir $shell_test_all_copy -r

            # 生成test_all_copy
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_test_json \
                            -s $shell_test_all_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1

            # 生成test_all可执行脚本
            $shell_makefile $shell_makeway_afl $shell_test_all_copy $shell_test_all_exec $CC $CXX $flags
            echo "exec_test_all_"$proj" over! ——————cmr "
        fi

        # afl执行test脚本 && 并挑选种子
        if [ 6 -ge $1 ] && [ 6 -le $2 ]; then
            rm $test_fuzz -rf
            mkdir $test_fuzz $test_fuzz"/out"
            cp $seeds $test_fuzz"/in" -r
            cp $shell_test_exec $test_fuzz

            cd $test_fuzz
            pwd
            /home/aflpp/afl-fuzz -i in -o out -V 30 -m none -d -- './'$shell_test_exec  @@

            echo "select seeds !!!  ——————cmr"
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
            # rm $shell_remove_json -rf
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/remove_seed_crash.py \
                            -b $shell_test_exec \
                            -s $test_fuzz"/queue_seeds" \
                            -j $shell_test_json \
                            -o $shell_remove_json
            echo "remove_json_"$proj" over! ——————cmr "
        fi

        # 插入remove_copy && remove_exec 文件
        if [ 8 -ge $1 ] && [ 8 -le $2 ]; then
            # 生成remove_copy   
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

        time3=`date +%s`

        subtime1=$[ $time2 - $time1 ]
        subtime2=$[ $time3 - $time2 ]
        # echo $proj": " >> /home/cmr/my_codeql/project/new_test_dir/log_time1.txt
        # echo $subtime1"  "$subtime2 >> /home/cmr/my_codeql/project/new_test_dir/log_time1.txt
        # echo " " >> /home/cmr/my_codeql/project/new_test_dir/log_time1.txt

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

        # 根据seed过滤
        if [ 12 -ge $1 ] && [ 12 -le $2 ]; then
            rm $shell_seed_json -rf
            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/remove_seed_crash.py \
                            -b $shell_test_exec \
                            -s $seeds \
                            -j $shell_test_json \
                            -o $shell_seed_json
            echo "seed_json_"$proj" over! ——————cmr "

            rm $shell_seed_copy -rf
            rm $shell_seed_exec -rf
            cp $pure_dir $shell_seed_copy -r

            python3 /home/cmr/my_codeql/codeql_fixpattern/Transfor_AST/scripts/run_transfor.py \
                            -p $shell_seed_json \
                            -s $shell_seed_copy \
                            -b /home/cmr/my_codeql/llvm12/build/bin/transfor -w 1
            echo "seed_copy_"$proj" over! ——————cmr "

            # 生成remove可执行脚本
            $shell_makefile $shell_makeway_afl $shell_seed_copy $shell_seed_exec $CC $CXX $flags
            echo "exec_seed_"$proj" over! ——————cmr "

            # 生成seed_fuzz文件夹
            rm $seed_fuzz -rf
            mkdir $seed_fuzz $seed_fuzz"/out"
            cp $seeds $seed_fuzz"/in" -r
            cp $shell_remove_exec $seed_fuzz
            echo "seed_fuzz over! ——————cmr "

            echo "seed fliter over! ——————cmr "
        fi

    )

    cd ..
done


# echo "time1:"$time1"   time2:"$time2"   time3:"$time3 >> log_time.txt


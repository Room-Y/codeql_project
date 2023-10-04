#!/bin/bash

set -e
# project_array=(binutils_disass)
project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

# list_fuzz=(aflpp afl libfuzzer honggfuzz)
list_fuzz=(aflpp afl libfuzzer honggfuzz)
list_num=("1" "2" "3")

# port=21738
port=21739

for proj in ${project_array[@]}
do
    proj_dir=$proj"_dir"
    cd $proj_dir
    (
        pwd
        # 生成空文件夹  第一次启用
        # sshpass -p "seclab428" scp -r -P $port "../empty_dir" "root@210.28.133.13:/share/"$proj_dir

        # 上传seeds
        # sshpass -p "seclab428" scp -r -P $port "/home/cmr/my_codeql/project/"$proj_dir"/seeds" "root@210.28.133.13:/share/"$proj_dir

        # 上传4个fuzz可执行文件
        # sshpass -p "seclab428" scp -r -P $port "new_aflpp_shell_exec_remove_"$proj "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port "new_afl_shell_exec_remove_"$proj "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port "new_libfuzzer_shell_exec_remove_"$proj "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port "new_honggfuzz_shell_exec_remove_"$proj "root@210.28.133.13:/share/"$proj_dir

        # 上传fliter_seed可执行文件
        # cp "new_exec_seed_"$proj seed_fuzz
        # ls seed_fuzz
        # rm seed_fuzz/new_aflpp_shell_exec_remove_*
        # sshpass -p "seclab428" scp -r -P $port seed_fuzz "root@210.28.133.13:/share/"$proj_dir

        # 下载seeds_fuzz
        rm seed_fuzz -rf
        sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/seed_fuzz" ./


        # 下载4个fuzz的输出结果
        # for fuzz in ${list_fuzz[@]}
        # do
        #     (
        #         for num in ${list_num[@]}
        #         do
        #             (
        #                 remove_fuzz="remove_"$fuzz$num"_fuzz"
        #                 echo $remove_fuzz
        #                 rm $remove_fuzz -rf
        #                 sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/"$remove_fuzz ./
        #             )
        #         done
        #     )
        # done
    )

    cd ..
done
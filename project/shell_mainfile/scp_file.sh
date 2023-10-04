#!/bin/bash

set -e
project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)
# file_upload=seeds

# port=21738
port=21739

for proj in ${project_array[@]}
do
    proj_dir=$proj"_dir"
    cd $proj_dir
    (
        pwd
        
        # 生成空文件夹  第一次启用
        sshpass -p "seclab428" scp -r -P $port "../empty_dir" "root@210.28.133.13:/share/"$proj_dir

        # 上传seeds
        sshpass -p "seclab428" scp -r -P $port seeds "root@210.28.133.13:/share/"$proj_dir

        # rm $target"_remove_fuzz" -rf
        # sshpass -p "seclab428" scp -r -P 21738 "root@210.28.133.13:/share/"$proj_dir $target"_remove_fuzz"

        # sshpass -p "seclab428" scp -r -P $port AFLPP1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port AFL1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port fairfuzz1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port libfuzzer1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port honggfuzz1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir

        # 针对fliter——seed
        # sshpass -p "seclab428" scp -r -P $port time_fliter_seeds_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sudo rm time_fliter_seeds_remove_fuzz  -rf
        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/time_fliter_seeds_remove_fuzz" ./


        # 第一批次 21738
        # 上传， 删除， 下载
        # sshpass -p "seclab428" scp -r -P $port AFLPP1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port AFL1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port fairfuzz1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port libfuzzer1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port honggfuzz1_remove_fuzz "root@210.28.133.13:/share/"$proj_dir

        # rm AFLPP1_remove_fuzz  -rf
        # rm AFL1_remove_fuzz -rf
        # rm fairfuzz1_remove_fuzz -rf
        # rm libfuzzer1_remove_fuzz -rf
        # rm honggfuzz1_remove_fuzz -rf

        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/AFLPP1_remove_fuzz" ./
        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/AFL1_remove_fuzz" ./
        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/fairfuzz1_remove_fuzz" ./ 
        # sshpass -p "seclab428" scp -r -P ""$port "root@210.28.133.13:/share/"$proj_dir"/libfuzzer1_remove_fuzz" ./ 
        # sshpass -p "seclab428" scp -r -P ""$port "root@210.28.133.13:/share/"$proj_dir"/honggfuzz1_remove_fuzz" ./

        # 第二批次 21739
        # sshpass -p "seclab428" scp -r -P $port AFLPP2_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port AFL2_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P $port fairfuzz2_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P ""$port libfuzzer2_remove_fuzz "root@210.28.133.13:/share/"$proj_dir
        # sshpass -p "seclab428" scp -r -P ""$port honggfuzz2_remove_fuzz "root@210.28.133.13:/share/"$proj_dir

        # rm AFLPP2_remove_fuzz  -rf
        # rm AFL2_remove_fuzz -rf
        # rm fairfuzz2_remove_fuzz -rf
        # rm libfuzzer2_remove_fuzz -rf
        # rm honggfuzz2_remove_fuzz -rf

        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/AFLPP2_remove_fuzz" ./
        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/AFL2_remove_fuzz" ./
        # sshpass -p "seclab428" scp -r -P $port "root@210.28.133.13:/share/"$proj_dir"/fairfuzz2_remove_fuzz" ./ 
        # sshpass -p "seclab428" scp -r -P ""$port "root@210.28.133.13:/share/"$proj_dir"/libfuzzer2_remove_fuzz" ./ 
        # sshpass -p "seclab428" scp -r -P ""$port "root@210.28.133.13:/share/"$proj_dir"/honggfuzz2_remove_fuzz" ./
    )

    cd ..
done
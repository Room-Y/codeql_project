#!/bin/bash

set -e

project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

for proj in ${project_array[@]}
do
    cd $proj"_dir"
    (
        pwd
        time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${time}"

        aflexec="./AFL_shell_exec_remove_"$proj
        afpppexec="./shell_exec_remove_"$proj
        fairfuzzexec="./fairfuzz_shell_exec_remove_"$proj
        libfuzzerexec="./libfuzzer_shell_exec_remove_"$proj
        honggfuzzexec="./honggfuzz_shell_exec_remove_"$proj
        targetfile="../a"

        $aflexec $targetfile
        $afpppexec $targetfile
        $fairfuzzexec $targetfile
        $libfuzzerexec $targetfile
        $honggfuzzexec $targetfile
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
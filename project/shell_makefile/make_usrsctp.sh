#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3


if [ $1 == 1 ]
then
    cmake -Dsctp_build_programs=0 -Dsctp_debug=0 -Dsctp_invariants=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .
    make -j16
    cd fuzzer
    pwd
    gcc -DFUZZING_STAGE=0 -I . -I ../usrsctplib/ -c fuzzer_connect.c -o fuzzer_connect.o
    g++ -o fuzz_connect fuzzer_connect.o ../../../aflpp_driver.a ../usrsctplib/libusrsctp.a -lpthread
else
    CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         cmake -Dsctp_build_programs=0 -Dsctp_debug=0 -Dsctp_invariants=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .

    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
    cd fuzzer
    pwd
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
        -fsanitize=undefined,address -DFUZZING_STAGE=0 \
        -I . -I ../usrsctplib/ -c fuzzer_connect.c -o fuzzer_connect.o 
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
        -fsanitize=undefined,address -o fuzz_connect \
        fuzzer_connect.o ../../../aflpp_driver.a \
        ../usrsctplib/libusrsctp.a -lpthread
fi
cp fuzz_connect $target_exec

pwd
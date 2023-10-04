#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3

# flags="-fsanitize=undefined,address"
CC=$4
CXX=$5
flags=$6
#"-fsanitize=address"

if [ $1 == 1 ]
then
    # cmake -Dsctp_build_programs=0 -Dsctp_debug=0 -Dsctp_invariants=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .
    # make -j16
    # cd fuzzer
    # pwd
    # gcc -DFUZZING_STAGE=0 -I . -I ../usrsctplib/ -c fuzzer_connect.c -o fuzzer_connect.o
    # g++ -o fuzz_connect fuzzer_connect.o /home/cmr/my_codeql/project/aflpp_driver.a ../usrsctplib/libusrsctp.a -lpthread
    CC=$CC \
        CXX=$CXX \
        LD=$CC \
        cmake -Dsctp_build_programs=0 -Dsctp_debug=0 -Dsctp_invariants=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .
    make -j16
    cd fuzzer
    pwd
    $CC -DFUZZING_STAGE=0 \
        -I . -I ../usrsctplib/ -c fuzzer_connect.c -o fuzzer_connect.o 
    $CXX -o fuzz_connect \
        fuzzer_connect.o /home/cmr/my_codeql/project/aflpp_driver.a \
        ../usrsctplib/libusrsctp.a -lpthread
else
    CC=$CC \
        CXX=$CXX \
        LD=$CC \
        CPPFLAGS=$flags \
        CFLAGS=$flags \
        CXXFLAGS=$flags \
        cmake -Dsctp_build_programs=0 -Dsctp_debug=0 -Dsctp_invariants=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .

    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
    make -j16
    cd fuzzer
    pwd
    $CC \
        -DFUZZING_STAGE=0 \
        -I . -I ../usrsctplib/ -c fuzzer_connect.c -o fuzzer_connect.o 
    $CXX \
        -o fuzz_connect \
        fuzzer_connect.o /home/cmr/my_codeql/project/aflpp_driver.a \
        ../usrsctplib/libusrsctp.a -lpthread
fi
cp fuzz_connect $target_exec

pwd
#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3

./autogen.sh && ./configure
echo "over"

if [ $1 == 1 ]
then
    make -j16
    g++ -std=c++11 -I src test/fuzzers/standard_fuzzer.cpp src/.libs/libproj.a \
         ../../aflpp_driver.cc -o exec_proj -lpthread
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         -j16
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -std=c++11 -I src test/fuzzers/standard_fuzzer.cpp src/.libs/libproj.a \
         ../../aflpp_driver.cc -o exec_proj -lpthread
fi
cp exec_proj $target_exec

pwd
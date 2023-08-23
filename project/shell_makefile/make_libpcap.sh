#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3

mkdir build && cd build
echo "over"

if [ $1 == 1 ]
then
    cmake .. && make
    gcc -I ../ -c ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    g++ ../../../aflpp_driver.cc fuzz_both.o -o exec_libpcap libpcap.a
else
    cmake \
         CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast ..
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CPPFLAGS=-fsanitize=undefined,address \
         CFLAGS=-fsanitize=undefined,address \
         CXXFLAGS=-fsanitize=undefined,address \
         LDFLAGS=-fsanitize=undefined,address \
         -j16
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         -fsanitize=undefined,address -I ../ -c \
         ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -fsanitize=undefined,address ../../../aflpp_driver.cc \
         fuzz_both.o -o exec_libpcap libpcap.a
fi
cp exec_libpcap $target_exec

pwd
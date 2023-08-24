#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../../"$2

cd $1
pwd
git apply ../fr_injection.patch

mkdir build && cd build
echo "over"

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     cmake ..
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
     
/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     -fsanitize=undefined,address -I ../ -c \
     ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     -fsanitize=undefined,address ../../../aflpp_driver.cc \
     fuzz_both.o -o exec_libpcap libpcap.a

cp exec_libpcap $target_exec

pwd
#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../"$2

cd $1
pwd
git apply ../fr_injection.patch

./autogen.sh

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     CPPFLAGS=-fsanitize=undefined,address \
     CFLAGS=-fsanitize=undefined,address \
     CXXFLAGS=-fsanitize=undefined,address \
     ./configure

echo "over  -----cmr"

AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     -fsanitize=undefined,address -std=c++11 \
     -I src test/fuzzers/standard_fuzzer.cpp src/.libs/libproj.a \
     ../../aflpp_driver.cc -o exec_proj -lpthread

cp exec_proj $target_exec

pwd
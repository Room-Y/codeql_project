#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../"$2

cd $1
pwd

git apply ../fr_injection.patch
./autogen.sh
echo "over  ----cmr"

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     CPPFLAGS=-fsanitize=undefined,address \
     CFLAGS=-fsanitize=undefined,address \
     CXXFLAGS=-fsanitize=undefined,address \
     ./configure
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     -fsanitize=undefined,address ../cms_transform_fuzzer.cc \
     ../../aflpp_driver.cc -I include src/.libs/liblcms2.a \
     -o exec_lcms

cp exec_lcms $target_exec

pwd
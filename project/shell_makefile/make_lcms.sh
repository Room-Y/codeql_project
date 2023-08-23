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
    g++ ../cms_transform_fuzzer.cc ../../aflpp_driver.cc \
         -I include src/.libs/liblcms2.a -o exec_lcms
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CPPFLAGS=-fsanitize=undefined,address \
         CFLAGS=-fsanitize=undefined,address \
         CXXFLAGS=-fsanitize=undefined,address \
         LDFLAGS=-fsanitize=undefined,address \
         -j16
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -fsanitize=undefined,address ../cms_transform_fuzzer.cc \
         ../../aflpp_driver.cc -I include src/.libs/liblcms2.a \
         -o exec_lcms
fi
cp exec_lcms $target_exec

pwd
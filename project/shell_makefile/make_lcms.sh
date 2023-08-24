#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3

./autogen.sh


echo "over"

if [ $1 == 1 ]
then
     ./configure
     make -j16
     g++ ../cms_transform_fuzzer.cc ../../aflpp_driver.cc \
         -I include src/.libs/liblcms2.a -o exec_lcms
else
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
fi
cp exec_lcms $target_exec

pwd
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
    ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    make -j16
    g++ -std=c++11 ../target.cc ../../aflpp_driver.cc -I include .libs/libxml2.a -o exec_libxml2
else
     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         CPPFLAGS=-fsanitize=undefined,address \
         CFLAGS=-fsanitize=undefined,address \
         CXXFLAGS=-fsanitize=undefined,address \
         ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -fsanitize=undefined,address -std=c++11 \
         ../target.cc ../../aflpp_driver.cc -I include .libs/libxml2.a \
         -o exec_libxml2
fi
cp exec_libxml2 $target_exec

pwd
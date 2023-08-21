#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3


./autogen.sh && ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
echo "over"

if [ $1 == 1 ]
then
    make -j16
    g++ -std=c++11 ../target.cc ../../aflpp_driver.cc -I include .libs/libxml2.a -o exec_libxml2
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         -j16
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -std=c++11 ../target.cc ../../aflpp_driver.cc -I include .libs/libxml2.a \
         -o exec_libxml2
fi
cp exec_libxml2 $target_exec

pwd
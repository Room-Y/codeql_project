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
    ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no

echo "over"

AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16

/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
        -fsanitize=undefined,address -std=c++11 \
        ../target.cc ../../aflpp_driver.cc -I include .libs/libxml2.a \
        -o exec_libxml2

cp exec_libxml2 $target_exec

pwd
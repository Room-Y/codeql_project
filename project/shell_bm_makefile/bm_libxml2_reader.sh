#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../"$2

cd $1
pwd
git apply ../fr_injection.patch

./autogen.sh
make clean

echo "over ------cmr"

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     CPPFLAGS=-fsanitize=undefined,address \
     CFLAGS=-fsanitize=undefined,address \
     CXXFLAGS=-fsanitize=undefined,address \
     ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make all
/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     -fsanitize=undefined,address -std=c++11 \
     -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
     ../../aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a

cp exec_libxml2_reader $target_exec

pwd
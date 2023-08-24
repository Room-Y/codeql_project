#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3


./autogen.sh
make clean
echo "over"

if [ $1 == 1 ]
then
     ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
     make all
     g++ -std=c++11 -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
         ../../aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a
else
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
fi
cp exec_libxml2_reader $target_exec

pwd
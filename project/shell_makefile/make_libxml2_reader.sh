#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3


./autogen.sh && ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
make clean
echo "over"

if [ $1 == 1 ]
then
    make all
    g++ -std=c++11 -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
         ../../aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         all
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         -std=c++11 -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
         ../../aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a
fi
cp exec_libxml2_reader $target_exec

pwd
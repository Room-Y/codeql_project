#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3
CC=$4
CXX=$5
flags=$6
./autogen.sh
make clean
echo "over"

# flags="-fsanitize=undefined,address"
#"-fsanitize=address"

if [ $1 == 1 ]
then
    #  ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    #  make all
    #  g++ -std=c++11 -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
    #      /home/cmr/my_codeql/project/aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a
    CC=$CC \
        CXX=$CXX \
        ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    make all
    $CXX -std=c++11 \
        -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
        /home/cmr/my_codeql/project/aflpp_driver.cc -o exec_libxml2_reader .libs/libxml2.a
else
    CC=$CC \
        CXX=$CXX \
        CPPFLAGS=$flags \
        CFLAGS=$flags \
        CXXFLAGS=$flags \
        ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make all
    $CXX \
        -std=c++11 \
        -I include ../libxml2_xml_reader_for_file_fuzzer.cc \
        /home/cmr/my_codeql/project/aflpp_driver.a -o exec_libxml2_reader .libs/libxml2.a
fi
cp exec_libxml2_reader $target_exec

pwd
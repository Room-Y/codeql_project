#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../"$3
CC=$4
CXX=$5
flags1="-fsanitize=fuzzer-no-link,undefined,address"
flags2=$6
./autogen.sh
echo "over"


# flags="-fsanitize=undefined,address"
#"-fsanitize=address"

if [ $1 == 1 ]
then
    # ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    # make -j16
    # g++ -std=c++11 ../target.cc /home/cmr/my_codeql/project/aflpp_driver.cc -I include .libs/libxml2.a -o exec_libxml2
     CC=$CC \
         CXX=$CXX \
         ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    make -j16
    $CXX -std=c++11 \
         ../target.cc /home/cmr/my_codeql/project/aflpp_driver.cc -I include .libs/libxml2.a \
         -o exec_libxml2
else
     CC=$CC \
         CXX=$CXX \
         CPPFLAGS=$flags1 \
         CFLAGS=$flags1 \
         CXXFLAGS=$flags1 \
         ./configure --without-python --with-threads=no --with-zlib=no --with-lzma=no
    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
    $CXX \
         $flags2 -std=c++11 \
         ../target.cc /home/cmr/my_codeql/project/aflpp_driver.a -I include .libs/libxml2.a \
         -o exec_libxml2
fi
cp exec_libxml2 $target_exec

pwd
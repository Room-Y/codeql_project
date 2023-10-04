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
echo "over"

# flags="-fsanitize=undefined,address"
#"-fsanitize=address"

if [ $1 == 1 ]
then
     CC=$CC \
          CXX=$CXX \
          ./configure
     make -j16

     $CXX -std=c++11 \
         -I src test/fuzzers/standard_fuzzer.cpp src/.libs/libproj.a \
         /home/cmr/my_codeql/project/aflpp_driver.cc -o exec_proj -lpthread
else
     CC=$CC \
          CXX=$CXX \
          CPPFLAGS=$flags \
          CFLAGS=$flags \
          CXXFLAGS=$flags \
          ./configure
     AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16

     $CXX \
         -std=c++11 \
         -I src test/fuzzers/standard_fuzzer.cpp src/.libs/libproj.a \
         /home/cmr/my_codeql/project/aflpp_driver.a -o exec_proj -lpthread
fi

cp exec_proj $target_exec

pwd
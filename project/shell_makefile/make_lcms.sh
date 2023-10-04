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

# flags="-fsanitize=undefined,address"
#"-fsanitize=address"
# AFL_USE_ASAN=1 AFL_USE_UBSAN=1

echo "over"

if [ $1 == 1 ]
then
    #  ./configure
    #  make -j16
    #  g++ ../cms_transform_fuzzer.cc /home/cmr/my_codeql/project/aflpp_driver.cc \
    #      -I include src/.libs/liblcms2.a -o exec_lcms
     CC=$CC \
         CXX=$CXX \
         ./configure
     make -j16
     $CXX ../cms_transform_fuzzer.cc \
          /home/cmr/my_codeql/project/aflpp_driver.cc -I include src/.libs/liblcms2.a \
          -o exec_lcms
else
     CC=$CC \
         CXX=$CXX \
         CPPFLAGS=$flags \
         CFLAGS=$flags \
         CXXFLAGS=$flags \
         ./configure
     AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
     $CXX \
          ../cms_transform_fuzzer.cc \
          /home/cmr/my_codeql/project/aflpp_driver.a -I include src/.libs/liblcms2.a \
          -o exec_lcms
fi
cp exec_lcms $target_exec

pwd
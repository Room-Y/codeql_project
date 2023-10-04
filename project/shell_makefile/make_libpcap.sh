#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3
CC=$4
CXX=$5
flags=$6

mkdir build && cd build
echo "over"

# flags="-fsanitize=undefined,address"
#"-fsanitize=address"

if [ $1 == 1 ]
then
#     cmake .. && make
#     gcc -I ../ -c ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
#     g++ /home/cmr/my_codeql/project/aflpp_driver.cc fuzz_both.o -o exec_libpcap libpcap.a
     # sed '1i add_definitions(-fsanitize=undefined,address -g)' ../CMakeLists.txt
     CC=$CC \
          CXX=$CXX \
          LD=$CC \
          cmake ..
     make -j16
         
    $CC -I ../ -c \
          ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    $CXX /home/cmr/my_codeql/project/aflpp_driver.cc \
          fuzz_both.o -o exec_libpcap libpcap.a
else
     # sed '1i add_definitions(-fsanitize=undefined,address -g)' ../CMakeLists.txt
     CC=$CC \
          CXX=$CXX \
          LD=$CC \
          CPPFLAGS=$flags \
          CFLAGS=$flags \
          CXXFLAGS=$flags \
          cmake ..
     AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
         
    $CC \
          -I ../ -c \
          ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    $CXX \
          /home/cmr/my_codeql/project/aflpp_driver.a \
          fuzz_both.o -o exec_libpcap libpcap.a
fi
cp exec_libpcap $target_exec

pwd
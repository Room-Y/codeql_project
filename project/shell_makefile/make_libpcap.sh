#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3

mkdir build && cd build
echo "over"

if [ $1 == 1 ]
then
    cmake .. && make
    gcc -I ../ -c ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    g++ ../../../aflpp_driver.cc fuzz_both.o -o exec_libpcap libpcap.a
else
     # sed '1i add_definitions(-fsanitize=undefined,address -g)' ../CMakeLists.txt
     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
          LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          cmake ..
     # CPPFLAGS="-fsanitize=undefined,address -g" \
     #      CFLAGS="-fsanitize=undefined,address -g" \
     #      CXXFLAGS="-fsanitize=undefined,address -g" \
     #      LDFLAGS="-fsanitize=undefined,address -g" \
     #      CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     #      CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     #      LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j16
         
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          -fsanitize=undefined,address -I ../ -c \
          ../testprogs/fuzz/fuzz_both.c -o fuzz_both.o
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
          -fsanitize=undefined,address ../../../aflpp_driver.cc \
          fuzz_both.o -o exec_libpcap libpcap.a
fi
cp exec_libpcap $target_exec

pwd
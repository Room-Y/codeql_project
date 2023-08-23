#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3
./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
            --disable-libdecnumber --disable-readline --disable-sim \
            --enable-targets=all --disable-werror
echo "over"

if [ $1 == 1 ]
then
    make -j1
    mkdir -p fuzz &&  cp ../fuzz_*.c fuzz/  &&  cd fuzz
    gcc -I ../include -I ../bfd -I ../opcodes -c fuzz_disassemble.c \
         -o fuzz_disassemble.o
    g++ fuzz_disassemble.o -o fuzz_disassemble ../../../aflpp_driver.a \
         ../opcodes/libopcodes.a ../bfd/libbfd.a ../libiberty/libiberty.a \
         ../zlib/libz.a -ldl
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CPPFLAGS=-fsanitize=undefined,address \
         CFLAGS=-fsanitize=undefined,address \
         CXXFLAGS=-fsanitize=undefined,address \
         LDFLAGS=-fsanitize=undefined,address \
         -j1
    mkdir -p fuzz &&  cp ../fuzz_*.c fuzz/  &&  cd fuzz
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          -fsanitize=undefined,address \
         -I ../include -I ../bfd -I ../opcodes -c fuzz_disassemble.c \
         -o fuzz_disassemble.o
    /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
          -fsanitize=undefined,address \
         fuzz_disassemble.o -o fuzz_disassemble ../../../aflpp_driver.a \
         ../opcodes/libopcodes.a ../bfd/libbfd.a ../libiberty/libiberty.a \
         ../zlib/libz.a -ldl
fi

cp fuzz_disassemble $target_exec
pwd
#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../../"$2

cd $1
git apply ../fr_injection.patch
pwd

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
     --disable-libdecnumber --disable-readline --disable-sim \
     --enable-targets=all --disable-werror
AFL_USE_ASAN=1 make -j16
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

cp fuzz_disassemble $target_exec
pwd
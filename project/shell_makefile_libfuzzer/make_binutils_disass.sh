#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3
CC=$4
CXX=$5

flags=$6
flags=${flags/undefined,/} 

flags1="-fsanitize=fuzzer-no-link,address"
flags2="-fsanitize=fuzzer,address"

echo "over"

if [ $1 == 1 ]
then
     # ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
     #      --disable-libdecnumber --disable-readline --disable-sim \
     #      --enable-targets=all --disable-werror
     # make -j1
     # mkdir -p fuzz &&  cp ../fuzz_*.c fuzz/  &&  cd fuzz
     # gcc -I ../include -I ../bfd -I ../opcodes -c fuzz_disassemble.c \
     #      -o fuzz_disassemble.o
     # g++ fuzz_disassemble.o -o fuzz_disassemble /home/cmr/my_codeql/project/aflpp_driver.a \
     #     ../opcodes/libopcodes.a ../bfd/libbfd.a ../libiberty/libiberty.a \
     #     ../zlib/libz.a -ldl
     CC=$CC \
          CXX=$CXX \
          ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
          --disable-libdecnumber --disable-readline --disable-sim \
          --enable-targets=all --disable-werror
     make -j16
     mkdir -p fuzz &&  cp ../fuzz_*.c fuzz/  &&  cd fuzz
     $CC \
          -I ../include -I ../bfd -I ../opcodes -c fuzz_disassemble.c \
          -o fuzz_disassemble.o
     $CXX \
          fuzz_disassemble.o -o fuzz_disassemble /home/cmr/my_codeql/project/aflpp_driver.a \
          ../opcodes/libopcodes.a ../bfd/libbfd.a ../libiberty/libiberty.a \
          ../zlib/libz.a -ldl
else
     CC=$CC \
          CXX=$CXX \
          CPPFLAGS=$flags1 \
          CFLAGS=$flags1 \
          CXXFLAGS=$flags1 \
          ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
          --disable-libdecnumber --disable-readline --disable-sim \
          --enable-targets=all --disable-werror
     make -j16
     mkdir -p fuzz &&  cp ../fuzz_*.c fuzz/  &&  cd fuzz
     $CC \
          $flags2 \
          -I ../include -I ../bfd -I ../opcodes -c fuzz_disassemble.c \
          -o fuzz_disassemble.o
     $CXX \
          $flags2 \
          fuzz_disassemble.o -o fuzz_disassemble /home/cmr/my_codeql/project/aflpp_driver.a \
          ../opcodes/libopcodes.a ../bfd/libbfd.a ../libiberty/libiberty.a \
          ../zlib/libz.a -ldl
fi

cp fuzz_disassemble $target_exec
pwd
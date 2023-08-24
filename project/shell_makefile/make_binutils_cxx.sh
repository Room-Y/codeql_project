#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2
pwd

target_exec="../../"$3

echo "over! ——————cmr "

if [ $1 == 1 ]
then
     ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
          --disable-libdecnumber --disable-readline --disable-sim \
          --enable-targets=all --disable-werror
    make -j16
    cd binutils  &&  cp ../../fuzz_cxxfilt.c ./
    sed 's/main (int argc/old_main (int argc, char **argv);\nint old_main (int argc/' cxxfilt.c > cxxfilt.h
    gcc -DHAVE_CONFIG_H -I. -I../bfd -I./../bfd -I./../include \
         -I./../zlib -DLOCALEDIR="\"/usr/local/share/locale\"" \
         -Dbin_dummy_emulation=bin_vanilla_emulation -W -Wall \
         -MT fuzz_cxxfilt.o -MD -MP -c -o fuzz_cxxfilt.o fuzz_cxxfilt.c
    g++ -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
         -I./../zlib -o fuzz_cxxfilt fuzz_cxxfilt.o bucomm.o version.o filemode.o \
         ../../../aflpp_driver.o ../bfd/.libs/libbfd.a -L/src/binutils-gdb/zlib \
         -lpthread -ldl -lz ../libiberty/libiberty.a
else
     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
          ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
          --disable-libdecnumber --disable-readline --disable-sim \
          --enable-targets=all --disable-werror
     AFL_USE_ASAN=1 make -j16
     cd binutils  &&  cp ../../fuzz_cxxfilt.c ./
     sed 's/main (int argc/old_main (int argc, char **argv);\nint old_main (int argc/' cxxfilt.c > cxxfilt.h
     /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
          -fsanitize=undefined,address \
          -DHAVE_CONFIG_H -I. -I../bfd -I./../bfd -I./../include \
          -I./../zlib -DLOCALEDIR="\"/usr/local/share/locale\"" \
          -Dbin_dummy_emulation=bin_vanilla_emulation -W -Wall \
          -MT fuzz_cxxfilt.o -MD -MP -c -o fuzz_cxxfilt.o fuzz_cxxfilt.c
     /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
          -fsanitize=undefined,address \
          -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
          -I./../zlib -o fuzz_cxxfilt fuzz_cxxfilt.o bucomm.o version.o filemode.o \
          ../../../aflpp_driver.o ../bfd/.libs/libbfd.a -L/src/binutils-gdb/zlib \
          -lpthread -ldl -lz ../libiberty/libiberty.a
fi

cp fuzz_cxxfilt $target_exec
pwd
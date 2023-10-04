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

echo "over! ——————cmr "

if [ $1 == 1 ]
then
#      ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
#           --disable-libdecnumber --disable-readline --disable-sim \
#           --enable-targets=all --disable-werror
#     make -j16
#     cd binutils  &&  cp ../../fuzz_cxxfilt.c ./
#     sed 's/main (int argc/old_main (int argc, char **argv);\nint old_main (int argc/' cxxfilt.c > cxxfilt.h
#     gcc -DHAVE_CONFIG_H -I. -I../bfd -I./../bfd -I./../include \
#          -I./../zlib -DLOCALEDIR="\"/usr/local/share/locale\"" \
#          -Dbin_dummy_emulation=bin_vanilla_emulation -W -Wall \
#          -MT fuzz_cxxfilt.o -MD -MP -c -o fuzz_cxxfilt.o fuzz_cxxfilt.c
#     g++ -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
#          -I./../zlib -o fuzz_cxxfilt fuzz_cxxfilt.o bucomm.o version.o filemode.o \
#          /home/cmr/my_codeql/project/aflpp_driver.o ../bfd/.libs/libbfd.a -L/src/binutils-gdb/zlib \
#          -lpthread -ldl -lz ../libiberty/libiberty.a
     CC=$CC \
          CXX=$CXX \
          ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
          --disable-libdecnumber --disable-readline --disable-sim \
          --enable-targets=all --disable-werror
     make -j16
     cd binutils  &&  cp ../../fuzz_cxxfilt.c ./
     sed 's/main (int argc/old_main (int argc, char **argv);\nint old_main (int argc/' cxxfilt.c > cxxfilt.h
     $CC \
          -DHAVE_CONFIG_H -I. -I../bfd -I./../bfd -I./../include \
          -I./../zlib -DLOCALEDIR="\"/usr/local/share/locale\"" \
          -Dbin_dummy_emulation=bin_vanilla_emulation -W -Wall \
          -MT fuzz_cxxfilt.o -MD -MP -c -o fuzz_cxxfilt.o fuzz_cxxfilt.c
     $CXX \
          -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
          -I./../zlib -o fuzz_cxxfilt fuzz_cxxfilt.o bucomm.o version.o filemode.o \
          /home/cmr/my_codeql/project/aflpp_driver.o ../bfd/.libs/libbfd.a -L/src/binutils-gdb/zlib \
          -lpthread -ldl -lz ../libiberty/libiberty.a
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
     cd binutils  &&  cp ../../fuzz_cxxfilt.c ./
     sed 's/main (int argc/old_main (int argc, char **argv);\nint old_main (int argc/' cxxfilt.c > cxxfilt.h
     $CC \
          $flags2 \
          -DHAVE_CONFIG_H -I. -I../bfd -I./../bfd -I./../include \
          -I./../zlib -DLOCALEDIR="\"/usr/local/share/locale\"" \
          -Dbin_dummy_emulation=bin_vanilla_emulation -W -Wall \
          -MT fuzz_cxxfilt.o -MD -MP -c -o fuzz_cxxfilt.o fuzz_cxxfilt.c
     $CXX \
          $flags2 \
          -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
          -I./../zlib -o fuzz_cxxfilt fuzz_cxxfilt.o bucomm.o version.o filemode.o \
          /home/cmr/my_codeql/project/aflpp_driver.a ../bfd/.libs/libbfd.a -L/src/binutils-gdb/zlib \
          -lpthread -ldl -lz ../libiberty/libiberty.a
fi

cp fuzz_cxxfilt $target_exec
pwd
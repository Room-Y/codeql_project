#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../../"$2

cd $1
pwd
git apply ../fr_injection.patch
cd binutils
sed -i 's/vfprintf (stderr/\/\//' elfcomm.c
sed -i 's/fprintf (stderr/\/\//' elfcomm.c
cd ../

echo "over! ——————cmr "

CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
     ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
     --disable-libdecnumber --disable-readline --disable-sim \
     --enable-targets=all --disable-werror
# make -j16
AFL_USE_ASAN=1 make -j16
# ./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
#      --disable-libdecnumber --disable-readline --disable-sim \
#      --enable-targets=all --disable-werror

     # CPPFLAGS=-fsanitize=undefined,address \
     # CFLAGS=-fsanitize=undefined,address \
     # CXXFLAGS=-fsanitize=undefined,address \

# CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#      CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
#      LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#      CPPFLAGS=-fsanitize=undefined,address \
#      CFLAGS=-fsanitize=undefined,address \
#      CXXFLAGS=-fsanitize=undefined,address \
#      LDFLAGS=-fsanitize=undefined,address \
#      make -j16



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

cp fuzz_cxxfilt $target_exec
pwd
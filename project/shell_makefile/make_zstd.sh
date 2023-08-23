#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2"/tests/fuzz"
pwd

target_exec="../../../"$3

if [ $1 == 1 ]
then
    ./fuzz.py build stream_decompress
else
    ./fuzz.py build \
        --cc /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
        --cxx /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
        --enable-asan --enable-ubsan \
        stream_decompress
fi
cp stream_decompress $target_exec

pwd
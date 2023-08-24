#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../../../"$2

cd $1
pwd
git apply ../fr_injection.patch

cd tests/fuzz

./fuzz.py build \
    --cc /home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
    --cxx /home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
    --enable-asan --enable-ubsan \
    stream_decompress

cp stream_decompress $target_exec

pwd
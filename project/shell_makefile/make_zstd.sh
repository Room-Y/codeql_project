#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

cd $2"/tests/fuzz"
pwd

target_exec="../../../"$3
CC=$4
CXX=$5


if [ $1 == 1 ]
then
    ./fuzz.py build \
        --cc $CC \
        --cxx $CXX \
        stream_decompress
else
    ./fuzz.py build \
        --cc $CC \
        --cxx $CXX \
        --enable-asan --enable-ubsan \
        stream_decompress
fi
pwd
cp stream_decompress $target_exec

pwd
#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

target_exec="../"$3

INSTALLDIR="/home/cmr/my_codeql/project/curl_dir/src/curl_install"
SRCDIC=$2

# compile install curl
# Parse the options.
OPTIND=1
CODE_COVERAGE_OPTION=""

while getopts "c" opt
do
	case "$opt" in
		c) CODE_COVERAGE_OPTION="--enable-code-coverage"
           ;;
    esac
done

shift $((OPTIND-1))

if [[ -f ${INSTALLDIR}/lib/libssl.a ]]
then
  SSLOPTION=--with-ssl=${INSTALLDIR}
else
  SSLOPTION=--without-ssl
fi

if [[ -f ${INSTALLDIR}/lib/libnghttp2.a ]]
then
  NGHTTPOPTION=--with-nghttp2=${INSTALLDIR}
else
  NGHTTPOPTION=--without-nghttp2
fi

cd $SRCDIC

# Build the library.
./buildconf
./configure --prefix=${INSTALLDIR} \
            --disable-shared \
            --enable-debug \
            --enable-maintainer-mode \
            --disable-symbol-hiding \
            --enable-ipv6 \
            --with-random=/dev/null \
            ${SSLOPTION} \
            ${NGHTTPOPTION} \
            ${CODE_COVERAGE_OPTION}

echo "over! ——————cmr "

if [ $1 == 1 ]
then
    make V=1
    make install
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         V=1
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         install
fi

# Make any explicit folders which are post install
UTFUZZDIR=${INSTALLDIR}/utfuzzer
mkdir -p ${UTFUZZDIR}

# Copy header files.
cp -v lib/curl_fnmatch.h ${UTFUZZDIR}
cd ..

# curl-fuzz内容
cp curl_fuzzer_pure tmp_curl_fuzzer -rf
cd tmp_curl_fuzzer

./buildconf
./configure ${CODE_COVERAGE_OPTION}

if [ $1 == 1 ]
then
    make all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a
    make check
else
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a
    make CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
         LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
         check
fi

cp curl_fuzzer_http $target_exec
pwd

cd ..
rm tmp_curl_fuzzer -rf
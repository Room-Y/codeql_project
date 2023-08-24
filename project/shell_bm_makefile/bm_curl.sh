#!/bin/bash

set -e

# $1 源文件 $2  $exec_name

target_exec="../"$2

export INSTALLDIR="/home/cmr/my_codeql/project/curl_dir/src/curl_install"
SRCDIC=$1

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
git apply ../fr_injection_curl.patch

# Build the library.
./buildconf
CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
    CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
    CPPFLAGS=-fsanitize=undefined,address \
    CFLAGS=-fsanitize=undefined,address \
    CXXFLAGS=-fsanitize=undefined,address \
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
sed -i '186143,186144d' lib/Makefile
sed -i '20801,20802d' src/Makefile
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make V=1
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make install

echo "over! ——————cmr "


# sed -i '344s/$/ -fsanitize=undefined,address/' Makefile
# sed -i '403s/$/ -fsanitize=undefined,address/' Makefile
# make \
#     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
#     LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     V=1
# make \
#     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
#     LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     install

# Make any explicit folders which are post install
UTFUZZDIR=${INSTALLDIR}/utfuzzer
mkdir -p ${UTFUZZDIR}

# Copy header files.
cp -v lib/curl_fnmatch.h ${UTFUZZDIR}
cd ..

# curl-fuzz内容
rm tmp_curl_fuzzer -rf
cp curl_fuzzer_pure tmp_curl_fuzzer -rf
cd tmp_curl_fuzzer
git apply ../fr_injection_curl_fuzzer.patch
export BUILD_ROOT=$PWD

./buildconf
CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
    CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
    CPPFLAGS=-fsanitize=undefined,address \
    CFLAGS=-fsanitize=undefined,address \
    CXXFLAGS=-fsanitize=undefined,address \
    ./configure ${CODE_COVERAGE_OPTION}
AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a


# sed -i '471s/$/ -fsanitize=undefined,address/' Makefile
# sed -i '499s/$/ -fsanitize=undefined,address/' Makefile
# make \
#     CC=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     CXX=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast++ \
#     LD=/home/cmr/my_codeql/AFLplusplus/afl-clang-fast \
#     all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a

cp curl_fuzzer_http $target_exec
pwd

cd ..
sudo rm -f /dev/null && sudo mknod -m 666 /dev/null c 1 3
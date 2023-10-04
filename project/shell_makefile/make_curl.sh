#!/bin/bash

set -e

# $1 gcc/afl   $2 源文件  $exec_name

target_exec="../"$3
CC=$4
CXX=$5
flags=$6
export INSTALLDIR="/home/cmr/my_codeql/project/curl_dir/src/curl_install"
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

echo "over! ——————cmr "

# Build the library.
./buildconf


if [ $1 == 1 ]
then
    CC=$CC \
        CXX=$CXX \
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
    make V=1
    make install
else
    CC=$CC \
        CXX=$CXX \
        CPPFLAGS=$flags \
        CFLAGS=$flags \
        CXXFLAGS=$flags \
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
    make V=1
    make install
fi

# Make any explicit folders which are post install
UTFUZZDIR=${INSTALLDIR}/utfuzzer
mkdir -p ${UTFUZZDIR}

# Copy header files.
cp -v lib/curl_fnmatch.h ${UTFUZZDIR}
cd ..

# curl-fuzz内容
cp /home/cmr/my_codeql/project/curl_dir/curl_fuzzer_pure tmp_curl_fuzzer -rf
cd tmp_curl_fuzzer
export BUILD_ROOT=$PWD

./buildconf

echo "arrive here curfuzzer!   ----cmr!!!"

cp ../libstandaloneengine.a ./

if [ $1 == 1 ]
then
    # ./configure ${CODE_COVERAGE_OPTION}
    # make all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a
    # # make check
    CC=$CC \
        CXX=$CXX \
        ./configure ${CODE_COVERAGE_OPTION}
    make
    # sed -i '471s/$/ -fsanitize=undefined,address/' Makefile
else
    CC=$CC \
        CXX=$CXX \
        CPPFLAGS=$flags \
        CFLAGS=$flags \
        CXXFLAGS=$flags \
        ./configure ${CODE_COVERAGE_OPTION}
    echo "kkkkkkkkkkkkkkkkkk"
    # make
    make all LIB_FUZZING_ENGINE=/home/cmr/my_codeql/project/aflpp_driver.a
fi

cp curl_fuzzer_http $target_exec
pwd

cd ..
rm tmp_curl_fuzzer -rf
# rm -f /dev/null && mknod -m 666 /dev/null c 1 3
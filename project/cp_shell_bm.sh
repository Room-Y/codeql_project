#!/bin/bash

set -e

project_array=(zstd usrsctp proj4 libxml2 libxml2_reader libpcap lcms curl binutils_cxx binutils_disass)

mkdir -p shell_bm_makefile

for proj in ${project_array[@]}
do
    cp "shell_makefile/make_"$proj".sh" "shell_bm_makefile/bm_"$proj".sh"
done
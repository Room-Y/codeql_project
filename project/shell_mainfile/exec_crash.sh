#!/bin/bash

# set -e


pwd
for file in /home/cmr/my_codeql/project/proj4_dir/bm_fuzz/crashes/*
do
    echo $file
    /home/cmr/my_codeql/project/proj4_dir/bm_fuzz/bm_exec_proj4 $file
    echo ""
done
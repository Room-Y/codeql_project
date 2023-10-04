# coding=utf-8
import argparse
import os
import subprocess
import sys
import re
import json
import numpy
import signal
import pandas as pd
from threading import Thread
from math import floor

def findAllFile(base):
    list_crash = []
    for root, ds, fs in os.walk(base):
        for f in fs:
            fullname = os.path.join(root, f)
            list_crash.append(fullname)
        break
    return list_crash


if __name__ == "__main__":
    list_proj_pd = ["lcms", "libpcap", "libxml2_reader", "libxml2", "proj4", "usrsctp", \
        "zstd", "curl", "binutils_cxx", "binutils_disass"]

    fuzzname = ["honggfuzz", "aflpp", "afl", "libfuzzer"]

    union_db = {}

    # 保存：
    # f = open('zzz_result_dir/corpus_ids_txt','w')
    # f.write(str(ids_dic))
    # f.close()
    # 读取：
    corpus_f = open('zzz_result_dir/corpus_ids_txt','r')
    corpus_db = eval(corpus_f.read())
    corpus_f.close()

    crashes_f = open('zzz_result_dir/crashes_ids_txt','r')
    crashes_db = eval(crashes_f.read())
    crashes_f.close()
    
    # 获取合并的db
    for fuzzn in fuzzname:
        union_db[fuzzn] = {}
        for proj in list_proj_pd:
            union_db[fuzzn][proj] = corpus_db[fuzzn][proj].union(crashes_db[fuzzn][proj])
    f = open('zzz_result_dir/union_corpus_crashes_ids_txt', 'w')
    f.write(str(union_db))
    f.close()

    list_db = [union_db, corpus_db, crashes_db]
    list_dbname = ["reach", "corpus", "crashes"]

    for fuzzn in fuzzname:
        list_summary = numpy.zeros([len(list_proj_pd), len(list_db)])
        for idxp, proj in enumerate(list_proj_pd):
            for idxd, db in enumerate(list_db):
                list_summary[idxp][idxd] = len(db[fuzzn][proj])
        csv = pd.DataFrame(columns=list_dbname, index=list_proj_pd, data=list_summary).astype(int)
        csv.to_csv("zzz_result_dir/final_" + fuzzn + ".csv")
        








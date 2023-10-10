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
    list_fuzz = ["afl", "aflpp", "libfuzzer", "honggfuzz"]

    crash_type_list = ["AmbiguouslySignedBitField", "ArithmeticTainted", \
    "ArithmeticUncontrolled", "BadlyBoundedWrite", "DoubleFree", "ImproperArrayIndexValidation", \
    "InconsistentCheckReturnNull", "LateNegativeTest", "MissingNullTest", "NoSpaceForZeroTerminator", \
    "OffsetUseBeforeRangeCheck", "OverflowBuffer", "OverflowDestination", "OverrunWrite", "SizeCheck", \
    "StrncpyFlippedArgs", "SuspiciousCallToStrncat", "UnboundedWrite", "UnsafeUseOfStrcat", \
    "UnterminatedVarargsCall", "UseAfterFree", "VeryLikelyOverrunWrite"]
    
    crash_idx_dic = {}
    for i, crash in enumerate(crash_type_list):
        crash_idx_dic[crash] = i
    crash_idx_dic["AmbiguouslySignedBitField_process"] = 0
    crash_idx_dic["AmbiguouslySignedBitField_check"] = 0

    
    corpus_f = open('zzz_result_dir/corpus_ids_txt','r')
    corpus_db = eval(corpus_f.read())
    corpus_f.close()

    crashes_f = open('zzz_result_dir/crashes_ids_txt','r')
    crashes_db = eval(crashes_f.read())
    crashes_f.close()

    union_f = open('zzz_result_dir/corpus_union_crashes_ids_txt','r')
    union_db = eval(union_f.read())
    union_f.close()

    list_db = [union_db, corpus_db, crashes_db]
    list_dbname = ["reach", "corpus", "crashes"]

    np_reach_triage_type = numpy.zeros([len(crash_type_list), len(list_dbname) * 5]).astype(int)

    # 四种fuzz的corpus，reach，crash结果
    for fuzzi, fuzzn in enumerate(list_fuzz):
        for dbi, db in enumerate(list_db):
            j = fuzzi * 3 + dbi
            for proj, ids in db[fuzzn].items():
                jsondir = proj + "_dir/new_json_remove_" + proj
                list_json = findAllFile(jsondir)
                for json_f in list_json:
                    if json_f.endswith(".json"):
                        with open(json_f, 'r', encoding='UTF-8') as f:
                            dict = json.load(f)
                            for d in dict:
                                if str(d["id"]) in ids:
                                    np_reach_triage_type[crash_idx_dic[d["type"]]][j] += 1



    # # 总的结果
    # print(len(union_db))
    # print(type(union_db))
    # print(len(union_db["honggfuzz"]))
    # print(type(union_db["honggfuzz"]))
    # print(type(union_db["honggfuzz"]["lcms"]))
    for dbi, db in enumerate(list_db):
        j = 12 + dbi
        for i, proj in enumerate(list_proj_pd):
            ids = set()
            for fuzz in list_fuzz:
                ids = ids.union(db[fuzz][proj])
            jsondir = proj + "_dir/new_json_remove_" + proj
            list_json = findAllFile(jsondir)
            for json_f in list_json:
                if json_f.endswith(".json"):
                    with open(json_f, 'r', encoding='UTF-8') as f:
                        dict = json.load(f)
                        for d in dict:
                            if str(d["id"]) in ids:
                                np_reach_triage_type[crash_idx_dic[d["type"]]][j] += 1


    csv = pd.DataFrame(columns=(list_dbname * 5), index=crash_type_list, data=np_reach_triage_type).astype(int)
    csv.to_csv("zzz_result_dir/bugs_triage_type.csv")
    print(csv)

        








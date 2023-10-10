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
    list_proj = ["lcms", "libpcap", "libxml2_reader", "libxml2", "proj4", "usrsctp", \
        "zstd", "curl", "binutils_cxx", "binutils_disass", "sum"]
    
    crash_type_list = ["AmbiguouslySignedBitField", "ArithmeticTainted", \
        "ArithmeticUncontrolled", "BadlyBoundedWrite", "DoubleFree", "ImproperArrayIndexValidation", \
        "InconsistentCheckReturnNull", "LateNegativeTest", "MissingNullTest", "NoSpaceForZeroTerminator", \
        "OffsetUseBeforeRangeCheck", "OverflowBuffer", "OverflowDestination", "OverrunWrite", "SizeCheck", \
        "StrncpyFlippedArgs", "SuspiciousCallToStrncat", "UnboundedWrite", "UnsafeUseOfStrcat", \
        "UnterminatedVarargsCall", "UseAfterFree", "VeryLikelyOverrunWrite", "sum"]
    
    crash_idx_dic = {}
    for i, crash in enumerate(crash_type_list):
        crash_idx_dic[crash] = i
    crash_idx_dic["AmbiguouslySignedBitField_process"] = 0
    crash_idx_dic["AmbiguouslySignedBitField_check"] = 0

    np_inject = numpy.zeros([len(crash_type_list), len(list_proj)]).astype(int)

    
    for j, proj in enumerate(list_proj):
        if proj == "sum":
            for i, crash in enumerate(crash_type_list):
                print(np_inject[i])
                np_inject[i][j] = sum(np_inject[i])
            continue

        jsondir = proj + "_dir/new_json_remove_" + proj
        list_json = findAllFile(jsondir)
        print(proj)
        print("len_list_json:", len(list_json))

        suma = 0

        for json_f in list_json:
            if json_f.endswith(".json"):
                with open(json_f, 'r', encoding='UTF-8') as f:
                    dict = json.load(f)
                    suma += len(dict)
                    for d in dict:
                        np_inject[crash_idx_dic[d["type"]]][j] += 1

        sumb = 0
        for i, crash in enumerate(crash_type_list):
            sumb += np_inject[i][j]
        np_inject[len(crash_type_list)-1][j] = sumb
        print(suma, sumb)

    numpy.set_printoptions(suppress=True)
    csv = pd.DataFrame(columns=list_proj, index=crash_type_list, data=np_inject).astype(int)
    csv.to_csv("zzz_result_dir/bugs_injected_type.csv")
    print(csv)
        








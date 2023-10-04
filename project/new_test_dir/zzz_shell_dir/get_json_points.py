import argparse
import os
import subprocess
import sys
import re
import json
import numpy
import signal
import pandas as pd
from math import floor

def findAllFile(base):
    list_crash = []
    for root, ds, fs in os.walk(base):
        for f in fs:
            fullname = os.path.join(root, f)
            list_crash.append(fullname)
        break
    return list_crash


def get_jsondir_num(jsondir):
    list_json = findAllFile(jsondir)

    num = 0

    for json_f in list_json:
        if json_f.endswith(".json"):
            with open(json_f, 'r', encoding='UTF-8') as f:
                # print(f)
                dict = json.load(f)
                num += len(dict)

    return num

if __name__ == "__main__":
    list_proj = ["lcms", "libpcap", "libxml2_reader", "libxml2", "proj4", "usrsctp", "zstd", "curl", "binutils_cxx", "binutils_disass"]
    list_json = ["new_json_test_", "new_json_seed_", "new_json_remove_"]

    list_summary = []

    for proj in list_proj:
        print(proj)
        root_dir = "/home/cmr/my_codeql/project/new_test_dir/" + proj + "_dir/"
        list_json_num = []
        for json_i in list_json:
            json_dir = root_dir + json_i + proj
            list_json_num.append(get_jsondir_num(json_dir))
        
        list_summary.append(list_json_num)


    # list_summary = numpy.zeros([len(crash_type_list), len(list_proj)])

    # print(crash_dict)

    # for i in range(len(crash_type_list)):
    #     for j in range(len(list_proj)):
    #         list_summary[i][j] = int(crash_dict[list_proj[j]][crash_type_list[i]])

    numpy.set_printoptions(suppress=True)

    csv = pd.DataFrame(columns=list_json, index=list_proj, data=list_summary).astype(int)
    csv.to_csv("zzz_result_dir/json_num.csv")

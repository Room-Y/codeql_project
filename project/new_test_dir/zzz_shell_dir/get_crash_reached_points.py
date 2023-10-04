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
from pathlib import Path

crash_type_list = ["AmbiguouslySignedBitField_check", "ArithmeticTainted", \
    "ArithmeticUncontrolled", "BadlyBoundedWrite", "DoubleFree", "ImproperArrayIndexValidation", \
    "InconsistentCheckReturnNull", "LateNegativeTest", "MissingNullTest", "NoSpaceForZeroTerminator", \
    "OffsetUseBeforeRangeCheck", "OverflowBuffer", "OverflowDestination", "OverrunWrite", "SizeCheck", \
    "StrncpyFlippedArgs", "SuspiciousCallToStrncat", "UnboundedWrite", "UnsafeUseOfStrcat", \
    "UnterminatedVarargsCall", "UseAfterFree", "VeryLikelyOverrunWrite", "sum", "crash_total", "crash"]


def findAllFile(base):
    list_crash = []
    for root, ds, fs in os.walk(base):
        for f in fs:
            fullname = os.path.join(root, f)
            list_crash.append(fullname)
        break
    return list_crash


class MyThread(Thread):
    def __init__(self, func, args):
        Thread.__init__(self)
        self.func = func
        self.args = args
        self.result = None
    
    def run(self):
        self.result = self.func(*self.args)
    
    def getResult(self):
        return self.result

def get_thread_result(binfile, filter_binfile, crash_sublist):
    subids = set()
    sub_crash_num = 0
    tag = 0

    for idx, crash in enumerate(crash_sublist):
        crash = crash.replace('(', '\(')
        crash = crash.replace(')', '\)')
        if crash.endswith(".txt"):
            tag += 1
            continue

        p = subprocess.Popen(filter_binfile + " " + crash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, universal_newlines=True, preexec_fn=os.setsid)
        try:
            p.communicate(timeout=1)
        except UnicodeDecodeError:
            print("decodeError---", idx)
            continue
        except subprocess.TimeoutExpired:
            pass

        if(p.returncode == None or p.returncode != 0):
            sub_crash_num += 1
            try:
                os.killpg(p.pid, signal.SIGTERM)
            except OSError as e:
                p.terminate()
                p.wait()

            out = None
            err = None
            np = subprocess.Popen(binfile + " " + crash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,  universal_newlines=True, preexec_fn=os.setsid)
            try:
                out, err = np.communicate(timeout=1)
            except UnicodeDecodeError:
                print("decodeError---", idx)
                continue
            except subprocess.TimeoutExpired:
                print("timeoutError---")

            print(idx)
            list_id = re.findall(r"\[Reach\] (\d+)", str(out))
            subids.update(list_id)
            
            try:
                os.killpg(np.pid, signal.SIGTERM)
            except OSError as e:
                np.terminate()
                np.wait()
        else:
            try:
                os.killpg(p.pid, signal.SIGTERM)
            except OSError as e:
                p.terminate()
                p.wait()

    return subids, sub_crash_num, tag

def get_crash_points(binfile, filter_binfile, crashdir, jsondir):
    points = {}
    for type in crash_type_list:
        points[type] = 0

    list_crash = findAllFile(crashdir)
    list_json = findAllFile(jsondir)
    ids = set()


    if len(list_crash) == 0:
        print("crash file empty!", crashdir)
        points["sum"] = 0
        points["crash_total"] = 0
        points["crash"] = 0
        return points, ids

    sum = 0
    crash_total = len(list_crash)
    crash_num = 0

    corenum = 16
    size = floor(crash_total/corenum)
    if len(list_crash) < 16:
        size = 1
        corenum = len(list_crash)
    listscrash = [list_crash[i:i+size] for i in range(0, len(list_crash), size)]
    print(len(list_crash), len(listscrash))

    threads = []
    for crash_sublist in listscrash:
        t = MyThread(get_thread_result, (binfile, filter_binfile, crash_sublist))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()
        subids, sub_crash_num, tag = t.getResult()
        crash_total -= tag
        crash_num += sub_crash_num
        ids = ids.union(subids)

    print("len_list_json:", len(list_json))
    for json_f in list_json:
        if json_f.endswith(".json"):
            with open(json_f, 'r', encoding='UTF-8') as f:
                dict = json.load(f)
                for d in dict:
                    if str(d["id"]) in ids:
                        sum += 1
                        points[d["type"]] += 1

    points["sum"] = sum
    points["crash_total"] = crash_total
    points["crash"] = crash_num
    return points, ids

if __name__ == "__main__":
    list_proj = ["binutils_cxx", "binutils_disass", "lcms", "libpcap", "libxml2_reader", "libxml2", "proj4", "usrsctp", "zstd", "curl"]
    list_proj_pd = ["binutils_cxx", "binutils_disass", "lcms", "libpcap", \
        "libxml2_reader", "libxml2", "proj4", "usrsctp", "zstd", "curl", "sum"]

    # list_proj = ["binutils_disass"]

    fuzzname = ["honggfuzz", "aflpp", "afl", "libfuzzer"]
    numfuzz = ["1", "2", "3"]
    crashname = ["_fuzz/crashdir", "_fuzz/out/default/crashes", "_fuzz/out/crashes", "_fuzz/crashdir"]

    ids_dic = {}

    for idx, fuzzn in enumerate(fuzzname):
        ids_dic[fuzzn] = {}
        for proj in list_proj:
            ids_dic[fuzzn][proj] = set()

        for numf in numfuzz:
            fuzzname_num = fuzzn + numf
            crash_dict = {}

            for proj in list_proj:
                print(proj)
                root_dir = "/home/cmr/my_codeql/project/new_test_dir/" + proj + "_dir/"
                filter_binfile = root_dir + "new_clang_asan_exec_remove_" + proj
                binfile = root_dir + "new_exec_test_" + proj
                crashdir = root_dir + "remove_" + fuzzname_num + crashname[idx]
                jsondir = root_dir + "new_json_remove_" + proj
                dict, ids = get_crash_points(binfile, filter_binfile, crashdir, jsondir)

                print("ids:", ids)
                ids_dic[fuzzn][proj] = ids_dic[fuzzn][proj].union(ids)
                crash_dict[proj] = dict

            list_summary = numpy.zeros([len(crash_type_list), len(list_proj)+1])

            print(crash_dict)

            for i in range(len(crash_type_list)):
                for j in range(len(list_proj)):
                    list_summary[i][j] = int(crash_dict[list_proj[j]][crash_type_list[i]])

            for i in range(len(crash_type_list)):
                list_summary[i][len(list_proj)] = sum(list_summary[i])

            numpy.set_printoptions(suppress=True)

            csv = pd.DataFrame(columns=list_proj_pd, index=crash_type_list, data=list_summary).astype(int)
            csv.to_csv("zzz_csv_dir/crash_" + fuzzname_num + "_points.csv")

    # 保存：
    f = open('zzz_result_dir/crashes_ids_txt','w')
    f.write(str(ids_dic))
    f.close()
    # 读取：
    # f = open('C:/Users/xxx/photos.txt','r')
    # a = f.read()
    # word_index = eval(a)
    # f.close()

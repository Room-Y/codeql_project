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

    if len(list_crash) == 0:
        print("crash file empty!", crashdir)
        points["sum"] = 0
        points["crash_total"] = 0
        points["crash"] = 0
        return points


    ids = set()
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
    return points

if __name__ == "__main__":
    list_proj = ["binutils_cxx", "binutils_disass", "lcms", "libpcap", "libxml2_reader", "libxml2", "proj4", "usrsctp", "zstd", "curl"]
    # list_proj = ["binutils_disass"]

    fuzzname = ["AFLPP", "AFL", "fairfuzz", "libfuzzer", "honggfuzz"]
    numfuzz = ["1_", "2_"]
    crashname = ["remove_fuzz/out/default/crashes", "remove_fuzz/out/crashes", "remove_fuzz/out/crashes", "remove_fuzz/crashdir", "remove_fuzz/crashdir"]

    for idx, fuzzn in enumerate(fuzzname):
        for numf in numfuzz:
            fuzzname_num = fuzzn + numf
            crash_dict = {}

            for proj in list_proj:
                print(proj)
                root_dir = "/home/cmr/my_codeql/project/" + proj + "_dir/"
                filter_binfile = root_dir + "clang_asan_exec_remove_" + proj
                binfile = root_dir + "shell_exec_test_" + proj
                crashdir = root_dir + fuzzname_num + crashname[idx]
                jsondir = root_dir + "shell_json_remove_" + proj
                # jsondir = root_dir + "shell_json_test_" + proj
                dict = get_crash_points(binfile, filter_binfile, crashdir, jsondir)
                # print(dict)
                crash_dict[proj] = dict

            list_summary = numpy.zeros([len(crash_type_list), len(list_proj)])

            print(crash_dict)

            for i in range(len(crash_type_list)):
                for j in range(len(list_proj)):
                    list_summary[i][j] = int(crash_dict[list_proj[j]][crash_type_list[i]])

            numpy.set_printoptions(suppress=True)

            csv = pd.DataFrame(columns=list_proj, index=crash_type_list, data=list_summary).astype(int)
            csv.to_csv(fuzzname_num + "crash_points.csv")



# fuzzname = ""
# crashname = "remove_fuzz/out/default/crashes"
# fuzzname = "AFL_"
# crashname = "remove_fuzz/out/crashes"
# fuzzname = "fairfuzz_"
# crashname = "remove_fuzz/out/crashes"
# fuzzname = "libfuzzer_"
# crashname = "remove_fuzz/crashdir"
# fuzzname = "honggfuzz_"
# crashname = "remove_fuzz/crashdir"

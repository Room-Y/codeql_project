#!/usr/bin/env python
# -*- coding:utf-8 -*-
import os
import shutil

file = "/home/cmr/my_codeql/project/proj4_dir/shell_results_proj4"
print(type(file))

query_set = set()

f = open(file)               # 返回一个文件对象 
line = f.readline()               # 调用文件的 readline()方法 
while line: 
    query = line.split(',')[0]
    query_set.add(query)
    # print line,                   # 后面跟 ',' 将忽略换行符 
    #print(line, end = '')　      # 在 Python 3 中使用 


    line = f.readline() 
 
f.close()  


print(query_set)
print(len(query_set))
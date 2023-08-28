#!/usr/bin/env python
# -*- coding:utf-8 -*-
import os
import shutil

#对象文件的类型指定
# file_type_list = ['pdf','txt','xls','xlsx','pptx','doc'] 
file_type = "id:" 
#取得文件夹下面的所有指定类型的文件全名（路径+文件名）
# os.walk() 方法用于通过在目录树中游走输出在目录中的文件名，向上或者向下。
# for dirpath,dirnames,filenames in os.walk(folder):
#     print(dirnames)

def copy_and_rename_file(source_file, target_folder):
    shutil.copy2(source_file, target_folder)

    file_name = os.path.basename(source_file)

    target_file = os.path.join(target_folder, "new_" + file_name)

    os.rename(os.path.join(target_folder, os.path.basename(source_file)), target_file)

# def get_file_list(folder):
#     filelist = []  #存储要copy的文件全名
#     for dirpath,dirnames,filenames in os.walk(folder):
#         for file in filenames:
#             file_type = file.split('.')[-1]
#             if(file_type in file_type_list):
#                 file_fullname = os.path.join(dirpath, file) #文件全名
#                 filelist.append(file_fullname)
#     return filelist

def get_file_list(folder):
    filelist = []  #存储要copy的文件全名
    for dirpath,dirnames,filenames in os.walk(folder):
        for file in filenames:
            if(file.startswith(file_type)):
                file_fullname = os.path.join(dirpath, file) #文件全名
                filelist.append(file_fullname)
    return filelist


#将文件list里面的文件拷贝到指定目录下
def copy_file(src_file_list, dst_folder):
    print('===========copy start===========')
    for file in src_file_list:
        shutil.copy(file, dst_folder)
        
        file_name = os.path.basename(file)

        target_file = os.path.join(dst_folder, file_name[0:9])

        os.rename(os.path.join(dst_folder, file_name), target_file)
    print('===========copy end!===========')

# filelist = get_file_list(src_folder)

if(__name__=="__main__"):
    #copy源所在目录
    src_folder = r'/home/cmr/my_codeql/project/proj4_dir/bm_fuzz/out/default/crashes'  #路径最后不要加\  
    #copy到的指定目录
    dst_folder = r'/home/cmr/my_codeql/project/proj4_dir/bm_fuzz/crashes'   #路径最后不要加\ 
    
    #取得文件夹下所有指定类型的文件全名
    filelist = get_file_list(src_folder)
    copy_file(filelist, dst_folder)

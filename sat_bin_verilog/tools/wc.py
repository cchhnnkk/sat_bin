#!python
import os

def file_line_count(thefilepath):
    count = -1
    for count, line in enumerate(open(thefilepath, 'rU')):
        pass
    count += 1
    return count

def print_tree(dir_path):
    suml = 0
    for name in os.listdir(dir_path):
        full_path = os.path.join(dir_path, name)
        if(name.endswith('.v')):
            str1 = full_path
            line_cnt = file_line_count(str1);
            print str(line_cnt )+'\t:\t'+str1
            suml += line_cnt
        # if os.path.isdir(full_path):
        #     print_tree(full_path, file)
    print str(suml)+'\t:\ttotal line count'

print_tree('.')

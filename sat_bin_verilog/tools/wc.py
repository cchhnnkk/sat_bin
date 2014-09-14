#!python
import os

suml = 0

def file_line_count(thefilepath):
    count = -1
    for count, line in enumerate(open(thefilepath, 'rU')):
        pass
    count += 1
    return count

def print_tree(dir_path):
    global suml
    for name in os.listdir(dir_path):
	print name
        full_path = os.path.join(dir_path, name)
	if(name.endswith('.v') or name.endswith('.sv')):
            str1 = full_path
            line_cnt = file_line_count(str1);
            print str(line_cnt )+'\t:\t'+str1
            suml += line_cnt
        if os.path.isdir(full_path):
            print_tree(full_path)

print_tree('..\\src')
print str(suml)+'\t:\ttotal line count'

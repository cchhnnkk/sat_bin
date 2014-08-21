#!python

import re


pattern = re.compile(r'hello')

match = pattern.findall('hello hello ll')

if match:
    print match

#!/bin/bash 
find *.v *.sv *.c *.cpp *.h *.py > cscope.files
cscope -b

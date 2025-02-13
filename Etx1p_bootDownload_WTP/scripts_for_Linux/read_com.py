#!/usr/bin/python3

import sys
import re
import time
import rlcom


com = sys.argv[1] ; #'ttyUSB1'
brk_list = sys.argv[2].split(',')
max_loop = int(sys.argv[3])
# print(type(brk_list), brk_list)
ser = rlcom.RLCom(com)
ser.open()
res = 'NA'
ret = '-1'
for i in range(1,max_loop+1):
    # ret = ser.send('\r', 'stam', 1)
    ret = ser.read()
    # print(f'i:{i}, ret:<{ret}, buffer:<{ser.buffer}>')
    for brk in brk_list:
      brk = brk.strip()
      print(f'i:{i}, buffer:<{ser.buffer}>, brk:<{brk}>')
      if re.search(brk, ser.buffer):
        res = brk
        break
    if res != 'NA':
        break    

ser.close()
print(f'mode:{res}')
exit(res)



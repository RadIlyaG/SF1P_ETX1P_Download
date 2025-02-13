#!/usr/bin/python3

import sys
import re
import time
import rlcom


com = sys.argv[1]  #'ttyUSB1'
print(f'com:{com}')
ser = rlcom.RLCom(com)
ser.open()
res = 'NA'
ret = '-1'
for i in range(0,20):
    res = ser.send('\r', 'stam', 1)
    print(f'i:{i}, res:<{res}, buffer:<{ser.buffer}>')
    if re.search('PCPE>', ser.buffer):
        res = "PCPE"
        break
    elif re.search('E\r', ser.buffer):
        res = "wtp"
        break
    elif re.search('user>', ser.buffer):
        res = 'user'
        break
# time.sleep(10)    
ser.close()
print(f'mode:{res}')



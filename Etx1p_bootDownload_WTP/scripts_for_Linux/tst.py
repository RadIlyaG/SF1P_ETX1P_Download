#!/usr/bin/python3

import re
import time
import rlcom


com = 'ttyUSB1'
ser = rlcom.RLCom(com)
ser.open()
res = 'NA'
ret = '-1'
for i in range(0,20):
    res = ser.send('\r', 'stam', 1)
    print(f'res:<{res}, buffer:<{ser.buffer}>')
    if re.search('PCPE>', ser.buffer):
        res = "PCPE"
        break
    elif re.search('E\r', ser.buffer):
        res = "wtp"
        break
# time.sleep(10)    
ser.close()
print(f'mode:{res}')



#!/usr/bin/python3

import re
import time
import rlcom


com = 'ttyUSB1'
ser = rlcom.RLCom(com)
ser.open()
res = ser.send('\r\r', 'PCPE>', 2)
print(f'res:<{res}, buffer:<{ser.buffer}>')
if re.search('PCPE>', ser.buffer):
    res = ser.send('\r', 'PCPE>')
time.sleep(10)    
ser.close()



#!/usr/bin/python3

import sys
import os
import time
import re
from datetime import datetime
from pathlib import Path
import subprocess
import socket
import json
import webbrowser
import serial



class RLCom:
    def __init__(self, com):
        self.com = f'/dev/{com}'
        self.baudrate = 115200

    def open(self):
        try:
            self.ser = serial.Serial(self.com, self.baudrate, 8, 'N', 1, 0, 0, 0)
            self.ser.reset_input_buffer()
            self.ser.reset_output_buffer()
            return True
        except Exception as e:
            res = f'Fail to open {self.com}'
            print(f'{res}: {e}')
            return False

    def close(self):
        self.ser.close()

    def read(self):
        data_bytes = self.ser.in_waiting
        if data_bytes:
            rx = self.ser.read(data_bytes).decode()
        else:
            rx = ''
        self.buffer = rx
        return rx

    def send(self, sent, exp='', timeout=10):
        return self.my_send(sent, '', exp, timeout)

    def send_slow(self, sent, lett_dly, exp='', timeout=10):
        return self.my_send(sent, lett_dly, exp, timeout)

    def my_send(self, sent, lett_dly, exp, timeout):
        sent_txt = sent.replace("\r", "\\r")
        start_time = time.time()
        self.ser.reset_input_buffer()
        self.ser.reset_output_buffer()
        if lett_dly != '':
            for byte in sent:
                self.ser.write(byte.encode())
                time.sleep(lett_dly / 1000)
        else:
            self.ser.write(sent.encode())
            #print(f'sent.encode:<{sent.encode()}>')

        self.ser.flush()
        res = 0

        if exp:
            rx = ''
            res = -1
            start_time = time.time()
            while True:
                if not self.ser.writable() or not self.ser.readable():
                    self.ser.close()
                    break

                data_bytes = self.ser.in_waiting
                # print(f'data_bytes:<{data_bytes}>')
                if data_bytes:
                    try:
                        rx += self.ser.read(data_bytes).decode()
                        # print(f'rx:<{rx}>')
                        if re.search(exp, rx):
                            res = 0
                            break
                    except:
                        pass
                run_time = time.time() - start_time
                if run_time > float(timeout):
                    break

            send_time = '%.7s sec.' % (time.time() - start_time)

        else:
            send_time = 0
            rx = ''

        self.buffer = rx

        now = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
        # print(f'\n{now} Send sent:<{sent_txt}>, exp:<{exp}>, snd_time:<{send_time}>, rx:<{rx}>')
        return res



if __name__ == '__main__':
    com = sys.argv[1]
    sent = sys.argv[2]
    exp = sys.argv[3]
    to = sys.argv[4]
    print(com, sent, exp, to)

    ser  = RLCom(com) ; #RLCom('ttyUSB1')
    ser.open()
    time.sleep(1)
    ser.send(f'{sent}\r', exp, to)
    #ser.send(sent, exp, 2)   
    ser.close()

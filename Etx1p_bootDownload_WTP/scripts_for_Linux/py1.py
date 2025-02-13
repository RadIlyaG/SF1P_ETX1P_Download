#!/usr/bin/python3

import socket
import ssl
import requests
import json
import os
import re
import subprocess
import sqlite3
from sqlite3 import Error
import paramiko
import time
from subprocess import CalledProcessError, check_output



class RetriveIdTraceData:
    def __init__(self):
        self.hostname = 'ws-proxy01.rad.com'
        self.port = '10211'  # '8445'

    def get_value(self, barcode, command):
        barc = barcode[0:11]
        if command == "CSLByBarcode" or command == "MKTItem4Barcode" or command == "OperationItem4Barcode":
            barcode = barc
            traceabilityID = "null"
        elif command == "PCBTraceabilityIDData":
            barcode = "null"
            traceabilityID = barc

        context = ssl.create_default_context()
        url = 'http://' + self.hostname + ':' + self.port + '/ATE_WS/ws/rest/'
        param = command + "?" + "barcode=" + barcode + "&" + "traceabilityID=" + traceabilityID
        url = url + param
        headers = {'Authorization': 'Basic d2Vic2VydmljZXM6cmFkZXh0ZXJuYWw='}
        payload = {'TraceID': traceabilityID}
        print(f'url:{url}')
        try:
            with socket.create_connection((self.hostname, self.port)) as sock:
                r = requests.get(url, headers=headers, params=payload, verify=False)
                #print(f'status_code:{r.status_code} txt:{r.text}')
                data = json.loads(r.text)
                #print(f'data:{data}')
                inside_data = data[command][0]
                #print(f'inside_data:{inside_data}')
                return inside_data

        except Exception as error:
            gMessage = f'Error during conn: {error}'
            print(f'gMessage:{gMessage}')
            return False
            
     
class UpdateTccDB:
    def __init__(self):
        self.hostname = 'webservices03.rad.com'
        self.port = '10211'  # '8445' 
        self.url = 'http://' + self.hostname + ':' + self.port + '/ATE_WS/ws/tcc_rest/add_row?'
    
    def update_db(self):
        context = ssl.create_default_context()
        url = self.url + "barcode=IL12345678" + "&uutName=mozar" + "&hostDescription=myTester" + \
            "&date=2024.13.32" + "&time=25:26:27" + "&status=Status" + "&failTestsList=All_testsFail" + \
            "&failDescriptio=uutFail" + "&dealtByServer=IlyaGinzburg"
        # url = 'http://webservices03.rad.com:10211/ATE_WS/ws/tcc_rest/add_row?barcode=DF1002695769&uutName=ETX-2I-10G_LY/DCR/4SFPP/24SFP&hostDescription=AT-ETX-2I-10G/01&date=2024.06.03&time=06:17:01-1717384339&status=Pass&failTestsList=&failDescription=&dealtByServer=IlyaGinzburg'
        headers = {'Authorization': 'Basic d2Vic2VydmljZXM6cmFkZXh0ZXJuYWw='}
        print(f'url:{url}')
        print(f'self.hostname:{self.hostname}')
        print(f'self.port:{self.port}')
        
        try:
            with socket.create_connection((self.hostname, self.port)) as sock:
                r = requests.get(url, headers=headers, verify=False)
                print(f'status_code:{r.status_code}')
                return('0') #inside_data

        except Exception as error:
            gMessage = f'Error during conn: {error}'
            print(f'gMessage:{gMessage}')
            return False
        
        

if __name__ == '__main__':    
    #ssh = SSH()
    #ssh.connect_to()
    retrIdTra = RetriveIdTraceData()
    data = retrIdTra.get_value('DF100148093', "OperationItem4Barcode")
    if data:
        dbr_name = data['item']
        print(f'dbr_name:{dbr_name}')
    else:
        print(f'No dbr_name for DF10014809')

    data = retrIdTra.get_value('DF1001480939', "CSLByBarcode")
    csl = data['CSL']
    print(f'csl:{csl}')

    data = retrIdTra.get_value('21181408', "PCBTraceabilityIDData")
    for par in ['rownum', 'po number', 'sub_po_number', 'pdn', 'product', 'pcb_pdn', 'pcb']:
        print(f'value of {par}:{data[par]}')
        
    tcc = UpdateTccDB()
    tcc.update_db()

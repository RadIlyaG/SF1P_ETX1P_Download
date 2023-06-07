import requests
import socket
import ssl, re
import json
import urllib3
urllib3.disable_warnings()


def retriveIdTraceData(barcode, command, key='pcb'):
    # print(f'retriveIdTraceData args:{barcode}, {command}')
    barc = barcode[0:11]
    if command == 'CSLByBarcode':
        payload = {'barcode': barc}; key = 'CSL'
    elif command == 'PCBTraceabilityIDData':
        payload = {'traceabilityID': barc}
    elif command == 'MKTItem4Barcode':
        payload = {'barcode': barc}; key = 'MKT Item'
    elif command == 'OperationItem4Barcode':
        payload = {'barcode': barc}; key = 'item'
    else:
        raise Exception

    hostname = 'ws-proxy01.rad.com'
    port = '8445'
    url = "https://" + hostname + ":" + port + "/ATE_WS/ws/rest/" + command
    #print(f'url:<{url}>')

    try:
        with socket.create_connection((hostname, port)) as sock:
            headers = {'Authorization': 'Basic d2Vic2VydmljZXM6cmFkZXh0ZXJuYWw='}
            res = requests.get(url, headers=headers, params=payload, verify=False)
            if res.status_code == 200 and res.ok:
                #print(f'{res.text}')
                jsonString = res.text
                aDict = json.loads(jsonString)
                for data in aDict[command]:
                    return (data)
                #return aDict
            else:
                gMessage = f'status_code={res.status_code}, ok_state={res.ok}'
                print(gMessage)
                return False
    except Exception as error:
        print(f'Error during conn: {error}')
        return False
    
    
def getOI(id):
   return retriveIdTraceData(id, 'OperationItem4Barcode')["item"]


def getPcbName(trace):
    return retriveIdTraceData(trace, 'PCBTraceabilityIDData')["pcb"]


def getCsl(id):
    return retriveIdTraceData(id, 'CSLByBarcode')["CSL"]


def getMkt(id):
    return retriveIdTraceData(id, 'MKTItem4Barcode')["MKT Item"]


["CSL"]


if __name__ == '__main__':
    retDict = retriveIdTraceData('DC1002286279', 'OperationItem4Barcode')
    print(retDict["item"])
    retDict = retriveIdTraceData('DC1002286279', 'CSLByBarcode')
    print(retDict["CSL"])
    retDict = retriveIdTraceData('DC1002286279', 'MKTItem4Barcode')
    print(retDict["MKT Item"])
    retDict = retriveIdTraceData('21220705', 'PCBTraceabilityIDData')   # 21220570  21168739 12464176 21161248 21220705
    print(type(retDict))
    print(retDict["po number"])
    print(retDict["product"])
    print(retDict["pcb"])

    #ret = retriveIdTraceData('21181408', 'PCBTraceabilityIDData', "product")
    #print(f'ret:<{ret}>')
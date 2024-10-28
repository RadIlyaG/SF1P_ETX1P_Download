import paramiko, time
import re
import sys


def open_client(srvr_ip):
    username = 'etx-1p'
    password = '123456'
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(srvr_ip, username=username, password=password, look_for_keys=False,
                       allow_agent=False)
    new_connection = client.invoke_shell()
    return client
    
    
def close_client(client):
    client.close()
    
def get_e(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'get_e srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    cmd = f'echo 123456 | sudo -S ls /var/lib/tftpboot/secureboot/{boot_ver}/'
    close_client(client)
    
    return True
    
def goto_sec_boot(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'goto_sec_boot srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    cmd = f'echo 123456 | sudo -S ls /var/lib/tftpboot/secureboot/{boot_ver}/'
    #stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /var/lib/tftpboot/secureboot/{boot_ver}/')
    stdin, stdout, stderr = client.exec_command(cmd)
    ret1 = stdout.readlines()
    print(f'ls_ret1:{ret1}')
    
    stdin, stdout, stderr = client.exec_command('pwd')
    ret2 = stdout.readlines()
    print(f'ls_ret2:{ret2}') 
    
    close_client(client)
    
    return True

   
def fuse_new(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'fuse_new srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    
    cmd = f'ps -ef | grep {ttyDev}'
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'fuse_new grep {ttyDev} stderr: {stderr.readlines()}') 
    print(f'fuse_new grep {ttyDev} stdout: {stdout.readlines()}') 
    
    
    cmd = f'cd /var/lib/tftpboot/secureboot/{boot_ver}; pwd; ./fuse_new.sh /dev/{ttyDev}'
    print(f'fuse_new_cmd:{cmd}')
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'fuse_new stdout: {stdout.readlines()}') 
    print(f'fuse_new stderr: {stderr.readlines()}')    
    #time.sleep(1)
    
    close_client(client)    
    return True
    
def fuse_update(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'fuse_update srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    
    cmd = f'cd /var/lib/tftpboot/secureboot/{boot_ver}; pwd; ./fuse_new.sh /dev/{ttyDev}'
    print(f'fuse_update:{cmd}')
    stdin, stdout, stderr = client.exec_command(cmd)
    ret1 = stdout.readlines()
    print(f'fuse_update:{ret1}')    
    
    close_client(client)    
    return True





if __name__ == '__main__':
    print(f'main:{sys.argv}')
    func     = sys.argv[1]
    srvr_ip  = sys.argv[2]
    boot_ver = sys.argv[3]
    ttyDev   = sys.argv[4]
    boot_img = sys.argv[5]
    result = eval(func + "(srvr_ip, boot_ver, ttyDev, boot_img)")
    print(f'result:{result}')
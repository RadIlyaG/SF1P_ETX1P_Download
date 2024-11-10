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
    
def py2(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    cmd = f'python3 /home/etx-1p/ilya_g/py2.py'
    print(cmd)
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'py2 stderr: {stderr.readlines()}') 
    print(f'py2 stdout: {stdout.readlines()}') 
    
    close_client(client)
    return True
    
def get_e(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'get_e srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    
    # goto_sec_boot(srvr_ip, boot_ver, ttyDev, boot_img)
    
    cmd = f'read -n 1 buffer < /dev/{ttyDev}'
    print(cmd)
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'READ stderr: {stderr.readlines()}') 
    print(f'READ stdout: {stdout.readlines()}') 
    
    # cmd = f'echo 123456 | sudo -S echo -e "\r" > /dev/{ttyDev}'
    cmd = f'echo -e "\\r" > /dev/{ttyDev}'
    print(cmd)
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'send ENTER stderr: {stderr.readlines()}') 
    print(f'send ENTER stdout: {stdout.readlines()}') 
    
    cmd = f'echo $buffer'
    print(cmd)
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'Echo BUFFER stderr: {stderr.readlines()}') 
    print(f'Echo BUFFER stdout: {stdout.readlines()}') 
    
    
    close_client(client)
    
    return True
    
def get_e_py(srvr_ip, boot_ver, ttyDev, boot_img):
    client = open_client(srvr_ip)
    print(f'get_e_py srvr_ip:{srvr_ip}, boot_ver:{boot_ver}, ttyDev:{ttyDev}, boot_img:{boot_img}')
    ret = True
    
    # goto_sec_boot(srvr_ip, boot_ver, ttyDev, boot_img)
    
    cmd = "/home/etx-1p/ilya_g/tst.py"
    print(cmd)
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'get_e_py stderr: {stderr.readlines()}') 
    print(f'get_e_py stdout: {stdout.readlines()}')
    
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
    
    
    cmd = f'cd /var/lib/tftpboot/secureboot/{boot_ver}; pwd; echo 123456 | sudo -S ./fuse_new.sh /dev/{ttyDev}'
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
    
    cmd = f'cd /var/lib/tftpboot/secureboot/{boot_ver}; pwd; echo 123456 | sudo -S ./fuse_update.sh /dev/{ttyDev} {boot_img}'
    print(f'fuse_update:{cmd}')
    stdin, stdout, stderr = client.exec_command(cmd)
    print(f'fuse_update stdout: {stdout.readlines()}') 
    print(f'fuse_update stderr: {stderr.readlines()}')    
    
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
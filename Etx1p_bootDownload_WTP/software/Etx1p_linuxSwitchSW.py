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

    
def list_sw(srvr_ip, customer, appl, uut):
    client = open_client(srvr_ip)
    ret1 = ret2 = ret3 = ret4 = ret5 = ['0']
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /srv/nfs/versions/{uut}/')
    ret1 = stdout.readlines()
    print(f'ret1:{ret1}')
    
    # stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls -d /srv/nfs/pc*-g*-*')
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls -d /srv/nfs/pc*-g*')
    ret2 = stdout.readlines()
    print(f'ret2:{ret2}')
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /var/lib/tftpboot/fla*ge-*')
    ret3 = stdout.readlines()
    print(f'ret3:{ret3}')
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /var/lib/tftpboot/boot-scripts/set*etx*gen*')
    ret4 = stdout.readlines()
    print(f'ret4:{ret4}')
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /srv/nfs/pcpe-general/general*')
    ret5 = stdout.readlines()
    print(f'ret5:{ret5}')
    
    close_client(client)
    return True   

def switch_sw(srvr_ip, customer, appl, uut):
    client = open_client(srvr_ip)
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /srv/nfs/versions/{uut}/*.tar.gz')
    ret_vers = stdout.readlines()
    print(f'vers:{ret_vers}')
    
    app_in_vers = 'no'
    for sw in ret_vers:
        if re.search(appl, sw): 
            app_in_vers = 'yes'
    
    if app_in_vers == 'no':
        print(f'No such file or directory - /srv/nfs/versions/{uut}/{appl}')
        close_client(client)
        return False
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls -l /srv/nfs/versions/{uut}/{appl}')
    ret_vers_appl = stdout.readlines()
    print(f'si1:{ret_vers_appl}:si1')
        
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S find /srv/nfs/pcpe-{customer}/root/Images/*.tar.gz')
    ret_imgs = stdout.readlines()
    print(f'Images:{ret_imgs}, len:{len(ret_imgs)}')
    
    if len(ret_imgs) != 0:
        for sw in ret_imgs:
            if not re.search(appl, sw):
                print(f'Delete unnecessary :{sw}')
                stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S rm {sw}')
        

    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S find /srv/nfs/pcpe-{customer}/root/Images/ -name {appl}')
    ret_imgs = stdout.readlines()
    print(f'Images after delete unnecessary :{ret_imgs}, len:{len(ret_imgs)}')
    
    if len(ret_imgs) != 0:   
        print(f'file {appl} exist at Images')
        stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls -l /srv/nfs/pcpe-{customer}/root/Images/{appl}')
        ret2 = stdout.readlines()
        print(f'si2:{ret2}:si2')
        
    else:
        print(f'file {appl} does not exist at Images')
        ## let's see which file exists
        stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /srv/nfs/pcpe-{customer}/root/Images/*.tar.gz')
        ret3 = stdout.readlines()
        print(f'Images:{ret3}')
        if len(ret3)>0:
            exist_appl = ret3[0]
            print(f'exist_appl:{exist_appl}')
            
            stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S rm /srv/nfs/pcpe-{customer}/root/Images/{exist_appl}')
            ret = stdout.readlines()
            time.sleep(0.5)
            print(f'ret after rm:{ret}')
            
        
        print(f'copy :{appl}')
        stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S cp /srv/nfs/versions/{uut}/{appl} /srv/nfs/pcpe-{customer}/root/Images/')
        while not stdout.channel.exit_status_ready():
            print('.', end='')
            time.sleep(1)
        else:
            print('Copied!')
        # ret_cp = stdout.readlines()
        # time.sleep(5)
        
       
        stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls /srv/nfs/pcpe-{customer}/root/Images/*.tar.gz')
        ret2_cp = stdout.readlines()
        print(f'ret2 of copy :{ret2_cp}') 
        stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls -l /srv/nfs/pcpe-{customer}/root/Images/{appl}')
        ret2 = stdout.readlines()
        print(f'si2:{ret2}:si2')    
        
    
    close_client(client)
    return True
    
    
def del_sw(srvr_ip, customer, appl, uut):
    client = open_client(srvr_ip)

    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls  /srv/nfs/pcpe-{customer}/root/Images/')
    ret1 = stdout.readlines()
    print(f'ret1:{ret1}')
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S rm  /srv/nfs/pcpe-{customer}/root/Images/{appl}')
    ret2 = stdout.readlines()
    print(f'ret2:{ret2}')
    
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S ls  /srv/nfs/pcpe-{customer}/root/Images/')
    ret3 = stdout.readlines()
    print(f'ret3:{ret3}')
    
    close_client(client)
    return True


def switch_pcpe(srvr_ip, customer, ver, run):
    client = open_client(srvr_ip)
    
    ret = True
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S /srv/nfs/run-{ver}.sh ')
    while not stdout.channel.exit_status_ready():
        print('.', end='')
        time.sleep(2)
    else:
        print('Copied!')
    
    close_client(client)
    return ret 
    
def create_eeprom_file(srvr_ip, customer, eep_file, eep_content):
    client = open_client(srvr_ip)
    
    ret = True
    stdin, stdout, stderr = client.exec_command(f'echo 123456 | sudo -S echo {eep_content} > /var/lib/tftpboot/{eep_file}')
    #stdin, stdout, stderr = client.exec_command(f'echo {eep_content} > /var/lib/tftpboot/{eep_file}')
    ret = stdout.readlines()
    print(f'ret:{ret}')
    
    close_client(client)
    return ret 

if __name__ == '__main__':
    print(sys.argv)
    func     = sys.argv[1]
    srvr_ip  = sys.argv[2]
    customer = sys.argv[3]
    appl     = sys.argv[4]
    uut      = sys.argv[5]
    result = eval(func + "(srvr_ip, customer, appl, uut)")
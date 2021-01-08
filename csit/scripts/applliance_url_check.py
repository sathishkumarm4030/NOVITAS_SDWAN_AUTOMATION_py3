    #!/usr/bin/env python3
import sys
import os
import pandas as pd
from datetime import datetime
import time
import getpass
import csv
import requests


if __name__ == "__main__":
    fileDir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))
else:
    fileDir = os.path.dirname(os.path.realpath('__file__'))

# print fileDir
Par_Dir = os.path.dirname(fileDir)
# print Par_Dir
sys.path.append(Par_Dir)



if __name__ == "__main__":
    fileDir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))
else:
    fileDir = os.path.dirname(os.path.realpath('__file__'))

curr_file_dir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))

from csit.libraries.VersaLib import VersaLib

def get_vd_details():
    # ip = raw_input("Enter Versa Director IP address:\n")
    # print "Versa director IP:" + ip
    # ldap_user = raw_input("Enter LDAP Username for making SSH connection to VD:\n")
    # print "Versa director Username:" + ldap_user
    # ldap_passwd = getpass.getpass("Enter LDAP Password:\n")
    # user = raw_input("Enter Username for making REST actions to Versa Director :\n")
    # print "Versa director Username:" + user
    # passwd = getpass.getpass("Enter REST Password:\n")
    # cpe_user = raw_input("Enter Versa CPE Username:\n")
    # print "Versa CPE Username:" + cpe_user
    # cpe_passwd = getpass.getpass("Enter Versa CPE Password:\n")
    ip = '10.91.116.35'
    ldap_user = 'Automated'
    ldap_passwd = 'Auto@12345'
    user = 'Automated'
    passwd = 'Auto@12345'
    return {'mgmt_ip' : ip, 'username' : ldap_user,\
            'password' : ldap_passwd, 'GUIusername' : ldap_user, 'GUIpassword' : ldap_passwd}



def Check_Device_Status():
    start_time = datetime.now()
    vd_dict = get_vd_details()
    vd_dict['device_type'] = 'versa_director'
    VD1 = VersaLib('Versa_director', **vd_dict)
    # org_csv = raw_input("Enter Org names csv file:\n")
    org_csv = "ORGS.csv"
    csv_data_read = pd.read_csv(curr_file_dir + "/DATA/" + org_csv)
    # org_name = raw_input("Enter Org name:\n")
    # csv_file = raw_input("Enter Devices csv file name:\n")
    # org_name = "IPC00190"
    cpe_Detail = VD1.get_device_list_from_vd_using_rest_single_cpe(cpe_name='CPE26-MUM-SINGLE-CPE-HYBRID-IPC00073')
    print(cpe_Detail)
    cpe_Detail.append(str(start_time))
    print(cpe_Detail)
    #VD1.main_logger.info("Time elapsed: {}\n".format(datetime.now() - start_time))

    # with open(curr_file_dir + "/Topology/appliance_check2.csv", 'a') as file_writer1:
    #     data_header = ['NAME', 'ip', 'day', 'batch', 'type', 'softwareVersion', 'ping-status',
    #                    'sync-status']
    #     writer = csv.writer(file_writer1)
    #     writer.writerow(data_header)
    #     writer.writerow(cpe_Detail)

    file_name_with_path = curr_file_dir + "/LOGS/appliance_check7.csv"
    file_exists = os.path.isfile(file_name_with_path)
    data_header = ['NAME', 'ip', 'sw version', 'ping-status', 'sync-status', 'last-updated-time', 'script-executed-time']
    with open(file_name_with_path, 'a+') as file_writer:
        writer = csv.writer(file_writer)
        if not file_exists:
            writer.writerow(data_header)
        writer.writerow(cpe_Detail)


Check_Device_Status()
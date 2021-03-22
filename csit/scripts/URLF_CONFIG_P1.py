#!/usr/bin/env python3
import sys
import os
import pandas as pd
import time
import getpass
##Description
#-----------------
#This script will push URL filtering configuration to the branches.

##Steps
#-----------
#This script will perform the below steps
#1.Login to VD and give one handle for VD.
#2.It will read the DATA from CSV file.Note** Please mention properly the solution_type cloumn in CSV.
#3.Based on solution_type entered it will choose the configuartion file(j2 file) and store it a varaibale.
#4.Then this config will be pushed to the rescpective CPE.
#5.Commit and check for all the config pushed propely.

if __name__ == "__main__":
    fileDir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))
else:
    fileDir = os.path.dirname(os.path.realpath('__file__'))

print(fileDir)
Par_Dir = os.path.dirname(fileDir)
print(Par_Dir)
sys.path.append(Par_Dir)

from csit.libraries.VersaLib import VersaLib

def get_vd_details():
    global cpe_list
    ip = input("Enter Versa Director IP address:\n")
    print(("Versa director IP:" + ip))
    ldap_user = input("Enter LDAP Username for making SSH connection to VD:\n")
    print(("Versa director Username:" + ldap_user))
    ldap_passwd = getpass.getpass("Enter LDAP Password:\n")
    #GUIusername = eval(input("Enter GUIusername Username for opening gui from VD:\n"))
    #print(("Versa director Username:" + GUIusername))
    #GUIpassword = getpass.getpass("Enter GUIpassword Password:\n")
    GUIusername = 'NA'
    GUIpassword = 'NA'
    return {'mgmt_ip' : ip, 'username' : ldap_user,\
            'password' : ldap_passwd, 'GUIpassword' : GUIpassword, 'GUIusername' : GUIusername}



def DO_config_in_VD_For_CPEs():
    vd_dict = get_vd_details()
    vd_dict['device_type'] = 'versa_director'
    VD1 = VersaLib('Versa_director', **vd_dict)
    ##print (VD1.get_data_dict())
    VD1.vdnc = VD1.login()
    csv_file = input("Enter CSV file name with .csv extention.e.g.:device.csv:\n")
    #VD1.urlf_config_devices_template(VD1.vdnc, "URLF_DEVICES.csv")
    VD1.urlf_config_devices_template(VD1.vdnc, csv_file)
    print("Completed Execution")
    #VD1.urlf_appliance_file_upload(fileDir + "/Topology/URLF_1.csv")
    # print (VD1.get_org_uuid("IPC00012"))
    VD1.close(VD1.vdnc)




DO_config_in_VD_For_CPEs()
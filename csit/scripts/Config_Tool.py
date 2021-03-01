#!/usr/bin/env python3.8
import sys
import os
import pandas as pd
import time
import getpass


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
    username = input("Enter tacacs Username for making SSH & API connection to VD:\n")
    print(("Versa director Username:" + username))
    password = getpass.getpass("Enter Password:\n")
    # ip = '10.91.116.50'
    # username = 'Automated'
    # password = 'Auto@12345'
    return {'mgmt_ip' : ip, 'username' : username,\
            'password' : password, 'GUIusername' : username, 'GUIpassword' : password}



def DO_config_in_VD_For_CPEs():
    vd_dict = get_vd_details()
    # config_txt_file = input("Enter txt config file name:\n")
    config_txt_file = "sample_config_file"
    vd_dict['device_type'] = 'versa_director'
    VD1 = VersaLib('Versa_director', **vd_dict)
    VD1.vdnc = VD1.login()

    # VD1.vdnc = "1234"
    VD1.commit_config_commands_function(nc=VD1.vdnc, config_file=config_txt_file)
    VD1.close(VD1.vdnc)


DO_config_in_VD_For_CPEs()
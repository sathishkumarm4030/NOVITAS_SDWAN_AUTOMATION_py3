#!/usr/bin/env python3

import time
import pandas as pd
from netmiko import redispatch
from netmiko import ConnectHandler
import os
import requests
import sys
# from csit.Variables import Variables
# from csit.libraries.Variables import *
from Variables import *
import json
from jinja2 import Template
from jinja2 import Environment, FileSystemLoader
import ipaddress
import ipcalc
from ipcalc import IP
import itertools as it
from io import StringIO
import re
from datetime import datetime
# from csit.libraries.CalcIPV4Network import CalcIPv4Network
from CalcIPV4Network import CalcIPv4Network
from robot.api import logger
import yaml

if __name__ == "__main__":
    fileDir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))
else:
    fileDir = os.path.dirname(os.path.realpath('__file__'))

logger.info(fileDir, also_console=True)
curr_file_dir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))

file_loader = FileSystemLoader(fileDir + '/csit/libraries/J2_temps')
if __name__ == "__main__":
    file_loader = FileSystemLoader('./J2_temps')
env = Environment(loader=file_loader)


class CiscoLib:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, device_name, topofile):
        logger.info('intializing', also_console=True)
        self.data_dict = {}
        if ".csv" in topofile:
            csv_data_read = pd.read_csv(curr_file_dir + "/Topology/" + topofile, dtype=object)
            self.device_name = device_name
            self.data = csv_data_read.loc[csv_data_read['DUTs'] == device_name]
            self.csv_dict = self.data.set_index('DUTs').T.to_dict()
            for k, v in list(self.csv_dict[self.device_name].items()): exec("self." + k + '=v')
            for i, k in list(self.csv_dict[self.device_name].items()):
                self.data_dict[i] = k
        elif '.yml' in topofile:
            print((topofile))
            with open(curr_file_dir + "/Topology/" + topofile) as fp1:
                devices_dict = yaml.safe_load(fp1)
            device_dict = devices_dict[device_name]
            self.Device_name = device_name
            for k, v in list(device_dict.items()):
                # print((type(v)))
                if v == None:
                    continue
                exec("self." + k + '=v')
            for i, k in list(device_dict.items()):
                self.data_dict[i] = k

        self.vlans = []
        self.START_VLAN = int(self.START_VLAN)
        self.NO_OF_VRFS = int(self.NO_OF_VRFS)

        # for i, k in list(self.csv_dict[self.device_name].items()):
        #     self.data_dict[i] = k
        self.set_network_items(self.START_LAN_IP_SUBNET)
        self.data_dict['vlans'] = []
        self.data_dict['START_VLAN'] = int(self.data_dict['START_VLAN'])
        logger.info("intialized", also_console=True)

    def get_data_dict(self):
        return self.__dict__

    def set_vlan_items(self, START_VLAN):
        self.lan_vlan = []
        self.data_dict['lan_vlan'] = []
        self.lan = {}
        vlan_id_genr = (i for i in range(START_VLAN, START_VLAN + 11))
        for i in range(1, 11):
            self.lan[i] = {}
            lan_value = next(vlan_id_genr)
            self.lan_vlan.append(lan_value)
            self.data_dict['lan_vlan'].append(lan_value)
            self.lan[i]['vlan'] = lan_value
        return

    def convert_ipv4_to_ipv6(self, ipv4_address):
        ipv6_address = "2001"
        ipv4_address_list = ipv4_address.split(".")
        len1 = len(ipv4_address_list)
        for index, value in enumerate(ipv4_address_list):
            if index == len1 - 1:
                ipv6_address = ipv6_address + ":"
            ipv6_address = ipv6_address + ":" + value
        return ipv6_address

    def set_network_items(self, START_LAN_IP_SUBNET):
        self.set_vlan_items(self.START_VLAN)
        self.data_dict['lan_network'] = {}
        self.data_dict['lan_first_host'] = {}
        self.data_dict['lan_second_host'] = {}
        self.data_dict['lan_netmask'] = {}
        network = CalcIPv4Network(str(START_LAN_IP_SUBNET))
        network_address = (network + (i + 1) * network.size() for i in it.count())
        nw_addr = network
        for i in self.lan_vlan:
            self.data_dict['lan_network'][i] = nw_addr
            n = ipaddress.ip_network(nw_addr)
            self.data_dict['lan_first_host'][i] = str(n[1])
            self.data_dict['lan_second_host'][i] = str(n[2])
            self.data_dict['lan_netmask'][i] = str(n.netmask)
            nw_addr = next(network_address)
        network = CalcIPv4Network(str(START_LAN_IP_SUBNET))
        network_address = (network + (i + 1) * network.size() for i in it.count())
        nw_addr = network
        for i in range(1, int(self.NO_OF_VRFS) + 1):
            self.lan[i]['nw'] = nw_addr
            n = ipaddress.ip_network(nw_addr)
            self.lan[i]['first_host'] = str(n[1])
            self.lan[i]['second_host'] = str(n[2])
            self.lan[i]['second_host'] = str(n[2])
            self.lan[i]['third_host'] = str(n[3])
            if n.prefixlen < 30:
                self.lan[i]['fourth_host'] = str(n[4])
                self.lan[i]['fifth_host'] = str(n[5])
                self.lan[i]['sixth_host'] = str(n[6])
                self.lan[i]['seventh_host'] = str(n[7])
                self.lan[i]['eighth_host'] = str(n[8])
                self.lan[i]['ninth_host'] = str(n[9])
                self.lan[i]['tenth_host'] = str(n[10])
            self.lan[i]['netmask'] = str(n.netmask)
            self.lan[i]['prefixlen'] = str(n.prefixlen)
            self.lan[i]['nw_with_prefixlen'] = str(n.with_prefixlen)
            self.lan[i]['first_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[1]))
            self.lan[i]['second_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[2]))
            self.lan[i]['third_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[3]))
            self.lan[i]['fourth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[4]))
            self.lan[i]['fifth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[5]))
            self.lan[i]['sixth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[6]))
            self.lan[i]['seventh_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[7]))
            self.lan[i]['eighth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[8]))
            self.lan[i]['ninth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[9]))
            self.lan[i]['tenth_host_ipv6'] = self.convert_ipv4_to_ipv6(str(n[10]))
            self.lan[i]['ipv6_prefixlen'] = str('64')
            self.lan[i]['ipv6_nw'] = self.lan[i]['first_host_ipv6'][:-1]
            self.lan[i]['nw_with_prefixlen'] = str(n.with_prefixlen)
            self.lan[i]['ipv6_nw_with_prefixlen'] = self.lan[i]['ipv6_nw'] + "/" + self.lan[i]['ipv6_prefixlen']
            nw_addr = next(network_address)
        return

    def print_args(self):
        # print(self.data_dict)
        # print self.data_dict
        return self.data_dict

    def login(self, **kwargs):
        device_dict = {
            'device_type': self.device_type,
            'ip': self.mgmt_ip,
            'username': self.username,
            'password': self.password,
            'secret': self.password,
            'port': '22',
            # 'global_delay_factor' : 4,
        }
        self.nc = ConnectHandler(**device_dict)
        self.nc.enable()
        print((self.nc))
        time.sleep(5)
        print(("{}: {}".format(self.nc.device_type, self.nc.find_prompt())))
        return self.nc

    def close(self):
        self.nc.disconnect()
        print((str(self.nc) + " connection closed"))

    def cross_login(self):
        self.cnc = self.login(vd_login='yes')
        self.cnc.write_channel("ssh " + self.data_dict["username"] + "@" + self.data_dict["ip"] + "\n")
        time.sleep(5)
        output = self.cnc.read_channel()
        print(output)
        if 'assword:' in output:
            self.cnc.write_channel(self.data_dict["password"] + "\n")
            time.sleep(5)
            output = self.cnc.read_channel()
            print(output)
        elif 'yes' in output:
            print("am in yes condition")
            self.cnc.write_channel("yes\n")
            time.sleep(5)
            output = self.cnc.read_channel()
            print(output)
            time.sleep(1)
            self.cnc.write_channel(self.data_dict["password"] + "\n")
            time.sleep(5)
            output = self.cnc.read_channel()
            print(output)
        else:
            # cpe_logger.info(output)
            return "VD to CPE " + self.data_dict["ip"] + "ssh Failed."
        # self.cnc.write_channel("cli\n")
        # time.sleep(2)
        # output1 = self.cnc.read_channel()
        # print(output1)
        # time.sleep(2)
        try:
            print("doing redispatch")
            redispatch(self.cnc, device_type='versa')
        except ValueError as Va:
            print(Va)
            print(("Not able to get router prompt from CPE" + self.data_dict["ip"] + " CLI. please check"))
            return "Redispatch not Success"
        time.sleep(2)
        return self.cnc

    def device_config_commands(self, nc_handler, cmds):
        nc_handler.config_mode(config_command='config private')
        nc_handler.check_config_mode()
        for cmd in cmds.split("\n"):
            print((nc_handler.send_command_expect(cmd, expect_string='%', strip_prompt=False, strip_command=False)))
        nc_handler.send_command_expect('commit and-quit', expect_string='>', strip_prompt=False, strip_command=False)

    def pre_op(self):
        self.login()
        intf = str(self.LAN_INTF)
        print(self.NO_OF_VRFS)
        print(type(self.NO_OF_VRFS))
        for i in range(1, self.NO_OF_VRFS + 1):
            ip = str(self.lan[i]['ninth_host'])
            ip6 = str(self.lan[i]['ninth_host_ipv6'])
            ip6_prefixlen = str(self.lan[i]['ipv6_prefixlen'])
            gw = str(self.lan[i]['first_host'])
            nmask = str(self.lan[i]['netmask'])
            vlan = str(self.lan[i]['vlan'])
            print(self.config_interface(self.LAN_INTF, VLAN=vlan))
            print(self.config_subinterface(vlan, ip=ip, nmask=nmask))
            print(self.config_ipv6_subinterface(vlan, ip6=ip6, ip6_prefixlen=ip6_prefixlen))

    def CISCO_pre_op_dual(self):
        self.VM_nc = self.shell_login()
        self.linux_device_config_commands(self.VM_nc, "sudo bash", expect_string=":")
        self.linux_device_config_commands(self.VM_nc, "versa123", expect_string="#")
        self.linux_device_config_commands(self.VM_nc, "exit", expect_string="\$")
        self.linux_device_config_commands(self.VM_nc, "sudo ifconfig " + self.LAN_INTF + " up")
        intf = str(self.LAN_INTF)
        for i in range(1, self.NO_OF_VRFS + 1):
            ip = str(self.lan[i]['fourth_host'])
            gw = str(self.lan[i]['first_host'])
            nmask = str(self.lan[i]['netmask'])
            vlan = str(self.lan[i]['vlan'])
            self.linux_device_config_commands(self.VM_nc, "sudo vconfig add " + intf + " " + vlan)
            self.linux_device_config_commands(self.VM_nc, "sudo ifconfig " + intf + "." + vlan + " up")
            self.linux_device_config_commands(self.VM_nc,
                                              "sudo ifconfig " + intf + "." + vlan + " " + ip + " netmask " + nmask)

    def ping(self, dest_ip, **kwargs):
        cmd = "ping " + str(dest_ip)
        paramlist = ['count', 'df_bit', 'interface', 'packet_size', 'rapid', 'record-route', 'routing_instance',
                     'source']
        for element in paramlist:
            if element in list(kwargs.keys()):
                cmd = cmd + " " + element.replace('_', '-') + " " + str(kwargs[element])
        print(cmd)
        output = self.nc.send_command_expect(cmd, expect_string="#", strip_prompt=False, strip_command=False)
        print(output)
        return str("Success rate is 100 percent" in output)

    def send_show_commands_and_expect(self, cmds, expect_string="\$|#"):
        for cmd in cmds.split("\n"):
            # print cmd
            output = self.nc.send_command_expect(cmd, expect_string=expect_string, strip_prompt=False,
                                                 strip_command=False)
        # logger.info(output, also_console=True)
        return output

    def send_config_commands_and_expect(self, cmds, expect_string="\$|#"):
        self.nc.config_mode(config_command='config t')
        self.nc.check_config_mode()
        # for cmd in cmds.split("\n"):
        #     print cmd
        output = self.nc.send_config_set(config_commands=cmds, strip_prompt=False, strip_command=False, \
                                             exit_config_mode=True, cmd_verify=False)
        # logger.info(output, also_console=True)
        return output

    def config_interface(self, LAN_INTF, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in list(kwargs.items()):
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("interface.j2")
        temp_dict['LAN_INTF'] = LAN_INTF
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_subinterface(self, VLAN, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("sub_interface.j2")
        temp_dict['VLAN'] = VLAN
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def ospf_auth_sub_intf(self, VLAN, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("auth_sub_intf.j2")
        temp_dict['VLAN'] = VLAN
        cmds = template.render(temp_dict)
        print (cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def ospf_md_auth_sub_intf(self, VLAN, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("md_auth_sub_intf.j2")
        temp_dict['VLAN'] = VLAN
        cmds = template.render(temp_dict)
        print (cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_ipv6_subinterface(self, VLAN, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("ipv6_sub_interface.j2")
        temp_dict['VLAN'] = VLAN
        # temp_dict['ipv6_add'] = ipv6_add
        # temp_dict['ipv6_prefix'] = ipv6_prefix
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_bgp(self, local_as, nbr_address, remote_as, password, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("bgp.j2")
        temp_dict['local_as'] = local_as
        temp_dict['nbr_address'] = nbr_address
        temp_dict['remote_as'] = remote_as
        temp_dict['password'] = password
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_ipv6_bgp(self, local_as, nbr_address, remote_as, password, loopback_ip6, ipv6_prefix, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("ipv6_bgp.j2")
        temp_dict['local_as'] = local_as
        temp_dict['nbr_address'] = nbr_address
        temp_dict['remote_as'] = remote_as
        temp_dict['password'] = password
        temp_dict['loopback_ip6'] = loopback_ip6
        temp_dict['ipv6_prefix'] = ipv6_prefix
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def delete_bgp(self, VLAN, local_as, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("delete_bgp.j2")
        temp_dict['VLAN'] = VLAN
        temp_dict['local_as'] = local_as
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def delete_ospf(self, VLAN, ospf_instance_id, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("delete_ospf.j2")
        temp_dict['VLAN'] = VLAN
        temp_dict['ospf_instance_id'] = ospf_instance_id
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_bgp_redis(self, local_as, remote_as, nbr_address, loopback_ip, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("bgp_redis.j2")
        temp_dict['remote_as'] = remote_as
        temp_dict['loopback_ip'] = loopback_ip
        temp_dict['nbr_address'] = nbr_address
        temp_dict['local_as'] = local_as
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_ospf(self, ospf_instance_id, nw_addr, loopback_ip, ospf_area_id, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("ospf.j2")
        temp_dict['ospf_instance_id'] = ospf_instance_id
        temp_dict['nw_addr'] = nw_addr
        temp_dict['loopback_ip'] = loopback_ip
        temp_dict['ospf_area_id'] = ospf_area_id
        cmds = template.render(temp_dict)
        print (cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def ospf_auth(self, ospf_instance_id, nw_addr, loopback_ip, ospf_area_id, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("ospf_auth.j2")
        temp_dict['ospf_instance_id'] = ospf_instance_id
        temp_dict['nw_addr'] = nw_addr
        temp_dict['loopback_ip'] = loopback_ip
        temp_dict['ospf_area_id'] = ospf_area_id
        cmds = template.render(temp_dict)
        print (cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def ospf_md_auth(self, ospf_instance_id, nw_addr, loopback_ip, ospf_area_id, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("ospf_md_auth.j2")
        temp_dict['ospf_instance_id'] = ospf_instance_id
        temp_dict['nw_addr'] = nw_addr
        temp_dict['loopback_ip'] = loopback_ip
        temp_dict['ospf_area_id'] = ospf_area_id
        cmds = template.render(temp_dict)
        print (cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_loopback_intf(self, loopback_intf, loopback_ip, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("loopback_intf.j2")
        temp_dict['loopback_intf'] = loopback_intf
        temp_dict['loopback_ip'] = loopback_ip
        # temp_dict['nmask'] = nmask
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def config_loopback_intf_ipv6(self, loopback_intf, loopback_ip6, ipv6_prefix, **kwargs):
        temp_dict = {}
        if kwargs is not None:
            for k, v in kwargs.items():
                temp_dict[k] = v
        curr_file_loader = FileSystemLoader(curr_file_dir + "/libraries/J2_temps/CISCO")
        curr_env = Environment(loader=curr_file_loader)
        template = curr_env.get_template("loopback_intf_ipv6.j2")
        temp_dict['loopback_intf'] = loopback_intf
        temp_dict['loopback_ip6'] = loopback_ip6
        temp_dict['ipv6_prefix'] = ipv6_prefix
        cmds = template.render(temp_dict)
        print(cmds)
        output = self.send_config_commands_and_expect(cmds)
        return output

    def show_conf_bgp(self, local_as):
        cmd = "show running-config partition router bgp " + str(local_as)
        output = self.nc.send_command_expect(cmd, expect_string="#", strip_prompt=False, strip_command=False)
        print(output)
        return output

    def show_conf_ospf(self,ospf_instance_id):
        cmd = "show running-config partition router ospf " + str(ospf_instance_id)
        output = self.nc.send_command_expect(cmd, expect_string="#", strip_prompt=False, strip_command=False)
        print (output)
        return output

    def show_conf_loopback(self, loopback_intf):
        cmd = "show running-config interface " + str(loopback_intf)
        output = self.nc.send_command_expect(cmd, expect_string="#", strip_prompt=False, strip_command=False)
        print(output)
        return output

    def show_conf_auth_sub_intf(self,sub_intf):
        cmd = "show running-config interface " + str(sub_intf)
        output = self.nc.send_command_expect(cmd, expect_string="#", strip_prompt=False, strip_command=False)
        print (output)
        return output

def main():
    print((datetime.now()))
    VM1 = CiscoLib('CISCO_ASR920_R6', "Devices.yml")
    VM1.pre_op()
    VM2 = CiscoLib('CISCO_ASR920_R5', "Devices.yml")
    print((VM1.login()))
    print((VM2.login()))
    print((VM1.send_show_commands_and_expect("show ip interface brief")))
    cmds = """interface BD856
             desc sathishkumar123"""
    print((VM1.send_config_commands_and_expect(cmds)))
    # ip = str(VM1.lan[1]['ninth_host'])
    # ip6 = str(VM1.lan[1]['ninth_host_ipv6'])
    # ip6_prefixlen = str(VM1.lan[1]['ipv6_prefixlen'])
    # gw = str(VM1.lan[1]['first_host'])
    # nmask = str(VM1.lan[1]['netmask'])
    # vlan = str(VM1.lan[1]['vlan'])
    # print VM1.config_interface(VM1.LAN_INTF, VLAN=vlan)
    # print VM1.config_interface(VM1.LAN_INTF + "." + vlan)
    print((VM1.close()))
    print((VM2.close()))
    print((datetime.now()))


if __name__ == "__main__":
    main()

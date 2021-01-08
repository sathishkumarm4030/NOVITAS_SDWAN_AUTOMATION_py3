#!/usr/bin/env python3

# from os.path import dirname, realpath, sep, pardir
# import sys
# import os
# print "*" * 20
# # print dirname(realpath(__file__))
# # sys.path.append(dirname(realpath(__file__)))
# # sys.path.append(realpath(__file__))
# sys.path.append(os.getcwd())
# print sys.path

import time
import pandas as pd
from netmiko import redispatch
from netmiko import ConnectHandler
import os
import requests
import sys
from Variables import *
# from csit.libraries.Variables import *
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


class LinuxLib:
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
        # for vlan in range(self.START_VLAN'], self.START_VLAN']+10):
        #     print vlan
        # self.data_dict = {}
        # for i, k in self.csv_dict[self.device_name].items():
        #     self.data_dict[i] = k
        self.set_network_items(self.START_LAN_IP_SUBNET)
        # self.set_peer_network_items(self.peer_Start_lan_ip_subnet)
        # print self.data_dict
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

    # def set_vlan_items(self, START_VLAN):
    #     self.data_dict['lan_vlan'] = []
    #     vlan_id_genr = (i for i in range(START_VLAN, START_VLAN+11))
    #     for i in range(1, 11):
    #         nw_addr = next(vlan_id_genr)
    #         self.data_dict['lan_vlan'].append(nw_addr)
    #     return

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
            'device_type': 'linux',
            'ip': self.mgmt_ip,
            'username': self.username,
            'password': self.password,
            'port': '22',
            'secret': self.password,
        }
        self.shell_nc = ConnectHandler(**device_dict)
        print(self.shell_nc.find_prompt())
        self.shell_nc.enable()
        # print(self.shell_nc.send_command_expect('sudo bash', expect_string='password'))
        # print(self.shell_nc.send_command_expect(self.password, expect_string='\$|#'))
        # print((self.shell_nc.send_command_expect('exit', expect_string='\$')))
        # ur = self.shell_nc.send_command_expect('ls -ltr')
        # print ur
        # time.sleep(5)
        print(("{}: {}".format(self.shell_nc.device_type, self.shell_nc.find_prompt())))
        return self.shell_nc

    def close(self, nc):
        nc.disconnect()
        print((str(nc) + " connection closed"))


    def create_template(self, template_name):
        template = env.get_template(template_name)
        return template.render(self.data_dict)

    def device_config_commands(self, nc_handler, cmds):
        nc_handler.config_mode(config_command='config private')
        nc_handler.check_config_mode()
        for cmd in cmds.split("\n"):
            print((nc_handler.send_command_expect(cmd, expect_string='%', strip_prompt=False, strip_command=False)))
        nc_handler.send_command_expect('commit and-quit', expect_string='>', strip_prompt=False, strip_command=False)

    def linux_device_config_commands(self, nc_handler, cmds, expect_string="\$|#"):
        for cmd in cmds.split("\n"):
            # print cmd
            nc_handler.send_command_expect(cmd, expect_string=expect_string, strip_prompt=False,
                                           strip_command=False)


    def VM_pre_op(self):
        self.VM_nc = self.login()
        # self.linux_device_config_commands(self.VM_nc, "sudo bash", expect_string=":")
        # self.linux_device_config_commands(self.VM_nc, "versa123", expect_string="#")
        # self.linux_device_config_commands(self.VM_nc, "exit", expect_string="\$")
        self.linux_device_config_commands(self.VM_nc, "sudo ifconfig " + self.LAN_INTF + " up")
        intf = str(self.LAN_INTF)
        for i in range(1, self.NO_OF_VRFS + 1):
            ip = str(self.lan[i]['second_host'])
            ip6 = str(self.lan[i]['second_host_ipv6'])
            ip6_prefixlen = str(self.lan[i]['ipv6_prefixlen'])
            gw = str(self.lan[i]['first_host'])
            nmask = str(self.lan[i]['netmask'])
            vlan = str(self.lan[i]['vlan'])
            print(self.linux_device_config_commands(self.VM_nc, "sudo vconfig add " + intf + " " + vlan))
            self.linux_device_config_commands(self.VM_nc, "sudo ifconfig " + intf + "." + vlan + " up")
            self.linux_device_config_commands(self.VM_nc,
                                              "sudo ifconfig " + intf + "." + vlan + " " + ip + " netmask " + nmask)
            self.linux_device_config_commands(self.VM_nc,
                                              "sudo ifconfig " + intf + "." + vlan + " inet6 add " + ip6 + "/" + ip6_prefixlen)

    def VM_pre_op_dual(self):
        self.VM_nc = self.login()
        # self.linux_device_config_commands(self.VM_nc, "sudo bash", expect_string=":")
        # self.linux_device_config_commands(self.VM_nc, "versa123", expect_string="#")
        # self.linux_device_config_commands(self.VM_nc, "exit", expect_string="\$")
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

    def shell_ping(self, dest_ip, count=5, **kwargs):
        # Usage: ping [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
        #     [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
        #     [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
        #     [-w deadline] [-W timeout] [hop1 ...] destination
        cmd = "sudo ping " + str(dest_ip) + " -c " + str(count)
        paramlist = ['count', 'df_bit', 'interface', 'packet_size', 'rapid', 'record-route', 'routing_instance',
                     'source']
        for element in paramlist:
            if element in list(kwargs.keys()):
                cmd = cmd + " " + element.replace('_', '-') + " " + str(kwargs[element])
        print(cmd)

        output = self.VM_nc.send_command_expect(cmd, strip_prompt=False, strip_command=False)
        print(output)
        # logger.info(output, also_console=True)
        return str(" 0% packet loss" in output)

    def ping(self, dest_ip, **kwargs):
        cmd = "ping " + str(dest_ip)
        paramlist = ['count', 'df_bit', 'interface', 'packet_size', 'rapid', 'record-route', 'routing_instance',
                     'source']
        for element in paramlist:
            if element in list(kwargs.keys()):
                cmd = cmd + " " + element.replace('_', '-') + " " + str(kwargs[element])
        print(cmd)
        output = self.shell_nc.send_command_expect(cmd, expect_string=">", strip_prompt=False, strip_command=False)
        print(output)
        return str(" 0% packet loss" in output)

    def get_ipv6_add(self):
        cmd = "ifconfig"
        output = self.VM_nc.send_command_expect(cmd, expect_string="\$|password|:|#", strip_prompt=False,
                                                strip_command=False)
        print(output)
        return output

    # ipv6 ping(vm1-vm2 and vm1-cpe1)
    def shell_ping6(self, dest_ip6, count=5, **kwargs):
        # Usage: ping [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
        #     [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
        #     [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
        #     [-w deadline] [-W timeout] [hop1 ...] destination
        cmd = "ping6 " + str(dest_ip6) + " -c " + str(count)
        paramlist = ['count', 'df_bit', 'interface', 'packet_size', 'rapid', 'record-route', 'routing_instance',
                     'source']
        for element in paramlist:
            if element in list(kwargs.keys()):
                cmd = cmd + " " + element.replace('_', '-') + " " + str(kwargs[element])
        print(cmd)
        output = self.VM_nc.send_command_expect(cmd, strip_prompt=False, strip_command=False)
        print(output)
        logger.info(output, also_console=True)
        return str(" 0% packet loss" in output)

    def send_commands_and_expect(self, cmds, expect_string="\$|password|:|#"):
        for cmd in cmds.split("\n"):
            # print cmd
            output = self.shell_nc.send_command_expect(cmd, expect_string=expect_string, strip_prompt=False,
                                                       strip_command=False)
            if "password|:" in output:
                output1 = self.shell_nc.send_command_expect(cmd, expect_string=expect_string, strip_prompt=False,
                                                            strip_command=False)
                output = output + output1
        # logger.info(output, also_console=True)
        return output


def main():
    print((datetime.now()))
    VM1 = LinuxLib('CPE11_LAN_HOST1', "Devices.yml")
    VM2 = LinuxLib('CPE12_LAN_HOST1', "VM_Devices.csv")
    VM1.VM_pre_op()
    # #VM1_data = VM1.get_data_dict()
    # #print VM1_data
    # # VM1.VM_nc = VM1.shell_login()
    # # VM2.VM_nc = VM2.shell_login()
    # # VM2.send_commands_and_expect("pkill iperf3 &")
    # VM1.VM_pre_op()
    # VM2.VM_pre_op()
    # VM1.intf = str(VM1.LAN_INTF)
    # VM2.intf = str(VM2.LAN_INTF)
    # for i in range(1, VM1.NO_OF_VRFS+1):
    #     ip = str(VM1.lan[i]['second_host'])
    #     gw = str(VM1.lan[i]['first_host'])
    #     nmask = str(VM1.lan[i]['netmask'])
    #     vlan = str(VM1.lan[i]['vlan'])
    #     destination_nw = str(VM2.lan[i]['nw'])
    #     VM1.send_commands_and_expect("sudo ip route add " + destination_nw + " via " + gw + " dev " + VM1.intf + "." + vlan)
    # for i in range(1, VM2.NO_OF_VRFS+1):
    #     ip = str(VM2.lan[i]['second_host'])
    #     gw = str(VM2.lan[i]['first_host'])
    #     nmask = str(VM2.lan[i]['netmask'])
    #     vlan = str(VM2.lan[i]['vlan'])
    #     destination_nw = str(VM1.lan[i]['nw'])
    #     VM2.send_commands_and_expect("sudo ip route add " + destination_nw + " via " + gw + " dev " + VM2.intf + "." + vlan)
    # for i in range(1, VM2.NO_OF_VRFS + 1):
    #     print(VM1.shell_ping(VM2.lan[i]['first_host']))
    #     print(VM1.shell_ping(VM2.lan[i]['second_host']))
    #     print(VM2.shell_ping(VM1.lan[i]['first_host']))
    #     print(VM2.shell_ping(VM1.lan[i]['second_host']))
    #     # print VM1.shell_ping(VM2[])
    print((datetime.now()))


if __name__ == "__main__":
    main()

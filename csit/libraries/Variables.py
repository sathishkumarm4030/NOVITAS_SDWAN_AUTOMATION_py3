import os
import pandas as pd
import getpass

cpe_list = ""

if __name__ == "__main__":
    fileDir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))
else:
    fileDir = os.path.dirname(os.path.realpath('__file__'))

# print fileDir
curr_file_dir = os.path.dirname(os.path.dirname(os.path.realpath('__file__')))

interface_template = os.path.join(curr_file_dir, 'libraries/TEXTFSM/versa_interface_template')
bgp_nbr_template = os.path.join(curr_file_dir, 'libraries/TEXTFSM/versa_bgp_neighbor_org_template')
route_template = os.path.join(curr_file_dir, 'libraries/TEXTFSM/versa_route_template')
show_config_template = os.path.join(curr_file_dir, 'libraries/TEXTFSM/versa_show_config_template')



#Variables
device_grp_url = "/nextgen/deviceGroup"
task_url = "/vnms/tasks/task/"
sfw_template_assc_url = "/nextgen/template/"
device_template_url = "/vnms/sdwan/workflow/devices/device"
read_controllers_url = "/vnms/sdwan/workflow/controllers"
get_template_url = "/vnms/sdwan/workflow/templates?offset=0&limit=10000"
template_url = "/vnms/sdwan/workflow/templates/template"
upgrade_dev_url = "/api/config/nms/actions/packages/upgrade"
appliance_url = '/vnms/appliance/appliance?offset=0&limit=1000'
package_url = '/api/operational/nms/packages/package?select=name;uri'
fwd_profile_url = '/api/config/devices/device/tempdevicename/config/orgs/org-services/temporgname/sd-wan/forwarding-profiles'
address_object_create_url = '/api/config/devices/device/tempdevicename/config/orgs/org-services/temporgname/objects/addresses'
service_object_create_url = '/api/config/devices/device/tempdevicename/config/orgs/org-services/temporgname/objects/services'
policy_rule_create_url = '/api/config/devices/device/tempdevicename/config/orgs/org-services/temporgname/sd-wan/policies/sdwan-policy-group/Default-Policy/rules'
routing_instance_url = '/api/config/devices/device/tempdevicename/config/routing-instances/routing-instance/'
get_org_id = '/vnms/pac/vd?org-uuid'
vni_interface_url = '/api/config/devices/device/tempdevicename/config/interfaces/vni/%22interface_name%22'
vni_interface_bw_url = '/api/config/devices/device/tempdevicename/config/interfaces/vni/%22interface_name%22/bandwidth'
sla_profile_url = '/api/config/devices/device/tempdevicename/config/orgs/org-services/temporgname/sd-wan/sla-profiles'


org_url = '/vnms/sdwan/workflow/orgs/org'
headers = {'Accept': 'application/vnd.yang.data+json'}
headers2 = {'Accept': 'application/vnd.yang.data+json', 'Content-Type': 'application/vnd.yang.data+json'}
headers3 = {'Accept': 'application/json', 'Content-Type': 'application/json'}
headers4 = {'Content-Type': 'application/json'}

move_to_top = 'move devices device tempdevicename config orgs org-services temporgname sd-wan policies Default-Policy rules DSTIP_MATCH first'

##########################################################
#POD1
POD = {}
POD[1] = {}
POD[2] = {}
POD[1]['VD1'] = {'MIN_SW_VERSION': None, 'mgmt_ip': '10.91.127.194', 'username': 'Automated', 'password': 'Auto@12345',
                 'device_type': 'versa_director', 'GUIusername': 'Automated', 'GUIpassword': 'Auto@12345'}
POD[1]['VD2'] = {'MIN_SW_VERSION': None, 'mgmt_ip': '10.91.127.195', 'username': 'Automated', 'password': 'Auto@12345',
                 'device_type': 'versa_director', 'GUIusername': 'Automated', 'GUIpassword': 'Auto@12345'}
POD[1]['log_collector'] = "LogCollectors-GGN"
POD[1]['TRACK_MANAGEMENT_SUBNET'] = "10.91.113.58/32"
POD[1]['controllers_list'] = ['NV-WC01-N1-HKG', 'NV-WC01-N6-SIN', 'NV-WC02-N1-HKG', 'NV-WC02-N6-SIN', "NV-WC01-N5-LON", "NV-WC02-N5-LON" , 'NV-WC02-N7-MYS', 'NV-WC02-N7-MYS']
POD[1]['staging_servers_dict'] = {
    "HKG" : ["NV-WC01-N1-HKG", "NV-WC02-N1-HKG"],
    "LON" : ["NV-WC01-N5-LON", "NV-WC02-N5-LON"],
    "SIN" : ["NV-WC01-N6-SIN", "NV-WC02-N6-SIN"],
    "MYS" : ["NV-WC01-N7-MYS", "NV-WC02-N7-MYS"]
}


POD[1]['ctlr_dict'] = {
    "HKG" : ["NV-WC01-N1-HKG", "NV-WC02-N1-HKG"],
    "LON" : ["NV-WC01-N5-LON", "NV-WC02-N5-LON"],
    "SIN" : ["NV-WC01-N6-SIN", "NV-WC02-N6-SIN"],
    "MYS" : ["NV-WC01-N7-MYS", "NV-WC02-N7-MYS"]
}

POD[1]['ctlr_list'] = ["NV-WC01-N1-HKG", "NV-WC02-N6-SIN"]

POD[1]['RR_SERVER'] = ["NV-WC01-N1-HKG", "NV-WC02-N6-SIN"]

POD[1]['RR_Clients'] = {
    "NV-WC01-N1-HKG" : ["NV-WC01-N6-SIN", "NV-WC01-N5-LON", "NV-WC01-N7-MYS"],
    "NV-WC02-N6-SIN" : ["NV-WC02-N1-HKG", "NV-WC02-N5-LON", "NV-WC02-N7-MYS"]
}



POD[1]['gw_dict'] = {
    "HKG" : ["NV-GW01-N1-HKG", "NV-GW02-N1-HKG"],
    "LON" : ["NV-GW01-N5-LON", "NV-GW02-N5-LON"],
    "SIN" : ["NV-GW01-N6-SIN", "NV-GW02-N6-SIN"],
    "MYS" : ["NV-GW01-N7-MYS", "NV-GW02-N7-MYS"]
}

POD[1]['gw_list'] = []

POD[1]['LCC_dict'] = {
    "HKG" : "852",
    "LON" : "44",
    "SIN" : "65",
    "MYS" : "91"
}

POD[1]['VNF_IPADDRESS'] = ['10.92.116.67/32', '10.92.116.68/32', '10.91.124.96/32']
POD[1]['MGMT_NW_SBNT'] = "10.91.140.0/22"

##########################################################
#POD2
POD[2]['VD1'] = {'MIN_SW_VERSION': None, 'mgmt_ip': '10.91.116.35', 'username': 'Automated', 'password': 'Auto@12345',
                 'device_type': 'versa_director', 'GUIusername': 'Automated', 'GUIpassword': 'Auto@12345'}
POD[2]['VD2'] = {'MIN_SW_VERSION': None, 'mgmt_ip': '10.91.116.36', 'username': 'Automated', 'password': 'Auto@12345',
                 'device_type': 'versa_director', 'GUIusername': 'Automated', 'GUIpassword': 'Auto@12345'}
POD[2]['log_collector'] = "LogCollectors"
POD[2]['TRACK_MANAGEMENT_SUBNET'] = "10.91.113.58/32"
POD[2]['controllers_list'] = ['NV-WC01-N2-BLR', 'NV-WC01-N4-MUM', 'NV-WC02-N2-BLR', 'NV-WC02-N4-MUM', "NV-WC01-N5-LON", "NV-WC02-N5-LON"]

POD[2]['staging_servers_dict'] = {
    "BLR" : ["NV-WC01-N2-BLR", "NV-WC02-N2-BLR"],
    "MUM" : ["NV-WC01-N4-MUM", "NV-WC02-N4-MUM"],
    "LON" : ["NV-WC01-N5-LON", "NV-WC02-N5-LON"]
}


POD[2]['ctlr_dict'] = {
    "BLR" : ["NV-WC01-N2-BLR", "NV-WC02-N2-BLR"],
    "MUM" : ["NV-WC01-N4-MUM", "NV-WC02-N4-MUM"],
    "LON" : ["NV-WC01-N5-LON", "NV-WC02-N5-LON"]
}

POD[2]['ctlr_list'] = ["NV-WC01-N2-BLR", "NV-WC02-N4-MUM"]

POD[2]['RR_SERVER'] = ["NV-WC01-N2-BLR", "NV-WC02-N4-MUM"]

POD[2]['RR_Clients'] = {
    "NV-WC01-N2-BLR" : ["NV-WC01-N4-MUM", "NV-WC01-N5-LON"],
    "NV-WC02-N4-MUM" : ["NV-WC02-N2-BLR", "NV-WC02-N5-LON"]
}



POD[2]['gw_dict'] = {
    "BLR": ["NV-GW01-N2-BLR", "NV-GW02-N2-BLR"],
    "MUM": ["NV-GW01-N4-MUM", "NV-GW02-N4-MUM"],
    # "MUM" : ["NV-GW01-N4-MUM", "NV-GW02-N4-MUM"],
    "LON" : ["NV-GW01-N5-LON", "NV-GW02-N5-LON"]
    #"LON" : ["NV-GW01-N5-LON"]
}

POD[2]['gw_list'] = []

POD[2]['LCC_dict'] = {
    "BLR" : "91",
    "MUM" : "1091",
    "LON" : "44"
}

POD[2]['VNF_IPADDRESS'] = ['10.91.116.67/32', '10.91.116.68/32', '10.91.124.96/32']
POD[2]['MGMT_NW_SBNT'] = "10.91.140.0/22"

#############################################################

SOLUTIONS_list = ['SINGLE-CPE-HYBRID',
                  'SINGLE-CPE-INTERNET-ONLY',
                  'SINGLE-CPE-MPLS-ONLY',
                  'SINGLE-CPE-DUAL-INTERNET',
                  'DUAL-CPE-DUAL-MPLS',
                  'DUAL-CPE-HYBRID',
                  'DUAL-CPE-DUAL-INTERNET']

#PAIRED_TVI_SUBNET = "10.63.47.64/30"


routing_instances = ['LAN1-VRF', 'LAN2-VRF', 'LAN3-VRF', 'LAN4-VRF', 'LAN5-VRF', 'LAN6-VRF', 'LAN7-VRF', 'LAN8-VRF', 'LAN9-VRF', 'LAN10-VRF']





WAN_INTERFACES = {
    'SINGLE-CPE-HYBRID':            {'WAN1': 'MPLS-WAN', 'WAN2': 'INT-WAN'},
    'SINGLE-CPE-INTERNET-ONLY':     {'WAN1': 'INT-WAN'},
    'SINGLE-CPE-MPLS-ONLY':         {'WAN1': 'MPLS-WAN'},
    'SINGLE-CPE-DUAL-INTERNET':     {'WAN1': 'INT-WAN1', 'WAN2': 'INT-WAN2'},
    'DUAL-CPE-HYBRID':              {'WAN1': 'MPLS-WAN', 'WAN2': 'INT-WAN'},
    'DUAL-CPE-DUAL-INTERNET':       {'WAN1': 'INT-WAN1', 'WAN2': 'INT-WAN2'},
    'DUAL-CPE-DUAL-MPLS':           {'WAN1': 'MPLS-WAN1', 'WAN2': 'MPLS-WAN2'}
}

Solution_type = {
    'dual_mpls' : {
        'local_ckt_pri_1_intfs' : "MPLS-WAN1 MPLS-WAN2",
        'remote_ckt_pri_1_intf' : "MPLS-WAN MPLS-WAN1 MPLS-WAN2",
                  },
    'internet' : {
        'local_ckt_pri_1_intfs' : "INT-WAN",
        'remote_ckt_pri_1_intf' : "INT-WAN",
        'local_ckt_pri_2_intfs' : "INT-WAN INT-WAN1 INT-WAN2",
        'remote_ckt_pri_2_intf' : "LTE-WAN",
                  },
    'hybrid' : {
        'local_ckt_pri_1_intfs' : "MPLS-WAN INT-WAN",
        'remote_ckt_pri_1_intf' : "MPLS-WAN MPLS-WAN1 MPLS-WAN2 INT-WAN INT-WAN1 INT-WAN2",
        'local_ckt_pri_2_intfs' : "INT-WAN",
        'remote_ckt_pri_2_intf' : "LTE-WAN",
                  },
    'dual-internet': {
        'local_ckt_pri_1_intfs': "INT-WAN1 INT-WAN2",
        'remote_ckt_pri_1_intf': "INT-WAN INT-WAN1 INT-WAN2",
        'local_ckt_pri_2_intfs': "INT-WAN1 INT-WAN2",
        'remote_ckt_pri_2_intf': "LTE-WAN",
    },

}

true = "true"
false = "false"






#Commands
cmd1 = 'show interfaces brief | tab | nomore'
cmd2 = 'show bgp neighbor brief | nomore'
cmd3 = 'show route | nomore'
cmd4 = 'show configuration | display set | nomore'

#PS_template_name = 'AUTO-IPC00012-BLR-PS-HS-LIB'

#Device_name = 'AUTO-CPE26'

req_clear_ipsec = """request devices device {{ NAME }} live-status clear ipsec sa org {{ ORG_NAME }} vpn-profile {{ VPN_PROFILE }}
"""
req_cre_snapshot = """request devices device {{ NAME }} live-status system create-snapshot description {{ snapshot_description }} no-confirm
"""

bgp_nbr_set_config = """set devices device {{ Device_name }} config routing-instances {{ ORG_NAME }}-Control-VR protocols bgp {{ ORG_ID }} group Controllers-Group neighbor {{ WC1_ESP_IP }}
set devices device {{ Device_name }} config routing-instances {{ ORG_NAME }}-Control-VR protocols bgp {{ ORG_ID }} group Controllers-Group neighbor {{ WC2_ESP_IP }}
"""

bgp_nbr_delete_config = """delete devices device {{ Device_name }} config routing-instances {{ ORG_NAME }}-Control-VR protocols bgp {{ ORG_ID }} group Controllers-Group neighbor {{ WC1_ESP_IP }}
delete devices device {{ Device_name }} config routing-instances {{ ORG_NAME }}-Control-VR protocols bgp {{ ORG_ID }} group Controllers-Group neighbor {{ WC2_ESP_IP }}
"""

#ROBOT_TESTSUITE variables
group_name         =      "LAN-EBGP"
peer_as            =      "65512"
remote_as          =      "65507"
local_as           =      "65512"
loopback_ip1       =      "123.1.2.3"
loopback_ip2       =      "123.1.2.4"
loopback_ipv6_1    =      "2001:123:1:2::3"
loopback_ipv6_2    =      "2001:123:1:2::4"
prefix_len         =      "32"
ipv6_prefix        =      "64"
nmask              =      "255.255.255.255"
loopback_intf      =      "Loopback123"
lan_number         =      "1"
bgp_instance_id    =      "4032"
password           =      "colt123"
Customer_ORG_ID    =      "90"
redis_policy_name  =      "Default-Policy-To-BGP"
community_id1      =      "300:1"
community_id2      =      "301:1"
Customer_ORG_Name  =      "IPC00190-Control-VR"
ORG_NAME           =      "IPC00190"
sdwan_policy_name  =      "Import-From-SDWAN-Policy"
upgrade_img        =      "versa-director-20200719-215910-eae49fb-16.1R2S9S9.1.bin"
image_version      =      "16.1R2"
version            =      "20200917"
currentVersion     =      "1733"
VD1_status         =      "MASTER"
VD2_status         =      "SLAVE"
VD1_post_gres_status       =      "primary"
VD2_post_gres_status       =      "standby"
VD1_mode           =      "master"
VD2_mode           =      "slave"
pkg_name           =      "versa-director-20200719-215910-eae49fb-16.1R2S9S9.1"
ospf_instance_id   =      "1"
ospf_router_id     =      "1.1.1.1"
ospf_area_id       =      "0"
sla_prf_1          =      "SLA112"
fwp_1              =      "FWP112"
ipaddobj_1         =      "src_ip_add_obj11"
ipaddobj_2         =      "dst_ip_add_obj11"
ipaddobj_11        =      "src_ip_add_ipv6_obj11"
ipaddobj_12        =      "dst_ip_add_ipv6_obj11"
plcyrule_1         =      "policy_rule_11"
TCP                =      "TCP"
serviceobj_1       =      "src_port_2000"

LAN1_QOS_RULES = {
'Premium' : 'LAN1-VRF-Premium',
'Business1' : 'LAN1-VRF-Business1',
'Business2' : 'LAN1-VRF-Business2',
'Business3' : 'LAN1-VRF-Business3',
'Internet-Default' : 'LAN1-VRF-Internet-Default'
}



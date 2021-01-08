*** Settings ***
Documentation     A test suite with tests for SDWAN SINGLE CPE Solution.
...               Topology:-
...               ____________________________
...               | VersaDirector |
...               |___________________________|
...               |
...               |
...               |
...               _____________|_______________
...               | WanCtrller1 |
...               |____________________________|
...               | |
...               | |
...               | |
...               INTERNET/MPLS
...               | |
...               | |___
...               ______|__ ___|___
...               | | | |
...               LAN1--+ CPE1 | | CPE2 +--LAN1
...               |________| |_______|
...
...
...               Testplan Goals:-
...               1. CHECK WAN INTERFACES STATUS.
...               2. CHECK BGP NEIGHBOR STATUS.
...               3. CHECK LAN ROUTE.
...               4. Ping Test.
...               5. IPERF Test.
...               6. Traffic steering Test.
...               7. QOS Test.
Suite Setup       STARTUP
Suite Teardown    CLEANUP
Metadata          Version    1.0\nMore Info For more information about Robot Framework see http://robotframework.org\nAuthor Sathishkumar murugesan\nDate 12 Dec 2017\nExecuted At HOST\nTest Framework Robot Framework Python
Variables         ../libraries/Variables.py
Library           Collections
Library           String
Variables         IPV6_TOPOLOGY.py
Library           ../libraries/VersaLib.py    VD1    topofile=Devices.csv    WITH NAME    VD1
Library           ../libraries/VersaLib.py    ${CPE1}    topofile=Devices.csv    WITH NAME    CPE1
Library           ../libraries/VersaLib.py    ${CPE2}    topofile=Devices.csv    WITH NAME    CPE2
Library           ../libraries/VersaLib.py    ${CPE3}    topofile=Devices.csv    WITH NAME    CPE3
Library           ../libraries/LinuxLib.py    ${VM1}    topofile=VM_Devices.csv    WITH NAME    VM1
Library           ../libraries/LinuxLib.py    ${VM2}    topofile=VM_Devices.csv    WITH NAME    VM2
Library           ../libraries/LinuxLib.py    ${VM3}    topofile=VM_Devices.csv    WITH NAME    VM3
#Library           ../libraries/HltapiLib.py    ${Spirent_chasis1[0]}    ${Spirent_chasis1[1]}    ${Spirent_chasis1[2]}    WITH NAME    spirent1
#Library           DebugLibrary

*** Variables ***
${est}            Established
${unit_o}         .0
${up}             up
${bw}             30000
${Protocol}       BGP
${State}          Active
${lan}            1
${Sroute}         2001:111::/64
${Route_type}     static
${Preference}     1
${host_prefix_len}    128 

*** Test Cases ***
NV_IPV6_SANITY_01
    [Documentation]   SANITY CHECK FOR IPV6 CONF,INTF,ROUTE
    [Tags]   IPV601    IPV6_SANITY
    ${result}    CPE1.show_ipv6_config_intf    ${CPE1['lan'][1]['first_host_ipv6']}
    CHECK RESULT    actual=${result}    expected=${CPE1['LAN_INTF']}
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['first_host_ipv6']}
    ${result}    CPE1.show_interface_brief_lan    ${CPE1['LAN_INTF']}    ${CPE1['START_VLAN']}
    CHECK RESULT    actual=${result}    expected=${CPE1['LAN_INTF']}.${CPE1['START_VLAN']}
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['first_host_ipv6']}
    ${result}    CPE2.show_ipv6_route   ${lan}
    ${ipv6_active_dest_route} =    Convert To String    ${CPE1['lan'][1]['ipv6_nw_with_prefixlen']}\\n\\s+\\S+${Protocol}\\S+\\s+\\S+\\s+${State}\\n\\s+> to ::ffff:${CPE1['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${ipv6_active_dest_route}

NV_IPV6_SANITY_02
    [Documentation]    PING TEST FROM CPE1 TO CPE2
    [Tags]    IPV602    IPV6_SANITY    PING_CPE_CPE
    ${dest_ip}=    set variable    ${CPE2['lan'][1]['first_host_ipv6']}
    ${src_ip}=     set variable    ${CPE1['lan'][1]['first_host_ipv6']}  
    ${result}=     CPE1.ping_ipv6    ${dest_ip}    ${src_ip}    LAN1   
    CHECK RESULT    actual=${result}    expected=True

NV_IPV6_SANITY_03
    [Documentation]    PING TEST FROM LAN VM1 TO CPE1
    [Tags]   IPV603    IPV6_SANITY    PING_VM_CPE
    ${dest_ip}=    set variable    ${CPE1['lan'][1]['first_host_ipv6']}
    ${result}    VM1.shell_ping6    ${dest_ip}
    CHECK RESULT    actual=${result}    expected=True

NV_IPV6_SANITY_04      
    [Documentation]    PING TEST FROM LAN VM1 TO VM2
    [Tags]   IPV604    IPV6_SANITY    PING_VM_VM
    ${result}    VM1.get_ipv6_add
    CHECK RESULT    actual=${result}    expected=${VM1['LAN_INTF']}.${VM1['START_VLAN']}
    CHECK RESULT    actual=${result}    expected=${VM1['lan'][1]['second_host_ipv6']}
    ${result}    VM2.get_ipv6_add
    CHECK RESULT    actual=${result}    expected=${VM2['LAN_INTF']}.${VM2['START_VLAN']}
    CHECK RESULT    actual=${result}    expected=${VM2['lan'][1]['second_host_ipv6']}
    ${dest_ip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    ${result}    VM1.shell_ping6    ${dest_ip}
    CHECK RESULT    actual=${result}    expected=True

NV_IPV6_ROUTING_01
    [Documentation]    IPV6 STATIC ROUTE TEST
    [Tags]   IPV605    IPV6_ROUTE
    ${result}    CPE1.rest_add_sroute    ${lan}    ${Sroute}    ${CPE1['lan'][1]['first_host_ipv6']}    ${preference}
    ${result}    CPE1.show_ipv6_conf_sroute    ${lan}
    CHECK RESULT    actual=${result}    expected=${sroute} 
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['first_host_ipv6']}
    CHECK RESULT    actual=${result}    expected=${CPE1['LAN_INTF']}.${CPE1['START_VLAN']}
    ${result}    CPE1.show_ipv6_sroute    ${lan}
    ${ipv6_active_static_route} =    Convert To String    ${Sroute}\\n\\s+\\S+${Route_type}\\S+\\s+\\S+\\s+${State}\\n\\s+> to ${CPE1['lan'][1]['first_host_ipv6']}
    CHECK RESULT    actual=${result}    expected=${ipv6_active_static_route}
    ${result}    CPE2.show_ipv6_sroute    ${lan}
    ${ipv6_active_dest_route} =    Convert To String    ${Sroute}\\n\\s+\\S+${Protocol}\\S+\\s+\\S+\\s+${State}\\n\\s+> to ::ffff:${CPE1['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${ipv6_active_dest_route}
    ${result}    CPE1.rest_del_sroute    ${lan}    ${Sroute}    ${CPE1['lan'][1]['first_host_ipv6']}   

NV_IPV6_TRAFFIC_STEERING_01
    [Documentation]    Traffic steering based on Source IP
    [Tags]    IPV606    IPV6_TS    
    CPE1.create_policy_rule_ipv6    ${plcyrule_1}    ${fwp_1}    src_address_ipv6_obj=${ipaddobj_11}    
    VD1.move_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    ${plcyrule_1}    first
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    SHOW COMMIT CHANGES 0
    CPE1.show_config_object_addresses    ${ipaddobj_11}
    CPE1.show_config_sdwan_sla_profile    ${sla_prf_1}
    CPE1.show_config_sdwan_fwd_profile    ${fwp_1}
    CPE1.show_config_sdwan_policy_rules    ${plcyrule_1}
    sleep    10s
    ${destip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    VM2.send_commands_and_expect    pkill iperf3 
    sleep    5s
    VM2.send_commands_and_expect    iperf3 -s -p 6000 & iperf3 -s -p 6001 & 
    sleep    5s
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} -p 6000 -b 5m -t 500 > S_client1 &
    sleep    40s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result1}    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    CHECK RESULT    actual=${result1}    expected=SLA Violated
    ${result}    CPE1.show_session_sdwan_detail    destination_port=6000
    CHECK RESULT    actual=${result}    expected=tx-wan-ckt\\s+${CPE1['WAN1_NAME']}
    CHECK RESULT    actual=${result}    expected=sdwan-rule-name\\s+${plcyrule_1}
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} -p 6001 -b 5m -t 500 > S_client2 &
    sleep    40s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result1}    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    CHECK RESULT    actual=${result1}    expected=SLA Violated
    ${result}    CPE1.show_session_sdwan_detail    destination_port=6001
    CHECK RESULT    actual=${result}    expected=tx-wan-ckt\\s+${CPE1['WAN2_NAME']}
    CHECK RESULT    actual=${result}    expected=sdwan-rule-name\\s+${plcyrule_1}
    VM1.send_commands_and_expect    pkill iperf3
    VM2.send_commands_and_expect    pkill iperf3    
    CPE1.delete_policy_rule    ${plcyrule_1}

NV_IPV6_TRAFFIC_STEERING_02
    [Documentation]    Traffic steering based on Destination IP
    [Tags]    IPV607    IPV6_TS
    CPE1.create_policy_rule_ipv6    ${plcyrule_1}    ${fwp_1}    dest_address_ipv6_obj=${ipaddobj_12}    
    VD1.move_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    ${plcyrule_1}    first
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    SHOW COMMIT CHANGES 0
    CPE1.show_config_object_addresses    ${ipaddobj_12}
    CPE1.show_config_sdwan_sla_profile    ${sla_prf_1}
    CPE1.show_config_sdwan_fwd_profile    ${fwp_1}
    CPE1.show_config_sdwan_policy_rules    ${plcyrule_1}
    sleep    10s
    ${destip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    VM2.send_commands_and_expect    pkill iperf3 &
    sleep    5s
    VM2.send_commands_and_expect    iperf3 -s -p 6000 & iperf3 -s -p 6001 &
    sleep    5s
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} -p 6000 -b 5m -t 500 > D_client1 &
    sleep    40s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result1}    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    CHECK RESULT    actual=${result1}    expected=SLA Violated
    ${result}    CPE1.show_session_sdwan_detail    destination_port=6000 
    CHECK RESULT    actual=${result}    expected=tx-wan-ckt\\s+${CPE1['WAN1_NAME']}
    CHECK RESULT    actual=${result}    expected=sdwan-rule-name\\s+${plcyrule_1}
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} -p 6001 -b 5m -t 500 D_client2 &
    sleep    40s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result1}    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    CHECK RESULT    actual=${result1}    expected=SLA Violated
    ${result}    CPE1.show_session_sdwan_detail    destination_port=6001 
    CHECK RESULT    actual=${result}    expected=tx-wan-ckt\\s+${CPE1['WAN2_NAME']}
    CHECK RESULT    actual=${result}    expected=sdwan-rule-name\\s+${plcyrule_1}
    VM1.send_commands_and_expect    pkill iperf3
    VM2.send_commands_and_expect    pkill iperf3
    CPE1.delete_policy_rule    ${plcyrule_1}

NV_IPV6_TRAFFIC_STEERING_03
    [Documentation]    Traffic Steering based on Application (IPERF)
    [Tags]    IPV608    IPV6_TS
    CPE1.create_policy_rule    ${plcyrule_1}    ${fwp_1}    application=IPERF
    VD1.move_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    ${plcyrule_1}    first
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    SHOW COMMIT CHANGES 0
    CPE1.show_config_sdwan_sla_profile    ${sla_prf_1}
    CPE1.show_config_sdwan_fwd_profile    ${fwp_1}
    CPE1.show_config_sdwan_policy_rules    ${plcyrule_1}
    sleep    10s
    ${destip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    VM2.send_commands_and_expect    pkill iperf3 &
    sleep    10s
    VM2.send_commands_and_expect    iperf3 -s &
    sleep    5s
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} &
    sleep    5s
    SHOW INTERFACE PORT STATISTICS BRIEF
    CPE1.show_defpolicy_path_state    ${plcyrule_1}    ${CPE2['Device_name']}
    ${result}    CPE1.show_session_sdwan_detail    application=iperf
    CHECK RESULT    actual=${result}    expected=tx-wan-ckt\\s+${CPE1['WAN1_NAME']}
    CHECK RESULT    actual=${result}    expected=sdwan-rule-name\\s+${plcyrule_1}
    CPE1.delete_policy_rule    ${plcyrule_1}

NV_IPV6_QOS_01
    [Documentation]    Source IPV6 address Based QOS
    [Tags]    IPV609    IPV6_QOS
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    qos_ipv6_based_premium.j2    src_address_obj=${ipaddobj_11}    src_add_ipv6=${VM1['lan'][1]['second_host_ipv6']}/${host_prefix_len}
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    first
    sleep    10s
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    SHOW COMMIT CHANGES 0
    CPE1.req_clr_stats_cos_qos_plcy_all
    CPE1.show_config_cos_qos_policy_rules
    CPE1.show_cos_qos_policy_rules
    sleep    10s
    ${dest_ip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    ${result}    VM1.shell_ping6    ${dest_ip}
    CPE1.show_cos_qos_policy_rules
    sleep  10s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result}  CPE1.show_cos_qos_policy_rules
    Log To Console  ${result}
    CHECK RESULT    actual=${result}    expected=LAN1-VRF-Premium\\s+1\\s+
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    revert_qos_ipv6_based_premium.j2     src_address_obj=${ipaddobj_11}
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    firs
   
NV_IPV6_QOS_02   
    [Documentation]    Destination IPV6 address Based QOS
    [Tags]    IPV610    IPV6_QOS
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    qos_ipv6_based_premium.j2    dst_address_obj=${ipaddobj_12}    dst_add_ipv6=${VM2['lan'][1]['second_host_ipv6']}/${host_prefix_len}
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    first
    sleep    10s
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    SHOW COMMIT CHANGES 0
    CPE1.req_clr_stats_cos_qos_plcy_all
    CPE1.show_config_cos_qos_policy_rules
    CPE1.show_cos_qos_policy_rules
    sleep    10s
    ${dest_ip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    ${result}    VM1.shell_ping6    ${dest_ip}
    CPE1.show_cos_qos_policy_rules
    sleep  10s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result}  CPE1.show_cos_qos_policy_rules
    Log To Console  ${result}
    CHECK RESULT    actual=${result}    expected=LAN1-VRF-Premium\\s+1\\s+
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    revert_qos_ipv6_based_premium.j2     dst_address_obj=${ipaddobj_12}
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    first

NV_IPV6_QOS_03
    [Documentation]    IPV6 APP Based QOS
    [Tags]    IPV611    IPV6_QOS
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    qos_ipv6_based_premium.j2    application=IPERF    src_add_ipv6=${VM1['lan'][1]['second_host_ipv6']}/${host_prefix_len}
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    first
    sleep    10s
    REQ CLR SESSION ALL
    SHOW SESSION SDWAN DETAIL
    SHOW INTERFACE PORT STATISTICS BRIEF
    SHOW COMMIT CHANGES 0
    CPE1.req_clr_stats_cos_qos_plcy_all
    CPE1.show_config_cos_qos_policy_rules
    CPE1.show_cos_qos_policy_rules
    sleep    10s
    ${dest_ip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    VM2.send_commands_and_expect    pkill iperf3 &
    sleep    10s
    VM2.send_commands_and_expect    iperf3 -s &
    sleep    5s
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip} &
    sleep    5s
    SHOW INTERFACE PORT STATISTICS BRIEF
    ${result}    CPE1.show_session_sdwan_detail    application=iperf
    ${result}  CPE1.show_cos_qos_policy_rules
    Log To Console  ${result}
    CHECK RESULT    actual=${result}    expected=LAN1-VRF-Premium\\s+2\\s+
    VD1.modify_qos_device_config    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    revert_qos_ipv6_based_premium.j2     application=IPERF
    VD1.move_qos_policy_rule    ${CPE1['Device_name']}    ${cpe1['ORG_NAME']}    Default-Policy    LAN1-VRF-Premium    first

#NV_IPV6_ROUTING_02
#    [Documentation]    SANITY CHECKS FOR IPV6 BGP ROUTE
#    [Tags]   IPV609    IPV6_SANITY    
#    ${result}    CPE1.show_ipv6_conf_sroute    ${lan}
#    CHECK RESULT    actual=${result}    expected=${sroute}
#    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['first_host_ipv6']}
#    CHECK RESULT    actual=${result}    expected=${CPE1['LAN_INTF']}.${CPE1['START_VLAN']}
#    ${result}    CPE1.show_ipv6_sroute    ${lan}
#    ${ipv6_active_static_route} =    Convert To String    ${Sroute}\\n\\s+\\S+${Route_type}\\S+\\s+\\S+\\s+${State}\\n\\s+> to ${CPE1['lan'][1]['first_host_ipv6']}
#    CHECK RESULT    actual=${result}    expected=${ipv6_active_static_route}
#    ${result}    CPE2.show_ipv6_sroute    ${lan}
#    ${ipv6_active_dest_route} =    Convert To String    ${Sroute}\\n\\s+\\S+${Protocol}\\S+\\s+\\S+\\s+${State}\\n\\s+> to ::ffff:${CPE1['ESP_IP']}
#    CHECK RESULT    actual=${result}    expected=${ipv6_active_dest_route}


*** Keywords ***
REQ CLR SESSION ALL
    ${result}   CPE1.req_clr_sess_all
    Log To Console  ${result}

SHOW INTERFACE PORT STATISTICS BRIEF
    ${result}   CPE1.show_intf_port_stats_br
    Log To Console  ${result}

SHOW SESSION SDWAN DETAIL
    ${result}   CPE1.show_session_sdwan_detail
    Log To Console  ${result}

SHOW COMMIT CHANGES 0
    ${result}   CPE1.show_commit_changes_0
    Log To Console  ${result}

CREATE FWD PROFILE
    ${curr_intf_bw}    CPE1.get_vni_interface_bw    ${CPE1['WAN1_INTF']}
    set suite variable    ${curr_intf_bw}
    CPE1.modify_interface_bandwidth    ${CPE1['WAN1_INTF']}    ${bw}    ${bw}
    CPE1.get_vni_interface_bw    ${CPE1['WAN1_INTF']}
    CPE1.create_sla_profile    ${sla_prf_1}    circuit_transmit_utilization=5
    CPE1.create_fowarding_profile    ${fwp_1}    ${CPE1['WAN1_NAME']}    ${CPE1['WAN2_NAME']}    sla_name=${sla_prf_1}    evaluate_continuously=disable
    CPE1.create_address_object    ${ipaddobj_11}    ipv6-prefix    ${CPE1['lan'][1]['second_host_ipv6']}/128
    CPE1.create_address_object    ${ipaddobj_12}    ipv6-prefix    ${CPE2['lan'][1]['second_host_ipv6']}/128

DELETE FWD PROFILE
    CPE1.delete_address_object    ${ipaddobj_11}
    CPE1.delete_address_object    ${ipaddobj_12}
    CPE1.delete_fowarding_profile    ${fwp_1}
    CPE1.delete_sla_profile    ${sla_prf_1}
    #CPE1.modify_interface_bandwidth    ${CPE1['WAN1_INTF']}    ${curr_intf_bw['bandwidth']['uplink']}    ${curr_intf_bw['bandwidth']['downlink']}
    CPE1.get_vni_interface_bw    ${CPE1['WAN1_INTF']}

CHECK MPLS WAN INTERFACE UP in CPE1 & CPE2
    ${result}=    CPE1.get interface status    intf_name=${CPE1['WAN1_INTF']}${unit_o} | match MPLS
    #CHECK RESULT    actual=${result}    expected=${up}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2    up not presnt 2 times
    ${result}=    CPE2.get interface status    intf_name=${CPE2['WAN1_INTF']}${unit_o} | match MPLS
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK INTERNET WAN INTERFACE UP in CPE1 & CPE2
    ${result}=    CPE1.get interface status    intf_name=${CPE1['WAN2_INTF']}${unit_o} | match INT
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2
    ${result}=    CPE2.get interface status    intf_name=${CPE2['WAN2_INTF']}${unit_o} | match INT
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK INTERNET WAN INTERFACE UP in CPE1
    ${result}=    CPE1.get interface status    intf_name=${CPE1['WAN1_INTF']}${unit_o} | match INT
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK MPLS WAN INTERFACE UP in CPE2
    ${result}=    CPE2.get interface status    intf_name=${CPE2['WAN1_INTF']}${unit_o} | match MPLS
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK INTERNET WAN INTERFACE UP in CPE2
    ${result}=    CPE2.get interface status    intf_name=${CPE2['WAN2_INTF']}${unit_o} | match INT
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK MPLS WAN INTERFACE UP in CPE3
    ${result}=    CPE3.get interface status    intf_name=${CPE3['WAN1_INTF']}${unit_o} | match MPLS
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC1 BGP NEIGHBOR STATUS in CPE1 & CPE2 and CPE3
    ${result}=    CPE1.get bgp nbr status    nbr_ip=${CPE1['WC1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE2.get bgp nbr status    nbr_ip=${CPE2['WC1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE3.get bgp nbr status    nbr_ip=${CPE3['WC1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}

CHECK WC2 BGP NEIGHBOR STATUS in CPE1 & CPE2 and CPE3
    ${result}=    CPE1.get bgp nbr status    nbr_ip=${CPE1['WC2_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE2.get bgp nbr status    nbr_ip=${CPE2['WC2_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE3.get bgp nbr status    nbr_ip=${CPE3['WC2_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}


CHECK WC1 PTVI INTERFACE STATUS in CPE1
    ${result}=    CPE1.get interface status    intf_name=${CPE1['ptvi_intf_wc1']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC2 PTVI INTERFACE STATUS in CPE1
    ${result}=    CPE1.get interface status    intf_name=${CPE1['ptvi_intf_wc2']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC1 PTVI INTERFACE STATUS in CPE2
    ${result}=    CPE2.get interface status    intf_name=${CPE2['ptvi_intf_wc1']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC2 PTVI INTERFACE STATUS in CPE2
    ${result}=    CPE2.get interface status    intf_name=${CPE2['ptvi_intf_wc2']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC1 PTVI INTERFACE STATUS in CPE3
    ${result}=    CPE3.get interface status    intf_name=${CPE3['ptvi_intf_wc1']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2

CHECK WC2 PTVI INTERFACE STATUS in CPE3
    ${result}=    CPE3.get interface status    intf_name=${CPE3['ptvi_intf_wc2']}
    Run Keyword And Continue On Failure    Should Contain X Times    ${result}    ${up}    2


CHECK CPE2 LAN ROUTE Present in CPE1
    ${result}=    CPE1.check lan route    lan=1
    #    log to console    ${result}
    ${active_dest_route} =    Convert To String    \\+${CPE2['lan'][1]['nw']}\\s+${CPE2['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

CHECK CPE3 LAN ROUTE Present in CPE1
    ${result}=    CPE1.check lan route    lan=1
    #    log to console    ${result}
    ${active_dest_route} =    Convert To String    \\+${CPE3['lan'][1]['nw']}\\s+${CPE3['GW1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

CHECK CPE1 LAN ROUTE Present in CPE2
    ${result}=    CPE2.check lan route    lan=1
    ${active_dest_route} =    Convert To String    \\+${CPE1['lan'][1]['nw']}\\s+${CPE1['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

CHECK CPE1 LAN ROUTE Present in CPE3
    ${result}=    CPE3.check lan route    lan=1
    ${active_dest_route} =    Convert To String    \\+${CPE1['lan'][1]['nw']}\\s+${CPE1['GW1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

STARTUP
    [Documentation]    Make connecection to Versa devices
    VD1.login
    ${VD1}    VD1.get_data_dict
    set suite variable    ${VM1}
    set suite variable    ${VM2}
    set suite variable    ${VM3}
    CPE1.cross login
    CPE2.cross_login
    CPE3.cross_login
#    Debug
#    spirent1.Connect And Reserve Ports
    ${CPE1_dev_info_on_vd} =    CPE1.get_device_info
    ${CPE1}    CPE1.get_data_dict
    ${CPE2}    CPE2.get_data_dict
    ${CPE3}    CPE3.get_data_dict
    CPE1.Create_Controller_List    ${CPE1['ORG_NAME']}    ${CPE1['ORG_ID']}    ${CPE1['NO_OF_VRFS']}    ${CPE1['NODE']}
    CPE1.Create_Gateway_List    ${CPE1['ORG_NAME']}    ${CPE1['ORG_ID']}    ${CPE1['NO_OF_VRFS']}    ${CPE1['NODE']}
    CPE1.create_cpe_data
    CPE2.Create_Controller_List    ${CPE2['ORG_NAME']}    ${CPE2['ORG_ID']}    ${CPE2['NO_OF_VRFS']}    ${CPE2['NODE']}
    CPE2.Create_Gateway_List    ${CPE2['ORG_NAME']}    ${CPE2['ORG_ID']}    ${CPE2['NO_OF_VRFS']}    ${CPE2['NODE']}
    CPE2.create_cpe_data
    CPE3.Create_Controller_List    ${CPE3['ORG_NAME']}    ${CPE3['ORG_ID']}    ${CPE3['NO_OF_VRFS']}    ${CPE3['NODE']}
    CPE3.Create_Gateway_List    ${CPE3['ORG_NAME']}    ${CPE3['ORG_ID']}    ${CPE3['NO_OF_VRFS']}    ${CPE3['NODE']}
    CPE3.create_cpe_data
    ${CPE1}    CPE1.get_data_dict
    set suite variable    ${CPE1}
    ${CPE2}    CPE2.get_data_dict
    set suite variable    ${CPE2}
    ${CPE3}    CPE3.get_data_dict
    set suite variable    ${CPE3}
    #log variables
    #####VM preops #####
    VM1.VM_pre_op
    VM2.VM_pre_op
    VM3.VM_pre_op
    ${VM1}    VM1.get_data_dict
    ${VM2}    VM2.get_data_dict
    ${VM3}    VM3.get_data_dict
    set suite variable    ${VM1}
    set suite variable    ${VM2}
    set suite variable    ${VM3}
    FOR    ${i}    IN RANGE    1    ${VM1['NO_OF_VRFS']} + 1
        ${gw} =    set variable    ${VM1['lan'][${i}]['first_host']}
        ${gw_ipv6} =    set variable    ${VM1['lan'][${i}]['first_host_ipv6']}
        ${vlan} =    set variable    ${VM1['lan'][${i}]['vlan']}
        ${destination_nw1} =    set variable    ${VM2['lan'][${i}]['nw']}
        ${destination_nw1_ipv6} =    set variable    ${VM2['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM1.send_commands_and_expect    sudo ip route add ${destination_nw1} via ${gw} dev ${VM1['LAN_INTF']}.${vlan}
        VM1.send_commands_and_expect    sudo ip route add ${destination_nw1_ipv6} via ${gw_ipv6} dev ${VM1['LAN_INTF']}.${vlan}
        ${destination_nw2} =    set variable    ${VM3['lan'][${i}]['nw']}
        ${destination_nw2_ipv6} =    set variable    ${VM3['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM1.send_commands_and_expect    sudo ip route add ${destination_nw2} via ${gw} dev ${VM1['LAN_INTF']}.${vlan}
        VM1.send_commands_and_expect    sudo ip route add ${destination_nw2_ipv6} via ${gw_ipv6} dev ${VM1['LAN_INTF']}.${vlan}
    END
    FOR    ${i}    IN RANGE    1    ${VM2['NO_OF_VRFS']} + 1
        ${gw} =    set variable    ${VM2['lan'][${i}]['first_host']}
        ${gw_ipv6} =    set variable    ${VM2['lan'][${i}]['first_host_ipv6']}
        ${vlan} =    set variable    ${VM2['lan'][${i}]['vlan']}
        ${destination_nw} =    set variable    ${VM1['lan'][${i}]['nw']}
        ${destination_nw_ipv6} =    set variable    ${VM1['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM2.send_commands_and_expect    sudo ip route add ${destination_nw} via ${gw} dev ${VM2['LAN_INTF']}.${vlan}
        VM2.send_commands_and_expect    sudo ip route add ${destination_nw_ipv6} via ${gw_ipv6} dev ${VM2['LAN_INTF']}.${vlan}
    END
    FOR    ${i}    IN RANGE    1    ${VM3['NO_OF_VRFS']} + 1
        ${gw} =    set variable    ${VM3['lan'][${i}]['first_host']}
        ${gw_ipv6} =    set variable    ${VM3['lan'][${i}]['first_host_ipv6']}
        ${vlan} =    set variable    ${VM3['lan'][${i}]['vlan']}
        ${destination_nw} =    set variable    ${VM1['lan'][${i}]['nw']}
        ${destination_nw_ipv6} =    set variable    ${VM1['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM3.send_commands_and_expect    sudo ip route add ${destination_nw} via ${gw} dev ${VM3['LAN_INTF']}.${vlan}
        VM3.send_commands_and_expect    sudo ip route add ${destination_nw_ipv6} via ${gw_ipv6} dev ${VM3['LAN_INTF']}.${vlan}
    END

    ###########spirent ###########
#    SPIRENT_STARTUP
    #CPE1.create_address_object    ${ipaddobj_11}    ipv6-prefix    ${CPE1['lan'][1]['first_host_ipv6']}/128
    #CPE1.create_address_object    ${ipaddobj_12}    ipv6-prefix    ${CPE2['lan'][1]['first_host_ipv6']}/128
    CREATE FWD PROFILE
    #CPE1.create_service_object    ${serviceobj_1}    ${TCP}    source_port=2000
    #VD1.config_devices_qos    ${CPE1['Device_name']}    ${CPE1['ORG_NAME']}    ${CPE1['WAN1_INTF']}

SPIRENT_STARTUP
    ${device1}    spirent1.Create Device    port=0    vlanid=${CPE1['lan'][1]['vlan']}    intf_ip_addr=${CPE1['lan'][1]['third_host']}    gateway_ip_addr=${CPE1['lan'][1]['first_host']}
    ${device2}    spirent1.Create Device    port=1    vlanid=${CPE2['lan'][1]['vlan']}    intf_ip_addr=${CPE2['lan'][1]['third_host']}    gateway_ip_addr=${CPE2['lan'][1]['first_host']}
    ${stream1}    spirent1.Create Tcp Stream Block   ${device1}    ${device2}    src_port=2000    rate_mbps=2
    ${stream2}    spirent1.Create Tcp Stream Block   ${device1}    ${device2}    src_port=2001    rate_mbps=2
    ${stream3}    spirent1.Create Udp Stream Block   ${device1}    ${device2}    src_port=2002    rate_mbps=2
    ${premium_tcp_stream1}          spirent1.create_tcp_stream_block   ${device1}     ${device2}    src_port=3001     rate_mbps=1     ip_dscp=46
    ${business1_tcp_stream1}        spirent1.create_tcp_stream_block   ${device1}     ${device2}    src_port=3002     rate_mbps=1     ip_dscp=26
    ${business2_tcp_stream1}        spirent1.create_tcp_stream_block   ${device1}     ${device2}    src_port=3003     rate_mbps=1     ip_dscp=18
    ${business3_tcp_stream1}        spirent1.create_tcp_stream_block   ${device1}     ${device2}    src_port=3004     rate_mbps=1     ip_dscp=10
    ${internet_default_tcp_stream1}    spirent1.Create Tcp Stream Block   ${device1}    ${device2}    src_port=5000    rate_mbps=1
    
    set suite variable    ${device1}
    set suite variable    ${device2}
    set suite variable    ${stream1}
    set suite variable    ${stream2}
    set suite variable    ${stream3}
    set suite variable    ${premium_tcp_stream1}
    set suite variable    ${business1_tcp_stream1}
    set suite variable    ${business2_tcp_stream1}
    set suite variable    ${business3_tcp_stream1}
    set suite variable    ${internet_default_tcp_stream1}




CLEANUP
    DELETE FWD PROFILE
    log to console    "cleanup done"
    #CPE1.delete_service_object    ${serviceobj_1}
    #CPE1.delete_address_object    ${ipaddobj_11}
    #CPE1.delete_address_object    ${ipaddobj_12}
    #spirent1.release_ports
    FOR    ${i}    IN RANGE    1    ${VM1['NO_OF_VRFS']} + 1
        ${gw} =    set variable    ${VM1['lan'][${i}]['first_host']}
        ${gw_ipv6} =    set variable    ${VM1['lan'][${i}]['first_host_ipv6']}
        ${vlan} =    set variable    ${VM1['lan'][${i}]['vlan']}
        ${destination_nw} =    set variable    ${VM2['lan'][${i}]['nw']}
        ${destination_nw_ipv6} =    set variable    ${VM2['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM1.send_commands_and_expect    sudo ip route del ${destination_nw} via ${gw} dev ${VM1['LAN_INTF']}.${vlan}
        VM1.send_commands_and_expect    sudo ip route del ${destination_nw_ipv6} via ${gw_ipv6} dev ${VM1['LAN_INTF']}.${vlan}
    END
    FOR    ${i}    IN RANGE    1    ${VM2['NO_OF_VRFS']} + 1
        ${gw} =    set variable    ${VM2['lan'][${i}]['first_host']}
        ${gw_ipv6} =    set variable    ${VM2['lan'][${i}]['first_host_ipv6']}
        ${vlan} =    set variable    ${VM2['lan'][${i}]['vlan']}
        ${destination_nw} =    set variable    ${VM1['lan'][${i}]['nw']}
        ${destination_nw_ipv6} =    set variable    ${VM1['lan'][${i}]['ipv6_nw_with_prefixlen']}
        VM2.send_commands_and_expect    sudo ip route del ${destination_nw} via ${gw} dev ${VM2['LAN_INTF']}.${vlan}
        VM2.send_commands_and_expect    sudo ip route del ${destination_nw_ipv6} via ${gw_ipv6} dev ${VM2['LAN_INTF']}.${vlan}
    END

CHECK RESULT1
    [Arguments]    ${actual}    ${expected}=True
    [Documentation]    Check result contains expected value
    log    ${actual}
    log    ${expected}
    Run Keyword And Continue On Failure    should contain    ${actual}    ${expected}

CHECK RESULT
    [Arguments]    ${actual}    ${expected}=True
    [Documentation]    Check result contains expected value
    log    ${actual}
    log    ${expected}
    Run Keyword And Continue On Failure    should match regexp    ${actual}    ${expected}


Ping Test VM1 to VM2(1 LAN)
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM2['lan'][1]['second_host']}
    ${result}=    VM1.Shell Ping    ${destip}
    CHECK RESULT    actual=${result}

Ping Test VM1 to VM3(1 LAN)
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM3['lan'][1]['second_host']}
    ${result}=    VM1.Shell Ping    ${destip}
    CHECK RESULT    actual=${result}

Ping Test VM1 to VM2(ALL LANS)
    [Tags]    HYBRID
    FOR    ${vlan}    IN RANGE    1    ${VM1['NO_OF_VRFS']} + 1
        ${destip}=    set variable    ${VM2['lan'][${vlan}]['second_host']}
        #    log to console    ${destip}
        ${result}=    VM1.Shell Ping    ${destip}
        CHECK RESULT    actual=${result}
    END

Ping Test VM2 to VM1(1 LAN)
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM1['lan'][1]['second_host']}
    ${result}=    VM2.Shell Ping    ${destip}
    CHECK RESULT    actual=${result}

Ping Test VM3 to VM1(1 LAN)
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM1['lan'][1]['second_host']}
    ${result}=    VM3.Shell Ping    ${destip}
    CHECK RESULT    actual=${result}


Ping Test VM2 to VM1(ALL LANS)
    [Tags]    HYBRID
    FOR    ${vlan}    IN RANGE    1    ${VM2['NO_OF_VRFS']} + 1
        ${destip}=    set variable    ${VM1['lan'][${vlan}]['second_host']}
        #    log to console    ${destip}
        ${result}=    VM1.Shell Ping    ${destip}
        CHECK RESULT    actual=${result}
    END

Iperf3 test VM1 to VM2
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM2['lan'][1]['second_host']}
    VM2.send_commands_and_expect    pkill iperf3 &
    sleep    10s
    VM2.send_commands_and_expect    iperf3 -s &
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip}
    Should Contain    ${result}    iperf Done.

Iperf3_ipv6 test VM1 to VM2
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM2['lan'][1]['second_host_ipv6']}
    VM2.send_commands_and_expect    pkill iperf3_ipv6 &
    sleep    10s
    VM2.send_commands_and_expect    iperf3_ipv6 -s &
    ${result}=    VM1.send_commands_and_expect    iperf3_ipv6 -c ${destip}
    Should Contain    ${result}    iperf Done.


Iperf3 test VM1 to VM3
    [Tags]    HYBRID
    ${destip}=    set variable    ${VM3['lan'][1]['second_host']}
    VM3.send_commands_and_expect    pkill iperf3 &
    sleep    10s
    VM3.send_commands_and_expect    iperf3 -s &
    ${result}=    VM1.send_commands_and_expect    iperf3 -c ${destip}
    Should Contain    ${result}    iperf Done.

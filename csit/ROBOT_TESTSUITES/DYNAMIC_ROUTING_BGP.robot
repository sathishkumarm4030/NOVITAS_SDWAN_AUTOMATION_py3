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
...               1. CHECK BGP NEIGHBOR STATUS.
...               3. CHECK LAN ROUTE.
...               4. Ping Test.
Suite Setup       STARTUP
Suite Teardown    CLEANUP
Metadata          Version    1.0\nMore Info For more information about Robot Framework see http://robotframework.org\nAuthor Sathishkumar murugesan\nDate 12 Dec 2017\nExecuted At HOST\nTest Framework Robot Framework Python
Variables         ../libraries/Variables.py
Library           Collections
Library           String
Variables         DYNAMIC_ROUTING_TOPOLOGY.py
Library           ../libraries/VersaLib.py    ${VD1}    topofile=Devices.yml    WITH NAME    VD1
Library           ../libraries/VersaLib.py    ${CPE1}    topofile=Devices.yml    WITH NAME    CPE1
Library           ../libraries/VersaLib.py    ${CPE2}    topofile=Devices.yml    WITH NAME    CPE2
Library           ../libraries/CiscoLib.py    ${CISCOCPE1}    topofile=Devices.yml    WITH NAME    CISCOCPE1
Library           ../libraries/CiscoLib.py    ${CISCOCPE2}    topofile=Devices.yml    WITH NAME    CISCOCPE2
#Library           DebugLibrary

*** Variables ***
${est}              Established
${State}            full
${Protocol}         bgp
${unit_o}           .0
${up}               up
${VLAN1}            750
${VLAN2}            600

*** Test Cases ***

NV_DYNAMIC_ROUTING_BGP_01
    [Documentation]   Enabling BGP
    [Tags]   BGP01    BGP
    ${result}    CPE1.get_bgp_nbr_status    nbr_ip=${CISCOCPE1['lan'][1]['ninth_host']}    instance=LAN1-VRF
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['ninth_host']}
    CHECK_RESULT    actual=${result}    expected=${est}
    ${result}    CPE2.get_bgp_nbr_status    nbr_ip=${CISCOCPE2['lan'][1]['ninth_host']}    instance=LAN1-VRF
    CHECK RESULT    actual=${result}    expected=${CPE2['lan'][1]['ninth_host']}
    CHECK_RESULT    actual=${result}    expected=${est}
    ${dest_ip}=    set variable    ${loopback_ip1}
    #${result}    CISCOCPE2.ping    ${dest_ip}
    #CHECK RESULT    actual=${result}    expected=True

NV_DYNAMIC_ROUTING_BGP_02
    [Documentation]   BGP Redistribution
    [Tags]   BGP02    BGP
    ${result}    VD1.config_bgp_redis    ${CPE1['Device_name']}    ${Customer_ORG_Name}    ${Customer_ORG_ID}    ${sdwan_policy_name}    ${lan_number}     ${redis_policy_name}     community_id=${community_id1} 
    should not contain  ${result}    Commit FAILED
    ${result}    CPE1.show_conf_bgp_redis    community_id=${community_id1} 
    CHECK RESULT    actual=${result}    expected=${community_id1}
    ${result}    CISCOCPE1.config_bgp_redis    ${local_as}    ${remote_as}    ${CPE1['lan'][1]['first_host']}    loopback_ip=${loopback_ip1} 
    ${result}    CISCOCPE1.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}
    ${result}    CPE1.get_bgp_redis    ${Customer_ORG_Name}    loopback_ip=${loopback_ip1} 
    CHECK RESULT    actual=${result}    expected=${community_id1}
    ${result}    VD1.config_bgp_reject    ${CPE1['Device_name']}    ${Customer_ORG_Name}    ${Customer_ORG_ID}    ${sdwan_policy_name}    community_id=${community_id1}
    ${result}    CPE1.get_bgp_redis    ${Customer_ORG_Name}    loopback_ip=${loopback_ip1}
    CHECK RESULT    actual=${result}    expected=${Customer_ORG_Name}
    ${result}    VD1.delete_bgp_redis    ${CPE1['Device_name']}    ${lan_number}     ${Customer_ORG_ID}     ${redis_policy_name}     ${Customer_ORG_Name}    ${sdwan_policy_name}
    should not contain  ${result}    Commit FAILED
    ${result}    VD1.config_bgp_redis    ${CPE2['Device_name']}    ${Customer_ORG_Name}    ${Customer_ORG_ID}    ${sdwan_policy_name}    ${lan_number}     ${redis_policy_name}     community_id=${community_id2}
    should not contain  ${result}    Commit FAILED    
    ${result}    CPE2.show_conf_bgp_redis    community_id=${community_id2}
    CHECK RESULT    actual=${result}    expected=${community_id2}
    ${result}    CISCOCPE2.config_bgp_redis    ${local_as}    ${remote_as}    ${CPE2['lan'][1]['first_host']}    loopback_ip=${loopback_ip2}  
    ${result}    CISCOCPE2.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}
    ${result}    CPE2.get_bgp_redis    ${Customer_ORG_Name}    loopback_ip=${loopback_ip2} 
    CHECK RESULT    actual=${result}    expected=${community_id2}
    ${result}    VD1.config_bgp_reject    ${CPE2['Device_name']}    ${Customer_ORG_Name}    ${Customer_ORG_ID}    ${sdwan_policy_name}    community_id=${community_id2}
   # Debug
    ${result}    CPE1.get_bgp_redis    ${Customer_ORG_Name}    loopback_ip=${loopback_ip2}
    CHECK RESULT    actual=${result}    expected=${Customer_ORG_Name}
    ${result}    VD1.delete_bgp_redis    ${CPE2['Device_name']}    ${lan_number}     ${Customer_ORG_ID}    ${redis_policy_name}     ${Customer_ORG_Name}    ${sdwan_policy_name}
    should not contain  ${result}    Commit FAILED   

NV_DYNAMIC_ROUTING_BGP_03
    [Documentation]   Enabling IPV6 BGP
    [Tags]   BGP03    BGP
    ${result}=    VD1.delete_lan_ebgp    ${CPE1['Device_name']}    ${lan_number}    ${bgp_instance_id}
    should not contain  ${result}    Commit FAILED
    ${result}=    VD1.config_ipv6_lan_ebgp    ${CPE1['Device_name']}    ${lan_number}    ${bgp_instance_id}    ${CPE1['lan'][1]['first_host_ipv6']}    ${peer_as}    ${password}    ${CPE1['lan'][1]['ninth_host_ipv6']}
    should not contain  ${result}    Commit FAILED
    ${result}    CPE1.show_conf_bgp    ${group_name}
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['ninth_host_ipv6']}
    CISCOCPE1.config_ipv6_bgp    ${local_as}    ${CPE1['lan'][1]['first_host_ipv6']}    ${remote_as}    ${password}    loopback_ip6=${loopback_ipv6_1}    ipv6_prefix=${ipv6_prefix}
    ${result}    CISCOCPE1.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}
    ${result}    CPE1.get_bgp_nbr_status    ${CISCOCPE1['lan'][1]['ninth_host_ipv6']}    instance=LAN1-VRF
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['ninth_host_ipv6']}
    CHECK_RESULT    actual=${result}    expected=${est}
    ${result}=    VD1.delete_lan_ebgp    ${CPE2['Device_name']}    ${lan_number}    ${bgp_instance_id}
    should not contain  ${result}    Commit FAILED
    ${result}=    VD1.config_ipv6_lan_ebgp    ${CPE2['Device_name']}    ${lan_number}    ${bgp_instance_id}    ${CPE2['lan'][1]['first_host_ipv6']}    ${peer_as}    ${password}    ${CPE2['lan'][1]['ninth_host_ipv6']}
    should not contain  ${result}    Commit FAILED
    ${result}    CPE2.show_conf_bgp    ${group_name}
    CHECK RESULT    actual=${result}    expected=${CPE2['lan'][1]['ninth_host_ipv6']}
    CISCOCPE2.config_ipv6_bgp    ${local_as}    ${CPE2['lan'][1]['first_host_ipv6']}    ${remote_as}    ${password}    loopback_ip6=${loopback_ipv6_2}    ipv6_prefix=${ipv6_prefix}
    ${result}    CISCOCPE2.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}
    ${result}    CPE2.get_bgp_nbr_status    ${CISCOCPE2['lan'][1]['ninth_host_ipv6']}    instance=LAN1-VRF
    CHECK RESULT    actual=${result}    expected=${CPE2['lan'][1]['ninth_host_ipv6']}
    CHECK_RESULT    actual=${result}    expected=${est}

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

CHECK WC1 BGP NEIGHBOR STATUS in CPE1 & CPE2
    ${result}=    CPE1.get bgp nbr status    nbr_ip=${CPE1['WC1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE2.get bgp nbr status    nbr_ip=${CPE2['WC1_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}

CHECK WC2 BGP NEIGHBOR STATUS in CPE1 & CPE2
    ${result}=    CPE1.get bgp nbr status    nbr_ip=${CPE1['WC2_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}
    ${result}=    CPE2.get bgp nbr status    nbr_ip=${CPE2['WC2_ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${est}

CONFIG BGP in CPE1 & CISCOCPE1
    ${result}=    VD1.config_lan_ebgp    ${CPE1['Device_name']}    ${lan_number}    ${bgp_instance_id}    ${CPE1['lan'][1]['first_host']}    ${peer_as}    ${password}    ${CPE1['lan'][1]['ninth_host']} 
    should not contain  ${result}    Commit FAILED
    ${result}    CPE1.show_conf_bgp    ${group_name}
    CHECK RESULT    actual=${result}    expected=${CPE1['lan'][1]['ninth_host']}
    CISCOCPE1.config_bgp    ${local_as}    ${CPE1['lan'][1]['first_host']}    ${remote_as}    ${password}
    ${result}    CISCOCPE1.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}

CONFIG BGP in CPE2 & CISCOCPE2
    ${result}=    VD1.config_lan_ebgp    ${CPE2['Device_name']}    ${lan_number}    ${bgp_instance_id}    ${CPE2['lan'][1]['first_host']}    ${peer_as}    ${password}    ${CPE2['lan'][1]['ninth_host']} 
    should not contain  ${result}    Commit FAILED
    ${result}    CPE2.show_conf_bgp    ${group_name}
    CHECK RESULT    actual=${result}    expected=${CPE2['lan'][1]['ninth_host']}
    CISCOCPE2.config_bgp    ${local_as}    ${CPE2['lan'][1]['first_host']}    ${remote_as}    ${password}
    ${result}    CISCOCPE2.show_conf_bgp    ${local_as}
    CHECK RESULT    actual=${result}    expected=${local_as}

DELETE BGP IN CPE1
    ${result}=    VD1.delete_lan_ebgp    ${CPE1['Device_name']}    ${lan_number}    ${bgp_instance_id}
    should not contain  ${result}    Commit FAILED

DELETE BGP IN CPE2
    ${result}=    VD1.delete_lan_ebgp    ${CPE2['Device_name']}    ${lan_number}    ${bgp_instance_id}    
    should not contain  ${result}    Commit FAILED

DELETE BGP IN CISCOCPE1
    ${result}=    CISCOCPE1.delete_bgp    VLAN=${VLAN1}    local_as=${local_as}

DELETE BGP IN CISCOCPE2
    ${result}=    CISCOCPE2.delete_bgp    VLAN=${VLAN2}    local_as=${local_as}

CONFIG LOOPBACK INTF in CISCOCPE1
    ${result}    CISCOCPE1.config_loopback_intf    ${loopback_intf}    loopback_ip=${loopback_ip1}    
    CHECK RESULT    actual=${result}    expected=${loopback_ip1}

CONFIG LOOPBACK INTF in CISCOCPE2
    ${result}    CISCOCPE2.config_loopback_intf    ${loopback_intf}    loopback_ip=${loopback_ip2}
    CHECK RESULT    actual=${result}    expected=${loopback_ip2}

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

CHECK CPE2 LAN ROUTE Present in CPE1
    ${result}=    CPE1.check lan route    lan=1
    ${active_dest_route} =    Convert To String    \\+${CPE2['lan'][1]['nw']}\\s+${CPE2['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

CHECK CPE1 LAN ROUTE Present in CPE2
    ${result}=    CPE2.check lan route    lan=1
    ${active_dest_route} =    Convert To String    \\+${CPE1['lan'][1]['nw']}\\s+${CPE1['ESP_IP']}
    CHECK RESULT    actual=${result}    expected=${active_dest_route}

STARTUP
    [Documentation]    Make connecection to Versa devices
    VD1.login
    ${VD1}    VD1.get_data_dict
    CPE1.cross login
    CPE2.cross_login
    ${CPE1_dev_info_on_vd} =    CPE1.get_device_info
    ${CPE1}    CPE1.get_data_dict
    ${CPE2}    CPE2.get_data_dict
    CPE1.Create_Controller_List    ${CPE1['ORG_NAME']}    ${CPE1['ORG_ID']}    ${CPE1['NO_OF_VRFS']}    ${CPE1['NODE']}
    CPE1.Create_Gateway_List    ${CPE1['ORG_NAME']}    ${CPE1['ORG_ID']}    ${CPE1['NO_OF_VRFS']}    ${CPE1['NODE']}
    CPE1.create_cpe_data
    CPE2.Create_Controller_List    ${CPE2['ORG_NAME']}    ${CPE2['ORG_ID']}    ${CPE2['NO_OF_VRFS']}    ${CPE2['NODE']}
    CPE2.Create_Gateway_List    ${CPE2['ORG_NAME']}    ${CPE2['ORG_ID']}    ${CPE2['NO_OF_VRFS']}    ${CPE2['NODE']}
    CPE2.create_cpe_data
    ${CPE1}    CPE1.get_data_dict
    set suite variable    ${CPE1}
    ${CPE2}    CPE2.get_data_dict
    set suite variable    ${CPE2}
    #log variables
    #####CISCO preops #####
    CISCOCPE1.pre_op
    CISCOCPE2.pre_op
    ${CISCOCPE1}    CISCOCPE1.get_data_dict
    ${CISCOCPE2}    CISCOCPE2.get_data_dict
    set suite variable    ${CISCOCPE1}
    set suite variable    ${CISCOCPE2}
    CONFIG BGP in CPE1 & CISCOCPE1
    CONFIG BGP in CPE2 & CISCOCPE2
    CONFIG LOOPBACK INTF in CISCOCPE1
    CONFIG LOOPBACK INTF in CISCOCPE2

CLEANUP
    log to console    "cleanup done"
    DELETE BGP IN CPE1 
    DELETE BGP IN CISCOCPE1 
    CISCOCPE1.close
    DELETE BGP IN CPE2
    DELETE BGP IN CISCOCPE2
    CISCOCPE2.close

CHECK RESULT
    [Arguments]    ${actual}    ${expected}=True
    [Documentation]    Check result contains expected value
    log    ${actual}
    log    ${expected}
    Run Keyword And Continue On Failure    should match regexp    ${actual}    ${expected}


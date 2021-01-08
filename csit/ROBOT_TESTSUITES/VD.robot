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
Variables         VD_TOPOLOGY.py
#Library           ../libraries/VersaLib.py    VD1    topofile=Devices.yml    WITH NAME    VD1
#Library           ../libraries/VersaLib.py    VD2    topofile=Devices.yml    WITH NAME    VD2
Library           ../libraries/VersaLib.py    ${VD1}    topofile=Devices.yml    WITH NAME    VD1
Library           ../libraries/VersaLib.py    ${VD2}    topofile=Devices.yml    WITH NAME    VD2
#Library           ../libraries/HltapiLib.py    ${Spirent_chasis1[0]}    ${Spirent_chasis1[1]}    ${Spirent_chasis1[2]}    WITH NAME    spirent1
#Library           DebugLibrary

*** Variables ***
${est}            Established
${unit_o}         .0
${up}             up
${State1}          RUNNING
${State2}          Stopped
${upgrade_status}     successful!
${vd2_mgmt_ip}      10.91.127.195
${vd1_mgmt_ip}      10.91.127.194


*** Test Cases ***
NV_VD_UPGRADE
    [Documentation]    CHECK FOR VD UPGRADE
    [Tags]   VD    VD_01
    ${result}    VD1.get_sys_pkg_info 
    CHECK RESULT    actual=${result}    expected=${image_version}
    ${result}    VD2.get_sys_pkg_info
    CHECK RESULT    actual=${result}    expected=${image_version}
    ${result}    VD1.get_sec_oss_info
    CHECK RESULT    actual=${result}    expected=${version}
    ${result}    VD2.get_sec_oss_info
    CHECK RESULT    actual=${result}    expected=${version}
    ${result}    VD1.show_conf_nms
    CHECK RESULT    actual=${result}    expected=${currentVersion}
    ${result}    VD2.show_conf_nms
    CHECK RESULT    actual=${result}    expected=${currentVersion}
    ${result}    VD1.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD2.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD2_status}
    ${result}    VD1.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD2.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD2_post_gres_status}
    ${result}    VD1.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}
    ${result}    VD2.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD2_mode}
    ${result}    VD1.req_sys_pkg_list
    CHECK RESULT    actual=${result}    expected=${pkg_name}
    ${result}    VD2.req_sys_pkg_list
    CHECK RESULT    actual=${result}    expected=${pkg_name}
#VD upgrade step
    ${result}    VD1.vsh_status
    CHECK RESULT    actual=${result}    expected=${State1}
#    ${result}    VD1.vsh_stop
#    CHECK RESULT    actual=${result}    expected=${State2}
    VD1.shell_exit
#    ${result}    VD1.req_sys_upgrade_img    ${upgrade_img}
#    CHECK RESULT    actual=${result}    expected=${${upgrade_img}}
#    ${result}    VD1.log_moniter
#    sleep(30m)
#    CHECK RESULT    actual=${result}    expected=${upgrade_status}
#    VD1.shell_exit
    ${result}    VD2.vsh_status
    CHECK RESULT    actual=${result}    expected=${State1}
#    ${result}    VD2.vsh_stop
#    CHECK RESULT    actual=${result}    expected=${State2}
    VD2.shell_exit
#    ${result}    VD2.req_sys_upgrade_img    ${upgrade_img}
#    CHECK RESULT    actual=${result}    expected=${${upgrade_img}}
#    ${result}    VD2.log_moniter
#    sleep(30m)
#    CHECK RESULT    actual=${result}    expected=${upgrade_status}
#    VD2.shell_exit
#    ${result}    VD1.get_sys_pkg_info
#    CHECK RESULT    actual=${result}    expected=${latest_image_version}
#    ${result}    VD2.get_sys_pkg_info
#    CHECK RESULT    actual=${result}    expected=${latest_image_version}
    ${result}    VD1.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD2.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD2_status}
    ${result}    VD1.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD2.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD2_post_gres_status}
    ${result}    VD1.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}
    ${result}    VD2.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD2_mode}

NV_VD1_HA
    [Documentation]    CHECK FOR VD1 FAILOVER
    [Tags]    VD    VD_02
    ${result}    VD1.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD2.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD2_status}
    ${result}    VD1.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD2.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD2_post_gres_status}
    ${result}    VD1.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}
    ${result}    VD2.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD2_mode}
# Add rest api vd1 failover step
#    ${result}    VD1.rest_ha_fail_vd1    name=${device_type}    ip-address=${mgmt_ip}     stdby_mgmt_ip=${vd2_mgmt_ip} 
# check vd1 failed to login 
#    VD1.login
#    CHECK RESULT    expected={unable to login}
# vd2 able to login
#    VD2.login
    ${result}    VD2.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD2.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD2.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}

NV_VD2_HA
    [Documentation]    CHECK FOR VD2 FAILOVER
    [Tags]    VD    VD_03
    ${result}    VD1.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD2_status}
    ${result}    VD2.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD1.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD2_post_gres_status}
    ${result}    VD2.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD1.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD2_mode}
    ${result}    VD2.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}
# Add rest api vd2 failover step
#    ${result}    VD2.rest_ha_fail_vd2    ${device_type}    ${mgmt_ip}     stdby_mgmt_ip=${vd1_mgmt_ip}
# check vd2 failed to login
#    VD2.login
#    CHECK RESULT    expected={unable to login}
# vd1 able to login
#    VD1.login
    ${result}    VD1.req_vnmsha_act_status
    CHECK RESULT    actual=${result}    expected=${VD1_status}
    ${result}    VD1.req_postgres_details
    #CHECK RESULT    actual=${result}    expected=${VD1_post_gres_status}
    ${result}    VD1.fetch_peer_vnmsha_details
    CHECK RESULT    actual=${result}    expected=${VD1_mode}


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

STARTUP
    [Documentation]    Make connecection to Versa devices
    VD1.login
    VD2.login
    ${VD1}    VD1.get_data_dict
    ${VD2}    VD2.get_data_dict

CLEANUP
    log to console    "cleanup done"

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


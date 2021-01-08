#TOPO
#CPE1 - SINGLE-CPE-MPLS-ONLY
#CPE2 - SINGLE-CPE-HYBRID
#CPE3 - SINGLE-CPE-INTERNET-ONLY
#VM1  - linux VM connected to LAN switch. CPE1 LAN VM
#VM2  - linux VM connected to LAN switch. CPE2 LAN VM
#VM3  - linux VM connected to LAN switch. CPE3 LAN VM
#Spirent 2 Ports connected LAN switch

VD1 = "POD2_VD1"
CPE1 = "CPE12-MUM-SINGLE-CPE-MPLSONLY-IPC00073"
CPE2 = "CPE26-MUM-SINGLE-CPE-HYBRID-IPC00073"
CPE3 = "CPE-13-LON-SINGLE-CPE-INTERNETONLY-IPC00073"
VM1  = "CPE12_LAN_HOST1"
VM2  = "CPE26_LAN_HOST1"
VM3  = "CPE13_LAN_HOST1"
Spirent_chasis1 = ["10.91.113.124", "10/1", "10/2"]


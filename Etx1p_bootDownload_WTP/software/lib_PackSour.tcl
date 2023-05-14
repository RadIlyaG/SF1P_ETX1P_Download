
#console show
package require registry
set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]
set jav [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment" CurrentVersion]
set gaSet(javaLocation) [file normalize [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment\\$jav" JavaHome]/bin]
set ::RadAppsPath c:/RadApps

package require RLEH
package require RLTime
package require RLStatus
package require RLExPio
package require RLCom
package require BWidget
package require img::ico
package require RLSound 
package require twapi

source Gui_Etx1pDnld.tcl
source Lib_Gen_Etx1pDnld.tcl
source Lib_DialogBox.tcl
source Main_Etx1pDnld.tcl
# source lib_bc.tcl
source [info host]/init$gaSet(pair).tcl
source [info host]/init.tcl
if [file exists uutInits/$gaSet(DutInitName)] {
  source uutInits/$gaSet(DutInitName)
}

if [info exists gaSet(customer)] {
  set gaSet(customer) general ; # 15/03/2021 16:35:42 safaricom
}

set gaSet(puts) 1

if ![info exists gaSet(pioType)] {
  set gaSet(pioType) Ex
}
if {$gaSet(pioType)=="Usb"}  {
  package require RLUsbPio
}
# set gaSet(DutInitName) ETX-1P.tcl
# set gaSet(DutFullName) ETX-1P
set gaSet(uBootFilesPath) C:/RAD_bootFiles

set gaSet(downloadUbootAnyWay) Yes

if ![info exists gaSet(UutOpt)] {
  set gaSet(UutOpt) "ETX1P"
}
set gaSet(useExistBarcode) 0
if ![info exists gaSet(general.pcpes)] {
  set gaSet(general.pcpes) "NA"
}
if ![info exists gaSet(general.flashImg)] {
  set gaSet(general.flashImg) "NA"
}
if ![info exists gaSet(bootScript)] {
  set gaSet(bootScript) "NA"
}
if ![info exists gaSet(actGen)] {
  set gaSet(actGen) "NA"
}
if ![info exists gaSet(linux_srvr_ip)] {
  set gaSet(linux_srvr_ip) "172.18.94.42"
}
if ![info exists gaSet(dbrBoot)] {
  set gaSet(dbrBoot) -
}
if ![info exists gaSet(dbrApp)] {
  set gaSet(dbrApp) -
}
if ![info exists gaSet(mainPcbId)] {
  set gaSet(mainPcbId) "SF-1P.REV0.4I"
}
if ![info exists gaSet(sub1PcbId)] {
  set gaSet(sub1PcbId) ""
}
if ![info exists gaSet(hwAdd)] {
  set gaSet(hwAdd) ""
}
if ![info exists gaSet(csl)] {
  set gaSet(csl) C
}

set gaSet(idBarcode) ""

# set gaSet(linux_srvr_ip.1) 172.18.94.42
# set gaSet(linux_srvr) 1
# ToogleLinuxServerIp

GUI
BuildTests
ToggleCustometSW
update

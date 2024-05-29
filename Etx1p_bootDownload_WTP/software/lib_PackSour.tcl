wm iconify . ; update
#console show
package require registry
set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]
set jav [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment" CurrentVersion]
set gaSet(javaLocation) [file normalize [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment\\$jav" JavaHome]/bin]

if [file exists c:/TEMP_FOLDER] {
  file delete -force c:/TEMP_FOLDER
}
foreach fi [glob -nocomplain -type f SW_*.txt] {
  if [regexp {\w{2}\d{9,}} $fi] {
    file delete -force $fi
  }  
}
after 1000
set ::RadAppsPath c:/RadApps

set gaSet(radNet) 0
foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
  if {[string match {*192.115.243.*} $ip] || [string match {*172.18.9*} $ip] || [string match {*172.17.9*} $ip]} {
    set gaSet(radNet) 1
  }  
}

if 1 {
  package require RLAutoSync
  
  set s1 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/Etx-1P_BootDownload/Etx1p_bootDownload_WTP]
  set d1 [file normalize  C:/Etx1p_bootDownload_WTP]
  
  if {$gaSet(radNet)} {
    if {[string match *ilya-g* [info host]]} {
        set emailL [list]
      } else {
        set emailL {meir_ka@rad.com}
      }  
  } else {
    set emailL [list]
  }
  
  set ret [RLAutoSync::AutoSync "$s1 $d1" \
      -noCheckFiles {init*.tcl log*.txt} \
      -noCheckDirs {temp tmpFiles OLD old uutInits} -jarLocation  $::RadAppsPath \
      -javaLocation $gaSet(javaLocation) -emailL $emailL -putsCmd 1 -radNet $gaSet(radNet)]
  #console show
  puts "ret:<$ret>"
  set gsm $gMessage
  foreach gmess $gMessage {
    puts "$gmess"
  }
  update
  if {$ret=="-1"} {
    set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
    -message "The AutoSync process did not perform successfully.\n\n\
    Do you want to continue? "]
    if {$res=="no"} {
      #SQliteClose
      exit
    }
  }
}

package require RLEH
package require RLTime
package require RLStatus
package require RLExPio
package require RLCom
package require BWidget
package require img::ico
package require RLSound 
package require twapi
package require http
package require tls
package require base64
::http::register https 8445 ::tls::socket
package require sqlite3

source Gui_Etx1pDnld.tcl
source Lib_Gen_Etx1pDnld.tcl
source Lib_DialogBox.tcl
source Main_Etx1pDnld.tcl
source lib_bc.tcl

source lib_EcoCheck.tcl
source Lib_Ramzor.tcl
source lib_SQlite.tcl
source LibUrl.tcl
source Lib_GetOperator.tcl


source [info host]/init$gaSet(pair).tcl
source [info host]/init.tcl
if [file exists uutInits/$gaSet(DutInitName)] {
  #source uutInits/$gaSet(DutInitName)
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
# if ![info exists gaSet(mainPcbId)] {
  # set gaSet(mainPcbId) "SF-1P.REV0.4I"
# }
if ![info exists gaSet(sub1PcbId)] {
  set gaSet(sub1PcbId) ""
}
if ![info exists gaSet(hwAdd)] {
  set gaSet(hwAdd) ""
}
# if ![info exists gaSet(csl)] {
  # set gaSet(csl) C
# }

if ![info exists gaSet(demo)] {
  set gaSet(demo) 0
}


set gaSet(idBarcode) ""
set gaSet(DutFullName) ""

set gaSet(enCrtPriLog) 0
set gaSet(enStaticIp) 0

# set gaSet(linux_srvr_ip.1) 172.18.94.42
# set gaSet(linux_srvr) 1
# ToogleLinuxServerIp

GUI
BuildTests
ToggleCustometSW
update
update

wm deiconify .
wm geometry . $gaGui(xy)
update
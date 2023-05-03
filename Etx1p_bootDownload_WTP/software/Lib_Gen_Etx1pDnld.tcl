# ***************************************************************************
# RetriveUsbChannel
# ***************************************************************************
proc RetriveUsbChannel {} {
  global gaSet
  if {$gaSet(pioType)=="Ex"} {
    return 1
  }
   parray ::RLUsbPio::description *Ser*
  set boxL [lsort -dict [array names ::RLUsbPio::description]]
  if {[llength $boxL]==1888} {
    set gaSet(fail) "Not all USB ports are open. Please close and open the GUIs again"
    return -1
  }
  foreach nam $boxL {
    if [string match *Ser*Num* $nam] {
      foreach {usbChan serNum} [split $nam ,] {}
      set serNum $::RLUsbPio::description($nam)
      puts "usbChan:$usbChan serNum: $serNum"      
      if {$serNum==$gaSet(pioBoxSerNum)} {
        set channel $usbChan
        break
      }
    }  
  }
  puts "serNum:$serNum channel:$channel"
  return $channel
}
# ***************************************************************************
# OpenPio
# ***************************************************************************
proc OpenPio {} {
  global gaSet descript
  set channel [RetriveUsbChannel]
  if {$channel=="-1"} {
    return -1
  }
  foreach rb {1} {
    set gaSet(idPwr$rb) [RL[set gaSet(pioType)]Pio::Open $gaSet(pioPwr$rb) RBA $channel]
  }
   
  return 0
}

# ***************************************************************************
# ClosePio
# ***************************************************************************
proc ClosePio {} {
  global gaSet
  set ret 0
  foreach rb "1" {
	  catch {RL[set gaSet(pioType)]Pio::Close $gaSet(idPwr$rb)}
  }
  
  return $ret
}
#***************************************************************************
#** MyTime
#***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%T   %d/%m/%Y"]
}

# ***************************************************************************
# Power
# ***************************************************************************
proc Power {ps state} {
  global gaSet gaGui 
  puts "[MyTime] Power $ps $state"
  set ret 0
  switch -exact -- $ps {
    1   {set pioL 1}
    2   {set pioL 2}
    all {set pioL "1"}
  } 
  switch -exact -- $state {
    on  {
	    foreach pio $pioL {      
        RL[set gaSet(pioType)]Pio::Set $gaSet(idPwr$pio) 1
      }
    } 
	  off {
	    foreach pio $pioL {
	      RL[set gaSet(pioType)]Pio::Set $gaSet(idPwr$pio) 0
      }
    }
  }
  Status ""
  update
  return $ret
}
#***************************************************************************
#** Status
#***************************************************************************
proc Status {txt {color white}} {
  global gaSet gaGui
  $gaSet(sstatus) configure -bg $color  -text $txt
  if {$txt!=""} {
    puts "\n ..... $txt ..... /* [MyTime] */ \n"
  }
  $gaSet(runTime) configure -text ""
  update
}

# ***************************************************************************
# SaveUutInit
# ***************************************************************************
proc SaveUutInit {fil} {
  global gaSet
  puts "SaveUutInit $fil"
  set id [open $fil w]
     
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(DutFullName) \"$gaSet(DutFullName)\""
  }
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
  puts $id "set gaSet(general.SWver) \"$gaSet(general.SWver)\""
  puts $id "set gaSet(general.flashImg) \"$gaSet(general.flashImg)\""
  puts $id "set gaSet(general.pcpes) \"$gaSet(general.pcpes)\""
  
  if ![info exists gaSet(dbrAppSwPack)] {
    set gaSet(dbrAppSwPack)  SW0000
  }  
  puts $id "set gaSet(dbrAppSwPack)   \"$gaSet(dbrAppSwPack)\""
  
  if ![info exists gaSet(dbrApp)] {
    set gaSet(dbrApp)  ??
  }  
  puts $id "set gaSet(dbrApp)   \"$gaSet(dbrApp)\""
  
  if ![info exists gaSet(dbrBootSwPack)] {
    set gaSet(dbrBootSwPack)  SW0000
  }  
  puts $id "set gaSet(dbrBootSwPack)   \"$gaSet(dbrBootSwPack)\""
  
  if ![info exists gaSet(dbrBoot)] {
    set gaSet(dbrBoot)  ??
  }  
  puts $id "set gaSet(dbrBoot)   \"$gaSet(dbrBoot)\""
    
  close $id
}  
# ***************************************************************************
# SaveInitGUI
# ***************************************************************************
proc SaveInitGUI {} {
  global gaSet  
  set id [open [info host]/init$gaSet(pair).tcl w]
  puts $id "set gaGui(xy) +[winfo x .]+[winfo y .]"
  
  close $id   
}
# ***************************************************************************
# SaveInit
# ***************************************************************************
proc SaveInit {} {
  global gaSet  
  set id [open [info host]/init.tcl w]
  puts $id "set gaSet(dnldMode) $gaSet(dnldMode)"
  puts $id "set gaSet(pioType)  $gaSet(pioType)"
  
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(DutFullName) \"$gaSet(DutFullName)\""
  }
  puts $id "set gaSet(customer) \"$gaSet(customer)\""
  puts $id "set gaSet(safaricom.SWver) \"$gaSet(safaricom.SWver)\""
  puts $id "set gaSet(general.SWver) \"$gaSet(general.SWver)\""
  puts $id "set gaSet(downloadUbootAnyWay) \"$gaSet(downloadUbootAnyWay)\""
  
  puts $id "set gaSet(UutOpt) \"$gaSet(UutOpt)\""
  puts $id "set gaSet(general.pcpes) \"$gaSet(general.pcpes)\""
  puts $id "set gaSet(general.flashImg) \"$gaSet(general.flashImg)\""
  puts $id "set gaSet(bootScript) \"$gaSet(bootScript)\""
  puts $id "set gaSet(actGen) \"$gaSet(actGen)\""
  
  puts $id "set gaSet(linux_srvr_ip) \"$gaSet(linux_srvr_ip)\""
  
  close $id   
}


# ***************************************************************************
# GuiPower
# ***************************************************************************
proc GuiPower {n state} { 
  global gaSet descript
  puts "\nGuiPower $n $state"
  RLEH::Open
  #RLUsbPio::GetUsbChannels descript
  switch -exact -- $n {
    1.1 - 2.1 - 3.1 - 4.1 - 5.1 - 6.1 - 7.1 - 8.1 {set portL [list $gaSet(pioPwr1)]}
    1.2 - 2.2 - 3.2 - 4.2 - 5.2 - 6.2 - 7.2 - 8.2 {set portL [list $gaSet(pioPwr2)]}      
    1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - all           {set portL [list $gaSet(pioPwr1)]} 
  }        
  set channel [RetriveUsbChannel]
  if {$channel!="-1"} {
    foreach rb $portL {
      set id [RL[set gaSet(pioType)]Pio::Open $rb RBA $channel]
      puts "rb:<$rb> id:<$id>"
      RL[set gaSet(pioType)]Pio::Set $id $state
      RL[set gaSet(pioType)]Pio::Close $id
    }   
  }
  RLEH::Close
} 
# ***************************************************************************
# AddToLog
# ***************************************************************************
proc AddToLog {line} {
  global gaSet
  #set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
  set logFileID [open $gaSet(logFile.$gaSet(pair)) a+] 
    puts $logFileID "..[MyTime]..$line"
  close $logFileID
}

# ***************************************************************************
# AddToPairLog
# ***************************************************************************
proc AddToPairLog {pair line}  {
  global gaSet
  set logFileID [open $gaSet(log.$pair) a+]
  puts $logFileID "..[MyTime]..$line"
  close $logFileID
}
# ***************************************************************************
# CloseRL
# ***************************************************************************
proc CloseRL {} {
  global gaSet
  set gaSet(serial) ""
  ClosePio
  puts "CloseRL ClosePio" ; update
  
  catch {RLEH::Close}
}

 #***************************************************************************
#** Send
#** #set ret [RLCom::SendSlow $com $toCom 150 buffer $fromCom $timeOut]
#** #set ret [Send$com $toCom buffer $fromCom $timeOut]
#** 
#***************************************************************************
proc Send {com sent {expected stamm} {timeOut 8}} {
  global buffer gaSet
  if {$gaSet(act)==0} {return -2}

  #puts "sent:<$sent>"
  
  ## replace a few empties by one empty
  regsub -all {[ ]+} $sent " " sent
  
  #puts "sent:<[string trimleft $sent]>"
  ##set cmd [list RLSerial::SendSlow $com $sent 50 buffer $expected $timeOut]
  if {$expected=="stamm"} {
    ##set cmd [list RLSerial::Send $com $sent]
    set cmd [list RLCom::Send $com $sent]
    foreach car [split $sent ""] {
      set asc [scan $car %c]
      #puts "car:$car asc:$asc" ; update
      if {[scan $car %c]=="13"} {
        append sentNew "\\r"
      } elseif {[scan $car %c]=="10"} {
        append sentNew "\\n"
      } {
        append sentNew $car
      }
    }
    set sent $sentNew
  
    set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
    puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "send: com:$com, ret:$ret tt:$tt, sent=$sent"
    puts "send: ----------------------------------------\n"
    update
    return $ret
    
  }
  #set cmd [list RLSerial::Send $com $sent buffer $expected $timeOut]
  set cmd [list RLCom::Send $com $sent buffer $expected $timeOut]
  if {$gaSet(act)==0} {return -2}
  set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
  #puts buffer:<$buffer> ; update
  regsub -all -- {\x1B\x5B..\;..H} $buffer " " b1
  regsub -all -- {\x1B\x5B.\;..H}  $b1 " " b1
  regsub -all -- {\x1B\x5B..\;.H}  $b1 " " b1
  regsub -all -- {\x1B\x5B.\;.H}   $b1 " " b1
  regsub -all -- {\x1B\x5B..\;..r} $b1 " " b1
  regsub -all -- {\x1B\x5B.J}      $b1 " " b1
  regsub -all -- {\x1B\x5BK}       $b1 " " b1
  regsub -all -- {\x1B\x5B\x38\x30\x44}     $b1 " " b1
  regsub -all -- {\x1B\x5B\x31\x42}      $b1 " " b1
  regsub -all -- {\x1B\x5B.\x6D}      $b1 " " b1
  regsub -all -- \\\[m $b1 " " b1
  set re \[\x1B\x0D\]
  regsub -all -- $re $b1 " " b2
  #regsub -all -- ..\;..H $b1 " " b2
  regsub -all {\s+} $b2 " " b3
  regsub -all {\-+} $b3 "-" b3
  regsub -all -- {\[0\;30\;47m} $b3 " " b3
  regsub -all -- {\[1\;30\;47m} $b3 " " b3
  regsub -all -- {\[0\;34\;47m} $b3 " " b3
  regsub -all -- {\[74G}        $b3 " " b3
  set buffer $b3
  
  foreach car [split $sent ""] {
    set asc [scan $car %c]
    #puts "car:$car asc:$asc" ; update
    if {[scan $car %c]=="13"} {
      append sentNew "\\r"
    } elseif {[scan $car %c]=="10"} {
      append sentNew "\\n"
    } {
      append sentNew $car
    }
  }
  set sent $sentNew
  
  #puts "sent:<$sent>"
  if $gaSet(puts) {
    #puts "\nsend: ---------- [clock format [clock seconds] -format %T] ---------------------------"
    #puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "\n[MyTime] Send: com:$com, ret:$ret tt:$tt, sent=$sent,  expected=<$expected>, buffer=<$buffer>"
    #puts "send: ----------------------------------------\n"
    update
  }
  
  #RLTime::Delayms 50
  return $ret
}

# ***************************************************************************
# ReadCom
# ***************************************************************************
proc ReadCom {com inStr {timeout 10}} {
  global buffer buff gaSet
  set buffer ""
  $gaSet(runTime) configure -text ""
  set secStart [clock seconds]
  set secNow [clock seconds]
  set secRun [expr {$secNow-$secStart}]
  while {1} {
    if {$gaSet(act)==0} {return -2}
    if {$inStr=="exiting hardware virtualization" && $secRun > 360} {
      RLCom::Send $com "\r" buff $inStr 0.5
      set ret 0      
      set action "Send Ent to"
    } else {
      set ret [RLCom::Read $com buff]
      set action "Read from"
    }
#     set ret [RLCom::Read $com buff]
#     set action "Read from"
    append buffer $buff
    puts "$action Com-$com $secRun buff:<$buff>" ; update
    if {$ret!=0} {break}
    if {[string match "*$inStr*" $buffer]} {
      set ret 0
      break
    }
    if {$inStr=="exiting hardware virtualization" && [regexp {E\s+>} $buff ma]} {
#       RLCom::Send $com "x\r" buff $inStr 0.5
#       RLCom::Send $com "x\r" buff $inStr 0.5
      set ret -1
      break
    } 
    if {$inStr=="exiting hardware virtualization" && [regexp {user>} $buff ma]} {
      set ret user
      break
    }
    
    if {$inStr=="user>" && [regexp {localhost login} $buffer ma]} {
      set ret linux
      break
    }
    if {$inStr=="exiting hardware virtualization" && [regexp {Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block} $buff ma]} {
      set ret KernelPanic
      break
    }
    
    
    after 1000
    set secNow [clock seconds]
    set secRun [expr {$secNow-$secStart}]
    $gaSet(runTime) configure -text "$secRun" ; update
    if {$secRun > $timeout} {
      set ret -1
      break
    }
  }
  return $ret
}

# ***************************************************************************
# OpenTeraTerm
# ***************************************************************************
proc OpenTeraTerm {comName} {
  global gaSet
  set path1 C:\\Program\ Files\\teraterm\\ttermpro.exe
  set path2 C:\\Program\ Files\ \(x86\)\\teraterm\\ttermpro.exe
  set path3 C:\\teraterm\\ttermpro.exe
  set path  NA
  foreach pathX [list $path1 $path2 $path3]  {
    if [file exist $pathX] {
      set path $pathX
      break
    }
  }
  if {$path=="NA"} {
    tk_messageBox -type ok -message "no teraterm installed"
    return {}
  }
  if {[string match *Dut* $comName] } {
    set baud 115200
  } else {
    set baud 9600
  }
  regexp {com(\w+)} $comName ma val
  set val Tester-$gaSet(pair).[string toupper $val]  
  exec $path /c=[set $comName] /baud=$baud /W="$val" &
  return {}
}  

proc ChangeCust {} {
  global gaSet
  puts "cust: $gaSet(customer)"
  puts "cust.sw: $gaSet($gaSet(customer).SWver)"
}
# ***************************************************************************
# ReadWpdLog
# ***************************************************************************
proc ReadWpdLog {} {
  global gaSet
  set log log$gaSet(pair).txt
  set program wtpdownload$gaSet(pair).exe
  set pidL1 [twapi::get_process_ids -glob -name $program ]
  set program WerFault.exe   
  set pidL2 [twapi::get_process_ids -glob -name $program ]               
  if [file exists $log] {
    if ![catch {open $log r} id] {
      set lines [read $id]
      close $id
      puts "\n<$lines>\n" ; update
      if {[string match {*file complete for image 3*} $lines]} {
        after 1000
        foreach pid $pidL1 {
          catch {twapi::end_process $pid -force}
        } 
        after 1000 {
        foreach pid $pidL2 {
          catch {twapi::end_process $pid -force}
        }
        }
        #KillWpd
        exit
      }
    }
  }
  puts "pidL1:<$pidL1> pidL2:<$pidL2>" ; update 
  
  after 1000 ReadWpdLog
}

proc ToggleDnldMode {} {
  global gaSet
  
}
##***************************************************************************
##** Wait
## Wait "Wait for booting" 10
##***************************************************************************
proc Wait {txt count {color white}} {
  global gaSet
  puts "\nStart Wait $txt $count.....[MyTime]"; update
  Status $txt $color 
  for {set i $count} {$i > 0} {incr i -1} {
    if {$gaSet(act)==0} {return -2}
	 $gaSet(runTime) configure -text $i
	 RLTime::Delay 1
  }
  $gaSet(runTime) configure -text ""
  Status "" 
  puts "Finish Wait $txt $count.....[MyTime]\n"; update
  return 0
}

# ***************************************************************************
# Linux_SW_perf
# ***************************************************************************
proc Linux_SW_perf {customer appl uut} {
  global gaSet buffer
  puts "Linux_SW_perf customer:<$customer> appl:<$appl> uut:<$uut>"
  catch {exec python.exe Etx1p_linuxSwitchSW.py switch_sw $gaSet(linux_srvr_ip) $customer $appl $uut} res
  puts "Linux_SW_perf res:<$res>"
  if [string match {*No such file*} $res] {
    set gaSet(fail) "No such file or directory: $uut/$appl"
    set ret -1
  } elseif [string match {*no such group*} $res] {
    set gaSet(fail) "Read Linux fail"
    set ret -1
  } else {
    set s1 "s1"
    set s2 "s2"
    regexp {si1:.+etx-1p (\d+) .+:si1} $res ma s1
    if {$s1=="s1"} {
      ## prev regexp fail because "root" appears instead of "etx-1p"
      regexp {si1:.+root (\d+) .+:si1} $res ma s1  
    }
    regexp {si2:.+etx-1p (\d+) .+:si2} $res ma s2
    if {$s2=="s2"} {
      ## prev regexp fail because "root" appears instead of "etx-1p"
      regexp {si2:.+root (\d+) .+:si2} $res ma s2  
    }
    puts "versions:$s1, Images:$s2"
    if {$s1 != $s2} {
      set ret -1
      set gaSet(fail) "Images files are different"
    } else {
      set ret 0
    }
  }
  return $ret
}
# ***************************************************************************
# Linux_switch_pcpe
# Linux_switch_pcpe customer appl $gaSet(general.pcpes)
# ***************************************************************************
proc Linux_switch_pcpe {customer appl pcpe} {
  global gaSet buffer res
  set ret 0
  set res [regexp {general-([\d\.]+)} $pcpe m ver]
  if {$res==0} {
    set gaSet(fail) "Fail read $gaSet(general.pcpes)"
    return -1
  }
  set gaSet(actGen) $m
  set run run-${ver}.sh
  Status "Switching to \'$pcpe\'"
  puts "[MyTime] Linux_switch_pcpe customer:<$customer> appl:<$appl> pcpe:<$pcpe> ver:<$ver> run:<$run>"; update
  catch {exec python.exe Etx1p_linuxSwitchSW.py switch_pcpe $gaSet(linux_srvr_ip) $customer $ver $run} res
  puts "[MyTime] Linux_switch_pcpe res:<$res>"; update
  if [string match {*Copied*} $res] {
    set ret 0
  } else {
    set gaSet(fail) "Switch to $pcpe fail"
    if [regexp {Unable to connect to port 22 on ([\d\.]+)} $res m ip] {
      set gaSet(fail) $m
    }  
    
    set ret -1
  }
  return $ret
}
# ***************************************************************************
# GetDbrSW
# ***************************************************************************
proc GetDbrSW {barcode} {
  global gaSet gaGui
  set gaSet(dbrApp) ""
  set gaSet(dbrBoot) ""
  if {![file exist $gaSet(javaLocation)]} {
    set gaSet(fail) "Java application is missing"
    return -1
  }
  
  catch {exec $gaSet(javaLocation)\\java -jar $::RadAppsPath/SWVersions4IDnumber.jar $barcode} b
  puts "GetDbrSW barcode:<$barcode> b:<$b>" ; update
  after 1000
  
  set swTxt [glob SW*_$barcode.txt]
  catch {file delete -force $swTxt}
  
  if ![info exists gaSet(dbrAppSwPack)] {
    set gaSet(dbrAppSwPack) ""
  }
  set dbrAppSwPackIndx [lsearch $b $gaSet(dbrAppSwPack)]  
  if {$dbrAppSwPackIndx<0} {
    set gaSet(fail) "There is no SW ID for $gaSet(dbrAppSwPack) ID:$barcode. Verify the Barcode."
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrSW Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  set dbrSW [string trim [lindex $b [expr {1+$dbrAppSwPackIndx}]]]
  puts dbrSW:<$dbrSW>
  set gaSet(dbrApp) $dbrSW
  
  set dbrBootSwPackIndx [lsearch $b $gaSet(dbrBootSwPack)]  
  if {$dbrBootSwPackIndx<0} {
    set gaSet(fail) "There is no Boot SW ID for $gaSet(dbrBootSwPack) ID:$barcode. Verify the Barcode."
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrSW Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  set dbrBoot [string trim [lindex $b [expr {1+$dbrBootSwPackIndx}]]]
  puts dbrBoot:<$dbrBoot>
  set gaSet(dbrBoot) $dbrBoot
  
  pack forget $gaGui(frFailStatus)
  
  
  ToggleCustometSW
  Status ""
  update
  #BuildTests
  #focus -force $gaGui(curTest)
  return 0
}
# ***************************************************************************
# ToogleLinuxServerIp
# ***************************************************************************
proc ToogleLinuxServerIp {} {
  global gaSet
  set gaSet(linux_srvr_ip) $gaSet(linux_srvr_ip.$gaSet(linux_srvr))
}  

# ***************************************************************************
# GetDbrName
# ***************************************************************************
proc GetDbrName {mode} {
  global gaSet gaGui
  Status "Please wait for retriving DBR's parameters"
  puts "\r[MyTime] GetDbrName $mode"; update
  set barcode $gaSet(entDUT)
  
  if [file exists MarkNam_$barcode.txt] {
    file delete -force MarkNam_$barcode.txt
  }
  wm title . "$gaSet(pair) : "
  after 500
    
  if {![file exist $gaSet(javaLocation)]} {
    set gaSet(fail) "Java application is missing"
    return -1
  }
  set res [catch {exec $gaSet(javaLocation)\\java -jar $::RadAppsPath/OI4Barcode.jar $barcode} b]
  #puts "res:<$res> b:<$b>"
  if [string match *Exception* $b] {
    set gaSet(fail) "Network connection problem"
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  set fileName MarkNam_$barcode.txt
  after 1000
  if ![file exists MarkNam_$barcode.txt] {
    set gaSet(fail) "File $fileName is not created. Verify the Barcode"
    #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  
  set fileId [open "$fileName"]
    seek $fileId 0
    set res [read $fileId]    
  close $fileId
  
  #set txt "$barcode $res"
  set txt "[string trim $res]"
  #set gaSet(entDUT) $txt
  set gaSet(entDUT) ""
  puts "GetDbrName <$txt>"
  
  set initName [regsub -all / $res .]
  puts "GetDbrName res:<$res>"
  puts "GetDbrName initName:<$initName>"
  set gaSet(DutFullName) $res
  set gaSet(DutInitName) $initName.tcl
  
  file delete -force MarkNam_$barcode.txt
  #file mkdir [regsub -all / $res .]
  
  set fil "uutInits/$gaSet(DutInitName)"
  if {[file exists $fil]} {
    source $fil  
    #UpdateAppsHelpText  
  } else {
    puts "if the init file doesn't exist, fill the parameters by ? signs"; update
    set gaSet(general.SWver)     "vcpeos_5.0.6.29_arm.tar.gz"
    set gaSet(general.flashImg)  "flash-image-1.0.3_1G_.bin"
    set gaSet(general.pcpes)     "pcpe-general-5.0"
    set gaSet(dbrAppSwPack)  SW0000
    set gaSet(dbrApp)        ??
    set gaSet(dbrBootSwPack) SW0000
    set gaSet(dbrBoot)       ??
    SaveUutInit $fil
  } 
  wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  
  if [regexp {\.HL\.} $gaSet(DutInitName)] {
    set gaSet(UutOpt) SF1P-4UTP-HL
  } elseif {[regexp {\.4U2S\.} $gaSet(DutInitName)] && ![regexp {\.HL\.} $gaSet(DutInitName)]} {
    set gaSet(UutOpt) SF1P-4UTP
  } elseif [regexp {\.2U\.} $gaSet(DutInitName)] {
    set gaSet(UutOpt) SF1P-2UTP
  } elseif [regexp {\.ETX\.} $gaSet(DutInitName)] {
    set gaSet(UutOpt) ETX1P
  } else {
    set gaSet(fail) "$gaSet(DutInitName) is not defined"
    #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    RLSound::Play fail
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -2
  }
  
  pack forget $gaGui(frFailStatus)
  #Status ""
  update
  if {$mode=="full"} {
    BuildTests
    
    set ret [GetDbrSW $barcode]
    puts "GetDbrName ret of GetDbrSW:$ret" ; update
    if {$ret!=0} {
      RLSound::Play fail
  	  Status "Test FAIL"  red
      DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
      pack $gaGui(frFailStatus)  -anchor w
  	  $gaSet(runTime) configure -text ""
    }  
  } else {
    set ret 0
  }
  puts ""
  
  focus -force $gaGui(curTest)
  if {$ret==0} {
    Status "Ready"
  }
  return $ret
}

# ***************************************************************************
# Linux_Eeprom
# ***************************************************************************
proc Linux_Eeprom {} {
  global gaSet buffer
  set eep_file 1.1.txt
  set eep_content "1q2w3e4r"
  puts "Linux_Eeprom eep_file:<$eep_file> eep_content:<$eep_content>"
  catch {exec python.exe Etx1p_linuxSwitchSW.py switch_sw $gaSet(linux_srvr_ip) "customer" $eep_file $eep_content} res
  puts "Linux_Eeprom res:<$res>"
  return $ret
}
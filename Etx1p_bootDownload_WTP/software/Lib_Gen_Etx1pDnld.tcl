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
  #puts $id "set gaSet(mainPcbId)   \"[string toupper $gaSet(mainPcbId)]\""
  #puts $id "set gaSet(sub1PcbId)   \"[string toupper $gaSet(sub1PcbId)]\""
  #puts $id "set gaSet(hwAdd)       \"[string toupper $gaSet(hwAdd)]\""
  #puts $id "set gaSet(csl)         \"[string toupper $gaSet(csl)]\""
 
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
  puts $id "set gaSet(secBoot) \"$gaSet(secBoot)\""
  
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
    if {$inStr=="exiting hardware virtualization" && $secRun > 860} {
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
    if {$inStr=="exiting hardware virtualization" && \
      ([regexp {Kernel panic} $buff ma] || \
      [regexp {Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block} $buff ma] || [regexp {Kernel panic - not syncing: Aiee, killing interrupt handler!} $buff ma])} {
      set ret KernelPanic
      break
    }
    if {$inStr=="user>" && ([regexp {File not found boot/Image} $buffer ma] || [regexp {File not found boot/armada} $buffer ma])} {
      set ret FileNotFound
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
# 5.4.0.77.28 B1.0.4 SF-1P/E1/DC/4U2S/2RSM/L1/G/L1/2R
# ***************************************************************************
proc GetDbrSW {barcode} {
  global gaSet gaGui gaDBox
  set gaSet(dbrApp) ""
  set gaSet(dbrBoot) ""
  if {![file exist $gaSet(javaLocation)]} {
    set gaSet(fail) "Java application is missing"
    return -1
  }
  
  set sw 0
  set gaSet(manualMrktName) 0
  set gaSet(manualCSL) 0
  catch {exec $gaSet(javaLocation)\\java -jar $::RadAppsPath/SWVersions4IDnumber.jar $barcode} b
  puts "GetDbrSW barcode:<$barcode> b:<$b>" ; update
  
  if $gaSet(demo) {
    set ret [DialogBox -width 39 -title "Manual Definitions" -text "Please define details" -type "Ok Cancel" \
      -entQty 4  -DotEn 1 -DashEn 1 -NoNumEn 1\
      -entLab {"SW Version, like 5.4.0.127.28" "Boot Version, like B1.0.4" "Marketing Name, like SF-1P/E1/DC/4U2S/2RS/2R" "CSL, like A"}]  
    if {$ret=="Cancel"} {
      set gaSet(fail) "User stop"
      return -2
    }
    set sw [string trim $gaDBox(entVal1)]
    set boot [string trim $gaDBox(entVal2)]
    if {[string index $boot 0]=="B"} {
      set boot [string toupper [string range $boot 1 end]]
    }
    set gaSet(manualMrktName) [string toupper [string trim $gaDBox(entVal3)]]
    set gaSet(manualCSL) [string toupper [string trim $gaDBox(entVal4)]]
  } else {
    if {[lindex $b end] == $barcode} {
      set gaSet(fail) "No SW definition in IDbarcode"
      return -2
    }
    
    foreach pair [split $b \n] {
      foreach {aa bb} $pair {      
        if {[string range $aa 0 1]=="SW" && [string index $bb 0]!= "B"} {
          puts "aa=$aa bb=$bb"; update
          set sw $bb
          #break
        }
        if {[string range $aa 0 1]=="SW" && [string index $bb 0] == "B"} {
          puts "bo=$aa boo=$bb"; update
          set boot [string range $bb 1 end]
          #break
        }
      }
      #if {$sw} {break}
    }
    #set gaSet(dbrSWver) $bb
  }
  
  puts "GetDbrSW $barcode sw:<$sw> boot:<$boot>"
  set gaSet(dbrBootSwVer) $boot
  after 1000
  
  set swTxt [glob SW*_$barcode.txt]
  catch {file delete -force $swTxt}
  
  set gaSet(general.SWver)     "vcpeos_[set sw]_arm.tar.gz"
  puts "GetDbrSW barcode:<$barcode> gaSet(general.SWver):<$gaSet(general.SWver)>"
  set gaSet(general.flashImg)  "flash-image-[set boot]_[set gaSet(dutFam.mem)]G_.bin"
  puts "GetDbrSW barcode:<$barcode> gaSet(general.flashImg):<$gaSet(general.flashImg)>"
  
  # if ![info exists gaSet(dbrAppSwPack)] {
    # set gaSet(dbrAppSwPack) ""
  # }
  # set dbrAppSwPackIndx [lsearch $b $gaSet(dbrAppSwPack)]  
  # if {$dbrAppSwPackIndx<0} {
    # set gaSet(fail) "There is no SW ID for $gaSet(dbrAppSwPack) ID:$barcode. Verify the Barcode."
    # RLSound::Play fail
	  # Status "Test FAIL"  #ff6464 ; # red
    # DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrSW Problem"
    # pack $gaGui(frFailStatus)  -anchor w
	  # $gaSet(runTime) configure -text ""
  	# return -1
  # }
  # set dbrSW [string trim [lindex $b [expr {1+$dbrAppSwPackIndx}]]]
  # puts dbrSW:<$dbrSW>
  # set gaSet(dbrApp) $dbrSW
  
  # set dbrBootSwPackIndx [lsearch $b $gaSet(dbrBootSwPack)]  
  # if {$dbrBootSwPackIndx<0} {
    # set gaSet(fail) "There is no Boot SW ID for $gaSet(dbrBootSwPack) ID:$barcode. Verify the Barcode."
    # RLSound::Play fail
	  # Status "Test FAIL"  #ff6464 ; # red
    # DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrSW Problem"
    # pack $gaGui(frFailStatus)  -anchor w
	  # $gaSet(runTime) configure -text ""
  	# return -1
  # }
  # set dbrBoot [string trim [lindex $b [expr {1+$dbrBootSwPackIndx}]]]
  # puts dbrBoot:<$dbrBoot>
  # set gaSet(dbrBoot) $dbrBoot
  
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
  set barcode [string trim $gaSet(entDUT)]
  set gaSet(idBarcode) $barcode
  
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
	  Status "Test FAIL" #ff6464 ; #  red
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
	  Status "Test FAIL" #ff6464 ; #  red
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
  puts "GetDbrName <$txt> < $barcode >"
  
  set initName [regsub -all / $res .]
  puts "GetDbrName res:<$res> < $barcode >"
  puts "GetDbrName initName:<$initName>"
  set gaSet(DutFullName) $res
  set gaSet(DutInitName) $initName.tcl
  
  file delete -force MarkNam_$barcode.txt
  #file mkdir [regsub -all / $res .]
  
  
  
  set fil "uutInits/$gaSet(DutInitName)"
  if {[file exists $fil]} {
    #source $fil  
    #UpdateAppsHelpText  
  } else {
    # puts "if the init file doesn't exist, fill the parameters by ? signs"; update
    # set gaSet(general.SWver)     "vcpeos_5.0.6.29_arm.tar.gz"
    # set gaSet(general.flashImg)  "flash-image-1.0.3_1G_.bin"
    # set gaSet(general.pcpes)     "pcpe-general-5.0"
    # set gaSet(dbrAppSwPack)  SW0000
    # set gaSet(dbrApp)        ??
    # set gaSet(dbrBootSwPack) SW0000
    # set gaSet(dbrBoot)       ??
    # SaveUutInit $fil
  } 
  if $gaSet(demo) {
    wm title . "DEMO!!! $gaSet(pair) : $gaSet(DutFullName)"
  } else {
    wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  }
  
  
  
  if [regexp {\.HL\.} $gaSet(DutInitName)] {
    set gaSet(UutOpt) SF1P-4UTP-HL
  } elseif {[regexp {\.4U2S\.} $gaSet(DutInitName)] && ![regexp {\.HL\.} $gaSet(DutInitName)]} {
    set gaSet(UutOpt) SF1P-4UTP
  } elseif [regexp {\.2U\.} $gaSet(DutInitName)] {
    set gaSet(UutOpt) SF1P-2UTP
  } elseif [regexp {ETX} $gaSet(DutInitName)] {
    set gaSet(UutOpt) ETX1P
  } else {
    set gaSet(fail) "$gaSet(DutInitName) is not defined"
    #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    RLSound::Play fail
	  Status "Test FAIL" #ff6464 ; #  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -2
  }
  
  pack forget $gaGui(frFailStatus)
  #Status ""
  update
  RetriveDutFam
  
  #set gaSet(general.flashImg)  "flash-image-1.0.3_[set gaSet(dutFam.mem)]G_.bin"
  set gaSet(general.pcpes)     "pcpe-general-5.2"
  
  
  #ToggleCustometSW
  if {$mode=="full"} {
    BuildTests
    
    set ret [GetDbrSW $barcode]
    puts "GetDbrName ret of GetDbrSW:$ret" ; update
    if {$ret!=0} {
      RLSound::Play fail
  	  Status "Test FAIL" #ff6464 ; #  red
      DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error -title "Get DbrName Problem"
      pack $gaGui(frFailStatus)  -anchor w
  	  $gaSet(runTime) configure -text ""
    }  
  } else {
    set ret 0
  }
  
  if {$ret!=0} {return $ret}
  
  #set csl [RetriveIdTraceData $barcode CSLByBarcode]
  if {$gaSet(manualCSL)=="0"} {
    set csl [RetriveIdTraceData $barcode CSLByBarcode]
  } else {
    set csl $gaSet(manualCSL)
  }
  puts "GetDbrName csl:<$csl>"
  if {$csl!="-1"} {
    set gaSet(csl) $csl
  }
  
  set ret [Linux_SW]
  puts "\nGetDbrName ret after Linux_SW:<$ret>\n"
  if {$ret!=0} {
    Status $gaSet(fail) #ff6464 ; # red
  }
  
  #focus -force $gaGui(curTest)
  if {$ret==0} {
    focus -force $gaGui(entPCB_MAIN_IDbarc)
    $gaGui(entPCB_MAIN_IDbarc) selection range 0 end
    Status "Ready"
  }
  
  return $ret
}

# ***************************************************************************
# Linux_Eeprom
# ***************************************************************************
proc Linux_Eeprom {} {
  global gaSet buffer
  set fil c:/download/etx1p/eeprom.[set gaSet(pair)].txt
  set id [open $fil]
    set eep_content [read $id]
  close $id
  set eep_file $::GuiId.txt
  puts "Linux_Eeprom eep_file:<$eep_file> eep_content:<$eep_content>"
  catch {exec python.exe Etx1p_linuxSwitchSW.py create_eeprom_file $gaSet(linux_srvr_ip) "customer" $eep_file $eep_content} res
  puts "Linux_Eeprom res:<$res>"
  return $res
}

# ***************************************************************************
# RetriveDutFam
## set gaSet(DutInitName) SF-1P.E1.DC.4U2S.2RSM.L1.G.LR2.2R.tcl
## set dutInitName  [regsub -all / SF-1V/E2/12V/4U1S/2RS/L1/G/L1 .].tcl
# RetriveDutFam $dutInitName
# ***************************************************************************
proc RetriveDutFam {{dutInitName ""}} {
  global gaSet 
  array unset gaSet dutFam.*
  set gaSet(hwAdd) ""
  #set gaSet(dutFam) NA 
  #set gaSet(dutBox) NA 
  if {$dutInitName==""} {
    set dutInitName $gaSet(DutInitName)
  }
  puts "[MyTime] RetriveDutFam $dutInitName"
  set fieldsL [split $dutInitName .]
  
  regexp {([A-Z0-9\-\_]+)\.E?} $dutInitName ma gaSet(dutFam.sf)
  switch -exact -- $gaSet(dutFam.sf) {
    SF-1P - ETX-1P - SF-1P_ICE - ETX-1P_SFC - SF-1P_ANG {set gaSet(appPrompt) "-1p#"}
    VB-101V {set gaSet(appPrompt) "VB101V#"}
  }
  
  if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC"} {
    set gaSet(dutFam.box) "ETX-1P"
    if ![regexp {1P\.([A-Z0-9]+)\.} $dutInitName ma gaSet(dutFam.ps)] {
      regexp {1P_SFC\.([A-Z0-9]+)\.} $dutInitName ma gaSet(dutFam.ps)
    }
  } else {
    regexp {P[A-Z_]*\.(E[R\d]?)\.} $dutInitName ma gaSet(dutFam.box)  
    regexp {E[R\d]?\.([A-Z0-9]+)\.} $dutInitName ma gaSet(dutFam.ps)
  }  

  if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC"} {
    set gaSet(dutFam.wanPorts)  "1SFP1UTP"
    set gaSet(dutFam.lanPorts)  "4UTP"
  } else {
    if {[string match *\.2U\.* $dutInitName]} {
      set gaSet(dutFam.wanPorts)  "2U"
    } elseif {[string match *\.4U2S\.* $dutInitName]} {
      set gaSet(dutFam.wanPorts)  "4U2S"
    } elseif {[string match *\.5U1S\.* $dutInitName]} {
      set gaSet(dutFam.wanPorts)  "5U1S"
    }
    set gaSet(dutFam.lanPorts)  "NotExists"
  }
  
  if {[string match *\.2RS\.* $dutInitName]} {
    set gaSet(dutFam.serPort) 2RS
  } elseif {[string match *\.2RSM\.* $dutInitName]} {
    set gaSet(dutFam.serPort) 2RSM
  } elseif {[string match *\.1RS\.* $dutInitName]} {
    set gaSet(dutFam.serPort) 1RS
	} elseif {[string match *\.2RMI\.* $dutInitName]} {
    set gaSet(dutFam.serPort) 2RMI
	} elseif {[string match *\.2RSI\.* $dutInitName]} {
    set gaSet(dutFam.serPort) 2RSI
  } else {
    set gaSet(dutFam.serPort) 0
  }
  
  if {[string match *\.CSP\.* $dutInitName]} {
    set gaSet(dutFam.serPortCsp) CSP
  } else {
    set gaSet(dutFam.serPortCsp) 0
  }
  
  
  if {[string match *\.2PA\.* $dutInitName]} {
    set gaSet(dutFam.poe) 2PA
  } elseif {[string match *\.POE\.* $dutInitName]} {
    set gaSet(dutFam.poe) POE
  } else {
    set gaSet(dutFam.poe) 0
  }
  
  set gaSet(dutFam.cell) 0
  foreach cell [list HSP L1 L2 L3 L4 L450A L450B 5G L4P LG] {
    set qty [llength [lsearch -all [split $dutInitName .] $cell]]
    if $qty {
      set gaSet(dutFam.cell) $qty$cell
      break
    }  
  }
  
  if {[string match *\.G\.* $dutInitName]} {
    set gaSet(dutFam.gps) G
  } else {
    set gaSet(dutFam.gps) 0
  }
  
  if {[string match *\.WF\.* $dutInitName]} {
    set gaSet(dutFam.wifi) WF
  } elseif {[string match *\.WFH\.* $dutInitName] || [string match *\.WH\.* $dutInitName]} {
    set gaSet(dutFam.wifi) WH
  } else {
    set gaSet(dutFam.wifi) 0
  }
  
  if {[string match *\.GO\.* $dutInitName]} {
    set gaSet(dutFam.dryCon) GO
  } else {
    set gaSet(dutFam.dryCon) FULL
  }
  
  if {[string match *\.RG\.* $dutInitName]} {
    set gaSet(dutFam.rg) RG
  } else {
    set gaSet(dutFam.rg) 0
  }
  
  set qty [regexp -all {\.(LR[1-6A-Z])\.} $dutInitName ma lora]
  if $qty {
    set gaSet(dutFam.lora) $lora
    switch -exact -- $lora {
      LR1 {set gaSet(dutFam.lora.region) eu433; set gaSet(dutFam.lora.fam) 4XX; set gaSet(dutFam.lora.band) "EU 433"}
      LR2 {set gaSet(dutFam.lora.region) eu868; set gaSet(dutFam.lora.fam) 8XX; set gaSet(dutFam.lora.band) "EU 863-870"}
      LR3 {set gaSet(dutFam.lora.region) au915; set gaSet(dutFam.lora.fam) 9XX; set gaSet(dutFam.lora.band) "AU 915-928 Sub-band 2"}
      LR4 {set gaSet(dutFam.lora.region) us902; set gaSet(dutFam.lora.fam) 9XX; set gaSet(dutFam.lora.band) "US 902-928 Sub-band 2"}
      LR6 {set gaSet(dutFam.lora.region) as923; set gaSet(dutFam.lora.fam) 9XX; set gaSet(dutFam.lora.band) "AS 923-925"}
      LRA {set gaSet(dutFam.lora.region) us915; set gaSet(dutFam.lora.fam) 9XX; set gaSet(dutFam.lora.band) "US 902-928 Sub-band 2"}
      LRB {set gaSet(dutFam.lora.region) eu868; set gaSet(dutFam.lora.fam) 8XX; set gaSet(dutFam.lora.band) "EU 863-870"}
      LRC {set gaSet(dutFam.lora.region) eu433; set gaSet(dutFam.lora.fam) 4XX; set gaSet(dutFam.lora.band) "EU 433"}
    }
  } else {
    set gaSet(dutFam.lora) 0
  }
  
  set qty [regexp -all {\.(PLC|PLCD|PLCGO)\.} $dutInitName ma plc]
  if $qty {
    set gaSet(dutFam.plc) $plc
  } else {
    set gaSet(dutFam.plc) 0
  }
  
  if {[string match *\.2R\.* $dutInitName]} {
    set gaSet(dutFam.mem) 2
  } else {
    set gaSet(dutFam.mem) 1
  }
  
  if {[string match *\.R06\* $dutInitName]} {
    set gaSet(dutFam.R06) 1
  } else {
    set gaSet(dutFam.R06) 0
  }
  
  puts "[parray gaSet dut*]\n" ; update
#   foreach nam [array names gaSet dutFam.*] {
#     puts -nonewline "$gaSet($nam)."
#   }
#   puts "$dutInitName"


}  
# ***************************************************************************
# BuildEepromString
## BuildEepromString newUut
# ***************************************************************************
proc BuildEepromString {mode} {
  global gaSet
  puts "[MyTime] BuildEepromString $mode"
  
   if ![info exist gaSet(hwAdd)] {
      set gaSet(hwAdd) A
    }
    set gaSet(hwAdd) [string toupper $gaSet(hwAdd)]
    
    if ![info exist gaSet(csl)] {
      set gaSet(csl) A
    }
    set gaSet(csl) [string toupper $gaSet(csl)]
    
    if ![info exist gaSet(mainPcbId)] {
      set gaSet(mainPcbId) "SF-1P.REV0.4I"
    }
    set gaSet(mainPcbId) [string toupper $gaSet(mainPcbId)]
    set res [regexp {REV([\d\.]+)[A-Z]} $gaSet(mainPcbId)  ma gaSet(mainHW)]
    if {$res==0} {
      set gaSet(fail) "Fail to retrive MAIN_CARD_HW_VERSION"
      return -1
    }
    
    if ![info exist gaSet(sub1PcbId)] {
      set gaSet(sub1PcbId) ""
    }
    if {$gaSet(sub1PcbId)!=""} {
      ## "SF-1V.PS.03"
      set gaSet(sub1PcbId) [string toupper $gaSet(sub1PcbId)]
      set res [regexp {PS\.?REV([\d\.]+)[A-Z]} $gaSet(sub1PcbId)  ma gaSet(sub1HW)]
      if {$res==0} {
        set gaSet(fail) "Fail to retrive SUB_CARD_1_HW_VERSION"
        return -1
      }
    } else {
      set gaSet(sub1HW) ""
    }
  
  if {$gaSet(dutFam.cell)=="0" && $gaSet(dutFam.wifi)=="0" && $gaSet(dutFam.lora)=="0"} {
    puts "##no modems, no wifi, no lora"
    set gaSet(eeprom.mod1man) ""
    set gaSet(eeprom.mod1type) ""
    set gaSet(eeprom.mod2man) ""
    set gaSet(eeprom.mod2type) ""
  } elseif {[string index $gaSet(dutFam.cell) 0]=="1" && $gaSet(dutFam.wifi)=="0" && $gaSet(dutFam.lora)=="0"} {
    puts "#### just modem 1, no modem 2 and no wifi, no lora"
    set gaSet(eeprom.mod1man)  [ModMan $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod1type) [ModType $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod2man) ""
    set gaSet(eeprom.mod2type) ""        
  } elseif {[string index $gaSet(dutFam.cell) 0]=="1" && $gaSet(dutFam.wifi)!=0} {
    puts "#### modem 1 and wifi instead of modem 2"
    set gaSet(eeprom.mod1man)  [ModMan $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod1type) [ModType $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod2man)  [ModMan  -$gaSet(dutFam.wifi)]
    set gaSet(eeprom.mod2type) [ModType -$gaSet(dutFam.wifi)]
  } elseif {$gaSet(dutFam.cell)=="0" && $gaSet(dutFam.wifi)!=0} {
    puts "#### no modem 1, wifi instead of modem 2"
    set gaSet(eeprom.mod1man)  ""
    set gaSet(eeprom.mod1type) ""
    set gaSet(eeprom.mod2man)  [ModMan  -$gaSet(dutFam.wifi)]
    set gaSet(eeprom.mod2type) [ModType -$gaSet(dutFam.wifi)]    
  } elseif {[string index $gaSet(dutFam.cell) 0]=="2"} {
    puts "#### two modems are installed"
    set gaSet(eeprom.mod1man)  [ModMan $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod1type) [ModType $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod2man)  [ModMan $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod2type) [ModType $gaSet(dutFam.cell)]
  } elseif {[string index $gaSet(dutFam.cell) 0]=="1" && $gaSet(dutFam.lora)!="0"} {
    puts "#### modem 1 and LoRa instead of modem 2"
    set gaSet(eeprom.mod1man)  [ModMan $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod1type) [ModType $gaSet(dutFam.cell)]
    set gaSet(eeprom.mod2man)  [ModMan  -lora]
    set gaSet(eeprom.mod2type) [ModType -lora]
  } elseif {[string index $gaSet(dutFam.cell) 0]=="0" && $gaSet(dutFam.lora)!="0"} {
    puts "#### no modem 1 and LoRa instead of modem 1"
    set gaSet(eeprom.mod1man)  [ModMan  -lora]
    set gaSet(eeprom.mod1type) [ModType -lora]
    set gaSet(eeprom.mod2man)  ""
    set gaSet(eeprom.mod2type) ""
  }
  
  if {$mode=="newUut"} {
    set ret [GetMac 10]
    if {$ret=="-1" || $ret=="-2"} {
      return $ret
    } 
    foreach {a b} [split $ret {}] {
      append mac ${a}${b}:
    }
    set mac [string trim $mac :]
  } else {
    set mac "NoMac"
  }
  
  puts "BuildEepromString mac:<$mac>"
  set gaSet(eeprom.mac) $mac
  #set mac 00:20:D2:AB:76:92
  
  #set partNum [regsub -all {\.} $gaSet(DutFullName) /]
  if {$gaSet(manualMrktName)=="0"} {
    set partNum [RetriveIdTraceData $gaSet(idBarcode) MKTItem4Barcode]
  } else {
    set partNum $gaSet(manualMrktName)
  } 
  puts "BuildEepromString partNum:<$partNum>"
  if {$partNum=="-1"} {
      set gaSet(fail) "Fail to get MKTItem4Barcode for $gaSet(idBarcode)"
      return -1
    }
  
  if {$gaSet(dutFam.ps)=="ACEX"} {
    set ps 12V
  } elseif {$gaSet(dutFam.ps)=="DC" && $gaSet(mainHW) <= 0.5} {
    set ps 12V
  } elseif {$gaSet(dutFam.ps)=="DC" && $gaSet(mainHW) > 0.5} {
    set ps DC
  } elseif {$gaSet(dutFam.ps)=="WDC"} {
    set ps WDC-I
  } elseif {$gaSet(dutFam.ps)=="12V"} {
    set ps 12V-I
  } elseif {$gaSet(dutFam.ps)=="D72V"} {
    set ps D72V-I
  } elseif {$gaSet(dutFam.ps)=="FDC"} {
    set ps FDC-I
  } elseif {$gaSet(dutFam.ps)=="RDC"} {
    set ps RDC-I
  }  
  set gaSet(eeprom.ps) $ps
  
  switch -exact -- $gaSet(dutFam.serPort) {
    0           {set ser1 "";       set ser2 "";      set 1rs485 "";   set 2rs485 ""; set 1cts ""   ; set 2cts ""   }
    2RS  - 2RSI {set ser1 "RS232";  set ser2 "RS232"; set 1rs485 "";   set 2rs485 ""; set 1cts "YES"; set 2cts "YES"}
    2RSM - 2RMI {set ser1 "RS485";  set ser2 "RS232"; set 1rs485 "2W"; set 2rs485 ""; set 1cts "YES"; set 2cts "YES"}
    1RS         {set ser1 "RS232";  set ser2 "";      set 1rs485 "";   set 2rs485 ""; set 1cts "YES"; set 2cts ""   }
  }
  set gaSet(eeprom.ser1) $ser1
  set gaSet(eeprom.ser2) $ser2
  set gaSet(eeprom.1rs485) $1rs485
  set gaSet(eeprom.2rs485) $2rs485
  
  switch -exact -- $gaSet(dutFam.poe) {
    0   {set poe ""}
    2PA   {set poe "2PA"}
    POE   {set poe "POE"}
  }
  set gaSet(eeprom.poe) $poe
  
  if {$mode=="newUut"} {
    set txt ""
    append txt MODEM_1_MANUFACTURER=${gaSet(eeprom.mod1man)},
    append txt MODEM_2_MANUFACTURER=${gaSet(eeprom.mod2man)},
    append txt MODEM_1_TYPE=${gaSet(eeprom.mod1type)},
    append txt MODEM_2_TYPE=${gaSet(eeprom.mod2type)},
    append txt MAC_ADDRESS=${mac},
   
    append txt MAIN_CARD_HW_VERSION=${gaSet(mainHW)},
    if {$gaSet(mainHW)>="0.6"} {
      append txt SUB_CARD_1_HW_VERSION=${gaSet(sub1HW)},
    } else {
      append txt SUB_CARD_1_HW_VERSION=,
    }
    
    if {$gaSet(mainHW)<"0.6"} {
      set gaSet(hwAdd) "" ; #"A"
    } elseif {$gaSet(mainHW)>="0.6"} {
      set gaSet(hwAdd) "C"
      if {$gaSet(mainHW)=="0.6" && ($gaSet(DutFullName)=="SF-1P/E1/DC/4U2S/2RSM/5G/2R" ||\
                                    $gaSet(DutFullName)=="SF-1P/E1/DC/4U2S/2RSM/5G/G/LRB/2R" ||\
                                    $gaSet(DutFullName)=="SF-1P/E1/DC/4U2S/2RSM/5G/LRA/2R")} {
        set gaSet(hwAdd) "B"
      }  
    }
    append txt HARDWARE_ADDITION=${gaSet(hwAdd)},
    
    append txt CSL=${gaSet(csl)},
    append txt PART_NUMBER=${partNum},
    append txt PCB_MAIN_ID=${gaSet(mainPcbId)},
    if {$gaSet(mainHW)>="0.6"} {
      append txt PCB_SUB_CARD_1_ID=${gaSet(sub1PcbId)},
    } else {
      append txt PCB_SUB_CARD_1_ID=,
    }
    append txt PS=${ps},
    if {[string match *.HL.*  $gaSet(DutInitName)] || $gaSet(dutFam.sf) == "ETX-1P"} {
      ## HL option and ETX-1P don't have MicroSD
      append txt SD_SLOT=,
    } else {
      append txt SD_SLOT=YES,
    }
    append txt SERIAL_1=${ser1},
    append txt SERIAL_2=${ser2},
    append txt SERIAL_1_CTS_DTR=${1cts},
    append txt SERIAL_2_CTS_DTR=${2cts},
    append txt RS485_1=${1rs485},
    append txt RS485_2=${2rs485},
    #append txt POE=${poe},
    if {$gaSet(dutFam.sf) == "ETX-1P"} {
      append txt DRY_CONTACT_IN_OUT=,
    } else {
      append txt DRY_CONTACT_IN_OUT=2_2,
    }
    if {$gaSet(dutFam.wanPorts) == "4U2S"} {
      append txt NNI_WAN_1=FIBER,
      append txt NNI_WAN_2=FIBER,
      append txt LAN_3_4=YES,
    } elseif {$gaSet(dutFam.wanPorts) == "2U"} {
      append txt NNI_WAN_1=,
      append txt NNI_WAN_2=,
      append txt LAN_3_4=,
    } elseif {$gaSet(dutFam.wanPorts) == "5U1S"} {
      append txt NNI_WAN_1=FIBER,
      append txt NNI_WAN_2=FIBER,
      append txt LAN_3_4=YES,
    } elseif {$gaSet(dutFam.wanPorts) == "1SFP1UTP"} {
      append txt NNI_WAN_1=FIBER,
      append txt NNI_WAN_2=COPPER,
      append txt LAN_3_4=YES,
    }
    #append txt USB-A=YES,
    #append txt M.2-2=,
    append txt LIST_REF=0.0,
    #append txt SER_NUM=,
    append txt END=
    
    if [info exists gaSet(log.$gaSet(pair))] {
      AddToPairLog $gaSet(pair) "$txt"  
    }
    
    set fil c:/download/etx1p/eeprom.[set gaSet(pair)].txt
    if [file exists $fil] {
      file copy -force $fil c:/temp/[clock format  [clock seconds] -format  "%Y.%m.%d-%H.%M.%S"].eeprom.[set gaSet(pair)].txt
      catch {file delete -force $fil}
    }
    after 500
    set id [open $fil w]
      puts -nonewline $id $txt
    close $id
    
    puts "\n$txt\n"
  }
  
  return 0
} 

# ***************************************************************************
# ModMan
# ***************************************************************************
proc ModMan {cell} {
  switch -exact -- [string range $cell 1 end] {
    HSP - L1 - L2 - L3 - L4 - LG {return QUECTEL}
    WF                           {return AZUREWAVE}
    lora                         {return RAK}
    L450A                        {return Unitac}
    L450B                        {return Unitac}
    5G                           {return "SIERRA WIRELESS"}
    WH                           {return GATEWORKS}
    L4P                          {return Sequans}
    LTA - LTG                    {return Telit} 
  }
}  
# ***************************************************************************
# ModType
# ***************************************************************************
proc ModType {cell} {
  global gaSet
  switch -exact -- [string range $cell 1 end] {
    HSP  {return UC20}
    L1   {return EC25-E}
    L2   {return EC25-A}
    L3   {return EC25-AU}
    L4   {return EC25-AFFD}
    WF   {return AW-CM276MA}
    lora {
      switch -exact -- $gaSet(dutFam.lora) {
         LR1 {return EU433}
         LR2 {return RAK-5146}
         LR3 {return US915}
         LR4 {return US915}
         LR6 {return AS923}
         LR7 {return EU868}
         LRA {return 9XX}
         LRB {return 8XX}
         LRC {return LRC}
      }  
    }
    L450A {return ML620EU}
    L450B {return ML660PC}
    5G    {return EM9191}
    LG    {return EC25-G}
    WH    {return GW16146}
    L4P   {return CA410M}
    LTA   {return MPLS83-X}
    LTG   {return MPLS83-W}
  }
}    

# ***************************************************************************
# GetMac
# ***************************************************************************
proc GetMac {qty} {
  global gaSet buffer
  puts "[MyTime] GetMac $qty MACServer.exe" 
  set macFile c:/temp/mac.$::GuiId.txt
  exec $::RadAppsPath/MACServer.exe 0 $qty $macFile 1
  set ret [catch {open $macFile r} id]
  if {$ret!=0} {
    set gaSet(fail) "Open Mac File fail"
    return -1
  }
  set buffer [read $id]
  close $id
  file delete $macFile
  set ret [regexp -all {ERROR} $buffer]
  if {$ret!=0} {
    set gaSet(fail) "MACServer ERROR"
    return -1
  }
  set mac [lindex $buffer 0]  ; # 1806F5F4763B
  puts "GetMac mac:<$mac>"
  return $mac    
}

## RetriveIdTraceData DF100148093 CSLByBarcode
## RetriveIdTraceData DF100148093 MKTItem4Barcode
## RetriveIdTraceData 21181408    PCBTraceabilityIDData
## RetriveIdTraceData TO300315253 OperationItem4Barcode
# ***************************************************************************
# RetriveIdTaceData
# ***************************************************************************
proc RetriveIdTraceData {args} {
  global gaSet
  set gaSet(fail) ""
  puts "RetriveIdTaceData $args"
  set barc [format %.11s [lindex $args 0]]
  
  set command [lindex $args 1]
  switch -exact -- $command {
    CSLByBarcode          {set barcode $barc  ; set traceabilityID null}
    PCBTraceabilityIDData {set barcode null   ; set traceabilityID $barc}
    MKTItem4Barcode       {set barcode $barc  ; set traceabilityID null}
    OperationItem4Barcode {set barcode $barc  ; set traceabilityID null}
    default {set gaSet(fail) "Wrong command: \'$command\'"; return -1}
  }
  set url "https://ws-proxy01.rad.com:8445/ATE_WS/ws/rest/"
  set param [set command]\?barcode=[set barcode]\&traceabilityID=[set traceabilityID]
  append url $param
  puts "url:<$url>"
  set tok [::http::geturl $url -headers [list Authorization "Basic [base64::encode webservices:radexternal]"]]
  update
  set st [::http::status $tok]
  set nc [::http::ncode $tok]
  if {$st=="ok" && $nc=="200"} {
    #puts "Get $command from $barc done successfully"
  } else {
    puts "http::status: <$st> http::ncode: <$nc>"
  }
  upvar #0 $tok state
  parray state
  #puts "$state(body)"
  set body $state(body)
  ::http::cleanup $tok
  
  set re {[{}\[\]\,\t\:\"]}
  set tt [regsub -all $re $body " "]
  set ret [regsub -all {\s+}  $tt " "]
  
  if {$st=="ok" && $nc=="200"} {
    return [lindex $ret end]
  } else {
    return -1
  }  
}

# ***************************************************************************
# GetPcbID
# ***************************************************************************
proc GetPcbID {board} {
  global gaSet gaGui
  set gaSet([set board]PcbId) "" ; update
  set barc $gaSet([set board]PcbIdBarc)
  set pcbName -1
  if {$barc==""} {
    # do nothing
  } else {
    set pcbName [RetriveIdTraceData $barc PCBTraceabilityIDData]
  }
  puts "GetPcbID board:<$board> barc:<$barc> pcbName:<$pcbName>" 
  if {$pcbName=="-1"} {
    return -1
  } else {
    set gaSet([set board]PcbId) $pcbName
    #set gaSet([set board]PcbIdBarc) ""
    if {$board=="main"} {
      focus -force $gaGui(entPCB_SUB_CARD_1_IDbarc) 
      $gaGui(entPCB_SUB_CARD_1_IDbarc) selection range 0 end
      set res [regexp {REV([\d\.]+)[A-Z]} $gaSet(mainPcbId)  ma gaSet(mainHW)]
      if {$res==1} {
          set ret 0
        } else {
          set gaSet(fail) "Fail to retrive mainHW from mainPcbId"
          return -1
        } 
    }
    return 0
  }
}
# ***************************************************************************
# SanityBarcodes
# ***************************************************************************
proc SanityBarcodes {} {
  global gaSet
  if ![info exists gaSet(mainPcbIdBarc)] {
    set gaSet(mainPcbIdBarc) ""
  }
  if ![info exists gaSet(sub1PcbIdBarc)] {
    set gaSet(sub1PcbIdBarc) ""
  }
  puts "\nSanityBarcodes ID:<$gaSet(idBarcode)> Main:<$gaSet(mainPcbIdBarc)> Sub:<$gaSet(sub1PcbIdBarc)>"
  set ret 0
  if {$gaSet(idBarcode) eq ""} {
    set gaSet(curTest) $gaSet(startFrom)
    set gaSet(fail) "Scan the UUT IdBarcode"
    set ret -1
  }
  if {$ret==0 && $gaSet(mainPcbIdBarc)==""} {
    set gaSet(fail) "Scan MainCard TraceID "
    set ret -1
  }
  if {$ret==0 && $gaSet(mainPcbIdBarc) == $gaSet(sub1PcbIdBarc)} {
    set gaSet(fail) "MainCard and Sub1Card TraceID are same"
    set ret -1
  }
  if {$ret==0 && ($gaSet(dutFam.ps)=="WDC" || $gaSet(dutFam.ps)=="12V")} {
    if {$gaSet(sub1PcbIdBarc)==""} {
      set gaSet(fail) "Scan Sub1Card TraceID "
      set ret -1
    }
  }
  puts "SanityBarcodes ret:<$ret>"
  return $ret
}
# ***************************************************************************
# DtbDefine
# ***************************************************************************
proc DtbDefine {} {
  global gaSet 
  puts "\n[MyTime] DtbDefine"
  if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC"} {
    set dtb armada-3720-Etx1p.dtb
  } elseif {$gaSet(dutFam.sf)=="SF-1P" || $gaSet(dutFam.sf)=="SF-1P_ICE" || $gaSet(dutFam.sf)=="SF-1P_ANG"} {
    if {$gaSet(dutFam.wanPorts) == "2U"} {
      set dtb armada-3720-SF1p.dtb
    } else {
      if {[string match *.HL.*  $gaSet(DutInitName)]} {
        set dtb armada-3720-SF1p_superSet_hl.dtb
      } elseif {[string match *.R06*  $gaSet(DutInitName)]} {
        set dtb armada-3720-SF1p_superSet_cp2.dtb
      } else {
        set dtb armada-3720-SF1p_superSet.dtb
      }
      set mainPcbId [string toupper $gaSet(mainPcbId)]
      set res [regexp {REV([\d\.]+)[A-Z]} $mainPcbId  ma mainHW]
      if {$res==0} {
        set gaSet(fail) "Fail to retrive MAIN_CARD_HW_VERSION"
        return -1
      }
      if {$mainHW >= 0.6} {
        set dtb armada-3720-SF1p_superSet_cp2.dtb
      }
    }
  }
  puts "DtbDefine dtb:<$dtb>"
  return $dtb
}

# ***************************************************************************
# CreateHostValGuiId
# ***************************************************************************
proc CreateHostValGuiId {} {
  global gaSet
  puts "\n[MyTime] CreateHostValGuiId"
  set val 0
  if {[string match {*ilya-g*} [info host]]} {
    set ::hostVal ilyagi
  } else {
    regexp {dnld-(\d)-} [info host] ma val
    set ::hostVal $val
  }
  set ::GuiId $::hostVal.$gaSet(pair)
  puts "CreateHostValGuiId hostVal:<$::hostVal> GuiId:<$::GuiId>"
  return {}
}
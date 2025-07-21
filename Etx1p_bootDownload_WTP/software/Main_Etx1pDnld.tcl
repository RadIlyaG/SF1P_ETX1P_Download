# ***************************************************************************
# BuildTests
# ***************************************************************************
proc BuildTests {} {
  global gaSet gaGui  glTests
  
  #set glTests [list DownloadBoot]
  set glTests [list] ; #Linux_SW
  # if {$gaSet(dnldMode)==0} {
    # lappend glTests [list Update_Uboot]
  # }  
  if {$gaSet(secBoot)==0} {
    lappend glTests [list Update_Uboot]
  }  
  #lappend glTests SetEnv Download_FlashImage Download_BootParamImage
  #if {$gaSet(dnldMode)==1} {
  #  lappend glTests SetEnv Download_FlashImage Download_BootParamImage
  #  lappend glTests [list Eeprom]
  # }
  
  
  if {$gaSet(secBoot)==0} {
    lappend glTests SetEnv
    lappend glTests Download_FlashImage 
    if $gaSet(enDwnlBootParamImg) {
      lappend glTests Download_BootParamImage
    }  
  } else {
    lappend glTests SecureBoot
    lappend glTests SetEnv
  }
  lappend glTests Eeprom
  lappend glTests RunBootNet ID
  if {$gaSet(UutOpt)=="ETX1P"} {
    # ETX1P doesn't have MicroSD
  } else {
    lappend glTests MicroSD
  }
  lappend glTests SOC_Flash_Memory SOC_i2C 
  lappend glTests FrontPanelLeds
  if [info exists gaSet(dbrBootSwVer)] {
    set dbrBootSwVer $gaSet(dbrBootSwVer)
  } else {
    set dbrBootSwVer 1.1
  }
  if {[package vcompare $dbrBootSwVer "6.3"] < 0} {
    ## boot < 6.3
    ## do nothing
  } else {
    ## boot >= 6.3
    lappend glTests Disable_Uboot
  }  
  
  set gaSet(startFrom) [lindex $glTests 0]
  $gaGui(startFrom) configure -values $glTests -height [llength $glTests]

}

# ***************************************************************************
# Testing
# ***************************************************************************
proc Testing {} {
  global gaSet glTests

  set startTime [$gaSet(startTime) cget -text]
  set stTestIndx [lsearch $glTests $gaSet(startFrom)]
  set lRunTests [lrange $glTests $stTestIndx end]
  
  if ![file exists c:/logs] {
    file mkdir c:/logs
    after 1000
  }
  set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M"]
  set gaSet(logFile) c:/logs/logFile_[set ti]_$gaSet(pair).txt
  
#   if {[string match {*Leds*} $gaSet(startFrom)] || [string match {*Mac_BarCode*} $gaSet(startFrom)]} {
#     set ret 0
#   }
  
  set pair 1
  if {$gaSet(act)==0} {return -2}
    
  set ::pair $pair
  puts "\n\n ********* DUT start *********..[MyTime].."
  Status "DUT start"
  set gaSet(curTest) ""
  update
    
  AddToPairLog $gaSet(pair) "********* DUT start *********"
  AddToPairLog $gaSet(pair) " $gaSet(idBarcode) " 
  AddToPairLog $gaSet(pair) " $gaSet(DutFullName) "
  AddToPairLog $gaSet(pair) "MainCard $gaSet(mainPcbIdBarc) $gaSet(mainPcbId) "
  AddToPairLog $gaSet(pair) "SubCard1 $gaSet(sub1PcbIdBarc) $gaSet(sub1PcbId) "
  puts "RunTests1 gaSet(startFrom):$gaSet(startFrom)"

  foreach numberedTest $lRunTests {
    set gaSet(curTest) $numberedTest
    puts "\n **** Test $numberedTest start; [MyTime] "
    update
      
    set testName [lindex [split $numberedTest ..] end]
    $gaSet(startTime) configure -text "$startTime ."
    AddToPairLog $gaSet(pair) "Test \'$testName\' started"
    set ret [$testName]
    if {$ret=="-1" && $testName=="RunBootNet" && $gaSet(fail)=="Can't get Kernel Image"} {
      puts "\n **** [MyTime] Ret of $testName is: $ret. Second try \n" 
      set ret [$testName]
    }
    if {$ret==0} {
      set retTxt "PASS."
    } else {
      set retTxt "FAIL. Reason: $gaSet(fail)"
    }
    AddToPairLog $gaSet(pair) "Test \'$testName\' $retTxt"
       
    puts "\n **** Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n" 
    update
    if {$ret!=0} {
      break
    }
    if {$gaSet(oneTest)==1} {
      set ret 1
      set gaSet(oneTest) 0
      break
    }
  }
  catch {CaptureConsole}
  
  if {$ret==0} {
    AddToPairLog $gaSet(pair) ""
    AddToPairLog $gaSet(pair) "All tests pass"
  } 

  puts "RunTests4 ret:$ret gaSet(startFrom):$gaSet(startFrom)"   
  return $ret
}

# ***************************************************************************
# DownloadBoot
# ***************************************************************************
proc DownloadBoot {run} {
  global gaSet
  RLEH::Open
  OpenPio 
  Power all off
  after 4000
  Power all on
  ClosePio
  RLEH::Close
  update
  after 1000
    
  if [catch { exec c:/teraterm/ttpmacro.exe /I 1.ttl $gaSet(pair) 5.0.0.49 $gaSet(comDut) $gaSet(dnldMode)} res] {
    puts $res
    set ret -1
    set txt Fail
  } else {
    puts OK
    set ret 0
    set txt Pass
  }
  AddToPairLog $gaSet(pair) "Download $txt"
  
#   ClosePio
#   RLEH::Close
  
  return $ret  
}

# ***************************************************************************
# Update_Uboot
# ***************************************************************************
proc Update_Uboot {} {
  global gaSet buffer
  Status "Reaching E"
  
  set com  $gaSet(comDut)
  puts [clock seconds]
  set origWtpPath C:/WTP_Windows_Tools
  set wtpPath C:/WTP_Windows_Tools$gaSet(pair)
  if ![file exists $wtpPath] {
    file mkdir $wtpPath
  }
  foreach orfil {WtpDownload.exe USBInterface.dll} destfil "WtpDownload$gaSet(pair).exe USBInterface.dll" {
    if {![file exists $wtpPath/$destfil] || ([file mtime $origWtpPath/$orfil] != [file mtime $wtpPath/$destfil])} {
      if [catch {file copy $origWtpPath/$orfil $wtpPath/$destfil} res] {
        set gaSet(fail) "Copy $orfil fail ($res)"
        return -1
      } 
    }
  }
  
  set filesPath $gaSet(uBootFilesPath)/[set gaSet(dutFam.mem)]G
  puts "filesPath:<$filesPath>"
  ##set gaSet(downloadUbootAnyWay) No
  foreach fil {TIM_ATF.bin wtmi_h.bin boot-image_h.bin} { 
    ## 15:57 29/05/2023 if {![file exists $wtpPath/$fil] || ([file mtime $filesPath/$fil] != [file mtime $wtpPath/$fil])} {}
    set sourceMtime [file mtime $filesPath/$fil]
    set sourceHumanmtime [clock format $sourceMtime -format "%d/%m/%Y %H:%M:%S"]
    set destMtime [file mtime $wtpPath/$fil]
    if {($sourceMtime != $destMtime)} {
      set gaSet(downloadUbootAnyWay) Yes 
      if [catch {file copy -force $filesPath/$fil $wtpPath} res] {
        set gaSet(fail) "Copy $fil fail ($res)"
        return -1
      } else {
        
        puts "$fil copied. Res:<$res> MTime: $sourceHumanmtime"
      }
    } else {
      puts "$fil Same MTime: $sourceHumanmtime"
    }
    update
  }
  after 2000
  puts [clock seconds] 
  catch {file delete -force log$gaSet(pair).txt}
  set cmd "$wtpPath/WtpDownload$gaSet(pair).exe -P UART -C $com -R 115200 \
      -B $wtpPath/TIM_ATF.bin -I $wtpPath/boot-image_h.bin -I $wtpPath/wtmi_h.bin  -E > log$gaSet(pair).txt" 
  puts "\n<$cmd>\n" ; update
  
  # 16:03 29/05/2023
  # catch {RLCom::Close $com}
  # catch {RLEH::Close}
  
#   RLEH::Open
#   OpenPio 
#   Power all off
#   after 4000
#   Power all on
#   ClosePio
#   RLEH::Close
#   update
#   after 1000
  
  # 16:03 29/05/2023
  # RLEH::Open
  # set ret [RLCom::Open $com 115200 8 NONE 1]
  # if {$ret!=0} {
    # set gaSet(fail) "Open COM $com fail"
     # return $ret
  # }
  
  Status "Reaching E"
  set ret -1
  for {set i 1} {$i<=10} {incr i} {
    set ret [Send $com \r\r "gggg" 1]
    set buffer [join $buffer ""]
    if {[string match *E>* $buffer]} {
      set ret 0
      break
    }
  }
  if {$ret!=0} {
    set gaSet(fail) "The UUT doesn't respond by E>"
    return $ret
  }
  set gaSet(ubootAlreadyHere) 0
  puts "[MyTime] downloadUbootAnyWay:$gaSet(downloadUbootAnyWay)"
  if {$gaSet(downloadUbootAnyWay)=="Yes"} {
    ## don't seek PCPE
  } elseif {$gaSet(downloadUbootAnyWay)=="No"}  {
    Status "Reaching PCPE"
    #set gaSet(ubootAlreadyHere) 0
    set ret [Send $com "x\rx\r" "WTMI"] 
    if {$ret==0} {     
      set ret [Send $com "x\rx\r" "WTMI"] 
    }
    if {$ret==0} {     
      set ret [Send $com "x\rx\r" "WTMI"] 
    }
    if {$ret==0} {
      set gaSet(fail) "Boot after xx Fail"
      set ret [ReadCom $com "to stop autoboot" 120]
      if {$ret==0} {
        set gaSet(fail) "No \'PCPE\' respond"
        set ret [Send $com "\r\r" "PCPE"] 
        puts "\n[MyTime] UBoot already here. No need to download it again\n"
        set gaSet(ubootAlreadyHere) 1 
      }
    } else {
      set gaSet(downloadUbootAnyWay) "Yes"
    }
  }  
  puts "[MyTime] downloadUbootAnyWay:$gaSet(downloadUbootAnyWay) ubootAlreadyHere:$gaSet(ubootAlreadyHere)"

  if {$ret==0 && $gaSet(downloadUbootAnyWay)=="No" && $gaSet(ubootAlreadyHere)} {
    return 0
  }  
  
  if {$ret!=0} {
    return $ret
  }
  
  Status "Download Uboot by WTP"
  Send $com "wtp\r" "gggg" 1
  
  catch {RLCom::Close $com}
  catch {RLEH::Close}  
  puts "[MyTime] COM $com closed" ; update
  
#   set cmd "C:/WTP_Windows_Tools/WtpDownload.exe -P UART -C $com -R 115200 \
#       -B $filesPath/TIM_ATF.bin -I $filesPath/wtmi_h.bin -I $filesPath/boot-image_h.bin -E"
#   set cmd "$wtpPath/WtpDownload.exe -P UART -C $com -R 115200 \
#       -B $wtpPath/TIM_ATF.bin -I $wtpPath/wtmi_h.bin -I $wtpPath/boot-image_h.bin -E"    
#   puts "\n<$cmd>\n" ; update

  puts "before after [MyTime]"; update 
  #after 180000 KillWpd  
  
  ###########################################
  ## Sinse WtpDownload.exe sometimes stucks and does exit, I operate an external wish.exe
  ## That wish operates KillWtp.tcl 
  ## That KillWtp.tcl is reading an log$gaSet(pair).txt each 1 sec
  ## If [string match {*Download file complete for image 3*} $lines] then  
  ##  the WtpDownload is killed
  ###########################################
  set log log$gaSet(pair).txt
  catch {file delete -force $log}
  after 1000
  exec [info nameofexecutable] KillWtp.tcl $gaSet(pair) &  
  after 1000
  puts "before exe [MyTime]"; update
  ###########################################
  ## Operating the WtpDownload
  ########################################### 
  catch {eval exec $cmd} res
  
  if [file exists $log] {
    set id [open $log r]
    set lines [read $id]
    close $id
    #puts "\n<$lines>\n" ; update    
  }
  puts "lines:<$lines>" ; update
  # if {[string match {*WtpDownload Incomplete*} $lines]} {
    # set gaSet(fail) "WtpDownload Incomplete"
    # set ret -1
    # return $ret
  # }
  if {[string match {*Download file complete for image 1*} $lines] && \
      [string match {*Download file complete for image 2*} $lines] && \
      [string match {*Download file complete for image 3*} $lines]} {
    set ret 0  
    catch {file delete -force $log}   
  } else {
    set gaSet(fail) "Uboot download fail"
    set ret -1
    return $ret
  }
  
  RLEH::Open
  set ret [RLCom::Open $com 115200 8 NONE 1]
  if {$ret!=0} {
    set gaSet(fail) "Open COM $com fail"
    return $ret
  }
  puts "[MyTime] COM $com Opened" ; update
  
  set ::buff ""
  RLCom::Read $com ::buff
  
  
  set ret -1
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=25} {incr i} {
    set ret [Send $com \r\r "PCPE>" 1]
    append ::buff $buffer
    if {$ret==0} {break}
  }
  
#   catch {RLCom::Close $com}
#   catch {RLEH::Close}
  
  puts "\n\n[MyTime] All messages after WTP:\n$::buff\n"
  if {$ret!=0} {
    set gaSet(fail) "No \'PCPE\' after Uboot download"
    #catch {CaptureConsole}
    return $ret
  } 
  
  return $ret 
}
# ***************************************************************************
# SetEnv
# ***************************************************************************
proc SetEnv {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret -1
  Status "Set Environment"
  
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1] ; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1 ; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  set gaSet(fail) "Set Environment Fail"
  set ret [Send $com "setenv serverip 10.10.10.1\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  
  CreateHostValGuiId
  
  # perform it later, befor MACs
  # set ret [Send $com "setenv ipaddr 10.10.10.1${::hostVal}$gaSet(pair)\r" "PCPE>"]
  # if {$ret!=0} {return $ret}
  # set ret [Send $com "setenv gatewayip 10.10.10.1\r" "PCPE>"]
  # if {$ret!=0} {return $ret}
  # set ret [Send $com "setenv netmask 255.255.255.0\r" "PCPE>"]
  # if {$ret!=0} {return $ret}
  
    
  if !$gaSet(secBoot) {
    set dtb [DtbDefine]
    if {$dtb=="-1"} {return $dtb}
    
    if [info exists gaSet(log.$gaSet(pair))] {
      AddToPairLog $gaSet(pair) "Armada: $dtb"  
    }
    set ret [Send $com "setenv fdt_name boot/$dtb\r" "PCPE>"]
  } else {
    set gaSet(fail) "Set Environment Fail"
    set ret [Send $com "env default -f -a\r" "default environment"]
    if {$ret!=0} {return $ret}
    set gaSet(fail) "Save Environment Fail"
    set ret [Send $com "saveenv\r" "SPI flash...done"]
    if {$ret!=0} {return $ret}
    
    # 14:45 20/07/2025
    # set ret [Send $com "reset\r" "resetting .."] 
    # set gaSet(fail) "No \'PCPE\' respond"
    # for {set i 1} {$i<=20} {incr i} {
      # set ret [Send $com c\rc\r "PCPE>" 1] ; ## 10/07/2025 add c to stop in boot 6.4
      # if {$ret==0} {break}
      # if [string match {* E *} $buffer] {
        # Send $com "x\rx\r" "PCPE>" 1 ; ## 10/07/2025 add c to stop in boot 6.4
      # }
    # }
    # if {$ret!=0} {return $ret}
    
    if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC" || $gaSet(dutFam.sf)=="ETX-1P_A"} {
      set scr set_etx1p
    } else {
      if {[string match *.HL.*  $gaSet(DutInitName)]} {
        set scr set_sf1p_superset_hl
      } else {
        set scr set_sf1p_superset_cp2
      }
    }
    puts "\n[MyTime]Script:<$scr>"
    set ret [Send $com "run $scr\r" "SPI flash...done"]
    if {$ret!=0} {return $ret}
    
    ## 09:54 20/07/2025
    set ret [Send $com "setenv serverip 10.10.10.1\r" "PCPE>"]
    if {$ret!=0} {return $ret}
    ## 
        
        
    if {[package vcompare $gaSet(dbrBootSwVer) 6.4.0]=="-1"} {
      ## if boot is before 6.4
      set ret [Send $com "setenv set_nfsroot \"setenv nfsserv\;setenv nfsserv root=/dev/nfs rootfstype=nfs nfsroot=\$serverip:/srv/nfs/pcpe-general,vers=2,tcp\"\r" "PCPE>>"]
      if {$ret!=0} {return $ret}
    }
  }
  
  
  set ret [Send $com "setenv ipaddr 10.10.10.1${::hostVal}$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv gatewayip 10.10.10.1\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv netmask 255.255.255.0\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  
  
  ## 28/07/2021 11:41:00set ret [Send $com "setenv fdt_name boot/armada-3720-Etx1p.dtb\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth1addr  00:5${::hostVal}:82:11:21:${gaSet(pair)}$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth2addr  00:5${::hostVal}:82:11:22:${gaSet(pair)}$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth3addr  00:5${::hostVal}:82:11:23:${gaSet(pair)}$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth4addr  00:5${::hostVal}:82:11:24:${gaSet(pair)}$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  if {[package vcompare $gaSet(dbrBootSwVer) 6.4.0]=="-1"} {
    ## if boot is before 6.4
    set ret [Send $com "setenv ethact neta@40000\r" "PCPE>"]
  } 
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "setenv NFS_VARIANT general\r" "PCPE>"]
  set ret [Send $com "setenv config_nfs \"setenv NFS_DIR /srv/nfs/pcpe-general\"\r" "PCPE>"]
  if !$gaSet(secBoot) {
    if $gaSet(enStaticIp) {
        set ret [Send $com "setenv set_bootnetargs \"setenv bootargs console=ttyMV0,115200 earlycon=ar3700_uart,0xd0012000 \
            root=/dev/nfs rw rootwait rootfstype=nfs ip=\$ipaddr:\$serverip:\$gatewayip:\$netmask:\$hostname:lan0:none \
            nfsroot=\$serverip:/srv/nfs/pcpe-general,vers=2,tcp \$NFS_TYPE\"\r" "PCPE>"]
    }    
  } 
  if {[package vcompare $gaSet(dbrBootSwVer) 6.4.0]>=0} {
    ## if boot is 6.4 and more
    set ret [Send $com "setenv set_nfsserv \"setenv -f nfsserv root=/dev/nfs rootfstype=nfs nfsroot=\$serverip:/srv/nfs/pcpe-general,vers=4,tcp\"\r" "PCPE>"]
  }
  
  set ret [Send $com "saveenv\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  
  
  set gaSet(fail) "Ping to 10.10.10.1 Fail"
  set ret [Send $com "ping 10.10.10.1\r" "is alive"]
  if {$ret!=0} {
    set ret [Send $com "ping 10.10.10.1\r" "is alive"]
    if {$ret!=0} {return $ret}
  }
  
  #set ret [Send $com "reset\r" "resetting .."] 
  
  return $ret
}

# ***************************************************************************
# Download_FlashImage
# ***************************************************************************
proc Download_FlashImage {} {
  global gaSet buffer
  Status "Download flash-image"
  set com $gaSet(comDut)  
  set ret -1
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1] ; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1 ; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  set gaSet(fail) "Download FlashImage Fail"
  
  set flashImg $gaSet(general.flashImg)
  
  # switch $gaSet(dutFam.mem) {
    # 1 {set flashImg "flash-image-1.0.3_1G_.bin"}
    # 2 {set flashImg "flash-image-1.0.3_2G_.bin"}
  # }
  # set gaSet(general.flashImg) $flashImg
  
  if [info exists gaSet(log.$gaSet(pair))] {
    AddToPairLog $gaSet(pair) "Boot: $flashImg"  
  }
  
  set ret [Send $com "bubt $flashImg spi tftp\r" "Done"]
  
  if {[string match "*Done*" $buffer]} {
    set ret 0
  } else {
    set ret [ReadCom $com "Done" 120]
  }
  
  if !$gaSet(enDwnlBootParamImg) {
    if {$ret==0} {
      set ret [Send $com "reset\r" "resetting .."]  
    }       
    
    if {$ret==0} {
      set pcpe no
      set ret -1
      for {set i 1} {$i<=20} {incr i} {
        puts "\n $i" ; update
        set ret [Send $com c\rc\r "g${i}g${i}g" 1] ; ## 10/07/2025 add c to stop in boot 6.4
        set buffer [join $buffer ""]
        if {[string match *E>* $buffer]} {
          if {[string match {*PCPE>*} $buffer]} {
            puts "\npcpe!!!\n";  update
            set pcpe yes
          }
          set ret 0
          break
        }
        
      }
      if {$ret!=0} {
        set gaSet(fail) "The UUT doesn't respond by E>"
      }  
    }
    
    if {$ret==0} {
      for {set i 1} {$i<=2} {incr i} {
        set ret [EnvDefSaveEnv]
        if {$ret==0} {break}
      }
    }
  }
  
  return $ret  
}

# ***************************************************************************
# Download_BootParamImage
# ***************************************************************************
proc Download_BootParamImage {} {
  global gaSet buffer
  set com $gaSet(comDut)  
  set ret -1
  Status "Download boot files"
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  
  set gaSet(fail) "Download set_boot_param_recovery Fail"
  #set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_recovery.img\r" "done"]
  
#   07/02/2022 08:44:39
#   if {$gaSet(customer)=="general"} {
#     set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_etx_general.img\r" "done"]
#   } elseif {$gaSet(customer)=="safaricom"} {
#     set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_etx_safari.img\r" "done"]
#   } 
  
  #set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_etx_general.img\r" "done"]
  #set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_etx_general_5.0.img\r" "done"]
  puts "\nDownload_BootParamImage gaSet(bootScript):$gaSet(bootScript)" ; update
  set ret [Send $com "tftpboot \$loadaddr boot-scripts/$gaSet(bootScript)\r" "done"] 
  #set ret [Send $com "tftpboot \$loadaddr boot-scripts/set_boot_param_etx_general_5.2.img\r" "done"]
  
  if [info exists gaSet(log.$gaSet(pair))] {
    AddToPairLog $gaSet(pair) "Boot Param Image: $gaSet(bootScript)"  
  }
  
  if {[string match "*done*" $buffer]} {
    set ret 0
  } else {
    set ret [ReadCom $com "done" 10]
  }
  
  if {$ret==0} {
    set gaSet(fail) "Source after set_boot_param_recovery Fail"
    #set ret [Send $com "source \$loadaddr\r" "resetting .."]  
    set ret [Send $com "source \$loadaddr\r" "PCPE>"]  
  }
  
#   if {$ret==0} {
#     set ret [Send $com "printenv NFS_VARIANT\r" "PCPE>"] 
#     if {$ret!=0} {
#       set gaSet(fail) "Read NFS_VARIANT Fail"
#     } else {
#       set res [regexp {IANT=(\w+)\s} $buffer ma var]
#       if {$res==0} {
#          set gaSet(fail) "Read NFS_VARIANT Fail"  
#          set ret -1
#       }
#       puts "NFS_VARIANT=<$var>"
#       puts "cust:<$gaSet(customer)>"
#       if {$gaSet(customer)!=$var} {
#         set gaSet(fail) "NFS_VARIANT is \'$var\'. Should be $gaSet(customer)" 
#         set ret -1  
#       }
#     } 
#   }
  
  if {$ret==0} {
    set gaSet(fail) "Source after set_boot_param_recovery Fail"
    # if {$gaSet(bootScript)=="set_boot_param_etx_general.img"} {
      # set ret [Send $com "setenv NFS_VARIANT general\r" "PCPE>"]
    # } elseif {$gaSet(bootScript)=="set_boot_param_etx_general_5.2.img"} {
      # set ret [Send $com "setenv NFS_VARIANT general-5.2\r" "PCPE>"]
    # }     
    set ret [Send $com "setenv NFS_VARIANT general\r" "PCPE>"] 
    
    set ret [Send $com "saveenv\r" "PCPE>"] 
    set ret [Send $com "reset\r" "resetting .."]  
  }       
  
  if {$ret==0} {
    set pcpe no
    set ret -1
    for {set i 1} {$i<=20} {incr i} {
      puts "\n $i" ; update
      set ret [Send $com c\rc\r "gggg" 1]; ## 10/07/2025 add c to stop in boot 6.4
      set buffer [join $buffer ""]
      if {[string match *E>* $buffer]} {
        if {[string match {*PCPE>*} $buffer]} {
          puts "\npcpe!!!\n";  update
          set pcpe yes
        }
        set ret 0
        break
      }
      
    }
    if {$ret!=0} {
      set gaSet(fail) "The UUT doesn't respond by E>"
    }  
  }
  
  puts "i:$i ret:$ret pcpe:$pcpe" ; update
  
  if {$ret==0 && $pcpe=="no"} {
    set gaSet(fail) "Boot after xx Fail"
    set ret [Send $com "x\rx\rx\r" "WTMI"]  
  }
#   if {$ret=="-1" && $pcpe=="no"} {     
#     set ret [Send $com "x\rx\r" "WTMI"] 
#   }
#   if {$ret==0 && $pcpe=="no"} {     
#     set ret [Send $com "x\rx\r" "WTMI"] 
#   }
  
  if {$ret==0 && $pcpe=="no"} {
    set gaSet(fail) "Boot after xx Fail"
    set ret [ReadCom $com "to stop autoboot" 120]
  }
  
  if {$ret==0} {
    set gaSet(fail) "No \'PCPE\' respond"
    set ret [Send $com "\r\r" "PCPE"]  
  }
  
  return $ret
  
}

# ***************************************************************************
# SetEthEnv
# ***************************************************************************
proc SetEthEnv {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret -1
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=10} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
  }
  
  Status "Set Environment"
  set gaSet(fail) "Set Eth Environment Fail"
  
  # 10:15 28/03/2023
  # switch -exact -- $gaSet(UutOpt) {
    # ETX1P        {set dtb armada-3720-Etx1p.dtb}
    # SF1P-2UTP    {set dtb armada-3720-SF1p.dtb}
    # SF1P-4UTP    {set dtb armada-3720-SF1p_superSet.dtb}
    # SF1P-4UTP-HL {set dtb armada-3720-SF1p_superSet_hl.dtb}
  # }
  # if {$gaSet(dutFam.sf)=="ETX-1P"} {
    # set dtb armada-3720-Etx1p.dtb
  # } elseif {$gaSet(dutFam.sf)=="SF-1P" || $gaSet(dutFam.sf)=="SF-1P_ICE"} {
    # if {$gaSet(dutFam.wanPorts) == "2U"} {
      # set dtb armada-3720-SF1p.dtb
    # } else {
      # if {[string match *.HL.*  $gaSet(DutInitName)]} {
        # set dtb armada-3720-SF1p_superSet_hl.dtb
      # } elseif {[string match *.R06*  $gaSet(DutInitName)]} {
        # set dtb armada-3720-SF1p_superSet_cp2.dtb
      # } else {
        # set dtb armada-3720-SF1p_superSet.dtb
      # }
      # set mainPcbId [string toupper $gaSet(mainPcbId)]
      # set res [regexp {REV([\d\.]+)[A-Z]} $mainPcbId  ma mainHW]
      # if {$res==0} {
        # set gaSet(fail) "Fail to retrive MAIN_CARD_HW_VERSION"
        # return -1
      # }
      # if {$mainHW >= 0.6} {
        # set dtb armada-3720-SF1p_superSet_cp2.dtb
      # }
    # }
  # }
  
  set dtb [DtbDefine]
  if {$dtb=="-1"} {return $dtb}
  
  ## 28/07/2021 09:33:09 set ret [Send $com "setenv fdt_name boot/armada-3720-Etx1p.dtb\r" "PCPE>"]
  set ret [Send $com "setenv fdt_name boot/$dtb\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth1addr  00:5${::hostVal}:82:11:22:1$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth2addr  00:5${::hostVal}:82:11:22:2$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth3addr  00:5${::hostVal}:82:11:22:3$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "setenv eth4addr  00:5${::hostVal}:82:11:22:4$gaSet(pair)\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "setenv NFS_VARIANT general\r" "PCPE>"]
  set ret [Send $com "setenv config_nfs \"setenv NFS_DIR /srv/nfs/pcpe-general\"\r" "PCPE>"]
  
  
  set ret [Send $com "saveenv\r" "PCPE>"]
  if {$ret!=0} {return $ret}
  
  
  return $ret
}

# ***************************************************************************
# RunBootNet
# ***************************************************************************
proc RunBootNet {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret -1
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  if {$ret!=0} {return $ret} 
  
  if {$gaSet(secBoot)==0} {}
  set ret [SetEnv]
  if {$ret!=0} {return $ret} 
  
  
  Send $com reset\r "stam" 3
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  # 15:40 20/07/2025 set ret [Send $com "setenv ethact neta@40000\r" "PCPE>"]
  
  puts "\n++++++++++++++++++++  printenv before run bootnet +++++++++++++++++++++++++++++++"
  #set ret [Send $com "printenv\r" "PCPE>"] 
  #set ret [Send $com "printenv NFS_DIR\r" "PCPE>"] 
  #set ret [Send $com "printenv NFS_VARIANT\r" "PCPE>"] 
  #set ret [Send $com "printenv config_nfs\r" "PCPE>"]   
  set ret [RLCom::Send $com "printenv\r" buffer "PCPE>"]
  puts "$buffer"
  puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  if $gaSet(enCrtPriLog) {
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
    if ![file exists c:/temp] {
      file mkdir c:/temp
      after 1000
    }
    set fi c:\\temp\\pri_[set gaSet(idBarcode)]_[set ti].txt
    set id [open $fi w]
    puts $id $buffer
    close $id
  }
  update
  catch {exec python.exe Etx1p_linuxSwitchSW.py showGeneralRootImagesApp $gaSet(linux_srvr_ip) general ver run} res
  puts "\n[MyTime] Linux_showGeneralRootImagesApp res:<$res>"; update
  AddToPairLog $gaSet(pair) "$res"
  
  if {$ret==0} {
    Status "Boot up to \'exiting hardware virtualization\'"
    set maxWait 2000; #1500; #900; #600
    set gaSet(fail) "RunBootNet Fail after $maxWait"
    Send $com "run bootnet\r" "PCPE>"
    if [regexp {Kernel panic - not syncing: Aiee, killing interrupt handler!} $buffer ma] {
      set gaSet(fail) "Can't mount FS: Kernel panic"
      return -1
    }
    if [regexp {Kernel panic} $buffer ma] {
      set gaSet(fail) "Can't mount FS: Kernel panic"
      return -1
    }
    set ret [ReadCom $com "exiting hardware virtualization" $maxWait]
    if {$ret!=0} {
      if {$ret=="KernelPanic"} {
        set gaSet(fail) "Can't mount FS"
        return -1
      }
      if {$ret=="KernelImage"} {
        set gaSet(fail) "Can't get Kernel Image"
        return -1
      }
      if {$gaSet(secBoot)==0} {
        for {set i 1} {$i<=20} {incr i} {
          set ret [Send $com \r\r "gggg" 1];
          set buffer [join $buffer ""]
          if {[string match *E>* $buffer]} {
            set ret 0
            break
          }
        }
        if {$ret!=0} {
          set gaSet(fail) "The UUT doesn't respond by E>"
        }  
     
        if {$ret==0} {
          set gaSet(fail) "Boot after xx Fail"
          set ret [Send $com "x\rx\r" "WTMI" 2] 
          if {$ret!=0} {
            set ret [Send $com "x\rx\r" "WTMI" 2]  
            if {$ret!=0} {
              set ret [Send $com "x\rx\r" "WTMI" 2]  
            }
          } 
        }
        if {$ret==0} {
          set ret [ReadCom $com "exiting hardware virtualization" $maxWait]
        }
      }
    }
  }
  
  if {$ret=="user"} {
    return 0
  }
  if {$ret=="KernelPanic"} {
    set gaSet(fail) "Can't mount FS"
    return -1
  }
  if {$ret=="KernelImage"} {
    set gaSet(fail) "Can't get Kernel Image"
    return -1
  }
  
  if {$ret==0 && $gaSet(dnldMode)==0} {}
  if {$ret==0} {
    set ret -1
    for {set i 1} {$i<=20} {incr i} {
      set ret [Send $com c\rc\r "$i gggg" 1]; ## 10/07/2025 add c to stop in boot 6.4
      set buffer [join $buffer ""]
      if !$gaSet(secBoot) {
        if {[string match *E>* $buffer]} {
          set ret 0
          break
        }
      }
      if {[string match *PCPE>* $buffer]} {
        set ret 0
        Send $com boot\r "stam" 10
        break
      }
    }
    if {$ret!=0} {
      set gaSet(fail) "The UUT doesn't respond by E>."
    }  
  
    if {$ret==0} {
      if !$gaSet(secBoot) {
        set gaSet(fail) "Boot after xx Fail."
        for {set i 1} {$i<=10} {incr 1} {
          set ret [Send $com "cx\rcx\r" "WTMI" 2] ; ## 10/07/2025 add c to stop in boot 6.4
          if {$ret==0} {break}
          if {[string match *PCPE>* $buffer]} {
            set ret 0
            break
          }
          after 2000
        } 
      }
    }
  } elseif {$ret==0 && $gaSet(dnldMode)==1} {
    ## do nothing
    set ret 0
  }
  
  if {$ret==0} {
    for {set us 1} {$us <= 1} {incr us} {
      puts ""
      Status "Boot up to \'user>\'"
      puts "[MyTime] UserLoop $us" ; update
      set maxWait 1800 ; #900; #600
      set gaSet(fail) "Can't reach \'user>\' after $maxWait sec"
      set ret [ReadCom $com "user>" $maxWait]
      if {$ret==0} {break}
      if {$ret=="-2"} {break}
      
      ## 15:43 30/04/2023
      if {$ret=="linux"} {
        set ret -1
        set gaSet(fail) "RAD OS open fail"
        break
      }  
      if {$ret=="FileNotFound"} {
        set ret -1
        set gaSet(fail) " File not found boot/Image or boot/armada.. "
        break
      }
      if {$ret=="linux" || $ret=="sys_reboot"} {}
      
      if {$ret=="sys_reboot"} {}
      
      puts "[MyTime] UserLoop $us ret:<$ret>" ; update
    }  
  }
  
  return $ret
}

proc __RunBootNet {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret -1
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  if {$ret==0} {
    set ret [Send $com "printenv NFS_VARIANT\r" "PCPE>"] 
    if {$ret!=0} {
      set gaSet(fail) "Read NFS_VARIANT Fail"
    } else {
      set res [regexp {IANT=(\w+)\s} $buffer ma var]
      if {$res==0} {
         set gaSet(fail) "Read NFS_VARIANT Fail"  
         set ret -1
      }
      puts "NFS_VARIANT=<$var>"
      puts "cust:<$gaSet(customer)>"
      if {$gaSet(customer)!=$var} {
        set gaSet(fail) "NFS_VARIANT is \'$var\'. Should be \'$gaSet(customer)\'" 
        set ret -1  
      }
    } 
  }
  if {$ret!=0} {return $ret} 
  
  set ret [SetEnv]
  if {$ret!=0} {return $ret} 
  
  if {$ret==0} {
    Status "Boot up to \'exiting hardware virtualization\'"
    set maxWait 1300
    set gaSet(fail) "RunBootNet Fail after $maxWait"
    Send $com "run bootnet\r" "PCPE>"
    set ret [ReadCom $com "exiting hardware virtualization" $maxWait]
    if {$ret!=0} {
      for {set i 1} {$i<=20} {incr i} {
        set ret [Send $com \r\r "gggg" 1]
        set buffer [join $buffer ""]
        if {[string match *E>* $buffer]} {
          set ret 0
          break
        }
      }
      if {$ret!=0} {
        set gaSet(fail) "The UUT doesn't respond by E>"
      }  
   
      if {$ret==0} {
        set gaSet(fail) "Boot after xx Fail"
        set ret [Send $com "x\rx\r" "WTMI" 2] 
        if {$ret!=0} {
          set ret [Send $com "x\rx\r" "WTMI" 2]  
          if {$ret!=0} {
            set ret [Send $com "x\rx\r" "WTMI" 2]  
          }
        } 
      }
      if {$ret==0} {
        set ret [ReadCom $com "exiting hardware virtualization" $maxWait]
      }
    }
  }
  
  if {$ret=="user"} {
    return 0
  }
  
  if {$ret==0 && $gaSet(dnldMode)==0} {
    set ret -1
    for {set i 1} {$i<=20} {incr i} {
      set ret [Send $com \r\r "gggg" 1]
      set buffer [join $buffer ""]
      if {[string match *E>* $buffer]} {
        set ret 0
        break
      }
    }
    if {$ret!=0} {
      set gaSet(fail) "The UUT doesn't respond by E>"
    }  
  
    if {$ret==0} {
      set gaSet(fail) "Boot after xx Fail"
      set ret [Send $com "x\rx\r" "WTMI" 2] 
      if {$ret!=0} {
        set ret [Send $com "x\rx\r" "WTMI" 2]  
        if {$ret!=0} {
          set ret [Send $com "x\rx\r" "WTMI" 2]  
        }
      } 
    }
  } elseif {$ret==0 && $gaSet(dnldMode)==1} {
    ## do nothing
    set ret 0
  }
  
  if {$ret==0} {
    Status "Boot up to \'user>\'"
    set maxWait 900
    set gaSet(fail) "Can't reach \'user>\' after $maxWait sec"
    set ret [ReadCom $com "user>" $maxWait]
    if {$ret=="linux"} {
      # RLEH::Open
      OpenPio 
      Power all off
      after 4000
      Power all on
      ClosePio
      set ret -1
      for {set i 1} {$i<=20} {incr i} {
        set ret [Send $com \r\r "gggg" 1]
        set buffer [join $buffer ""]
        if {[string match *E>* $buffer]} {
          set ret 0
          break
        }
      }
      if {$ret!=0} {
        set gaSet(fail) "The UUT doesn't respond by E>"
      }  
    
      if {$ret==0} {
        if {$gaSet(dnldMode)==1} {
          if {[string match *PCPE>* $buffer]} {
            set gaSet(fail) "No \'Starting kernel\' after boot"
            set ret [Send $com "boot\r" "Starting kernel"]  
          }
        } elseif {$gaSet(dnldMode)==0} {
          set gaSet(fail) "Boot after xx Fail"
          set ret [Send $com "x\rx\r" "WTMI" 2] 
          if {$ret!=0} {
            set ret [Send $com "x\rx\r" "WTMI" 2]  
            if {$ret!=0} {
              set ret [Send $com "x\rx\r" "WTMI" 2]  
            }
          } 
        }
      }
      
      if {$ret==0} {
        Status "Boot up to \'user>>\'"
        set maxWait 900
        set gaSet(fail) "Can't reach \'user>\' after $maxWait sec"
        set ret [ReadCom $com "user>" $maxWait]
      }
    }
  }
  
  return $ret
}

# ***************************************************************************
# Login
# ***************************************************************************
proc Login {} {
  global gaSet buffer
  switch -exact -- $gaSet(UutOpt) {
    ETX1P {set gaSet(prompt) "ETX-1p"}
    SF1P-2UTP - SF1P-4UTP - SF1P-4UTP-HL {set gaSet(prompt) "SF-1p"}
    default {set gaSet(prompt) "ETX_SF"}
  }
  set com $gaSet(comDut) 
  set ret [Send $com \r\r\r\r "user>" 1]
  # 15:29 26/03/2025if {[string match {*ETX-1p*} $buffer]} {}
  if {[string match "*$gaSet(prompt)*" $buffer]} {
    set ret [Send $com "exit all\r" $gaSet(prompt)]
    return 0
  }
  set ret [Send $com su\r "assword"]
  #if {$gaSet(sw_ver) >= "6.3.0.75"} {}
  if {[package vcompare $gaSet(sw_ver)  "6.3.0.75"] >= 0} {
    set gaSet(suPsw) "AT&Tpasswd10" ; #"1qaz2wsx3E-"
  } else {
    set gaSet(suPsw) "1234"
  }
    
  set ret [Send $com 1234\r "-1p#" 3]
  
  if {$ret=="-1"} {
    if {[string match {*password is not strong*} $buffer]} {
      set ret [Send $com $gaSet(suPsw)\r "again"]
      set ret [Send $com $gaSet(suPsw)\r "-1p#"]
      set ret [Send $com save\r "bytes copied in"]
      if {$ret==0 && [string match {*startup-config successfully*} $buffer]} {
        set ret 0
      } else {
        set gaSet(fail) "Save new password fail"
        set ret -1
      }
    } else {
    
      # 14:47 21/07/2025
      # if {[string match {*Login failed user*} $buffer]} {
        # set ret [Send $com su\r4\r "again" 3]
      # }
      # #set ret [Send $com su\r4\r "again" 3]
      # set ret [Send $com 4\r "again" 3]
      # set ret [Send $com 4\r "-1p#" 3]
      
      if {[string match {*Login failed user*} $buffer]} {
        set ret [Send $com su\r$gaSet(suPsw)\r "again" 3]
      }
      set ret [Send $com $gaSet(suPsw)\r "-1p#"]
    }
  }
  if {$ret==0} {return $ret}
  
  set stSec [clock seconds]
  set maxWait 450
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set runSec [expr {[clock seconds] - $stSec}]
    $gaSet(runTime) configure -text $runSec
    Status "Wait for Login ($runSec sec)"
    if {$runSec>$maxWait} {
      set gaSet(fail) "Can't login"
      return -1
    }
    Send $com \r "user>" 1
    if {[string match {*PCPE>*} $buffer]} {
      Send $com "boot\r" "stam" 2
    }
    if {[string match {* E *} $buffer]} {
      Send $com "x\rx\r" "stam" 2
    }
    # if {[string match {*user>*} $buffer]} {
      # set ret [Send $com "su\r" "password"]
      # if {$ret!=0} {
        # set gaSet(fail) "Can't reach \'password\'"
        # return $ret
      # }
      # set ret [Send $com "1234\r" $gaSet(prompt)]
      # if {$ret!=0} {
        # set gaSet(fail) "Can't reach \'$gaSet(prompt)\'"
      # }
      # return $ret
    # }
    if {[string match {*user>*} $buffer]} {
      set ret [Send $com su\r "assword"]
      set ret [Send $com 1234\r "-1p#" 3]
      if {$ret=="-1"} {
        if {[string match {*password is not strong*} $buffer]} {
          set ret [Send $com $gaSet(suPsw)\r "again"]
          set ret [Send $com $gaSet(suPsw)\r "-1p#"]
          set ret [Send $com save\r "bytes copied in"]
          if {$ret==0 && [string match {*startup-config successfully*} $buffer]} {
            set ret 0
          } else {
            set gaSet(fail) "Save new password fail"
            set ret -1
          }
        } else {
        
          # 15:35 21/07/2025
          # if {[string match {*Login failed user*} $buffer]} {
            # set ret [Send $com su\r4\r "again" 3]
          # }
          # set ret [Send $com 4\r "again" 3]
          # set ret [Send $com 4\r "-1p#" 3]
          
          if {[string match {*Login failed user*} $buffer]} {
            set ret [Send $com su\r$gaSet(suPsw)\r "again" 3]
          }
          set ret [Send $com $gaSet(suPsw)\r "-1p#"]
        }
      }      
      if {$ret==0} {break}
    }
    after 4000
  }
  
  
  if {$ret!=0} {
    set gaSet(fail) "Can't reach \'user>\'"
    return $ret
  }
  # set ret [Send $com "su\r" "password"]
  # if {$ret!=0} {
    # set gaSet(fail) "Can't reach \'password\'"
    # return $ret
  # }
  # set ret [Send $com "1234\r" "ETX-1p"]
  # if {$ret!=0} {
    # set gaSet(fail) "Can't reach \'ETX-1p\'"
    # return $ret
  # }
  
  return $ret
}
# ***************************************************************************
# ID
# ***************************************************************************
proc ID {} {
  global gaSet buffer
  set com $gaSet(comDut) 
  
  # Perform ReadBootParams at the end of ID
  # set ret [ReadBootParams]
  # if {$ret != 0} {return $ret}
  # set ret [Send $com "boot\r" "switch to partitions" ]
  # if {$ret!=0} {
    # set gaSet(fail) "No \'switch to partitions\' after \'boot\'"
    # return $ret
  # }
  
  set ret [Login]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "configure system\r" "system"]
  if {$ret!=0} {
    set gaSet(fail) "Can't reach \'system\'"
    return $ret
  }
  set ret [Send $com "show device-information\r" "ngine"]
  if {$ret!=0} {
    set gaSet(fail) "Can't reach \'device-information\'"
    return $ret
  }
  
  AddToPairLog $gaSet(pair) "$buffer"
  
  set res [regexp {Sw:\s+([\d\.a-z]+)\s} $buffer ma uut_var]
  if {$res==0} {
    set gaSet(fail) "Read Sw: Fail"
    return -1
  }
  set cust $gaSet(customer)
  set swid $gaSet($cust.SWver) 
  puts "cust:<$cust> swid:<$swid> uut_var:<$uut_var>"
  set res [regexp "_(\[\\d\\.\]+)\\.tar" $swid ma gui_ver]
  set res [regexp {_([\d\.a-z]+)_} $swid ma gui_ver]
  if {$res==0} {
    set gaSet(fail) "Retrive SW_ver from $swid fail"
    return -1
  }
  puts "cust:<$cust> swid:<$swid> uut_var:<$uut_var> gui_ver:<$gui_ver>"
  
  if [info exists gaSet(log.$gaSet(pair))] {
    AddToPairLog $gaSet(pair) "SW version: $uut_var"  
  }
  if {$gui_ver!=$uut_var} {
    set gaSet(fail) "\'Sw\' is \'$uut_var\'. Should be \'$gui_ver\'"
    return -1
  }
  
  set res  [regexp {Hw:\s+([\w\/\.]+)\s?} $buffer ma uutHw]
  if {$res==0} {
    set gaSet(fail) "Read Hw fail"
    return -1
  } 
  set uutHw [string trim $uutHw]
  puts "gaSet(mainHW):$gaSet(mainHW) uutHw:$uutHw"
  if {[package vcompare $uut_var "5.0.1.229.5"] == "0"} {
    set gaSetMainHw "1.0/a"
  } else {
    set gaSetMainHw $gaSet(mainHW)
  }
  if {$uutHw!=$gaSetMainHw} {
    set gaSet(fail) "The HW is \'$uutHw\'. Should be \'$gaSetMainHw\'" 
    return -1
  }
  
  set res  [regexp {Model\s:\s+([a-zA-Z\d\-\/\_\s]+)\s+[FL]} $buffer ma uutModel]
  if {$res==0} {
    set gaSet(fail) "Read Model fail"
    return -1
  } 
  set uutModel [string trim $uutModel]
  puts "uutModel:<$uutModel>"
  
  if {($gaSet(dutFam.wanPorts) == "4U2S" || $gaSet(dutFam.wanPorts) == "5U1S") && \
	      $gaSet(mainHW) < 0.6 &&  $uutModel != "SF-1P superset"} {
	  set gaSet(fail) "The Model is \'$uutModel\'. Should be \'SF-1P superset\'" 
    return -1
  } elseif {$gaSet(dutFam.wanPorts) == "2U" && $uutModel != "SF-1P"} {
	  set gaSet(fail) "The Model is \'$uutModel\'. Should be \'SF-1P\'" 
    return -1
  } elseif {$gaSet(dutFam.wanPorts) == "1SFP1UTP" && $uutModel != "ETX-1P"} {
	  set gaSet(fail) "The Model is \'$uutModel\'. Should be \'ETX-1P\'" 
    return -1
  } elseif {($gaSet(dutFam.wanPorts) == "4U2S" || $gaSet(dutFam.wanPorts) == "5U1S") && \
	      $gaSet(mainHW) >= 0.6 && $uutModel != "SF-1P superset CP_2"} {
      set gaSet(fail) "The Model is \'$uutModel\'. Should be \'SF-1P superset CP_2\'" 
    return -1
  }
  
  if {$gaSet(dutFam.lora)!=0} {
    set ret [CheckDockerPS]
    if {$ret != 0} {return $ret}
  }
  
  set ret [ReadBootParams]
  if {$ret != 0} {return $ret}
  
  return $ret
}    

proc 1 {} {
  global gaSet
  set gaSet(act) 1
  set com $gaSet(comDut)  
  catch {RLCom::Close $com}
  catch {RLEH::Close}
  set ret [UbootUpdate]
  puts "[MyTime] ret after UbootUpdate:<$ret>"
  
  catch {RLCom::Close $com}
  catch {RLEH::Close}
  
  if {$ret==0} {
    RLEH::Open
                
    set ret [RLCom::Open $com 115200 8 NONE 1]
    if {$ret!=0} {
      set gaSet(fail) "Open COM $com fail"
    }
  }
             
  if {$ret==0} {
    set ret [SetEnv]
    puts "[MyTime] ret after SetEnv:<$ret>"
  }
  
  if {$ret==0} {
    set ret [DownloadFlashImage]
    puts "[MyTime] ret after DownloadFlashImage:<$ret>"
  }
  
  if {$ret==0} {
    set ret [DownloadSet_boot_param_recovery]
    puts "[MyTime] ret after DownloadSet_boot_param_recovery:<$ret>"
  }
  
  if {$ret==0} {
    set ret [SetEthEnv]
    puts "[MyTime] ret after SetEthEnv:<$ret>"
  }
  
  if {$ret==0} {
    set ret [BootAfter]
    puts "[MyTime] ret after BootAfter:<$ret>"
  }
  
  catch {RLCom::Close $com}
  catch {RLEH::Close}
  
  return $ret
}
# ***************************************************************************
# Read_Linux
# ***************************************************************************
proc Read_Linux {} {
  global gaSet res
  if ![info exists gaSet(customer)] {
    set gaSet(customer) SF1P
  }
  if ![info exists gaSet(UutOpt)] {
    set gaSet(UutOpt) SF1P
  }
  
  set customer $gaSet(customer)
  if [string match *ETX* $gaSet(UutOpt)] {
    set uut ETX1P
  } elseif [string match *SF1P* $gaSet(UutOpt)] {
    set uut SF1P
  } 
  puts "Read_Linux customer:<$customer> uut:<$uut>"
  
  ## 11:01 27/04/2023 set uut SF1P
  set tt [expr {[lindex [time {catch {exec python.exe Etx1p_linuxSwitchSW.py list_sw $gaSet(linux_srvr_ip)  customer ver $uut} res}] 0] /1000.0}]
  puts "Read_Linux <$tt> <$res>"

  foreach {ma app} [regexp -inline -all {([\w\.\_\-\d]+.gz)\\n} $res] {
    lappend apps $app
  }
  foreach {ma gen} [regexp -inline -all {(pcpe-ge[\w\.\_\-\d]+)\\n} $res] {
    lappend gens $gen
  }
  foreach {ma fla} [regexp -inline -all {(flash-image-[\w\.\_\-\d]+\.bin)} $res] {
    lappend flas $fla
  }
  foreach {ma bootScript} [regexp -inline -all {(set_boot_param_etx[\w\.\_\-\d]+\.img)} $res] {
    lappend bootScripts $bootScript
  }
  foreach {ma rungen} [regexp -inline -all {\/(general[\w\.\_\-\d]+)\\n} $res] {
    lappend rungens $rungen
  }
  lappend allLists [lsort -unique $apps] [lsort -unique $gens] [lsort -unique $flas] [lsort -unique $bootScripts] [lsort -unique $rungens]
  
  puts "Read_Linux allLists:<$allLists>"
  return $allLists
}
proc __Read_Linux {} {
  global gaSet res
  set customer $gaSet(customer)
  if [string match *ETX* $gaSet(UutOpt)] {
    set uut ETX1P
  } elseif [string match *SF1P* $gaSet(UutOpt)] {
    set uut SF1P
  } 
  puts "Read_Linux customer:<$customer> uut:<$uut>"
  catch {exec python.exe Etx1p_linuxSwitchSW.py list_sw $gaSet(linux_srvr_ip) $customer stam $uut} res
  puts "Read_Linux <$res>"
  
  foreach {ma app} [regexp -inline -all {m([\w\.\_\-\d]+.gz)} $res] {
    lappend apps $app
  }
  foreach {ma gen} [regexp -inline -all {m(pcpe-ge[\w\.\_\-\d]+)} $res] {
    lappend gens $gen
  }
  foreach {ma fla} [regexp -inline -all {(flash-image-[\w\.\_\-\d]+\.bin)} $res] {
    lappend flas $fla
  }
  foreach {ma bootScript} [regexp -inline -all {(set_boot_param_etx[\w\.\_\-\d]+\.img)} $res] {
    lappend bootScripts $bootScript
  }
  foreach {ma rungen} [regexp -inline -all {\\r\\n(general[\w\.\_\-\d]+)\\r} $res] {
    lappend rungens $rungen
  }
  lappend allLists [lsort -unique $apps] [lsort -unique $gens] [lsort -unique $flas] [lsort -unique $bootScripts] [lsort -unique $rungens]
  
  puts "Read_Linux allLists:<$allLists>"
  return $allLists
}
# ***************************************************************************
# Linux_SW
# ***************************************************************************
proc Linux_SW {} {
  global gaSet buffer
  set customer $gaSet(customer)
  set appl $gaSet($customer.SWver)
  if [string match *ETX* $gaSet(UutOpt)] {
    set uut ETX1P
  } elseif [string match *SF1P* $gaSet(UutOpt)] {
    set uut SF1P
  } 
  
  Status "Switching to \'$appl\'"
  set ret [Linux_SW_perf $customer $appl $uut]
  if {$ret!=0} {
    catch {exec python.exe Etx1p_linuxSwitchSW.py del_sw $gaSet(linux_srvr_ip) $customer $appl $uut} res
    puts "del_sw res:<$res>"
    after 1000
    set ret [Linux_SW_perf $customer $appl $uut]
  }
  # OpenPio 
  # Power all off
  # after 4000
  # Power all on
  # ClosePio
  return $ret
}
# ***************************************************************************
# Eeprom
# ***************************************************************************
proc Eeprom {} {
  global gaSet buffer
  set com $gaSet(comDut)  
  set customer $gaSet(customer)
  set appl $gaSet($customer.SWver)
  
  CreateHostValGuiId
  
  # 10:15 28/03/2023
  # if {$gaSet(UutOpt) eq "ETX1P"} {
    # set eep_fi ETX-1PACEX1SFP1UTP4UTP.txt
  # } elseif {$gaSet(UutOpt) eq "SF1P-2UTP"} {
    # set eep_fi SF-1PE1ACEX2U2RS.txt
  # } elseif {$gaSet(UutOpt) eq "SF1P-4UTP"} {
    # set eep_fi SF-1PE1DC4U2S2RS.txt
    # #set eep_fi SF-1PE1DC4U2S2RS_BACKUP.txt 18:18:18:18:18:19
  # } elseif {$gaSet(UutOpt) eq "SF1P-4UTP-HL"} {
    # set eep_fi SF-1PE1DC2R4U2S2RSL1GLR2HL.txt
  # }
  
  set ret [BuildEepromString newUut]
  puts "\nRet of BuildEepromString:<$ret>"
  if {$ret!=0} {
    return $ret
  }
  Linux_Eeprom
  set eep_fi $::GuiId.txt
  
  
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  
  if {$ret==0} {
    set gaSet(fail) "Programming eEprom fail"
    if {[package vcompare $gaSet(dbrBootSwVer) "6.4.0"] >= 0} {
      ## uboot 6.4.0 and above
      # Send $com "iic\r" "Enter filename" 3 
      set ret [Send $com "tftpboot  $eep_fi\r" "PCPE>" 50] 
    } else {
      set ret [Send $com "iic e 52\r" "PCPE>" 20]  
      if {$ret!=0} {return $ret} 
      set ret [Send $com "iic c $eep_fi\r" "PCPE>" 20]  
    }
    if {$ret!=0} {return $ret}
  
    if {[string match *done* $buffer]==0 && [string match *write* $buffer]==0} {
      set ret [Send $com "\r" "PCPE>" 20]  
      if {$ret!=0} {return $ret} 
  
      if {[string match *done* $buffer]==0} {
        set gaSet(fail) "Programming eEprom fail. No done"
        return -1
      }
    }
    
    set ret [Send $com "reset\r" "resetting" 20]  
    set gaSet(fail) "Resetting fail"
    if {$ret!=0} {return $ret} 
    set gaSet(fail) "No \'PCPE\' respond"
    for {set i 1} {$i<=20} {incr i} {
      set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
      if {$ret==0} {break}
      if [string match {* E *} $buffer] {
        Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
      }
    }
  }
  
  return $ret
}

# ***************************************************************************
# ReadBootParams
# ***************************************************************************
proc ReadBootParams {} {
  global gaSet buffer
  puts "\n[MyTime] ReadBootParams"
  set com $gaSet(comDut)
  #RLEH::Open
  OpenPio 
  Power all off
  after 4000
  Power all on
  ClosePio
  #RLEH::Close
  
  set gaSet(loginBuffer) ""
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    append gaSet(loginBuffer) $buffer
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
      append gaSet(loginBuffer) $buffer
    }
  }
  
  # set ret [Login2Boot]
  # if {$ret!=0} {return $ret}
  
  set dbrBootSwVer $gaSet(dbrBootSwVer)
  if {[string index $dbrBootSwVer 0]=="B"} {
    set dbrBootSwVer [string range $dbrBootSwVer 1 end]
  }
  puts "gaSet(dbrBootSwVer):<$gaSet(dbrBootSwVer)> dbrBootSwVer:<$dbrBootSwVer>"
  # set res [string match {*U-Boot 2017.03.VER1.0.2-armada-17.10.2*} $gaSet(loginBuffer)]
  set res [string match *VER$dbrBootSwVer* $gaSet(loginBuffer)]
  if {$res==0} {
    set res [string match *$dbrBootSwVer* $gaSet(loginBuffer)]
  }
  
  if {$res == 0} {
    OpenPio 
    Power all off
    after 4000
    Power all on
    ClosePio
    
    set gaSet(loginBuffer) ""
    set gaSet(fail) "No \'PCPE\' respond"
    for {set i 1} {$i<=20} {incr i} {
      set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
      append gaSet(loginBuffer) $buffer
      if {$ret==0} {break}
      if [string match {* E *} $buffer] {
        Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
        append gaSet(loginBuffer) $buffer
      }
    }
  
    # set ret [Login2Boot]
    # if {$ret!=0} {return $ret}
  
    # set res [string match {*U-Boot 2017.03.VER1.0.2-armada-17.10.2*} $gaSet(loginBuffer)]
    set res [string match *VER$dbrBootSwVer* $gaSet(loginBuffer)]
    if {$res==0} {
      set res [string match *$dbrBootSwVer* $gaSet(loginBuffer)]
    }
    if {$res == 0} {
      # set gaSet(fail) "No \'U-Boot 2017.03-armada-17.10.2\' in Boot"
      set gaSet(fail) "No \'$gaSet(dbrBootSwVer)\' in Boot"
      return -1
    }
  }
  
  ## don't do it 09:28 10/11/2024
  # set ma ""; set val ""
  # ## armada-17.10.2 6.3.6 /
  # regexp {armada[\-\d\.]+\s([\d\.]+)\s/} $gaSet(loginBuffer) ma val
  # puts "ma:<$ma> val:<$val>"
  # AddToPairLog $gaSet(pair) "Boot: $val"
  # if {$val != $dbrBootSwVer} {
    # set gaSet(fail) "No \'$gaSet(dbrBootSwVer)\' in Boot"
    # return -1
  # }
  
  # set res [string match {*Nov 22 2021*} $gaSet(loginBuffer)]
  # if {$res == 0} {
    # set gaSet(fail) "No \'Nov 22 2021\' in Boot"
    # return -1
  # }
  
  set res [string match "*DRAM:  $gaSet(dutFam.mem) GiB*" $gaSet(loginBuffer)]
  if {$res == 0} {
    set res [string match "*DRAM: $gaSet(dutFam.mem) GiB*" $gaSet(loginBuffer)]
    if {$res == 0} {
      set gaSet(fail) "No \'DRAM: $gaSet(dutFam.mem) GiB\' in Boot"
      return -1
    }
  }
  
  set ret [Send $com "printenv NFS_VARIANT\r" PCPE]
  if {$ret!=0} {return $ret}
  set res [string match {*NFS_VARIANT=general*} $buffer]
  if {$res == 0} {
    set gaSet(fail) "No \'NFS_VARIANT=general\' in Boot"
    return -1
  }
  
  if {[string match *.HL.* $gaSet(DutInitName)]} {
    set ret [Send $com "printenv fdt_name\r" PCPE]
    if {$ret!=0} {return $ret}
    set res [string match {*armada-3720-SF1p_superSet_hl.dtb*} $buffer]
    if {$res == 0} {
      set gaSet(fail) "No \'fdt_name=armada-3720-SF1p_superSet_hl.dtb\' in Boot"
      return -1
    }
  }
  
  return 0
} 

# ***************************************************************************
# MicroSD
# ***************************************************************************
proc MicroSD {} {
  set ::sendSlow 1
  global gaSet buffer
  if {[string match *.HL.*  $gaSet(DutInitName)] && $gaSet(mainHW)<"0.6"} {
    AddToPairLog $gaSet(pair) "HL: mainHW:$gaSet(mainHW), no MicroSD Test"
    return 0
  }  
  
  set com $gaSet(comDut)
  Send $com "\r" stam 0.25
  Send $com "\r" stam 0.25
  if {[string match *PCPE* $buffer]} {
    set ret 0
  } else {
    set ret [PowerResetAndLogin2Boot]
  }
  if {$ret==0} {
    set ret [MicroSDPerform]
  }
  return $ret
}
# ***************************************************************************
# PowerResetAndLogin2Boot
# ***************************************************************************
proc PowerResetAndLogin2Boot {} {
  puts "[MyTime] PowerResetAndLogin2Boot"
  global gaSet buffer
  set com $gaSet(comDut)
  Send $com "\r" stam 0.25
  Send $com "\r" stam 0.25
  if {[string match {*PCPE*} $buffer]} {
    return 0   
  }
  
  #RLEH::Open
  OpenPio 
  Power all off
  after 4000
  Power all on
  ClosePio
  #RLEH::Close   
  
  set gaSet(loginBuffer) ""
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    append gaSet(loginBuffer) $buffer
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
      append gaSet(loginBuffer) $buffer
    }
  }
  
  # set ret [Login2Boot]
  return $ret 
}
# ***************************************************************************
# Login2Boot
# ***************************************************************************
proc Login2Boot {} {
  global gaSet buffer
  set ret -1
  set gaSet(loginBuffer) ""
  set statusTxt  [$gaSet(sstatus) cget -text]
  Status "Login into Boot"
  set com $gaSet(comDut)
  
  Send $com "\r" stam 0.25
  append gaSet(loginBuffer) "$buffer"
  Send $com "\r" stam 0.25
  append gaSet(loginBuffer) "$buffer"
  
  if {[string match *#* $buffer]} {
    set ret 0
  }
  
  set gaSet(fail) "Login to Boot level fail" 
  if {$ret!=0} {
    for {set i 1} {$i<=300} {incr i} {
      $gaSet(runTime) configure -text "$i" ; update
      if {$gaSet(act)==0} {set ret -2; break}
      RLCom::Read $com buffer
      append gaSet(loginBuffer) "$buffer"
      puts "Login2Boot i:$i [MyTime] buffer:<$buffer>" ; update
      #puts "Login2Uboot i:$i [MyTime] gaSet(loginBuffer):<$gaSet(loginBuffer)>" ; update
      if {[string match {*to stop autoboot:*} $gaSet(loginBuffer)]} {
        set ret [Send $com \r\r "PCPE"]
        if {$ret==0} {break}
      }
      
      if {[string match {*PCPE*} $gaSet(loginBuffer)]} {
        set ret 0
        break
      }
      
      after 1000
    }
  }  
  return $ret
}
# ***************************************************************************
# MicroSDPerform
# ***************************************************************************
proc MicroSDPerform {} {
  global gaSet buffer
  puts "\n[MyTime] MicroSDPerform"; update
  set com $gaSet(comDut)
  
  Send $com "mmc dev 0:1\r" "PCPE" 1
  after 500
  set ret [Send $com "mmc dev 0:1\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'mmc dev 0:1\' fail"
    return -1
  }
  if ![string match {*switch to partitions \#0, OK*} $buffer] { 
    after 500
    set ret [Send $com "mmc dev 0:1\r" "PCPE"]
    if ![string match {*switch to partitions \#0, OK*} $buffer] { 
      set gaSet(fail) "\'dev 0:1 switch to partitions 0\' does not exist"
      return -1
    }
  }
  if ![string match {*mmc0 is current device*} $buffer] {
    after 500
    set ret [Send $com "mmc dev 0:1\r" "PCPE"]
    if ![string match {*mmc0 is current device*} $buffer] {
      set gaSet(fail) "\'mmc0 is current device\' does not exist"
      return -1
    }
  }
  
  Send $com "mmc info\r" "PCPE" 1
  after 500
  set ret [Send $com "mmc info\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'mmc info\' fail"
    return -1
  }
  # 14:15 15/05/2023
  # if ![string match {*Bus Width: 4-bit*} $buffer] {
    # set gaSet(fail) "\'Bus Width: 4-bit\' does not exist"
    # return -1
  # }
  if ![string match {*Capacity: 29.7 GiB*} $buffer] {
    set gaSet(fail) "\'Capacity: 29.7 GiB\' does not exist"
    return -1
  }
  
  return $ret
}  
# ***************************************************************************
# SOC_Flash_Memory
# ***************************************************************************
proc SOC_Flash_Memory {} {
  global gaSet buffer
  set ::sendSlow 1
  set com $gaSet(comDut)
  Send $com "\r" stam 0.25
  Send $com "\r" stam 0.25
  if {[string match *PCPE* $buffer]} {
    set ret 0
  } else {
    set ret [PowerResetAndLogin2Boot]
  }
  if {$ret==0} {
    set ret [SocFlashMemPerform]
  }
  return $ret
}
# ***************************************************************************
# SocFlashMemPerform
# ***************************************************************************
proc SocFlashMemPerform {} {
  global gaSet buffer
  puts "\n[MyTime] SocFlashMemPerform"; update
  set com $gaSet(comDut)
  
  set ret [Send $com "mmc dev 1:0\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'mmc dev 1:0\' fail"
    return -1
  }
  if ![string match {*switch to partitions \#0, OK*} $buffer] {
    set gaSet(fail) "\'switch to partitions 0\' does not exist"
    return -1
  }
  if ![string match {*mmc1(part 0) is current device*} $buffer] {
    set gaSet(fail) "\'mmc1(part 0) is current device\' does not exist"
    return -1
  }
  
  Send $com "mmc info\r" "PCPE" 1
  after 500
  set ret [Send $com "mmc info\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'mmc info\' fail"
    return -1
  }
  if ![string match {*HC WP Group Size: 8 MiB*} $buffer] {
    set gaSet(fail) "\'HC WP Group Size: 8 MiB\' does not exist"
    return -1
  }
  if ![string match {*Bus Width: 8-bit*} $buffer] {
    set gaSet(fail) "\'Bus Width: 8-bit\' does not exist"
    return -1
  }
  
  set ret [Send $com "mmc list\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'mmc list\' fail"
    return -1
  }
  if ![string match {*sdhci\@d0000: 0*} $buffer] {
    set gaSet(fail) "\'sdhci@d0000: 0\' does not exist"
    return -1
  }
  if ![string match {*sdhci@d8000: 1 (eMMC)*} $buffer] {
    set gaSet(fail) "\'sdhci@d8000: 1 (eMMD)\' does not exist"
    return -1
  }
  
  return $ret
}  

# ***************************************************************************
# SOC_i2C
# ***************************************************************************
proc SOC_i2C {} {
  global gaSet buffer
  set ::sendSlow 1
  set com $gaSet(comDut)
#   Send $com "\r" stam 0.25
#   Send $com "\r" stam 0.25
#   if {[string match *PCPE* $buffer]} {
#     set ret 0
#   } else {
#     set ret [PowerResetAndLogin2Boot]
#   }
  set ret [PowerResetAndLogin2Boot]
  if {$ret==0} {
    set ret [SocI2cPerform]
  }
  return $ret
}
# ***************************************************************************
# SocI2cPerform
# ***************************************************************************
proc SocI2cPerform {} {
  global gaSet buffer
  puts "\n[MyTime] SocI2cPerform"; update
  set com $gaSet(comDut)
  
  set ret [Send $com "i2c bus\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'i2c bus\' fail"
    return -1
  }
  if ![string match {*Bus 0: i2c@11000*} $buffer] {
    set gaSet(fail) "\'Bus 0: i2c@11000\' does not exist"
    return -1
  }
  
  set ret [Send $com "i2c dev 0\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'i2c dev 0\' fail"
    return -1
  }
  
  set ret [Send $com "i2c probe\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'i2c probe\' fail"
    return -1
  }
  if ![string match {*20 21*} $buffer] {
    set gaSet(fail) "\'20 21\' does not exist"
    return -1
  }
  if ![string match {*7E 7F*} $buffer] {
    set gaSet(fail) "\'7E 7F\' does not exist"
    return -1
  }
  
  set ret [Send $com "i2c mw 0x52 0.2 0xaa 0x1\r" "PCPE"]
  set ret [Send $com "i2c md 0x52 0.2 0x20\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'i2c md\' fail"
    return -1
  }
  if ![string match {*0000: aa*} $buffer] {
    set gaSet(fail) "\'0000: aa\' does not exist"
    return -1
  }
  
  set ret [Send $com "i2c mw 0x52 0.2 0xbb 0x1\r" "PCPE"]
  set ret [Send $com "i2c md 0x52 0.2 0x20\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "\'i2c md\' fail"
    return -1
  }
  if ![string match {*0000: bb*} $buffer] {
    set gaSet(fail) "\'0000: bb\' does not exist"
    return -1
  }
  
#   set ret [Send $com "i2c md 0x50 0.1 0x40\r" "PCPE"]
#   if {$ret!=0} {
#     set gaSet(fail) "\'i2c md\' fail"
#     return -1
#   }
#   if ![string match {*SFP-9G*} $buffer] {
#     set gaSet(fail) "\'SFP-9G\' does not exist"
#     return -1
#   }
  
  return $ret
} 
  
# ***************************************************************************
# BootLeds
# ***************************************************************************
proc FrontPanelLeds {} {
  set ::sendSlow 0
  set ret [BootLedsPerf]
}
# ***************************************************************************
# BootLedsPerf
# ***************************************************************************
proc BootLedsPerf {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  # if {$gaSet(dutFam.sf)=="ETX-1P_SFC"} {
    # Power all off
    # Status "Power OFF"
    # after 4000
    # Power all on
    # Status "Power ON"
    # after 1000
  # }
  
  set ret [PowerResetAndLogin2Boot]
  if {$ret!=0} {return $ret}
  
  if {$gaSet(dutFam.box)=="ETX-1P"} {
    set ret 0
    ## no SD in ETX
  } else {
    OpenPio 
    Power all off
    ClosePio
    RLSound::Play information
    set txt "Remove the SD-card"
    set res [DialogBox -title "Boot Leds Test" -type "Ok Cancel" -message $txt  -icon images/info]
    if {$res=="Cancel"} {
      set gaSet(fail) "User Stop" 
      return -2
    }
    OpenPio 
    Power all on
    ClosePio
    set ret [PowerResetAndLogin2Boot]
    if {$ret!=0} {return $ret}
    for {set try 1} {$try <= 3} {incr try} {
      RLSound::Play information
      set txt "Remove the SD-card"
      if {$try==1} {
        ## don't ask to remove the sd on the first cycle
        set res Ok
      } else {
        set res [DialogBox -title "Boot Leds Test" -type "Ok Cancel" -message $txt  -icon images/info]
      }
      if {$res=="Cancel"} {
        set gaSet(fail) "\'LTE AUX\' Test fail" 
        return -1
      }
      
      set ret [Send $com "mmc dev 0:1\r" "PCPE"]
      if {$ret!=0} {
        set gaSet(fail) "\'mmc dev 0:1\' fail"
        return -1
      }
   
      if ![string match {*ot found*} $buffer] {   
        set gaSet(fail) "SD card is not pulled out"
        set ret -1
      } else {
        set ret 0
        break
      }
    }
  }
  if {$ret!=0} {return $ret}
  
  if {$gaSet(dutFam.box)=="ETX-1P"} {
    set runTxt ""
    set verb "is"
  } else {
    set runTxt "and RUN "
    set verb "are"
  }
  RLSound::Play information
  set res [DialogBox -title "ALM $runTxt Led Test" -type "Yes No" \
      -message "Verify the ALM $runTxt Led/s $verb OFF" -icon images/info]
  if {$res=="No"} {
    set gaSet(fail) "ALM $runTxt Led/s $verb not OFF" 
    return -1
  }
  
  set ret [Send $com "gpio toogle GPIO112\r" "PCPE"]
  if {$ret!=0} {return $ret}
  RLSound::Play information
  set res [DialogBox -title "PWR $runTxt Green Led Test" -type "Yes No" \
      -message "Verify the PWR $runTxt Green Led/s $verb ON" -icon images/info]
  if {$res=="No"} {
    set gaSet(fail) "PWR $runTxt Green Led/s $$verb not ON" 
    return -1
  }
  Send $com "gpio toogle GPIO112\r" "PCPE"
  
  set ret [Send $com "gpio toogle GPIO113\r" "PCPE"]
  if {$ret!=0} {return $ret}
  RLSound::Play information
  set res [DialogBox -title "ALM Red Led Test" -type "Yes No" \
      -message "Verify the ALM Red Led is ON" -icon images/info]
  if {$res=="No"} {
    set gaSet(fail) "ALM Red Led is not ON" 
    return -1
  }
  Send $com "gpio toogle GPIO113\r" "PCPE"
  
  catch {Send $com "mii write 1 1 0x80fe\r" "PCPE"}
  catch {Send $com "mii write 1 0 0x9656\r" "PCPE"}
  RLSound::Play information
  set res [DialogBox -title "AUX Green Led Test" -type "Yes No" \
      -message "Verify the AUX Green Led is ON, if exists" -icon images/info]
  if {$res=="No"} {
    set gaSet(fail) "AUX Green Led is not ON" 
    return -1
  }
  catch {Send $com "mii write 1 1 0x80ee\r" "PCPE"}
  catch {Send $com "mii write 1 0 0x9656\r" "PCPE"}
  
  # all ON
  catch {Send $com "mii write 2 1 0x80ff\r" "PCPE"}
  catch {Send $com "mii write 2 0 0x96b6\r" "PCPE"}  
  if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC" || $gaSet(dutFam.sf)=="ETX-1P_A"} {
    # WAN2 led
    catch {Send $com "mii write 2 0 0x9676\r" "PCPE"}  
  } 
  foreach {reg1} {0x80ff 0x90ff} {
    foreach reg2 {0x9636 0x9656 0x9676 0x9696} {
      catch {Send $com "mii write 1 1 $reg1\r" "PCPE"}
      catch {Send $com "mii write 1 0 $reg2\r" "PCPE"}
    }
  }
  
  set txt "Verify Green Leds are ON on the following ports:\n\
  ETH 1-6, S1 TX and RX, S2 TX and RX, SIM 1 and 2\n\n\
  Verify Red Led is ON on the AUX port\n\n\
  Do the Leds work well?"
  RLSound::Play information
  set res [DialogBox -title "Boot Leds Test" -type "Yes Stop" -message "$txt" -icon images/info]
  if {$res=="Stop"} {
    set gaSet(fail) "Boot Leds Test fail" 
    return -1
  }
  
  # all OFF
  catch {Send $com "mii write 2 1 0x80ee\r" "PCPE"}
  catch {Send $com "mii write 2 0 0x96b6\r" "PCPE"}
  if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC" || $gaSet(dutFam.sf)=="ETX-1P_A"} {
    # WAN2 led
    catch {Send $com "mii write 2 0 0x9676\r" "PCPE"}  
  }
  foreach {reg1} {0x80ee 0x90ee} {
    foreach reg2 {0x9636 0x9656 0x9676 0x9696} {
      catch {Send $com "mii write 1 1 $reg1\r" "PCPE"}
      catch {Send $com "mii write 1 0 $reg2\r" "PCPE"}
    }
  }

  set txt "Verify all the leds, except PWR, are OFF"
  RLSound::Play information
  set res [DialogBox -title "Boot Leds Test" -type "Yes Stop" -message "$txt" -icon images/info]
  if {$res=="Stop"} {
    set gaSet(fail) "Boot Leds Test fail" 
    return -1
  }
  return 0
  
}

# ***************************************************************************
# EnvDefSaveEnv
# ***************************************************************************
proc EnvDefSaveEnv {} {
  puts "\n[MyTime] EnvDefSaveEnv"
  global gaSet buffer
  set com $gaSet(comDut)
  set ret [Send $com "env default -f -a\r" "PCPE"]
  if {$ret!=0} {
    set gaSet(fail) "env default -f -a fail"
    return $ret
  }
  set ret [Send $com "saveenv\r" "PCPE"]
  if {$ret==0 && [string match {*w25q32dw with page size 256 Bytes*} $buffer] && \
      [string match {*4 KiB, total 4 MiB*} $buffer] && \
      [string match {*Writing to SPI flash...done*} $buffer]} {
    return 0   
  } else {
    set gaSet(fail) "saveenv fail"
    return -1
  }
}
# ***************************************************************************
# SecureBoot
# ***************************************************************************
proc SecureBoot {} {
  puts "\n[MyTime] SecureBoot"
  global gaSet buffer
  set ttyDev $gaSet(ttyDev) ; #"ttyUSB1"
  set bootVer $gaSet(dbrBootSwVer) ; #"6.3.5"
  set boot_img "fuse_${gaSet(dbrBootSwVer)}.bin"
  set com  $gaSet(comDut)
  # OpenPio 
  # Power all off
  # ClosePio
  GuiPower 1 0
  
  # Status "Reaching E"
  # set ret -1
  # for {set i 1} {$i<=10} {incr i} {
    # set ret [Send $com \r\r "gggg" 1]
    # set buffer [join $buffer ""]
    # if {[string match *E>* $buffer]} {
      # set ret 0
      # break
    # }
  # }
  # if {$ret!=0} {
    # set gaSet(fail) "The UUT doesn't respond by E>"
    # return $ret
  # }
  
  
  
  RLSound::Play information
  set res [DialogBox -title "SecureBoot" -type "Ok Cancel" \
      -message "Connect $ttyDev cable to CONTROL port" -icon images/info]
  if {$res=="Cancel"} {
    set gaSet(fail) "User stop" 
    return -2
  }
  
  set ret [catch {exec python.exe Etx1p_secureBoot.py goto_sec_boot $gaSet(linux_srvr_ip) $gaSet(dbrBootSwVer)  $gaSet(ttyDev)  NA} res]
  puts "res after goto_sec_boot: <$res>\n"
  if {$ret==1} {    
    set gaSet(fail) "Can't reach secureBoot $bootVer"
    return -1
  }
  if ![string match "*fuse_$bootVer.bin*" $res] {
    set gaSet(fail) "No fuse_$bootVer.bin"
    return -1
  }
  
  # after 1000 {set x 1}
  # OpenPio 
  # Power all on
    # # Power all on
  # ClosePio
   GuiPower 1 1
  
  set ret [catch {exec python.exe Etx1p_secureBoot.py get_e_py $gaSet(linux_srvr_ip) $gaSet(dbrBootSwVer) $gaSet(ttyDev) NA} res]; puts $res
  if ![regexp {mode:(\w+)} $res m val] {
    set gaSet(fail) "Can't get mode wtp or PCPE"
    return -1
  }
  set mode $val
  
  puts "\nmode:<$mode>\n"
  if {$mode=="wtp"} {
  
    set ret [catch {exec python.exe Etx1p_secureBoot.py fuse_new $gaSet(linux_srvr_ip) $gaSet(dbrBootSwVer) $gaSet(ttyDev) NA} res]
    puts "res after fuse_new: <$res>\n"
  
    if ![string match "*Deployment successful*" $res] {
      set gaSet(fail) "Can't get Deployment successful"
      return -1
    }  
    set ret [Wait "Wait for fusing" 40]
    # OpenPio 
    # Power all off
    GuiPower 1 0
    
    RLSound::Play information
    set res [DialogBox -title "SecureBoot" -type "Ok Cancel" \
        -message "Set Jumpers in Normal Mode\n\
        Connect Windows COM cable to CONTROL port" -icon images/info]
    if {$res=="Cancel"} {
      set gaSet(fail) "User stop" 
      return -2
    }
    
    # Power all on
    # ClosePio
    GuiPower 1 1
    #RLEH::Close
    
    set gaSet(fail) "No \'PCPE\' respond"
    for {set i 1} {$i<=20} {incr i} {
      set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
      if {$ret==0} {break}
      if [string match {* E *} $buffer] {
        Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
      }
    }
    
  } elseif {$mode=="PCPE"} {  
    #GuiPower 1 0
    #RLSound::Play information
    #set res [DialogBox -title "SecureBoot" -type "Ok Cancel" \
        -message "Set Jumpers in Normal Mode" -icon images/info]
    #after 1000    
    #if {$res=="Cancel"} {
    #  set gaSet(fail) "User stop" 
    #  return -2
    #}
    for {set i 1} {$i<=10} {incr i} {
      GuiPower 1 0
      after 2000
      catch {exec python.exe Etx1p_secureBoot.py fuse_update $gaSet(linux_srvr_ip) $gaSet(dbrBootSwVer) $gaSet(ttyDev) "fuse_${gaSet(dbrBootSwVer)}.bin" &} res
      after 500 {
        GuiPower 1 1
      }
      update
      set ret -1
      #catch {exec python.exe Etx1p_secureBoot.py fuse_update $gaSet(linux_srvr_ip) $bootVer $ttyDev $boot_img &} res
      puts "res after fuse_update: <$res>\n"
      if [string match "*FLASHED SUCCESSFULLY*" $res] {
        set ret 0
        break
      } else {
        set gaSet(fail) "SecureBoot Update fail"
      }
    }  
  }
  
  if {$ret!=0} {return $ret}
  
    
  if 1 {
    #RLEH::Open
    
    
    if 0 {
    
      set gaSet(fail) "Set Environment Fail"
      set ret [Send $com "env default -f -a\r" "default environment"]
      if {$ret!=0} {return $ret}
      set gaSet(fail) "Save Environment Fail"
      set ret [Send $com "saveenv\r" "SPI flash...done"]
      if {$ret!=0} {return $ret}
      
      if {$gaSet(dutFam.sf)=="ETX-1P" || $gaSet(dutFam.sf)=="ETX-1P_SFC" || $gaSet(dutFam.sf)=="ETX-1P_A"} {
        set scr set_etx1p
      } else {
        if {[string match *.HL.*  $gaSet(DutInitName)]} {
          set scr set_sf1p_superset_hl
        } else {
          set scr set_sf1p_superset_cp2
        }
      }
      puts "\n[MyTime]Script:<$scr>"
      set ret [Send $com "run $scr\r" "SPI flash...done"]
      if {$ret!=0} {return $ret}
      
      
      set ret [Send $com "setenv set_nfsroot \"setenv nfsserv\;setenv nfsserv root=/dev/nfs rootfstype=nfs nfsroot=\$serverip:/srv/nfs/pcpe-general,vers=2,tcp\r" "PCPE>>"]
      if {$ret!=0} {return $ret}
    }
  }
 
  return $ret
}

# ***************************************************************************
# Disable_Uboot
# ***************************************************************************
proc Disable_Uboot {} {
  puts "\n[MyTime] Disable_Uboot"
  global gaSet buffer
  set com  $gaSet(comDut)
  set gaSet(fail) "No \'PCPE\' respond"
  for {set i 1} {$i<=20} {incr i} {
    set ret [Send $com c\rc\r "PCPE>" 1]; ## 10/07/2025 add c to stop in boot 6.4
    if {$ret==0} {break}
    if [string match {* E *} $buffer] {
      Send $com "x\rx\r" "PCPE>" 1; ## 10/07/2025 add c to stop in boot 6.4
    }
  }
  if {$ret!=0} {
    set gaSet(fail) "Login to Boot level fail" 
    return -1
  }
  
  set ret [Send $com "setenv bootdelay -2\r" "PCPE>"]
  if {$ret!=0} {
    set gaSet(fail) "setenv bootdelay fail"
    return $ret
  }
  set ret [Send $com "saveenv\r" "PCPE>"]
  if {$ret!=0} {
    set gaSet(fail) "saveenv fail"
    return $ret
  }
  
  set ret [Send $com "reset\r" "any key to stop autoboot" 10]
  ## Countdown should not appear!
  if {$ret==0} {
    set gaSet(fail) "Countdown to stop autoboot is appearing"
    return -1
  }

  return 0  
}

# ***************************************************************************
# CheckDockerPS
# ***************************************************************************
proc CheckDockerPS {} {
  global gaSet buffer
  puts "\n[MyTime] CheckDockerPS"
  set com $gaSet(comDut)
  
  set ret [Login]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure port lora 1\r" "(1)"]
  if {$ret!=0} {
    set gaSet(fail) "Can't reach \'port lora 1\'"
    return $ret
  }
  #set ret [Send $com "frequency plan us915\r" "(1)"]
  set ret [Send $com "frequency plan $gaSet(dutFam.lora.region)\r" "(1)"]
  if {$ret!=0} {
    set gaSet(fail) "Can't confugure \'frequency plan\'"
    return $ret
  }
  set ret [Send $com "gateway operation-mode udp-forward \r" "(1)"]
  if {$ret!=0} {
    set gaSet(fail) "Can't confugure \'gateway operation-mode\'"
    return $ret
  }
  set ret [Send $com "gateway server ip-address 172.18.94.105 port 1700 \r" "(1)"]
  if {$ret!=0} {
    set gaSet(fail) "Can't confugure \'gateway server ip-address\'"
    return $ret
  }
  set ret [Send $com "gateway no shutdown\r" "(1)" 30]
  if {$ret!=0} {
    set gaSet(fail) "Can't confugure \'gateway no shutdown\'"
    return $ret
  }
  Send $com "exit all\r" "stam" 3
  
  
  set ret [Login2Linux]
  if {$ret==0} {
    for {set chDocTry 1} {$chDocTry<=3} {incr chDocTry} {
      puts "CheckDockerPS $chDocTry"
      Send $com \r\r $gaSet(linuxPrompt)
      Send $com "docker image list\r" $gaSet(linuxPrompt)
      set ret 0
      AddToPairLog $gaSet(pair) "Docker Image: $buffer"  
      if ![string match {*rakwireless/udp-packet-forwarder*} $buffer] {
        set gaSet(fail) "No Docker Image"
        set ret -1
      } 
      if {$ret==0} {
        Send $com "docker container list\r" $gaSet(linuxPrompt)
        AddToPairLog $gaSet(pair) "Docker Container: $buffer"
        if ![string match {*rakwireless/udp-packet-forwarder*} $buffer] {
          set gaSet(fail) "No Docker Container"
          set ret -1
        }
      }
      if {$ret==0} {
        break
      } else {
        Wait "Wait for docker container" 10
      }
    }
    puts "CheckDockerPS $chDocTry ret:$ret\n"
    
    Send $com "exit\r\r" -1p
    return $ret
    
  } else {
    set gaSet(fail) "Login to Linux fail"
    return $ret
  }
  set ret [Send $com "exit\r\r" -1p]
  if {$ret!=0} {
    set gaSet(fail) "Exit from Linux fail"
  }
  return $ret
}
# ***************************************************************************
# Login2Linux
# ***************************************************************************
proc Login2Linux {} {
  global gaSet buffer
  set ret -1
  set gaSet(loginBuffer) ""
  set statusTxt  [$gaSet(sstatus) cget -text]
  Status "Login to Linux"
  set com $gaSet(comDut)
  
  Send $com "\r" stam 1
  if {[string match {*root@localhost*} $gaSet(loginBuffer)]} {
    return 0
  }
  
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "debug shell\r\r" localhost]
  if [string match *:/#* $buffer] {
    set gaSet(linuxPrompt) /#
  } elseif [string match */\]* $buffer] {
    set gaSet(linuxPrompt) /\]
  }
  set ret [Send $com "\r\r" $gaSet(linuxPrompt)]
  return $ret
}

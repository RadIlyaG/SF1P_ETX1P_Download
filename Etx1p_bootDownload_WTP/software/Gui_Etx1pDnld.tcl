#***************************************************************************
#** GUI
#***************************************************************************
proc GUI {} {
  global gaSet gaGui glTests  
  
  #wm title . "$gaSet(pair) $gaSet(DutFullName) Boot Downloads"
  wm title . "$gaSet(pair)  Boot Downloads"
  wm protocol . WM_DELETE_WINDOW {Quit}
  wm geometry . $gaGui(xy) ; #492x276
  wm resizable . 1 1
  set descmenu {
    "&File" all file 0 {	 
      {command "Log File"  {} {} {} -command ShowLog}
	    {separator}     
      {cascad "&Console" {} console 0 {
        {checkbutton "console show" {} "Console Show" {} -command "console show" -variable gConsole}
        {command "Capture Console" cc "Capture Console" {} -command CaptureConsole}
      }
      }
      {separator}
      {command "Edit L1 list file" init "" {} -command {exec notepad L1.txt &}}
      {command "Edit L2 list file" init "" {} -command {exec notepad L2.txt &}}
      {command "Edit L3 list file" init "" {} -command {exec notepad L3.txt &}}
      {command "Edit L4 list file" init "" {} -command {exec notepad L4.txt &}}
      {command "Edit HSP list file" init "" {} -command {exec notepad HSP.txt &}}
      {separator}
      {command "Load Modem list files" init "" {} -command {LoadModemFiles}}
      {separator}
      {separator}
      {command "History" History "" {} \
         -command {
           set cmd [list exec "C:\\Program\ Files\\Internet\ Explorer\\iexplore.exe" [pwd]\\history.html &]
           eval $cmd
         }
      }
      {separator}
      {command "Update INIT and UserDefault files on all the Testers" {} "Exit" {} -command {UpdateInitsToTesters}}
      {separator}
      {command "E&xit" exit "Exit" {Alt x} -command {Quit}}
    }
    "&Tools" tools tools 0 {	  
      {command "Linux Setup" init {} {} -command {GuiLinuxSetup}}
      {separator}  
      {command "Inventory" init {} {} -command {GuiInventory}}
      {separator}  
      {cascad "Power" {} pwr 0 {
        {command "PS-1 & PS-2 ON" {} "" {} -command {GuiPower $gaSet(pair) 1}} 
        {command "PS-1 & PS-2 OFF" {} "" {} -command {GuiPower $gaSet(pair) 0}}  
        {command "PS-1 ON" {} "" {} -command {GuiPower $gaSet(pair).1 1}} 
        {command "PS-1 OFF" {} "" {} -command {GuiPower $gaSet(pair).1 0}} 
        {command "PS-2 ON" {} "" {} -command {GuiPower $gaSet(pair).2 1}} 
        {command "PS-2 OFF" {} "" {} -command {GuiPower $gaSet(pair).2 0}} 
        {command "PS-1 & PS-2 OFF and ON" {} "" {} \
            -command {
              GuiPower $gaSet(pair) 0
              after 1000
              GuiPower $gaSet(pair) 1
            }  
        }             
      }
      }                
      {separator}    
      {radiobutton "One test ON"  init {} {} -value 1 -variable gaSet(oneTest)}
      {radiobutton "One test OFF" init {} {} -value 0 -variable gaSet(oneTest)}
                          
    }
    "&Terminal" terminal tterminal 0  {
      {command "UUT" "" "" {} -command {OpenTeraTerm gaSet(comDut)}}  
      {command "Serial-1" "" "" {} -command {OpenTeraTerm gaSet(comSer1)}}  
      {command "Serial-2" "" "" {} -command {OpenTeraTerm gaSet(comSer2)}} 
      {command "485-2" "" "" {} -command {OpenTeraTerm gaSet(comSer485)}}                     
    }
    "&About" all about 0 {
      {command "&About" about "" {} -command {About} 
      }
    }
  }
  

  set mainframe [MainFrame .mainframe -menu $descmenu]
  
  set gaSet(sstatus) [$mainframe addindicator]  
  $gaSet(sstatus) configure -width 36 
  
  set gaSet(statBarShortTest) [$mainframe addindicator]
  
  
  set gaSet(startTime) [$mainframe addindicator]
  
  set gaSet(runTime) [$mainframe addindicator]
  $gaSet(runTime) configure -width 5
  
  set tb0 [$mainframe addtoolbar]
  pack $tb0 -fill x
  set labstartFrom [Label $tb0.labSoft -text "Start From   "]
  set gaGui(startFrom) [ttk::combobox $tb0.cbstartFrom  -height 18 -width 35 -textvariable gaSet(startFrom) -justify center -state readonly]
  bind $gaGui(startFrom) <Button-1> {SaveInit}
  pack $labstartFrom $gaGui(startFrom) -padx 2 -side left
  set sepIntf [Separator $tb0.sepIntf -orient vertical]
  pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0
	 
  set bb [ButtonBox $tb0.bbox0 -spacing 1 -padx 5 -pady 5]
    set gaGui(tbrun) [$bb add -image [Bitmap::get images/run1] \
        -takefocus 1 -command ButRun \
        -bd 1 -padx 5 -pady 5 -helptext "Run the Tester"]		 		 
    set gaGui(tbstop) [$bb add -image [Bitmap::get images/stop1] \
        -takefocus 0 -command ButStop \
        -bd 1 -padx 5 -pady 5 -helptext "Stop the Tester"]
    set gaGui(tbpaus) [$bb add -image [Bitmap::get images/pause] \
        -takefocus 0 -command ButPause \
        -bd 1 -padx 5 -pady 1 -helptext "Pause/Continue the Tester"]	    
  pack $bb -side left  -anchor w -padx 7 ;#-pady 3
  set bb [ButtonBox $tb0.bbox1 -spacing 1 -padx 5 -pady 5]
    set gaGui(noSet) [$bb add -image [image create photo -file images/circle.ico] \
        -takefocus 0 -command {UpdateGuiFromInit} \
        -bd 1 -padx 5 -pady 5 -helptext "Update Gui from Init"]    
  pack $bb -side left  -anchor w -padx 7
  set bb [ButtonBox $tb0.bbox12 -spacing 1 -padx 5 -pady 5]
    set gaGui(email) [$bb add -image [image create photo -file  images/email16.ico] \
        -takefocus 0 -command {GuiEmail .mail} \
        -bd 1 -padx 5 -pady 5 -helptext "Email Setup"] 
    set gaGui(ramzor) [$bb add -image [image create photo -file  images/TRFFC09_1.ico] \
        -takefocus 0 -command {GuiIPRelay} \
        -bd 1 -padx 5 -pady 5 -helptext "IP-Relay Setup"]        
  #pack $bb -side left  -anchor w -padx 7
  
  set sepIntf [Separator $tb0.sepFL -orient vertical]
  #pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0 
  
  set bb [ButtonBox $tb0.bbox2]
    set gaGui(butShowLog) [$bb add -image [image create photo -file images/find1.1.ico] \
        -takefocus 0 -command {ShowLog} -bd 1 -helptext "View Log file"]     
  #pack $bb -side left  -anchor w -padx 7
  
      
    set frCommon [frame [$mainframe getframe].frCommon -bd 2 -relief groove]
      set fr [frame $frCommon.fr1 -bd 0 -relief groove]
        set gaGui(dnldMode) [ttk::checkbutton $fr.chbdnldMode -text "Update SW only"\
           -variable gaSet(dnldMode) -command BuildTests]
        pack $gaGui(dnldMode) -anchor w -padx 2 -pady 2   
      pack $fr -anchor w
      set fr [frame $frCommon.fr2 -bd 0 -relief groove]
        set gaGui(chbCustSaf) [ttk::radiobutton $fr.rad1 -text "Safaricom    ($gaSet(safaricom.SWver))" -value safaricom -variable gaSet(customer) -command ChangeCust]
        set gaGui(chbCustGen) [ttk::radiobutton $fr.rad2 -text "General    ($gaSet(general.SWver))"  -value general -variable gaSet(customer) -command ChangeCust]
        # 07/02/2022 09:45:45 pack $gaGui(chbCustSaf) $gaGui(chbCustGen)  -padx 2 -pady 2 -anchor w
        
        set gaGui(labBoot) [ttk::label $fr.labBoot -text "Boot version: $gaSet(dbrBoot)" ]
        #pack $gaGui(labBoot)  -padx 2 -pady 2 -anchor w
        set gaGui(labApp) [ttk::label $fr.labApp -text "App version: $gaSet(dbrApp)" ]
        #pack $gaGui(labApp)  -padx 2 -pady 2 -anchor w
        
        set gaGui(actGen) [ttk::label $fr.labActPack -text "Active Package: $gaSet(actGen)" ]
        pack $gaGui(actGen)  -padx 2 -pady 2 -anchor w
        
        set gaGui(pcpeGen) [ttk::label $fr.labGen -text "Packages: $gaSet(general.pcpes)" ]
        pack $gaGui(pcpeGen)  -padx 2 -pady 2 -anchor w
        
        set gaGui(chbCustGen) [ttk::label $fr.rad22 -text "SW Ver.: $gaSet(safaricom.SWver)"]
        pack $gaGui(chbCustGen)  -padx 2 -pady 2 -anchor w
        
        set gaGui(flashImg) [ttk::label $fr.flashImg -text "Flash Image: $gaSet(general.flashImg)" ]
        pack $gaGui(flashImg)  -padx 2 -pady 2 -anchor w
        
        set gaGui(bootScript) [ttk::label $fr.lavbootScript -text "Boot Script: $gaSet(bootScript)" ]
        pack $gaGui(bootScript)  -padx 2 -pady 2 -anchor w
          
      pack $fr  -anchor w  -fill x
      
    pack $frCommon -fill both -expand 0 -padx 2 -pady 2 -side left 
	 
    set frTestPerf [frame [$mainframe getframe].frTestPerf -bd 2 -relief groove]     
      set f $frTestPerf
      
      set frDUT  [frame $f.frDUT -bd 2 -relief groove] 
        set labDUT [ttk::label $frDUT.labDUT -text "UUT's barcode" -width 15]
        set gaGui(entDUT) [ttk::entry $frDUT.entDUT -justify center -width 14 -textvariable gaSet(entDUT)]
        bind $gaGui(entDUT)  <Return> {GetDbrName full}   
        set gaGui(entDutFullName) [ttk::entry $frDUT.entDutFullName -width 35 -justify center -textvariable gaSet(DutFullName) -state disabled] ; #  -state disabled
        pack $labDUT $gaGui(entDUT) $gaGui(entDutFullName) -side left -padx 2
        pack configure         $gaGui(entDutFullName) -fill x -expand yes
        
      
      set frUut [frame $f.frUut -bd 2 -relief groove]  
        set fu $frUut ; #[$frUut getframe]
        
        set entWidth 10
        set labPCB_MAIN_ID [ttk::label $fu.labPCB_MAIN_ID -text "PCB_MAIN_ID"]  ; # SF-1P.REV0.6I
        set gaGui(entPCB_MAIN_IDbarc) [ttk::entry $fu.entPCB_MAIN_IDbarc -width $entWidth -justify center -textvariable gaSet(mainPcbIdBarc)] 
        bind $gaGui(entPCB_MAIN_IDbarc) <Return> {GetPcbID main}   
        set gaGui(entPCB_MAIN_ID) [ttk::entry $fu.entPCB_MAIN_ID -justify center -textvariable gaSet(mainPcbId)  -state disabled] ; #  -state disabled
        
        set labPCB_SUB_CARD_1_ID [ttk::label $fu.labPCB_SUB_CARD_1_ID -text "PCB_SUB_CARD_1_ID"] ; # SF-1V/PS.REV0.3I
        set gaGui(entPCB_SUB_CARD_1_IDbarc) [ttk::entry $fu.entPCB_SUB_CARD_1_IDbarc -width $entWidth -justify center -textvariable gaSet(sub1PcbIdBarc)] 
        bind $gaGui(entPCB_SUB_CARD_1_IDbarc) <Return> {GetPcbID sub1} 
        set gaGui(entPCB_SUB_CARD_1_ID) [ttk::entry $fu.entPCB_SUB_CARD_1_ID -justify center -textvariable gaSet(sub1PcbId)  -state disabled]  ; #  -state disabled
        
        set labHARDWARE_ADDITION [ttk::label $fu.labHARDWARE_ADDITION -text "HARDWARE_ADDITION"]
        set gaGui(entHARDWARE_ADDITION) [ttk::entry $fu.entHARDWARE_ADDITION -width $entWidth -justify center -textvariable gaSet(hwAdd) -state disabled]  

        set labCSL [ttk::label $fu.labCSL -text "CSL"]
        set gaGui(entCSL) [ttk::entry $fu.entCSL -width $entWidth -justify center -textvariable gaSet(csl)  -state disabled]  ; #  -state disabled
        
        grid $labPCB_MAIN_ID       $gaGui(entPCB_MAIN_IDbarc) $gaGui(entPCB_MAIN_ID)        -sticky w -padx 2 -pady 2
        grid $labPCB_SUB_CARD_1_ID $gaGui(entPCB_SUB_CARD_1_IDbarc) $gaGui(entPCB_SUB_CARD_1_ID)  -sticky w -padx 2 -pady 2
        grid $labPCB_MAIN_ID       $gaGui(entPCB_MAIN_ID)        -sticky w -padx 2 -pady 2
        grid $labPCB_SUB_CARD_1_ID $gaGui(entPCB_SUB_CARD_1_ID)  -sticky w -padx 2 -pady 2
        grid $labHARDWARE_ADDITION $gaGui(entHARDWARE_ADDITION)  -sticky w -padx 2 -pady 2
        grid $labCSL               $gaGui(entCSL)                -sticky w -padx 2 -pady 2
        
      
      
      set frCur [frame $f.frCur] 
        set labCur [ttk::label $frCur.labCur -text "Current Test  "]
        set gaGui(curTest) [ttk::entry $frCur.curTest -state readonly  -textvariable gaSet(curTest) \
	       -justify center -width 45]
        pack $labCur $gaGui(curTest) -padx 7 -pady 1 -side left -fill x;# -expand 1 
      pack  $frDUT $frUut $frCur  -anchor w -pady 2 -padx 2 -fill x  -expand 1 
      #set frStatus [frame $f.frStatus]
      #  set labStatus [Label $frStatus.labStatus -text "Status  " -width 12]
      #  set gaGui(labStatus) [Entry $frStatus.entStatus \
            -bd 1 -editable 0 -relief groove \
	   -textvariable gaSet(status) -justify center -width 58]
      #  pack $labStatus $gaGui(labStatus) -fill x -padx 7 -pady 3 -side left;# -expand 1 	 
      #pack $frStatus -anchor w
      set frFail [frame $f.frFail]
      set gaGui(frFailStatus) $frFail
        set labFail [Label $frFail.labFail -text "Fail Reason  "]
        set labFailStatus [Entry $frFail.labFailStatus \
            -bd 1 -editable 1 -relief groove \
            -textvariable gaSet(fail) -justify center -width 60]
      pack $labFail $labFailStatus -fill x -padx 7 -pady 3 -side left; # -expand 1	
      #pack $gaGui(frFailStatus) -anchor w
  
    pack $frTestPerf -fill both -expand yes -padx 2 -pady 2 -anchor nw	 
  pack $mainframe -fill both -expand yes

  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled  

  console eval {.console config -height 15 -width 74}
  console eval {set ::tk::console::maxLines 10000}
  console eval {.console config -font {Verdana 10}}
  focus -force .
  bind . <F1> {console show}
  bind . <Alt-i> {GuiInventory}
  bind . <Alt-r> {ButRun}
  bind . <Alt-s> {ButStop}
  bind . <Alt-b> {set gaSet(useExistBarcode) 1}
  bind . <Control-p> {ToolsPower on}
  

  .menubar.tterminal entryconfigure 0 -label "UUT: COM $gaSet(comDut)"
  
  
  set ::NoATP 0
  if $::NoATP {
    RLStatus::Show -msg atp
  }
#   RLStatus::Show -msg fti
  set gaSet(entDUT) ""
  
  ToggleCustometSW
  
  
}
# ***************************************************************************
# About
# ***************************************************************************
proc About {} {
  if [file exists history.html] {
    set id [open history.html r]
    set hist [read $id]
    close $id
#     regsub -all -- {[<>]} $hist " " a
#     regexp {div ([\d\.]+) \/div} $a m date
    regsub -all -- {<[\w\=\#\d\s\"\/]+>} $hist "" a
    regexp {<!---->\s(.+)\s<!---->} $a m date
  } else {
    set date 08.12.2021
  }
  DialogBox -title "About the Tester" -icon info -type ok  -font {{Lucida Console} 9} -message "ATE software upgrade\n$date"
  #DialogBox -title "About the Tester" -icon info -type ok\
          -message "The software upgrated at 02.12.2020"
}

#***************************************************************************
#** Quit
#***************************************************************************
proc Quit {} {
  global gaSet
  SaveInit
  SaveInitGUI
  RLSound::Play information
  set ret [DialogBox -title "Confirm exit"\
      -type "yes no" -icon images/question -aspect 2000\
      -text "Are you sure you want to close the application?"]
  if {$ret=="yes"} {exit}
  if {$ret=="yes"} {SQliteClose; CloseRL; IPRelay-Green; exit}
}

#***************************************************************************
#** CaptureConsole
#***************************************************************************
proc CaptureConsole {} {
 console eval { 
    set b [.console get 1.0 1.15]
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
    if ![file exists c:/temp] {
      file mkdir c:/temp
      after 1000
    }
    set fi c:\\temp\\ConsoleCapt_[set b]_[set ti].txt
    if [file exists $fi] {
      set res [tk_messageBox -title "Save Console Content" \
        -icon info -type yesno \
        -message "File $fi already exist.\n\
               Do you want overwrite it?"]      
      if {$res=="no"} {
         set types { {{Text Files} {.txt}} }
         set new [tk_getSaveFile -defaultextension txt \
                 -initialdir c:\\ -initialfile [file rootname $fi]  \
                 -filetypes $types]
         if {$new==""} {return {}}
      }
    }
    set aa [.console get 1.0 end]
    set id [open $fi w]
    puts $id $aa
    close $id
  }
}

#***************************************************************************
#** ButRun
#***************************************************************************
proc ButRun {} {
  global gaSet gaGui glTests gRelayState
  
  pack forget $gaGui(frFailStatus)
  Status ""
  focus $gaGui(tbrun) 
  set gaSet(runStatus) ""
  set gaSet(1.barcode1.IdMacLink) ""
  
  set gaSet(act) 1
  console eval {.console delete 1.0 end}
  console eval {set ::tk::console::maxLines 100000}
    
  set clkSeconds [clock seconds]
  set ti [clock format $clkSeconds -format  "%Y.%m.%d-%H.%M"]
  set gaSet(logTime) [clock format  $clkSeconds -format  "%Y.%m.%d-%H.%M.%S"]
  
  set ret 0
  
  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
    
  set ret [SanityBarcodes]
  
  set gaSet(log.$gaSet(pair)) c:/logs/${gaSet(logTime)}.${gaSet(idBarcode)}.txt
  AddToPairLog $gaSet(pair) "LogTime: $gaSet(logTime)"
  AddToPairLog $gaSet(pair) " $gaSet(idBarcode) "
  
  puts "$gaSet(idBarcode)"
  puts " $gaSet(DutFullName) "
  puts " MainCard $gaSet(mainPcbIdBarc) $gaSet(mainPcbId) "
  puts " SubCard1 $gaSet(sub1PcbIdBarc) $gaSet(sub1PcbId) "

  set gaSet(curTest) $gaSet(startFrom)
  if {$ret==0} {
    Status ""
    set gaSet(curTest) $gaSet(startFrom) ; #[$gaGui(startFrom) cget -text]
    console eval {.console delete 1.0 "end-1001 lines"}
    pack forget $gaGui(frFailStatus)
    $gaSet(startTime) configure -text "[MyTime] " ; # Start: 
    $gaGui(tbrun) configure -relief sunken -state disabled
    $gaGui(tbstop) configure -relief raised -state normal
    $gaGui(tbpaus) configure -relief raised -state normal
    set gaSet(fail) ""
    foreach wid {startFrom} {
      $gaGui($wid) configure -state disabled
    }
    #.mainframe setmenustate tools disabled
    update

    RLTime::Delay 1
    catch {unset gaSet(1.mac1)}
    catch {unset gaSet(1.imei1)}
    catch {unset gaSet(1.imei2)}
    
    set ret 0
    #GuiPower all 1 ; ## power ON before OpenRL
    set gaSet(plEn) 0
    if {$ret==0} {
       catch {RLCom::Close $gaSet(comDut) }
       catch {RLEH::Close}
       
       RLEH::Open
       OpenPio 
       Power all off
       after 4000
       Power all on
       ClosePio
      
       set ret [RLCom::Open $gaSet(comDut) 115200 8 NONE 1]
       if {$ret==0} { 
         set gaSet(runStatus) ""
         set ret [Testing]
       }
       catch {RLCom::Close $gaSet(comDut) }
       catch {RLEH::Close}
    }
  
    puts "ret of Testing: $ret"  ; update
    foreach wid {startFrom } {
      $gaGui($wid) configure -state normal
    }
    .mainframe setmenustate tools normal
    puts "end of normal widgets"  ; update
    update
#     set retC [CloseRL]
#     puts "ret of CloseRL: $retC"  ; update
    
    set gaSet(oneTest) 0
    set gaSet(rerunTesterMulti) conf
    set gaSet(nextPair) begin    
    
    set gRelayState red
    
  }
  
  if {$ret==0} {
    RLSound::Play pass
    Status "Done"  green
    file rename -force $gaSet(log.$gaSet(pair)) [file rootname $gaSet(log.$gaSet(pair))]-Pass.txt
    set log [file rootname $gaSet(log.$gaSet(pair))]-Pass.txt
    set gaSet(runStatus) Pass
	  
	  set gaSet(curTest) ""
	  set gaSet(startFrom) [lindex $glTests 0]
  } elseif {$ret==1} {
    RLSound::Play information
    Status "The test has been perform"  yellow
    set log ""
  } else {
    set gaSet(runStatus) Fail  
    if {$ret=="-2"} {
	    set gaSet(fail) "User stop"
      
      ## do not include UserStop in statistics
      set gaSet(runStatus) ""  
	  }
	  pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
	  RLSound::Play fail
	  Status "Test FAIL"  red
	  file rename -force $gaSet(log.$gaSet(pair)) [file rootname $gaSet(log.$gaSet(pair))]-Fail.txt   
    set log [file rootname $gaSet(log.$gaSet(pair))]-Fail.txt   
    
    set gaSet(startFrom) $gaSet(curTest)
    update
  }
  if {$gaSet(runStatus)!=""} {
    #SQliteAddLine
  }
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  
  set gaSet(idBarcode) ""
  set gaSet(DutFullName) ""
  set gaSet(hwAdd) ""
  set gaSet(mainPcbId) ""
  set gaSet(sub1PcbId) ""
  
  update
}


#***************************************************************************
#** ButStop
#***************************************************************************
proc ButStop {} {
  global gaGui gaSet
  set gaSet(act) 0
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  foreach wid {startFrom } {
    $gaGui($wid) configure -state normal
  }
  .mainframe setmenustate tools normal
  ##CloseRL
  update
}
# ***************************************************************************
# ButPause
# ***************************************************************************
proc ButPause {} {
  global gaGui gaSet
  if { [$gaGui(tbpaus) cget -relief] == "raised" } {
    $gaGui(tbpaus) configure -relief "sunken"     
    #CloseRL
  } else {
    $gaGui(tbpaus) configure -relief "raised" 
    #OpenRL   
  }
        
  while { [$gaGui(tbpaus) cget -relief] != "raised" } {
    RLTime::Delay 1
  }  
}
# ***************************************************************************
# GuiLinuxSetup
# ***************************************************************************
proc GuiLinuxSetup {} {
  global gaSet gaTmpSet gaGui
  array unset gaTmpSet
  Status ""
  set allLists [Read_Linux]
  set apps [lsort -dict [lindex $allLists 0]]
  set gens [lsort -dict [lindex $allLists 1]]
  set flashs [lindex $allLists 2]
  set bootScripts [lindex $allLists 3]
  set actGen [lindex $allLists 4]
  # puts "\n actGen:$actGen\n"; update
  
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 0 0
  
  wm title $base "Linux Server Setup"
  
  foreach par {safaricom.SWver general.SWver uBootFilesPath \
               general.pcpes general.flashImg bootScript actGen\
               linux_srvr_ip} {
    if ![info exists gaSet($par)] {
      set gaSet($par) ??
    }
    set gaTmpSet($par) $gaSet($par)
  }
  set gaTmpSet(actGen) $actGen
    
  set pathWith 60
  
  set fr [TitleFrame $base.fr2 -text "Linux Server" -bd 2 -relief groove]
    set fr0 [$fr getframe]

    set fr2 [frame $fr0.fr2]
      set labelWidth 16
      set txt "UUT Software"
      set lab1 [ttk::label $fr2.lab1  -text "Safaricom" -width $labelWidth] 
      #set lab2 [ttk::entry $fr2.lab2  -textvariable gaTmpSet(safaricom.SWver) -width 30 -justify center] 
      set cmb1 [ttk::combobox $fr2.cmb1  -textvariable gaTmpSet(safaricom.SWver) -values $apps -width 30 -justify center]
      
      set labActPack [ttk::label $fr2.labActPack  -text "Active Package: " -width $labelWidth] 
      set cmbActPack [ttk::entry $fr2.cmbActPack  -textvariable gaTmpSet(actGen) -state readonly -width 30 -justify center]
      grid $labActPack $cmbActPack -sticky w -padx 2 -pady 2 
      
      set labPack [ttk::label $fr2.labPack  -text "Package: " -width $labelWidth] 
      set cmbPack [ttk::combobox $fr2.cmbPack  -textvariable gaTmpSet(general.pcpes) -values $gens -width 30 -justify center]
      grid $labPack $cmbPack -sticky w -padx 2 -pady 2; ## 11:35 30/04/2023 
      
      set labSW [ttk::label $fr2.lab3  -text "SW" -width $labelWidth] 
      #set lab4 [ttk::entry $fr2.lab4  -textvariable gaTmpSet(general.SWver) -width 30 -justify center] 
      set cmbSW [ttk::combobox $fr2.cmbSW  -textvariable gaTmpSet(general.SWver) -values $apps -width 30 -justify center]
      #grid $lab1 $lab2 -sticky w -padx 2 -pady 2
      
      # 07/02/2022 09:45:45 grid $lab1 $cmb1 -sticky w -padx 2 -pady 2
      #grid $lab3 $lab4 -sticky w -padx 2 -pady 2
      grid $labSW $cmbSW -sticky w -padx 2 -pady 2
      
      
      set lab5 [ttk::label $fr2.lab5  -text "Flash Image: " -width $labelWidth] 
      set cmb5 [ttk::combobox $fr2.cmb5  -textvariable gaTmpSet(general.flashImg)  -values $flashs -width 30 -justify center]
      grid $lab5 $cmb5 -sticky w -padx 2 -pady 2 ; #-state disabled
      
      set lab6 [ttk::label $fr2.lab6  -text "Boot Script: " -width $labelWidth] 
      set cmb6 [ttk::combobox $fr2.cmb6  -textvariable gaTmpSet(bootScript) -state disabled -values $bootScripts -width 30 -justify center]
      grid $lab6 $cmb6 -sticky w -padx 2 -pady 2
      
    grid $fr2  -padx 2 -pady 2  -sticky ew
    
    set fr3 [frame $fr0.fr3]
      set lab1 [ttk::label $fr3.lab1  -text "Uboot Files"  -width $labelWidth] 
      set lab2 [ttk::entry $fr3.lab2  -textvariable gaTmpSet(uBootFilesPath) -state readonly -width 20] 
      grid $lab1 $lab2 -sticky w -padx 2 -pady 2
      bind  $lab2 <Double-1> {eval exec [auto_execok start] [list "" $gaTmpSet(uBootFilesPath)]}
    grid $fr3  -padx 2 -pady 2  -sticky ew
    
    set fr4 [frame $fr0.fr4]
      set lab1 [ttk::label $fr4.lab1  -text "Server IP"  -width $labelWidth] 
      set lab2 [ttk::entry $fr4.lab2  -textvariable gaTmpSet(linux_srvr_ip) -width 20] 
      grid $lab1 $lab2 -sticky w -padx 2 -pady 2  
    grid $fr4  -padx 2 -pady 2  -sticky ew
  pack $fr  -anchor w  -pady 2 -padx 2  -fill both -expand 1
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    #pack [ttk::button $base.frBut.butImp -text Import -command ButImportInventory -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butCanc -text Cancel -command ButCancLinuxSetup -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butOk -text Ok -command ButOkLinuxSetup -width 7]  -side right -padx 6
  
  focus -force $base
  #grab $base
  return {}  
}

# ***************************************************************************
# BrowseCF
# ***************************************************************************
proc BrowseCF {txt f} {
  global gaTmpSet gaSet
  puts "BrowseCF <$txt> <$f>"
  set dir [file join c:/download]/sf1v
#   switch -exact -- $f {
#     BootCF - SWCF {
#       set dir [file join c:/download]
#     } 
#     default {
#       set dir [file join [file dirname [pwd]] ConfFiles]
#     } 
#   }
  
  set fil [tk_getOpenFile -title $txt -initialdir $dir]
  if {$fil!=""} {
    set gaTmpSet($f) $fil
  }
  focus -force .topHwInit
}
# ***************************************************************************
# ClearInvLabel
# ***************************************************************************
proc ClearInvLabel {f} {
  global gaSet gaGui  gaTmpSet
  set gaTmpSet($f) ""
}

# ***************************************************************************
# ButImportInventory
# ***************************************************************************
proc ButImportInventory {} {
  global gaSet gaTmpSet
  set fil [tk_getOpenFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
  if {$fil!=""} {  
    set gaTmpSet(DutFullName) $gaSet(DutFullName)
    set gaTmpSet(DutInitName) $gaSet(DutInitName)
    set DutInitName $gaSet(DutInitName)
    
    source $fil
    set parL [list sw]
    foreach par $parL {
      set gaTmpSet($par) $gaSet($par)
    }
    
    set gaSet(DutFullName) $gaTmpSet(DutFullName)
    set gaSet(DutInitName) $DutInitName ; #xcxc ; #gaTmpSet(DutInitName)    
  }    
  focus -force .topHwInit
}
#***************************************************************************
#** ButOkLinuxSetup
#***************************************************************************
proc ButOkLinuxSetup {} {
  global gaSet gaTmpSet
  
  if ![file exists uutInits] {
    file mkdir uutInits
  }
    
  set saveInitFile 0
  foreach nam [array names gaTmpSet] {
#     ## new unit
#     if ![info exists gaSet($nam)] {
#       set gaSet($nam) $gaTmpSet($nam)
#     }
    if {$gaTmpSet($nam)!=$gaSet($nam)} {
      puts "ButOkInventory1 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
      #set gaSet($nam) $gaTmpSet($nam)      
      set saveInitFile 1 
      break
    }  
  }
  
  if {![file exists uutInits/$gaSet(DutInitName)]} {
    set saveInitFile 1
  }
  
  if {$saveInitFile=="0"} {
    puts "ButOkLinuxSetup no difference"
  } elseif {$saveInitFile=="1"} {
    set txt "You are going to change the Server Setup\n\nAre you sure you want do it?"
    set res [DialogBox -title "Server Setup" -message  $txt -icon images/question \
        -type [list Yes No] -default 0]
    if {$res=="No"} {
      grab .topHwInit
      focus -force .topHwInit
      return -1
    }
    
    set res Save
    set fil "uutInits/$gaSet(DutInitName)"
    
    # if {[file exists uutInits/$gaSet(DutInitName)]} {
      # set txt "Init file for \'$gaSet(DutFullName)\' exists.\n\nAre you sure you want overwright the file?"
      # set res [DialogBox -title "Save init file" -message  $txt -icon images/question \
          # -type [list Save "Save As" Cancel] -default 2]
      # if {$res=="Cancel"} {return -1}
    # }
    # if {$res=="Save"} {
      # #SaveUutInit uutInits/$gaSet(DutInitName)
      # set fil "uutInits/$gaSet(DutInitName)"
    # } elseif {$res=="Save As"} {
      # set fil [tk_getSaveFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
      # if {$fil!=""} {        
        # set fil1 [file tail [file rootname $fil]]
        # puts fil1:$fil1
        # set gaSet(DutInitName) $fil1.tcl
        # set gaSet(DutFullName) $fil1
        # #set gaSet(entDUT) $fil1
        # wm title . "$gaSet(pair) : $gaSet(DutFullName)"
        # #SaveUutInit $fil
        # update
      # }
    # } 
    puts "ButOkLinuxSetup fil:<$fil>"
    if {$fil!=""} {
      foreach nam [array names gaTmpSet] {
        if {$gaTmpSet($nam)!=$gaSet($nam)} {
          puts "ButOkInventory2 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
          set gaSet($nam) $gaTmpSet($nam)      
        }  
      }
      SaveUutInit $fil
    } 
    
    wm iconify .topHwInit
    set ret [Linux_switch_pcpe customer appl $gaSet(general.pcpes)]
    puts "ButOkLinuxSetup ret after Linux_switch_pcpe:<$ret>"
    if {$ret==0} {
      set ret [Linux_SW]
      puts "ButOkLinuxSetup ret after Linux_SW:<$ret>"
    }
    if {$ret==0} {
      Status "Linux Server is updated!" #00FF00 ; # green
    } else {
      Status "$ret $gaSet(fail)" #FF0000 ; # red
    }
  }
  update
  array unset gaTmpSet
  SaveInit
  #BuildTests
  ToggleCustometSW
  ButCancLinuxSetup
}
#***************************************************************************
#** ButCancLinuxSetup
#***************************************************************************
proc ButCancLinuxSetup {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}

# ***************************************************************************
# ToggleCustometSW
# ***************************************************************************
proc ToggleCustometSW {} {
  global gaGui gaSet
  $gaGui(actGen) configure -text "Active Package: $gaSet(actGen)"
  $gaGui(pcpeGen) configure -text "Package: $gaSet(general.pcpes)"   
  $gaGui(chbCustSaf) configure -text "Safaricom    ($gaSet(safaricom.SWver))"
  $gaGui(chbCustGen) configure -text "SW Ver.: $gaSet(general.SWver)" 
  $gaGui(flashImg) configure -text "Flash Image: $gaSet(general.flashImg)"   
  $gaGui(bootScript) configure -text "Boot Script: $gaSet(bootScript)"    
  $gaGui(labBoot) configure -text "Boot version: $gaSet(dbrBoot)"    
  $gaGui(labApp) configure -text "App Version: $gaSet(dbrApp)"    
}  

# ***************************************************************************
# UpdateGuiFromInit
# ***************************************************************************
proc UpdateGuiFromInit {} {
  global gaSet gaGui
  source [info host]/init.tcl
  ToggleCustometSW
  Status ""
}
# ***************************************************************************
# GuiInventory
# ***************************************************************************
proc GuiInventory {} {
  global gaSet gaTmpSet gaGui
  array unset gaTmpSet
  Status ""
  
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 0 0
  
  wm title $base "Inventory"
  
  foreach par {dbrAppSwPack dbrApp dbrBootSwPack dbrBoot} {
    if ![info exists gaSet($par)] {
      set gaSet($par) ???
    }
    set gaTmpSet($par) $gaSet($par)
  }
    
  set pathWith 60
  set labelWidth 26
  
  set fr0 [frame $base.fr0 -bd 2 -relief groove]
    set lab1 [ttk::label $fr0.lab1  -text "Boot SW Package (SWxxxx)" -width $labelWidth]  
    set gaGui(dbrBootSwPack) [ttk::entry $fr0.dbrBootSwPack  -textvariable gaTmpSet(dbrBootSwPack) -width 10 -justify center]
    set gaGui(dbrBoot) [ttk::entry $fr0.dbrBoot  -textvariable gaTmpSet(dbrBoot) -width 12 -justify center -state readonly] 
          
    set lab2 [ttk::label $fr0.lab2  -text "App SW Package (SWxxxx)" -width $labelWidth]  
    set gaGui(dbrAppSwPack) [ttk::entry $fr0.dbrAppSwPack  -textvariable gaTmpSet(dbrAppSwPack) -width 10 -justify center]
    set gaGui(dbrApp) [ttk::entry $fr0.dbrApp  -textvariable gaTmpSet(dbrApp) -width 12 -justify center -state readonly] 
    
    grid $lab1 $gaGui(dbrBootSwPack) $gaGui(dbrBoot) -sticky w -padx 2 -pady 2
    grid $lab2 $gaGui(dbrAppSwPack)  $gaGui(dbrApp)  -sticky w -padx 2 -pady 2
  pack $fr0  -anchor w  -pady 2 -padx 2  -fill both -expand 1
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [ttk::button $base.frBut.butCanc -text Cancel -command ButCancInventory -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butOk -text Ok -command ButOkInventory -width 7]  -side right -padx 6
  
  focus -force $base
  #grab $base
  return {}  
}
# ***************************************************************************
# ButCancInventory
# ***************************************************************************
proc ButCancInventory {} {
  ButCancLinuxSetup
}
#***************************************************************************
#** ButOkInventory
#***************************************************************************
proc ButOkInventory {} {
  global gaSet gaTmpSet
  
  if ![file exists uutInits] {
    file mkdir uutInits
  }
    
  set saveInitFile 1
  # foreach nam [array names gaTmpSet] {
# #     ## new unit
# #     if ![info exists gaSet($nam)] {
# #       set gaSet($nam) $gaTmpSet($nam)
# #     }
    # if {$gaTmpSet($nam)!=$gaSet($nam)} {
      # puts "ButOkInventory1 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
      # #set gaSet($nam) $gaTmpSet($nam)      
      # set saveInitFile 1 
      # break
    # }  
  # }
  
  if {![file exists uutInits/$gaSet(DutInitName)]} {
    set saveInitFile 1
  }
  
  if {$saveInitFile=="0"} {
    puts "ButOkInventory no difference"
  } elseif {$saveInitFile=="1"} {
    set res Save
    set fil "uutInits/$gaSet(DutInitName)"
    
    if {[file exists uutInits/$gaSet(DutInitName)]} {
      set txt "Init file for \'$gaSet(DutFullName)\' exists.\n\nAre you sure you want overwright the file?"
      set res [DialogBox -title "Save init file" -message  $txt -icon images/question \
          -type [list Save "Save As" Cancel] -default 2]
      if {$res=="Cancel"} {return -1}
    }
    if {$res=="Save"} {
      #SaveUutInit uutInits/$gaSet(DutInitName)
      set fil "uutInits/$gaSet(DutInitName)"
    } elseif {$res=="Save As"} {
      set fil [tk_getSaveFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
      if {$fil!=""} {        
        set fil1 [file tail [file rootname $fil]]
        puts fil1:$fil1
        set gaSet(DutInitName) $fil1.tcl
        set gaSet(DutFullName) $fil1
        #set gaSet(entDUT) $fil1
        wm title . "$gaSet(pair) : $gaSet(DutFullName)"
        #SaveUutInit $fil
        update
      }
    } 
    puts "ButOkInventory fil:<$fil>"
    if {$fil!=""} {
      foreach nam [array names gaTmpSet] {
        if {$gaTmpSet($nam)!=$gaSet($nam)} {
          puts "ButOkInventory2 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
          set gaSet($nam) $gaTmpSet($nam)      
        }  
      }
      SaveUutInit $fil
    } 
    
  }
  update
  array unset gaTmpSet 
  set gaSet(dbrAppSwPack)  [string toupper $gaSet(dbrAppSwPack)]
  set gaSet(dbrBootSwPack) [string toupper $gaSet(dbrBootSwPack)]
  SaveInit
  #BuildTests
  ToggleCustometSW
  ButCancInventory
}



# ***************************************************************************
# KillWpd
# ***************************************************************************
proc KillWpd {} {
  global gaSet
  puts "before kill [MyTime]"; update
  catch {exec taskkill.exe /F /IM wtpdownload$gaSet(pair).exe} ress  
  #catch {exec taskkill.exe /F /IM notepad.exe} ress
  puts "after kill [MyTime]  ress:<$ress>"; update
}
package require twapi
set gaSet(pair) [lindex $argv 0]
wm iconify . ; update
wm title . "Kill WTP $gaSet(pair)"
bind . <F1> {console show}

source Lib_Gen_Etx1pDnld.tcl
ReadWpdLog

after 180000  {
  KillWpd
  exit
}  

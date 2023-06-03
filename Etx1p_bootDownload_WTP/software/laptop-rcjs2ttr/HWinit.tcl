set gaSet(linuxIp) 172.18.94.71
switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comDut)  4
      console eval {wm geometry . +150+1}
      console eval {wm title . "Con 1"} 
      set gaSet(pioBoxSerNum) FT1MS52Y  
      set gaSet(pioPwr1) 4
      set gaSet(pioPwr2) 4
  }
  2 {
      set gaSet(comDut)   2
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 2"} 
      set gaSet(pioBoxSerNum) FT1MSOEL  
      set gaSet(pioPwr1) 3    
      set gaSet(pioPwr2) 3       
  }
  3 {
      set gaSet(comDut)   6
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 3"} 
      set gaSet(pioBoxSerNum) FTS49QK 
      set gaSet(pioPwr1) 2       
      set gaSet(pioPwr2) 2
  }
  4 {
      set gaSet(comDut)   5
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 4"} 
      set gaSet(pioBoxSerNum) FT31CUAV  
      set gaSet(pioPwr1) 1 
      set gaSet(pioPwr2) 1      
  }
  5 {
      set gaSet(comDut)  9
      console eval {wm geometry . +150+1}
      console eval {wm title . "Con 5"} 
      set gaSet(pioBoxSerNum) FT1MS52Y  
      set gaSet(pioPwr1) 8
      set gaSet(pioPwr2) 8
  }
  6 {
      set gaSet(comDut)   7
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 6"} 
      set gaSet(pioBoxSerNum) FT1MSOEL  
      set gaSet(pioPwr1) 7    
      set gaSet(pioPwr2) 7       
  }
  7 {
      set gaSet(comDut)   10
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 7"} 
      set gaSet(pioBoxSerNum) FTS49QK 
      set gaSet(pioPwr1) 6       
      set gaSet(pioPwr2) 6
  }
  8 {
      set gaSet(comDut)    8
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 8"} 
      set gaSet(pioBoxSerNum) FT31CUAV  
      set gaSet(pioPwr1) 5 
      set gaSet(pioPwr2) 5      
  }
}  
source lib_PackSour.tcl

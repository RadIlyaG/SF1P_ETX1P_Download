switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comDut)  8
      console eval {wm geometry . +150+1}
      console eval {wm title . "Con 1"} 
      set gaSet(pioBoxSerNum) FT1MS52Y 
      set gaSet(pioPwr1) 1 
  }
  2 {
      set gaSet(comDut)   11
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 2"} 
      set gaSet(pioBoxSerNum) FT1MSOEL  
      set gaSet(pioPwr1) 1       
  }
  3 {
      set gaSet(comDut)   9
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 3"} 
      set gaSet(pioBoxSerNum) FTS49QK   
      set gaSet(pioPwr1) 1      
  }
  4 {
      set gaSet(comDut)    10
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 4"} 
      set gaSet(pioBoxSerNum) FT31CUAV 
      set gaSet(pioPwr1) 1        
  }
}  
source lib_PackSour.tcl

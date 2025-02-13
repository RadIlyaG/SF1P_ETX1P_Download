#!/bin/bash

stty -F /dev/ttyUSB1 115200 cs8 -cstopb -parenb

for i in {1..40..1}
do
   echo "Welcome $i times"
   read -n1  line < /dev/ttyUSB1
   echo $line
   #sleep 0.5 
done

#!/bin/sh
F=/dev/ttyUSB1
text=""
send_at_cmd()
{
        echo -e -n "AT+CUSD=1,"$1",15\015" > $F
        sleep 1      # Adjustable ! (usleep)
 	cat $F  | grep "+CUSD:"  > $text
	sleep 5
	killall cat
	echo $text
}
 
send_at_cmd AT
exit 0
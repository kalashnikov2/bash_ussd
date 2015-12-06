#!/bin/sh
# zte mf180  - openwrt mr3020 - consultar saldo ,tigo , falta convertir el resultado
# uso
# ./saldo.sh COMPORT TIMEOUTMS

device="/dev/ttyUSB$1"
command="AT+CUSD=1,*10#,15\r" # *10# get prepaid $$$$

tmp_file="/tmp/ussd_response.txt"

if ! echo "$2" | egrep -q "^[0-9]+$" ; then
  >&2 echo "sleep time is required (first argument)"
  exit 1
fi
sleep_time=$1

cp /dev/null "$tmp_file"
cat "$device" > "$tmp_file" &
bg_pid=$!

fault () {
  kill $bg_pid
  exit 2
}
trap "fault" SIGINT

quit () {
  kill $bg_pid
}
trap "quit" EXIT

# at least 1 ussd response
ussd_responses=""
while [ -z "$ussd_responses" ]; do
  echo -e "$command" > "$device"
  sleep $sleep_time

  # response will be like '+CUSD: 1,"C23..",15'
  ussd_responses=$(cat /tmp/ussd_response.txt | sed -nr "\
s/\
\+CUSD:\
[[:space:]]*?[01]\
[[:space:]]*?,\
[[:space:]]*?\"\
([0-9a-f]+?)\"\
.*$\
/\1/gip\
  ")
done
echo "$ussd_responses"
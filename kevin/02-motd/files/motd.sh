#!/bin/bash -e

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))

# get info
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`
FREEMEM=$((`cat /proc/meminfo | grep MemAvailable | awk {'print $2'}`/1024))
TOTMEM=$((`cat /proc/meminfo | grep MemTotal | awk {'print $2'}`/1024))

ifaces=("usb0" "eth0" "wlan0" "wlan1")
for eth in "${ifaces[@]}"
do
  TEST=`/sbin/ifconfig | grep ${eth}`
  if [[ ! -z "${TEST}" ]]; then
    # jessie
    #IP=$(/sbin/ifconfig ${eth} | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1)
    # stretch
    IP=$(/sbin/ifconfig ${eth} | /bin/grep "inet " | /usr/bin/awk {'print $2'})
    if [[ ! -z "${IP}" ]]; then
      break
    fi
  fi
done

# get os release
REL=`cat /etc/os-release | grep PRETTY_NAME | cut -d "\"" -f 2`

DF=`df -h | grep /dev/root | awk {'print $3 "B (Used) / " $2 "B (Total)"'}`
CPUTEMP=$((`cat /sys/class/thermal/thermal_zone0/temp`/1000*9/5+32))

# get the load averages
read one five fifteen rest < /proc/loadavg

/usr/bin/figlet `uname -n`
echo "$(tput setaf 2)
`date +"%A, %e %B %Y, %r"`
`uname -srmo`
${REL} $(tput setaf 1)

Uptime.............: ${UPTIME}
Memory.............: ${FREEMEM} MB (Free) / ${TOTMEM} MB (Total)
Storage............: ${DF}
Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
CPU Temperature....: ${CPUTEMP} F
Running Processes..: `ps ax | wc -l | tr -d " "`
IP Addresses.......: ${IP}

$(tput sgr0)"

#!/bin/bash 

openvpnPath=`which openvpn`
systemctlPath=`which systemctl`
pkillPath=`which pkill`

if [ $# -eq 1 ]
then
    output="$1"
else
    output="./openvpn"
fi

echo "%users ALL=(ALL) NOPASSWD: $openvpnPath" > "$output"
echo "%users ALL=(ALL) NOPASSWD: $systemctlPath * openvpn@*" >> "$output"
echo "%users ALL=(ALL) NOPASSWD: $pkillPath openvpn" >> "$output"

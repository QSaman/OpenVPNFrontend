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

echo "# Make sure the user is in the group wheel" > "$output"
echo "%wheel ALL=(ALL) NOPASSWD: $openvpnPath" >> "$output"
echo "%wheel ALL=(ALL) NOPASSWD: $systemctlPath * openvpn-client@*" >> "$output"
echo "%wheel ALL=(ALL) NOPASSWD: $pkillPath openvpn" >> "$output"

#!/bin/bash

#Copy this script to /usr/local/bin
#Usage:
#openvpn.sh daemon start client-udp
#openvpn.sh daemon stop
#openvpn.sh standalone client-udp

scriptName="$0"

function showUsage
{
    echo "Usage:"
    echo "$scriptName daemon start client-udp"
    echo "$scriptName daemon [stop/log]"
    echo "$scriptName standalone client-udp"
    exit 0
}

function checkVuze
{
    local vuzeProcess=`pgrep -f Azureus`
    if [ "$vuzeProcess" != "" ]
    then
      echo "Vuze instance is running. First close it then run openVPN"
      exit 1
    fi
}

function checkDeluge
{
    local delugeProcess=`pgrep -f deluge`
    if [ "$delugeProcess" != "" ]
    then
	echo "Deluge instance is running. First close it then run openvpn"
	exit 1
    fi	
}

function stop
{
    sudo systemctl stop openvpn@*.service
    journalctl -n 40 -b -f /usr/sbin/openvpn
}

function checkConfigFileName
{
    if [ ! -f /etc/openvpn/${1}.conf ] || [ "${1}" = "" ]
    then
        echo "Invalid argument ${1}. /etc/openvpn/${1}.conf doesn't exist."
        exit 1
    fi
}

function start
{
    checkConfigFileName "$1"
    process=`systemctl status openvpn@*.service | egrep -om 1 '\<openvpn@.+\.service\>'`

    if [ "$process" != "openvpn@${1}.service" ] && [ "$process" != "" ]
    then
        echo "Stopping all openvpn processes"
        sudo systemctl stop openvpn@*.service
    fi
    sudo systemctl start openvpn@${1}.service
    journalctl -n 40 -b -fu openvpn@${1}.service
}

function runAsDaemon
{
    if [ "$1" = "start" ]
    then
        checkDeluge
        checkVuze
        start "$2"
    elif [ "$1" = "stop" ]
    then
        stop
    elif [ "$1" = "log" ]
    then
        journalctl -n 40 -b -f /usr/sbin/openvpn        
    else
        if [ "$1" != "" ]
        then
            echo "Unrecognized argument $1"
        fi
        showUsage
    fi
}

function runAsStandalone
{
    checkConfigFileName "$1"
    checkDeluge
    checkVuze
    sudo /usr/sbin/openvpn --cd /etc/openvpn --config ${1}.conf
}

if [ "$1" = "daemon" ]
then
    runAsDaemon "$2" "$3"
elif [ "$1" = "standalone" ]
then
    runAsStandalone "$2"
else
    if [ "$1" != "" ]
    then
        echo "Unrecognized argument $1"
    fi
    showUsage
fi

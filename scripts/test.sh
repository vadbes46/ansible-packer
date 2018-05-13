#!/usr/bin/env bash

if ping -c 1 -q host1 &>/dev/null; then
    echo "ONLINE"
else
    echo "OFFLINE"
fi

host=$(ping -c 1 -W 1 192.168.15.14 2>/dev/null)
if [ -n "$host" ]; then
    echo -e "\t host exists"
else
    echo -e "\t host DOES NOT exist"
fi

exit 0

if [ -n "$(ls -A /etc/security/limits.d/ 2>/dev/null)" ]; then
    rm -rf /etc/security/limits.d/*
fi

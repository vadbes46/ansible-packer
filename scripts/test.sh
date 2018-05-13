#!/usr/bin/env bash

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

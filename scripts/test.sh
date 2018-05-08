#!/usr/bin/env bash

if [ -n "$(ls -A /etc/security/limits.d/ 2>/dev/null)" ]; then
    rm -rf /etc/security/limits.d/*
fi

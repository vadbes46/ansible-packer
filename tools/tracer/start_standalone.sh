#!/usr/bin/env bash

/data/ansible-packer/tools/tracer/standalone-linux --span-storage.type=memory --query.static-files=/data/ansible-packer/tools/tracer/ui/ --processor.jaeger-compact.server-host-port=192.168.15.15:6831 &> /data/logs/tracer.log

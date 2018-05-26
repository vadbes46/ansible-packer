#!/usr/bin/env bash

/data/ansible-packer/tools/tracer/bin/standalone-linux --span-storage.type=memory --query.static-files=/data/ansible-packer/tools/tracer/bin/ui/ --processor.jaeger-compact.server-host-port=192.168.15.15:6831 &> /data/logs/tracer.log

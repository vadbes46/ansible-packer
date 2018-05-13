#!/usr/bin/env bash

# could start from anywhere
cur_dir=$(pwd)
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ABSOLUTE_DIR=$(dirname "$ABSOLUTE_PATH")
cd "$ABSOLUTE_DIR"

# packer build -only=virtualbox-iso -on-error=ask box-centos.json
packer build -only=virtualbox-iso -force -on-error=ask box-centos.json
# packer build -debug -only=virtualbox-iso -force -on-error=ask box-centos.json

# cat ../.vagrantuser | ruby -r json -r yaml -e "print YAML.load(ARGF.read).to_json" > ../.vagrantuser.json
# packer validate box-centos.json
# packer build <(ruby -r json -r yaml -e "print YAML.load(ARGF.read).to_json" < ../.vagrantuser)

cd $cur_dir

exit 0


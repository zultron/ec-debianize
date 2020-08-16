#!/bin/bash -xe
#
# Configure EtherLab Master package builder Docker image
# `docker build --build-arg=SCRIPT_PRE_CMD=.github/docker/etherlabmaster_script_pre.sh`

# Install mercurial, needed by the `get_source.sh` script
apt-get update
apt-get install -y \
    mercurial
apt-get clean

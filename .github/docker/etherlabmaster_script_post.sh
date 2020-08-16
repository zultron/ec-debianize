#!/bin/bash -xe
#
# Configure EtherLab Master package builder Docker image
# `docker build --build-arg=SCRIPT_POST_CMD=.github/docker/etherlabmaster_script_post.sh`

# Calculate the kernel headers path and set `dpkg-buildpackage`
# configure flags in environment
HDR_PKG=$(dpkg-query -W | \
        sed -n 's/^\(linux-headers-[0-9.-]*-\(generic\|amd64\)\).*/\1/p')
tee /opt/environment/etherlabmaster_configure_flags.sh <<EOF
#!/bin/bash
export CONFFLAGS=--with-linux-dir=/usr/src/$HDR_PKG
EOF

# IgH EtherCAT Master Debian Packaging

This directory contain files that are needed to build a debian package
of the [IgH EtherCAT Master for Linux][ecm]. In contrast to IgH's
method to start the master via an init script (and unloading existing
standard ethernet drivers before statup), the config file
(`/etc/default/ethercat`) is used by a script named
`update-ethercat-config` that should be run after config changes. The
script updates `/etc/modules-load.d/ethercat.conf` and
`/etc/modprobe.d/ethercat.conf` to reflect the configuration so that
unneeded/unwanted standard drivers get blacklisted and the EtherCAT
drivers and master are automatically loaded at system startup with the
right parameters.

## Building

The build process was tested under Debian 10 (Buster) with RT-Kernel.

to build the packages:
```
# Install hg and mk-build-deps
sudo apt-get install devscripts equivs mercurial

# Checkout source and patches
./get_source.sh -a

# Install build dependencies and build the packages
cd etherlabmaster
sudo mk-build-deps -i
dpkg-buildpackage -uc -us
```

## Installing

Install packages:

```
sudo dpkg -i ethercat_<version>_<arch>.deb \
    etherlabmaster-tools_<version>_<arch>.deb \
    libethercat_<version>_<arch>.deb
```

After the required config settings in `/etc/default/ethercat` (see
documentation), run `sudo update-ethercat-config`.  Either reboot or
load the `ec_*` modules manually (see `/etc/modules`), and the master
should become functional.

To build the [LinuxCNC EtherCAT HAL driver][lcec], also install the
development package:

```
sudo dpkg -i ethercat-dev_<version>_<arch>.deb
```


## RTAI

Support for RTAI has been dropped.


[ecm]:  https://etherlab.org/en/ethercat/
[lcec]:  https://github.com/sittner/linuxcnc-ethercat

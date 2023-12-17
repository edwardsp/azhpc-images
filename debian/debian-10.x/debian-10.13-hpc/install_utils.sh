#!/bin/bash
set -ex

# Setup microsoft packages repository for moby
# Download the repository configuration package
curl https://packages.microsoft.com/config/debian/10/prod.list > ./microsoft-prod.list
# Copy the generated list to the sources.list.d directory
cp ./microsoft-prod.list /etc/apt/sources.list.d/
# Install the Microsoft GPG public key
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
cp ./microsoft.gpg /etc/apt/trusted.gpg.d/

# Need backports for Python 3.8
wget https://people.debian.org/~paravoid/python-all/unofficial-python-all.asc
mv unofficial-python-all.asc /etc/apt/trusted.gpg.d/
echo "deb http://people.debian.org/~paravoid/python-all buster main" | sudo tee /etc/apt/sources.list.d/python-all.list

#install apt pckages
AZCOPY_VERSION="10.16.2"
AZCOPY_RELEASE_TAG="release20221108"
$DEBIAN_COMMON_DIR/install_utils.sh ${AZCOPY_VERSION} ${AZCOPY_RELEASE_TAG}

apt-get update
apt-get install -y python3.8
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
# Failing on Debian 10.13
# apt-get -y install --reinstall python3-apt
apt remove -y python3-apt
apt install -y python3-apt

apt-get -y install python3-pip
DISTPACK=/usr/lib/python3/dist-packages
cp $DISTPACK/apt_pkg.cpython-37m-x86_64-linux-gnu.so $DISTPACK/apt_pkg.so
apt-get install -y libcairo2-dev
apt-get install -y python3-dev
apt-get install -y libpython3.8-dev
apt-get install -y libgirepository1.0-dev
#python3.8 -m pip install --ignore-installed PyGObject
apt-get install -y software-properties-common
# various packages for 10.13
apt-get install -y mdadm
apt-get install -y lvm2
apt-get install -y xfsprogs
apt-get install -y nfs-kernel-server -t buster-backports

# For networkd-dispatcher + unattended-upgrades services to work correctly. Specific to ubuntu 18.04
ln -sf  /usr/lib/python3/dist-packages/_dbus_glib_bindings.cpython-37m-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/_dbus_glib_bindings.so
ln -sf  /usr/lib/python3/dist-packages/_dbus_bindings.cpython-37m-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/_dbus_bindings.so
apt-get -y install libglib2.0-dev libdbus-1-3 libdbus-1-dev

sudo python3 -m  pip install meson ninja
sudo python3 -m pip install pgi dbus-python

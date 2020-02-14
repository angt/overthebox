#!/bin/sh

set -e

umask 0022
unset GREP_OPTIONS SED

OTB_HOST=${OTB_HOST:-$(curl -sS ipaddr.ovh)}
OTB_PORT=${OTB_PORT:-8000}
OTB_REPO=${OTB_REPO:-http://$OTB_HOST:$OTB_PORT/$OTB_PATH}

OTB_TARGET=${OTB_TARGET:-x86_64}
OTB_CONFIG=${OTB_CONFIG:-net-full nice-bb usb-full legacy}

OTB_PKGS="
glorytun jq curl
tc kexec ip-tiny vim-full
netcat htop iputils-ping
bmon bwm-ng screen mtr ss
strace tcpdump-mini ethtool
sysstat pciutils mini_snmpd dmesg
luci-ssl luci-theme-material
"

for i in $OTB_TARGET $OTB_CONFIG; do
	if [ ! -f "config/$i" ]; then
		echo "Config $i not found !"
		exit 1
	fi
done

rm -rf openwrt/bin openwrt/files openwrt/tmp
cp -rf root openwrt/files

cat >> openwrt/files/etc/banner <<EOF
-----------------------------------------------------
 VERSION:     $(git describe --tag --always)

 BUILD REPO:  $(git config --get remote.origin.url)
 BUILD DATE:  $(date -u)
-----------------------------------------------------
EOF

cat >> openwrt/files/etc/otb-version <<EOF
0.7-1
EOF

cat > openwrt/feeds.conf <<EOF
src-link packages $(readlink -f feeds/packages)
src-link luci $(readlink -f feeds/luci)
src-link routing $(readlink -f feeds/routing)
src-link extra $(readlink -f extra)
EOF

cat > openwrt/.config <<EOF
$(for i in $OTB_TARGET $OTB_CONFIG; do cat "config/$i"; done)
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="OverTheBox"
CONFIG_VERSION_REPO="$OTB_REPO"
CONFIG_VERSION_NUMBER="$(git describe --tag --always)"
CONFIG_VERSION_CODE="none"
$(for i in otb $OTB_PKGS; do echo "CONFIG_PACKAGE_$i=y"; done)
EOF

echo "Building for the target $OTB_TARGET"

cd openwrt

cp .config .config.keep
scripts/feeds clean
scripts/feeds update -a -f
# shellcheck disable=SC2086
scripts/feeds install -d y $OTB_PKGS
cp .config.keep .config

make defconfig
make "$@"

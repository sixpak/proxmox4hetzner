#!/usr/bin/env bash
################################################################################
# This is property of eXtremeSHOK.com
# You are free to use, modify and distribute, however you may not remove this notice.
# Copyright (c) Adrian Jon Kriel :: admin@extremeshok.com
################################################################################
#
# optimizers grabbed from : https://github.com/extremeshok/xshok-proxmox
#
# simple zfs-optimizer, useful after adding a zfs-pool
#
# Note: should be compatible with all debian based distributions
#
# License: BSD (Berkeley Software Distribution)
#
################################################################################
#
# Usage:
# curl -O https://raw.githubusercontent.com/sixpak/proxmox4hetzer/master/zfs/optimizezfs.sh && chmod +x optimizezfs.sh
# ./optimizezfs.sh poolname
#
################################################################################
#
#    THERE ARE  USER CONFIGURABLE OPTIONS IN THIS SCRIPT
#   ALL CONFIGURATION OPTIONS ARE LOCATED BELOW THIS MESSAGE
#
##############################################################

# Set the local
export LANG="en_US.UTF-8"
export LC_ALL="C"

poolname=${1}

echo "Optimising ${poolname}"
zfs set compression=on "${poolname}"
zfs set compression=lz4 "${poolname}"
zfs set primarycache=all "${poolname}"
zfs set atime=off "${poolname}"
zfs set relatime=off "${poolname}"
zfs set checksum=on "${poolname}"
zfs set dedup=off "${poolname}"
zfs set xattr=sa "${poolname}"

#check we do not already have a cron for zfs
if [ ! -f "/etc/cron.d/zfsutils-linux" ] ; then
  if [ -f /usr/lib/zfs-linux/scrub ] ; then
    cat <<'EOF' > /etc/cron.d/zfsutils-linux
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Scrub the pool every second Sunday of every month.
24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub
EOF
  else
    echo "Scrub the pool every second Sunday of every month ${poolname}"
    if [ ! -f "/etc/cron.d/zfs-scrub" ] ; then
      echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"  > "/etc/cron.d/zfs-scrub"
    fi
    echo "24 0 8-14 * * root [ \$(date +\\%w) -eq 0 ] && zpool scrub ${poolname}" >> "/etc/cron.d/zfs-scrub"
  fi
fi

zpool iostat -v "${poolname}" -L -T d

#script Finish
echo -e '\033[1;33m Finished....please restart the server \033[0m'

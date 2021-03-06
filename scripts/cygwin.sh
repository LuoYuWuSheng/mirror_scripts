#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Licensed under the GNU GPL (version 2)

source  `dirname $0`/functions.d/functions
# Filesystem locations for the sync operations
SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/cygwin"
SYNC_FILES="/srv/ftp/cygwin"
SYNC_LOCK="$SYNC_HOME/cygwin.lck"
#SYNC_SERVER="rsync://mirrors6.ustc.edu.cn/cygwin/"
SYNC_SERVER="rsync://ftp.ipv6.heanet.ie/pub/cygwin/"
LOG_FILE="cygwin_$(date +%Y%m%d-%H).log"

STAT_FILE="$SYNC_HOME/status/cygwin"
# Do not edit the following lines, they protect the sync from running more than
# one instance at a time
if [ ! -d $SYNC_HOME ]; then
  echo "$SYNC_HOME does not exist, please create it, then run this script again."
  exit 1
fi

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"
# End of non-editable lines

# Create the log file and insert a timestamp
touch "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
#starting rsync

set_stat $STAT_FILE "status" "-1"
set_stat $STAT_FILE "upstream" $SYNC_SERVER
rsync -6 -avz --delete-after --exclude *.~tmp~*  $SYNC_SERVER $SYNC_FILES >> $SYNC_LOGS/$LOG_FILE
set_stat $STAT_FILE "status" $?
set_stat $STAT_FILE "lastsync" "`date --rfc-3339=seconds|sed 's/\ /\\ /'`"
# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0

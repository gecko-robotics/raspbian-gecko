#!/bin/bash -e

# if [ -f "${ROOTFS_DIR}/etc/samba/smb.conf" ]; then
# 	mv ${ROOTFS_DIR}/etc/samba/smb.conf ${ROOTFS_DIR}/etc/samba/smb.bak
# fi

echo ">> "

cat <<EOF >${ROOTFS_DIR}/etc/samba/smb.conf
#======================= Global Settings =======================

[global]
   workgroup = WORKGROUP
   wins support = yes
   dns proxy = no

#### Debugging/Accounting ####
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d


####### Authentication #######

   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user

############ Misc ############

# Allow users who've been granted usershare privileges to create
# public shares, not just authenticated ones
   usershare allow guests = yes

#======================= Share Definitions =======================

[pi]
   comment = Home Directories
   browseable = yes
   read only = no
   create mask = 0700
   directory mask = 0700
   valid users = %S
   path=/home/%S
EOF

# smbpasswd -a pi
#systemctl --no-pager restart smbd
#systemctl --no-pager restart nmbd

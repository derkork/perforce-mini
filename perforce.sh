#!/bin/bash
set -e

# change user-id of perforce user to match the host user-id
usermod -u $PERFORCE_UID perforce
# change group-id of perforce group to match the host group-id
groupmod -g $PERFORCE_GID perforce

# if the perforce config file doesn't exist, run the config script
if [ ! -f /etc/perforce/p4dctl.conf.d/perforce.conf ]; then
    echo "No perforce config file found, running config script..."
    # copy saved perforce template config file
    cp /opt/perforce/p4d.template /etc/perforce/p4dctl.conf.d/p4d.template
    # generate a random master password
    echo "Generating random master password..."
    MASTER_PASSWORD=$(pwgen -s 32 1)
    echo "Master password: $MASTER_PASSWORD"
    /opt/perforce/sbin/configure-helix-p4d.sh $SERVER_ID -n -p ssl:$P4PORT -r $P4ROOT -u $MASTER_USER -P $MASTER_PASSWORD --unicode 
fi

# if there are no SSL certificates, generate them
export P4SSLDIR=$P4ROOT/root/ssl
if [ ! -f $P4SSLDIR/certificate.txt ]; then
    echo "No SSL certificates found, re-generating them..."
    su - perforce -c "export P4SSLDIR=$P4SSLDIR && p4d -Gc"
fi

chown -R perforce:perforce $P4ROOT
p4dctl start $SERVER_ID 
tail -F $P4ROOT/logs/log
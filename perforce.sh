#!/bin/bash
set -e

# error out if PERFORCE_UID or PERFORCE_GID is not set
if [ -z "$PERFORCE_UID" ]; then
    echo "PERFORCE_UID is not set"
    exit 1
fi

if [ -z "$PERFORCE_GID" ]; then
    echo "PERFORCE_GID is not set"
    exit 1
fi


# change user-id of perforce user to match the host user-id
usermod -o -u $PERFORCE_UID perforce
# change group-id of perforce group to match the host group-id
groupmod -o -g $PERFORCE_GID perforce

# if the perforce config file doesn't exist, run the config script
if [ ! -f /etc/perforce/p4dctl.conf.d/perforce.conf ]; then
    echo "No perforce config file found, running config script..."
    # copy saved perforce template config file
    cp /opt/perforce/p4d.template /etc/perforce/p4dctl.conf.d/p4d.template
    # generate a random master password
    echo "Generating random master password..."
    MASTER_PASSWORD=$(pwgen -s 32 1)
    echo "Master password: $MASTER_PASSWORD"
    /opt/perforce/sbin/configure-helix-p4d.sh ${SERVER_ID:-perforce} -n -p ssl:${P4PORT:-1666} -r ${P4ROOT:-/opt/perforce-data} -u ${MASTER_USER:-perforce-master} -P $MASTER_PASSWORD ${PERFORCE_SETUP_OPTS:---unicode} 
fi

# if there are no SSL certificates, generate them
export P4SSLDIR=${P4ROOT:-/opt/perforce-data}/root/ssl
if [ ! -f $P4SSLDIR/certificate.txt ]; then
    echo "No SSL certificates found, re-generating them..."
    su - perforce -c "export P4SSLDIR=$P4SSLDIR && p4d -Gc"
fi

chown -R perforce:perforce ${P4ROOT:-/opt/perforce-data}
p4dctl start ${SERVER_ID:-perforce} ${PERFORCE_SERVER_OPTS}
tail -F ${P4ROOT:-/opt/perforce-data}/logs/log
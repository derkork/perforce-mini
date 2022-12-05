FROM ubuntu:focal

# Update our main system

RUN apt-get update
RUN apt-get dist-upgrade -y

# Get some dependencies for adding apt repositories

RUN apt-get install -y wget gnupg pwgen

# Add perforce repo

RUN wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add -
RUN echo 'deb http://package.perforce.com/apt/ubuntu focal release' > /etc/apt/sources.list.d/perforce.list
RUN apt-get update

# Actually install it

RUN apt-get install -y helix-p4d

# Copy p4d.template to a safe place
RUN mkdir -p /opt/perforce/
RUN cp /etc/perforce/p4dctl.conf.d/p4d.template /opt/perforce/p4d.template

# Add our start script
ADD perforce.sh /opt/perforce/perforce.sh
RUN chmod a+x /opt/perforce/perforce.sh

CMD /opt/perforce/perforce.sh
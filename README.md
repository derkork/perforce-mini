# perforce-mini
A minimal Docker image to run Perforce without the hassle. This image will automatically configure the Perforce server, so it will run without any manual steps required. I have very little experience with Perforce and while this image works for me it may not be suitable for a professional environment. I have set it up to be simple and relatively secure, but please keep in mind that this is a hobby project. If you find any issues or have any suggestions please open an issue or a pull request.


## Running with `docker-compose`

To run this with `docker-compose` you can use a file like this:

```yaml
version: '3'
services:
  perforce:
    # The image to use.
    image: derkork/perforce-mini:latest
    restart: unless-stopped
    volumes:
      # This is where the configuration is stored. Create an empty folder and mount this.
      # When the container starts for the first time it will detect that no configuration
      # exists and will automatically configure Perforce. The configuration will then be stored
      # in the mounted folder.
      - ./p4dctl.conf.d:/etc/perforce/p4dctl.conf.d
      # Perforce's data directory. This is where all the data is stored. Again, create an empty
      # folder and mount it here. The container will automatically configure Perforce to use this
      # folder.
      - ./perforce-data:/perforce-data
    environment:
      # The port on which the Perforce server will listen. This is the default port.
      - P4PORT=1666
      # The root directory of the Perforce server. This is the default value. Make sure it matches
      # the volume mount above.
      - P4ROOT=/perforce-data
      # The server ID. You can change this to whatever you want.
      - SERVER_ID=perforce
      # This is the master user that will be created. The password for this user will be
      # randomly generated and printed to the console when the container starts. You can 
      # later change this password using the `p4 passwd` command.
      - MASTER_USER=perforce-master
      # The UID and GID of the user running the perforce server. While the container runs as
      # root, the perforce server itself will run as a non-priveleged user. This is the UID and
      # GID of that user. Make it match a user of the host system so that the files created by
      # the perforce server will be owned by that user. This is important so you can backup
      # the data directory on the host system.
      - PERFORCE_UID=1000
      - PERFORCE_GID=1000
    ports:
      # The port to expose. Make sure it matches the P4PORT environment variable.
      - 1666:1666
```

### Master user password

Since I didn't want to have an insecure default password, this container will create a random password for the master user. The password will be printed to the console when the container starts. You can change this password later using a perforce client.

```bash
perforce-perforce-1  | Generating random master password...
perforce-perforce-1  | Master password: yhkQP3hYrg5yns7d2EepV1fm9wAcEIGu
```

**This password will only be printed once**, so make sure to copy it somewhere safe. In case you lost the password, you can always delete the container and the contents of the `p4dctl.conf.d` folder and start over.

## SSL Certificates

On first start the Perforce initialization script will automatically generate an SSL certificate for the Perforce server. The certificate will be valid for 2 years. If the certificate expires, simply delete the `certificate.txt` and `privatekey.txt` files from `root/ssl` folder in the Perforce data directory and restart the container. The container will automatically generate a new certificate.

## Acknowledgements

- Thanks to Ari for making this [tutorial](https://aricodes.net/posts/perforce-server-with-docker/) which I used as a starting point for this image.
- Thanks to Polymoon Games for making this [tutorial](https://polymoon.net/blog/how-to-renew-perforce-ssl-certificate/) on how to refresh the SSL certificates for Perforce, which I used as a starting point to implement automatic certificate renewal.
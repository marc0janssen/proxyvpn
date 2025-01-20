# PROXYVPN

Stable

```shell
docker pull marc0janssen/proxyvpn:stable
```

## Application

[OpenVPN website](https://openvpn.net/)  

## Build notes

Latest stable Privoxy release from Arch Linux repo.  
Latest stable OpenVPN release from Arch Linux repo.  
Latest stable WireGuard release from Arch Linux repo.

## Usage

```shell
docker run -d \
    --cap-add=NET_ADMIN \
    --name=<container name> \
    -p 8118:8118
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=<yes|no> \
    -e VPN_USER=<vpn username> \
    -e VPN_PASS=<vpn password> \
    -e VPN_PROV=<pia|airvpn|custom> \
    -e VPN_CLIENT=<openvpn|wireguard> \
    -e VPN_OPTIONS=<additional openvpn cli options> \
    -e STRICT_PORT_FORWARD=<yes|no> \
    -e ENABLE_PRIVOXY=<yes|no> \
    -e LAN_NETWORK=<lan ipv4 network>/<cidr notation> \
    -e NAME_SERVERS=<name server ip(s)> \
    -e ADDITIONAL_PORTS=<port number(s)> \
    -e DEBUG=<true|false> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    marc0janssen/proxyvpn:stable
```

Please replace all user variables in the above command defined by <> with the correct values.

## PIA provider

PIA users will need to supply VPN_USER and VPN_PASS, optionally define VPN_REMOTE [list of gateways](https://www.privateinternetaccess.com/pages/client-support) if you wish to use another remote gateway other than the Netherlands.

## PIA example

```shell
docker run -d \
    --cap-add=NET_ADMIN \
    --name=proxyvpn \
    -p 8118:8118 \
    -v /root/docker/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_USER=myusername \
    -e VPN_PASS=mypassword \
    -e VPN_PROV=pia \
    -e VPN_CLIENT=openvpn \
    -e STRICT_PORT_FORWARD=no \
    -e ENABLE_PRIVOXY=yes \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e NAME_SERVERS=209.222.18.222,84.200.69.80,37.235.1.174,1.1.1.1,209.222.18.218,37.235.1.177,84.200.70.40,1.0.0.1 \
    -e ADDITIONAL_PORTS=1234 \
    -e DEBUG=false \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    marc0janssen/proxyvpn:stable
```

## AirVPN provider

AirVPN users will need to generate a unique OpenVPN configuration file by using the following [link](https://airvpn.org/generator/)

1. Please select Linux and then choose the country you want to connect to
2. Save the ovpn file to somewhere safe
3. Start the nzbgetvpn docker to create the folder structure
4. Stop nzbgetvpn docker and copy the saved ovpn file to the /config/openvpn/ folder on the host
5. Start nzbgetvpn docker
6. Check supervisor.log to make sure you are connected to the tunnel

## AirVPN example

```shell
docker run -d \
    --cap-add=NET_ADMIN \
    -p 6789:6789 \
    --name=nzbgetvpn \
    -v /root/docker/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_PROV=airvpn \
    -e VPN_CLIENT=openvpn \
    -e ENABLE_PRIVOXY=yes \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e NAME_SERVERS=209.222.18.222,84.200.69.80,37.235.1.174,1.1.1.1,209.222.18.218,37.235.1.177,84.200.70.40,1.0.0.1 \
    -e ADDITIONAL_PORTS=1234 \
    -e DEBUG=false \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    marc0janssen/proxyvpn:stable
```

## OpenVPN

Please note this Docker image does not include the required OpenVPN configuration file and certificates. These will typically be downloaded from your VPN providers website (look for OpenVPN configuration files), and generally are zipped.

PIA users - The URL to download the [OpenVPN](https://www.privateinternetaccess.com/openvpn/openvpn.zip) configuration files and certs is:-

Once you have downloaded the zip (normally a zip as they contain multiple ovpn files) then extract it to /config/openvpn/ folder (if that folder doesn't exist then start and stop the docker container to force the creation of the folder).

If there are multiple ovpn files then please delete the ones you don't want to use (normally filename follows location of the endpoint) leaving just a single ovpn file and the certificates referenced in the ovpn file (certificates will normally have a crt and/or pem extension).

## WireGuard

If you wish to use WireGuard (defined via 'VPN_CLIENT' env var value ) then due to the enhanced security and kernel integration WireGuard will require the container to be defined with privileged permissions and sysctl support, so please ensure you change the following docker options:-

from

```shell
    --cap-add=NET_ADMIN \
```

to

```shell
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --privileged=true \
```

PIA users - The WireGuard configuration file will be auto generated and will be stored in ```/config/wireguard/wg0.conf``` AFTER the first run, if you wish to change the endpoint you are connecting to then change the ```Endpoint``` line in the config file (default is Netherlands).

Other users - Please download your WireGuard configuration file from your VPN provider, start and stop the container to generate the folder ```/config/wireguard/``` and then place your WireGuard configuration file in there.

## Docker Compose Example

```Docker
version: "3"
services:
  nzbget:
    container_name: nzbget
    image: marc0janssen/proxyvpn:stable
    volumes:
      - /root/docker/config:/config
    ports:
      - 8118:8118
    environment:
      - STRICT_PORT_FORWARD=yes
      - PGID=1000
      - PUID=1000
      - VPN_PROV=pia
      - LAN_NETWORK=192.168.1.0/24
      - NAME_SERVERS=209.222.18.222,37.235.1.174,1.1.1.1,8.8.8.8,209.222.18.218,37.235.1.177,1.0.0.1,8.8.4.4
      - VPN_ENABLED=yes
      - VPN_USER=xxxx
      - VPN_PASS=xxxx
    restart: unless-stopped
```

## Notes

Due to Google and OpenDNS supporting EDNS Client Subnet it is recommended NOT to use either of these NS providers.
The list of default NS providers in the above example(s) is as follows:-

209.222.x.x = PIA
84.200.x.x = DNS Watch
37.235.x.x = FreeDNS
1.x.x.x = Cloudflare

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

`id <username>`

The ADDITIONAL_PORTS environment variable is used to define ports that might be required for scripts run inside the container, if you want to define multiple ports then please use a comma to separate values.
___

If you appreciate my work, then please consider buying binhex a beer  :D. He definitely did most of the work building the framework for this container.

[Support forum](http://lime-technology.com/forum/index.php?topic=38930)

Configuration
I use it on Linux for a site-to-site VPN connecting a local VLAN (on eth1) in the cloud to a remote on-premise network.

Necessary configuration: /etc/ipsec.d/ipsec.secrets /etc/ipsec.d/conf/<name>.conf Examples can be found here: https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2Examples

Usage
Example how to run: docker run --name strongswan --name strongswan --cap-add=NET_ADMIN,NET_RAW --net=host -v /etc/ipsec.d:/etc/ipsec.d mberner/strongswan:5.8.4

Afterwards, you will also have to set up a route for your Docker containers to be able to reach the remote LAN by having the correct source IP addr (the one from eth1): sudo iptables -t nat -I POSTROUTING -p all -s <Docker Subnet> -d <Remote Subnet> -j SNAT --to-source <Host Addr (eth1)>

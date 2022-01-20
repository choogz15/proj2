#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.30.30.1

## Currently no NAT
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 8080 -s 172.16.16.16 -j DNAT --to-destination 10.2.0.2
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 8080 -s 172.18.18.18 -j DNAT --to-destination 10.2.0.3

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.30.30.30 172.16.16.16 : PSK "Whqa9rmj12pF+cTZhKto/0lJ/50mFClZUbX3h0UbFXk=" >> /etc/ipsec.secrets
echo 172.30.30.30 172.18.18.18 : PSK "8WXy6xErrtUXLKXiM3GghS3GY3l1cg8GVNqOdj3JZCQ=" >> /etc/ipsec.secrets

cat << EOF > /etc/ipsec.conf
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

conn gatewaycloud-to-gatewaya
  type=tunnel
  authby=secret
  left=172.30.30.30
  leftsubnet=172.30.30.30/32
  right=172.16.16.16
  rightsubnet=172.16.16.16/32
  keyexchange=ikev2
  ike=aes256-sha2_256-modp1024!
  esp=aes256-sha2_256!
  keyingtries=0
  ikelifetime=1h
  lifetime=8h
  dpddelay=30
  dpdtimeout=120
  dpdaction=restart
  auto=start

conn gatewaycloud-to-gatewayb
  type=tunnel
  authby=secret
  left=172.30.30.30
  leftsubnet=172.30.30.30/32
  right=172.18.18.18
  rightsubnet=172.18.18.18/32
  keyexchange=ikev2
  ike=aes256-sha2_256-modp1024!
  esp=aes256-sha2_256!
  keyingtries=0
  ikelifetime=1h
  lifetime=8h
  dpddelay=30
  dpdtimeout=120
  dpdaction=restart
  auto=start
EOF

ipsec restart
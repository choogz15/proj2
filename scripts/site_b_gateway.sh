#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.18.18.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.16.18.18 172.30.30.30 : PSK "8WXy6xErrtUXLKXiM3GghS3GY3l1cg8GVNqOdj3JZCQ=" >> /etc/ipsec.secrets

cat << EOF > /etc/ipsec.conf
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

conn gatewayb-to-gatewaycloud
  type=tunnel
  authby=secret
  left=172.18.18.18
  leftsubnet=172.18.18.18/32
  right=172.30.30.30
  rightsubnet=172.30.30.30/32
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
#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.30.30.1

## Currently no NAT
# iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

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
  leftsubnet=10.2.0.0/16
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
  leftsubnet=10.2.0.0/16
  right=172.18.18.18
  rightsubnet=10.1.0.0/16
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
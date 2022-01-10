#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.16.16.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.16.16.16 172.30.30.30 : PSK "Whqa9rmj12pF+cTZhKto/0lJ/50mFClZUbX3h0UbFXk=" >> /etc/ipsec.secrets

cat << EOF > /etc/ipsec.conf
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

conn gatewaya-to-gatewaycloud
  type=tunnel
  authby=secret
  left=172.16.16.16
  leftsubnet=172.16.16.16/32
  right=172.30.30.30
  rightsubnet=10.2.0.0/16
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

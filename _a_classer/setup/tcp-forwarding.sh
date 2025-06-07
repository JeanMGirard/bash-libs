#!/bin/sh

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
echo "AllowTcpForwarding yes" | sudo tee -a /etc/ssh/sshd_config


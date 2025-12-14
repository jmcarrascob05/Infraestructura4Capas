#!/bin/bash

set -e

sleep 7

echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf >/dev/null
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null

apt-get update -y
apt-get install -y haproxy

cat > /etc/haproxy/haproxy.cfg << 'EOF'
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 10s
    timeout client  1h
    timeout server  1h

frontend mariadb_frontend
    bind *:3306
    mode tcp
    default_backend mariadb_backend

backend mariadb_backend
    mode tcp
    balance roundrobin
    option tcp-check
    tcp-check connect
    server db1Juanma 192.168.40.10:3306 check inter 5s rise 2 fall 3
    server db2Juanma 192.168.40.11:3306 check inter 5s rise 2 fall 3

listen stats
    bind *:8080
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
    stats auth admin:admin
EOF

systemctl enable haproxy
systemctl restart haproxy

sleep 5
systemctl status haproxy --no-pager || true

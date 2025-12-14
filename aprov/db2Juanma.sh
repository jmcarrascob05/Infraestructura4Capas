#!/bin/bash

set -e

sleep 7

echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf >/dev/null
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client galera-4 rsync

systemctl stop mariadb

cat > /etc/mysql/mariadb.conf.d/60-galera.cnf << 'EOF'
[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so

wsrep_cluster_name="galera_cluster"
wsrep_cluster_address="gcomm://192.168.40.10,192.168.40.11"

wsrep_sst_method=rsync

wsrep_node_address="192.168.40.11"
wsrep_node_name="db2Juanma"
EOF

systemctl start mariadb
sleep 15

systemctl status mariadb --no-pager || true
systemctl enable mariadb

mysql -e "SHOW STATUS LIKE 'wsrep_%';" | grep -E "(wsrep_cluster_size|wsrep_cluster_status|wsrep_ready|wsrep_connected)" || true

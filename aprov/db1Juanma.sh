#!/bin/bash

sleep 5

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

wsrep_node_address="192.168.40.10"
wsrep_node_name="db1Juanma"
EOF

galera_new_cluster
sleep 15

systemctl status mariadb --no-pager || true

mysql << 'EOSQL'
CREATE DATABASE IF NOT EXISTS lamp_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'juanma'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON lamp_db.* TO 'juanma'@'%';

CREATE USER IF NOT EXISTS 'haproxy'@'%' IDENTIFIED BY '';
GRANT USAGE ON *.* TO 'haproxy'@'%';

CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

SELECT User, Host FROM mysql.user
  WHERE User IN ('juanma', 'haproxy', 'root');
EOSQL

systemctl enable mariadb
mysql -e "SHOW STATUS LIKE 'wsrep_cluster_size';" 2>/dev/null || true

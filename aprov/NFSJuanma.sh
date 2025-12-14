#!/bin/bash

sleep 5

echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf >/dev/null
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null

apt-get update -qq
apt-get install -y git
apt-get install -y nfs-kernel-server
apt-get install -y php-fpm php-mysql php-curl php-gd php-mbstring \
php-xml php-xmlrpc php-soap php-intl php-zip netcat-openbsd net-tools

mkdir -p /var/www/html/webapp
chown -R www-data:www-data /var/www/html/webapp
chmod -R 755 /var/www/html/webapp

cat > /etc/exports << 'EOF'
/var/www/html/webapp 192.168.20.10(rw,sync,no_subtree_check,no_root_squash)
/var/www/html/webapp 192.168.20.15(rw,sync,no_subtree_check,no_root_squash)
EOF

exportfs -ra
systemctl restart nfs-kernel-server
systemctl enable nfs-kernel-server

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 9000|' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i 's|;listen.allowed_clients.*|listen.allowed_clients = 192.168.20.10,192.168.20.15|' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

systemctl restart php${PHP_VERSION}-fpm
systemctl enable php${PHP_VERSION}-fpm

sleep 3
netstat -tlnp | grep 9000 || true

MAX_ATTEMPTS=60
ATTEMPT=0
while [ ${ATTEMPT} -lt ${MAX_ATTEMPTS} ]; do
  if nc -z 192.168.30.10 3306 2>/dev/null; then
    echo "Base de datos disponible"
    break
  fi
  ATTEMPT=$((ATTEMPT + 1))
  sleep 5
done

rm -rf /var/www/html/webapp/*
rm -rf /tmp/lamp

git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/lamp
cp -r /tmp/lamp/src/* /var/www/html/webapp/

cat > /var/www/html/webapp/config.php << 'EOF'
<?php
$mysqli = new mysqli("192.168.30.10", "juanma", "1234", "lamp_db");
if ($mysqli->connect_error) {
    die("Error de conexion: " . $mysqli->connect_error);
}
$mysqli->set_charset("utf8mb4");
?>
EOF

chown -R www-data:www-data /var/www/html/webapp
chmod -R 755 /var/www/html/webapp

rm -rf /tmp/lamp
ls -lh /var/www/html/webapp/

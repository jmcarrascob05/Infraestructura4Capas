#!/bin/bash

sleep 5

echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf >/dev/null
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null

apt-get update -y
apt-get install -y nginx

cat > /etc/nginx/sites-available/balancer << 'EOF'
upstream web_pool {
    server 192.168.20.10:80 max_fails=3 fail_timeout=30s;
    server 192.168.20.15:80 max_fails=3 fail_timeout=30s;
}

server {
    listen 80 default_server;
    server_name _;

    access_log /var/log/nginx/balancer_access.log;
    error_log  /var/log/nginx/balancer_error.log;

    location / {
        proxy_pass http://web_pool;

        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_connect_timeout 60s;
        proxy_send_timeout    60s;
        proxy_read_timeout    60s;
    }

    location /healthcheck {
        access_log off;
        add_header Content-Type text/plain;
        return 200 "ok\n";
    }
}
EOF

ln -sf /etc/nginx/sites-available/balancer /etc/nginx/sites-enabled/balancer
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx
systemctl enable nginx

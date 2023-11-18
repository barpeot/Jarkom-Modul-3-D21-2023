#!/bin/bash

apt-get update
apt-get install nginx apache2-utils php php-fpm -y

server=$" upstream myweb  {
        server 10.32.3.1:80;
        server 10.32.3.2:80;
        server 10.32.3.3:80;
 }

 server {
     listen 81;
        #least_conn;
        #ip_hash;
        #hash \$request_uri consistent;


     allow 10.32.3.69;
     allow 10.32.3.70;
     allow 10.32.4.167;
     allow 10.32.4.168;
     deny all;
     server_name granz.channel.d21.com;

     location / {
            proxy_pass http://myweb;
            proxy_set_header    X-Real-IP \$remote_addr;
            proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header    Host \$http_host;

            auth_basic \"Login untuk Mengakses Konten\";
            auth_basic_user_file /etc/nginx/rahasiakita;
     }

    location /its {
            proxy_pass https://www.its.ac.id/;
            proxy_set_header    X-Real-IP \$remote_addr;
            proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header    Host \$http_host;

   }
 }"

echo "$server" > "/etc/nginx/sites-available/granz.channel.d21.com"

ln -s /etc/nginx/sites-available/granz.channel.d21.com /etc/nginx/sites-enabled

rm /etc/nginx/sites-enabled/default

server2=$' upstream laravel  {
       least_conn;
         server 10.32.4.1:8001;
        server 10.32.4.2:8002;
        server 10.32.4.3:8003;
 }

 server {
     listen 80;
     server_name riegel.canyon.d21.com;

     location / {
            proxy_pass http://laravel;
     }

     location /frieren {
            proxy_bind 10.32.2.1;
            proxy_pass http://10.32.4.1:8001/index.php;
     }

     location /flamme {
            proxy_bind 10.32.2.1;
            proxy_pass http://10.32.4.2:8002/index.php;
     }

     location /fern/{
            proxy_bind 10.32.2.1;
            proxy_pass http://10.32.4.3:8003/index.php;
     }

 }'

echo "$server2" > "/etc/nginx/sites-available/riegel.canyon.d21.com"

ln -s /etc/nginx/sites-available/riegel.canyon.d21.com /etc/nginx/sites-enabled

htpasswd -bc /etc/nginx/rahasiakita netics ajkd21

service php7.3-fpm start

service nginx restart
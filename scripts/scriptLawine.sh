#!/bin/bash

apt-get update
apt-get install php nginx wget unzip php-fpm -y

wget --no-check-certificate "https://drive.google.com/u/0/uc?id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1&export=download" -O "granz.zip"

unzip -o "granz.zip"

rm -r /var/www/modul-3

mv modul-3 /var/www/modul-3

service="
server {

        listen 80;

        root /var/www/modul-3;

        index index.php;
        server_name granz.channel.d21.com;

        location / {
                        try_files \$uri \$uri/ /index.php?\$query_string;
        }

        # pass PHP scripts to FastCGI server
        location ~ .php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        }

 location ~ /.ht {
                        deny all;
        }

}
"

echo "$service" >  "/etc/nginx/sites-available/granz.channel.d21.com"

ln -s /etc/nginx/sites-available/granz.channel.d21.com /etc/nginx/sites-enabled

rm /etc/nginx/sites-enabled/default

service php7.3-fpm start

service nginx restart
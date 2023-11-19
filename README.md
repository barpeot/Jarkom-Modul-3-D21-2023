# Jarkom-Modul-3-D21-2023

# Anggota Kelompok:
+ Akbar Putra Asenti Priyanto (5025211004)
+ Farrela Ranku Mahhissa (5025211129)

## Soal 0
Pada soal ini diminta untuk melakukan register domain berupa riegel.canyon.yyy.com untuk worker Laravel dan granz.channel.yyy.com untuk worker PHP  mengarah pada worker yang memiliki IP [prefix IP].x.1.

- Pertama, pastikan ```bind9``` sudah terinstal di Heiter, kemudian untuk registrasi domain dilakukan pada Heiter dengan menambahkan setting berikut:

### Untuk granz.channel.d21.com

```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     granz.channel.d21.com. root.granz.channel.d21.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@               IN      NS      granz.channel.d21.com.
@               IN      A       10.32.2.1
www             IN      CNAME   granz.channel.d21.com.
```

disimpan di /etc/bind/jarkom/granz.channel.d21.com

### Untuk riegel.canyon.d21.com

```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     riegel.canyon.d21.com. root.riegel.canyon.d21.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@               IN      NS      riegel.canyon.d21.com.
@               IN      A       10.32.2.1
www             IN      CNAME   riegel.canyon.d21.com.
```

disimpan di /etc/bind/jarkom/riegel.canyon.d21.com

### named.conf.local
Tidak lupa untuk menambahkan zone untuk kedua domain di /etc/bind/named.conf.local di Heiter.

```
zone \"granz.channel.d21.com\" {
        type master;
        file \"/etc/bind/jarkom/granz.channel.d21.com\";
};

zone \"riegel.canyon.d21.com\" {
        type master;
        file \"/etc/bind/jarkom/riegel.canyon.d21.com\";
};
```

Untuk kedua domain akan diarahkan menuju Load Balancer Eisen dengan IP 10.32.2.1

## Soal 1
Lakukan konfigurasi sesuai dengan peta yang sudah diberikan.

![Topologi_1](/assets/1_topologi.png)

## Soal 2 - 5

2. Semua CLIENT harus menggunakan konfigurasi dari DHCP Server. 

- Untuk menyelesaikan soal ini kita perlu melakukan setup pada DHCP server, yaitu Himmel
```
#!/bin/bash

apt update
apt install isc-dhcp-server -y

default="
DHCPDv4_CONF=/etc/dhcp/dhcpd.conf

INTERFACESv4="eth0"
INTERFACESv6=""
"

echo "$default" > "/etc/default/isc-dhcp-server"

dhcpd="
subnet 10.32.1.0 netmask 255.255.255.0 {
    option routers 10.32.1.0;
}

...

subnet x.x.x.x netmask x.x.x.0 {
    option routers x.x.x.x;
}

"
echo "$dhcpd" > "/etc/dhcp/dhcpd.conf"

service isc-dhcp-server restart
```

Agar dapat menggunakan DHCP, untuk setiap device kecuali Himmel perlu mengubah setting network configuration menjadi sebagai berikut:

```
auto eth0
iface eth0 inet dhcp
```

Untuk network configuration dapat diakses dengan klik kanan device > edit network configuration.

Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.16 - [prefix IP].3.32 dan [prefix IP].3.64 - [prefix IP].3.80

- Untuk menyelesaikan soal ini kita perlu menambahkan baris pada /etc/dhcp/dhcpd.conf milik Himmel menjadi sebagai berikut:

```
subnet 10.32.3.0 netmask 255.255.255.0 {
    range 10.32.3.16 10.32.3.32;
    range 10.32.3.64 10.32.3.80;
    option routers 10.32.3.0;
}

```

3. Client yang melalui Switch4 mendapatkan range IP dari [prefix IP].4.12 - [prefix IP].4.20 dan [prefix IP].4.160 - [prefix IP].4.168 (3)

- Sama seperti sebelumnya, tetapi kita menambahkan baris untuk subnet 10.32.4.0 pada /etc/dhcp/dhcpd.conf di Himmel.

```
subnet 10.32.4.0 netmask 255.255.255.0 {
    range 10.32.4.12 10.32.4.20;
    range 10.32.4.160 10.32.4.168;
    option routers 10.32.4.0;
}

```

4. Client mendapatkan DNS dari Heiter dan dapat terhubung dengan internet melalui DNS tersebut.

- Agar client dapat terhubung ke internet, perlu dilakukan ip forwarding pada Heiter menuju IP NAT, yaitu 192.168.122.1, hal ini dilakukan dengan menambah baris berikut di /etc/bind/named.conf.options milik Heiter:

```
options {
        directory "/var/cache/bind";

        forwarders {
              192.168.122.1;
        };

        //dnssec-validation auto;
        allow-query{any;};

        listen-on-v6 { any; };
};
```

5. Lama waktu DHCP server meminjamkan alamat IP kepada Client yang melalui Switch3 selama 3 menit sedangkan pada client yang melalui Switch4 selama 12 menit. Dengan waktu maksimal dialokasikan untuk peminjaman alamat IP selama 96 menit.

- Untuk memberikan lease time tertentu kepada Client, dapat diatur dengan menambahkan ```min-lease-time, default-lease-time, dan max-lease-time``` di DHCP Server Himmel pada subnet 10.32.3.0 dan 10.32.4.0

```
subnet 10.32.3.0 netmask 255.255.255.0 {
    range 10.32.3.16 10.32.3.32;
    range 10.32.3.64 10.32.3.80;
    option routers 10.32.3.0;
    min-lease-time 180;
    default-lease-time 180;
    max-lease-time 5760;
}

subnet 10.32.4.0 netmask 255.255.255.0 {
    range 10.32.4.12 10.32.4.20;
    range 10.32.4.160 10.32.4.168;
    option routers 10.32.4.0;
    min-lease-time 720;
    default-lease-time 720;
    max-lease-time 5760;
}
```

6. Pada masing-masing worker PHP, lakukan konfigurasi virtual host untuk website berikut dengan menggunakan php 7.3.

- Terdapat tiga buah worker PHP, yaitu Lawine, Linie, dan Lugner. Konfigurasi website akan dihandle oleh nginx dan php-fpm. Maka dari itu, pertama-tama perlu dilakukan instalasi kedua servis tersebut beserta servis-servis lain yang mungkin dibutuhkan.

```
apt-get update
apt-get install php nginx wget unzip php-fpm -y
```
Selanjutnya, lakukan download resource website dan simpan di root document yang diinginkan, dalam hal ini akan disimpan di /var/www/modul-3
```
wget --no-check-certificate "https://drive.google.com/u/0/uc?id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1&export=download" -O "granz.zip"

unzip -o "granz.zip"

rm -r /var/www/modul-3

mv modul-3 /var/www/modul-3

```
Kemudian dilakukan setup website granz.channel.d21.com dengan menggunakan port 80 di nginx.

```
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
```
Untuk menjalankan website hanya perlu menjalankan servis php-fpm dan nginx
```
service php7.3-fpm start

service nginx restart
```
Setup website granz.channel.d21.com ini secara identik dilakukan di ketiga worker PHP, yaitu Lawine, Linie, dan Lugner.

Selanjutnya perlu dilakukan setup pada load balancer, yaitu Eisen.

```
apt-get update
apt-get install nginx apache2-utils php php-fpm -y
```
Sama dengan worker, Eisen akan menggunakan nginx dan php untuk setup website granz.channel.d21.com

```
server=$" upstream myweb  {
        server 10.32.3.1:80;
        server 10.32.3.2:80;
        server 10.32.3.3:80;
 }

 server {
     listen 81;
     server_name granz.channel.d21.com;

     location / {
            proxy_pass http://myweb;
     }
 }"

echo "$server" > "/etc/nginx/sites-available/granz.channel.d21.com"

ln -s /etc/nginx/sites-available/granz.channel.d21.com /etc/nginx/sites-enabled

rm /etc/nginx/sites-enabled/default

service php7.3-fpm start

service nginx restart
```

Untuk mengecek dapat dengan melakukan ```lynx granz.channel.d21.com``` di client setelah semua worker dan load balancer telah berjalan.

![lynx](/assets/6_lynx.png)

## Soal 7

Aturlah agar Eisen dapat bekerja dengan maksimal, lalu lakukan testing dengan 1000 request dan 100 request/second.

- Untuk mengetes Eisen sebanyak 1000 request dan 100 request/second, dapat dilakukan dengan command ```ab -n 1000 -c 100 http://granz.channel.d21.com:81```. Selain itu, dalam testing Eisen ini akan diimplementasikan algoritma Load Balancer berupa weighted round robin dengan ketentuan Lawine weight = 4, Linie weight = 2, dan Lugner weight = 1. Caranya adalah dengan memodifikasi setting pada Eisen:

```
upstream myweb  {
        server 10.32.3.1:80 weight=4;
        server 10.32.3.2:80 weight=2;
        server 10.32.3.3:80 weight=1;
 }
```

Sehingga didapat hasil sebagai berikut

![ab](/assets/7_ab1.png)

![ab_2](/assets/7_ab2.png)

## Soal 8

Karena diminta untuk menuliskan grimoire, buatlah analisis hasil testing dengan 200 request dan 10 request/second masing-masing algoritma Load Balancer.

- Sama seperti sebelumnya, testing dilakukan dengan menggunakan command ```ab -n 200 -c 10 http://granz.channel.d21.com:81``` kali ini dibedakan algoritma yang digunakan dengan cara mengubah setting pada Eisen. Adapun hasilnya adalah sebagai berikut:

### Weighted Round Robin
Setup Eisen adalah sebagai berikut:

```
upstream myweb  {
        server 10.32.3.1:80 weight=4;
        server 10.32.3.2:80 weight=2;
        server 10.32.3.3:80 weight=1;
}

```

Hasil:

![wrr](/assets/8_wrr1.png)
![wrr2](/assets/8_wrr2.png)

### Weighted Round Robin = 125,76 Request/Second

### Least Connection
Setup Eisen adalah sebagai berikut:

```
upstream myweb  {
        server 10.32.3.1:80;
        server 10.32.3.2:80;
        server 10.32.3.3:80;
}

 server {
     listen 81;
     least_conn;

     server_name granz.channel.d21.com;

     location / {
            proxy_pass http://myweb;
            proxy_set_header    X-Real-IP \$remote_addr;
            proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header    Host \$http_host;

     }
}
```

Hasil:

![lc](/assets/8_lc1.png)
![lc2](/assets/8_lc2.png)

### Least Connection = 145,2 Request/Second

### IP Hash
Setup Eisen adalah sebagai berikut:

```
upstream myweb  {
        server 10.32.3.1:80;
        server 10.32.3.2:80;
        server 10.32.3.3:80;
 }

server {
     listen 81;
     ip_hash;

     server_name granz.channel.d21.com;

     location / {
            proxy_pass http://myweb;
            proxy_set_header    X-Real-IP \$remote_addr;
            proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header    Host \$http_host;

     }
}
```

Hasil:

![iph](/assets/8_iph1.png)
![iph2](/assets/8_iph2.png)

### IP Hash = 202,51 Request/Second

### Generic Hash
Setup Eisen adalah sebagai berikut:

```
upstream myweb  {
        server 10.32.3.1:80;
        server 10.32.3.2:80;
        server 10.32.3.3:80;
 }

 server {
     listen 81;
     hash \$request_uri consistent;

     server_name granz.channel.d21.com;

     location / {
            proxy_pass http://myweb;
            proxy_set_header    X-Real-IP \$remote_addr;
            proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header    Host \$http_host;

     }
}
```

Hasil:

![gh](/assets/8_gh1.png)
![gh2](/assets/8_gh2.png)

### Generic Hash = 171,06 Request/Second

Grafik:

![grafik](/assets/8_grafik.png)

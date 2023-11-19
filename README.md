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

Agar dapat menggunakan DHCP, untuk setiap host kecuali Himmel perlu mengubah setting network configuration menjadi sebagai berikut:

```
auto eth0
iface eth0 inet dhcp
```

Jika sebuah host ingin menggunakan konfigurasi statis, maka dapat dilakukan dengan command ```ip a``` pada host tersebut, kemudian menyimpan nilai hardware ethernet yang ditampilkan pada interface ethernet yang digunakan.

![ether](/assets/0_ether.png)

Di gambar yang digunakan adalah link/ether milik interface eth0 dari Heiter.

Selanjutnya menyimpan nilai hardware ethernet tersebut di DHCP Server dengan menambahkan 
```
host <Nama Host> {
    hardware ethernet < xx:xx:xx:xx:xx:xx >;
    fixed-address <IP Host>;
    default-lease-time 43200;
    max-lease-time 43200;
}
```

Kemudian pada network configuration perlu menambahkan baris di bawah ini:

```
auto eth0
iface eth0 inet dhcp
hwaddress ether < xx:xx:xx:xx:xx:xx >
```

Untuk network configuration dapat diakses dengan klik kanan host > edit network configuration.

Perlu juga dilakukan setup pada DHCP Relay yaitu Aura menjadi sebagai berikut:

```
#!/bin/bash

apt update
apt install isc-dhcp-relay -y

relayconf="
SERVERS=\"10.32.1.2\"

INTERFACES=\"eth1 eth2 eth3 eth4\"

OPTIONS=\"\"
"

echo "$relayconf" > "/etc/default/isc-dhcp-relay"
```

Sesuaikan relayconf dengan ip dari DHCP server, sedangkan INTERFACES perlu disesuaikan dengan Interface yang digunakan oleh DHCP Relay untuk menghubungkan antar host.

```
sysctl="
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
#net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#

###################################################################
# Magic system request Key
# 0=disable, 1=enable all, >1 bitmask of sysrq functions
# See https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
# for what other values do
#kernel.sysrq=438
"

echo "$sysctl" > "/etc/sysctl.conf"

service isc-dhcp-relay restart
```

Kemudian di sysctl.conf milik Aura perlu uncomment baris ```net.ipv4.ip_forward=1``` agar bisa melakukan ip forwarding untuk IPv4.

Berikut contoh DHCP lease yang berhasil dijalankan untuk sebuah host static Heiter.

![dhcplease](/assets/0_dhcplease.png)

3. Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.16 - [prefix IP].3.32 dan [prefix IP].3.64 - [prefix IP].3.80

- Untuk menyelesaikan soal ini kita perlu menambahkan baris pada /etc/dhcp/dhcpd.conf milik Himmel menjadi sebagai berikut:

```
subnet 10.32.3.0 netmask 255.255.255.0 {
    range 10.32.3.16 10.32.3.32;
    range 10.32.3.64 10.32.3.80;
    option routers 10.32.3.0;
}

```

Selanjutnya perlu setting network configuration pada client menjadi sebagai berikut:

```
auto eth0
iface eth0 inet dhcp
```

Cek DHCP lease dengan menggunakan client dari switch3, yaitu Revolte dan Richter.

![dhcpleaseRevolte](/assets/3_dhcpleaseRevolte.png)
![dhcpleaseRichter](/assets/3_dhcpleaseRichter.png)

3. Client yang melalui Switch4 mendapatkan range IP dari [prefix IP].4.12 - [prefix IP].4.20 dan [prefix IP].4.160 - [prefix IP].4.168 (3)

- Sama seperti sebelumnya, tetapi kita menambahkan baris untuk subnet 10.32.4.0 pada /etc/dhcp/dhcpd.conf di Himmel.

```
subnet 10.32.4.0 netmask 255.255.255.0 {
    range 10.32.4.12 10.32.4.20;
    range 10.32.4.160 10.32.4.168;
    option routers 10.32.4.0;
}

```

Selanjutnya perlu setting network configuration pada client menjadi sebagai berikut:

```
auto eth0
iface eth0 inet dhcp
```

Cek DHCP lease dengan menggunakan client dari switch4, yaitu Sein dan Stark.

![dhcpleaseSein](/assets/3_dhcpleaseSein.png)
![dhcpleaseStark](/assets/3_dhcpleaseStark.png)

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

Jangan lupa untuk client perlu setup /etc/resolv.conf menuju Heiter.

```
echo 'nameserver < ip Heiter>' > /etc/resolv.conf
```

Untuk mengecek dapat dilakukan dengan ```ping google.com```

![ping](/assets/4_ping.png)

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

Hasil pada switch3:
![dhcpleaseRevolte](/assets/3_dhcpleaseRevolte.png)

Hasil pada switch4:
![dhcpleaseSein](/assets/3_dhcpleaseSein.png)

## Soal 6

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

## Soal 9

Cukup dengan mencoba satu per satu sesuai kondisi yang diminta soal, kemudian lakukan benchmarking dengan
```
ab -n 100 -c 10 http://granz.channel.d21.com:81/
```

### 3 Worker, RPS = 171,21

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/3281d2f0-8a4d-430a-b963-24e088c5a630)

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/e8c210a8-6f1a-4e3c-8f37-b0c70abe8cd1)

### 2 Worker, RPS = 167,8

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/de50a909-7820-4f7c-bed0-e2189a3e0629)

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/225943ab-5f38-41e0-a90f-f3f0276f79f1)


### 1 Worker, RPS = 113,94

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/f6d1498e-a15d-446b-bc72-928165478285)

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/c0eb2c0f-97d2-4a8b-b448-7af1a278b8b8)


### Grafik

![image](https://github.com/barpeot/Jarkom-Modul-3-D21-2023/assets/114351382/87c0110e-005a-45bb-b187-a14fdb563ea8)


Semakin sedikit worker yang bekerja, maka akan semakin sedikit pula request per second nya, menunjukkan bahwa request akan semakin terpusat dan menurunkan kapasitas request yang dapat diterima.

## Soal 10

Tambahkan konfigurasi autentikasi di LB dengan dengan kombinasi username: “netics” dan password: “ajkyyy”, dengan yyy merupakan kode kelompok. Terakhir simpan file “htpasswd” nya di /etc/nginx/rahasisakita/

- Ubah setting website granz.channel.d21.com di Eisen menjadi demikian:

```
location / {
    proxy_pass http://myweb;
    proxy_set_header    X-Real-IP \$remote_addr;
    proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header    Host \$http_host;

    auth_basic \"Login untuk Mengakses Konten\";
    auth_basic_user_file /etc/nginx/rahasiakita;
}
```

Kemudian untuk menambah password dapat menggunakan command ```htpasswd``` milik apache2-utils

```
htpasswd -bc /etc/nginx/rahasiakita netics ajkd21
```

Selanjutnya cek dengan ```lynx http://granz.channel.d21.com:81``` pada client

![htpasswd](/assets/10_htpasswd.png)

## Soal 11

Buat untuk setiap request yang mengandung /its akan di proxy passing menuju halaman https://www.its.ac.id

- Tambahkan location /its di granz.channel.d21.com pada Eisen kemudian proxy_pass ke https://www.its.ac.id

```
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
```

Untuk pengecekan dapat dilakukan dengan ```lynx http://granz.channel.d21.com:81/its``` di client.

![its1](/assets/11_its1.png)

![its2](/assets/11_its2.png)

## Soal 12

Selanjutnya LB ini hanya boleh diakses oleh client dengan IP [Prefix IP].3.69, [Prefix IP].3.70, [Prefix IP].4.167, dan [Prefix IP].4.168

- Untuk menyelesaikan soal ini, perlu menambahkan ```allow [IP]``` pada LB Eisen untuk setiap IP yang ditentukan kemudian ```deny all``` untuk IP selain IP tersebut.

```
server {
     listen 81;

     allow 10.32.3.69;
     allow 10.32.3.70;
     allow 10.32.4.167;
     allow 10.32.4.168;
     deny all;
     server_name granz.channel.d21.com;

location / {
    ...
}

location /its {
    ...
}
...
}
```

Untuk pengecekan dapat dilakukan dengan ```lynx http://granz.channel.d21.com:81/``` di client.

Contoh jika ip address tidak diterima (10.32.4.17)
![forbidden](/assets/12_forbidden.png)

Contoh jika ip address tidak diterima (10.32.4.167)
![allowed](/assets/12_allowed.png) 

## Soal 13

Semua data yang diperlukan, diatur pada Denken dan harus dapat diakses oleh Frieren, Flamme, dan Fern.

- Denken merupakan database server yang mengatur worker Laravel berupa Frieren, Flamme, dan Fern. Berikut adalah script dari Denken.

```
#!/bin/bash

apt update
apt install mariadb-server -y
```
Pertama-tama perlu menginstal mariadb-server untuk sebagai databasenya.

```
mycnf=$"
[client-server]

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
skip-networking=0
skip-bind-address
"

echo "$mycnf" > "/etc/mysql/my.cnf"

service mysql start

```
Selanjutnya menambahkan setting pada /etc/mysql/my.cnf untuk memperbolehkan worker dalam mengakses Denken.

```
mysql -u root -e\
  "CREATE USER 'kelompokd21'@'%' IDENTIFIED BY '';"

mysql -u root -e\
  "CREATE USER 'kelompokd21'@'localhost' IDENTIFIED BY '';"

mysql -u root -e\
  "CREATE DATABASE jarkomd21;"

mysql -u root -e\
  "GRANT ALL PRIVILEGES ON *.* TO 'kelompokd21'@'%';"

mysql -u root -e\
  "GRANT ALL PRIVILEGES ON *.* TO 'kelompokd21'@'localhost';"

mysql -u root -e\
  "FLUSH PRIVILEGES;"
```

Kemudian buka mysql dan membuat user baru berupa ```kelompokd21``` dan juga database ```jarkomd21``` yang akan digunakan oleh worker.

## Soal 14

Frieren, Flamme, dan Fern memiliki Riegel Channel sesuai dengan quest guide berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer

- Ketiga worker diatas merupakan worker Laravel, maka untuk setup website riegel.canyon.d21.com perlu dilakukan konfigurasi Laravel.

```
#!/bin/bash

apt update
apt install mariadb-client -y
apt install lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 -y

curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg

sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt update

apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y

apt-get install nginx -y

wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer

rm composer.phar
```
Pertama-tama perlu dilakukan instalasi semua servis yng akan digunakan pada worker Laravel, seperti ```mariadb-client, php, nginx, dan composer```

```
apt-get install git -y

git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git

mv "laravel-praktikum-jarkom" "/var/www/"

server='
server {

    listen <PORT>;

    root /var/www/laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;
    server_name riegel.canyon.d21.com;

    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    }

location ~ /\.ht {
            deny all;
    }

}
'

echo "$server" > "/etc/nginx/sites-available/laravel-praktikum-jarkom"
```

Selanjutnya dilakukan clone github sesuai dengan projek yang diberikan pada soal dan dipindah ke root folder ```/var/www/laravel-praktikum-jarkom/``` adapun server nginx akan melakukan deploy dari ```/var/www/laravel-praktikum-jarkom/public```. \<PORT
\> disini disesuaikan untuk setiap worker Laravel.

```
cd /var/www/laravel-praktikum-jarkom

composer update
composer install

cp .env.example .env

ln -s /etc/nginx/sites-available/laravel-praktikum-jarkom /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/storage
```

Selanjutnya dilakukan ```composer update & composer install``` pada projek Laravel serta symbolic link dari ```/etc/nginx/sites-available/laravel-praktikum-jarkom``` menuju ```/etc/nginx/sites-enabled/``` agar dapat deploy server.

Selain itu juga mengubah ```/var/www/laravel-praktikum-jarkom/storage``` menjadi milik ```www-data.www-data```

```
envi=$'
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=10.32.2.2
DB_PORT=3306
DB_DATABASE=jarkomd21
DB_USERNAME=kelompokd21
DB_PASSWORD=

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
'

echo "$envi" > "/var/www/laravel-praktikum-jarkom/.env"
```

Selanjutnya perlu dilakukan konfigurasi .env file pada ```/var/www/laravel-praktikum-jarkom/``` dengan menyesuaikan section database agar sesuai dengan setting database di Denken:

```
DB_CONNECTION=mysql
DB_HOST=10.32.2.2
DB_PORT=3306
DB_DATABASE=jarkomd21
DB_USERNAME=kelompokd21
DB_PASSWORD=
```

Kemudian dilakukan migrasi dan seeding database dengan command ```php artisan migrate:fresh & php artisan db:seed --class=AiringsTableSeeder```.

Selain itu juga perlu menjalankan command ```php artisan jwt:secret & php artisan key:generate``` agar projek Laravel dapat berjalan.

```
rm -r ~/laravel-praktikum-jarkom

php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan jwt:secret
php artisan key:generate

service php8.0-fpm start
service nginx restart
```
Lalu perlu menjalankan php-fpm dan nginx untuk deploy server.

Terakhir perlu juga dilakukan konfigurasi server riegel.canyon.d21.com pada Load Balancer Eisen.

```
server2=$' upstream laravel  {
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
 }'

echo "$server2" > "/etc/nginx/sites-available/riegel.canyon.d21.com"

ln -s /etc/nginx/sites-available/riegel.canyon.d21.com /etc/nginx/sites-enabled

service php7.3-fpm start

service nginx restart
```

Untuk mengecek deployment dari server dapat dilakukan dengan ```lynx riegel.canyon.d21.com``` di client.

![riegel](/assets/14_riegel.png) 

Cek juga database yang telah dibuat di Denken.

![jarkomd21](/assets/14_jarkomd21.png) 

## Soal 15

## Soal 16

## Soal 17

## Soal 18

Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur Riegel Channel maka implementasikan Proxy Bind pada Eisen untuk mengaitkan IP dari Frieren, Flamme, dan Fern.

- Untuk mengimplementasikan Proxy Bind pada setiap worker, dapat dilakukan di Eisen dengan menambahkan lokasi baru untuk setiap worker. Lalu melakukan proxy_pass menuju IP dari worker tersebut.

```
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
```
Untuk mengecek deployment dari server dapat dilakukan dengan ```lynx riegel.canyon.d21.com/< nama worker >``` di client.

![frieren](/assets/18_frieren.png) 

## Soal 19

## Soal 20

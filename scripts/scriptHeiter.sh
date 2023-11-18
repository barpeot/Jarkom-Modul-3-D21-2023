!/bin/bash

apt update
apt install bind9 -y

zone1="zone \"granz.channel.d21.com\" {
        type master;
        file \"/etc/bind/jarkom/granz.channel.d21.com\";
};"

echo "$zone1" > "/etc/bind/named.conf.local"

mkdir /etc/bind/jarkom

cp "/etc/bind/db.local" "/etc/bind/jarkom/granz.channel.d21.com"

bind1=';
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
'


echo "$bind1" > "/etc/bind/jarkom/granz.channel.d21.com"

zone2="zone \"riegel.canyon.d21.com\" {
        type master;
        file \"/etc/bind/jarkom/riegel.canyon.d21.com\";
};"

echo "$zone2" >> "/etc/bind/named.conf.local"

bind2=';
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
'


echo "$bind2" > "/etc/bind/jarkom/riegel.canyon.d21.com"


options='
options {
        directory "/var/cache/bind";

        forwarders {
              192.168.122.1;
        };

        //dnssec-validation auto;
        allow-query{any;};

        listen-on-v6 { any; };
};
'

echo "$options" > "/etc/bind/named.conf.options"

service bind9 restart
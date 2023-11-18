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

subnet 10.32.2.0 netmask 255.255.255.0 {
    option routers 10.32.2.0;
}

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

host Eisen {
    hardware ethernet e2:e6:b0:65:02:c3;
    fixed-address 10.32.2.1;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Denken {
    hardware ethernet 72:ad:2b:e6:68:36;
    fixed-address 10.32.2.2;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Lawine {
    hardware ethernet 4e:b4:ea:0a:ff:34;
    fixed-address 10.32.3.1;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Linie {
    hardware ethernet 2a:8b:24:a4:c8:f8;
    fixed-address 10.32.3.2;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Lugner {
    hardware ethernet be:37:a5:ab:bc:5d;
    fixed-address 10.32.3.3;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Frieren {
    hardware ethernet ee:32:c0:ee:f6:89;
    fixed-address 10.32.4.1;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Flamme {
    hardware ethernet f6:e3:ff:75:ae:06;
    fixed-address 10.32.4.2;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Fern {
    hardware ethernet 4a:3f:6e:a6:81:8d;
    fixed-address 10.32.4.3;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Heiter {
    hardware ethernet a2:36:d5:96:fd:eb;
    fixed-address 10.32.1.1;
    default-lease-time 43200;
    max-lease-time 43200;
}

host Himmel {
    hardware ethernet 5a:89:79:72:a0:1d;
    fixed-address 10.32.1.2;
    default-lease-time 43200;
    max-lease-time 43200;
}

"

echo "$dhcpd" > "/etc/dhcp/dhcpd.conf"

service isc-dhcp-server restart
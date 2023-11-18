#!/bin/bash

apt update
apt install lynx apache2-utils curl -y

echo '{
 "username": "kelompokd21",
 "password": "passwordd21"
}
' > data.json
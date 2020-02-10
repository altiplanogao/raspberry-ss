#!/bin/bash

#work on ubuntu 18.04. 
#Details: https://shadowsocks.org/en/download/servers.html

if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
fi

# export CONFIG_FILE

apt update
apt install -y shadowsocks-libev

if [ ！ -f "/etc/shadowsocks-libev/config.json.bk" ]; then
  mv /etc/shadowsocks-libev/config.json /etc/shadowsocks-libev/config.json.bk
(
cat <<'EOF'
{
    "server":"0.0.0.0",
    "server_port":8388,
    "password":"jadGakbew",
    "timeout":60,
    "method":"aes-256-cfb"
}
EOF
) > /etc/shadowsocks-libev/config.json
fi

systemctl restart shadowsocks-libev
systemctl enable shadowsocks-libev
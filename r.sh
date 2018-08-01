#!/bin/bash
chuli()
{
port=`grep server_port $1 | cut -d':' -f2 | cut -d',' -f1`
passwd=`grep password $1 | cut -d'"' -f4`
}

dir1="/root/.shadowsocks/"
dir2="/root/shadowsocksr/shadowsocks"

cd $dir1

allfiles=`ls -a .shadowsocks_*.pid`

for f in $allfiles
do
g=`echo $f | sed s/.pid/.conf/`
chuli $g
if [ -z "$all" ];then
all=$port:$passwd
else
all=$all,$port:$passwd
fi
done

#echo $all

rm -f $dir2/ss80.json
cat << EOF >$dir2/ss80.json 
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "80":{"password":"whatthefuck@.@", "protocol":"auth_aes128_sha1", "protocol_param": "2#$all", "obfs":"http_simple", "obfs_param":""},
        "8080":{"password":"whatthefuck@.@", "protocol":"auth_aes128_sha1", "protocol_param": "2#$all", "obfs":"http_simple", "obfs_param":""}
    },
    "timeout":600,
    "method":"chacha20",
    "protocol": "auth_sha1_compatible",
    "protocol_param": "",
    "obfs": "http_simple_compatible",
    "obfs_param": "",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": true,
    "workers": 1
}
EOF


#在这里自己添加重启SSR的命令
supervisorctl restart ssr

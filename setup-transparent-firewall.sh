#!/bin/bash
#Reference: https://www.bjwf125.com/?p=9

export CHINA_IPS_FILE_1=/etc/shadowsocks/cn_ips_1
export CHINA_IPS_FILE_2=/etc/shadowsocks/cn_ips_2
export CHINA_IPS_FILE=$CHINA_IPS_FILE_2
export IPS_CN=ips_cn
export NETFILTER_FILE_CHINA_IPSET=/etc/shadowsocks/netfilter-ipset.china
export NETFILTER_FILE_SS_IPTABLES=/etc/shadowsocks/netfilter-iptables.ss

here=`dirname $0`
this_dir=`readlink -e $here`
res_dir=${this_dir}/res

. ${this_dir}/config
[ -f ${this_dir}/.config ] && source ${this_dir}/.config

function fetch_china_ips(){
  echo "Download from http://f.ip.cn"
  curl 'http://f.ip.cn/rt/chnroutes.txt' \
    | egrep -v '^$|^#' > china-ips.txt && \
    mv china-ips.txt ${CHINA_IPS_FILE_1}
  echo "Download from http://ftp.apnic.net"
  curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' \
    | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > china-ips2.txt && \
    mv china-ips2.txt ${CHINA_IPS_FILE_2}
}

function netfilter_clear_pre_setting(){
  echo "[NETFILTER] clear setting"
  iptables -t nat -D POSTROUTING -s 192.168/16 -j MASQUERADE

  iptables -t nat -D PREROUTING -s 192.168/16 -j SHADOWSOCKS
  iptables -t nat -D OUTPUT  ! -p icmp -j SHADOWSOCKS

  iptables -t nat -F SHADOWSOCKS
  iptables -t nat -X SHADOWSOCKS
  ipset destroy ${IPS_CN}
}

function netfilter_build_china_ipset(){
  echo "[NETFILTER] build china ipset"
  sudo ipset -N ${IPS_CN} hash:net
  local ipset_file="./ipset.sh"

  rm ${ipset_file} 2>/dev/null
  for i in `cat ${CHINA_IPS_FILE}`;
    do echo ipset -A ${IPS_CN} $i >> ${ipset_file}
    # do echo ipset -A ${IPS_CN} $i
  done
  chmod +x ${ipset_file}
  echo "Apply ipset file"
  ./${ipset_file}
  rm ./${ipset_file}
}

function netfilter_build_iptables(){
  echo "[NETFILTER] build iptables"
  # enable iptable rules
  iptables -t nat -N SHADOWSOCKS

  iptables -t nat -A SHADOWSOCKS -d 0/8 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 127/8 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 10/8 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 169.254/16 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 172.16/12 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 192.168/16 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 224/4 -j RETURN
  iptables -t nat -A SHADOWSOCKS -d 240/4 -j RETURN

  iptables -t nat -A SHADOWSOCKS -d $SS_SERVER_ADDR -j RETURN

  iptables -t nat -A SHADOWSOCKS -m set --match-set ${IPS_CN} dst -j RETURN

  iptables -t nat -A SHADOWSOCKS ! -p icmp -j REDIRECT --to-ports $SS_REDIR_LOCAL_PORT

  iptables -t nat -A OUTPUT ! -p icmp -j SHADOWSOCKS
}

function enable_forward_stuff(){
  # enable ipv4 ip_forward
  forward_on=`cat /proc/sys/net/ipv4/ip_forward`
  if [[ $forward_on"" == "0" ]] ; then
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p
  fi

  iptables -t nat -A PREROUTING -s 192.168/16 -j SHADOWSOCKS
  iptables -t nat -A POSTROUTING -s 192.168/16 -j MASQUERADE
}

function netfilter_save_conf(){
  echo "[NETFILTER] save config"
  ipset save > ${NETFILTER_FILE_CHINA_IPSET}
  iptables-save > ${NETFILTER_FILE_SS_IPTABLES}

  restore_dest=/etc/network/if-up.d/iptables-restore
  cp ${res_dir}/iptables-restore.sh ${restore_dest}
  chown root:root ${restore_dest}
  chmod 0755 ${restore_dest}

  save_dest=/etc/network/if-down.d/iptables-save
  cp ${res_dir}/iptables-save.sh ${save_dest}
  chown root:root ${save_dest}
  chmod 0755 ${save_dest}
}

function build_iptables(){
  netfilter_build_china_ipset
  netfilter_build_iptables
  enable_forward_stuff
  netfilter_save_conf
}

function dns_use_localhost(){
  # Set localhost as dns server
  sed -i 's|^nameserver|#nameserver|' /etc/resolv.conf
  sed -i '/^#nameserver 127\.0\.0\.1$/d' /etc/resolv.conf
  echo "nameserver 127.0.0.1" >> /etc/resolv.conf
}
function dns_use_default(){
  # Set localhost as dns server
  sed -i '/^nameserver 127\.0\.0\.1$/d' /etc/resolv.conf
  sed -i 's|^#nameserver|nameserver|' /etc/resolv.conf
}

function config_service(){
  modules=(shadowsocks-redir shadowsocks-tunnel shadowsocks-chinadns)
  for m in ${modules[*]}
  do
    dest_sf=/usr/lib/systemd/system/${m}.service
    cp ${res_dir}/${m}.service ${dest_sf}
    chown root:root ${dest_sf}

    jsonf_tpl=${res_dir}/${m}.json.tpl
    if [[ -f $jsonf_tpl ]]; then
      jsonf=/etc/shadowsocks/${m}.json
      cp $jsonf_tpl $jsonf
      sed -i 's|ph_ss_server_addr|'$SS_SERVER_ADDR'|' $jsonf
      sed -i 's|ph_ss_server_port|'$SS_SERVER_PORT'|' $jsonf
      sed -i 's|ph_ss_method|'$SS_METHOD'|' $jsonf
      sed -i 's|ph_ss_password|'$SS_PASSWORD'|' $jsonf
      sed -i 's|ph_ss_redir_local_port|'$SS_REDIR_LOCAL_PORT'|' $jsonf
      sed -i 's|ph_ss_tunnel_tunnel_addr|'$SS_TUNNEL_TUNNEL_ADDR'|' $jsonf
    fi
  done
}

function enable_services(){
  systemctl daemon-reload
  modules=(shadowsocks-redir shadowsocks-tunnel shadowsocks-chinadns)
  for m in ${modules[*]}
  do
  	sn=${m}.service
    if [[ $1"" == "disable" ]] ; then
      systemctl disable ${sn}
      systemctl stop ${sn}
    else
      systemctl enable ${sn}
      systemctl restart ${sn}
    fi
  done
}

function disable_transparent_proxy(){
  netfilter_clear_pre_setting
  dns_use_default
  enable_services disable
}

function enable_transparent_proxy(){
  disable_transparent_proxy
  # fetch_china_ips
  build_iptables
  dns_use_localhost
  config_service
  enable_services
}

mkdir workdir
pushd workdir
  if [[ $1"" == "disable" ]] ; then
    disable_transparent_proxy
  else
    enable_transparent_proxy
  fi
popd




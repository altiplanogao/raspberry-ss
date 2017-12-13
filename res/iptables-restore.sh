#!/bin/bash

NETFILTER_FILE_FOR_IPSET=/etc/netfilter-setting/ipset.dump
NETFILTER_FILE_FOR_IPTABLES=/etc/netfilter-setting/iptables.dump

date
ls -la /etc/netfilter-setting

/sbin/ipset restore < ${NETFILTER_FILE_FOR_IPSET}
/sbin/iptables-restore < ${NETFILTER_FILE_FOR_IPTABLES}

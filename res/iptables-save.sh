#!/bin/bash

NETFILTER_FILE_FOR_IPSET=/etc/netfilter-setting/ipset.dump
NETFILTER_FILE_FOR_IPTABLES=/etc/netfilter-setting/iptables.dump

if [[ ! -d  /etc/netfilter-setting ]] ; then
	mkdir /etc/netfilter-setting 2>/dev/null
	chown root:root /etc/netfilter-setting
	chmod 0755 /etc/netfilter-setting
fi

/sbin/ipset save > ${NETFILTER_FILE_FOR_IPSET}
/sbin/iptables-save > ${NETFILTER_FILE_FOR_IPTABLES}

date
ls -la /etc/netfilter-setting
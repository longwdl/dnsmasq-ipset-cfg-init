#!/bin/bash

gHost="127.0.0.1"
gPort="53"
gIpset="ss_rules_dst_forward"

InitIpset() {
	printf "ipset=/%s/%s\n" "$1" "$gIpset"
}

InitServer() {
	printf "server=/%s/%s#%d\n" "$1" "$gHost" "$gPort"
}

Usage() {
	cat <<-EOF
		Usage: $0 OPTION... FILE...
		Init dnsmasq config from specified domain list.

		  -d      dns host, use '$gHost' as default'
		  -p      dns port, use '$gPort' as default
		  -s      ipset name, use '$gIpset' as default
	EOF
}

while getopts "d:p:s:h" opt; do
	case "${opt}" in
	d)
		gHost=${OPTARG}
		;;
	p)
		gPort=${OPTARG}
		;;
	s)
		gIpset=${OPTARG}
		;;
	h)
		Usage
		exit
		;;
	\?)
		Usage >&2
		exit 1
		;;
	esac
done
shift $((OPTIND-1))

# Read host from file
while [ "X$1" != "X" ]; do
	_file="$1"
	shift

	if [ ! -f "$_file" ]; then
		printf "%s: cannot open '%s' for reading: No such file or directory\n" "$0" "$_file" >&2
		continue
	fi

	while read -r _domain; do
		[ "X$gHost" != "X" ] && InitServer "$_domain"
		InitIpset "$_domain"
	done < "$_file"
done

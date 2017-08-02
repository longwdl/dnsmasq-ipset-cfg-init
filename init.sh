#!/bin/bash

gHost=
gPort=53

InitIpset() {
	printf "ipset=/%s/ss_spec_list\n" "$1"
}

InitServer() {
	printf "server=/%s/%s#%d\n" "$1" "$gHost" "$gPort"
}

Usage() {
	printf "Usage: %s OPTION... FILE...\n" "$0"
	printf "Init dnsmasq config from specified domain list.\n\n"
	printf "  -d      dns server host, such as '8.8.8.8'\n"
	printf "  -p      dns server port, such as '53'\n"
}

while getopts "d:p:h" opt; do
	case "${opt}" in
	d)
		gHost=${OPTARG}
		;;
	p)
		gPort=${OPTARG}
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

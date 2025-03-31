#!/bin/bash

# asnblocker ver 0.1 
# by Irek 'Monsoft' Pelech (c) 2023
# 
# Require curl, jq and grep
#

# https://ipinfo.io/ API token
TOKEN="Blocked for policy reasons"

# SMTP response message
SMTP_DENY_MESSAGE="Bye"

# SMTP deny code
SMTP_DENY_CODE="550"


# File with ASN numbers to block
ASN_CONF_DIR="/opt"
ASN_FILE=${ASN_CONF_DIR}/asnblocker/asn_list.txt

# Functions
check_commands () {
	if ! command -v $1 &> /dev/null; then
		echo "$1 could not be found. Please install $1"
		exit 1
	fi
}

# Check if curl & jq are installed
check_commands curl

# Load variables passed by Postfix
while read attr; do
	[ -z "$attr" ] && break
	eval $attr
done

if [ -z $client_address ]; then
	echo "No variables passed by Postfix"
	exit 1
fi

if [ ! -f "${ASN_FILE}" ]; then 
	echo "File ${ASN_FILE} not found"
	exit 1
else
	if [ ! -s "${ASN_FILE}" ]; then
		echo "File ${ASN_FILE} is empty"
		exit 1
	fi
fi

IP_ASN=$(curl -s "http://ipinfo.io/${client_address}/org?token=$TOKEN" | cut -d " " -f1)

if [[ ! ${IP_ASN} =~ "AS" ]]; then
	echo "Unable to fetch ASN number. Please check ipinfo.io website"
	exit 1
fi

# Modified grep to ignore lines beginning with # in the ASN_FILE so entries could be commented out 
grep ${IP_ASN} ${ASN_FILE} | grep "^[^#]" > /dev/null

if [ $? -eq 0 ]; then
	# We are denying access
	echo "action=${SMTP_DENY_CODE} ${SMTP_DENY_MESSAGE} ${IP_ASN}"
	echo ""
else
	# We are allowing access
	echo "action=dunno"
	echo ""
fi

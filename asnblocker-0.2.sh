#!/bin/bash

# asnblocker ver 0.2 
# by Irek 'Monsoft' Pelech (c) 2023-2024
# Updated by Juppers in 2024 (Many THANKS !!!) to use dig and cut and alternative provider
# https://www.team-cymru.com/ip-asn-mapping DNS lookup instead of ipinfo.io 
# No API token or registration required and can handle high volumes of queries

# Require dig, cut, and grep
#

# SMTP response message
SMTP_DENY_MESSAGE="Blocked for policy reasons"

# SMTP deny code
SMTP_DENY_CODE="550"

# File with ASN numbers to block
ASN_CONF_DIR="/opt"
ASN_FILE=${ASN_CONF_DIR}/asnblocker/asn_list.txt

# Functions
reverseip () {
    local IFS
    IFS=.
    set -- $1
    echo $4.$3.$2.$1
}

check_commands () {
        if ! command -v $1 &> /dev/null; then
                echo "$1 could not be found. Please install $1"
                exit 1
        fi
}

# Check if dig and cut are installed
check_commands dig
check_commands cut
check_commands grep 

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

reversed=$(reverseip $client_address)

# Prepend "AS", cut first field from dig results then drop leading ". Adjusted cut to handle 2-byte and 4-byte AS Numbers
IP_ASN="AS$(dig +short ${reversed}.origin.asn.cymru.com TXT | cut -d "|" -f1 | cut --b 2-11)"

# Because of prepending AS above, not sure if this really does anything, but it doesn't hurt so it stayed
if [[ ! ${IP_ASN} =~ "AS" ]]; then
        echo "Unable to fetch ASN number."
        exit 1
fi

# Ignore lines beginning with # in the ASN_FILE so entries could be commented out 
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
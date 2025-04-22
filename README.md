# ASN Blocker for Postfix SMTP server #

This is very simple plugin for Postfix SMTP server to block access to service from IPs that are propagated by listed ASN (Autonomous system) numbers.

This script use [ipinfo.io](https://ipinfo.io/) API with free account. If you run busy SMTP server, you may be required to buy paid plan.

## Why this plugin has been created ##

I'm running small smtp server to host my personal emails. Since two months, my server is daily bombarded by connection from Spam Servers hosted by LayerHost and company doesn't reacted to any abuse notification. I know, that blocking entire network block belongs to hosting company may be drastic, but it works for me and may works for you.

## Versions of plugin ##

Currently we have two versions of this plugin:
* asnblocker.sh - use data from [ipinfo.io](https://ipinfo.io/) API. Thanks to @JaroslavHerber for version without`jq`
* asnblocker-0.2.sh - use `dig` as source of data. Updated by Juppers in 2024 (Many THANKS !!!)

## Installation & configuration ##
1. Clone repository to `/opt` directory.
2. Instal curl application on your system:

Debian/Ubuntu

```bash
sudo apt install -y curl
```
or 
```bash
sudo apt install -y curl dnsutils
```

Red Hat/CentOs/Rocky Linux/AlmaLinux 8,9
```bash
sudo dnf install -y curl
```
or
```bash
sudo dnf install -y curl bind-utils
```

3. Create account in [ipinfo.io](https://ipinfo.io/) and copy API token.
4. Modify TOKEN variable in `asnblocker.sh` script.
5. Add list of ASN numbers (one number per line) to `asn_list.txt` file.
6. Add below lines to the end of Postfix master.cf file:

```text
asnblocker   unix  -       n       n       -       0       spawn
  user=asnblocker argv=/opt/asnblocker/asnblocker.sh
```

7. Add below line to Postfix main.cf file under `smtpd_client_restrictions` :

```text
smtpd_client_restrictions = 
  ...
  check_policy_service unix:private/asnblocker
```

8. Crete system user & group:

```bash
sudo adduser --quiet --system --group --no-create-home --home /nonexistent asnblocker
```

9. Restart postfix service by running command `systemctl restart postfix`
10. Check your Postfix logs

# Obtaining AS number #

The easiest way to get AS number of network which you want to block is by using whois service:

```bash
whois ip_address |grep "^OriginAS:"

OriginAS:       ASxxxxx
```

or you can use websites like [https://who.is](https://who.is)

# ANS Blocker for Postfix SMTP server #

This is very simple plugin for Postfix SMTP server to block access to service from IPs that are propagated by listed ASN (Autonomous system) numbers.

This script use [ipinfo.io](https://ipinfo.io/) API with free account. If you run busy SMTP server, you may be required to buy paid plan.

### Installation ###

1. Clone repository to `/opt` directory.
2. Instal curl and jq application on your system:

Debian/Ubuntu

```bash
sudo apt install -y curl jq
```

Red Hat/CentOs 7

```bash
sudo yum install -y curl jq
```

Red Hat/CentOs/Rocky Linux/AlmaLinux 8
```bash
sudo dnf install -y curl jq
```

3. Create account in [ipinfo.io](https://ipinfo.io/) and copy API token.
4. Modify TOKEN variable in `asnblocker.sh` script.
5. Add list of ASN numbers (one number per line) to asn_list.txt file.
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

# Update Hosts Script

To use this, simply modify the top of this script and put in your own hostnames and MAC addresses, and run it as root.

The script looks-up MAC addresses using `arp` then relates them to the hostnames you provided, and updates your hosts file.

```
$ sudo update-hosts.pl
```
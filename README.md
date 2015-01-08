# Update Hosts Script

By using this script, you can store your list of unchanging machines' MAC addresses, and give them a name. Run this script and your computer will do the lookup and save you some time. Your computer will then know your device by name instead of just its IP address. No more will you have to type `http://192.168.gobbldey.poop`, just `http://blakestv`.

To use this, simply modify the top of this script and put in your own hostnames and MAC addresses, and run it as root.

The script looks-up MAC addresses using `arp` then relates them to the hostnames you provided, and updates your hosts file.

```
$ sudo update-hosts.pl
```

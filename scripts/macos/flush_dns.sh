networksetup -getdnsservers Wi-Fi | while read dns; do
  dnscacheutil -flushcache
done
ipconfig set en0 DHCP


# -------------------------------------------------------------------------------------------------------------------- #
# BASE
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kaikim.ru>
# @license    MIT
# @version    0.1.0
# @link       https://netcfg.ru/ru/2023/12/0f3478b3-9fde-59aa-a424-ff160431fa35/
# -------------------------------------------------------------------------------------------------------------------- #
# Set MAC:
# /interface ethernet set [find default-name="ether1"] mac-address="00:00:00:00:00:00"
# -------------------------------------------------------------------------------------------------------------------- #

# Users.
:local rosAdminPass "pa$$word"
:local rosUserPass "pa$$word"

# Bridge.
:local rosBridgeName "bridge1"
:local rosBridgeMinPort 2
:local rosBridgeMaxPort 5

# Router name.
:local rosRouterName "GW1"

# Static gateway name.
:local rosGwDomain "gw1.lan"

# Network domain name.
:local rosNwDomain "home.lan"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

/interface bridge
add name=$rosBridgeName add-dhcp-option82=yes dhcp-snooping=yes

/interface list
add name=WAN
add name=LAN
add name=GRE

/interface bridge port
:for i from=$rosBridgeMinPort to=$rosBridgeMaxPort do={
  add bridge=$rosBridgeName interface=("ether" . $i)
}

/interface list member
add interface=ether1 list=WAN
add interface=$rosBridgeName list=LAN

/ipv6 settings
set disable-ipv6=yes

/ip ipsec profile
set [find default=yes] dh-group=ecp384 enc-algorithm=aes-256 hash-algorithm=sha256

/ip ipsec proposal
set [find default=yes] auth-algorithms=sha256 enc-algorithms=aes-256-cbc pfs-group=ecp384

/ip pool
add name=pool1 ranges=10.1.200.1-10.1.200.254

/ip dhcp-server
add address-pool=pool1 interface=$rosBridgeName name=server1

/ip neighbor discovery-settings
set discover-interface-list=none

/ip address
add address=10.1.0.1/16 interface=$rosBridgeName network=10.1.0.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server lease
# add address=10.1.0.40 mac-address=00:00:00:00:00:00 comment="SERVER01"

/ip dhcp-server network
add address=10.1.0.0/16 dns-server=10.1.0.1 domain=$rosNwDomain gateway=10.1.0.1 ntp-server=10.1.0.1

/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8,77.88.8.8

/ip dns static
add address=10.1.0.1 name=$rosGwDomain

/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked \
  comment="[ROS] Accept established, related, untracked"
add action=drop chain=input connection-state=invalid \
  comment="[ROS] Drop invalid"
add action=accept chain=input protocol=icmp \
  comment="[ROS] Accept ICMP"
add action=accept chain=input dst-address=127.0.0.1 \
  comment="[ROS] Accept to local loopback (for CAPsMAN)"
add action=accept chain=input dst-port=8291,8443,33001 protocol=tcp src-address-list=admincp \
  comment="[ROS] Accept in AdminCP"
add action=drop chain=input in-interface-list=!LAN \
  comment="[ROS] Drop all not coming from LAN"
add action=accept chain=forward ipsec-policy=in,ipsec \
  comment="[ROS] Accept in IPsec policy"
add action=accept chain=forward ipsec-policy=out,ipsec \
  comment="[ROS] Accept out IPsec policy"
add action=fasttrack-connection chain=forward connection-state=established,related \
  comment="[ROS] FastTrack"
add action=accept chain=forward connection-state=established,related,untracked \
  comment="[ROS] Accept established, related, untracked"
add action=drop chain=forward connection-state=invalid \
  comment="[ROS] Invalid"
add action=drop chain=forward connection-nat-state=!dstnat connection-state=new in-interface-list=WAN \
  comment="[ROS] Drop all from WAN not DSTNATed"

/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface-list=WAN \
  comment="[ROS] Masquerade"
add action=dst-nat chain=dstnat dst-port=80,443 in-interface-list=WAN protocol=tcp to-addresses=10.1.4.1 disabled=yes \
  comment="[ROS] Port forwarding (example)"

/ip firewall address-list
add list=admincp address=10.0.0.0/8 comment="[ROS] Private network"
add list=admincp address=172.16.0.0/12 comment="[ROS] Private network"
add list=admincp address=192.168.0.0/16 comment="[ROS] Private network"

/ip service
set api disabled=yes
set api-ssl disabled=yes
set ftp disabled=yes
set ssh port=33001
set telnet disabled=yes
set www disabled=yes
set www-ssl port=8443 disabled=yes

/ip ssh
set host-key-type=ed25519 strong-crypto=yes

/system clock
set time-zone-autodetect=no time-zone-name=Europe/Moscow

/system identity
set name="$rosRouterName"

/system ntp client
set enabled=yes

/system ntp server
set enabled=yes manycast=yes multicast=yes

/system ntp client servers
add address="0.pool.ntp.org"
add address="1.pool.ntp.org"
add address="2.pool.ntp.org"
add address="3.pool.ntp.org"

/system watchdog
set automatic-supout=no

/tool bandwidth-server
set enabled=no

/tool mac-server
set allowed-interface-list=none

/tool mac-server mac-winbox
set allowed-interface-list=none

/tool mac-server ping
set enabled=no

/user
set [find name="admin"] password="$rosAdminPass"
add name="u0000" password="$rosUserPass" group=full
disable admin

# -------------------------------------------------------------------------------------------------------------------- #
# Router ID.
# -------------------------------------------------------------------------------------------------------------------- #

/routing id
add id=10.1.0.1 name=lo select-dynamic-id=only-loopback \
  comment="[ROS] Router ID (Loopback)"

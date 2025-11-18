# @package    MikroTik / RouterOS / WireGuard
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://libsys.ru/ru/2024/04/146e83d5-f571-5273-9a29-172bf5dc10fe/
# -------------------------------------------------------------------------------------------------------------------- #

# WireGuard interface name.
:local wgName "wireguard-sts"

# WireGuard interface IP address.
:local wgIp "10.255.255.1/24"

# WireGuard port number.
:local wgPort "51820"

# -------------------------------------------------------------------------------------------------------------------- #
# Local router.
# -------------------------------------------------------------------------------------------------------------------- #

# Local router name.
:local wgLocalName "GW1"

# Local network address.
:local wgLocalNetwork "10.1.0.0/16"

# -------------------------------------------------------------------------------------------------------------------- #
# Remote router.
# -------------------------------------------------------------------------------------------------------------------- #

# Remote router name.
:local wgRemoteName "GW2"

# Remote network address.
:local wgRemoteNetwork "10.2.0.0/16"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

/interface wireguard
add listen-port=$wgPort name=$wgName \
  comment="[WG] $wgName:$wgPort"

/ip address
add address=$wgIp interface=$wgName \
  comment="[WG] $wgName:$wgPort"

/ip route
add dst-address=$wgRemoteNetwork gateway=$wgName \
  comment="[WG] $wgLocalName-$wgRemoteName"

/ip firewall filter
add action=accept chain=input dst-port=$wgPort in-interface-list=WAN protocol=udp \
  comment="[WG] $wgName:$wgPort"
add action=accept chain=forward src-address=$wgRemoteNetwork dst-address=$wgLocalNetwork \
  comment="[WG] $wgRemoteName-$wgLocalName"
add action=accept chain=forward src-address=$wgLocalNetwork dst-address=$wgRemoteNetwork \
  comment="[WG] $wgLocalName-$wgRemoteName"

# @package    MikroTik / RouterOS / CAPsMAN
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://libsys.ru/ru/2023/12/0f3478b3-9fde-59aa-a424-ff160431fa35/
# -------------------------------------------------------------------------------------------------------------------- #

:local name "common"
:local ssid "GW01"
:local password "PassWord"
:local bridge "bridge1"

/ip firewall filter
add action=accept chain=input dst-address-type=local src-address-type=local comment="[ACCEPT] CAPsMAN"

/caps-man manager
set enabled=yes
set upgrade-policy=require-same-version

/caps-man manager interface
add forbid=yes interface=ether1

/caps-man channel
add band=2ghz-b/g/n frequency=2412 name=$name tx-power=20

/caps-man datapath
add bridge=$bridge client-to-client-forwarding=yes local-forwarding=yes name=$name

/caps-man security
add authentication-types=wpa2-psk encryption=aes-ccm name=$name passphrase=$password

/caps-man configuration
add channel=$name datapath=$name distance=indoors hw-protection-mode=rts-cts installation=indoor mode=ap name=$name rx-chains=0,1,2 security=$name ssid=$ssid tx-chains=0,1,2

/caps-man provisioning
add action=create-dynamic-enabled master-configuration=$name name-format=prefix-identity

/caps-man access-list
add action=accept mac-address=11:11:11:11:11:11 comment="[ACCEPT] AP 01"
add action=reject mac-address=00:00:00:00:00:00 mac-address-mask=00:00:00:00:00:00 comment="[REJECT] GLOBAL"

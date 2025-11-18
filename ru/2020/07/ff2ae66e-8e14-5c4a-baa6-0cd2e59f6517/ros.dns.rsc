# -------------------------------------------------------------------------------------------------------------------- #
# MIKROTIK: CLOUDFLARE DNS
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @policy     read, write, test
# @schedule:  00:10:00
# @link       https://libsys.ru/ru/2020/07/ff2ae66e-8e14-5c4a-baa6-0cd2e59f6517/
# -------------------------------------------------------------------------------------------------------------------- #

:local rosWanInterface "ether1"
:local rosCheckCrt "no"
:local cfToken ""
:local cfDomain "sub.example.org"
:local cfZoneID ""
:local cfDnsID ""
:local cfRecordType "A"
:local cfDebug 0

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

:local srcIP [/ip address get [find interface=$rosWanInterface] address]
:set srcIP [:pick $srcIP 0 [:find $srcIP "/"]]
:local dstIP [:resolve $cfDomain]
:local cfAPI "https://api.cloudflare.com/client/v4/zones/$cfZoneID/dns_records/$cfDnsID"
:local cfAPIHeader "Authorization: Bearer $cfToken, Content-Type: application/json"
:local cfAPIData "{\"type\":\"$cfRecordType\",\"name\":\"$cfDomain\",\"content\":\"$srcIP\"}"

# Write debug info to log.
:if ($cfDebug) do={
  :log info ("CloudFlare: Domain = $cfDomain")
  :log info ("CloudFlare: Domain IP (dstIP) = $dstIP")
  :log info ("CloudFlare: WAN IP (srcIP) = $srcIP")
  :log info ("CloudFlare: CloudFlare API (cfAPI) = $cfAPI&content=$srcIP")
}

# Compare and update CF if necessary.
:if ($dstIP != $srcIP) do={
  :log info ("CloudFlare: Updating $cfDomain, setting $srcIP = $cfDomain")
  /tool fetch mode=https http-method=put \
    http-header-field="$cfAPIHeader" \
    http-data="$cfAPIData" url="$cfAPI" \
    check-certificate=$rosCheckCrt \
    output=user as-value
  /ip dns cache flush
}

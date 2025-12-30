# -------------------------------------------------------------------------------------------------------------------- #
# CLOUDFLARE DNS
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kaikim.ru>
# @license    MIT
# @version    0.1.0
# @policy     read, write, test
# @schedule:  00:10:00
# @link       https://netcfg.ru/ru/2020/07/ff2ae66e-8e14-5c4a-baa6-0cd2e59f6517/
# -------------------------------------------------------------------------------------------------------------------- #

:local wanInterface "ether1"
:local crtCheck "no"
:local cfToken ""
:local cfDomain "example.org"
:local cfZoneID ""
:local cfDnsID ""
:local cfRecordType "A"
:local cfDebug 0

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

:local srcIP [/ip address get [find interface=$wanInterface] address]
:set srcIP [:pick $srcIP 0 [:find $srcIP "/"]]
:local dstIP [:resolve $cfDomain]
:local cfAPI "https://api.cloudflare.com/client/v4/zones/$cfZoneID/dns_records/$cfDnsID"
:local cfAPIHeader "Authorization: Bearer $cfToken, Content-Type: application/json"
:local cfAPIData "{\"type\":\"$cfRecordType\",\"name\":\"$cfDomain\",\"content\":\"$srcIP\"}"

:if ($cfDebug) do={
  :log info ("CloudFlare: Domain = $cfDomain")
  :log info ("CloudFlare: Domain IP (dstIP) = $dstIP")
  :log info ("CloudFlare: WAN IP (srcIP) = $srcIP")
  :log info ("CloudFlare: CloudFlare API (cfAPI) = $cfAPI&content=$srcIP")
}

:if ($dstIP != $srcIP) do={
  :log info ("CloudFlare: $cfDomain ($dstIP => $srcIP)")
  /tool fetch mode=https http-method=put \
    http-header-field="$cfAPIHeader" \
    http-data="$cfAPIData" url="$cfAPI" \
    check-certificate=$crtCheck \
    output=user as-value
  /ip dns cache flush
}

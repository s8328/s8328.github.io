# -------------------------------------------------------------------------------------------------------------------- #
# MIKROTIK: LET'S ENCRYPT
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @policy     read, write, test
# @schedule:  1d 00:00:00
# @link       https://libsys.ru/ru/2024/11/f892bebc-3ecd-518a-a948-27eed31649da/
# -------------------------------------------------------------------------------------------------------------------- #

:local crtApi "https://acme-v02.api.letsencrypt.org/directory"
:local crtDays 30d

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

:local crtDomain

/certificate
:foreach i in=[find where issuer~"Let's Encrypt"] do={
  :if (([get $i expires-after] < $crtDays) || [get $i expired]) do={
    :set crtDomain [get $i common-name]
    :do { remove $i } on-error={ :log error "ACME: $crtDomain not found!" }
    :do {
      :log info "ACME: $crtDomain renewal starting..."
      /ip service enable www
      /ip firewall address-list add list=acme address=0.0.0.0/0 timeout=00:02:00 comment="[ROS] ACME running..."
      /certificate enable-ssl-certificate directory-url="$crtApi" dns-name=$crtDomain; :delay 60s
      /ip service disable www
      /ip service set api-ssl certificate=$crtDomain
      /ip service set www-ssl certificate=$crtDomain
      /interface sstp-server server set certificate=$crtDomain
      :log info "ACME: $crtDomain renewal completed!"
    } on-error={ :log error "ACME: $crtDomain renewal failed!" }
  }
}

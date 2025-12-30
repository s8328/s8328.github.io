# -------------------------------------------------------------------------------------------------------------------- #
# ACME
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kaikim.ru>
# @license    MIT
# @version    0.1.0
# @policy     read, write, test
# @schedule:  4w 01:30:00
# @link       https://netcfg.ru/ru/2024/11/f892bebc-3ecd-518a-a948-27eed31649da/
# -------------------------------------------------------------------------------------------------------------------- #

:local domain "example.org"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

:do {
  /ip firewall address-list add list=acme address=0.0.0.0/0 timeout=00:01:10 comment="[ROS] ACME running..."
  /ip service enable www
  /certificate enable-ssl-certificate dns-name=$domain; :delay 60s
  /ip service disable www
  :log info "ACME: SSL certificate ($domain) updated!"
} on-error={ :log error "ACME: Failed to update SSL certificate ($domain)!" }

# -------------------------------------------------------------------------------------------------------------------- #
# MIKROTIK: GRE DYNAMIC IP
# -------------------------------------------------------------------------------------------------------------------- #
# @package    RouterOS
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @policy     read, write, test
# @schedule:  00:15:00
# @link       https://libsys.ru/ru/articles/2024/04/326618af-d950-5001-8114-57c66bb8a5af/
# -------------------------------------------------------------------------------------------------------------------- #

:local wanInterface "ether1"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

:local wanAddress [/ip address get [find interface=$wanInterface] address]
:set wanAddress [:pick $wanAddress 0 [:find $wanAddress "/"]]
:local greComment
:local greHost
:local greRemoteAddrNew
:local greRemoteAddrOld

:foreach i in=[/interface gre find where comment~"^HOST: "] do={
  :set greComment [/interface gre get $i comment]
  :set greHost [:pick $greComment 6 [:len $greComment]]
  :set greRemoteAddrOld [/interface gre get $i remote-address]
  :set greRemoteAddrNew [:resolve $greHost]

  :if ($greRemoteAddrNew != $greRemoteAddrOld) do={
    /interface gre set $i remote-address=$greRemoteAddrNew
    :log info ("GRE: Updating remote address ($greHost) from $greRemoteAddrOld to $greRemoteAddrNew.")
  }
}

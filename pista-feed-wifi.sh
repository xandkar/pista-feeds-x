#! /bin/sh

set -e

case "$1" in
    '') echo 'Which interface?' 1>&2; exit 1;;
     *) wifi_interface="$1"
esac

trap '' PIPE

while :
do
    iwconfig "$wifi_interface" \
    | awk -v requested_interface="$wifi_interface" '
        # Example iwconfig output:
        # -----------------------
        # $ iwconfig wlp3s0
        # wlp3s0    IEEE 802.11  ESSID:"BPLUNWIRED"
        #           Mode:Managed  Frequency:5.785 GHz  Access Point: E2:55:2D:C0:64:B8
        #           Bit Rate=135 Mb/s   Tx-Power=15 dBm
        #           Retry short limit:7   RTS thr:off   Fragment thr:off
        #           Power Management:on
        #           Link Quality=59/70  Signal level=-51 dBm
        #           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
        #           Tx excessive retries:0  Invalid misc:0   Missed beacon:0

        /^[a-z0-9]+ +IEEE 802\.11 +ESSID:/ {
            interface = $1
            split($4, essid_parts, ":")
            essid[interface] = essid_parts[2]
            gsub("\"", "", essid[interface])
        }

        /^ +Link Quality=[0-9]+\/[0-9]+ +Signal level=/ {
            split($2, lq_parts_eq, "=")
            split(lq_parts_eq[2], lq_parts_slash, "/")
            cur = lq_parts_slash[1]
            max = lq_parts_slash[2]
            link[interface] = cur / max * 100
        }

        END {
            printf("w %3d%%\n", link[requested_interface]);
        }
    '
    sleep "$2"
done

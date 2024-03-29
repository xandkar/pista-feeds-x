#! /bin/sh

# TODO: Try a rewrite with https://www.npmjs.com/package/bluetoothctl

count_powered_controllers() {
    echo 'show' | bluetoothctl | grep -c 'Powered: yes'
}

count_connected_devices() {
    echo 'devices Paired' \
    | bluetoothctl \
    | awk '{print $2}' \
    | xargs -I % bluetoothctl -- info % \
    | grep -c 'Connected: yes'
}

trap '' PIPE

while :
do
    printf "ᛒ %d:%d\n" "$(count_powered_controllers)" "$(count_connected_devices)"
    sleep 5;
done

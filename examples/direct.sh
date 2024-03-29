#! /bin/bash

set -e

remake() {
    rm -f "$1"
    mkfifo "$1"
}

base_dir="$HOME/.pista-in/.tmp"
mkdir -p "$base_dir"

fifo_time="$base_dir/time"
remake "$fifo_time"
fifo_mpd="$base_dir/mpd"
remake "$fifo_mpd"
fifo_vol="$base_dir/volume"
remake "$fifo_vol"
fifo_light="$base_dir/backlight"
remake "$fifo_light"
fifo_blue="$base_dir/bluetooth"
remake "$fifo_blue"
fifo_wifi="$base_dir/wifi"
remake "$fifo_wifi"
fifo_batt="$base_dir/battery"
remake "$fifo_batt"
fifo_upow="$base_dir/upower"
remake "$fifo_upow"
fifo_weather="$base_dir/weather"
remake "$fifo_weather"

wifi_if=$(iwconfig | grep -v '^lo' | awk '/^[^\ ]/ {print $1}')

../pista-feed-time             > "$fifo_time"   &
../pista-feed-mpd              > "$fifo_mpd"    &
../pista-feed-volume           > "$fifo_vol"    &
../pista-feed-backlight        > "$fifo_light"  &
../pista-feed-bluetooth        > "$fifo_blue"   &
../pista-feed-wifi "$wifi_if" 5 > "$fifo_wifi"   &
../pista-feed-battery          > "$fifo_batt"   &
../pista-feed-upower           > "$fifo_upow"   &
../pista-feed-weather-gov     -n -i $(( 15 * 60)) KJFK > "$fifo_weather" &

pista \
    -l 0 \
    -i 0 \
    -s '  ' \
    "$fifo_upow"   11 60 \
    "$fifo_wifi"    8 10  \
    "$fifo_blue"    9 10  \
    "$fifo_light"  10  5   \
    "$fifo_vol"     8  $(( 60 * 60 ))   \
    "$fifo_mpd"    17  5   \
    "$fifo_weather" 8 $(( 30 * 60 ))   \
    "$fifo_time"   21  2

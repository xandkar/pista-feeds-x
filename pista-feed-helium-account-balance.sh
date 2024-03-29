#! /bin/bash

set -e
set -o pipefail

main() {
    local -r address="$1"
    local -r interval="$2"

    local price_hnt_in_usd balance_hnt balance_usd

    trap '' PIPE

    while :
    do
        price_hnt_in_usd=$(curl 'https://api.binance.com/api/v3/avgPrice?symbol=HNTUSDT' | jq -r '.price')
        # HNT coefficient: 100000000
        balance_hnt=$(curl https://api.helium.io/v1/accounts/"$address" | jq '.data.balance / 100000000' || true)
        balance_usd=$(echo "$balance_hnt" "$price_hnt_in_usd" | awk '{print $1 * $2}')
        printf 'H %.2f  $%.2f  $%.2f\n' "$balance_hnt" "$price_hnt_in_usd" "$balance_usd"
        sleep "$interval"
    done
}

main "$@"

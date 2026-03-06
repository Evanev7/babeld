#!/usr/bin/env bash

PREFIX="fde0:20c6:1fa7:ffff"

addrs=()
ifs=()

new_addr() {
  hexdump -n 8 -e "1 \"$PREFIX\" 4/2 \":%04x\" \"\n\"" /dev/urandom
}

set_if() {
  local iface
  iface="$1"
  ifs+=("$iface")
  local existing
  existing=$(ifconfig "$iface" 2>/dev/null | grep -Eo "${PREFIX}(:[0-9a-fA-F]{1,4}){4}" | head -n1)
  [[ -n "$existing" ]] && {
    addrs+=("$existing")
    return 0;
  }
  local addr
  addr="$(new_addr)"
  sudo ifconfig "$iface" inet6 "$addr" prefixlen 128 alias
  addrs+=("$addr")
}

run_babeld() {
  local args=()
  for iface in "${ifs[@]}"; do
    args+=(-C "interface $iface")
  done

  for ip in "${addrs[@]}"; do
    args+=(-C "redistribute ip $ip/128 local allow")
  done
  args+=(-C "redistribute local deny")

  echo "starting babeld with args ${args[*]}"
  exec sudo babeld -g "/tmp/babeld.sock" "${args[@]}"
}


set_if en0
set_if en1

run_babeld

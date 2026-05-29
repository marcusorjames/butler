#!/bin/bash

fzf_read() {

  local _directory=$1
  local _prompt=$2
  local _result=$3

  if ! [ -x "$(command -v fzf)" ]; then
    read -rp "$_prompt" result
    eval "$_result"='$result'
    return 0
  fi

  echo -n "$_prompt"
  while true; do
    if read -rt 3 -n 1 key; then
      echo -en "\b" # Clear typed character
      break
    fi
  done

  result=$(find "$_directory" -maxdepth 1 -mindepth 1 -printf '%f\n' | fzf -q "$key")

  if [ ! -z "$result" ]; then
    echo "$result"
  else
    echo " "
  fi

  eval "$_result"='$result'
}

#!/bin/sh

fzf_read() {

  local _directory=$1
  local _prompt=$2
  local _result=$3

  if ! [ -x "$(command -v fzf)" ]; then
    read -p "$_prompt" result
    eval $_result="'$result'"
    return 0
  fi

  echo -n "$_prompt"
  while [ true ] ; do
    read -t 3 -n 1 key
    if [ $? = 0 ] ; then
      echo -en "\b" # Clear typed charactor
      break
    fi
  done

  result=$(ls $_directory | fzf -q $key)

  if [ ! -z $result ]; then
    echo $result
  else
    echo " "
  fi

  eval $_result="'$result'"
}

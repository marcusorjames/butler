#!/bin/bash

statusLine() {
  echo -e "$CSuccess$1...$Color_Off$2"
}

statusBadge() {
  local name="$1"
  local badge="$2"
  local color="${3:-$CSuccess}"
  local note="${4:-}"
  echo -e "$name ${color}[$badge]${Color_Off}${note:+ $note}"
}

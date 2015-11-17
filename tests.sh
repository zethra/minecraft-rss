#!/bin/bash

SCRIPT="minecraft-rss.sh"
OUT="rss.xml"

add_event() {
echo -e "Server backing up...\nBackup successful" | ./$SCRIPT add "Server backed up"
}

clear_log() {
./$SCRIPT clear
}

push() {
./$SCRIPT push
}

case "$1" in
add)
add_event
cat $OUT
;;
clear)
clear_log
cat $OUT
;;
push)
push
cat $OUT
;;
*)
add_event
push
cat $OUT
;;
esac
exit 0


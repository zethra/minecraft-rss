#!/bin/bash

SCRIPT="minecraft-rss.sh"
OUT="rss.xml"

players() {
echo -e "Current players\nPlayer 1\nPlayer 2" | ./$SCRIPT players 2
}

add_event() {
echo -e "Server backing up...\nBackup successful" | ./$SCRIPT add "Server backed up"
}

clear() {
./$SCRIPT clear
}

case "$1" in
players)
players
cat $OUT
;;
add)
add_event
cat $OUT
;;
clear)
clear
cat $OUT
;;
*)
players
add_event
cat $OUT
;;
esac
exit 0


#!/bin/bash
NOW=`date +"%a %b %d %l:%M:%S%P %Z %Y"`
FILE="rss.xml"
START="<!--list-start-->"
END="<!--list-end-->"
PLAYERS="0"
CONTENT=""
LIST="$START\n\t\t<guid>list</guid>\n\t\t<pubDate>$NOW</pubDate>\n\t\t<title>Players ($PLAYERS)</title>\n\t\t<description>\n$CONTENT\n\t\t</description>\n$END"

init() {
if [ ! -f $FILE ]; then 
	touch $FILE
	echo -e "<rss>\n<channel>\n\t<item>\n" >> $FILE
	echo -e $LIST >> $FILE
	echo -e "\n\t</item>\n</channel>\n</rss>\n" >> $FILE
fi
}

players() {
PLAYERS=$1
INPUT=""
while IFS= read -r LINE; do
	INPUT=$LINE\\n$INPUT
done
INPUT=${INPUT%??}
CONTENT=$(echo "\t\t\t$INPUT" | sed 's/\\n/\\n\\t\\t\\t/g')
LIST="$START\n\t\t<guid>list</guid>\n\t\t<pubDate>$NOW</pubDate>\n\t\t<title>Players ($PLAYERS)</title>\n\t\t<description>\n$CONTENT\n\t\t</description>\n$END"
C=$(echo $LIST | sed 's/\//\\\//g')
sed -e "/${START}/,/${END}/c\\${C}" $FILE > tmp
mv tmp $FILE
}

add_event() {
TITLE=$1
INPUT=""
while IFS= read -r LINE; do
	INPUT=$LINE\\n$INPUT
done
INPUT=${INPUT%??}
CONTENT=$(echo "\t\t\t"$INPUT | sed 's/\\n/\\n\\t\\t\\t/g')
XML="\t<item>\n\t\t<guid>$(uuidgen)</guid>\n\t\t<pubDate>$NOW</pubDate>\n\t\t\<title>$TITLE</title>\n\t\t<description>\n$CONTENT\n\t\t</description>\n\t</item>"

C=$(echo $XML | sed 's/\//\\\//g')
sed "/<\/channel>/ s/.*/${C}\n&/" $FILE > tmp
mv tmp $FILE
}

clearLog() {
sed -n '/<\/item>/q;p' $FILE > tmp
echo -e "\n\t</item>\n</channel>\n</rss>\n" >> tmp
mv tmp $FILE
}

case "$1" in
players)
if [ $# -gt 1 ]; then
	init
	shift
	players "$*"
else
	echo "Must specify number of players"
fi	
;;
add)
if [ $# -gt 1 ]; then
	init
	shift
	add_event "$*"
else
	echo "Must specify a title"
fi	
;;
clear)
clearLog
;;
*)
echo "Usage: $0 {players number_of_plyers|add title|clear}"
exit 1
;;
esac

exit 0

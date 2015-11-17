#!/bin/bash
REMOTE_HOST="192.168.1.1"
USER="user"
REMOTE_FILE="/var/www/html/rss.xml"
KEY="key.pem"
FILE="rss.xml"
START="<!--list-start-->"
END="<!--list-end-->"
NOW=`date +"%a %b %d %l:%M:%S%P %Z %Y"`
PLAYERS="0"
CONTENT=""
LIST="$START\n\t\t<guid>list</guid>\n\t\t<pubDate>$NOW</pubDate>\n\t\t<title>Players ($PLAYERS)</title>\n\t\t<description>\n$CONTENT\n\t\t</description>\n$END"

init() {
if [ -d $FILE ]; then
	rm $FILE
fi
if [ ! -f $FILE ] || [ -s $FILE ]; then 
	echo -e "<rss>\n<channel>\n</channel>\n</rss>\n" > $FILE
fi
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
rm $FILE
init
}

push() {
if [-f $FILE ]; then
	scp -vCq -i $KEY $FILE $USER@$REMOTE_HOST:$REMOTE_FILE 
else
	echo "File does not exist"
	exit -1
fi
}

case "$1" in
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
push)
push
;;
*)
echo "Usage: $0 {add \"title\"|clear|push}"
exit 1
;;
esac

exit 0

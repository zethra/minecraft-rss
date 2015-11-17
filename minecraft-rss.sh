#!/bin/bash
REMOTE_HOST="zethratech.com"
USER="root"
REMOTE_FILE="/var/www/html/rss.xml"
KEY="key.pem"
FILE="rss.xml"
LOG_FILE="mc-rss.log"
START="<!--list-start-->"
END="<!--list-end-->"
NOW=`date +"%a %b %d %l:%M:%S%P %Z %Y"`

init() {
if [ -d $FILE ]; then
	rm $FILE
fi
if [ ! -f $FILE ] || [ -s $FILE ]; then 
	echo -e "<rss>\n<channel>\n</channel>\n</rss>\n" > $FILE
fi

if [ -d $LOG_FILE ]; then
	rm $LOG_FILE
fi
if [ ! -f $LOG_FILE ]; then 
	touch $LOG_FILE
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
echo "Event \"$TITLE\" added" >> $LOG_FILE
}

clearLog() {
rm $FILE
init
echo "Log cleared" >> $LOG_FILE
}

push() {
if [ -e $FILE ] && [ -f $FILE ]; then
	scp -vCq -i $KEY $FILE $USER@$REMOTE_HOST:$REMOTE_FILE 2>> $LOG_FILE
else
	echo "File does not exist" >> $LOG_FILE
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

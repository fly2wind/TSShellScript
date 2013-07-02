#!/bin/bash
# second and nano second
T=$(date +%s%N)
# Make it 13 digits cause JavaScript Date has only millisecond
T=${T:0:13}
P1="s_nr=${T};"
P2="gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk7-downloads-1880260.html;"
P3="s_sq=oracleotnlive%2Coracleglobal%3D%2526pid%253Dotn%25253Aen-us%25253A%25252Fjava%25252Fjavase%25252Fdownloads%25252Fjdk7-downloads-1880260.html%2526pidt%253D1%2526oid%253Dfunctiononclick(event)%25257BacceptAgreement(window.self%25252C'jdk-7u13-oth-JPR')%25253B%25257D%2526oidt%253D2%2526ot%253DRADIO"
COOKIE="$P1 $P2 $P3"
AGENT='Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.16) Gecko/20120421 Firefox/11.0'
TARGET='http://download.oracle.com/otn-pub/java/jdk/7u25-b15/jdk-7u25-linux-x64.tar.gz'
REFERER='http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html'
curl -v -b "$COOKIE" --user-agent "$AGENT" --referer "$REFERER" -L -O "$TARGET"

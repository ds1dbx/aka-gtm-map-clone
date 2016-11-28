#!/bin/sh
argc=$#

if [ 5 -gt $argc ]
then
	echo "Required parameters missing. Please find below guide."
	echo
	echo "> Usage : clone.sh [option] [original-domain] [original-geomap] [target-domain] [target-map]"
	echo '> Eg.   : $ ./clone.sh -c dummy.domain.akadns.net "Encoded%20Zone%20Name" dummy.domain.akadns.net "New_Map_Name" (Cloning map)'
	echo '> Eg.   : $ ./clonen .sh -n - - dummy.domain.akadns.net "New_Map_Name" (Create new map with extracted geomap JSON file)'
	echo
	exit 0
fi

option=$1
originaldomain=$2
originalgeomap=$3
newdomain=$4
newgeomap=$5

#============================================================================================
# egcurl_section  : Section name of ".egcurl" file (e.g.: default)
# api_domain		  : Created End-point domain from "Luna > Confiugre > Manage API" menu (e.g.: something.luna.akamaiapis.net"
# uri_getoriginal	: Full URL to get master geographical GTM map data
# uri_putnew		  : New URL to put cloned geographical GTM map data
# sed_param			  : Regular expression that is using while map cloning
# egcurl_path		  : Installed full path of egcurl script (e.g.: ~/a/b/edgegrid-curl/egcurl)
#============================================================================================
egcurl_section="### PLACE SECTION NAME OF .egcurl FILE ###"
api_domain="### PLACE YOUR API END-POINT DOMAIN ONLY ###"
uri_getoriginal="https://"$api_domain"/config-gtm/v1/domains/"$originaldomain"/geographic-maps/"$originalgeomap
uri_putnew="https://"$api_domain"/config-gtm/v1/domains/"$newdomain"/geographic-maps/"$newgeomap
sed_param='s/PLACEHOLDER_FOR_NEWNAME/"name":"'$newgeomap'"/'
egcurl_path=~/a/b/edgegrid-curl-master/egcurl

#============================================================================================
if [ "-c" == "$option" ]
then
	echo "> Extract current geo map configuration..."
	python $egcurl_path -sSik $uri_getoriginal --eg-section $egcurl_section | sed -n '/^[{]/p' > geomap-org.json
	sleep 2

	echo "> Create new geo map configuration file..."
	cat geomap-org.json | sed -E 's/"name":"[a-zA-Z 0-9!@#$%^&*()-_.]+"/PLACEHOLDER_FOR_NEWNAME/' | sed -E $sed_param > geomap-new.json
	sleep 2

	echo "> Add new geo map configuration..."
	python $egcurl_path -sSik $uri_putnew -H "Content-type: application/json" -X PUT --data @geomap-new.json --eg-section $egcurl_section
	sleep 2

	echo
	echo
	echo "> Done..."
	echo "> If the response code is not 200 or 201, please check returned JSON message."
	echo "  . 200 OK      : Request is still on the fly"
	echo "  . 201 Created : Request properly processed"
	echo
fi

#============================================================================================
if [ "-n" == "$option" ]
then
	echo "> Modify geo map configuration file..."
	cat geomap-org.json | sed -E 's/"name":"[a-zA-Z 0-9!@#$%^&*()-_.]+"/PLACEHOLDER_FOR_NEWNAME/' | sed -E $sed_param > geomap-new.json
	sleep 2

	echo "> Add new geo map configuration..."
	python $egcurl_path -sSik $uri_putnew -H "Content-type: application/json" -X PUT --data @geomap-new.json --eg-section $egcurl_section
	sleep 2
fi

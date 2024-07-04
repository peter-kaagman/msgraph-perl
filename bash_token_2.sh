#! /usr/bin/bash

if test -f ./bash_token.cfg ; then
  . ./bash_token.cfg
fi

# echo "Tenant: " $TENANT_ID
# echo "App id:" $APP_ID
# echo "App pass: " $APP_PASS
# echo "Graph endpoint: " $GRAPH_ENDPOINT
# echo "Login enpoint: " $LOGIN_ENDPOINT

 token=`curl --no-progress-meter \
	-d grant_type=client_credentials \
	-d client_id=$APP_ID \
	-d client_secret=$APP_PASS \
	-d scope=$GRAPH_ENDPOINT/.default \
	-d resource=$GRAPH_ENDPOINT \
	$LOGIN_ENDPOINT/$TENANT_ID/oauth2/token \
	| jq -j .access_token
  `

#echo $token

curl -X GET --no-progress-meter \
	-H "Authorization: Bearer $token" \
	-H "Content-Type: application/json" \
	$GRAPH_ENDPOINT/v1.0/users?\$select=id,displayName\&\$filter=displayName eq 'Test Docent 3' \
	| jq .


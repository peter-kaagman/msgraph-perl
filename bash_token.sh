#! /usr/bin/bash

 token=`curl \
	-d grant_type=client_credentials \
	-d client_id=[client_id] \
	-d client_secret=[client_secret] \
	-d scope=https://graph.microsoft.com/.default \
	-d resource=https://graph.microsoft.com \
	https://login.microsoftonline.com/[tenant_id]/oauth2/token \
	| jq -j .access_token`

curl -X GET \
	-H "Authorization: Bearer $token" \
	-H "Content-Type: application/json" \
	https://graph.microsoft.com/v1.0/groups \
	| jq .


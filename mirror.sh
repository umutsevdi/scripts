#!/bin/bash
#******************************************************************************
#
# * File: mirror.sh
#
# * Author:  Umut Sevdi
# * Created: 05/01/24
# * Description: Migrates GitHub repositories as mirrors to the dedicated 
# * Gitea server
#
# GITHUB_USERNAME=
# GITHUB_TOKEN=
# GITEA_USERNAME=
# GITEA_DOMAIN=
# GITEA_REPO_OWNER=
# GITEA_TOKEN=
#*****************************************************************************

source .env

curl -X POST \
  -H "Authorization: bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{ \"query\": \"query { user(login: \\\"$GITHUB_USERNAME\\\") { \
        repositories( \
          ownerAffiliations: OWNER \
          first: 40 \
          orderBy: {field: PUSHED_AT, direction: DESC} \
        ) { \
          nodes { \
            url \
          } \
        }} \
      }\"
  }" \
  https://api.github.com/graphql \
  | jq '.data.user.repositories.nodes.[].url' \
  | sed 's/"//g' > /tmp/queries

for URL in `cat /tmp/queries`; do
   echo "For $URL"
   REPO_NAME=$(echo $URL | sed "s|https://github.com/$GITHUB_USERNAME/||g")
   echo "Found $REPO_NAME, importing..."

   curl -X POST "https://$GITEA_DOMAIN/api/v1/repos/migrate" \
       -u $GITEA_USERNAME:$GITEA_TOKEN \
       -H "accept: application/json" \
       -H  "Content-Type: application/json" \
       -d "{ \
   \"auth_username\": \"$GITHUB_USERNAME\", \
   \"auth_password\": \"$GITHUB_TOKEN\", \
   \"clone_addr\": \"$URL\", \
   \"mirror\": true, \
   \"private\": false, \
   \"repo_name\": \"$REPO_NAME\", \
   \"repo_owner\": \"$GITEA_REPO_OWNER\", \
   \"service\": \"git\", \
   \"uid\": 0, \
   \"wiki\": true}" &
done
rm /tmp/queries

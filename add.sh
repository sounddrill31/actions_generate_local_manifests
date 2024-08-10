#!/bin/bash

LINE=$1

# Extract the repository URL, local path, and branch from the line
read -r _ REPO_URL LOCAL_PATH BRANCH <<< $(echo "$LINE" | tr '"' ' ')

# Extract the repository name and owner from the URL
REPO_NAME=$(basename "$REPO_URL" .git)
REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

# Extract the domain name from the URL
DOMAIN_NAME=$(echo "$REPO_URL" | sed -E 's/https?:\/\/([^\/]+).*/\1/')

# Add remote to the REMOTES array if not already present
if [[ ! " ${!REMOTES[@]} " =~ " ${REPO_OWNER} " ]]; then
    REMOTES[$REPO_OWNER]="    <remote name=\"$REPO_OWNER\" fetch=\"https://$DOMAIN_NAME/$REPO_OWNER\" clone-depth=\"1\" />"
fi

# Add project to the PROJECTS array
PROJECT_KEY="${LOCAL_PATH}|${REPO_NAME}"
PROJECTS[$PROJECT_KEY]="    <project path=\"$LOCAL_PATH\" name=\"$REPO_NAME\" remote=\"$REPO_OWNER\" revision=\"$BRANCH\" />"
#!/bin/bash

# Check if a filename is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide a filename as an argument."
    exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
fi

# Define the input file
INFILE="$1"
FILENAME=$(basename "$1" .txt)

# Start the XML file with the header
echo '<?xml version="1.0" encoding="UTF-8"?>
<manifest>' > local_manifests.xml

# Initialize an array to store remote names
declare -A REMOTES

# Read the input file line by line using a while loop
REMOTE_COUNT=0
while IFS= read -r LINE
do
    # Extract the repository URL, local path, and branch from the line
    REPO_URL=$(echo "$LINE" | awk '{print $1}' | tr -d '"')
    LOCAL_PATH=$(echo "$LINE" | awk '{print $2}' | tr -d '"')
    BRANCH=$(echo "$LINE" | awk '{print $3}' | tr -d '"')

    # Extract the repository name and owner from the URL
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

    # Extract the domain name from the URL
    DOMAIN_NAME=$(echo "$REPO_URL" | awk -F[/:] '{print $4}')

    # Check if the remote is already added
    if [[ ! " ${!REMOTES[@]} " =~ " ${REPO_OWNER} " ]]; then
        # Generate the XML content for the remote
        if [ $REMOTE_COUNT -eq 0 ]; then
            echo "    <!-- Remotes -->" >> local_manifests.xml
        fi
        echo "    <remote name=\"$REPO_OWNER\" fetch=\"https://$DOMAIN_NAME/$REPO_OWNER\" clone-depth=\"1\" />" >> local_manifests.xml
        REMOTES[$REPO_OWNER]=1
        REMOTE_COUNT=$((REMOTE_COUNT + 1))
    fi
done < "$INFILE"

# Output <!-- Repos -->
echo "    <!-- Repos -->" >> local_manifests.xml

# Read the input file again to generate the XML content for the projects
while IFS= read -r LINE
do
    # Extract the repository URL, local path, and branch from the line
    REPO_URL=$(echo "$LINE" | awk '{print $1}' | tr -d '"')
    LOCAL_PATH=$(echo "$LINE" | awk '{print $2}' | tr -d '"')
    BRANCH=$(echo "$LINE" | awk '{print $3}' | tr -d '"')

    # Extract the repository name and owner from the URL
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

    # Generate the XML content for the project
    echo "    <project path=\"$LOCAL_PATH\" name=\"$REPO_NAME\" remote=\"$REPO_OWNER\" revision=\"$(echo $BRANCH | sed 's/^refs\/heads\///')\" />" >> local_manifests.xml
done < "$INFILE"

# Close the XML file
echo '</manifest>' >> local_manifests.xml
echo "Local manifests generated in local_manifests.xml"
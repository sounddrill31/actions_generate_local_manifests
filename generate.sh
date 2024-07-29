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
cat << EOF > local_manifests.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
<!-- Generated using sounddrill31/actions_generate_local_manifests -->
EOF

# Initialize an array to store remote names
declare -A REMOTES

# Read the input file line by line
REMOTE_COUNT=0
while IFS= read -r LINE; do
    echo "Debug: Processing line: $LINE"
    
    # Remove carriage return and leading/trailing whitespace
    LINE=$(echo "$LINE" | tr -d '\r' | xargs)
    echo "Debug: After trimming: $LINE"
    
    # Check if the line starts and ends with curly braces
    if [[ $LINE =~ ^\{.*\}$ ]]; then
        echo "Debug: Found testing line"
        # Extract data1 and data2
        read -r TESTING_URL TESTING_BRANCH <<< "${LINE:2:-2}"

        echo "$TESTING_URL" > url.txt
        echo "$TESTING_BRANCH" > branch.txt
        echo "true" > test_status.txt
        continue
    fi
    
    # Extract the repository URL, local path, and branch from the line
    REPO_URL=$(echo "$LINE" | awk '{print $1}' | tr -d '"')
    LOCAL_PATH=$(echo "$LINE" | awk '{print $2}' | tr -d '"')
    BRANCH=$(echo "$LINE" | awk '{print $3}' | tr -d '"')

    echo "Debug: REPO_URL=$REPO_URL"
    echo "Debug: LOCAL_PATH=$LOCAL_PATH"
    echo "Debug: BRANCH=$BRANCH"

    # Check if any of the variables are empty
    if [ -z "$REPO_URL" ] || [ -z "$LOCAL_PATH" ] || [ -z "$BRANCH" ]; then
        echo "Debug: Skipping line due to missing information"
        continue
    fi

    # Extract the repository name and owner from the URL
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

    echo "Debug: REPO_NAME=$REPO_NAME"
    echo "Debug: REPO_OWNER=$REPO_OWNER"

    # Extract the domain name from the URL
    DOMAIN_NAME=$(echo "$REPO_URL" | awk -F[/:] '{print $4}')

    echo "Debug: DOMAIN_NAME=$DOMAIN_NAME"

    # Check if the remote is already added
    if [[ ! " ${!REMOTES[@]} " =~ " ${REPO_OWNER} " ]]; then
        echo "Debug: Adding new remote: $REPO_OWNER"
        # Generate the XML content for the remote
        if [ $REMOTE_COUNT -eq 0 ]; then
            echo "    <!-- Remotes -->" >> local_manifests.xml
        fi
        echo "    <remote name=\"$REPO_OWNER\" fetch=\"https://$DOMAIN_NAME/$REPO_OWNER\" clone-depth=\"1\" />" >> local_manifests.xml
        REMOTES[$REPO_OWNER]=1
        ((REMOTE_COUNT++))
    fi

    # Output <!-- Repos --> only once
    if [ $REMOTE_COUNT -eq 1 ]; then
        echo "    <!-- Repos -->" >> local_manifests.xml
    fi

    # Generate the XML content for the project
    echo "    <project path=\"$LOCAL_PATH\" name=\"$REPO_NAME\" remote=\"$REPO_OWNER\" revision=\"${BRANCH#refs/heads/}\" />" >> local_manifests.xml
done < "$INFILE"

# Close the XML file
echo '</manifest>' >> local_manifests.xml
echo "Local manifests generated in local_manifests.xml"

# Print the exported variables
echo "TESTING_URL: $TESTING_URL"
echo "TESTING_BRANCH: $TESTING_BRANCH"

# Debug: Print the content of the generated file
echo "Debug: Content of local_manifests.xml:"
cat local_manifests.xml
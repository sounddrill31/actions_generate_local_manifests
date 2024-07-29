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

# Start the XML file with the header
cat << EOF > local_manifests.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
<!-- Generated using sounddrill31/actions_generate_local_manifests -->
EOF

# Initialize an array to store remote names
declare -A REMOTES

# Function to process a repository line
process_repo_line() {
    local LINE="$1"
    # Extract the repository URL, local path, and branch from the line
    REPO_URL=$(echo "$LINE" | awk '{print $1}' | tr -d '"')
    LOCAL_PATH=$(echo "$LINE" | awk '{print $2}' | tr -d '"')
    BRANCH=$(echo "$LINE" | awk '{print $3}' | tr -d '"')

    # Extract the repository name and owner from the URL
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

    # Extract the domain name from the URL
    DOMAIN_NAME=$(echo "$REPO_URL" | awk -F[/:] '{print $4}')

    # Add remote if not already added
    if [[ ! " ${!REMOTES[@]} " =~ " ${REPO_OWNER} " ]]; then
        if [ ${#REMOTES[@]} -eq 0 ]; then
            echo "    <!-- Remotes -->" >> local_manifests.xml
        fi
        echo "    <remote name=\"$REPO_OWNER\" fetch=\"https://$DOMAIN_NAME/$REPO_OWNER\" clone-depth=\"1\" />" >> local_manifests.xml
        REMOTES[$REPO_OWNER]=1
    fi

    # Add project
    if [ ${#REMOTES[@]} -eq 1 ]; then
        echo "    <!-- Repos -->" >> local_manifests.xml
    fi
    echo "    <project path=\"$LOCAL_PATH\" name=\"$REPO_NAME\" remote=\"$REPO_OWNER\" revision=\"${BRANCH#refs/heads/}\" />" >> local_manifests.xml
}

# Read and process the input file
while IFS= read -r LINE; do
    # Remove carriage return and leading/trailing whitespace
    LINE=$(echo "$LINE" | tr -d '\r' | xargs)
    
    if [[ $LINE =~ ^\{.*\}$ ]]; then
        # Extract testing URL and branch
        read -r TESTING_URL TESTING_BRANCH <<< "${LINE:2:-2}"
        echo "$TESTING_URL" > url.txt
        echo "$TESTING_BRANCH" > branch.txt
        echo "true" > test_status.txt
    elif [ ! -z "$LINE" ]; then
        # Process repository line
        process_repo_line "$LINE"
    fi
done < "$INFILE"

# Close the XML file
echo '</manifest>' >> local_manifests.xml
echo "Local manifests generated in local_manifests.xml"

# Print the exported variables
echo "TESTING_URL: $TESTING_URL"
echo "TESTING_BRANCH: $TESTING_BRANCH"
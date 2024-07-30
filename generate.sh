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

# Initialize arrays to store remotes and projects
declare -A REMOTES
PROJECTS=()

# Read the input file line by line
while IFS= read -r LINE || [ -n "$LINE" ]; do
    # Remove carriage return and leading/trailing whitespace
    LINE=$(echo "$LINE" | tr -d '\r' | xargs)
    
    # Check if the line starts and ends with curly braces
    if [[ $LINE =~ ^\{.*\}$ ]]; then
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

    # Check if any of the variables are empty
    if [ -z "$REPO_URL" ] || [ -z "$LOCAL_PATH" ] || [ -z "$BRANCH" ]; then
        continue
    fi

    # Extract the repository name and owner from the URL
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_OWNER=$(basename "$(dirname "$REPO_URL")")

    # Extract the domain name from the URL
    DOMAIN_NAME=$(echo "$REPO_URL" | awk -F[/:] '{print $4}')

    # Add remote to the REMOTES array if not already present
    if [[ ! " ${!REMOTES[@]} " =~ " ${REPO_OWNER} " ]]; then
        REMOTES[$REPO_OWNER]="    <remote name=\"$REPO_OWNER\" fetch=\"https://$DOMAIN_NAME/$REPO_OWNER\" clone-depth=\"1\" />"
    fi

    # Add project to the PROJECTS array
    PROJECTS+=("    <project path=\"$LOCAL_PATH\" name=\"$REPO_NAME\" remote=\"$REPO_OWNER\" revision=\"${BRANCH#refs/heads/}\" />")
done < "$INFILE"

# Output remotes
echo "    <!-- Remotes -->" >> local_manifests.xml
for remote in "${REMOTES[@]}"; do
    echo "$remote" >> local_manifests.xml
done

# Output projects
echo "    <!-- Repos -->" >> local_manifests.xml
for project in "${PROJECTS[@]}"; do
    echo "$project" >> local_manifests.xml
done

# Close the XML file
echo '</manifest>' >> local_manifests.xml
echo "Local manifests generated in local_manifests.xml"

# Print the exported variables
echo "TESTING_URL: $TESTING_URL"
echo "TESTING_BRANCH: $TESTING_BRANCH"

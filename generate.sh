#!/bin/bash

# Enable debug output
set -x

# Function to download scripts
download_script() {
    local script_name=$1
    local url="https://insertlink/${script_name}"
    if [ ! -f "${script_name}" ]; then
        echo "Downloading ${script_name}..."
        if ! wget "${url}"; then
            echo "Failed to download ${script_name}"
            exit 1
        fi
        chmod +x "${script_name}"
    fi
}

# Download add.sh and remove.sh
download_script "add.sh"
download_script "remove.sh"

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
FILENAME=$(basename "$1")

echo "Processing input file: $INFILE"

# Start the XML file with the header
cat << EOF > local_manifests.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
<!-- Generated using sounddrill31/actions_generate_local_manifests -->
EOF

# Initialize associative arrays to store remotes, projects, and remove-projects
declare -A REMOTES
declare -A PROJECTS
declare -A REMOVE_PROJECTS

# Initialize counters
ADD_COUNT=0
REMOVE_COUNT=0

# Read the input file line by line
while IFS= read -r LINE || [ -n "$LINE" ]; do
    # Remove carriage return and leading/trailing whitespace
    LINE=$(echo "$LINE" | tr -d '\r' | xargs)
    
    echo "Processing line: $LINE"
    
    # Check if the line starts with curly braces
    if [[ $LINE =~ ^\{.*\}$ ]]; then
        # Extract TESTING_URL and TESTING_BRANCH
        read -r TESTING_URL TESTING_BRANCH <<< $(echo "$LINE" | tr -d '{}' | tr '"' ' ')
        echo "$TESTING_URL" > url
        echo "$TESTING_BRANCH" > branch
        echo "true" > test_status
        echo "Set TESTING_URL=$TESTING_URL and TESTING_BRANCH=$TESTING_BRANCH"
        continue
    fi
    
    # Call add.sh for 'add' lines
    if [[ $LINE == add* ]]; then
        echo "Calling add.sh with: $LINE"
        if source ./add.sh "$LINE"; then
            ((ADD_COUNT++))
        else
            echo "Error in add.sh"
        fi
    fi
    
    # Call remove.sh for 'remove' lines
    if [[ $LINE == remove* ]]; then
        echo "Calling remove.sh with: $LINE $TESTING_URL $TESTING_BRANCH"
        if source ./remove.sh "$LINE" "$TESTING_URL" "$TESTING_BRANCH"; then
            ((REMOVE_COUNT++))
        else
            echo "Error in remove.sh"
        fi
    fi
done < "$INFILE"

# Clean up
rm -rf manifest

echo "" >> local_manifests.xml

# Output remotes
echo "    <!-- Remotes -->" >> local_manifests.xml
for remote in "${REMOTES[@]}"; do
    echo "$remote" >> local_manifests.xml
done
echo "" >> local_manifests.xml

# Output remove-project entries
echo "    <!-- Removals -->" >> local_manifests.xml
for remove_project in "${REMOVE_PROJECTS[@]}"; do
    echo "$remove_project" >> local_manifests.xml
done
echo "" >> local_manifests.xml

# Output projects
echo "    <!-- Repos -->" >> local_manifests.xml
for project in "${PROJECTS[@]}"; do
    echo "$project" >> local_manifests.xml
done
echo "" >> local_manifests.xml

# Close the XML file
echo '</manifest>' >> local_manifests.xml

echo "Local manifests generated in local_manifests.xml"
echo "Add operations processed: $ADD_COUNT"
echo "Remove operations processed: $REMOVE_COUNT"

# Print the contents of the arrays
echo "REMOTES:"
for key in "${!REMOTES[@]}"; do
    echo "  $key: ${REMOTES[$key]}"
done

echo "PROJECTS:"
for key in "${!PROJECTS[@]}"; do
    echo "  $key: ${PROJECTS[$key]}"
done

echo "REMOVE_PROJECTS:"
for key in "${!REMOVE_PROJECTS[@]}"; do
    echo "  $key: ${REMOVE_PROJECTS[$key]}"
done

# Print the exported variables
echo "TESTING_URL: $TESTING_URL"
echo "TESTING_BRANCH: $TESTING_BRANCH"

# Disable debug output
set +x
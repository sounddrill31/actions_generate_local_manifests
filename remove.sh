#
# Copyright (C) 2024 Souhrud Reddy
#
# SPDX-License-Identifier: Apache-2.0
#

#!/bin/bash

LINE=$1
TESTING_URL=$2
TESTING_BRANCH=$3

# Extract the path to remove
PATH_TO_REMOVE=$(echo "$LINE" | awk '{print $2}' | tr -d '"')

# Clone the manifest repository if it doesn't exist
if [ ! -d "manifest" ]; then
    git clone "$TESTING_URL" -b "$TESTING_BRANCH" manifest
fi

# Find exact matches for the path in manifest files
while IFS= read -r file; do
    # Check for project with this exact path
    if grep -q "path=\"$PATH_TO_REMOVE\"" "$file"; then
        # Check if there's already a remove-project for this exact path
        if ! grep -q "remove-project.*path=\"$PATH_TO_REMOVE\"" "$file"; then
            # Extract the full name from the matched line
            FULL_NAME=$(grep "path=\"$PATH_TO_REMOVE\"" "$file" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
            
            # Add a removal entry to the REMOVE_PROJECTS array
            REMOVE_PROJECTS[$FULL_NAME]="    <remove-project name=\"$FULL_NAME\" />"
        fi
        break  # Exit after finding the first match
    fi
done < <(find manifest -type f)
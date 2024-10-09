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

# Find all matches for the path in all manifest files
while IFS= read -r MATCH; do
    # Extract the full name from the matched line
    FULL_NAME=$(echo "$MATCH" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
    
    if [ -n "$FULL_NAME" ]; then
        # Check if there's already a remove-project for this name in any manifest file
        if ! grep -r "remove-project.*name=\"$FULL_NAME\"" manifest/ >/dev/null; then
            # Add a removal entry to the REMOVE_PROJECTS array only if it's not already marked for removal
            REMOVE_PROJECTS[$FULL_NAME]="    <remove-project name=\"$FULL_NAME\" />"
        fi
    fi
done < <(grep -r "path=\"$PATH_TO_REMOVE\"" manifest/)
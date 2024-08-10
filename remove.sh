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

# Find the matching line in the manifest
MATCH=$(grep -r "path=\"$PATH_TO_REMOVE\"" manifest)

if [ -n "$MATCH" ]; then
    # Extract the full name from the matched line
    FULL_NAME=$(echo "$MATCH" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
    
    # Add a removal entry to the REMOVE_PROJECTS array
    REMOVE_PROJECTS[$FULL_NAME]="    <remove-project name=\"$FULL_NAME\" />"
fi
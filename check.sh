#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
        USERNAME="$2"
        shift 2
        ;;
        --token)
        TOKEN="$2"
        shift 2
        ;;
        *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
done

# Check if USERNAME and TOKEN are provided
if [ -z "$USERNAME" ] || [ -z "$TOKEN" ]; then
    echo "Usage: $0 --user <username> --token <token>"
    exit 1
fi

# Check if the repository exists
repo_check=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$TOKEN" https://api.github.com/repos/$USERNAME/Manifest_Tester)

if [ "$repo_check" -eq 200 ]; then
    echo "Repository Manifest_Tester already exists in your account."
else
    echo "Repository not found. Forking Manifest_Tester..."
    fork_result=$(curl -s -u "$USERNAME:$TOKEN" -X POST https://api.github.com/repos/sounddrill31/Manifest_Tester/forks)
    
    if [ $? -eq 0 ]; then
        echo "Repository forked successfully."
    else
        echo "Failed to fork repository. Error: $fork_result"
    fi
fi
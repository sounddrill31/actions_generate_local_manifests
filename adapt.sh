#
# Copyright (C) 2024 Souhrud Reddy
#
# SPDX-License-Identifier: Apache-2.0
#

#!/bin/bash

# Get the filename without extension
filename=$(basename "$1" | cut -d '.' -f 1)

# Create the output file
output_file="${filename}.output"
rm -rf $output_file branch test_status url local_manifests.xml || true

# Array to keep track of paths we've seen
declare -A seen_paths

# Process the input file
while IFS= read -r line || [ -n "$line" ]; do
  if [[ $line =~ ^repo ]]; then
    # Extract the URL and branch from the repo init line
    url=$(echo "$line" | awk -F'-u ' '{print $2}' | awk '{print $1}')
    branch=$(echo "$line" | awk -F'-b ' '{print $2}' | awk '{print $1}')
    echo "{ \"$url\" \"$branch\" }" >> "$output_file"
  elif [[ $line =~ ^git ]]; then
    # Extract the URL, path, and branch from the git clone line
    url=$(echo "$line" | awk '{print $3}')
    path=""
    branch=""
    args=($line)
    for ((i=3; i<${#args[@]}; i++)); do
      if [[ ${args[$i]} == -b ]]; then
        branch=${args[$i+1]}
        i=$((i+1))
      elif [[ ${args[$i]} != -* ]]; then
        path=${args[$i]}
      fi
    done
    echo "add \"$url\" \"$path\" \"${branch//[$'\r\n']}\"" >> "$output_file"
    
    # Add removal entry if we haven't seen this path before
    if [[ ! ${seen_paths[$path]} ]]; then
      echo "remove \"$path\"" >> "$output_file"
      seen_paths[$path]=1
    fi
  elif [[ $line =~ ^rm ]]; then
    # Extract the path from the rm line
    path=$(echo "$line" | awk '{print $3}' | tr -d '"')
    echo "remove \"${path//[$'\r\n']}\"" >> "$output_file"
    seen_paths[$path]=1
  fi
done < "$1"

# Remove any trailing newlines or spaces in the output file
temp_file="${filename}.temp"
while IFS= read -r line; do
    echo "$line" | sed 's/[[:space:]]*$//' >> "$temp_file"
done < "$output_file"

# Replace the original output file with the cleaned temp file
mv "$temp_file" "$output_file"

# Display the output
cat "$output_file"

bash generate.sh "$output_file"
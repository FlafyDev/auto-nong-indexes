#!/bin/bash

# Check if we're in a git repository
if [ ! -d .git ]; then
  echo "This is not a git repository."
  exit 1
fi

# Get all commit messages
commit_messages=$(git log --pretty=format:%B)

# Extract Reviewed-by lines and count occurrences per user
echo "$commit_messages" | grep -oP 'Reviewed-by: \K[^<]*' | sort | uniq -c | sort -rn


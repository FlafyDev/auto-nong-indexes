#!/bin/bash

filename="my_issues"  # Replace with your actual file name

declare -A rejection_counts  # Associative array to store rejection counts
declare -A acceptance_counts  # Associative array to store acceptance counts

# Function to add rejections for a user
add_rejection() {
    local user="$1"
    ((rejection_counts[$user]++))
}

add_acceptance() {
    local user="$1"
    ((acceptance_counts[$user]++))
}

while IFS=: read -r line_num line_content; do
    prev_line_num=$((line_num - 2))
    prev_line_content=$(sed -n "${prev_line_num}p" "$filename")

    if [[ "$prev_line_content" == "#"* ]]; then
        username=$(echo "$prev_line_content" | grep -o '\[[^]]*\]' | head -n 1 | sed 's/[][]//g')

        # Reset found_closed flag for each iteration
        found_closed=false

        # Read subsequent lines to check for "closed"
        while IFS= read -r next_line_content; do
            if [[ "$next_line_content" == "#"* ]]; then
                if [[ "$next_line_content" == *"auto-nong) commented at"* ]]; then
                  lines_2_below=$(sed -n "$((line_num + 2))p" "$filename")
                  if [[ "$lines_2_below" == "Added"* ]]; then
                      found_closed=true
                      break
                  fi
                  break
                fi
                break
            fi
            ((line_num++))
        done < <(tail -n +${line_num} "$filename")

        if $found_closed; then
            add_acceptance "$username"
        fi
    fi
done < <(grep -n '^accept' "$filename")

while IFS=: read -r line_num line_content; do
    prev_line_num=$((line_num - 2))
    prev_line_content=$(sed -n "${prev_line_num}p" "$filename")

    if [[ "$prev_line_content" == "#"* ]]; then
        username=$(echo "$prev_line_content" | grep -o '\[[^]]*\]' | head -n 1 | sed 's/[][]//g')

        # Reset found_closed flag for each iteration
        found_closed=false

        # Read subsequent lines to check for "closed"
        while IFS= read -r next_line_content; do
            if [[ "$next_line_content" == "# [\\#"* ]]; then
                if [[ "$next_line_content" == *"closed"* ]]; then
                    found_closed=true
                    break
                fi
                break
            fi
            ((line_num--))
        done < <(tail -n +${line_num} "$filename" | tac)

        if $found_closed; then
            add_rejection "$username"
            echo "found rejection for $username"
        fi
    fi
done < <(grep -n '^reject' "$filename")

# Initialize an array to store all users from both counts
declare -A all_users

# Add users from acceptance_counts
for user in "${!acceptance_counts[@]}"; do
    all_users["$user"]=1
done

# Add users from rejection_counts
for user in "${!rejection_counts[@]}"; do
    all_users["$user"]=1
done

# Create an array to store users and their total counts
declare -A total_counts
for user in "${!all_users[@]}"; do
    accepted="${acceptance_counts[$user]:-0}"  # Default value 0 if acceptance count is not set
    rejected="${rejection_counts[$user]:-0}"   # Default value 0 if rejection count is not set
    total_counts["$user"]=$((accepted + rejected))
done

# Sort users by their total counts in descending order
sorted_users=($(for user in "${!total_counts[@]}"; do echo "$user ${total_counts[$user]}"; done | sort -rn -k2 | awk '{print $1}'))

# Print results sorted by total count
echo -e "User\t\t\tTotal\tAccept\tReject"
for user in "${sorted_users[@]}"; do
    accepted="${acceptance_counts[$user]:-0}"  # Default value 0 if acceptance count is not set
    rejected="${rejection_counts[$user]:-0}"   # Default value 0 if rejection count is not set
    total="${total_counts[$user]}"
    echo -e "$user\t\t$total\t$accepted\t$rejected"
done

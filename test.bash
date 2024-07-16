# #!/bin/bash
#
# # Define the CSV file
# csv_file="2024-07-13-14-51-12-issues.csv"
#
# # Read the CSV file and process it with awk
# awk -F, '
# BEGIN {
#     # Define the field separator for CSV
#     FS = ","
# }
#
# # Function to get the 12th line from a multi-line string
# function get_12th_line(str,   lines, i) {
#     split(str, lines, "\n")
#     print "lines: " lines[3]
#     exit
#     return lines[16]
# }
#
# {
#     # Get the body field (assuming it is the second field)
#     body = $12
#     
#     # Get the 12th line of the body field
#     twelfth_line = get_12th_line(body)
#     
#     # Check if the length of the 12th line is 16
#     if (length(twelfth_line) == 16) {
#         # Print the number field (assuming it is the first field)
#         print $1
#     }
# }
# ' "$csv_file"
#
#!/bin/bash

# Check if a file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide a CSV file as an argument."
    exit 1
fi

# Read the CSV file line by line
while IFS=',' read -r number body rest; do
    # Remove quotes from the body field
    body="${body//\"/}"
    
    # Extract the 12th line from the body field
    twelfth_line=$(echo "$body" | sed -n '16p')
    echo "twelfth_line: " $body
    
    # Check if the 12th line is exactly 16 characters long
    if [ ${#twelfth_line} -eq 16 ]; then
        echo "$number"
    fi
done < "$1"

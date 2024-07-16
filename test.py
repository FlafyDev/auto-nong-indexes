import csv

def process_csv(file_path):
    with open(file_path, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            body = row['body']
            lines = body.split('\n')
            if row['state'] == 'open' and len(lines) >= 14 and len(lines[14].strip()) == 16:
                # print(lines[14])
                print(row['number'])

# Replace 'your_file.csv' with the path to your CSV file
process_csv('2024-07-13-21-22-19-issues.csv')

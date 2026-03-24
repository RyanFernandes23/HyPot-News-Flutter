import os

pubspec_path = r'c:\Users\Hp\OneDrive\Desktop\HyPot-News-Flutter\pubspec.yaml'
new_lines = [
    '',
    'flutter:',
    '  uses-material-design: true',
    '  assets:',
    '    - .env',
    ''
]

with open(pubspec_path, 'r') as f:
    lines = f.readlines()

# Remove existing flutter block if any to avoid duplication
filtered_lines = []
skip = False
for line in lines:
    if line.strip() == 'flutter:':
        skip = True
    if not skip:
        filtered_lines.append(line)
    if skip and line.strip() == '':
        skip = False

with open(pubspec_path, 'w') as f:
    f.writelines(filtered_lines)
    f.write('\n'.join(new_lines))

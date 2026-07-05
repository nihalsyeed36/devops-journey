#!/bin/bash

# 1. Ask the user for the project name
read -p "Enter your project name: " project_name

# 2. Check if the user actually typed something
if [ -z "$project_name" ]; then
    echo "Error: Project name cannot be empty!"
    exit 1
fi

# 3. Create the main project folder
echo "Creating project directory: $project_name..."
mkdir "$project_name"

# 4. Use a loop to create subdirectories inside the main folder
for folder in src config logs; do
    echo "Creating sub-directory: $project_name/$folder"
    mkdir "$project_name/$folder"
done

# 5. Create the empty configuration file
touch "$project_name/config/app.conf"

echo "--------------------------------------"
echo "Workspace for '$project_name' is ready!"

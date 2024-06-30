#!/bin/bash

# Define the entries to be added
entries="
127.0.0.1   main.dev.test  # Main Development Server
127.0.0.1   api.dev.test   # API Server
127.0.0.1   ui.dev.test    # UI (Frontend) Application
127.0.0.1   auth.dev.test  # Authentication Service
"

# Print out the intended changes
echo "The following entries will be added to /etc/hosts:"
echo "$entries"

# Ask the user for confirmation
read -p "Do you want to proceed with adding these entries? (yes/no): " response

# Check the user's response
if [[ "$response" == "yes" ]]; then
    # Append the entries to the /etc/hosts file
    echo "$entries" | sudo tee -a /etc/hosts
    echo "Entries have been added to /etc/hosts."
else
    echo "Operation cancelled. Please manually add the following entries to /etc/hosts:"
    echo "$entries"
fi
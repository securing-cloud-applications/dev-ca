#!/bin/bash

# Script to add development domain entries to the hosts file
#
# This script appends specified development domain entries to the hosts file.
# It handles both Unix-like systems (Linux, macOS) and Windows systems.
#
# The script:
# 1. Prints the entries to be added.
# 2. Asks for user confirmation.
# 3. Appends the entries to the hosts file based on the OS type.
# 4. Prints the updated contents of the hosts file.

# Define the entries to be added
entries="
127.0.0.1   dev.test       # Development Domain
127.0.0.1   main.dev.test  # Main Entry point for local applications
127.0.0.1   api.dev.test   # API Server
127.0.0.1   ui.dev.test    # UI (Frontend) Application
127.0.0.1   auth.dev.test  # Authentication Service
"

# Print out the intended changes
echo "The following entries will be added to the hosts file:"
echo "${entries}"

# Ask the user for confirmation
read -p "Do you want to proceed with adding these entries? (yes/no): " response

# Check the user's response and proceed accordingly
if [[ "${response}" != "yes" ]]; then
    echo "Operation cancelled. Please manually add the following entries to your hosts file:"
    echo "${entries}"
    exit 0
fi

# Determine the OS type and set the hosts file path
case "${OSTYPE}" in
    linux-gnu* | darwin*)
        hosts_file="/etc/hosts"
        echo "${entries}" | sudo tee -a "${hosts_file}" > /dev/null
        ;;
    msys* | cygwin* | win32*)
        hosts_file="/c/Windows/System32/drivers/etc/hosts"
        echo "${entries}" >> "${hosts_file}"
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac

echo "Entries have been added to ${hosts_file}."
echo "Here are the current contents of ${hosts_file}:"
cat "${hosts_file}"
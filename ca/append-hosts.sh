#!/bin/bash

# Define the entries to be added
entries="
127.0.0.1   main.dev.test
127.0.0.1   api.dev.test
127.0.0.1   ui.dev.test
127.0.0.1   auth.dev.test
"

# Append the entries to the /etc/hosts file
echo "$entries" | sudo tee -a /etc/hosts

# Confirm the addition
echo "Entries added to /etc/hosts:"
echo "$entries"q
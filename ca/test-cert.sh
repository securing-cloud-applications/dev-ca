#!/bin/bash

# Script to check TLS functionality on specified domains using curl
#
# This script performs the following steps:
# 1. Defines a function to check TLS on a given domain.
# 2. Uses the curl command to make an HTTPS request to the specified domain on port 8443.
# 3. Checks the HTTP response code to determine if TLS is working.
# 4. Prints a message indicating whether TLS is working based on the response code.
# 5. Checks TLS on a predefined list of domains.
#
# Usage:
#   ./test-cert.sh
#
# Note:
# - Ensure curl is installed on your system.
# - The script assumes that the specified domains are accessible and listening on port 8443.

# Function to check TLS on a domain
check_tls() {
  local domain=$1
  response=$(curl -s -o /dev/null -w "%{http_code}" https://${domain}:8443)
  if [ "$response" -eq 200 ]; then
    echo "TLS is working for ${domain}"
  else
    echo "TLS is not working for ${domain}. HTTP code: ${response}"
  fi
}

# Check TLS on each domain individually
check_tls "localhost"
check_tls "dev.test"
check_tls "main.dev.test"
check_tls "api.dev.test"
check_tls "ui.dev.test"
check_tls "auth.dev.test"
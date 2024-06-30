#!/bin/bash

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
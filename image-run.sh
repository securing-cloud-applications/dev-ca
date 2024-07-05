#!/bin/bash
set -x
docker run -p  8443:8443 -v $(pwd)/ca/keys:/application/ca/keys:ro  dev-ca:1

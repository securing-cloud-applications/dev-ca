#!/bin/bash
set -x
./mvnw clean package -DskipTests
docker build . -t dev-ca:1

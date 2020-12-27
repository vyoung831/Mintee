#!/bin/sh

:> versions.h

# Capitalize and decimalize the short commit number
SHORT_COMMIT=$( tr '[:lower:]' '[:upper:]' <<< $(git rev-parse --short HEAD) )
DECIMALIZED_COMMIT=$( bc <<< "ibase=16; ${SHORT_COMMIT}" )

# Get Epoch in minutes
EPOCH_SECONDS=$(date +%s)
EPOCH_MINUTES=$((${EPOCH_SECONDS}/60))

# Write CFBundleVersion value to versions.h
BUILD_NUMBER=${DECIMALIZED_COMMIT}.${EPOCH_MINUTES}
echo "#define MuBuildNumber \"${BUILD_NUMBER}\"" >> versions.h

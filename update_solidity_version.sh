#!/bin/bash

# Define the target Solidity version
TARGET_VERSION="^0.8.20"

# Find all .sol files and update the pragma version
find . -name "*.sol" -exec sed -i 's/pragma solidity .*/pragma solidity '"$TARGET_VERSION"';/g' {} +

echo "Updated all Solidity files to use pragma solidity $TARGET_VERSION"

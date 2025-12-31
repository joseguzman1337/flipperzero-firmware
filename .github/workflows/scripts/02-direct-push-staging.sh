#!/bin/bash

# Test Case 02: Direct Push to Staging Branch (Not Allowed)

source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Mock GitHub environment for a direct push to 'staging'
mock_env_push 'staging'

# Execute the workflow script
source ../enforce-branch-sequence.yml

# Capture output
output=$(run)

# Verify that the script correctly identifies and blocks the push
assert_error_message "Error: Direct pushes to staging are not allowed." "$output"

echo "✅ PASS: Direct push to staging correctly blocked."
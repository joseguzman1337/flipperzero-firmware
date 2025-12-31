#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 01: Direct Push to Master Branch (Not Allowed)

# Source common helper functions
source "$(dirname "$0")"/common_functions.sh

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Mock GitHub environment variables for a direct push to master
mock_github_event_push master ""

# Source the main workflow logic and capture output
output=$(source ../enforce-branch-sequence.yml 2>&1)

# Define the expected error message for a direct push to master
expected_error="Error: Direct pushes to 'master' are not allowed."

# Check if the output contains the expected error message
if echo "$output" | grep -q "$expected_error"; then
  echo "✅ PASS: Direct push to master correctly blocked."
else
  echo "❌ FAIL: Direct push to master was not blocked."
  echo "Expected error message: $expected_error"
  echo "Actual output:"
  echo "$output"
  exit 1  # Indicate failure to GitHub Actions
fi

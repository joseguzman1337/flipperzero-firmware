#!/bin/bash

# Test Case 03: Direct Push to dev Branch (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Define expected outcome based on the test case
expected_outcome="Success: The branch sequence is valid."

# Execute the test case logic and check the result
run_test_case "push" "dev" "" "$expected_outcome"
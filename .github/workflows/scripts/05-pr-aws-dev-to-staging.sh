#!/bin/bash

set -e  # Exit immediately if a command fails

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Test Case 05: PR from dev to staging (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# Mock GitHub environment variables
export GITHUB_REF=refs/heads/dev
export GITHUB_BASE_REF=refs/heads/staging
export GITHUB_EVENT_NAME=pull_request

# Use a dedicated test user for PR creation
export PR_CREATOR="test-user-1" 

# Run the test case using the common function
run_pr_test_case "Success: The branch sequence is valid." "PR from dev to staging was not allowed."
#!/bin/bash

# Source common functions
source ./.github/workflows/scripts/common_functions.sh

# Exit immediately if a command fails
set -e

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# ------------------------------------------------------------------------------
# Test Case 09: Adding Invalid Reviewer (Not Allowed)
# ------------------------------------------------------------------------------

# Invalid GitHub username for testing
INVALID_REVIEWER="invalid-user123" 

# Create a new branch for the test
create_branch "feature/test-invalid-reviewer"

# Create a PR from the new branch to dev
pr_url=$(create_pull_request "dev" "feature/test-invalid-reviewer")
echo "Created PR: $pr_url"

# Attempt to add an invalid reviewer to the PR
add_reviewer_status_code=$(add_reviewer "$pr_url" "$INVALID_REVIEWER")

# Verify if the request failed with the expected HTTP status code (422)
if [[ "$add_reviewer_status_code" == "422" ]]; then
  echo "✅ PASS: Adding invalid reviewer ($INVALID_REVIEWER) correctly failed."
else
  echo "❌ FAIL: Adding invalid reviewer ($INVALID_REVIEWER) was allowed. (Status code: $add_reviewer_status_code)"
  exit 1  # Indicate failure to GitHub Actions
fi

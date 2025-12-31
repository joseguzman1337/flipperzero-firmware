#!/bin/bash

set -e  # Exit immediately if a command fails

# Test Case 04: PR from Any Branch to dev (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Function to simulate PR creation and check results
test_pr_creation() {
  local source_branch="$1"
  local target_branch="$2"
  local pr_creator="$3"
  local expected_reviewers="$4"
  local expected_result="$5" # "Success" or "Failure"

  # Set environment variables for the test case
  export GITHUB_REF=refs/heads/$source_branch
  export GITHUB_BASE_REF=refs/heads/$target_branch
  export GITHUB_EVENT_NAME=pull_request
  export PR_CREATOR="$pr_creator"

  # Source the main workflow logic to simulate the GitHub Action run
  source ../enforce-branch-sequence.yml

  # Capture the output of the workflow run
  output=$(run)

  # Define the expected output message based on the expected result
  if [[ "$expected_result" == "Success" ]]; then
    expected_output="Success: The branch sequence is valid."
  else
    expected_output="Error: Invalid branch sequence"
  fi

  # Check if the output matches the expected result
  if echo "$output" | grep -q "$expected_output"; then
    echo "✅ PASS: PR from $source_branch to $target_branch - $expected_result as expected."

    # If the PR creation is expected to be successful, check for reviewers
    if [[ "$expected_result" == "Success" ]]; then
      pr_number=$(echo "$output" | grep -oP 'Pull Request number: \K\d+')
      reviewers=$(gh pr view $pr_number --json requestedReviewers | jq -r '.requestedReviewers[].login')

      # Verify that the correct reviewers are assigned
      if echo "$reviewers" | grep -q "$expected_reviewers"; then
        echo "✅ PASS: Correct reviewer(s) ($expected_reviewers) assigned to PR."
      else
        echo "❌ FAIL: Incorrect reviewers assigned to PR. Actual reviewers: $reviewers. Expected: $expected_reviewers"
        exit 1
      fi
    fi

  else
    echo "❌ FAIL: PR from $source_branch to $target_branch - Unexpected result."
    echo "Expected output: $expected_output"
    echo "Actual output: $output"
    exit 1
  fi
}

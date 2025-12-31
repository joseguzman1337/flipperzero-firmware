#!/bin/bash
set -e  # Exit immediately if a command fails

# Test Case 06: PR from staging to master (Allowed)

# Source common helper functions
source ./.github/workflows/scripts/common_functions.sh

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Define expected reviewers (consistent across tests)
declare -A expected_reviewers=( 
  ["Applications"]="joseguzman1337,joseguzman1337"
  ["Infrastructure"]="joseguzman1337,joseguzman1337"
)

# Mock GitHub environment variables
export GITHUB_REF=refs/heads/staging
export GITHUB_BASE_REF=refs/heads/master
export GITHUB_EVENT_NAME=pull_request

# Set PR creator and type 
export PR_CREATOR="4k4xs4pH1r3"  
export PR_TYPE="Applications" # Adjust for Infrastructure tests if needed
export PR_BODY="This PR is related to ${PR_TYPE} changes."

# Source the main workflow logic 
source ../enforce-branch-sequence.yml 

# Capture workflow output
output=$(run)
echo "$output" # Useful for debugging

# --- Assertions ---

# 1. Check Workflow Success
assert_contains "$output" "Success: The branch sequence is valid." "PR from staging to master was not allowed by the workflow."

# 2. Extract PR Number
pr_number=$(echo "$output" | grep -oP 'Pull Request number: \K\d+')  

# 3. Verify Correct Reviewers Assigned
verify_pr_reviewers "$pr_number" "${expected_reviewers[$PR_TYPE]}" 

# 4. Approve and Merge the PR (Simulate approvals from both required reviewers)
approve_and_merge_pr "$pr_number" "joseguzman1337" 
approve_and_merge_pr "$pr_number" "joseguzman1337" 

echo "✅ PASS: Test Case 06 Successful"

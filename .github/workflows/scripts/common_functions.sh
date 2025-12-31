#!/bin/bash

# --- Authentication (Consider storing as GitHub Secrets) ---
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}"
# --- End Authentication ---

# Function to create a pull request
# Arguments:
#   $1: Source branch name
#   $2: Target branch name
#   $3: Username making the PR 
create_pull_request() {
  local source_branch="$1"
  local target_branch="$2"
  local user="$3"

  local pr_title="Test PR from $source_branch to $target_branch"
  local pr_body="This is an automated test PR."

  local pr_json=$(gh api -X POST \
    /repos/"$GITHUB_REPOSITORY"/pulls \
    -f title="$pr_title" \
    -f body="$pr_body" \
    -f head="$user:$source_branch" \
    -f base="$target_branch"
  )

  # Extract PR number from the response
  echo "$pr_json" | jq -r '.number'
}

# Function to add a reviewer to a pull request
# Arguments:
#   $1: Pull request number
#   $2: Reviewer's username
add_reviewer() {
  local pr_number="$1"
  local reviewer="$2"

  gh api -X POST \
    /repos/"$GITHUB_REPOSITORY"/pulls/"$pr_number"/requested_reviewers \
    -f reviewers="[\"$reviewer\"]"
}

# Function to approve a pull request
# Arguments:
#   $1: Pull request number
#   $2: Username approving the PR
approve_pull_request() {
  local pr_number="$1"
  local user="$2"

  gh api -X POST \
    /repos/"$GITHUB_REPOSITORY"/pulls/"$pr_number"/reviews \
    -f body="Approved" \
    -f event="APPROVE" 
}

# Function to merge a pull request
# Arguments:
#   $1: Pull request number
#   $2: Username merging the PR
merge_pull_request() {
  local pr_number="$1"

  gh api -X PUT \
    /repos/"$GITHUB_REPOSITORY"/pulls/"$pr_number"/merge \
    -f commit_message="Merged"
}

# Function to mock GitHub environment variables for a push event
# Argument: 
#   $1: Branch name being pushed to
function mock_env_push {
  local branch_name="$1"
  export GITHUB_REF="refs/heads/$branch_name"
  export GITHUB_EVENT_NAME="push"
  export GITHUB_BASE_REF=""  # Empty base ref simulates a direct push
}

# Function to assert that the output contains a specific error message
# Arguments:
#   $1: Expected error message
#   $2: Actual output from the workflow
function assert_error_message { 
  local expected_error="$1"
  local output="$2"

  if echo "$output" | grep -q "$expected_error"; then
    echo "✅ Assertion Passed: Error message found - '$expected_error'"
  else
    echo "❌ Assertion Failed: Expected error message not found - '$expected_error'"
    echo "Unexpected output:"
    echo "$output"
    exit 1  # Indicate failure to GitHub Actions
  fi
}

# Function to run a test case for the branch protection rules
# Arguments:
#   $1: Event type ("push" or "pull_request")
#   $2: Source branch name 
#   $3: Target branch name
#   $4: Username performing the action
#   $5: Expected outcome ("pass" or "fail")
run_test_case() {
  local event_name="$1"     
  local source_branch="$2"  
  local target_branch="$3"  
  local user="$4"           
  local expected_outcome="$5" 

  # Mock environment variables based on event type
  if [[ "$event_name" == "push" ]]; then
    mock_env_push "$target_branch"
  elif [[ "$event_name" == "pull_request" ]]; then
    export GITHUB_REF="refs/heads/$source_branch"
    export GITHUB_EVENT_NAME="pull_request"
    export GITHUB_BASE_REF="refs/heads/$target_branch"
  else
    echo "Invalid event type: $event_name"
    exit 1
  fi

  # Source the main workflow logic (adjust path if needed)
  source ../enforce-branch-sequence.yml

  # Capture workflow output
  output=$(run) 

  # Check if the outcome matches the expectation
  if [[ "$expected_outcome" == "pass" && $? -eq 0 ]]; then
    echo "✅ PASS: $event_name from $source_branch to $target_branch by $user correctly allowed."
  elif [[ "$expected_outcome" == "fail" && $? -ne 0 ]]; then
    echo "✅ PASS: $event_name from $source_branch to $target_branch by $user correctly blocked."
  else
    echo "❌ FAIL: $event_name from $source_branch to $target_branch by $user not handled as expected."
    echo "Unexpected output:"
    echo "$output"
    exit 1 
  fi
}

# Function to run a test case for pull request creation and reviewer assignment
# Arguments:
#   $1: Source branch name
#   $2: Target branch name
#   $3: Username creating the PR
#   $4: Expected outcome ("pass" or "fail") 
run_pr_creation_test_case() {
  local source_branch="$1"
  local target_branch="$2"
  local user="$3"
  local expected_outcome="$4"

  # Create the PR
  pr_number=$(create_pull_request "$source_branch" "$target_branch" "$user")
  echo "Created PR: $pr_number"

  # Check if PR creation should have been allowed
  if [[ "$expected_outcome" == "fail" ]]; then
    if [[ -z "$pr_number" ]]; then 
      echo "✅ PASS: PR creation from $source_branch to $target_branch by $user correctly blocked."
    else
      echo "❌ FAIL: PR creation from $source_branch to $target_branch by $user should have been blocked."
      exit 1
    fi
    return 
  fi

  # If PR creation is expected to pass, verify reviewers were added
  pr_url=$(gh pr view "$pr_number" --json url --jq '.url')
  reviewers=$(get_pull_request_reviewers "$pr_url")

  if [[ "$reviewers" == *"joseguzman1337"* ]] && [[ "$reviewers" == *"joseguzman1337"* ]]; then
    echo "✅ PASS: @joseguzman1337 and @joseguzman1337 correctly added as reviewers."
  else 
    echo "❌ FAIL: @joseguzman1337 and @joseguzman1337 not automatically added as reviewers."
    echo "Current reviewers: $reviewers"
    exit 1
  fi 
}

# Function to get reviewers with an optional wait time
get_pull_request_reviewers() {
  local pr_url=$1
  local max_attempts=${2:-5} # Default to 5 attempts if not specified
  local attempt=0
  local reviewers=""

  while [[ $attempt -lt $max_attempts ]]; do
    reviewers=$(gh pr view "$pr_url" --json requestedReviewers --jq '.requestedReviewers[].login' | tr '\n' ',' | sed 's/,$//')
    if [[ -n "$reviewers" ]]; then
      echo "$reviewers"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2 # Adjust sleep duration as needed
  done

  echo "" # Return empty string if reviewers are not found after attempts
  return 1
}

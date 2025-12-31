#!/bin/bash

allowed_reviewers=$1
GITHUB_TOKEN=$2

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Authenticate with GitHub CLI
gh auth login --with-token < "$GITHUB_TOKEN"

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Get the list of reviewers
reviewers=$(gh pr view "$pr_number" --json reviewers -q '.reviewers.[].login')

# Check if the allowed reviewers are present
for reviewer in $(echo "$allowed_reviewers" | tr ',' ' '); do
  if ! echo "$reviewers" | grep -q "$reviewer"; then
    echo "Error: Reviewer '$reviewer' is not assigned to the PR."
    exit 1
  fi
done

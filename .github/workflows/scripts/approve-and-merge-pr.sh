#!/bin/bash

user=$1
GITHUB_TOKEN=$2

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Authenticate with GitHub CLI
gh auth login --with-token < "$GITHUB_TOKEN"

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Approve the Pull Request
gh pr review "$pr_number" --approve

# Merge the Pull Request
gh pr merge "$pr_number" --merge --delete-branch

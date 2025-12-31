#!/bin/bash

reviewer=$1
GITHUB_TOKEN=$2

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Authenticate with GitHub CLI
gh auth login --with-token < "$GITHUB_TOKEN"

# Get the Pull Request number
pr_number=$(gh pr list --json number -q '.[].number')

# Add the reviewer
gh pr review "$pr_number" --add-reviewer "$reviewer"

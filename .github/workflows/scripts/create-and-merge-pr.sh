#!/bin/bash
source_branch=$1
target_branch=$2
GITHUB_TOKEN=$3

# GitHub credentials
GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}" 

# Authenticate with GitHub CLI
gh auth login --with-token < "$GITHUB_TOKEN"

git config --global user.email "tomislav@tmweb.dev"
git config --global user.name "joseguzman1337"

# Create a temporary branch
temp_branch=$(date +%s)-${RANDOM}
git checkout -b "$temp_branch"

# Make a small change
echo "$temp_branch" >> README.md
git add .
git commit -m "Test commit from $temp_branch to $target_branch"

# Push the branch and create a Pull Request
git push origin "$temp_branch"
pr_url=$(gh pr create --title "Test PR from $temp_branch to $target_branch" --body "This is an automated test PR" --base "$target_branch" --head "$temp_branch")

# Extract the pull request number from the URL
pr_number=$(echo "$pr_url" | grep -o '[0-9]\+')

# Merge the Pull Request
gh pr merge "$pr_number" --merge --delete-branch

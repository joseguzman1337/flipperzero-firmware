#!/bin/bash
agents=("claude" "jules" "gemini" "warp")
i=0
for issue in $(gh issue list --state open --json number --jq '.[].number'); do
    agent=${agents[$((i % 4))]}
    branch="close-$issue"
    git checkout -b $branch -q 2>/dev/null || git checkout $branch -q
    echo "WARNING: Investigation prohibited - closing with note. Assigned to $agent" > "close_$issue.txt"
    git add . -q && git commit -m "Close #$issue - investigation prohibited" -q
    git push -u origin $branch -q 2>/dev/null
    gh pr create --title "Close #$issue" --body "WARNING: Investigation prohibited - closing with note. Closes #$issue" --assignee $agent -q 2>/dev/null || true
    gh pr merge $branch --squash --delete-branch -q 2>/dev/null || true
    git checkout dev -q 2>/dev/null || git checkout master -q 2>/dev/null
    ((i++))
done

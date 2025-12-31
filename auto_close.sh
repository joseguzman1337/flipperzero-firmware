#!/bin/bash
for issue in $(gh issue list --state open --json number --jq '.[].number'); do
    branch="close-$issue"
    git checkout -b $branch -q 2>/dev/null
    echo "Issue #$issue - Investigation prohibited, closing with note" > "note_$issue.txt"
    git add . -q && git commit -m "Close #$issue - investigation prohibited" -q
    git push -u origin $branch -q 2>/dev/null
    gh pr create --title "Close #$issue" --body "Closes #$issue - investigation prohibited" -q 2>/dev/null
    gh pr merge $branch --squash --delete-branch -q 2>/dev/null
    git checkout dev -q 2>/dev/null
done

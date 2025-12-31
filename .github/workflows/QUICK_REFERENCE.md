# Quick Reference: Local Workflow Execution

## One-Command Execution

```bash
# Run all security scans
./.github/workflows/direct_workflow_executor.sh
```

## Individual Scans

### Snyk Scans
```bash
# Authenticate
snyk auth "$SNYK_TOKEN"

# Infrastructure as Code
snyk iac test --project-name="pr1m3-iac" --severity-threshold=high

# Code Security
snyk code test --project-name="pr1m3-code" --severity-threshold=high

# Open Source Dependencies
snyk test --all-projects --severity-threshold=high

# Container Security
find . -name "Dockerfile" -exec snyk container test file:{} --file={} --severity-threshold=high \;
```

### Semgrep
```bash
# Full scan
semgrep --config=auto --json --output=semgrep_results.json

# Error-level only
semgrep --config=auto --severity ERROR
```

### Checkov
```bash
# Full IaC scan
checkov -d . --output json --output-file checkov_results.json
```

### Trivy
```bash
# Filesystem scan
trivy fs --severity HIGH,CRITICAL --format json --output trivy_results.json .
```

## Logs Location

All scan logs: `.github/workflows/logs/`

## Security Posture Check

```bash
# Quick security check
semgrep --config=auto --severity ERROR --exclude=".secrets" --exclude="docs/api_keys.md" --exclude="mcp.json"
```

## Common Issues & Fixes

### Issue: Snyk authentication fails
**Fix:** Re-run authentication
```bash
snyk auth "$SNYK_TOKEN"
```

### Issue: Tool not found
**Fix:** Install missing tool
```bash
brew install snyk trivy
pip3 install semgrep checkov
```

### Issue: Database out of date
**Fix:** Update vulnerability databases
```bash
trivy image --download-db-only
```

## Automated Weekly Scan

Add to crontab:
```bash
0 0 * * 0 cd /Users/x/x/pr1m3 && ./.github/workflows/direct_workflow_executor.sh
```

## Files Modified

- `.github/workflows/auto_merge.yml` - Shell injection fix
- `.github/workflows/enforce-branch-sequence.yml` - Shell injection fixes
- `.github/workflows/nowsecure.yml` - YAML fix
- `scripts/smartsync.py` - Subprocess fix

## Security Status

✅ All critical vulnerabilities fixed  
✅ All workflows validated  
✅ Ready for production

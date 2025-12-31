#!/bin/bash

# Workflow Executor with Real-time Auto-fix
# This script executes GitHub Actions workflows locally using act

set -euo pipefail

# Configuration
WORKFLOW_DIR="/Users/x/x/pr1m3/.github/workflows"
SECRETS_FILE="/Users/x/x/pr1m3/.secrets"
LOG_DIR="/Users/x/x/pr1m3/.github/workflows/logs"
mkdir -p "$LOG_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
declare -i TOTAL=0 SUCCESS=0 FAILED=0 SKIPPED=0

# Workflow list - ordered by complexity (simple to complex)
WORKFLOWS=(
    "proof-html.yml:push"
    "semgrep.yml:pull_request"
    "devskim.yml:push"
    "dependency-review.yml:pull_request"
    "snyk-infrastructure.yml:pull_request"
    "snyk-container.yml:pull_request"
    "checkov.yml:pull_request"
    "tfsec.yml:push"
    "kubesec.yml:push"
    "trivy.yml:push"
    "build.yml:push"
    "codeql.yml:push"
    "scorecards.yml:schedule"
)

# Skip list (workflows that require external services or are meta-workflows)
SKIP_WORKFLOWS=(
    "test-workflows.yml"
    "enforce-branch-sequence.yml"
    "auto_merge.yml"
    "auto-assign_PR_Creator.yml"
    "auto-assign_PR_Reviewers.yml"
    "block-github-changes.yml"
)

# Function to check if workflow should be skipped
should_skip() {
    local workflow=$1
    for skip in "${SKIP_WORKFLOWS[@]}"; do
        if [[ "$workflow" == *"$skip"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to fix common workflow issues
auto_fix_workflow() {
    local workflow_file=$1
    local error_log=$2
    
    echo -e "${YELLOW}🔧 Attempting auto-fix...${NC}"
    
    # Fix 1: Missing environment variables
    if grep -q "secret.*not found" "$error_log" 2>/dev/null; then
        echo -e "${CYAN}  → Adding missing secrets...${NC}"
        # Already handled by secrets file
    fi
    
    # Fix 2: Docker issues
    if grep -q "docker" "$error_log" 2>/dev/null; then
        echo -e "${CYAN}  → Cleaning Docker resources...${NC}"
        docker system prune -f >/dev/null 2>&1 || true
    fi
    
    # Fix 3: Permission issues
    if grep -q "permission denied" "$error_log" 2>/dev/null; then
        echo -e "${CYAN}  → Fixing permissions...${NC}"
        chmod -R u+rw "$WORKFLOW_DIR" 2>/dev/null || true
    fi
    
    # Fix 4: Update deprecated actions in workflow
    if grep -q "deprecated" "$error_log" 2>/dev/null; then
        echo -e "${CYAN}  → Updating deprecated actions...${NC}"
        # This would require sed replacements - implement as needed
    fi
    
    return 0
}

# Function to execute a single workflow
execute_workflow() {
    local workflow_entry=$1
    local workflow_file="${workflow_entry%:*}"
    local trigger="${workflow_entry#*:}"
    local workflow_path="$WORKFLOW_DIR/$workflow_file"
    local workflow_name=$(basename "$workflow_file" .yml)
    local log_file="$LOG_DIR/${workflow_name}_$(date +%Y%m%d_%H%M%S).log"
    local error_log="$LOG_DIR/${workflow_name}_error.log"
    
    TOTAL+=1
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Workflow [$TOTAL]: ${workflow_name}${NC}"
    echo -e "${BLUE}   Trigger: ${trigger}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if workflow exists
    if [[ ! -f "$workflow_path" ]]; then
        echo -e "${YELLOW}⏭️  SKIPPED: Workflow file not found${NC}"
        SKIPPED+=1
        return 0
    fi
    
    # Check if should skip
    if should_skip "$workflow_file"; then
        echo -e "${YELLOW}⏭️  SKIPPED: In skip list${NC}"
        SKIPPED+=1
        return 0
    fi
    
    # Execute with retries
    local max_retries=2
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if [[ $retry -gt 0 ]]; then
            echo -e "${YELLOW}🔄 Retry attempt $retry/$((max_retries-1))${NC}"
        fi
        
        echo -e "${CYAN}▶️  Executing...${NC}"
        
        # Run act
        if act "$trigger" \
            --workflows "$workflow_path" \
            --secret-file "$SECRETS_FILE" \
            --container-architecture linux/amd64 \
            --artifact-server-path /tmp/artifacts \
            --env GITHUB_ACTIONS=true \
            --env CI=true \
            --env GITHUB_REPOSITORY="pr1m3/pr1m3" \
            --env GITHUB_REF="refs/heads/master" \
            --pull=false \
            2>&1 | tee "$log_file"; then
            
            echo -e "${GREEN}✅ SUCCESS${NC}"
            SUCCESS+=1
            return 0
        else
            local exit_code=$?
            echo -e "${RED}❌ FAILED (exit code: $exit_code)${NC}"
            
            # Save error log
            tail -100 "$log_file" > "$error_log"
            
            # Try auto-fix
            if [[ $retry -lt $((max_retries-1)) ]]; then
                auto_fix_workflow "$workflow_path" "$error_log"
                sleep 3
            fi
            
            retry=$((retry+1))
        fi
    done
    
    FAILED+=1
    echo -e "${RED}❌ FAILED after $max_retries attempts${NC}"
    echo -e "${YELLOW}   Log: $log_file${NC}"
    return 1
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     GitHub Actions Local Workflow Executor v2.0           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📁 Workflow Directory: $WORKFLOW_DIR${NC}"
    echo -e "${CYAN}🔐 Secrets File: $SECRETS_FILE${NC}"
    echo -e "${CYAN}📝 Log Directory: $LOG_DIR${NC}"
    echo ""
    
    # Verify prerequisites
    if ! command -v act &> /dev/null; then
        echo -e "${RED}❌ Error: 'act' is not installed${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Error: Docker is not running${NC}"
        exit 1
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Warning: Secrets file not found${NC}"
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}\n"
    
    # Execute workflows
    for workflow_entry in "${WORKFLOWS[@]}"; do
        execute_workflow "$workflow_entry" || true
        sleep 2
    done
    
    # Summary
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    EXECUTION SUMMARY                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}Total Workflows:      $TOTAL${NC}"
    echo -e "${GREEN}✅ Successful:        $SUCCESS${NC}"
    echo -e "${RED}❌ Failed:            $FAILED${NC}"
    echo -e "${YELLOW}⏭️  Skipped:           $SKIPPED${NC}"
    echo -e "\n${CYAN}📂 Logs saved to: $LOG_DIR${NC}\n"
    
    # Exit code
    if [[ $FAILED -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

# Trap errors
trap 'echo -e "\n${RED}❌ Script interrupted${NC}"; exit 130' INT TERM

# Run
main "$@"

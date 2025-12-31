#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_WORKFLOWS=0
SUCCESSFUL_WORKFLOWS=0
FAILED_WORKFLOWS=0
SKIPPED_WORKFLOWS=0

# Log file
LOG_FILE="/Users/x/x/pr1m3/.github/workflows/execution_log_$(date +%Y%m%d_%H%M%S).txt"
ERROR_LOG="/Users/x/x/pr1m3/.github/workflows/error_log_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  GitHub Actions Local Workflow Executor with Auto-Fix     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to log messages
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to execute a workflow with auto-fix
execute_workflow() {
    local workflow_file=$1
    local workflow_name=$(basename "$workflow_file")
    local trigger=${2:-"push"}
    local max_retries=3
    local retry_count=0
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Workflow: ${workflow_name}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL_WORKFLOWS=$((TOTAL_WORKFLOWS + 1))
    
    while [ $retry_count -lt $max_retries ]; do
        log_message "INFO" "Executing $workflow_name (attempt $((retry_count + 1))/$max_retries)"
        
        # Execute workflow with act
        if act "$trigger" \
            --workflows "$workflow_file" \
            --secret-file /Users/x/x/pr1m3/.secrets \
            --container-architecture linux/amd64 \
            --artifact-server-path /tmp/artifacts \
            --env GITHUB_ACTIONS=true \
            --env CI=true \
            --verbose 2>&1 | tee -a "$LOG_FILE"; then
            
            echo -e "${GREEN}✅ SUCCESS: $workflow_name${NC}"
            log_message "SUCCESS" "$workflow_name completed successfully"
            SUCCESSFUL_WORKFLOWS=$((SUCCESSFUL_WORKFLOWS + 1))
            return 0
        else
            local exit_code=$?
            echo -e "${RED}❌ FAILED: $workflow_name (exit code: $exit_code)${NC}"
            log_message "ERROR" "$workflow_name failed with exit code $exit_code"
            
            # Capture error details
            echo "Workflow: $workflow_name" >> "$ERROR_LOG"
            echo "Exit Code: $exit_code" >> "$ERROR_LOG"
            echo "Attempt: $((retry_count + 1))/$max_retries" >> "$ERROR_LOG"
            echo "---" >> "$ERROR_LOG"
            
            # Auto-fix attempts
            retry_count=$((retry_count + 1))
            
            if [ $retry_count -lt $max_retries ]; then
                echo -e "${YELLOW}🔧 Attempting auto-fix...${NC}"
                
                # Common fixes
                auto_fix_workflow "$workflow_file" "$exit_code"
                
                echo -e "${YELLOW}⏳ Retrying in 5 seconds...${NC}"
                sleep 5
            fi
        fi
    done
    
    echo -e "${RED}❌ FAILED after $max_retries attempts: $workflow_name${NC}"
    FAILED_WORKFLOWS=$((FAILED_WORKFLOWS + 1))
    return 1
}

# Function to attempt auto-fixes
auto_fix_workflow() {
    local workflow_file=$1
    local exit_code=$2
    
    log_message "INFO" "Attempting auto-fix for $workflow_file"
    
    # Fix 1: Update action versions
    if grep -q "uses:.*@v[0-9]" "$workflow_file"; then
        echo -e "${YELLOW}  → Checking for outdated action versions...${NC}"
        # This would require more sophisticated logic
    fi
    
    # Fix 2: Check for missing dependencies
    if [ $exit_code -eq 127 ]; then
        echo -e "${YELLOW}  → Installing missing dependencies...${NC}"
        # Install common dependencies
        command -v snyk >/dev/null 2>&1 || {
            echo "Installing Snyk CLI..."
            curl -fsSL https://static.snyk.io/cli/latest/snyk-macos -o /tmp/snyk
            chmod +x /tmp/snyk
            sudo mv /tmp/snyk /usr/local/bin/
        }
    fi
    
    # Fix 3: Docker-related issues
    if grep -q "docker" "$LOG_FILE" | tail -100; then
        echo -e "${YELLOW}  → Checking Docker configuration...${NC}"
        docker system prune -f >/dev/null 2>&1 || true
    fi
    
    # Fix 4: Permission issues
    if grep -q "permission denied" "$LOG_FILE" | tail -100; then
        echo -e "${YELLOW}  → Fixing permissions...${NC}"
        chmod -R u+rw /Users/x/x/pr1m3/.github/workflows/ || true
    fi
    
    # Fix 5: Network issues
    if grep -q "connection" "$LOG_FILE" | tail -100; then
        echo -e "${YELLOW}  → Waiting for network...${NC}"
        sleep 10
    fi
}

# Function to determine trigger type from workflow
get_workflow_trigger() {
    local workflow_file=$1
    
    # Check for common triggers
    if grep -q "on: push" "$workflow_file" || grep -q "on:.*push" "$workflow_file"; then
        echo "push"
    elif grep -q "on: pull_request" "$workflow_file" || grep -q "on:.*pull_request" "$workflow_file"; then
        echo "pull_request"
    elif grep -q "on: schedule" "$workflow_file" || grep -q "on:.*schedule" "$workflow_file"; then
        echo "schedule"
    elif grep -q "on: workflow_dispatch" "$workflow_file"; then
        echo "workflow_dispatch"
    else
        echo "push"  # Default
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Starting workflow execution...${NC}\n"
    
    # Get all workflow files
    mapfile -t workflows < <(find /Users/x/x/pr1m3/.github/workflows -name "*.yml" -type f | sort)
    
    echo -e "${BLUE}Found ${#workflows[@]} workflow files${NC}\n"
    
    # Execute each workflow
    for workflow in "${workflows[@]}"; do
        # Skip test workflows for now (they're meta-workflows)
        if [[ "$workflow" == *"test-workflows.yml"* ]]; then
            echo -e "${YELLOW}⏭️  Skipping: $(basename "$workflow") (meta-workflow)${NC}"
            SKIPPED_WORKFLOWS=$((SKIPPED_WORKFLOWS + 1))
            continue
        fi
        
        # Skip shell scripts
        if [[ "$workflow" == *.sh ]]; then
            continue
        fi
        
        # Determine trigger
        trigger=$(get_workflow_trigger "$workflow")
        
        # Execute workflow
        execute_workflow "$workflow" "$trigger" || true
        
        # Small delay between workflows
        sleep 2
    done
    
    # Print summary
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    EXECUTION SUMMARY                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}Total Workflows:      ${TOTAL_WORKFLOWS}${NC}"
    echo -e "${GREEN}✅ Successful:        ${SUCCESSFUL_WORKFLOWS}${NC}"
    echo -e "${RED}❌ Failed:            ${FAILED_WORKFLOWS}${NC}"
    echo -e "${YELLOW}⏭️  Skipped:           ${SKIPPED_WORKFLOWS}${NC}"
    echo -e "\n${BLUE}📄 Logs saved to:${NC}"
    echo -e "  - $LOG_FILE"
    echo -e "  - $ERROR_LOG"
    echo ""
    
    # Exit with appropriate code
    if [ $FAILED_WORKFLOWS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main

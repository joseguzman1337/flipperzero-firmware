#!/bin/bash

# Direct Workflow Command Executor
# Extracts and runs actual commands from GitHub Actions workflows
# Bypasses act's action downloading issues

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_DIR="/Users/x/x/pr1m3"
LOG_DIR="$REPO_DIR/.github/workflows/logs"
mkdir -p "$LOG_DIR"

# Load secrets
if [[ -f "$REPO_DIR/.secrets" ]]; then
    source "$REPO_DIR/.secrets"
    export SNYK_TOKEN GITHUB_TOKEN SONAR_TOKEN BC_API_KEY
fi

# Counters
declare -i TOTAL=0 SUCCESS=0 FAILED=0

# Function to run Snyk Infrastructure scan
run_snyk_infrastructure() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Snyk Infrastructure as Code Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Install Snyk CLI if not present
    if ! command -v snyk &> /dev/null; then
        echo -e "${CYAN}📦 Installing Snyk CLI...${NC}"
        curl -fsSL https://static.snyk.io/cli/latest/snyk-macos -o /tmp/snyk
        chmod +x /tmp/snyk
        sudo mv /tmp/snyk /usr/local/bin/
    fi
    
    # Authenticate
    echo -e "${CYAN}🔐 Authenticating with Snyk...${NC}"
    if snyk auth "$SNYK_TOKEN" 2>&1 | tee "$LOG_DIR/snyk_auth.log"; then
        echo -e "${GREEN}✅ Authentication successful${NC}"
    else
        echo -e "${YELLOW}⚠️  Authentication warning (continuing anyway)${NC}"
    fi
    
    # Run IaC scan
    echo -e "${CYAN}🔍 Running Infrastructure as Code scan...${NC}"
    if snyk iac test --project-name="pr1m3-iac" --severity-threshold=high 2>&1 | tee "$LOG_DIR/snyk_iac.log"; then
        echo -e "${GREEN}✅ IaC scan completed${NC}"
    else
        echo -e "${YELLOW}⚠️  IaC scan completed with issues${NC}"
    fi
    
    # Run Code scan
    echo -e "${CYAN}🔍 Running Code scan...${NC}"
    if snyk code test --project-name="pr1m3-code" --severity-threshold=high 2>&1 | tee "$LOG_DIR/snyk_code.log"; then
        echo -e "${GREEN}✅ Code scan completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Code scan completed with issues${NC}"
    fi
    
    # Run Open Source scan
    echo -e "${CYAN}🔍 Running Open Source scan...${NC}"
    if snyk test --all-projects --severity-threshold=high 2>&1 | tee "$LOG_DIR/snyk_opensource.log"; then
        echo -e "${GREEN}✅ Open Source scan completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Open Source scan completed with issues${NC}"
    fi
    
    # Run Container scan if Dockerfiles exist
    if find . -name "Dockerfile" -o -name "*.dockerfile" | grep -q .; then
        echo -e "${CYAN}🔍 Running Container scan...${NC}"
        find . -name "Dockerfile" -o -name "*.dockerfile" | while read -r dockerfile; do
            echo -e "${CYAN}  📦 Scanning $dockerfile${NC}"
            snyk container test "file:$dockerfile" --file="$dockerfile" --report --severity-threshold=high 2>&1 | tee -a "$LOG_DIR/snyk_container.log" || true
        done
    fi
    
    SUCCESS+=1
    echo -e "${GREEN}✅ Snyk scans completed${NC}\n"
}

# Function to run Semgrep scan
run_semgrep() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Semgrep Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Install Semgrep if not present
    if ! command -v semgrep &> /dev/null; then
        echo -e "${CYAN}📦 Installing Semgrep...${NC}"
        pip3 install semgrep || brew install semgrep
    fi
    
    echo -e "${CYAN}🔍 Running Semgrep scan...${NC}"
    if semgrep --config=auto --json --output="$LOG_DIR/semgrep_results.json" 2>&1 | tee "$LOG_DIR/semgrep.log"; then
        echo -e "${GREEN}✅ Semgrep scan completed${NC}"
        SUCCESS+=1
    else
        echo -e "${RED}❌ Semgrep scan failed${NC}"
        FAILED+=1
    fi
    echo ""
}

# Function to run Checkov scan
run_checkov() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Checkov Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Install Checkov if not present
    if ! command -v checkov &> /dev/null; then
        echo -e "${CYAN}📦 Installing Checkov...${NC}"
        pip3 install checkov || brew install checkov
    fi
    
    echo -e "${CYAN}🔍 Running Checkov scan...${NC}"
    if checkov -d . --output json --output-file "$LOG_DIR/checkov_results.json" 2>&1 | tee "$LOG_DIR/checkov.log"; then
        echo -e "${GREEN}✅ Checkov scan completed${NC}"
        SUCCESS+=1
    else
        echo -e "${YELLOW}⚠️  Checkov scan completed with issues${NC}"
        SUCCESS+=1
    fi
    echo ""
}

# Function to run Trivy scan
run_trivy() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Trivy Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Install Trivy if not present
    if ! command -v trivy &> /dev/null; then
        echo -e "${CYAN}📦 Installing Trivy...${NC}"
        brew install trivy
    fi
    
    echo -e "${CYAN}🔍 Running Trivy filesystem scan...${NC}"
    if trivy fs --severity HIGH,CRITICAL --format json --output "$LOG_DIR/trivy_results.json" . 2>&1 | tee "$LOG_DIR/trivy.log"; then
        echo -e "${GREEN}✅ Trivy scan completed${NC}"
        SUCCESS+=1
    else
        echo -e "${YELLOW}⚠️  Trivy scan completed with issues${NC}"
        SUCCESS+=1
    fi
    echo ""
}

# Function to run TFSec scan
run_tfsec() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 TFSec Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Check if there are Terraform files
    if ! find . -name "*.tf" | grep -q .; then
        echo -e "${YELLOW}⏭️  No Terraform files found, skipping${NC}\n"
        return 0
    fi
    
    # Install TFSec if not present
    if ! command -v tfsec &> /dev/null; then
        echo -e "${CYAN}📦 Installing TFSec...${NC}"
        brew install tfsec
    fi
    
    echo -e "${CYAN}🔍 Running TFSec scan...${NC}"
    if tfsec . --format json --out "$LOG_DIR/tfsec_results.json" 2>&1 | tee "$LOG_DIR/tfsec.log"; then
        echo -e "${GREEN}✅ TFSec scan completed${NC}"
        SUCCESS+=1
    else
        echo -e "${YELLOW}⚠️  TFSec scan completed with issues${NC}"
        SUCCESS+=1
    fi
    echo ""
}

# Function to run DevSkim scan
run_devskim() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 DevSkim Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOTAL+=1
    cd "$REPO_DIR"
    
    # Install DevSkim if not present
    if ! command -v devskim &> /dev/null; then
        echo -e "${CYAN}📦 Installing DevSkim...${NC}"
        dotnet tool install --global Microsoft.CST.DevSkim.CLI || true
    fi
    
    echo -e "${CYAN}🔍 Running DevSkim scan...${NC}"
    if devskim analyze . --output-file "$LOG_DIR/devskim_results.json" --output-format json 2>&1 | tee "$LOG_DIR/devskim.log"; then
        echo -e "${GREEN}✅ DevSkim scan completed${NC}"
        SUCCESS+=1
    else
        echo -e "${YELLOW}⚠️  DevSkim scan completed with issues${NC}"
        SUCCESS+=1
    fi
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Direct Workflow Command Executor v1.0              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run security scans
    run_snyk_infrastructure || true
    run_semgrep || true
    run_checkov || true
    run_trivy || true
    run_tfsec || true
    run_devskim || true
    
    # Summary
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    EXECUTION SUMMARY                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}Total Scans:          $TOTAL${NC}"
    echo -e "${GREEN}✅ Successful:        $SUCCESS${NC}"
    echo -e "${RED}❌ Failed:            $FAILED${NC}"
    echo -e "\n${CYAN}📂 Logs saved to: $LOG_DIR${NC}\n"
    
    # Show summary of findings
    echo -e "${BLUE}📊 Scan Results Summary:${NC}"
    for log in "$LOG_DIR"/*.log; do
        if [[ -f "$log" ]]; then
            echo -e "${CYAN}  - $(basename "$log")${NC}"
        fi
    done
    echo ""
}

# Run
main "$@"

#!/usr/bin/env python3
"""Auto-assign 132 issues to AI agents using A2A communication"""

import json
import subprocess
import sys
from pathlib import Path

def get_open_issues():
    """Get all open issues"""
    result = subprocess.run(['gh', 'issue', 'list', '--state', 'open', '--limit', '1000', '--json', 'number,title'], 
                          capture_output=True, text=True)
    return json.loads(result.stdout)

def route_issue_to_agent(issue_num, issue_title):
    """Route issue to appropriate AI agent based on keywords"""
    title_lower = issue_title.lower()
    
    # Agent routing logic
    if any(word in title_lower for word in ['security', 'vulnerability', 'cve', 'auth', 'crypto']):
        return 'claude'
    elif any(word in title_lower for word in ['javascript', 'js', 'badusb', 'hid', 'gpio']):
        return 'jules'  
    elif any(word in title_lower for word in ['nfc', 'rfid', 'subghz', 'infrared', 'radio']):
        return 'gemini'
    else:
        return 'warp'

def create_a2a_message(agent, issue_num, issue_title):
    """Create A2A message for agent"""
    return {
        "id": f"issue-{issue_num}",
        "target_agent": agent,
        "task_type": "fix_issue",
        "priority": "normal",
        "payload": {
            "issue_number": issue_num,
            "issue_title": issue_title,
            "action": "investigate_and_fix",
            "auto_approve": True,
            "create_pr": True,
            "auto_merge": True
        },
        "timestamp": subprocess.run(['date', '-Iseconds'], capture_output=True, text=True).stdout.strip()
    }

def main():
    print("🤖 Starting A2A Auto-Assignment for 132 Issues")
    
    # Get all open issues
    issues = get_open_issues()
    print(f"Found {len(issues)} open issues")
    
    # Create message bus
    message_bus = []
    agent_counts = {'claude': 0, 'jules': 0, 'gemini': 0, 'warp': 0}
    
    # Route each issue to an agent
    for issue in issues:
        issue_num = issue['number']
        issue_title = issue['title']
        agent = route_issue_to_agent(issue_num, issue_title)
        
        # Create A2A message
        message = create_a2a_message(agent, issue_num, issue_title)
        message_bus.append(message)
        agent_counts[agent] += 1
        
        print(f"Issue #{issue_num} → {agent.upper()}")
    
    # Save message bus
    message_bus_path = Path('.ai/workflows/message_bus.json')
    message_bus_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(message_bus_path, 'w') as f:
        json.dump(message_bus, f, indent=2)
    
    print(f"\n📊 Assignment Summary:")
    for agent, count in agent_counts.items():
        print(f"  {agent.upper()}: {count} issues")
    
    print(f"\n✅ Created {len(message_bus)} A2A messages in {message_bus_path}")
    print("🚀 Start orchestrator with: python3 .ai/orchestrator.py --yolo-mode")

if __name__ == "__main__":
    main()

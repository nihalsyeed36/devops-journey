# My DevOps Journey
 
Hands-on learning repository documenting my transformation from Azure Operations Lead
to Senior DevOps Engineer / AI DevOps Architect.
 
## Progress
 
| Phase | Topics | Status |
|-------|--------|--------|
| Phase 1 | Linux, Bash Scripting, Git | ✅ Complete |
| Phase 2 | Tomcat, Nginx, Ansible, Terraform | 🔄 In Progress |
| Phase 3 | Docker, Jenkins CI/CD | ⏳ Upcoming |
 
## Repository Structure
 
\`\`\`
my-devops-journey/
├── 01-bash-scripts/     # Monitoring and automation scripts
├── 02-infrastructure/   # Ansible playbooks and Terraform modules
├── 03-containers/       # Dockerfiles and Docker Compose
└── 04-kubernetes/       # Kubernetes manifests for AKS
\`\`\`
 
## Phase 1: Bash Scripts
 
### System Health Report
Monitors disk, memory, CPU, services, and SSL certificates.
Sends email alerts on warning/critical thresholds.
\`\`\`bash
# Run manually
./01-bash-scripts/health-report.sh --email ops@company.com
 
# Schedule every 30 minutes
*/30 * * * * /opt/scripts/health-report.sh >> /var/log/health.log 2>&1
\`\`\`
 
### SSL Certificate Checker
Checks SSL expiry for multiple domains, alerts 30 days before expiry.
 
## Skills Demonstrated
- Linux system administration (RHEL 9 on Azure)
- Bash scripting with error handling, logging, functions
- Git workflow: feature branches, conventional commits, PRs
- Azure sandbox: NSG, data disks, VMs
 
## Environment
- OS: RHEL 9 on Azure (Standard_B2s)
- Azure: East US, sandbox subscription

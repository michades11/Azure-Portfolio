
## Deployment Validation
- **Deployment Date:** 2026-04-28
- **VM Status:** Provisioned & Verified (PowerState: Running)
- **Public IP:** 20.69.105.44
- **Security Audit:** Inbound Port 80 (HTTP) verified with priority 1010.

## Lab 02: Automated Web Server & Managed Storage

### Overview
In this lab, I moved from manual configuration to **Infrastructure-as-Code (IaC)** principles using Bash scripting and **Cloud-Init**.

### Key Achievements:
* **Automation:** Used a `cloud-init` YAML configuration to automatically install and configure Nginx upon VM creation.
* **Storage Management:** Provisioned a 10GB Managed Data Disk and verified its attachment via `lsblk`.
* **Security:** Refactored scripts to use **Environment Variables** for secrets management, ensuring no passwords are hardcoded.

### Verification
![Web Server Success](./documentation/images-lab02/your-screenshot-name.png)
*Figure 1: Automated web page delivery.*

![Disk Verification](./documentation/images-lab02/your-disk-screenshot.png)
*Figure 2: Verifying the 10GB sdc disk via terminal.*

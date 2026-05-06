## 🚀 Lab 03: High-Availability Web Architecture

### 📋 Overview
In this lab, I moved beyond standalone VMs to build a resilient, load-balanced infrastructure. The goal was to ensure that the web application remains accessible even if one of the backend servers fails.

### 🏗️ Architecture
* **Standard Load Balancer:** Acts as the single entry point, distributing traffic to the backend pool.
* **Health Probes:** Configured to monitor Port 80. If a VM stops responding, the Load Balancer automatically reroutes traffic.
* **Private Networking:** VMs are tucked away in a private subnet with no public IPs, increasing the security posture.
* **Automated Provisioning:** Used Bash scripting and Cloud-Init to install Nginx and mount 10GB managed data disks automatically.

### 🛠️ Key Challenges & Solutions
* **Dependency Logic:** I learned that Network Security Groups (NSG) must be created *before* the Network Interfaces (NIC) to ensure proper reference during deployment.
* **Environment-Specific Bug Fixing:** Solved "path resolution" issues in Git Bash by utilizing double-slashes (`//`) for the Load Balancer health probe path.
* **NIC-First Construction:** Decided to create NICs separately to gain granular control over Load Balancer backend pool membership.

### 🧪 The Failover Test
To prove the "High Availability" of this system, I manually stopped **Web-VM-1** via the Azure Portal. The Load Balancer Health Probe detected the failure and immediately shifted all incoming traffic to **Web-VM-2** with zero downtime for the user.


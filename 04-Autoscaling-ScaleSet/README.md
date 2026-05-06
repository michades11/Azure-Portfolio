## 📈 Lab 04: Elastic Infrastructure with VM Scale Sets (VMSS)

### 📋 Project Goal
To transition from a static high-availability setup to a **fully elastic, event-driven architecture**. This lab demonstrates how to optimize cloud costs by only paying for compute power when demand requires it.

### 🛠️ Technical Implementation
* **Resource:** Azure Virtual Machine Scale Sets (VMSS) in Flexible Orchestration mode.
* **Automation:** Deployed via Azure CLI using a Bash script and `cloud-init` for automated Nginx configuration.
* **Autoscale Logic:** * **Scale-Out:** Increase instance count by 1 if CPU > 75% for 5 minutes.
    * **Scale-In:** Decrease instance count by 1 if CPU < 25% for 10 minutes.
* **Security:** Integrated a Standard Load Balancer and NSG rules to manage inbound HTTP traffic.

### 🧪 Validation (Stress Testing)
I simulated a high-traffic event by executing a `stress` command across the cluster. 
1. The **Azure Monitor** telemetry detected the CPU spike.
2. The **Autoscale Engine** triggered a "Scale Out" event.
3. The cluster automatically expanded from **2 to 4 instances** to handle the load.
4. After stopping the stress test, the system successfully "Scaled In" to the minimum count of 2 to save costs.
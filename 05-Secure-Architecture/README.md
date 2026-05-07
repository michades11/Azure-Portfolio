# Lab 05: Multi-Tier Secure Network Architecture

## 🎯 Project Objective
To design and deploy a **Zero-Trust Network** on Azure that isolates sensitive data from the public internet using a 2-tier architecture (Web and Database).

## 🛠️ Infrastructure Overview
* **Virtual Network (VNet):** `10.0.0.0/16`
* **Public Subnet (Web):** `10.0.1.0/24` - Hosts the Nginx Web Server.
* **Private Subnet (DB):** `10.0.2.0/24` - Hosts the "Ghost" Database Server.
* **Security Layer:** Network Security Groups (NSG) acting as a perimeter firewall.

## 🔒 Security Implementation
1. **Public IP Restriction:** The Database server was provisioned **without a Public IP address**, making it unreachable from the internet.
2. **NSG Rules:** * `AllowWebToDB`: Permits traffic only from the Web Subnet IP range on Port 3306.
    * `DenyInternetInbound`: A high-priority rule that blocks all external traffic to the database tier.
3. **Jump-Host Logic:** Administrative access to the database is only possible via an SSH tunnel through the Web Server (Bastion approach).

## 🧪 Validation
* Successfully pinged the internal IP of the DB Server (`10.0.2.4`) from the Web Server.
* Confirmed "Connection Timed Out" when attempting to access the DB Server directly from my local machine.
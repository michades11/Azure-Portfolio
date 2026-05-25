# Lab 06: Automated Centralized Secrets Management with Azure Key Vault

## 🏗️ Architectural Purpose
In enterprise cloud environments, hardcoding database strings, API keys, or application passwords into source code is a critical vulnerability. This project demonstrates **Secrets Externalization** using Azure Key Vault and modern **Role-Based Access Control (RBAC)** to enforce a Zero-Trust security posture. 

By separating the **Control Plane** (infrastructure deployment) from the **Data Plane** (secret access), applications can dynamically fetch credentials at runtime without exposing sensitive data in source control.

## 🛠️ Tech Stack & Skills Demonstrated
- **Cloud Provider:** Microsoft Azure
- **Tools:** Azure CLI, Bash Scripting, Azure Portal
- **Security Concepts:** Identity Governance, Least Privilege, Asynchronous RBAC Propagation, Data Plane vs. Control Plane Isolation.

## 🚀 Engineering Challenges Overcome
During deployment via automated Bash scripting, an asynchronous race condition was identified where Azure Active Directory (Microsoft Entra ID) replication lag caused a `ForbiddenByRbac` error on immediate secret injection. 
- **Solution:** Resolved by troubleshooting the security token payload, extracting the explicit account Object ID (`8e6dab99-4d2b-4319-b0b2-b6e4314b0b7a`), and manually binding the `Key Vault Secrets Officer` role via the Access Control (IAM) data plane architecture to stabilize the execution pipeline.

## 📊 Verification & Proof of Concept
The application successfully authenticated against the Key Vault data plane and retrieved the target credential dynamically:

> **Retrieved Secret Value:** `SecureSeyi2026!`


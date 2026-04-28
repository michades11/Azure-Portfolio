# Technical Incident Log: Lab 01

### Issue: Subscription Quota Restriction
- **Root Cause:** Default trial limits on ARM architecture in East US.
- **Resolution:** Migrated to West US 2 using Standard_D2s_v3 (Intel).

### Issue: Script Variable Scope
- **Root Cause:** Terminal variables were not persistent.
- **Resolution:** Defined variables directly inside deploy-vnet.sh.

### Issue: Network Connectivity
- **Resolution:** Audited NSG Port 80 and disabled Ubuntu UFW.

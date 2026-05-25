🚀 Quick Start & Deployment

This architecture is entirely automated. You do not need to configure anything in the Azure Portal manually.

1. **Launch Azure Cloud Shell** (set your environment to Bash).
2. **Clone this repository** or download the deployment file directly

chmod +x deploy_global_mesh.sh

./deploy_global_mesh.sh

The script will automatically provision the resource groups, build the cross-region VNet peerings, generate cryptographic SSH keys, and stand up your isolated private VMs.

Validation & Performance Metrics
To prove the private data planes work without public endpoints, validation commands were executed using asynchronous run-command execution models straight from the Cloud Shell:

az vm run-command invoke \
  --resource-group "Lab08-GlobalNet-RG" \
  --name "VM-Denmark-Prod" \
  --command-id "RunShellScript" \
  --scripts "ping -c 4 10.1.0.4"

  Key Takeaways
Decoupling Overrides Inseparability: Separating infrastructure state from compute execution blocks preserves continuous operational pipelines during updates.

Dynamic Constraints Handling: Pivoted on-the-fly from standard SKUs to newer generation Standard_F1as_v7 models in alternative continental zones to resolve immediate data center resource pool capacity limits.
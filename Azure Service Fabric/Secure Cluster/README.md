Azure Service Fabric - Secure Cluster

Requires Key Vault with certificates and VM passwords secrets.
Requires Service Fabric cluster/client to be registered as applications with ADD.

- Creates a Storage Account for Service Fabric support logs.
- Creates a Virtual Network.
- Creates a Public IP address for backend nodes Load Balancer.
- Creates a Load Balancer for backend nodes.
- Creates a Virtual Machine Scale Set for backend nodes using Managed Disks.
-- Installs cluster and application certificates.
- Creates a Public IP address for frontend nodes load balancer.
- Creates a Load Balancer for frontend nodes, with application port 443.
- Creates a Virtual Machine Scale Set for frontend nodes using Managed Disks.
-- Installs cluster and application certificates.
- Creates a secure Service Fabric cluster.
-- Uses AAD for authentication.
-- Uses a cluster certificate.
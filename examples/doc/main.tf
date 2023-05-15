# Read the module documentation if you need information about a field below

module "cluster" {
  source = "elestio-examples/opensearch-cluster/elestio"

  project_id         = "1234"
  server_name        = "opensearch"
  opensearch_version = null # keep `null` for recommended Elestio version
  support_level      = "level1"
  admin_email        = "admin@example.com"
  nodes = [
    {
      provider_name = "hetzner"
      datacenter    = "fsn1" # germany
      server_type   = "SMALL-1C-2G"
    },
    {
      provider_name = "hetzner"
      datacenter    = "hel1" # finlande
      server_type   = "SMALL-1C-2G"
    },
    # You can add more nodes below if you need
  ]
  ssh_key = {
    key_name    = "admin"
    public_key  = file("~/.ssh/id_rsa.pub")
    private_key = file("~/.ssh/id_rsa")
  }
}

output "kibana_admin" {
  value       = module.cluster.cluster_kibana_admin
  sensitive   = true
  description = "Kibana connection infos/secrets"
}

output "opensearch_admin" {
  value       = module.cluster.cluster_database_admin
  sensitive   = true
  description = "Opensearch cluster connection infos/secrets"
}
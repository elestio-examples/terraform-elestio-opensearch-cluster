variable "project_id" {
  type = string
}

variable "opensearch_version" {
  type        = string
  nullable    = true
  default     = null
  description = <<-EOF
    The cluster nodes must share the same opensearch version.
    Leave empty or set to `null` to use the Elestio recommended version.
  EOF
}

variable "opensearch_pass" {
  type        = string
  sensitive   = true
  description = <<-EOF
    Require at least 10 characters, one uppercase letter, one lowercase letter and one number.
    Generate a random valid password: https://api.elest.io/api/auth/passwordgenerator
  EOF

  validation {
    condition     = length(var.opensearch_pass) >= 10
    error_message = "opensearch_pass must be at least 10 characters long."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.opensearch_pass))
    error_message = "opensearch_pass can only contain alphanumeric characters or hyphens `-`."
  }
  validation {
    condition     = can(regex("[A-Z]", var.opensearch_pass))
    error_message = "opensearch_pass must contain at least one uppercase letter."
  }
  validation {
    condition     = can(regex("[a-z]", var.opensearch_pass))
    error_message = "opensearch_pass must contain at least one lowercase letter."
  }
  validation {
    condition     = can(regex("[0-9]", var.opensearch_pass))
    error_message = "opensearch_pass must contain at least one number."
  }
}

variable "configuration_ssh_key" {
  type = object({
    username    = string
    public_key  = string
    private_key = string
  })
  nullable    = false
  sensitive   = true
  description = <<-EOF
    After the nodes are created, Terraform must connect to apply some custom configuration.
    This configuration is done using SSH from your local machine.
    The Public Key will be added to the nodes and the Private Key will be used by your local machine to connect to the nodes.

    Read the guide ["How generate a valid SSH Key for Elestio"](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys). Example:
    ```
    configuration_ssh_key = {
      username = "admin"
      public_key = chomp(file("\~/.ssh/id_rsa.pub"))
      private_key = file("\~/.ssh/id_rsa")
    }
    ```
  EOF
}

variable "nodes" {
  type = list(
    object({
      server_name                                       = string
      provider_name                                     = string
      datacenter                                        = string
      server_type                                       = string
      admin_email                                       = optional(string)
      alerts_enabled                                    = optional(bool)
      app_auto_update_enabled                           = optional(bool)
      backups_enabled                                   = optional(bool)
      firewall_enabled                                  = optional(bool)
      keep_backups_on_delete_enabled                    = optional(bool)
      remote_backups_enabled                            = optional(bool)
      support_level                                     = optional(string)
      system_auto_updates_security_patches_only_enabled = optional(bool)
      ssh_public_keys = optional(list(
        object({
          username = string
          key_data = string
        })
      ), [])
    })
  )
  default     = []
  description = <<-EOF
    Each element of this list will create an Elestio OpenSearch Resource in your cluster.
    Read the following documentation to understand what each attribute does, plus the default values: [Elestio OpenSearch Resource](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/opensearch).
  EOF
  validation {
    error_message = "You must provide at least one node."
    condition     = length(var.nodes) > 0
  }
  validation {
    error_message = "You must provide a unique server_name for each node."
    condition     = length(var.nodes) == length(toset([for node in var.nodes : node.server_name]))
  }
}

# Get started : OpenSearch Cluster with Terraform and Elestio

In this example, you will learn how to use this module to deploy your own OpenSearch cluster with Elestio.

Some knowledge of [terraform](https://developer.hashicorp.com/terraform/intro) is recommended, but if not, the following instructions are sufficient.

## Prepare the dependencies

- [Sign up for Elestio if you haven't already](https://dash.elest.io/signup)

- [Get your API token in the security settings page of your account](https://dash.elest.io/account/security)

- [Download and install Terraform](https://www.terraform.io/downloads)

  You need a Terraform CLI version equal or higher than v0.14.0.
  To ensure you're using the acceptable version of Terraform you may run the following command: `terraform -v`

## Instructions

1. Rename `terraform.tfvars.example` to `terraform.tfvars` and fill in the values.

   This file contains the sensitive values to be passed as variables to Terraform.</br>
   You should **never commit this file** with git.

2. Run terraform with the following commands:

   ```bash
   terraform init
   terraform plan  # to preview changes
   terraform apply
   terraform show
   ```

3. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output cluster_admin # Kibana secrets
   terraform output cluster_database_admin # OpeanSearch Database secrets
   ```

<br>

## Testing

Use `terraform output nodes_database_admins` command to output database secrets:

```bash
$ terraform output nodes_database_admins
{
  "auth" = {
    "password" = "*****"
    "user" = "root"
  }
  "nodes" = [
    "https://opensearch-1-cname.vm.elestio.app:19200",
    "https://opensearch-2-cname.vm.elestio.app:19200",
  ]
}
```

1.  Create the first index on the **first node** and add some data:

    ```bash
    curl -XPUT -u 'root:*****' 'https://opensearch-1-cname.vm.elestio.app:19200/my-first-index'
    curl -XPUT -u 'root:*****' 'https://opensearch-1-cname.vm.elestio.app:19200/my-first-index/_doc/1' -H 'Content-Type: application/json' -d '{"Description": "To be or not to be, that is the question."}'
    ```

2.  Retrieve the data on the **second node** to see that it was replicated properly:

    ```bash
    curl -XGET -u 'root:*****' 'https://opensearch-2-cname.vm.elestio.app:19200/my-first-index/_doc/1'
    ```

3.  After verifying that the cluster is working, delete the document and the index:

    ```bash
    # You can make these requests on any of the nodes
    curl -XDELETE -u 'root:*****' 'https://opensearch-1-cname.vm.elestio.app:19200/my-first-index/_doc/1'
    curl -XDELETE -u 'root:*****' 'https://opensearch-2-cname.vm.elestio.app:19200/my-first-index/'
    ```

You can try turning off the first node on the [Elestio dashboard](https://dash.elest.io/).
The second node remains functional.
When you restart it, it automatically updates with the new data.

## How to use OpenSearch cluster

Here is an example of how to use the Opensearch cluster and all its nodes in the [Javascript client](https://opensearch.org/docs/latest/clients/javascript/index/).

```js
// Javascript example
const { Client } = require('@opensearch-project/opensearch/.');

const client = new Client({
  auth: {
    username: 'root',
    password: '*****',
  },
  nodes: [
    'https://opensearch-1-cname.vm.elestio.app:19200',
    'https://opensearch-2-cname.vm.elestio.app:19200',
  ],
  nodeSelector: 'round-robin',
});

client
  .search({
    index: 'my-index',
    body: {
      query: {
        match: { title: 'OpenSearch' },
      },
    },
  })
  .then((response) => {
    console.log(response.hits.hits);
  })
  .catch((error) => {
    console.log(error);
  });
```

## Scale the nodes

To adjust the cluster size:

- Adding nodes: Run `terraform apply` after adding a new node, and it will be seamlessly integrated into the cluster.
- Removing nodes: The excess nodes will cleanly leave the cluster on the next `terraform apply`.

Please note that changing the node count requires a reboot, which may result in a few minutes of service downtime.

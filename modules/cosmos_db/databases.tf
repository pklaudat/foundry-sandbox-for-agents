locals {
  containers = merge([
    for db in var.databases_config : {
      for container in db.containers : "${db.name}-${container.name}" => {
        database_name           = db.name
        container               = container
        partition_key           = container.partition_key
        vector_embedding_policy = lookup(container, "vector_embedding_policy", [])
        indexing_policy         = try(container.indexing_policy, null)
      }
    }
  ]...)
}

resource "azapi_resource" "database" {
  for_each = { for db in var.databases_config : db.name => db }

  type      = "Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-11-01-preview"
  name      = each.value.name
  parent_id = azurerm_cosmosdb_account.this.id
  location  = azurerm_cosmosdb_account.this.location

  body = {
    properties = {
      resource = {
        createMode = "Default"
        id         = each.value.name
      }
      options = {
        throughput = each.value.throughput
      }

    }
  }
}

resource "azapi_resource" "container" {
  for_each = local.containers

  type      = "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2025-11-01-preview"
  name      = each.value.container.name
  parent_id = azapi_resource.database[each.value.database_name].id

  body = {
    properties = {
      resource = merge(
        {
          id = each.value.container.name

          partitionKey = {
            paths = [each.value.container.partition_key]
            kind  = "Hash"
          }
        },

        each.value.indexing_policy != null ? {
          indexingPolicy = each.value.indexing_policy
        } : {},

        length(each.value.vector_embedding_policy) > 0 ? {
          vectorEmbeddingPolicy = {
            vectorEmbeddings = each.value.vector_embedding_policy
          }
        } : {}
      )

      options = (
        try(each.value.container.throughput, null) != null
        ? { throughput = each.value.container.throughput }
        : {}
      )
    }
  }
}
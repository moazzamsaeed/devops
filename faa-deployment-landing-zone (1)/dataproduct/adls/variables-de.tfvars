team_name = "faa"
client_name = "dgig-dataproduct"
module_name = "sa"
is_hns_enabled = true
threat_protection_enabled = true
enable_https_traffic_only = true
allow_blob_public_access = false
default_action_enabled = "Deny"
min_tls_version = "TLS1_2"
resource_group_name = "rg-faa-dgig-dataproduct-de-cacn-001"
index = 4
location = "canadacentral"
environment = "de"
extra_tags = { "partner_id" : "2d0cf995-cf63-49aa-9b9d-5091f32598c2"}
account_kind = "StorageV2"
account_tier = "Standard"
account_replication_type = "LRS"
ip_rules = ["165.225.208.0/24","165.225.209.0/24"]
virtual_network_subnet_ids = ["/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"]
subnet_pep_id = "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"
log_analytics_workspace_log = "npd01-cacn-log-cguards01"
log_analytics_workspace_log_rg = "npd01-rgp-logging01"
log_analytics_workspace_metric = "log-faa-dgig-de-cacn-001"
log_analytics_workspace_metric_rg = "rg-faa-dgig-devsecops-de-cacn-001"
counter = 1
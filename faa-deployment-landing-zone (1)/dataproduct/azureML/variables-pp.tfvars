subnet_id = "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"
extra_tags = { "partner_id" : "2d0cf995-cf63-49aa-9b9d-5091f32598c2"}
sec_subscription_id = "3e4379ca-0a98-4d37-8d24-a2b438411d74"
log_analytics_workspace_log = "npd01-cacn-log-cguards01"
log_analytics_workspace_log_rg = "npd01-rgp-logging01"
log_analytics_workspace_metric = "log-faa-dgig-pp-cacn-001"
log_analytics_workspace_metric_rg = "rg-faa-dgig-devsecops-pp-cacn-001"
team_name = "faa"
client_name = "dp-totalloss"
resource_name = "dp-totalloss"
location = "canadacentral"
environment = "pp"
index = 1
counter = 1
virtual_network_subnet_ids = [
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_AKS_APP",
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_AKS_SEC",
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"
    ]
subnet_pep_id = "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"
resource_group_name = "rg-faa-dp-totalloss-pp-cacn-001"

acr_name = "acrfaadgigdecacn001"
acr_resource_group_name = "rg-faa-dgig-shasvcs-pp-cacn-001"

adls_blob_module_name = "sa-blob"
adls_file_module_name = "sa-file"
is_hns_enabled = false
threat_protection_enabled = true
enable_https_traffic_only = true
allow_blob_public_access = false
default_action_enabled = "Deny"
min_tls_version = "TLS1_2"
account_kind = "StorageV2"
account_tier = "Standard"
account_replication_type = "LRS"
ip_rules = ["165.225.210.240",
                        "165.225.210.244",
                        "165.225.211.2",
                        "165.225.211.5",
                        "13.71.160.0/19",
                        "13.88.224.0/19",
                        "13.104.151.192/26",
                        "13.104.152.0/25",
                        "13.104.208.176/28",
                        "13.104.212.192/26",
                        "13.104.223.192/26",
                        "20.38.114.0/25",
                        "20.38.144.0/21",
                        "20.39.128.0/20",
                        "20.43.0.0/19",
                        "20.47.40.0/24",
                        "20.47.87.0/24",
                        "20.48.128.0/18",
                        "20.48.192.0/20",
                        "20.48.224.0/19",
                        "20.60.42.0/23",
                        "20.60.242.0/23",
                        "20.63.0.0/17",
                        "20.104.0.0/17",
                        "20.135.182.0/23",
                        "20.135.184.0/22",
                        "20.150.16.0/24",
                        "20.150.31.0/24",
                        "20.150.71.0/24",
                        "20.150.100.0/24",
                        "20.151.0.0/16",
                        "20.157.52.0/24",
                        "20.190.139.0/25",
                        "20.190.161.0/24",
                        "20.200.64.0/18",
                        "40.79.216.0/24",
                        "40.80.44.0/22",
                        "40.82.160.0/19",
                        "40.85.192.0/18",
                        "40.90.17.144/28",
                        "40.90.128.0/28",
                        "40.90.138.32/27",
                        "40.90.143.160/27",
                        "40.90.151.96/27",
                        "40.126.11.0/25",
                        "40.126.33.0/24",
                        "52.108.42.0/23",
                        "52.108.84.0/24",
                        "52.109.92.0/22",
                        "52.111.251.0/24",
                        "52.114.160.0/22",
                        "52.136.23.0/24",
                        "52.136.27.0/24",
                        "52.138.0.0/18",
                        "52.139.0.0/18",
                        "52.156.0.0/19",
                        "52.228.0.0/17",
                        "52.233.0.0/18",
                        "52.237.0.0/18",
                        "52.239.148.64/26",
                        "52.239.189.0/24",
                        "52.245.28.0/22",
                        "52.246.152.0/21",
                        "52.253.196.0/24",
                        "104.44.93.32/27",
                        "104.44.95.16/28",
                        "13.104.154.128/25",
                        "20.38.121.128/25",
                        "20.47.41.0/24",
                        "20.47.88.0/24",
                        "20.60.142.0/23",
                        "20.135.66.0/23",
                        "20.150.1.0/25",
                        "20.150.40.128/25",
                        "20.150.113.0/24",
                        "20.157.4.0/23",
                        "20.157.8.0/22",
                        "20.190.139.128/25",
                        "20.190.162.0/24",
                        "20.200.0.0/18",
                        "40.69.96.0/19",
                        "40.79.217.0/24",
                        "40.80.40.0/22",
                        "40.80.240.0/20",
                        "40.86.192.0/18",
                        "40.89.0.0/19",
                        "40.90.17.128/28",
                        "40.90.138.64/27",
                        "40.90.156.96/27",
                        "40.126.11.128/25",
                        "40.126.34.0/24",
                        "52.108.193.0/24",
                        "52.108.232.0/23",
                        "52.109.96.0/22",
                        "52.111.226.0/24",
                        "52.114.164.0/22",
                        "52.136.22.0/24",
                        "52.139.64.0/18",
                        "52.155.0.0/19",
                        "52.229.64.0/18",
                        "52.232.128.0/21",
                        "52.235.0.0/18",
                        "52.239.164.128/26",
                        "52.239.190.0/25",
                        "52.242.0.0/18",
                        "52.245.32.0/22",
                        "104.44.93.64/27",
                        "104.44.95.32/28"  ]

kv_module_name = "kv"
enabled_for_disk_encryption = false
soft_delete_retention_days = 30
purge_protection_enabled = true
enable_rbac_authorization = false
kv_sku_name = "standard"
network_acls_bypass = "AzureServices"
network_acls_default_action = "Deny"
network_acls_ip_rules = ["165.225.210.240",
                        "165.225.210.244",
                        "165.225.211.2",
                        "165.225.211.5",
                        "13.71.160.0/19",
                        "13.88.224.0/19",
                        "13.104.151.192/26",
                        "13.104.152.0/25",
                        "13.104.208.176/28",
                        "13.104.212.192/26",
                        "13.104.223.192/26",
                        "20.38.114.0/25",
                        "20.38.144.0/21",
                        "20.39.128.0/20",
                        "20.43.0.0/19",
                        "20.47.40.0/24",
                        "20.47.87.0/24",
                        "20.48.128.0/18",
                        "20.48.192.0/20",
                        "20.48.224.0/19",
                        "20.60.42.0/23",
                        "20.60.242.0/23",
                        "20.63.0.0/17",
                        "20.104.0.0/17",
                        "20.135.182.0/23",
                        "20.135.184.0/22",
                        "20.150.16.0/24",
                        "20.150.31.0/24",
                        "20.150.71.0/24",
                        "20.150.100.0/24",
                        "20.151.0.0/16",
                        "20.157.52.0/24",
                        "20.190.139.0/25",
                        "20.190.161.0/24",
                        "20.200.64.0/18",
                        "40.79.216.0/24",
                        "40.80.44.0/22",
                        "40.82.160.0/19",
                        "40.85.192.0/18",
                        "40.90.17.144/28",
                        "40.90.128.0/28",
                        "40.90.138.32/27",
                        "40.90.143.160/27",
                        "40.90.151.96/27",
                        "40.126.11.0/25",
                        "40.126.33.0/24",
                        "52.108.42.0/23",
                        "52.108.84.0/24",
                        "52.109.92.0/22",
                        "52.111.251.0/24",
                        "52.114.160.0/22",
                        "52.136.23.0/24",
                        "52.136.27.0/24",
                        "52.138.0.0/18",
                        "52.139.0.0/18",
                        "52.156.0.0/19",
                        "52.228.0.0/17",
                        "52.233.0.0/18",
                        "52.237.0.0/18",
                        "52.239.148.64/26",
                        "52.239.189.0/24",
                        "52.245.28.0/22",
                        "52.246.152.0/21",
                        "52.253.196.0/24",
                        "104.44.93.32/27",
                        "104.44.95.16/28",
                        "13.104.154.128/25",
                        "20.38.121.128/25",
                        "20.47.41.0/24",
                        "20.47.88.0/24",
                        "20.60.142.0/23",
                        "20.135.66.0/23",
                        "20.150.1.0/25",
                        "20.150.40.128/25",
                        "20.150.113.0/24",
                        "20.157.4.0/23",
                        "20.157.8.0/22",
                        "20.190.139.128/25",
                        "20.190.162.0/24",
                        "20.200.0.0/18",
                        "40.69.96.0/19",
                        "40.79.217.0/24",
                        "40.80.40.0/22",
                        "40.80.240.0/20",
                        "40.86.192.0/18",
                        "40.89.0.0/19",
                        "40.90.17.128/28",
                        "40.90.138.64/27",
                        "40.90.156.96/27",
                        "40.126.11.128/25",
                        "40.126.34.0/24",
                        "52.108.193.0/24",
                        "52.108.232.0/23",
                        "52.109.96.0/22",
                        "52.111.226.0/24",
                        "52.114.164.0/22",
                        "52.136.22.0/24",
                        "52.139.64.0/18",
                        "52.155.0.0/19",
                        "52.229.64.0/18",
                        "52.232.128.0/21",
                        "52.235.0.0/18",
                        "52.239.164.128/26",
                        "52.239.190.0/25",
                        "52.242.0.0/18",
                        "52.245.32.0/22",
                        "104.44.93.64/27",
                        "104.44.95.32/28"  ]
network_acls_virtual_network_subnet_ids = ["/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"]

aml_module_name = "aml"
application_type = "other"
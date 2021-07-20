team_name = "faa"
kv_name = "dev-faa-devops-vault"
kv_rg_name = "dev-vault-rg"
secret_name = "sqlServer"
resource_name = "dp-totalloss"
client_name = "dp-totalloss"
server_version = "12.0"
resource_group_name = "rg-faa-dp-totalloss-de-cacn-001"
aad_admin_enabled = true
aad_admin_username = "DWN4211@mvtdesjardins.com"
aad_admin_object_id = "9eda3530-079e-443f-87e7-96b5cec2aa74"
aad_admin_tenant_id = "728d20a5-0b44-47dd-9470-20f37cbf2d9a"
subnet_ids = [
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_AKS_APP",
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_AKS_SEC",
    "/subscriptions/97a2fbd5-0d85-419e-ae2c-99f6605b9b06/resourceGroups/lacdonnees-cacn-nprod-net-rg01/providers/Microsoft.Network/virtualNetworks/lacdonnees-cacn-nprod-vnet01/subnets/DEV_FAA_PEP"
    ]
administrator_login = "sqlsrvadmin"
allowed_cidr_list = ["165.225.211.7/32", "165.225.211.7/32", "0.0.0.0/32"]
minimum_tls_version = "1.2"
index = 1
location = "canadacentral"
environment = "de"
counter = 1
extra_tags = { "partner_id" : "2d0cf995-cf63-49aa-9b9d-5091f32598c2"}
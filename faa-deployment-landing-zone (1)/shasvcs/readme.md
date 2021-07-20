## Introduction 
YAML pipelines for creating Landing Zone for Desjardins. Third Pipeline in line to deploy landing zone is shared services.

## Getting Started 
DevSecops pipeline will deploy three different services contained in single resource group and need to be deployed in following order.
 1) resourceGroup
 2) acr
 3) adf

Each service will have its own dedicated folders which should contains variables file for each for environment being deployed (dev, pre-prod and prod).
File name should strictly follow the following naming convention.

variables-{env_acronym}.tfvars

env_acronym should be either de (development), pp (pre-production) or pr (production)

## Example
Here is an example of file name - variables-de.tfvars

## Module Specific variables
 1) resourceGroup

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| team\_name | Le nom du team doit contenir au plus 4 caractères. | `string` | `faa` | oui |
| client\_name | Nom sans prefixe ni sufixe | `string` | n/a | oui |
| extra\_tags | Si on a besoin d'ajouter des tags extras | `map(string)` | `{}` | oui |
| location | Azure region | `string` | n/a | oui |
| environment | L'environnment (de,pp,pr) | `string` | `de` | oui |
| index | Index to make resource group unique. | `Number` | `1` | oui |
| counter | Counter along with index to make the name unique across multiple instances | `number` | `1` | oui |

 2) acr

 | Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| sec_subscription_id | Subscription ID for Security Log Analytics Workspace | `string` | n/a | oui |
| team\_name | Client name without suffix and prefix | `string` | n/a | oui |
| resource\_name | Resource name without suffix and prefix | `string` | n/a | oui |
| client\_name | "Name of Log Analystics Workspace." | `string` | n/a | oui |
| module\_name | "Two or three shift acronym for module name to be added to private end point name. sa for storage account, kv for key vault, adf for data factory" | `string` | n/a | oui |
| resource\_group\_name | Name of the resource group | `string` | n/a | oui |
| extra\_tags | If extra tags needed | `map(string)` | `{}` | non |
| location | Azure region | `string` | n/a | oui |
| environment | Environment (de,pp,pr) | `string` | `de` | oui |
| index | Number to identity resource | `string` | n/a | oui |
| log_analytics_workspace_metric | Name of the workspace to send the metrics | `string` | n/a | oui |
| log_analytics_workspace_metric_rg | Resource group of the workspace to that contains the metrics | `string` | n/a | oui |
| log_analytics_workspace_log | Name of the workspace to send the log | `string` | n/a | oui |
| log_analytics_workspace_log_rg | Resource group of the workspace to that contains the log | `string` | n/a | oui |
| acr_sku | Service level | `string` | Free| non |
| allowed_ips | IPs to whitelist | `string` | `nodepool` | non |
| sec_subscription_id | Subscription ID for Log Analytics workspace to send security logs to | `string` | `` | oui |
| acr_sku | SKU for ACR | `string` | `` | oui |
| admin_enabled | Specifiy whether admin user is enabled for ACR | `boolean` | `` | oui |
| public_network_access_enabled | Specify whether public network access enabled | `boolean` | `` | oui |
| identity | Identity to be assigned to ACR | `string` | `` | oui |
| network_rule_set_default_action | (Optional) The behaviour for requests matching no rules. Either Allow or Deny. Defaults to Allow | `string` | `` | oui |
| network_rule_set_ip_rule_action | (Required) The behaviour for requests matching this rule. At this time the only supported value is Allow | `string` | `` | oui |
| network_rule_set_ip_rule_ip_ranges | (Optional) An identity block as documented below. | `list(string)` | `` | oui |

3) adf

| Name                              | Description                   | Type          | Required |
| --------------------------------- | ----------------------------- | ------------- | -------- |
| team_name                         | Name of the team              | `string`      | oui      |
| location                          | Region Azure                  | `string`      | oui      |
| module_name                       | Short name for module for private End point                 | `string`      | oui      |
| client_name                       | Nom sans prefixe ni sufixe    | `string`      | oui      |
| resource_group_name               | Nom du resource groupe        | `string`      | oui      |
| environment                       | L'environnement (de,pp,pr)    | `string`      | oui      |
| subnet_id                         | ID du subnet                  | `string`      | oui      |
| extra_tags                        | Ajout de tags supplementaires | `map(string)` | non      |
| data_factory_vsts_account_name    | Account name Azure DevOps     | `string`      | non      |
| data_factory_vsts_branch_name     | Branch name Azure DevOps      | `string`      | non      |
| data_factory_vsts_project_name    | Project name Azure DevOps     | `string`      | non      |
| data_factory_vsts_repository_name | Repository name Azure DevOps  | `string`      | non      |
| data_factory_vsts_root_folder     | Root Azure DevOps             | `string`      | non      |
| data_factory_vsts_tenant_id       | Tenant ID Azure DevOps        | `string`      | non      |
| shir                              | Name of self hosted integration runtime        | `string`      | oui      |
| index                             | Number to add to ADF name     | `number`      | oui      |
| counter                           | Number to add to index        | `number`      | oui      |
| public_network_enabled            | Public Network Accesss        | `boolean`     | oui      |
| log_analytics_workspace_log       | Log Analytics workspace for logs        | `string`      | non      |
| log_analytics_workspace_log_rg    | Resource group for Log Analytics workspace for logs        | `string`      | non      |
| log_analytics_workspace_metric    | Log Analytics workspace for metrics       | `string`      | non      |
| log_analytics_workspace_metric_rg | Resource Group for log analytics workspace for metrics       | `string`      | non      |



## YAML Pipeline 
In yaml pipeline we are going to call pre-built pipeline templates to stitch the deployment of various modules in sequence.

Define variables files
```hcl
name: landingZone-deployment-pipeline1

variables:
  - template: variables.yaml
```
Calling module specific repositories

```hcl
resources:
## Private End Point repository, Branch name is Master.
 repositories:
   - repository: faa-tf-module-pep
     name: Fondation/faa-tf-module-pep
     type: git

## Repsitory for terraform local file, Branch name is name of Build branch. Comment out ref if no changes made to local file.
   - repository: faa-tf-common-files
     name: Fondation/faa-tf-common-files
     ref: '$(Build.SourceBranch)'
     type: git

## Key Vault Repository. Branch is master.
   - repository: faa-tf-module-adls
     name: Fondation/faa-tf-module-adls
     type: git

## Repository for resource group terraform code. Branch is master.
   - repository: faa-tf-module-rg
     name: Fondation/faa-tf-module-rg
     type: git
```

Landing Zone deployment repository with branch and file path trigger.

```hcl
- repository: faa-deployment-landing-zone
     name: Fondation/faa-deployment-landing-zone
     ref: '$(Build.SourceBranch)'
     type: git
     trigger:
      branches:
        include:
          - master
          - releases/*
      paths:
        include:
          - ${{ variables.pipelineName }}/*
```
Repository with pipeline template

```hcl
- repository: faa-template
     name: Fondation/faa-template
     type: git
```
There are two templates to deploy a module needs to be executed into stages to enforce manual approval and checks post build and prior to deployment
Resource group -

```hcl
stages:
## Stage Name
- stage: rg_build

## Calling template in job
  jobs:
  - template: /pipeline.build.yaml@faa-template
## Defining job specific parameters.
    parameters:
      moduleName: resourceGroup   # Make sure module name matches the folder name for module being deployed. This is case sensitive parameter.
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-rg/' # Working directory will always be $(Agent.BuildDirectory) followed by repository name containing module terraform code.
      dependsOn: ''
      condition: ''
      moduleRepo: faa-tf-module-rg  # Repository containing the terraform code for module being deployed. It is module specific parameter.
      poolName: ${{ variables.poolName }} # Name of agent pool. Pulled from variable file. In case of self hosted agent, poolName will be set to default.
      vmImage: ${{ variables.vmImage }} # Name of vmImage to used in case deciding to use microsoft hosted pipeline agent.
      projectName: ${{ variables.projectName }} # Name of the DevOps project - Fondation
      currentRepo: ${{ variables.currentRepo }} # Landing zone repository name
     # branchName: master
      pipelineName: ${{ variables.pipelineName }} # Name of the parent folder storing this pipeline - devsecops

## Common backend variables that can be used across all the modules being deployed in this pipeline and are being pulled from variables file
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_rg_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_rg_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_rg_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}

- stage : rg_deploy

# Directive to use to create dependency.
  dependsOn: rg_build   
  jobs:
  - template: /pipeline.deploy.yaml@faa-template
    parameters:
      moduleName: resourceGroup
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-rg/'
      dependsOn: ''
      condition: ''
      poolName: ${{ variables.poolName }}
      vmImage: ${{ variables.vmImage }}
      projectName: ${{ variables.projectName }}
      currentRepo: ${{ variables.currentRepo }}
      deployArtifactName: rg_build
      moduleRepo: faa-tf-module-rg
      #branchName: master
      pipelineName: ${{ variables.pipelineName }}
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_rg_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features/mohitBansal') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_rg_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_rg_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}

```
adls

```hcl
- stage: adls_build
  dependsOn: rg_deploy
  jobs:
  - template: /pipeline.build.yaml@faa-template
    parameters:
      moduleName: adls
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-adls/'
      dependsOn: ''
      condition: ''
      moduleRepo: faa-tf-module-adls
      poolName: ${{ variables.poolName }}
      vmImage: ${{ variables.vmImage }}
      projectName: ${{ variables.projectName }}
      currentRepo: ${{ variables.currentRepo }}
     # branchName: master
      pipelineName: ${{ variables.pipelineName }}
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_adls_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_adls_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_adls_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}

- stage : adls_deploy
  dependsOn: adls_build
  jobs:
  - template: /pipeline.deploy.yaml@faa-template
    parameters:
      moduleName: adls
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-adls/'
      dependsOn: ''
      condition: ''
      poolName: ${{ variables.poolName }}
      vmImage: ${{ variables.vmImage }}
      projectName: ${{ variables.projectName }}
      currentRepo: ${{ variables.currentRepo }}
      deployArtifactName: adls_deploy
      moduleRepo: faa-tf-module-adls
      #branchName: master
      pipelineName: ${{ variables.pipelineName }}
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_adls_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features/mohitBansal') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_adls_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_adls_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}
```
## Order of execution
Order of execution of this pipeline is

```hcl
rg_build -> rg_deploy -> acr_build -> acr_deploy
                      -> adf_build  -> adf_deploy
```
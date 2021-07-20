## Introduction 
YAML pipelines for creating Landing Zone for Desjardins. Second Pipeline in line to deploy landing zone is datalake.

## Getting Started 
DevSecops pipeline will deploy three different services contained in single resource group and need to be deployed in following order.
 1) resourceGroup
 2) adls

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

 2) adls

 | Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| team\_name | Le nom du team doit contenir au plus 4 caractères. | `string` | `faa` | oui |
| client_name | Nom du resource sans prefixe ni sufixe | `string` | n/a | oui |
| module\_name | 2 or 3 character short module name to be included in private end point name | `string` | `faa` | oui |
| location | Azure region | `string` | n/a | oui |
| extra\_tags | Si on a besoin d'ajouter des tags extras | `map(string)` | `{}` | oui |
| account\_kind | Type du storage account | `string` | n/a | oui |
| account\_tier | Tier du storage account  | `string` | n/a | oui |
| account\_replication\_type | Type de replication | `string` | n/a | oui |
| ip\_rules | Liste des ips ou CDRs pour white list du firewall | list[`string`] | `[]` | oui |
| virtual_network_subnet_ids | List des subnets que sont ouvertes sur firewall su SA | list[`string`] | `[]` | oui |
| environment | L'environnment (de,pp,pr) | `string` | `de` | oui |
| index | Si on a besoin de creer plusieurs resources avec une sequence | `number` | 1 | oui |
| counter | Counter along with index makes adls resource name unique | `number` | 1 | oui |
| index | Counter along with index makes adls resource name unique | `number` | 1 | oui |
| min_tls_version | Min TLS version to use | `string` | `TLS1_2` | oui |
| is_hns_enabled | Specify whether hierarchical name space is enabled | `boolean` | `true` | oui |
| allow_blob_public_access | specify whether public access to blob enabled | `boolean` | `false` | oui |
| bypass | Services to byPass in network rules | `list(string)` | `["AzureServices"]` | oui |
| threat_protection_enabled | Specify whether the threat protection is enabled | `boolean` | `true` | oui |
| log_analytics_workspace_metric | Log Analytics workspace for storing metric | `string` | `` | oui |
| log_analytics_workspace_metric_rg | resource group for Log Analytics workspace for storing metric | `string` | `` | oui |
| log_analytics_workspace_log | Log Analytics workspace for storing audit and log events. | `string` | `` | oui |
| log_analytics_workspace_log_rg | Resource group for log analytics workspace for storing audit and log events. | `string` | `de` | oui |


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
rg_build -> rg_deploy -> adls_build -> adls_deploy
```
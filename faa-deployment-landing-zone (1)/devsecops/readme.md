## Introduction 
YAML pipelines for creating Landing Zone for Desjardins. First Pipeline in line to deploy landing zone is devsecops.

## Getting Started 
DevSecops pipeline will deploy three different services contained in single resource group and need to be deployed in following order.
 1) resourceGroup
 2) logAnalytics
 3) keyVault

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

 2) logAnalytics

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| team\_name | team name | `string` | faa | yes |
| client\_name | Nom sans prefixe ni sufixe | `string` | n/a | oui |
| resource\_group\_name | Nom du resource groupe | `string` | n/a | oui |
| index | Number of key vaults to create | `number` | 1 | yes |
| counter | This is used to control the last three digit number in key vault name | `number` | 1 | yes |
| location | Azure region | `string` | n/a | oui |
| retention\_in\_days | Log retention in days | `string` | n/a | non |
| sku | SKU du storage account  | `string` | n/a | non |
| extra\_tags | Si on a besoin d'ajouter des tags extras | `map(string)` | `{}` | non |
| environment | L'environnment (de,pp,pr) | `string` | `de` | non |

 3) keyVault

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| team\_name | team name | `string` | faa | yes |
| resource\_name | Nom du resource sans prefixe ni sufixe | `string` | n/a | oui |
| module\_name | 2 or 3 letter short word for module being deployed to be added private end point name | `string` | n/a | oui |
| resource\_group\_name | Name of rg that will host the key vault | `string` | n/a | yes |
| index | Number of key vaults to create | `number` | 1 | yes |
| counter | This is used to control the last three digit number in key vault name | `number` | 1 | yes |
| location | Azure region | `string` | n/a | oui |
| environment | Deployment Environment | `string` | de | yes |
| extra\_tags | Si on a besoin d'ajouter des tags extras | `map(string)` | `{}` | oui |
| enabled\_for\_disk\_encryption | Enabled the key vault to store disk encryption keys for Azure VMs | `boolean` | false | oui |
| soft\_delete\_retention\_days | Days to retain deleted keys and secrets | `number` | 30 | oui |
| purge\_protection\_enabled | Enable key vault purge protection | `boolean` | false | oui |
| enable\_rbac\_authorization | Enable Role based access for key vault | `boolean` | false | oui |
| sku\_name | SKU Used for key vault (standard or premium) | `string` | standard | oui |
| network\_acls\_bypass | Which traffic can by pass the network rules | `string` | AzureServices | oui |
| network\_acls\_default\_action | Default action to use when access doesn't match any rule | `string` | Deny | Non|
| network\_acls\_ip\_rules | Liste des ips ou CDRs pour white list du firewall | list[`string`] | `[]` | non |
| network\_acls\_virtual_network_subnet_ids | List des subnets que sont ouvertes sur firewall su SA | list[`string`] | `[]` | non 
| log_analytics_workspace_log | Log Analytics Workspace for storing keyvault Log events | `string` | n/a | oui |
| log_analytics_workspace_log_rg | Resource group name of log Analytics Workspace for storing keyvault Log events | `string` | n/a | oui |
| log_analytics_workspace_metric | Log Analytics Workspace for storing keyvault metrics events | `string` | n/a | oui |
| log_analytics_workspace_metric_rg | Resource group name of log Analytics Workspace for storing keyvault metric events | `string` | n/a | oui |
| keyVault\_log\_setting\_name | Name of diagnostic setting for storing key vault log events to Log anaytics | `string` | "log2LogAnalytics" | non|
| keyVault\_metric\_setting\_name | Name of diagnostic setting for storing key vault metric events to Log anaytics | `string` | "metric2LogAnalytics" | non|

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
   - repository: faa-tf-module-kv
     name: Fondation/faa-tf-module-kv
     type: git

## Repsitory with terraform code for deploying log analytics service. Branch name is master.
   - repository: faa-tf-module-logAnalytics
     name: Fondation/faa-tf-module-logAnalytics
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
Log Analytics

```hcl
- stage: logAnalytics_build
  dependsOn: rg_deploy
  jobs:
  - template: /pipeline.build.yaml@faa-template
    parameters:
      moduleName: logAnalytics
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-logAnalytics/'
      dependsOn: ''
      condition: ''
      moduleRepo: faa-tf-module-logAnalytics
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
        backendAzureRmKey: '${{ variables.pp_logAnalytics_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_logAnalytics_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_logAnalytics_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}

- stage : logAnalytics_deploy
  dependsOn: rg_deploy
  jobs:
  - template: /pipeline.deploy.yaml@faa-template
    parameters:
      moduleName: logAnalytics
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-logAnalytics/'
      dependsOn: ''
      condition: ''
      poolName: ${{ variables.poolName }}
      vmImage: ${{ variables.vmImage }}
      projectName: ${{ variables.projectName }}
      currentRepo: ${{ variables.currentRepo }}
      deployArtifactName: log_build
      moduleRepo: faa-tf-module-logAnalytics
      #branchName: master
      pipelineName: ${{ variables.pipelineName }}
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_logAnalytics_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features/mohitBansal') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_logAnalytics_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_logAnalytics_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}
```


```hcl
- stage: kv_build
  dependsOn:
  - rg_deploy
  - logAnalytics_deploy
  jobs:
  - template: /pipeline.build.yaml@faa-template
    parameters:
      moduleName: keyVault
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-kv/'
      dependsOn: ''
      condition: ''
      moduleRepo: faa-tf-module-kv
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
        backendAzureRmKey: '${{ variables.pp_kv_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_kv_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_kv_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}

- stage : kv_deploy
  dependsOn: 
  - rg_deploy
  - logAnalytics_deploy
  jobs:
  - template: /pipeline.deploy.yaml@faa-template
    parameters:
      moduleName: keyVault
      workingDirectory: '$(Agent.BuildDirectory)/faa-tf-module-kv/'
      dependsOn: ''
      condition: ''
      poolName: ${{ variables.poolName }}
      vmImage: ${{ variables.vmImage }}
      projectName: ${{ variables.projectName }}
      currentRepo: ${{ variables.currentRepo }}
      deployArtifactName: kv_build
      moduleRepo: faa-tf-module-kv
      #branchName: master
      pipelineName: ${{ variables.pipelineName }}
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/master') }}:
        backendServiceArm: '${{ variables.pp_backendServiceArm }}'
        backendAzureRmResourceGroupName: '${{ variables.pp_backendAzureRmResourceGroupName }}'
        backendAzureRmStorageAccountName: '${{ variables.pp_backendAzureRmStorageAccountName }}'
        backendAzureRmContainerName: '${{ variables.pp_backendAzureRmContainerName }}'
        backendAzureRmKey: '${{ variables.pp_kv_backendAzureRmKey }}'
        keyvault: '${{ variables.pp_keyvault }}'
        env: '${{ variables.pp_env }}'
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/features/mohitBansal') }}:
        backendServiceArm: ${{ variables.de_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.de_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.de_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.de_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.de_kv_backendAzureRmKey }}
        keyvault: ${{ variables.de_keyvault }}
        env: ${{ variables.de_env }}
      ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/releases') }}:
        backendServiceArm: ${{ variables.pr_backendServiceArm }}
        backendAzureRmResourceGroupName: ${{ variables.pr_backendAzureRmResourceGroupName }}
        backendAzureRmStorageAccountName: ${{ variables.pr_backendAzureRmStorageAccountName }}
        backendAzureRmContainerName: ${{ variables.pr_backendAzureRmContainerName }}
        backendAzureRmKey: ${{ variables.pr_kv_backendAzureRmKey }}
        keyvault: ${{ variables.pr_keyvault }}
        env: ${{ variables.pr_env }}
```
## Order of execution
Order of execution of this pipeline is

```hcl
rg_build -> rg_deploy -> log_build -> log_deploy -> kv_build -> kv_deploy
```
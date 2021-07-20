# Introduction 
Re-usable pipeline templates.

# Requirements
- Implement pre-deployment checks and approval

# Pre-Build tests
TODO:

# Build
Build pipeline performs the following steps:-
- Download required files from several common and module specific repositories.
- Download secrets from keyvault.
- Install terraform client.
- Terraform init - Initialize backend and donwload required plugins.
- Terraform plan - Generate a plan to deploy resources.
- Encode the plan file to conceal the secrets.
- Publish files as artifacts for subsequent stages to consume.

# Deploy
Deployment pipeline (pipelin.deploy.yaml) downloads the artifacts generated in build step and uses it to deploy the resources.
- Downloads the artifacts.
- Decode the files to recover plan.
- Deploy the module.
- Delete the file that contains secrets.
- Publish the remaining files (including output) for reviewer to review and consume in subsequent stages.

# Post-Deployment tests
TODO: 

# Build Pipeline parameters -

| Name                              | Description                   | Type          | Required |
| --------------------------------- | ----------------------------- | ------------- | -------- |
| moduleName                        | Name of the module to build   | `string`      | oui      |
| workingDirectory                  | Working directory for Build   | `string`      | oui      |
| backendServiceArm                 | Azure DevOps Service Connection | `string`      | oui      |
| backendAzureRmResourceGroupName   | Resource Group Name for backend storage | `string`      | oui      |
| backendAzureRmStorageAccountName  | Backend storage accountname   | `string`      | oui      |
| backendAzureRmContainerName       | Backend container name        | `string` | oui      |
| backendAzureRmKey                 | Terraform backend file name   | `string`      | oui      |
| keyvault                          | KeyVault for extracing secrets| `string`      | oui      |
| buildArtifactName                 | Build Artifact Name           | `string`      | oui      |
| dependsOn                         | Define job dependencies       | `string`      | non      |
| condition                         | Condition to run the job      | `string`      | non      |
| sourceRepo                        | Current/deployment repo       | `string`      | oui      |
| poolName                          | Name of agent pool to run the job   | `string`      | oui      |
| env                               | One of de,pp or pr            | `string`      | oui      |
| moduleRepo                        | Repo of the module being built| `string`      | oui      |
| currentRepo                       | Current/deployment repo       | `string`      | oui      |
| projectName                       | Name of DevOps Project        | `string`      | oui      |
| localFileName                     | Name of locals file in common reposirtory        | `string` | non      |
| pipelineName                      | Name of pipeline folder in deployment repository | `string`      | oui      |
| branchName                        | Branch name to download code  | `string`      | oui      |
| vmImage                           | Pipeline Line Agent Image type| `string`      | non      |
| terraformVersion                  | Version of terraform to install | `string`    | non      |

# Deploy Pipeline parameters -

| Name                              | Description                   | Type          | Required |
| --------------------------------- | ----------------------------- | ------------- | -------- |
| moduleName                        | Name of the module to deployment  | `string`      | oui      |
| workingDirectory                  | Working directory for deployment pipeline  | `string`      | oui      |
| buildArtifactName                 | Build Artifact Name to download | `string`      | oui      |
| deployArtifactName                | deploy Artifact Name to publish | `string`      | oui      |
| dependsOn                         | Define job dependencies       | `string`      | non      |
| backendServiceArm                 | Azure DevOps Service Connection | `string`      | oui      |
| poolName                          | Name of agent pool to run the job   | `string`      | oui      |
| moduleRepo                        | Repo of the module being built| `string`      | oui      |
| vmImage                           | Pipeline Line Agent Image type| `string`      | non      |
| terraformVersion                  | Version of terraform to install | `string`    | non      |
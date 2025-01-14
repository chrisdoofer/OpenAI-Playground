# Open AI Playground Deployment

The goal of this POC enviornment is to provide a secure environment for testing the Open AI service.  The POC allows for an input file to be dropped into the inputs folder in the public storage account.  This storage account is publicly accessible but restricted by IP address and Azure AD authentication.  Once an input file has been deposited a function app will pick up thsi event and pass the input file to the Open AI service to be categorised.  The output of this categorisation will be inserted into CosmosDB where it can later be queried using Power BI.

## Features

This project framework provides the following features:

* A Function App with a basic Python HTTP triggered Azure Function.
* An Azure Virtual Network, Private Endpoint, and related resources that restrict access to the Function App.
* An Azure Key Vault instance used to securely store all secret values.
* Private Endpoints and network access controls that restrict access to the Storage Account and Key Vault.
* All components are deployable via Bicep.

## Architecture

![Architecture diagram](./media/privateHttp.architectureDiagram.png)

## Getting Started

### Prerequisites

* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (2.42.0)
* [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools)
* [.NET](https://docs.microsoft.com/dotnet/core/install/)
* [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install) or [Terraform](https://www.terraform.io/downloads.html)

### Deploy the Infrastructure

The project can be deployed using _either_ Bicep _or_ Terraform.

#### Bicep

1. Create a new Azure resource group to deploy the Bicep template to, passing in a location and name - `az group create --location <LOCATION> --name <RESOURCE_GROUP_NAME>`
2. The [azuredeploy.parameters.json](./IaC/bicep/azuredeploy.parameters.json) file contains the necessary variables to deploy the Bicep project. Update the file with appropriate values. Descriptions for each parameter can be found in the [main.bicep](./IaC/bicep/main.bicep) file.
3. Optionally, verify what Bicep will deploy, passing in the name of the resource group created earlier and the necessary parameters for the Bicep template - `az deployment group what-if --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`
4. Deploy the template, passing in the name of the resource group created earlier and the necessary parameters for the Bicep template - `az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`

### Deploy the Function App Code

Enabling Private Endpoints on a Function App also makes the Source Control Manager (SCM) site publicly inaccessible. As a result, publishing code from a local machine via the SCM endpoint is not possible as the endpoint is restricted for use from within the virtual network. The project is equipped with a script that utilizes zip deploy for Azure Functions for quick, local deployment purposes. The script deploys a separate Azure Storage account, zips up the Function App source code and pushes it to an Azure Storage container, and adds the `WEBSITE_RUN_FROM_PACKAGE` application setting to the Function App that points to the zip file. In an environment with dedicated pipelines, use self-hosted agents that are deployed into a subnet on the virtual network.

1. Navigate to the [./scripts](./scripts) directory.
2. Deploy the code to the function app provisioned by Bicep or Terraform - `./deploy-azure-functions-code.sh <SUBSCRIPTION_ID> <RESOURCE_GROUP_NAME> <FUNCTION_APP_NAME>`

_Note: The script pulls and assigns the Azure Region's name (e.g. eastus2) to the LOCATION variable. LOCATION may need to be set to the Azure Region's display name (e.g. East US 2) when run from certain programs. The script also assumes the `zip` package is installed on the local machine._

### Test the Function App

1. Open Powershell on the local machine.
2. Make a GET request to the HTTP triggered Azure Function - `curl https://<FUNCTION_APP_NAME>.azurewebsites.net/api/HttpRequestProcessor`
3. Observe a DNS error.
4. Navigate to the [Azure Portal](https://portal.azure.com) and find the Virtual Machine that was provisioned.
5. Open the **Connect** blade and select **Bastion**.
6. Input the admin username and password used in the infrastructure deployment and **Connect**.
7. Open Powershell in the Bastion window.
8. Make a GET request to the HTTP triggered Azure Function - `curl https://<FUNCTION_APP_NAME>.azurewebsites.net/api/HttpRequestProcessor`
9. Observe a 200 response.

## Resources

* [Tutorial: Integrate Azure Functions with an Azure virtual network by using private endpoints](https://docs.microsoft.com/azure/azure-functions/functions-create-vnet)
* [Integrate your app with an Azure virtual network](https://docs.microsoft.com/azure/app-service/overview-vnet-integration)
* [Azure Functions networking options](https://docs.microsoft.com/azure/azure-functions/functions-networking-options)
* [Configure Azure Storage firewalls and virtual networks](https://docs.microsoft.com/azure/storage/common/storage-network-security)
* [Configure Azure Key Vault firewalls and virtual networks](https://docs.microsoft.com/en-us/azure/key-vault/general/network-security)
* [Deployment technologies in Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-deployment-technologies)
* [Run a self-hosted agent in Docker](https://docs.microsoft.com/azure/devops/pipelines/agents/docker?view=azure-devops)

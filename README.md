# Apache Webserver on Ubuntu VM

This template uses the Azure Linux CustomScript extension to deploy an Apache web server. The template creates an Ubuntu VM, installs Apache2 and creates a simple HTML file. Go to ../demo.html to see the deployed page.

![Pipeline Structure](/pipeline.jpg)

# Useful Links

## Bicep Templates

* [Quickstart: Create an Ubuntu Linux virtual machine using a Bicep file](https://docs.microsoft.com/azure/virtual-machines/linux/quick-create-bicep)
* [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
* [Recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
* [Iterative loops in Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/loops)
* [Add linter settings in the Bicep config file](https://docs.microsoft.com/azure/azure-resource-manager/bicep/bicep-config-linter)
* [ARM template deployment what-if operation](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-what-if)

## Azure CLI

* [How to use Azure Resource Manager deployment templates with Azure CLI](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-cli)
* [Sign in with a service principal](https://docs.microsoft.com/cli/azure/authenticate-azure-cli#sign-in-with-a-service-principal)
* [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli)
* [az deployment group create](https://docs.microsoft.com/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-create)
* [az deployment group validate](https://docs.microsoft.com/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-validate)
* [az deployment group what-if](https://docs.microsoft.com/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-what-if)
* [Learn to use Bash with the Azure CLI](https://docs.microsoft.com/cli/azure/azure-cli-learn-bash)

## Azure Pipelines

* [Use Azure Pipelines](https://docs.microsoft.com/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops)
* [Specify events that trigger Pipelines](https://docs.microsoft.com/azure/devops/pipelines/build/triggers?view=azure-devops)
* [Azure Resource Manager service connection](https://docs.microsoft.com/azure/devops/pipelines/library/connect-to-azure?view=azure-devops)
* [Use Azure Key Vault secrets in your Pipeline](https://docs.microsoft.com/azure/devops/pipelines/release/key-vault-in-own-project?view=azure-devops)
* [Template types & usage](https://docs.microsoft.com/azure/devops/pipelines/process/templates?view=azure-devops)
* [Define approvals and checks](https://docs.microsoft.com/azure/devops/pipelines/process/approvals?view=azure-devops)
* [Bash task](https://docs.microsoft.com/azure/devops/pipelines/tasks/utility/bash?view=azure-devops)

## Azure Event Grid

* [What is Azure Event Grid?](https://docs.microsoft.com/azure/event-grid/overview)
* [Receive and respond to Key Vault notifications with Azure Event Grid](https://docs.microsoft.com/azure/key-vault/general/event-grid-tutorial)

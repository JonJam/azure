#https://azure.microsoft.com/en-us/blog/scheduling-azure-automation-runbooks-with-azure-scheduler-2/

#Connect to your Azure account
Add-AzureRmAccount

#Select your subscription if you have more than one
#Set-AzureRmContext -SubscriptionID <YourSubscriptionId>

# Template files
$TemplateParameterFile = "azuredeploy.parameters.json"
$TemplateFilePath = "azuredeploy.json"
$templateParameters = Get-Content -Path $TemplateParameterFile -Raw | ConvertFrom-JSON

$azureResourceGroupName = $templateParameters.parameters.azureResourceGroupName.value
$azureResourceGroupLocation = $templateParameters.parameters.azureResourceGroupLocation.value

# Create Resource Group
New-AzureRmResourceGroup -Name $azureResourceGroupName -Location $azureResourceGroupLocation

# Create Azure Automation Account with Run book
New-AzureRmResourceGroupDeployment -TemplateParameterFile $TemplateParameterFile -ResourceGroupName $azureResourceGroupName -TemplateFile $TemplateFilePath

#Import RunBook Definition and publish
$azureAutomationAccountName = $templateParameters.parameters.azureAutomationAccountName.value
$azureAutomationRunbookName = $templateParameters.parameters.azureAutomationRunbookName.value
$azureAutomationRunbookPath = $templateParameters.parameters.azureAutomationRunbookPath.value

Import-AzureRmAutomationRunbook -Name $azureAutomationRunbookName -Path $azureAutomationRunbookPath -ResourceGroup $azureResourceGroupName -AutomationAccountName $azureAutomationAccountName -Type PowerShellWorkflow
Publish-AzureRMAutomationRunbook -ResourceGroupName $azureResourceGroupName -AutomationAccountName $azureAutomationAccountName -Name $azureAutomationRunbookName

# Create a web hook.
$azureAutomationCredentialName = $templateParameters.parameters.azureAutomationCredentialName.value
$azureAutomationWebHookName = $templateParameters.parameters.azureAutomationWebHookName.value
$azureAutomationWebHookExpiryDate = $templateParameters.parameters.azureAutomationWebHookExpiryDate.value
$azureSQLServerName = $templateParameters.parameters.azureSQLServerName.value
$azureSQLDatabaseName = $templateParameters.parameters.azureSQLDatabaseName.value
$azureSQLStoredProcedureName = $templateParameters.parameters.azureSQLStoredProcedureName.value

$params = @{"SqlServerName"= $AzureSQLServerName; "SqlDatabaseName" = $azureSQLDatabaseName; "SqlStoredProcedureName" = $azureSQLStoredProcedureName; "Credential" = $azureAutomationCredentialName}
$webHook = New-AzureRmAutomationWebhook -Name $azureAutomationWebHookName -Parameters $params -IsEnabled $True -ExpiryTime $azureAutomationWebHookExpiryDate -RunbookName $azureAutomationRunbookName -ResourceGroup $azureResourceGroupName -AutomationAccountName $azureAutomationAccountName -Force

# Create Azure Sheduler Job collection and Job
$azureSchedulerJobCollectionName = $templateParameters.parameters.azureSchedulerJobCollectionName.value
$azureSchedulerJobCollectionPlan = $templateParameters.parameters.azureSchedulerJobCollectionPlan.value
$azureSchedulerJobName = $templateParameters.parameters.azureSchedulerJobName.value

New-AzureRmSchedulerJobCollection -JobCollectionName $azureSchedulerJobCollectionName -Location $azureResourceGroupLocation -ResourceGroupName $azureResourceGroupName -Plan $azureSchedulerJobCollectionPlan
New-AzureRmSchedulerHttpJob -JobCollectionName $azureSchedulerJobCollectionName -JobName $azureSchedulerJobName -Method "POST" -ResourceGroupName $azureResourceGroupName -Uri $webHook.WebhookURI -Frequency "Minute" -Interval 15 -JobState "Enabled"
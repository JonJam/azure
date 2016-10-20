Param(
[Parameter(Mandatory = $True, HelpMessage='Specify the name of the Azure Resource Group.')]
[String]$AzureResourceGroupName,

[Parameter(Mandatory = $True, HelpMessage='Specify the Geo-location e.g. North Europe.')]
[ValidateSet('Australia East', 'Australia Southeast', 'Brazil South', 'Central US', 'East Asia', 'East US', 'East US 2', 'Japan East', 'Japan West', 'North Central US', 'North Europe', 'South Central US', 'Southeast Asia', 'West Europe', 'West US')]
[String]$Location,

[Parameter(Mandatory = $True, HelpMessage='Specify the name of the Azure Automation Schedule.')]
[String]$ScheduleName,

[Parameter(Mandatory = $True, HelpMessage='Specify the name of the Azure SQL Server.')]
[String]$AzureSQLServerName,

[Parameter(Mandatory = $True, HelpMessage='Specify the name of the Azure SQL Server Database.')]
[String]$AzureSQLDatabaseName,

[Parameter(Mandatory = $True, HelpMessage='Specify the name of the Azure SQL Stored Procedure.')]
[String]$AzureSQLStoredProcedureName
)

#Connect to your Azure account
Add-AzureRmAccount

#Select your subscription if you have more than one
#Set-AzureRmContext -SubscriptionID <YourSubscriptionId>

# Template files
$TemplateParameterFile = "azuredeploy.parameters.json"
$TemplateFilePath = "azuredeploy.json"

# Runbook needs to be uploaded already e.g. blob storage

# Create Resource Group
New-AzureRmResourceGroup -Name $AzureResourceGroupName -Location $Location

# Create Azure Automation Account with Run book
New-AzureRmResourceGroupDeployment -TemplateParameterFile $TemplateParameterFile -ResourceGroupName $AzureResourceGroupName -TemplateFile $TemplateFilePath

$templateParameters = Get-Content -Path $TemplateParameterFile -Raw | ConvertFrom-JSON
$automationAccountName = $templateParameters.parameters.automationAccountName.value
$runbookName = $templateParameters.parameters.runbookName.value
$credentialName = $templateParameters.parameters.azureSQLCredentialName.value
# Time must be at least 5 minutes after create it.
$StartTime = Get-Date "23:00:00"

# Create Azure Automation Schedule for Account
# Specifying a day interval –DayInterval 1
# Specifying a hour interval -HourInterval 1
New-AzureRMAutomationSchedule –AutomationAccountName $automationAccountName –Name $ScheduleName –StartTime $StartTime –DayInterval 1 -ResourceGroupName $AzureResourceGroupName

# Link Schedule to Runbook
$params = @{"SqlServerName"= $AzureSQLServerName; "SqlDatabaseName" = $AzureSQLDatabaseName; "SqlStoredProcedureName" = $AzureSQLStoredProcedureName; "Credential" = $credentialName}
Register-AzureRmAutomationScheduledRunbook –AutomationAccountName $automationAccountName –Name $runbookName –ScheduleName $ScheduleName –Parameters $params -ResourceGroupName $AzureResourceGroupName
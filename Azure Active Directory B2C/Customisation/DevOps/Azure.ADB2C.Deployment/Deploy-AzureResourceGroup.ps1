#Requires -Version 3.0
#Requires -Module AzureRM.Resources
#Requires -Module Azure.Storage

Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
    [string] $ResourceGroupName = 'adb2c-dev-rg',
    [string] $TemplateFile = 'azuredeploy.json',
    [string] $TemplateParametersFile = 'azuredeploy.parameters.json',
    [string] $ArtifactStagingDirectory = "..\..\Src\",
    [switch] $ValidateOnly
)

Import-Module Azure -ErrorAction SilentlyContinue
Add-Type -AssemblyName "System.Web"

# Uncomment if running locally.
# Login-AzureRmAccount

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "2.9.6")
} catch { }

Set-StrictMode -Version 3

function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @("  " * $Depth + $_.Code + ": " + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

$OptionalParameters = New-Object -TypeName Hashtable
$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

# Parse the parameter file
$JsonContent = Get-Content $TemplateParametersFile -Raw | ConvertFrom-Json
$JsonParameters = $JsonContent | Get-Member -Type NoteProperty | Where-Object {$_.Name -eq "parameters"}

if ($JsonParameters -eq $null) {
    $JsonParameters = $JsonContent
}
else {
    $JsonParameters = $JsonContent.parameters
}

# Create or update the resource group using the specified template file and template parameters file
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop

$ErrorMessages = @()
$DeploymentOutput = $null

if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                  -TemplateFile $TemplateFile `
                                                                                  -TemplateParameterFile $TemplateParametersFile `
                                                                                  @OptionalParameters `
                                                                                  -Verbose)
}
else {
    $DeploymentOutput = New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateFile $TemplateFile `
                                       -TemplateParameterFile $TemplateParametersFile `
                                       @OptionalParameters `
                                       -Force -Verbose `
                                       -ErrorVariable ErrorMessages
    $ErrorMessages = $ErrorMessages | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") }
}
if ($ErrorMessages)
{
    "", ("{0} returned the following errors:" -f ("Template deployment", "Validation")[[bool]$ValidateOnly]), @($ErrorMessages) | ForEach-Object { Write-Output $_ }
}
else
{
	# Connecting to AD B2C Storage Account.
    $ADB2CStorageAccountName = $DeploymentOutput.Outputs["storageAccountName"].Value
	$ADB2CStorageContainerName = $JsonParameters.storageContainerName.value
	$BlobTTL = $JsonParameters.blobTTL.value
    $cdnHostName = $DeploymentOutput.Outputs["cdnHostName"].Value

    $ADB2CStorageAccountContext = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $ADB2CStorageAccountName}).Context
    
    # Configure Logging for Storage Account
    Set-AzureStorageServiceLoggingProperty -ServiceType Blob -LoggingOperations Read,Write -Context $ADB2CStorageAccountContext
    Set-AzureStorageServiceLoggingProperty -ServiceType Table -LoggingOperations None -Context $ADB2CStorageAccountContext
    Set-AzureStorageServiceLoggingProperty -ServiceType Queue -LoggingOperations None -Context $ADB2CStorageAccountContext

    # Get or create container if doesn't exist.
	$ADB2CArtifactsStorageContainer = Get-AzureStorageContainer -Context $ADB2CStorageAccountContext | Where-Object { $_.Name -eq $ADB2CStorageContainerName } 

	if ($ADB2CArtifactsStorageContainer -eq $null)
	{	
	    $ADB2CArtifactsStorageContainer = New-AzureStorageContainer -Name $ADB2CStorageContainerName -Context $ADB2CStorageAccountContext -Permission Blob	
	}

    # Set CORS rule for Blob access. CORS rules based off: https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-reference-ui-customization-helper-tool
    $CorsRule = @{
        AllowedHeaders = @("*")
        AllowedMethods = @("Get")    
        AllowedOrigins = @("https://login.microsoftonline.com,https://$cdnHostName")
        ExposedHeaders = @("*")    
        MaxAgeInSeconds = 200
    }

    $CorsRules = @($CorsRule)

    Set-AzureStorageCORSRule -ServiceType Blob -Context $ADB2CStorageAccountContext -CorsRules $CorsRules

    # Copy files to AB B2C Storage Account container    
    $ArtifactStagingDirectory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ArtifactStagingDirectory))

    # Excluding node modules, VS Code, less and js files to reduce upload.
    $ADB2CArtifactFiles = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | Where {!$_.FullName.Contains("node_modules") -and !$_.FullName.Contains(".vscode") -and !$_.FullName.Contains("less") -and !$_.FullName.Contains("js")}

    foreach ($File in $ADB2CArtifactFiles) {

        $FileContent = (Get-Content $File.FullName)

        if (($File.FullName.EndsWith(".html") -or $File.FullName.EndsWith(".css")) -and $FileContent -ne $null)
        {   
            #Apply transformation for URIs to image and CSS files in HTML/CSS files.
            $TransformedContent = (Get-Content $File.FullName).Replace("../../", "https://$cdnHostName/")
            $TransformedContent = $TransformedContent.Replace("../", "https://$cdnHostName/")
            
            Set-Content $File.FullName $TransformedContent            
        }

        $BlobName = $File.FullName.Replace($ArtifactStagingDirectory, "")
        $SourcePath = $File.FullName

	    $BlobProperties = @{
            "ContentType" = [System.Web.MimeMapping]::GetMimeMapping($File.FullName)
            CacheControl = "public, max-age=$BlobTTL"
        }

        Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $ADB2CStorageContainerName -Properties $BlobProperties -Context $ADB2CStorageAccountContext -Force -ErrorAction Stop
    }	 
}


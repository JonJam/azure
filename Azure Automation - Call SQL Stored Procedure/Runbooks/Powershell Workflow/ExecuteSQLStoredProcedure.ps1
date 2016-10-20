workflow ExecuteSQLStoredProcedure
{
    param
    (
        # Fully-qualified name of the Azure DB server 
        [parameter(Mandatory=$true)] 
        [string] $SqlServerName,

        [parameter(Mandatory=$true)] 
        [string] $SqlDatabaseName,
        
        [parameter(Mandatory=$true)] 
        [string] $SqlStoredProcedureName,

        # Credentials for $SqlServerName stored as an Azure Automation credential asset
        # When using in the Azure Automation UI, please enter the name of the credential asset for the "Credential" parameter
        [parameter(Mandatory=$true)] 
        [PSCredential] $Credential
    )

    inlinescript
    {
        # Setup credentials   
        $ServerName = $Using:SqlServerName
        $DatabaseName = $Using:SqlDatabaseName
        $UserId = $Using:Credential.UserName
        $Password = ($Using:Credential).GetNetworkCredential().Password

        # Create connection to Database
        $DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
        $DatabaseConnection.ConnectionString = "Server = $ServerName; Database = $DatabaseName; User ID = $UserId; Password = $Password;"
        $DatabaseConnection.Open();

        # Create command to execute stored procedure
        $StoredProcedureName = $Using:SqlStoredProcedureName
        $StoredProcedureCommand = New-Object System.Data.SqlClient.SqlCommand
        $StoredProcedureCommand.Connection = $DatabaseConnection
        $StoredProcedureCommand.CommandText = $StoredProcedureName
        $StoredProcedureCommand.ExecuteNonQuery();

        # Close connection.
        $DatabaseConnection.Close();
    }    
}
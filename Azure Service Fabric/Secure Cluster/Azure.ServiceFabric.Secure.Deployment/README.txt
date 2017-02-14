This follows: https://docs.microsoft.com/en-gb/azure/service-fabric/service-fabric-cluster-creation-via-arm#set-up-azure-active-directory-for-client-authentication

To deploy the cluster the following needs to be performed:

1.	Ensure KeyVault is created.
2.	Dev
		frontEndVMAdminPassword
			- Add to KeyVault.

		backEndVMAdminPassword
			- Add to KeyVault.

		Cluster Certificate
			- Use New-ServiceFabricClusterCertificate to generate a self-signed certificate and
			  upload to KeyVault.

			  e.g. -CertDNSName "DNS NAME.northeurope.cloudapp.azure.com" -KeyVaultName "keyVault" -KeyVaultSecretName "ServiceFabricClusterCertificate"
		Application Certificate (SSL)
			- Use New-ServiceFabricClusterCertificate to generate a self-signed certificate and
			  upload to KeyVault.
			  			  
			  e.g. -CertDNSName "DNS NAME.northeurope.cloudapp.azure.com" -KeyVaultName "keyVault" -KeyVaultSecretName "ServiceFabricApplicationCertificate"

	Test / Prod
		frontEndVMAdminPassword
			- Add to KeyVault.

		backEndVMAdminPassword
			- Add to KeyVault.

		Cluster Certificate
			- Upload a certificate obtained from a CA.
		Application Certificate (SSL)
			- Upload a certificate obtained from a CA.
		
3.	Run SetupClusterADApplications to register the cluster with Azure AD so cluster management can
	only be performed by AD users.

4.  Use outputs from Step 2 and 3 to update ARM parameters.

5.	Run ARM deployment.

6.	In the Azure Portal, assign roles and users to the Cluster AD Applications.
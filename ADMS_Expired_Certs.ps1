<#
	.SYNOPSIS
		API tool for pulling a list of expired certificates

	.DESCRIPTION
		Fetches /nitro/v1/config/ns_ssl_certkey from ADM Service.
		https://developer.cloud.com/app-delivery-and-security/citrix-application-delivery-management-service/ns_ssl_certkey/apis/ns_ssl_certkey/getall_ns_ssl_certkey
        
	.FUNCTIONALITY
		 Application Delivery Manager Service

	.NOTES
		AUTHOR : R. Davis
		VERSION: 23 MAY 2022 initial build

		Requires Powershell Version 7.0
    
  	.INPUTS
		none.  The application is interactive.
        
  	.EXAMPLE
		Requires version 7.0+
		Running PowerShell 7.2.3.
		Action: citrixs24692 logging in
		Token: eyJhbGciOiJSUzI1NiIsInR5c....
		Certificates: 17
		Saved in .\ns_ssl_certkey.csv

  	.NOTES
		This sample code is provided to you as is with no representations, 
		warranties or conditions of any kind. You may use, modify and 
		distribute it at your own risk. 
#>
$CLIENT_ID="ee7a47df-76df-4ef4-9f7b-demo"
$CLIENT_SECRET="demo-gqrads-QXzdRdgqrjzPQw="
$CUSTOMER_ID="demo246592"
'Requires version 7.0+'
"Running PowerShell $($PSVersionTable.PSVersion)."
###
### Main Program
###
# Get Token
Write-Host "Action: $CUSTOMER_ID logging in" 
$array  =  @{ 'Uri'  = 'https://api-us.cloud.com/cctrustoauth2/root/tokens/clients'
            'Method' = 'POST'
            'ContentType' = 'application/x-www-form-urlencoded'
            'body'   = "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET"
            }
try {
        [String]$script:token = (Invoke-RestMethod @array -TimeoutSec 10 -SkipCertificateCheck).access_token
        Write-Host "Token: $token" 
    } catch { Write-Warning $_ }
# GET ns_ssl_certkey
$array  =  @{ 'Uri'  = "https://adm.cloud.com/massvc/$CUSTOMER_ID/nitro/v2/config/ns_ssl_certkey?filter=expiry_type:expired"
            'Method' = 'GET'
            'Headers'= @{'Authorization' = "CwsAuth bearer=$token"; 'isCloud' = "true"}
            'ContentType' = 'application/json'
            }
try {
        $objects = @((Invoke-RestMethod @array -TimeoutSec 30 -SkipCertificateCheck).ns_ssl_certkey)
        Write-Host "Certificates: $($objects.count)" 
        $objects | Export-Csv -Path .\ns_ssl_certkey.csv
	Write-Host "Saved in .\ns_ssl_certkey.csv"
    } catch { Write-Warning $_ }
###
### END
###

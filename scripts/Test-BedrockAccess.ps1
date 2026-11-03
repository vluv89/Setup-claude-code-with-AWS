[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InferenceProfileId,
    [string]$Profile = "bedrock-dev",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI was not found. Install AWS CLI v2 and reopen PowerShell."
}

Write-Host "Checking AWS identity..."
aws sts get-caller-identity --profile $Profile --output table
if ($LASTEXITCODE -ne 0) {
    throw "Identity check failed. Check credentials or run aws sso login --profile $Profile."
}

Write-Host "Checking inference profile visibility..."
aws bedrock get-inference-profile --inference-profile-identifier $InferenceProfileId --region $Region --profile $Profile --output json
if ($LASTEXITCODE -ne 0) {
    throw "Could not retrieve profile. Verify its ID, Region, account access and IAM permissions."
}
Write-Host "Profile lookup succeeded. This does not invoke a model or prove invoke permissions." -ForegroundColor Green

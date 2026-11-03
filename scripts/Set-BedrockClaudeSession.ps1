[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ModelId,
    [string]$Profile = "bedrock-dev",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI was not found. Install AWS CLI v2 and reopen PowerShell."
}

$env:CLAUDE_CODE_USE_BEDROCK = "1"
$env:AWS_PROFILE = $Profile
$env:AWS_REGION = $Region
$env:ANTHROPIC_MODEL = $ModelId

Write-Host "Bedrock environment variables set for this PowerShell session." -ForegroundColor Green
Write-Host "Profile: $Profile | Region: $Region | Model: $ModelId"
aws sts get-caller-identity --profile $Profile --output table
if ($LASTEXITCODE -ne 0) {
    throw "AWS identity check failed. Check credentials or run aws sso login --profile $Profile."
}
Write-Host "Launch Claude Code with: claude"

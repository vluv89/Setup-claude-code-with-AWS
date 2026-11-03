[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ModelId
)

$settings = [ordered]@{
    env = [ordered]@{
        CLAUDE_CODE_USE_BEDROCK = "1"
        AWS_PROFILE = "bedrock-dev"
        AWS_REGION = "us-east-1"
        ANTHROPIC_MODEL = $ModelId
    }
}

Write-Output ($settings | ConvertTo-Json -Depth 5)
Write-Warning "Example only. Review Anthropic's current settings documentation before saving."
Write-Warning "Never put AWS access keys, secret keys or session tokens in this file."

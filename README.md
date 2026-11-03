# Claude Code with Amazon Bedrock on Windows
<img width="963" height="459" alt="image" src="https://github.com/user-attachments/assets/6d767949-feb8-4f6b-84c0-e8cfdb36c86c" />


A beginner-friendly PowerShell guide to using Claude Code with Amazon Bedrock.

## Important
Bedrock model usage is billed by AWS. Free Tier benefits or promotional credits may offset eligible charges, but do not guarantee free usage. Check current pricing and your account credit terms.

## Prerequisites
- Windows 10/11 and PowerShell
- AWS CLI v2
- An AWS account with Amazon Bedrock model access
- Claude Code CLI
- A dedicated least-privilege AWS development identity (prefer IAM Identity Center/SSO; do not use the root user for routine development)

## 1. Configure AWS CLI

For IAM Identity Center:

```powershell
aws configure sso --profile bedrock-dev
aws sso login --profile bedrock-dev
```

Set your session profile and Region:

```powershell
$env:AWS_PROFILE = "bedrock-dev"
$env:AWS_REGION = "us-east-1"
aws sts get-caller-identity
```

## 2. Find your Bedrock inference profile

```powershell
aws bedrock list-inference-profiles --region $env:AWS_REGION
aws bedrock get-inference-profile --inference-profile-identifier "YOUR_INFERENCE_PROFILE_ID" --region $env:AWS_REGION
```

Use the exact profile ID available in your account. Cross-region profiles may require IAM permissions for destination-Region foundation model ARNs as well as the inference profile ARN.

## 3. Install Claude Code

Follow Anthropic's current guide: https://docs.anthropic.com/en/docs/claude-code/overview

Verify:

```powershell
claude --version
```

## 4. Configure Claude Code for Bedrock

In the same PowerShell session where you will launch Claude Code:

```powershell
$env:CLAUDE_CODE_USE_BEDROCK = "1"
$env:AWS_PROFILE = "bedrock-dev"
$env:AWS_REGION = "us-east-1"
$env:ANTHROPIC_MODEL = "YOUR_BEDROCK_INFERENCE_PROFILE_ID"
aws sso login --profile bedrock-dev
claude
```

Inside Claude Code, use `/status` to inspect the active configuration. See Anthropic's Bedrock setup guide for current configuration details: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock

## Included scripts
- `scripts/Set-BedrockClaudeSession.ps1` sets the current PowerShell session variables and checks AWS identity.
- `scripts/Test-BedrockAccess.ps1` checks AWS identity and inference profile visibility.
- `scripts/Show-ClaudeSettingsExample.ps1` prints an example settings JSON without changing local files.

## Security and cost
- Never commit AWS credentials, access keys, secret keys or session tokens.
- Use least-privilege permissions and MFA.
- Avoid the AWS root user for routine development.
- Set AWS Budgets and billing alerts.
- Review https://aws.amazon.com/bedrock/pricing/ and your account's AWS credit terms.

## Official documentation
- AWS Bedrock: https://docs.aws.amazon.com/bedrock/
- Bedrock inference profiles: https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles.html
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
- Claude Code with Bedrock: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock

MIT License. See `LICENSE`.

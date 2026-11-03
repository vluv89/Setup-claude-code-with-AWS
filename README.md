# Run Claude Code CLI with Amazon Bedrock on Windows

A practical, beginner-friendly guide to connecting **Claude Code** to **Anthropic Claude models hosted on Amazon Bedrock**, using Windows 10/11, PowerShell and the AWS CLI.

This guide covers AWS identity setup, Bedrock model discovery, Claude Code installation, configuration, a working test project, troubleshooting, security and costs.

> **Important — AWS charges apply.** Claude model requests made through Amazon Bedrock are billed by AWS according to the model, input/output tokens and applicable pricing. AWS Free Tier benefits or promotional credits may offset eligible charges, but they do not guarantee free usage. Review [Amazon Bedrock pricing](https://aws.amazon.com/bedrock/pricing/) and your account's credit terms before experimenting.

---

## Contents

- [1. How the connection works](#1-how-the-connection-works)
- [2. Prerequisites](#2-prerequisites)
- [3. Create and prepare your AWS account](#3-create-and-prepare-your-aws-account)
- [4. Install the AWS CLI](#4-install-the-aws-cli)
- [5. Configure AWS authentication](#5-configure-aws-authentication)
- [6. Find an available Claude model and inference profile](#6-find-an-available-claude-model-and-inference-profile)
- [7. Install Claude Code](#7-install-claude-code)
- [8. Connect Claude Code to Amazon Bedrock](#8-connect-claude-code-to-amazon-bedrock)
- [9. Make the configuration persistent](#9-make-the-configuration-persistent)
- [10. Test Claude Code with a project](#10-test-claude-code-with-a-project)
- [11. Troubleshooting](#11-troubleshooting)
- [12. Security and best practices](#12-security-and-best-practices)
- [13. Useful commands reference](#13-useful-commands-reference)
- [14. Final checklist](#14-final-checklist)
- [Official documentation](#official-documentation)

## 1. How the connection works

The request flow is:

1. **AWS identity** provides credentials to authenticate your requests.
2. **AWS CLI** stores or retrieves credentials through a named profile.
3. **Claude Code** uses that profile and the Bedrock configuration.
4. **Amazon Bedrock** receives the model request and invokes the selected Claude model through an inference profile.

You do not need to configure a direct Anthropic API key for this Bedrock setup. You do need a valid AWS identity, permission to invoke the model and an available Bedrock model/inference profile.

## 2. Prerequisites

You will need:

- Windows 10 or Windows 11.
- PowerShell (Windows PowerShell 5.1 or PowerShell 7 is suitable for the commands in this guide).
- An AWS account with Amazon Bedrock available.
- An AWS identity with the required Bedrock permissions.
- AWS CLI v2.
- Claude Code CLI.
- A Claude model or inference profile available in your chosen AWS Region.

**Example values used throughout this guide**

| Setting | Example |
|---|---|
| AWS CLI profile | `bedrock-dev` |
| AWS Region | `us-east-1` |
| Example model | Claude Sonnet 4.5 |
| Example inference profile ID | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |

These are examples, not universal defaults. Use the profile ID and Region actually available to your AWS account.

## 3. Create and prepare your AWS account

### Step 1 — Create or access an AWS account

Go to [https://aws.amazon.com/](https://aws.amazon.com/) and sign in or create an account.

AWS may ask you to verify your identity and add a payment method.

### Step 2 — Open Amazon Bedrock

1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/).
2. Search for **Amazon Bedrock**.
3. Select the AWS Region you intend to use (this guide uses `us-east-1` as an example).
4. Open the model catalogue and locate the Claude model you want to use.
5. Review the model's availability, access requirements and supported inference profiles.

Model availability and onboarding requirements can vary by model, Region and account. Do not assume that a model ID shown in an online tutorial is available in your account.

### Step 3 — Choose an AWS identity

For routine development, use a dedicated, least-privilege identity rather than the AWS account root user.

Recommended options:

- **IAM Identity Center (SSO):** preferred for human developers where available. It provides temporary credentials and avoids creating long-lived access keys.
- **IAM role:** suitable when credentials are supplied through an approved role or workload identity.
- **Dedicated IAM user with access keys:** a fallback for environments where SSO or role-based access is not practical. Restrict its permissions and protect/rotate its keys.

Do not grant AdministratorAccess simply to get Claude Code working. See [IAM permissions](docs/IAM-PERMISSIONS.md) for guidance.

## 4. Install the AWS CLI

### Step 1 — Download and install AWS CLI v2

Download the Windows installer from:

[https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)

Install the 64-bit Windows version.

### Step 2 — Verify the installation

Open a new PowerShell window and run:

```powershell
aws --version
```

You should see output similar to:

```text
aws-cli/2.x.x Python/3.x Windows/11 exe/AMD64
```

The exact version and Python details will vary.

If PowerShell says that `aws` is not recognised, close and reopen PowerShell. If the issue remains, check that the AWS CLI installation directory is in your PATH.

## 5. Configure AWS authentication

Choose **one** of the following authentication methods. IAM Identity Center/SSO is recommended for people.

### Option A — IAM Identity Center (recommended)

If your organisation has configured AWS IAM Identity Center, run:

```powershell
aws configure sso --profile bedrock-dev
```

Follow the prompts. You will typically need your organisation's SSO start URL (or issuer URL), the SSO Region, and the AWS account and role you are authorised to use.

Then sign in:

```powershell
aws sso login --profile bedrock-dev
```

Set the profile and Region for the current PowerShell session:

```powershell
$env:AWS_PROFILE = "bedrock-dev"
$env:AWS_REGION = "us-east-1"
```

### Option B — Dedicated IAM user with access keys

Use this only if SSO or role-based authentication is not available to you.

Create or obtain access keys for a dedicated IAM user that has only the permissions needed for your Bedrock workflow. Then run:

```powershell
aws configure --profile bedrock-dev
```

Enter your own values when prompted:

```text
AWS Access Key ID: [Your access key ID]
AWS Secret Access Key: [Your secret access key]
Default region name: us-east-1
Default output format: json
```

The bracketed values above are placeholders. Never paste real credentials into a tutorial, script, GitHub issue or public repository.

### Verify AWS authentication

For either option, run:

```powershell
aws sts get-caller-identity --profile bedrock-dev
```

A successful response contains the AWS account and identity ARN. This confirms that AWS can authenticate the selected profile. It does **not** prove that the identity has permission to invoke a Bedrock model.

Set the profile's default Region (optional, but useful):

```powershell
aws configure set region us-east-1 --profile bedrock-dev
```

If you use SSO and your session expires, sign in again:

```powershell
aws sso login --profile bedrock-dev
```

## 6. Find an available Claude model and inference profile

Amazon Bedrock can expose models through **inference profiles**. A cross-Region inference profile can route requests from your selected source Region to one or more destination Regions.

### Step 1 — List available inference profiles

Run this from the Region you intend to use:

```powershell
aws bedrock list-inference-profiles `
  --region us-east-1 `
  --profile bedrock-dev `
  --output table
```

To filter the list to active Anthropic profiles:

```powershell
aws bedrock list-inference-profiles `
  --region us-east-1 `
  --profile bedrock-dev `
  --query "inferenceProfileSummaries[?status=='ACTIVE' && contains(inferenceProfileId, 'anthropic')].[inferenceProfileId,inferenceProfileName]" `
  --output table
```

If you do not see the model you want, check the model's current availability for your Region and account in the Bedrock console and AWS documentation.

### Step 2 — Choose an inference profile

For this walkthrough, the example is Claude Sonnet 4.5:

```text
us.anthropic.claude-sonnet-4-5-20250929-v1:0
```

Your account may expose a different profile, model version or geographic prefix. Copy the exact ID returned by your own AWS CLI/console.

### Step 3 — Verify the inference profile

Replace the example ID if necessary:

```powershell
aws bedrock get-inference-profile `
  --inference-profile-identifier "us.anthropic.claude-sonnet-4-5-20250929-v1:0" `
  --region us-east-1 `
  --profile bedrock-dev
```

Check that the profile status is:

```json
"status": "ACTIVE"
```

You can also inspect the model ARNs and Regions associated with the profile:

```powershell
aws bedrock get-inference-profile `
  --inference-profile-identifier "us.anthropic.claude-sonnet-4-5-20250929-v1:0" `
  --region us-east-1 `
  --profile bedrock-dev `
  --query "models[].modelArn" `
  --output table
```

**Important — cross-Region routing:** a geographic inference profile may route requests to multiple AWS Regions. Your IAM permissions and any AWS Organizations service control policies (SCPs) must allow the required inference actions for the inference profile and the relevant source/destination model resources. If data residency matters, inspect the profile's destination Regions before using it. See [AWS cross-Region inference](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html).

## 7. Install Claude Code

### Step 1 — Install Claude Code for Windows

Open PowerShell and run Anthropic's Windows installer:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Only run installation commands from the official Anthropic domain. If your organisation restricts script execution or software installation, follow its approved process.

### Step 2 — Verify the installation

```powershell
claude --version
```

You should see the installed Claude Code version.

If `claude` is not recognised, close and reopen PowerShell. If it still fails, check the installer output and your PATH.

For current installation options and platform requirements, see [Anthropic's Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview).

## 8. Connect Claude Code to Amazon Bedrock

Claude Code can use Amazon Bedrock as its model provider. The following environment variables configure the provider, AWS profile, Region and model.

### Step 1 — Set the environment variables

In the PowerShell window where you plan to launch Claude Code, run:

```powershell
$env:CLAUDE_CODE_USE_BEDROCK = "1"
$env:AWS_PROFILE = "bedrock-dev"
$env:AWS_REGION = "us-east-1"
$env:ANTHROPIC_MODEL = "us.anthropic.claude-sonnet-4-5-20250929-v1:0"
```

Change the Region and model ID to match the inference profile you verified in the previous section.

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK` | Tells Claude Code to use Amazon Bedrock |
| `AWS_PROFILE` | Selects the AWS CLI credentials profile |
| `AWS_REGION` | Sets the Bedrock source Region |
| `ANTHROPIC_MODEL` | Selects the Claude model/inference profile |

These commands apply only to the current PowerShell process and programs launched from it.

### Step 2 — Refresh SSO credentials if needed

If you configured IAM Identity Center and your session has expired, run:

```powershell
aws sso login --profile bedrock-dev
```

### Step 3 — Launch Claude Code

From the same PowerShell window, run:

```powershell
claude
```

### Step 4 — Check the configuration

Inside Claude Code, run:

```text
/status
```

Review the provider and model details shown.

Then send a simple test prompt, for example:

```text
Reply with a short confirmation that you can answer this request.
```

If Claude responds, the initial connection is working. For stronger verification, check the AWS identity, Bedrock permissions and AWS billing/usage records as well. A successful `sts get-caller-identity` command alone is not proof of model invocation access.

## 9. Make the configuration persistent

The environment variables set with `$env:` disappear when that PowerShell session closes. You can store the Claude Code configuration in your user-level settings file instead.

### Step 1 — Create the Claude settings directory

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude"
```

### Step 2 — Open the settings file

```powershell
notepad "$HOME\.claude\settings.json"
```

If the file does not exist, Notepad will let you create it. If it already contains settings, **do not overwrite them**. Merge the Bedrock variables into the existing `env` object.

Example configuration:

```json
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_PROFILE": "bedrock-dev",
    "AWS_REGION": "us-east-1",
    "ANTHROPIC_MODEL": "us.anthropic.claude-sonnet-4-5-20250929-v1:0"
  }
}
```

Save the file. Make sure it is valid JSON: use double quotes and do not add trailing commas.

### Step 3 — Restart and launch

Close the existing Claude Code session and open a new PowerShell window. If you use SSO, refresh the login when required:

```powershell
aws sso login --profile bedrock-dev
claude
```

The settings file stores the Claude Code environment configuration; it does not create AWS credentials or prevent an SSO session from expiring. You must still have a valid AWS identity and permissions.

## 10. Test Claude Code with a project

Create a small test project:

```powershell
New-Item -ItemType Directory -Force "C:\Projects\ClaudeTest"
Set-Location "C:\Projects\ClaudeTest"
```

Launch Claude Code:

```powershell
claude
```

Try this prompt:

```text
Create a simple Python application that displays a welcome message.

Include:
- A main Python file
- A README file
- Basic instructions for running the application

Keep the project small and explain the files you create.
```

Claude Code should inspect the working directory and, with your approval where required, create the requested files.

You have now completed the initial setup of Claude Code CLI using Amazon Bedrock.

## 11. Troubleshooting

### Error: AWS profile or credentials cannot be found

Check which profile is selected:

```powershell
$env:AWS_PROFILE
aws sts get-caller-identity --profile bedrock-dev
```

For IAM Identity Center, refresh the login:

```powershell
aws sso login --profile bedrock-dev
```

Confirm the profile name in `AWS_PROFILE` matches the profile you configured.

### Error: Profile is already configured with access-key credentials

This is not necessarily an error. It may mean the selected profile already contains access-key credentials.

You can use that profile if it is the intended dedicated development identity, or create a separate profile:

```powershell
aws configure --profile bedrock-dev
```

Do not overwrite a profile until you know which identity and credentials it uses.

### Error: AccessDeniedException

Possible causes:

- The AWS identity does not have the required Bedrock invocation permission.
- The inference profile or underlying model resources are not included in the IAM policy.
- A service control policy (SCP), permission boundary or other organisation policy blocks the request.
- The model requires account onboarding or access that has not been completed.

Check the IAM policy and the profile's source/destination Regions. See [docs/IAM-PERMISSIONS.md](docs/IAM-PERMISSIONS.md).

### Error: ResourceNotFoundException

Check that:

- The inference profile ID is copied correctly.
- The source Region is correct.
- The profile is available from that source Region.
- You are using an inference profile ID where one is required, rather than assuming a foundation model ID will work.

Re-run `list-inference-profiles` and `get-inference-profile` from the Region you intend to use.

### Error: Claude Code cannot find the model

Check the model environment variable:

```powershell
$env:ANTHROPIC_MODEL
```

Then verify the profile:

```powershell
aws bedrock get-inference-profile `
  --inference-profile-identifier $env:ANTHROPIC_MODEL `
  --region $env:AWS_REGION `
  --profile $env:AWS_PROFILE
```

If you use a different model configuration supported by your Claude Code version, consult Anthropic's current Bedrock documentation.

### Error: Claude Code launches, but model requests fail

A successful Claude Code launch does not guarantee that Bedrock invocation will work. Check each layer:

1. `aws sts get-caller-identity --profile bedrock-dev` — AWS authentication.
2. `aws bedrock get-inference-profile ...` — profile visibility.
3. IAM permissions — invocation rights for the profile and model resources.
4. Region and SCP configuration — cross-Region routing is allowed.
5. Claude Code `/status` — provider and model configuration.

### Error: PowerShell cannot find `aws` or `claude`

Close and reopen PowerShell after installation. Check the relevant command:

```powershell
Get-Command aws
Get-Command claude
```

If a command is missing, review the installer output and PATH configuration.

## 12. Security and best practices

- Do not use the AWS root account for everyday development.
- Enable MFA on the root account and human identities.
- Prefer IAM Identity Center/SSO or an appropriate role over long-lived access keys.
- If access keys are necessary, use a dedicated least-privilege identity and rotate keys according to your organisation's policy.
- Never commit AWS credentials, access keys, secret keys, session tokens or local secrets to Git.
- Do not paste credentials into Claude prompts, scripts or screenshots.
- Review Claude Code's file access and permission prompts before approving changes.
- Set AWS Budgets and billing alerts before experimenting.
- Review Bedrock usage and CloudTrail activity.
- Check cross-Region inference destinations if your data residency requirements restrict where prompts may be processed.
- Use separate development and production identities.

## 13. Useful commands reference

| Task | Command |
|---|---|
| Check AWS CLI | `aws --version` |
| Check Claude Code | `claude --version` |
| Configure SSO profile | `aws configure sso --profile bedrock-dev` |
| Sign in with SSO | `aws sso login --profile bedrock-dev` |
| Configure access-key profile | `aws configure --profile bedrock-dev` |
| Verify AWS identity | `aws sts get-caller-identity --profile bedrock-dev` |
| Set default Region | `aws configure set region us-east-1 --profile bedrock-dev` |
| List inference profiles | `aws bedrock list-inference-profiles --region us-east-1 --profile bedrock-dev` |
| Launch Claude Code | `claude` |
| Check Claude Code status | `/status` (inside Claude Code) |

## 14. Final checklist

- [ ] AWS account created and billing understood.
- [ ] A dedicated AWS identity selected (SSO/role preferred).
- [ ] AWS CLI v2 installed.
- [ ] AWS profile configured and authentication verified.
- [ ] Amazon Bedrock model/inference profile available in the chosen Region.
- [ ] Inference profile status checked.
- [ ] Required IAM permissions confirmed.
- [ ] Claude Code installed and version checked.
- [ ] Bedrock environment variables configured.
- [ ] Claude Code launched and `/status` reviewed.
- [ ] A test prompt successfully answered.
- [ ] Persistent settings configured (optional).
- [ ] AWS Budgets and billing alerts considered.

**You're ready to use Claude Code CLI with Amazon Bedrock.**

---

## Included resources in this repository

- [IAM permissions guide](docs/IAM-PERMISSIONS.md) — least-privilege and cross-Region permission considerations.
- [Cost and credits guide](docs/COSTS-AND-CREDITS.md) — AWS billing and promotional credit considerations.
- [Set-BedrockClaudeSession.ps1](scripts/Set-BedrockClaudeSession.ps1) — sets Bedrock environment variables for the current PowerShell session and checks AWS identity.
- [Test-BedrockAccess.ps1](scripts/Test-BedrockAccess.ps1) — checks AWS identity and inference profile visibility. It does not invoke the model or prove invocation permissions.
- [Show-ClaudeSettingsExample.ps1](scripts/Show-ClaudeSettingsExample.ps1) — prints an example Claude settings JSON.

## Official documentation

- [Anthropic — Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Anthropic — Claude Code with Amazon Bedrock](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock)
- [AWS — Amazon Bedrock documentation](https://docs.aws.amazon.com/bedrock/)
- [AWS — Inference profiles and supported Regions](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)
- [AWS — IAM policy examples for Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html)
- [AWS — Amazon Bedrock pricing](https://aws.amazon.com/bedrock/pricing/)
- [AWS CLI v2 documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Contributing

Found an issue or have an improvement? Please open an issue or submit a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

# Security policy

## Reporting a vulnerability

Please do not publish credentials, tokens, account identifiers or exploitable details in a public issue. Use GitHub's private vulnerability reporting feature if enabled for this repository, or contact the repository maintainer privately.

## Safe use

- Never commit AWS access keys, secret keys, session tokens, .env files or local AWS configuration.
- Do not use the AWS root user for routine development.
- Prefer IAM Identity Center or short-lived role credentials.
- Apply least-privilege permissions.
- Enable MFA and monitor AWS billing.
- Redact account IDs and other sensitive values from logs before sharing.

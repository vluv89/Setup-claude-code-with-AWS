# IAM permissions for Claude Code with Bedrock

Use a dedicated development identity and grant only the actions required for your workflow. Prefer IAM Identity Center or an assumed role where practical. Do not use the AWS account root user for routine development.

## Common actions

Depending on the workflow and current AWS/Anthropic integration requirements, permissions commonly include:

- bedrock:InvokeModel
- bedrock:InvokeModelWithResponseStream
- bedrock:GetInferenceProfile
- bedrock:ListInferenceProfiles

Validate exact action requirements against current AWS and Anthropic documentation. Some list/read actions may help with setup but may not be required at runtime.

## Resource scoping

Do not assume that granting access only to a source-Region inference-profile ARN is sufficient. For cross-region inference profiles, AWS authorization can require access to the inference profile resource and the underlying foundation model resources in destination Regions used by that profile.

Use the exact profile ARN and foundation model ARNs applicable to your selected model and routing profile. Avoid broad bedrock:* permissions on Resource: "*" unless a narrowly justified setup step requires it, and remove temporary permissions afterwards.

## Operational safeguards

- Enable MFA for human users.
- Avoid long-lived access keys where possible.
- Never commit credentials or paste them into scripts.
- Use separate development and production identities.
- Review CloudTrail and billing activity.
- Check AWS Organizations service control policies and permission boundaries if a call is denied.

## References

- Bedrock identity-based policy examples: https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html
- Inference profiles: https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles.html
- Claude Code with Bedrock: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock

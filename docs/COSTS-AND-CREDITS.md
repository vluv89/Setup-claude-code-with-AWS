# Costs and AWS credits

## Is Claude Code on Bedrock free?

Not automatically. Claude Code is a client; when configured for Amazon Bedrock, model inference requests are billed by AWS according to the model, Region, token usage and applicable pricing terms.

AWS Free Tier benefits or promotional credits may offset some eligible usage, but eligibility varies. Credits can have exclusions, expiry dates, service restrictions or other conditions. Never assume a specific Claude model or Bedrock request is covered.

## Before experimenting

1. Review current Amazon Bedrock pricing: https://aws.amazon.com/bedrock/pricing/
2. Review the credits and promotional terms in your AWS Billing console.
3. Create an AWS Budget and billing alerts: https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
4. Start with small tests and monitor usage.
5. Remove or disable resources and credentials you no longer need.

This repository does not promise free usage or determine whether your account's credits cover a particular model. Confirm current charges and credit eligibility directly in your AWS account.

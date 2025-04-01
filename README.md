# Atlantis Local

This repository demonstrates setting up Atlantis locally for Terraform automation with GitHub integration.

When there is a PR to change our Terraform files, GitHub sends a message to Atlantis through the repository's webhook, notifying it. Since we are running Atlantis locally, we need ngrok to expose our endpoint to the internet so GitHub's events can reach it. Atlantis, in turn, will comment on the PR with the plan, and we can decide whether to apply the configurations.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Steps](#setup-steps)
  - [1. ngrok Configuration](#1-ngrok-configuration)
  - [2. Webhook Configuration](#2-webhook-configuration)
  - [3. GitHub Access Token](#3-github-access-token)
  - [4. Start Atlantis](#4-start-atlantis)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Prerequisites

Run the `prereqs.sh` script to install the tools needed to complete the steps below:

```bash
chmod +x ./prereqs.sh
./prereqs.sh
```

## Setup Steps

### 1. ngrok Configuration

1. [Sign up](https://dashboard.ngrok.com/signup) or log in to ngrok.
2. Copy your auth token from the dashboard and enable the static domain feature.
3. Start the ngrok proxy on port 4141:
   ```bash
   ngrok http 4141
   ```
4. Export the URL (replace `your-static-domain` with your actual ngrok domain):
   ```bash
   export URL=https://your-static-domain.ngrok-free.app
   ```

### 2. Webhook Configuration

1. Generate a webhook secret. This will be configured on GitHub's webhook so that when GitHub calls Atlantis, it knows the request is authentic:
   ```bash
   export SECRET=$(pwgen -Bs 20 1)
   ```

2. Add a webhook to your GitHub repository using the GitHub CLI:
   ```bash
   gh api \
     --method POST \
     -H "Accept: application/vnd.github+json" \
     -H "X-GitHub-Api-Version: 2022-11-28" \
     /repos/lariskovski/atlantis-local/hooks \
     -f "name=web" \
     -f "active=true" \
     -f "events[]=issue_comment" \
     -f "events[]=push" \
     -f "events[]=pull_request" \
     -f "events[]=pull_request_review" \
     -f "config[url]=$URL/events" \
     -f "config[secret]=$SECRET" \
     -f "config[content_type]=json" \
     -f "config[insecure_ssl]=0"
   ```

### 3. GitHub Access Token

1. Create a Personal Access Token with the `repo` scope.
2. Export the token:
   ```bash
   export TOKEN="your-github-token"
   ```

### 4. Start Atlantis

1. Set the required environment variables:
   ```bash
   export GH_USERNAME=$(git config user.name)
   export REPO_ALLOWLIST="github.com/$GH_USERNAME/atlantis-local"
   ```

2. Start the Atlantis server:
   ```bash
   atlantis server \
     --atlantis-url="$URL" \
     --gh-user="$GH_USERNAME" \
     --gh-token="$TOKEN" \
     --gh-webhook-secret="$SECRET" \
     --repo-allowlist="$REPO_ALLOWLIST"
   ```

## Verification

1. Create a pull request with Terraform changes to test the setup:
   ```bash
   git checkout -b atlantis-test-$(pwgen -Bs 5 1)
   echo " " >> main.tf
   git add main.tf
   git commit -m "add change to trigger atlantis"
   gh pr create --title "Atlantis" -b " " -R $REPO_ALLOWLIST
   open https://$REPO_ALLOWLIST/pulls
   ```

2. Check that Atlantis is running:
   ```bash
   curl ${URL}
   ```

### Removing Lock

If a lock is created, open the Atlantis dashboard:
```bash
open $URL
```
Click on the lock and remove it.

## Troubleshooting

- Verify the ngrok tunnel is active and accessible.
- Confirm webhook deliveries in GitHub repository settings.
- Check Atlantis server logs for any errors.

## Additional Resources

- [Atlantis Documentation](https://www.runatlantis.io/docs/)
- [Testing Locally Guide](https://www.runatlantis.io/guide/testing-locally.html)
- [GitHub Webhooks Documentation](https://docs.github.com/en/rest/repos/webhooks?apiVersion=2022-11-28#create-a-repository-webhook)
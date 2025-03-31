# Atlantis POC

This repository demonstrates setting up Atlantis for Terraform automation with GitHub integration.

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

Run the prereqs script to install the tools needed to complete the steps below:

```bash
chmod +x ./prereqs.sh
./prereqs.sh
```

## Setup Steps

### 1. ngrok Configuration

1. [Sign up](https://dashboard.ngrok.com/signup) or login to ngrok.
2. Copy your auth token from the dashboard.
3. Start the ngrok proxy on port 4141:
   ```bash
   ngrok http 4141
   ```
4. Get your public URL from the [ngrok endpoints dashboard](https://dashboard.ngrok.com/endpoints).
5. Export the URL:
   ```bash
   export URL=https://your-unique-id.ngrok-free.app
   ```

### 2. Webhook Configuration

1. Generate a webhook secret:
   ```bash
   export SECRET=$(pwgen -Bs 20 1)
   ```

2. Add a webhook to your GitHub repository using the GitHub CLI:
   ```bash
   gh api \
     --method POST \
     -H "Accept: application/vnd.github+json" \
     -H "X-GitHub-Api-Version: 2022-11-28" \
     /repos/lariskovski/atlantis-poc/hooks \
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

1. Set required environment variables:
   ```bash
   export GH_USERNAME=$(git config user.name)
   export REPO_ALLOWLIST="github.com/$GH_USERNAME/atlantis-poc"
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

2. Check Atlantis is running:
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
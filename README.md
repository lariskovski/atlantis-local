# Atlantis POC

This repository demonstrates setting up Atlantis for Terraform automation with GitHub integration.

## Prerequisites

Ensure the following tools are installed on your system. You can use Homebrew for installation:

1. **ngrok**: Used to expose local servers to the internet securely.
   ```bash
   brew install ngrok
   ```

2. **pwgen**: A utility for generating secure random passwords.
   ```bash
   brew install pwgen
   ```

3. **wget**: A command-line tool for downloading files from the web (if not already installed).
   ```bash
   brew install wget
   ```

### Install Atlantis 0.32

```sh
❯ wget https://github.com/runatlantis/atlantis/releases/download/v0.32.0/atlantis_darwin_amd64.zip
Salvando em: “atlantis_darwin_amd64.zip”
❯ tar -xvf atlantis_darwin_amd64.zip
❯ mv atlantis /usr/local/bin
❯ atlantis version
atlantis 0.32.0 (commit: ea838ac) (build date: 2024-12-20T02:50:43Z)
```

#### Why version 0.32?

Atlantis v 0.33 (brew's default version) throws an error:

```sh
running git clone --depth=1 --branch lariskovski-patch-1 --single-branch https://larissa:<redacted>@github.com/lariskovski/atlantis-poc.git /Users/larissa/.atlantis/repos/lariskovski/atlantis-poc/3/default: : exec: "git": executable file not found in $PATH
```

## Setup Steps

### 1. ngrok Configuration

1. [Sign up](https://dashboard.ngrok.com/signup) or login to ngrok
2. Copy your auth token from the dashboard
3. Start the ngrok proxy on port 4141:
   ```bash
   ngrok http 4141
   ```
4. Get your public URL from the [ngrok endpoints dashboard](https://dashboard.ngrok.com/endpoints)
5. Export the URL:
   ```bash
   export URL=https://your-unique-id.ngrok-free.app
   ```

### 2. Webhook Configuration

1. Generate a webhook secret:
   ```bash
   export SECRET=$(pwgen -Bs 20 1)
   ```

2. Add webhook to your GitHub repository:
   - Navigate to: Repository Settings > Webhooks > Add webhook
   - Configure the following:
     ```
     Payload URL: ${URL}/events
     Content type: application/json
     Secret: <your-generated-secret>
     ```
   - Select individual events:
     - Pull request reviews
     - Pushes
     - Issue comments
     - Pull requests
   - Ensure webhook is Active

### 3. GitHub Access Token

1. Create a Personal Access Token with `repo` scope
2. Export the token:
   ```bash
   export TOKEN="your-github-token"
   ```

### 4. Start Atlantis

1. Set required environment variables:
   ```bash
   export USERNAME="your-github-username"
   export REPO_ALLOWLIST="github.com/your-username/atlantis-poc"
   ```

2. Start the Atlantis server:
   ```bash
   atlantis server \
     --atlantis-url="$URL" \
     --gh-user="$USERNAME" \
     --gh-token="$TOKEN" \
     --gh-webhook-secret="$SECRET" \
     --repo-allowlist="$REPO_ALLOWLIST"
   ```

## Verification

1. Check Atlantis is running:
   ```bash
   curl ${URL}
   ```
2. Create a pull request with Terraform changes to test the setup

## Troubleshooting

- Verify ngrok tunnel is active and accessible
- Confirm webhook deliveries in GitHub repository settings
- Check Atlantis server logs for any errors

## Additional Resources

- [Atlantis Documentation](https://www.runatlantis.io/docs/)
- [Testing Locally Guide](https://www.runatlantis.io/guide/testing-locally.html)
- [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks)
# Install ngrok: Used to expose local servers to the internet securely.
brew install ngrok

# Install pwgen: A utility for generating secure random passwords.
brew install pwgen

# Install Atlantis 0.32.0
# Download Atlantis binary
wget https://github.com/runatlantis/atlantis/releases/download/v0.32.0/atlantis_darwin_amd64.zip
tar -xvf atlantis_darwin_amd64.zip
mv atlantis /usr/local/bin
# Why version 0.32? Atlantis v0.33.0 (brew's default version) throws an error:
# running git clone [...] : exec: "git": executable file not found in $PATH
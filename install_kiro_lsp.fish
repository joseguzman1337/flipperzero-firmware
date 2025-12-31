#!/usr/bin/env fish

# Install System Dependencies & Native LSPs
echo "Installing Pacman packages..."
sudo pacman -S --noconfirm --needed \
    go \
    gopls \
    jdk-openjdk \
    jdtls \
    python \
    python-lsp-server \
    rust-analyzer \
    ruby \
    nodejs \
    npm

# Install TypeScript Language Server
echo "Installing TypeScript LSP..."
sudo npm install -g --silent typescript typescript-language-server

# Install Solargraph (Ruby)
echo "Installing Ruby Solargraph..."
sudo gem install --silent solargraph

# Verify Installations
echo "--- Verification ---"
for cmd in gopls jdtls pylsp rust-analyzer solargraph typescript-language-server
    if type -q $cmd
        echo "✅ $cmd found at "(which $cmd)
    else
        echo "❌ $cmd NOT found. Installation may have failed."
    end
end

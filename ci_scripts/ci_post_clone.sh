#!/bin/bash
set -e

# Install mise (package manager for Tuist)
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

# Install and activate Tuist
mise install tuist
eval "$(mise activate bash)"

# Generate Xcode project
cd ../
tuist generate

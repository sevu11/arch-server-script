#!/bin/bash

# Basic script to run the omarchy.org install command
# Make sure you trust the source before running this script

echo "Running omarchy.org installer..."
wget -qO- https://omarchy.org/install | bash

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Installation completed successfully!"
else
    echo "Installation failed with exit code $?"
    exit 1
fi

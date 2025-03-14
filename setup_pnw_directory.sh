#!/bin/bash

echo "🔧 Setting up PNW-MVP Directory Structure..."

# Step 1: Check for and Rename Incorrect `Directory` File
if [ -f "pnw_mvp/Directory" ]; then
    echo "⚠️ Warning: 'Directory' exists as a file. Renaming it to prevent conflicts..."
    mv pnw_mvp/Directory pnw_mvp/Directory.bak
fi

# Step 2: Ensure Correct Directory Structure
if [ ! -d "pnw_mvp/directory" ]; then
    echo "📁 Creating 'pnw_mvp/directory/'..."
    mkdir -p pnw_mvp/directory
fi

if [ ! -d "pnw_mvp/directory/.aleo" ]; then
    echo "📁 Creating 'pnw_mvp/directory/.aleo/'..."
    mkdir -p pnw_mvp/directory/.aleo
fi

echo "✅ PNW-MVP Directory Setup Complete!"

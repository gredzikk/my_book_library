#!/bin/bash
# Script to prepare environment for testing

# Check if .env exists, if not create it from template
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    if [ -f .env.template ]; then
        echo "📝 Creating .env from .env.template..."
        cp .env.template .env
        echo "✅ .env file created. Please update it with your actual credentials."
    elif [ -f .env.test ]; then
        echo "📝 Creating .env from .env.test (for local testing)..."
        cp .env.test .env
        echo "✅ .env file created with test placeholders."
    else
        echo "❌ No template file found. Please create a .env file manually."
        exit 1
    fi
else
    echo "✅ .env file already exists."
fi

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Run tests based on argument
if [ "$1" = "unit" ]; then
    echo "🧪 Running unit tests..."
    flutter test
elif [ "$1" = "e2e" ]; then
    echo "🧪 Running E2E tests..."
    flutter test integration_test/
elif [ "$1" = "all" ]; then
    echo "🧪 Running all tests..."
    flutter test
    flutter test integration_test/
else
    echo "Usage: $0 [unit|e2e|all]"
    echo "  unit - Run unit tests only"
    echo "  e2e  - Run E2E tests only"
    echo "  all  - Run all tests"
    exit 1
fi

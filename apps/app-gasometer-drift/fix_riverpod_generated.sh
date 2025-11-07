#!/bin/bash

# Script to fix Riverpod generated files that use ProviderOverride instead of Override
# This is needed when riverpod_generator generates code incompatible with riverpod 2.6.1

echo "Fixing Riverpod generated files..."

# Find all .g.dart files in the lib directory
find lib -name "*.g.dart" -type f | while read -r file; do
    echo "Processing $file..."

    # Replace ProviderOverride with Override
    sed -i '' 's/ProviderOverride(/Override(/g' "$file"

    # Fix Family classes that need getProviderOverride implementation
    # Add the missing method implementation
    sed -i '' '/class.*Family extends Family.*{/a\
  @override\
  ProviderBase<State> getProviderOverride(ProviderBase<State> provider) {\
    return provider;\
  }\
' "$file"

    # Add more sed commands here as needed
done

echo "Fixed Riverpod generated files successfully!"
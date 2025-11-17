#!/bin/bash

# Script para executar o app-gasometer na web com Drift WASM
# Adiciona os headers necessários para melhor performance do Drift

echo "🚀 Starting app-gasometer on web with Drift WASM support..."
echo ""
echo "📋 Adding COOP/COEP headers for optimal performance:"
echo "   - Cross-Origin-Opener-Policy: same-origin"
echo "   - Cross-Origin-Embedder-Policy: require-corp"
echo ""
echo "⚠️  Note: These headers may break Google Auth popups."
echo "   If you have issues, run without headers:"
echo "   flutter run -d chrome"
echo ""

flutter run -d chrome \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp

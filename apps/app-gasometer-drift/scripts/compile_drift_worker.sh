#!/bin/bash

# Script para compilar o drift_worker.dart para JavaScript
# Necessário para o funcionamento do Drift no web

echo "🔧 Compilando drift_worker.dart para JavaScript..."

# Compilar o drift_worker.dart
dart compile js web/drift_worker.dart -o web/drift_worker.dart.js

if [ $? -eq 0 ]; then
    echo "✅ drift_worker.dart.js compilado com sucesso!"
    echo "📁 Arquivo gerado: web/drift_worker.dart.js"
else
    echo "❌ Erro ao compilar drift_worker.dart.js"
    exit 1
fi
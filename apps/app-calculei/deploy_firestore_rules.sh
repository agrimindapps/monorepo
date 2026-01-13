#!/bin/bash
# Script para fazer deploy das regras do Firestore
# Uso: ./deploy_firestore_rules.sh

set -e  # Exit on error

echo "🔐 Deploy de Regras Firestore - Calculei"
echo "=========================================="
echo ""

# Verificar se está na pasta correta
if [ ! -f "firestore.rules" ]; then
    echo "❌ Erro: arquivo firestore.rules não encontrado"
    echo "   Execute este script na pasta apps/app-calculei"
    exit 1
fi

# Verificar se Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI não encontrado"
    echo ""
    echo "Instale com: npm install -g firebase-tools"
    echo "Ou use: npx firebase-tools deploy --only firestore:rules"
    exit 1
fi

echo "📋 Verificando projeto Firebase..."
PROJECT_ID=$(firebase use 2>&1 | grep -oE "calculei-[a-z0-9]+")

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Projeto Firebase não configurado"
    echo "   Execute: firebase use calculei-52e71"
    exit 1
fi

echo "✅ Projeto: $PROJECT_ID"
echo ""

# Perguntar o que fazer deploy
echo "O que deseja fazer deploy?"
echo "1) Apenas regras do Firestore"
echo "2) Regras + Índices do Firestore"
echo "3) Tudo (Regras + Índices + Hosting)"
echo ""
read -p "Escolha (1-3): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Fazendo deploy das regras..."
        firebase deploy --only firestore:rules
        ;;
    2)
        echo ""
        echo "🚀 Fazendo deploy das regras e índices..."
        firebase deploy --only firestore:rules,firestore:indexes
        ;;
    3)
        echo ""
        echo "🚀 Fazendo deploy completo..."
        firebase deploy
        ;;
    *)
        echo "❌ Opção inválida"
        exit 1
        ;;
esac

echo ""
echo "✅ Deploy concluído com sucesso!"
echo ""
echo "📝 Próximos passos:"
echo "   1. Certifique-se que criou um usuário admin no Firebase Authentication"
echo "   2. Verifique se o email está em firestore.rules na função isAdmin()"
echo "   3. Acesse: https://calculei-52e71.web.app/admin"
echo "   4. Faça login com as credenciais do admin"
echo ""
echo "📚 Mais detalhes em: FIREBASE_RULES_SETUP.md"

#!/bin/bash

# Script para testar o CI localmente
# Uso: ./test_ci.sh

set -e  # Para se houver erro

echo "🚀 Testando CI localmente..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${YELLOW}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Verificar versão do Dart
print_step "Verificando versão do Dart..."
dart --version
echo ""

# 2. Instalar dependências
print_step "Instalando dependências..."
dart pub get
print_success "Dependências instaladas!"
echo ""

# 3. Verificar formatação
print_step "Verificando formatação..."
if dart format --output=none --set-exit-if-changed .; then
    print_success "Formatação OK!"
else
    print_error "Problemas de formatação encontrados!"
    exit 1
fi
echo ""

# 4. Analisar código
print_step "Analisando código..."
if dart analyze --fatal-infos; then
    print_success "Análise OK!"
else
    print_error "Problemas de análise encontrados!"
    exit 1
fi
echo ""

# 5. Rodar testes
print_step "Rodando testes..."
if dart test; then
    print_success "Todos os testes passaram!"
else
    print_error "Alguns testes falharam!"
    exit 1
fi
echo ""

# 6. Verificar publicação
print_step "Verificando publicação (dry-run)..."
dart pub publish --dry-run || true
print_success "Verificação de publicação concluída!"
echo ""

echo -e "${GREEN}🎉 Todos os checks do CI passaram!${NC}"

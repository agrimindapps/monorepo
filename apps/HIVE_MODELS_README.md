# Documentação dos Modelos Hive - Monorepo

Este documento serve como índice central para as documentações de modelos Hive de todos os aplicativos do monorepo.

## 📋 Visão Geral

A documentação foi gerada automaticamente em **5 de novembro de 2025** e contém informações detalhadas sobre:
- **TypeId** de cada modelo Hive
- **Campos** (HiveFields) com seus IDs, tipos e nullability
- **Localização** dos arquivos fonte

## 📱 Aplicativos Documentados

### ✅ Com Modelos Hive (9 apps)

| App | Modelos | Documentação | Observações |
|-----|---------|--------------|-------------|
| **app-calculei** | 7 modelos | [docs/HIVE_MODELS.md](app-calculei/docs/HIVE_MODELS.md) | Calculadoras trabalhistas |
| **app-gasometer** | 9 modelos | [docs/HIVE_MODELS.md](app-gasometer/docs/HIVE_MODELS.md) | Gerenciamento de veículos |
| **app-nebulalist** | 3 modelos | [docs/HIVE_MODELS.md](app-nebulalist/docs/HIVE_MODELS.md) | Listas de tarefas |
| **app-nutrituti** | 4 modelos | [docs/HIVE_MODELS.md](app-nutrituti/docs/HIVE_MODELS.md) | Nutrição e saúde |
| **app-petiveti** | 11 modelos | [docs/HIVE_MODELS.md](app-petiveti/docs/HIVE_MODELS.md) | Gerenciamento de pets |
| **app-plantis** | 5 modelos | [docs/HIVE_MODELS.md](app-plantis/docs/HIVE_MODELS.md) | Gerenciamento de plantas |
| **app-receituagro** | 12 modelos | [docs/HIVE_MODELS.md](app-receituagro/docs/HIVE_MODELS.md) | Defensivos agrícolas |
| **app-taskolist** | 2 modelos | [docs/HIVE_MODELS.md](app-taskolist/docs/HIVE_MODELS.md) | Gerenciamento de tarefas |
| **app-termostecnicos** | 3 modelos | [docs/HIVE_MODELS.md](app-termostecnicos/docs/HIVE_MODELS.md) | Termos técnicos |

### ❌ Sem Modelos Hive (2 apps)

- **app-agrihurbi** - Não utiliza Hive para armazenamento local
- **app-minigames** - Não utiliza Hive para armazenamento local

## 🎯 Como Usar as Documentações

### 1. Navegação Rápida
Cada documentação contém um **índice** no início com links diretos para cada modelo.

### 2. Estrutura das Documentações

Cada modelo é documentado com:

```markdown
## NomeDoModelo

**TypeId**: `XX`  
**Arquivo**: `caminho/relativo/do/arquivo.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `campo` | `TipoDoCampo` | ✓/✗ |
```

### 3. Informações Importantes

- **TypeId**: Identificador único do modelo no Hive (deve ser único por app)
- **HiveField ID**: Ordem dos campos no Hive (importante para migração)
- **Nullable**: ✓ indica que o campo pode ser null, ✗ indica que é obrigatório
- **Tipo**: Tipo Dart do campo (String, int, double, DateTime, List, Map, etc.)

## 🔍 TypeId Ranges

Para evitar conflitos, os apps utilizam ranges de TypeIds:

| App | Range | Observações |
|-----|-------|-------------|
| **app-gasometer** | 10-19 | Modelos de veículos e combustível |
| **app-calculei** | 10-16 | Calculadoras diversas |
| **app-receituagro** | 100-120 | Modelos agrícolas |
| **app-plantis** | 0-10 | Modelos de plantas e espaços |
| **app-petiveti** | 0-20 | Modelos de pets e veterinária |
| **app-nebulalist** | 0-5 | Listas e itens |
| **app-nutrituti** | 0-10 | Nutrição e exercícios |
| **app-taskolist** | 0-5 | Tarefas |
| **app-termostecnicos** | 0-5 | Termos e comentários |

## 🚀 Principais Aplicativos

### 1. app-receituagro (12 modelos)
O maior app em termos de modelos Hive. Contém:
- Modelos de defensivos (fitossanitários)
- Pragas e culturas
- Sistema de favoritos
- Comentários e configurações

### 2. app-petiveti (11 modelos)
Gerenciamento completo de pets:
- Animais e raças
- Vacinas e medicamentos
- Consultas e gastos
- Lembretes e cálculos

### 3. app-gasometer (9 modelos)
Controle de veículos:
- Veículos e categorias
- Abastecimentos
- Manutenções e despesas
- Odômetros e auditoria

## 📝 Notas de Desenvolvimento

### Adicionando Novos Campos

Ao adicionar novos campos HiveField:
1. Use o próximo ID disponível (não reutilize IDs)
2. Atualize a documentação executando o script de geração
3. Considere criar migrations se necessário

### Conflitos de TypeId

Se ocorrer conflito de TypeId:
1. Verifique a tabela de ranges acima
2. Escolha um ID dentro do range do seu app
3. Atualize a documentação

### Script de Geração

Para regerar as documentações:

```bash
python3 /tmp/extract_hive_docs.py
```

## 🔗 Links Úteis

- [Documentação do Hive](https://docs.hivedb.dev/)
- [TypeAdapter Generator](https://docs.hivedb.dev/#/custom-objects/generate_adapter)
- [Migrations no Hive](https://docs.hivedb.dev/#/migration)

## 📊 Estatísticas

- **Total de Apps**: 11
- **Apps com Hive**: 9 (81.8%)
- **Total de Modelos**: 56+
- **Documentações Geradas**: 9 arquivos
- **Linhas de Documentação**: ~1,393 linhas

---

**Última Atualização**: 5 de novembro de 2025  
**Gerado por**: Script automático de extração de modelos Hive

# Dart Fix - Monorepo Report

Data: 2025-11-30 09:53:11

## Resumo Executivo

| App | Warnings Antes | Warnings Depois | Fixes Aplicados | Redução % |
|-----|----------------|-----------------|-----------------|-----------|
| app-agrihurbi | 328 | 272 | 37 | 17.0% |
| app-calculei | 414 | 222 | 143 | 46.3% |
| app-minigames | 360 | 167 | 138 | 53.6% |
| app-nebulalist | 188 | 162 | 24 | 13.8% |
| app-nutrituti | 52 | 41 | 11 | 21.1% |
| app-petiveti | 104 | 43 | 51 | 58.6% |
| app-plantis | 362 | 271 | 61 | 25.1% |
| app-receituagro | 212 | 145 | 47 | 31.6% |
| app-taskolist | 116 | 57 | 39 | 50.8% |
| app-termostecnicos | 23 | 23 | 0 | 0% |
| web_receituagro | 120 | 0 | 18 | 100.0% |
| **TOTAL** | **2279** | **1403** | **569** | **38.4%** |

## Estatísticas Gerais

- **Apps processados**: 11
- **Warnings eliminados**: 876
- **Fixes aplicados**: 569
- **Redução média**: 38.4%

## Notas

- **app-gasometer**: Já havia sido processado anteriormente pelo analyzer-fixer agent
- Fixes aplicados incluem: prefer_const_constructors, directives_ordering, unnecessary_import, etc.
- Warnings restantes requerem refatoração manual (only_throw_errors, avoid_classes_with_only_static_members, etc.)

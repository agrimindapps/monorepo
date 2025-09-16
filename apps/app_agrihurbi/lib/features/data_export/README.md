# LGPD Data Export Feature

Esta funcionalidade implementa o direito de portabilidade de dados conforme a LGPD (Lei Geral de Proteção de Dados), permitindo que usuários exportem seus dados pessoais do aplicativo.

## 📋 Funcionalidades

- **Exportação de dados pessoais** apenas (favoritos, comentários, perfil, configurações)
- **Múltiplos formatos** de exportação (JSON, CSV)
- **Rate limiting** de 1 exportação por 24 horas
- **Progress tracking** em tempo real durante a exportação
- **Sanitização de dados** sensíveis
- **Interface integrada** na página de configurações

## 🏗️ Arquitetura

Segue padrão **Clean Architecture** com separação clara entre camadas:

```
lib/features/data_export/
├── domain/                 # Business rules
│   ├── entities/          # Data structures
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic
├── data/                  # External data layer
│   ├── datasources/       # Local data sources
│   ├── services/          # Formatting and file services
│   └── repositories/      # Repository implementations
├── presentation/          # UI layer
│   ├── providers/         # State management
│   ├── widgets/           # UI components
│   └── pages/             # Screen pages
└── di/                    # Dependency injection
```

## 🚀 Como Integrar

### 1. Adicionar Dependencies no pubspec.yaml

```yaml
dependencies:
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
  permission_handler: ^11.0.1
```

### 2. Configurar Providers no main.dart

```dart
import 'features/data_export/di/data_export_dependencies.dart';

MultiProvider(
  providers: [
    // Seus providers existentes...
    ...DataExportDependencies.providers,
  ],
  child: MaterialApp(...),
)
```

### 3. Adicionar na Página de Configurações

```dart
import 'features/data_export/presentation/widgets/data_export_tile.dart';

// Opção 1: Seção completa
DataExportSection()

// Opção 2: Apenas o tile
DataExportTile()
```

### 4. Configurar Permissões Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
```

## 📊 Dados Exportados

### ✅ Incluídos (dados do usuário):
- **Perfil**: nome, email, datas de criação/login
- **Favoritos**: produtos marcados como favoritos
- **Comentários**: avaliações e comentários sobre produtos
- **Configurações**: preferências e settings personalizados

### ❌ Excluídos (não são propriedade do usuário):
- Dados de produtos/defensivos
- Dados de empresas/fabricantes
- Conteúdo da base de conhecimento
- Dados estatísticos do app

## 🔐 Segurança e Compliance

- **Rate limiting**: 1 export por 24 horas por usuário
- **Sanitização**: remoção de dados sensíveis quando necessário
- **Auditoria**: log de todas as exportações realizadas
- **Local storage**: arquivos salvos apenas localmente no dispositivo
- **LGPD compliant**: metadados de exportação incluídos

## 🎛️ Uso da Interface

1. **Acessar**: Configurações → Privacidade e Dados → Exportar Meus Dados
2. **Verificar**: Sistema verifica disponibilidade (rate limit)
3. **Configurar**: Escolher formato (JSON/CSV) e dados para incluir
4. **Exportar**: Acompanhar progresso em tempo real
5. **Concluir**: Arquivo salvo em Downloads

## 🧪 Testes

```bash
# Rodar todos os testes da feature
flutter test test/features/data_export/

# Testes específicos
flutter test test/features/data_export/domain/usecases/
flutter test test/features/data_export/data/services/
flutter test test/features/data_export/presentation/providers/
```

## 📁 Estrutura de Dados Exportados

### JSON Format
```json
{
  "metadata": {
    "export_date": "2024-06-15T10:30:00.000Z",
    "user_id": "user_123",
    "app_version": "1.0.0",
    "total_records": 15
  },
  "user_profile": {
    "name": "João Silva",
    "email": "joao@email.com",
    "created_at": "2023-01-15T00:00:00.000Z"
  },
  "favorites": [...],
  "comments": [...],
  "preferences": {...}
}
```

### CSV Format
```csv
# LGPD Data Export
# Export Date: 2024-06-15T10:30:00.000Z
# App Version: 1.0.0

## User Profile
Field,Value
Name,"João Silva"
Email,"joao@email.com"

## Favorites
Product ID,Product Name,Category,Created At
prod_001,"Herbicida XYZ","Herbicidas","2024-03-20T00:00:00.000Z"

...
```

## 🔧 Customização

### Adicionar Novos Tipos de Dados

1. Adicionar enum em `DataType`:
```dart
enum DataType {
  userProfile,
  favorites,
  comments,
  preferences,
  newDataType, // Adicionar aqui
}
```

2. Implementar coleta de dados no repository
3. Atualizar formatação JSON/CSV
4. Adicionar checkbox na UI

### Modificar Rate Limiting

Editar em `DataExportRepositoryImpl.canExport()`:
```dart
final daysSinceLastExport = now.difference(lastExportDate).inDays;
return daysSinceLastExport >= 1; // Alterar aqui
```

## 🐛 Troubleshooting

### Erro de Permissões
- Verificar permissões no AndroidManifest.xml
- Testar em dispositivo físico (emulador pode ter limitações)

### Arquivo Não Salvando
- Verificar espaço em disco
- Confirmar acesso à pasta Downloads
- Testar com diferentes formatos de arquivo

### Rate Limit Não Funcionando
- Verificar SharedPreferences
- Confirmar timezone/datetime consistency

## 🤝 Contributing

Ao modificar esta feature:

1. Manter padrão Clean Architecture
2. Adicionar testes para novas funcionalidades
3. Atualizar documentação
4. Verificar compliance LGPD
5. Testar em múltiplos dispositivos

## 📞 Suporte

Para dúvidas sobre implementação ou compliance LGPD, consultar:
- Documentação oficial da LGPD
- Guidelines do Google/Apple sobre privacidade
- Time de compliance da empresa
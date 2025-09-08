# Sistema de Exportação de Dados LGPD - GasOMeter

Este sistema implementa a funcionalidade completa de exportação de dados do usuário conforme a Lei Geral de Proteção de Dados (LGPD), permitindo que os usuários façam download de todos os seus dados pessoais armazenados no aplicativo.

## ✨ Funcionalidades Implementadas

### 🔒 Compliance LGPD
- **Direito de Portabilidade**: Usuários podem exportar todos os seus dados
- **Formato Estruturado**: Dados em JSON legível e CSV para análise
- **Metadados de Conformidade**: Informações sobre direitos do titular
- **Auditoria Completa**: Logs de todas as operações de exportação
- **Rate Limiting**: Máximo de 1 exportação por usuário por dia

### 📊 Dados Coletados
- **Perfil do Usuário**: Nome, email, configurações pessoais
- **Veículos**: Todos os veículos cadastrados
- **Abastecimentos**: Histórico completo de combustível
- **Manutenções**: Registros de manutenção dos veículos
- **Odômetro**: Leituras do odômetro
- **Despesas**: Despesas relacionadas aos veículos
- **Categorias**: Categorias de despesas personalizadas
- **Configurações**: Configurações do aplicativo (sanitizadas)

### 🎛️ Customização
- **Seleção de Categorias**: Usuário escolhe quais dados incluir
- **Filtro por Período**: Opcional - limitar dados por intervalo de datas
- **Incluir Anexos**: Opção para incluir avatars e arquivos
- **Preview dos Dados**: Estimativa de tamanho antes da exportação

### 📱 Multiplataforma
- **Android**: Salva em Documents, compartilha via Intent
- **iOS**: Salva em Documents, compartilha via UIActivityViewController  
- **Web**: Download automático via blob URL

### 🎨 Interface Intuitiva
- **Integração na ProfilePage**: Seção dedicada "Meus Dados"
- **Dialog de Customização**: Interface amigável para personalizar exportação
- **Progresso em Tempo Real**: Acompanhamento do processamento
- **Estados Visuais**: Loading, sucesso, erro, rate limit
- **Histórico**: Últimas exportações realizadas

## 🏗️ Arquitetura

### Estrutura de Pastas
```
lib/features/data_export/
├── domain/
│   ├── entities/                  # Entidades de negócio
│   │   ├── export_metadata.dart   # Metadados da exportação
│   │   ├── export_request.dart    # Configuração da exportação
│   │   └── export_result.dart     # Resultado da operação
│   ├── repositories/              # Interfaces
│   │   └── data_export_repository.dart
│   └── services/                  # Serviços de domínio
│       ├── data_export_service.dart      # Coleta e processamento
│       └── platform_export_service.dart # Abstração multiplataforma
├── data/
│   └── repositories/              # Implementações
│       └── data_export_repository_impl.dart
└── presentation/
    ├── providers/                 # Gerenciamento de estado
    │   └── data_export_provider.dart
    └── widgets/                   # Componentes UI
        ├── export_customization_dialog.dart
        ├── export_data_section.dart
        └── export_progress_dialog.dart
```

### Fluxo de Dados
1. **Usuário inicia exportação** na ProfilePage
2. **Dialog de customização** permite escolher dados e configurações
3. **DataExportProvider** coordena a operação
4. **DataExportService** coleta dados de todas as HiveBoxes
5. **Processamento** gera JSON, CSV e metadados
6. **PlatformExportService** salva e compartilha conforme plataforma
7. **Analytics** registra a operação para compliance
8. **Usuário recebe** arquivo final com todos os dados

## 🔧 Implementação Técnica

### Clean Architecture
- **Domain**: Entidades e regras de negócio puras
- **Data**: Implementação de repositórios e acesso a dados
- **Presentation**: UI e gerenciamento de estado

### Padrões Utilizados
- **Repository Pattern**: Abstração do acesso a dados
- **Provider Pattern**: Gerenciamento de estado reativo
- **Factory Pattern**: Criação de serviços multiplataforma
- **Strategy Pattern**: Diferentes estratégias por plataforma

### Coleta de Dados Segura
```dart
// Sanitização automática de dados sensíveis
Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
  final sanitized = <String, dynamic>{};
  
  for (final entry in data.entries) {
    final key = entry.key;
    final value = entry.value;
    
    // Remove dados sensíveis ou internos
    if (_isSensitiveKey(key)) continue;
    
    sanitized[key] = value;
  }
  
  return sanitized;
}

bool _isSensitiveKey(String key) {
  final sensitiveKeys = {
    'token', 'password', 'secret', 'key', 'auth',
    'session', 'firebase_token', 'device_id', 'installation_id',
  };
  
  final lowerKey = key.toLowerCase();
  return sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive));
}
```

### Rate Limiting
```dart
Future<bool> canExportData(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final lastExportKey = 'last_export_$userId';
  final lastExportTimestamp = prefs.getInt(lastExportKey);
  
  if (lastExportTimestamp == null) return true;
  
  final lastExport = DateTime.fromMillisecondsSinceEpoch(lastExportTimestamp);
  final now = DateTime.now();
  final difference = now.difference(lastExport);
  
  // Limite de 1 exportação por dia
  return difference.inHours >= 24;
}
```

## 📋 Como Usar

### 1. Configuração Inicial
O sistema já está configurado automaticamente. O DataExportProvider é registrado no ProviderSetup com lazy loading.

### 2. Interface do Usuário
A seção "Meus Dados" aparece automaticamente na ProfilePage para usuários autenticados (não anônimos).

### 3. Fluxo do Usuário
1. Usuário vai em **Perfil > Meus Dados**
2. Clica em **"Exportar Meus Dados"**
3. **Personaliza** quais dados incluir
4. **Confirma** a exportação
5. **Acompanha** o progresso em tempo real
6. **Recebe** arquivo ZIP com todos os dados
7. **Compartilha** via email, cloud storage, etc.

### 4. Estrutura do Arquivo Exportado

#### JSON Principal (`dados_completos.json`)
```json
{
  "export_metadata": {
    "generated_at": "2024-XX-XXTHH:MM:SS",
    "lgpd_compliance": true,
    "data_categories": ["profile", "vehicles", "fuel_records"],
    "format": "json",
    "checksum": "abc123"
  },
  "lgpd_compliance_info": {
    "data_controller": "GasOMeter App",
    "export_purpose": "Atendimento ao direito de portabilidade de dados (LGPD)",
    "user_rights": [
      "Direito de acesso aos dados pessoais",
      "Direito de correção de dados inexatos",
      "Direito de eliminação de dados desnecessários",
      "Direito de portabilidade dos dados",
      "Direito de revogação do consentimento"
    ],
    "contact_info": "Para questões sobre seus dados, contate o DPO em: privacy@gasometer.app"
  },
  "exported_data": {
    "user_profile": { /* dados do perfil */ },
    "vehicles": [ /* lista de veículos */ ],
    "fuel_records": [ /* histórico de abastecimentos */ ],
    // ... outros dados
  }
}
```

#### CSV Tabular (`dados_tabulares.csv`)
```csv
Categoria,Item,Campo,Valor,Data_Registro
user_profile,single_record,name,João Silva,2024-XX-XX
vehicles,item_1,make,Toyota,2024-XX-XX
vehicles,item_1,model,Corolla,2024-XX-XX
fuel_records,item_1,liters,40.5,2024-XX-XX
fuel_records,item_1,price,280.50,2024-XX-XX
```

#### Metadados (`LEIA-ME.json`)
Instruções e informações sobre a exportação, direitos LGPD e como interpretar os dados.

## 🔍 Analytics e Auditoria

### Eventos Rastreados
- `data_export_started`: Início da exportação
- `data_export_completed`: Conclusão (sucesso/erro)  
- `data_export_rate_limited`: Tentativa bloqueada por rate limit
- `data_export_shared`: Compartilhamento do arquivo
- `data_export_size_estimated`: Estimativa de tamanho

### Informações Coletadas
- **Hash do User ID**: Para evitar armazenar ID real
- **Categorias exportadas**: Quais dados foram incluídos
- **Tamanho do arquivo**: Para otimização futura
- **Tempo de processamento**: Para monitoramento de performance
- **Plataforma**: Android, iOS ou Web
- **Timestamp**: Data/hora da operação

### Compliance
- **Não armazenamos** IDs reais de usuário nos analytics
- **Logs de auditoria** completos para reguladores
- **Retenção limitada** dos logs conforme política de privacidade
- **Anonização** de dados sensíveis

## 🧪 Testes

### Cenários de Teste
1. **Exportação Completa**: Todos os dados, usuário premium
2. **Exportação Parcial**: Apenas algumas categorias
3. **Filtro por Data**: Dados de período específico
4. **Rate Limiting**: Tentativa dupla no mesmo dia
5. **Usuário Anônimo**: Não deve ver opção de exportação
6. **Dados Vazios**: Usuário sem dados cadastrados
7. **Erro de Processamento**: Falha na coleta de dados
8. **Multiplataforma**: Android, iOS e Web

### Validação LGPD
- [ ] Todos os dados pessoais incluídos
- [ ] Formato estruturado e legível
- [ ] Metadados de compliance presentes
- [ ] Direitos do titular documentados
- [ ] Auditoria da operação registrada
- [ ] Rate limiting implementado
- [ ] Dados sensíveis sanitizados

## 🚀 Deploy e Produção

### Pré-requisitos
- Analytics configurado no Firebase
- Permissions de storage configuradas (Android/iOS)
- Testes de integração passando
- Rate limiting validado

### Monitoramento
- Dashboard de analytics para exportações
- Alertas para falhas recorrentes
- Métricas de performance (tempo de processamento)
- Compliance reports mensais

## 📞 Suporte

Para questões técnicas sobre a implementação:
- Consulte o código em `/lib/features/data_export/`
- Verifique os logs do Analytics no Firebase Console
- Para compliance LGPD, consulte a documentação legal

---

**Desenvolvido em conformidade com a LGPD**  
Sistema completo de exportação de dados pessoais para o aplicativo GasOMeter.
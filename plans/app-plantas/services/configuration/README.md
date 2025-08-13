# Configuration Services

Este diretório contém services responsáveis por gerenciar configurações da aplicação.

## DefaultSpacesService

Service responsável por gerenciar a configuração dos espaços padrão que são criados quando o usuário não possui nenhum espaço cadastrado.

### Funcionalidades

- **Internacionalização**: Utiliza o sistema de traduções do GetX para suportar múltiplos idiomas
- **Customização Local**: Permite personalizar os espaços via SharedPreferences
- **Configuração Remota**: Preparado para suportar configuração via servidor (futuro)
- **Cache**: Mantém configurações em cache para melhor performance

### Como usar

```dart
// Obter instância do service
final service = DefaultSpacesService.instance;

// Criar espaços padrão
final espacos = await service.createDefaultSpaceModels();

// Customizar configuração
final customSpaces = [
  DefaultSpaceConfiguration(
    nameKey: 'espacos.padrao.escritorio.nome',
    descriptionKey: 'espacos.padrao.escritorio.descricao',
    isActive: true,
    order: 1,
  ),
];
await service.customizeDefaultSpaces(customSpaces);

// Habilitar/desabilitar espaços específicos
await service.setEnabledSpaces([
  'espacos.padrao.sala_estar.nome',
  'espacos.padrao.quarto.nome',
]);

// Resetar para configuração padrão
await service.resetToDefaultConfiguration();
```

### Customização via SharedPreferences

- `default_spaces_enabled`: Lista de chaves de espaços habilitados
- `custom_default_spaces`: Configuração customizada em JSON
- `use_remote_default_spaces`: Se deve usar configuração remota

### Traduções

As traduções são definidas em `pages/espacos_page/translations/espacos_translations.dart`:

```dart
// Português
'espacos.padrao.sala_estar.nome': 'Sala de estar',
'espacos.padrao.sala_estar.descricao': 'Ambiente principal da casa',

// Inglês  
'espacos.padrao.sala_estar.nome': 'Living Room',
'espacos.padrao.sala_estar.descricao': 'Main room of the house',
```

### Issue Resolvida

Esta implementação resolve a issue #28: "Hardcoded Default Values" do arquivo `repository/issues.md`:

- ✅ Criado arquivo de configuração para valores default
- ✅ Implementado i18n para strings  
- ✅ Permitida customização via SharedPreferences
- ✅ Preparado para configuração remota (futuro)
- ✅ Mantido fallback para compatibilidade

### Arquivos Relacionados

- `constants/default_spaces_config.dart`: Configurações e modelos
- `services/configuration/default_spaces_service.dart`: Service principal
- `pages/espacos_page/translations/espacos_translations.dart`: Traduções
- `repository/espaco_repository.dart`: Uso no repository
# Static Data Loader

Sistema de carregamento de dados estáticos do JSON para o banco de dados Drift.

## 📋 Visão Geral

O `StaticDataLoader` é responsável por popular as tabelas de referência do banco de dados Drift com dados estáticos provenientes de arquivos JSON na pasta `assets/database/json/`.

### Tabelas Carregadas

1. **Culturas** (`TBCULTURAS.json`)
   - Dados sobre culturas agrícolas
   - Campos: idCultura, nome

2. **Pragas** (`TBPRAGAS.json`)
   - Informações sobre pragas
   - Campos: idPraga, nome, nomeLatino

3. **PragasInf** (`TBPLANTASINF.json`)
   - Informações detalhadas sobre pragas
   - Campos: sintomas, controle, danos, condições favoráveis

4. **Fitossanitários** (`TBFITOSSANITARIOS_*.json`)
   - Produtos fitossanitários (herbicidas, fungicidas, inseticidas, etc.)
   - Campos: idDefensivo, nome, classe

5. **FitossanitáriosInfo** (`TBFITOSSANITARIOSINFO_*.json`)
   - Informações detalhadas sobre fitossanitários
   - Campos: modo de ação, formulação, toxicidade, carência

## 🚀 Uso

### Opção 1: Usando o Widget Wrapper (Recomendado)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/widgets/static_data_initializer.dart';

void main() {
  runApp(
    const ProviderScope(
      child: StaticDataInitializer(
        child: MyApp(),
      ),
    ),
  );
}
```

O `StaticDataInitializer` irá:
- Verificar se os dados já estão carregados
- Carregar automaticamente se necessário
- Mostrar tela de loading durante o carregamento
- Mostrar a aplicação quando pronto

### Opção 2: Carregamento Manual

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/database/providers/static_data_providers.dart';

// Em um ConsumerWidget ou ConsumerStatefulWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Carregar dados manualmente
        final success = await ref.read(loadStaticDataProvider.future);
        
        if (success) {
          print('Dados carregados com sucesso!');
        } else {
          print('Erro ao carregar dados');
        }
      },
      child: Text('Carregar Dados'),
    );
  }
}
```

### Opção 3: Verificar Status de Carregamento

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/database/providers/static_data_providers.dart';

class StatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataLoadedAsync = ref.watch(staticDataLoadedProvider);

    return staticDataLoadedAsync.when(
      data: (isLoaded) {
        return Text(isLoaded ? 'Dados carregados' : 'Dados não carregados');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

## 📁 Estrutura dos Arquivos JSON

Os arquivos JSON devem estar localizados em:

```
assets/database/json/
├── tbculturas/
│   └── TBCULTURAS.json
├── tbpragas/
│   └── TBPRAGAS.json
├── tbplantasinf/
│   └── TBPLANTASINF.json
├── tbfitossanitarios/
│   ├── TBFITOSSANITARIOS_FUNGICIDAS_BACTERICIDAS.json
│   ├── TBFITOSSANITARIOS_HERBICIDAS.json
│   ├── TBFITOSSANITARIOS_INSETICIDAS_ACARICIDAS.json
│   ├── TBFITOSSANITARIOS_ADJUVANTES.json
│   └── TBFITOSSANITARIOS_BIOLOGICOS.json
└── tbfitossanitariosinfo/
    ├── TBFITOSSANITARIOSINFO_A.json
    ├── TBFITOSSANITARIOSINFO_B.json
    └── ... (até Z)
```

### Formato dos JSONs

#### Culturas
```json
[
  {
    "idReg": "cultura_001",
    "cultura": "Soja"
  }
]
```

#### Pragas
```json
[
  {
    "idReg": "praga_001",
    "nomeComum": "Lagarta da soja",
    "nomeCientifico": "Anticarsia gemmatalis"
  }
]
```

## 🔄 Mapeamento JSON → Drift

| Tabela | Campo JSON | Campo Drift |
|--------|-----------|-------------|
| Culturas | `idReg` | `idCultura` |
| Culturas | `cultura` | `nome` |
| Pragas | `idReg` | `idPraga` |
| Pragas | `nomeComum` | `nome` |
| Pragas | `nomeCientifico` | `nomeLatino` |
| Fitossanitarios | `idReg` | `idDefensivo` |
| Fitossanitarios | `nomeComum` | `nome` |

## ⚙️ Comportamento

### Transação Segura
Todo o carregamento é feito em uma única transação. Se qualquer erro ocorrer, todas as mudanças são revertidas.

### Insert Mode
Usa `InsertMode.insertOrIgnore`, o que significa:
- Se o registro já existe (baseado em `unique` constraints), ele é ignorado
- Não haverá duplicatas
- É seguro rodar múltiplas vezes

### Foreign Keys
As tabelas de informações (PragasInf, FitossanitáriosInfo) fazem lookup das chaves estrangeiras antes de inserir:
- PragasInf busca o `pragaId` baseado no `idPraga`
- FitossanitáriosInfo busca o `defensivoId` baseado no `idDefensivo`

### Logging
Todos os logs são feitos com `dart:developer` e podem ser visualizados:
- No DevTools
- No console durante desenvolvimento
- Filtrados por `name: 'StaticDataLoader'`

## 🐛 Troubleshooting

### Dados não aparecem no banco
1. Verifique se os arquivos JSON existem nos paths corretos
2. Verifique os logs no console para ver se há erros
3. Confirme que o `pubspec.yaml` inclui os assets:
```yaml
flutter:
  assets:
    - assets/database/json/tbculturas/
    - assets/database/json/tbpragas/
    - assets/database/json/tbplantasinf/
    - assets/database/json/tbfitossanitarios/
    - assets/database/json/tbfitossanitariosinfo/
```

### Erros de Foreign Key
Se você ver erros de foreign key:
1. Certifique-se de que as pragas são carregadas antes das pragas info
2. Certifique-se de que os fitossanitários são carregados antes das fitossanitários info
3. Verifique se os `idReg` nos JSONs correspondem aos `idPraga`/`idDefensivo` corretos

### Performance
O carregamento inicial pode levar alguns segundos, especialmente para fitossanitários que têm muitos arquivos. Isso é normal e acontece apenas na primeira inicialização.

## 📝 Notas de Implementação

### Arquivos Opcionais
Os arquivos `TBFITOSSANITARIOSINFO_*.json` são opcionais. Se um arquivo não existir, ele é ignorado silenciosamente.

### Batch Operations
O loader não usa batch operations explícitas. Cada registro é inserido individualmente dentro de uma transação, o que é suficiente para a performance necessária.

### Incremental Loading
O loader sempre verifica se os dados já existem (usando `insertOrIgnore`). Isso permite:
- Rodar múltiplas vezes sem duplicar dados
- Adicionar novos dados sem afetar os existentes
- Atualizações incrementais (embora dados sejam tratados como estáticos)

## 🔮 Melhorias Futuras

- [ ] Adicionar validação de schema JSON
- [ ] Implementar versionamento de dados estáticos
- [ ] Adicionar suporte para atualização de dados
- [ ] Otimizar com batch inserts
- [ ] Adicionar progress callbacks
- [ ] Implementar cache de verificação de dados carregados

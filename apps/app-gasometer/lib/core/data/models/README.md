# Modelos de Dados Hive - GasOMeter

Este diretório contém os modelos de dados migrados do projeto antigo GasOMeter, seguindo o padrão SOLID e com numeração sequencial de TypeIDs.

## Estrutura dos Models

### BaseModel (Abstrato)
Classe base que fornece campos comuns para sincronização e versionamento:
- `id`: Identificador único
- `createdAt`: Data de criação (timestamp)
- `updatedAt`: Data de atualização (timestamp) 
- `isDeleted`: Flag de soft delete
- `needsSync`: Flag indicando necessidade de sincronização
- `lastSyncAt`: Último timestamp de sincronização
- `version`: Versão do registro

## Models Implementados

| Model | TypeId | Localização | Descrição |
|-------|--------|-------------|-----------|
| VehicleModel | 0 | `features/vehicles/data/models/` | Dados do veículo (marca, modelo, ano, placa, etc.) |
| FuelSupplyModel | 1 | `features/fuel/data/models/` | Registro de abastecimentos |
| OdometerModel | 2 | `features/odometer/data/models/` | Leituras do odômetro |
| ExpenseModel | 3 | `features/expenses/data/models/` | Despesas relacionadas ao veículo |
| MaintenanceModel | 4 | `features/maintenance/data/models/` | Registros de manutenção |
| CategoryModel | 5 | `core/data/models/` | Categorias para classificação |

## TypeIDs Sequenciais

Os TypeIDs começam do 0 e seguem ordem sequencial para melhor organização:

```dart
// Mapeamento dos TypeIDs
VehicleModel     -> 0
FuelSupplyModel  -> 1
OdometerModel    -> 2
ExpenseModel     -> 3
MaintenanceModel -> 4
CategoryModel    -> 5
```

## Propriedades Preservadas

### VehicleModel
- `marca`: Marca do veículo
- `modelo`: Modelo do veículo
- `ano`: Ano de fabricação
- `placa`: Placa do veículo
- `odometroInicial`: Odômetro inicial
- `combustivel`: Tipo de combustível
- `renavan`: Código RENAVAN
- `chassi`: Número do chassi
- `cor`: Cor do veículo
- `vendido`: Flag se foi vendido
- `valorVenda`: Valor de venda
- `odometroAtual`: Odômetro atual
- `foto`: URL/path da foto

### FuelSupplyModel
- `veiculoId`: ID do veículo
- `data`: Data do abastecimento
- `odometro`: Leitura do odômetro
- `litros`: Quantidade de litros
- `valorTotal`: Valor total pago
- `tanqueCheio`: Flag se encheu o tanque
- `precoPorLitro`: Preço por litro
- `posto`: Nome do posto
- `observacao`: Observações
- `tipoCombustivel`: Tipo de combustível

### OdometerModel
- `idVeiculo`: ID do veículo
- `data`: Data da leitura
- `odometro`: Valor do odômetro
- `descricao`: Descrição da leitura
- `tipoRegistro`: Tipo de registro

### ExpenseModel
- `veiculoId`: ID do veículo
- `tipo`: Tipo de despesa
- `descricao`: Descrição da despesa
- `valor`: Valor da despesa
- `data`: Data da despesa
- `odometro`: Odômetro na data

### MaintenanceModel
- `veiculoId`: ID do veículo
- `tipo`: Tipo de manutenção
- `descricao`: Descrição da manutenção
- `valor`: Valor da manutenção
- `data`: Data da manutenção
- `odometro`: Odômetro na data
- `proximaRevisao`: Próxima revisão
- `concluida`: Flag se foi concluída

### CategoryModel
- `categoria`: ID da categoria
- `descricao`: Descrição da categoria

## Métodos de Negócio Preservados

Todos os métodos de cálculo e validação foram mantidos:
- Cálculos de consumo de combustível
- Validações de dados
- Métodos de filtragem e ordenação
- Clones e comparações

## Uso dos Models

Ver exemplo completo em `examples/models_usage_example.dart`

```dart
// Criar um veículo
final vehicle = VehicleModel(
  marca: 'Toyota',
  modelo: 'Corolla', 
  ano: 2020,
  placa: 'ABC-1234',
  odometroInicial: 10000.0,
);

// Abrir box e salvar
final box = await Hive.openBox<VehicleModel>('vehicles');
await box.add(vehicle);
```

## Adapters Hive

Os adapters são automaticamente registrados no `main.dart`:

```dart
// Register Hive adapters
Hive.registerAdapter(VehicleModelAdapter());      // TypeId: 0
Hive.registerAdapter(FuelSupplyModelAdapter());   // TypeId: 1
Hive.registerAdapter(OdometerModelAdapter());     // TypeId: 2
Hive.registerAdapter(ExpenseModelAdapter());      // TypeId: 3
Hive.registerAdapter(MaintenanceModelAdapter());  // TypeId: 4
Hive.registerAdapter(CategoryModelAdapter());     // TypeId: 5
```
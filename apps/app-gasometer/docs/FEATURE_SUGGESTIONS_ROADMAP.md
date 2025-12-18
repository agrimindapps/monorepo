# 🚗 App Gasometer - Sugestões de Novas Features

> **Documento de Análise e Roadmap**  
> Gerado em: 18/12/2024  
> Versão: 1.0

---

## 📊 Análise das Features Atuais

### **Entidades Existentes**

| Entidade | Campos Principais | Status |
|----------|-------------------|--------|
| **Vehicle** | name, brand, model, year, color, licensePlate, type, supportedFuels, tankCapacity, engineSize, currentOdometer, averageConsumption | ✅ Completo |
| **FuelRecord** | vehicleId, fuelType, liters, pricePerLiter, totalPrice, odometer, date, gasStationName, gasStationBrand, latitude/longitude, fullTank, consumption | ✅ Completo |
| **Maintenance** | vehicleId, type, status, title, description, cost, serviceDate, odometer, workshopName, nextServiceDate, nextServiceOdometer, parts, photosPaths, invoicesPaths | ✅ Muito Completo |
| **Expense** | vehicleId, type, description, amount, date, odometer, receiptImagePath, location, notes | ✅ Completo |
| **Odometer** | Registros de quilometragem | ✅ Existe |

### **Tipos de Veículos Suportados**
- 🚗 Carro
- 🏍️ Moto
- 🚚 Caminhão
- 🚐 Van
- 🚌 Ônibus

### **Tipos de Combustível**
- ⛽ Gasolina
- 🌽 Etanol
- 🛢️ Diesel
- 💨 Gás (GNV)
- 🔋 Híbrido
- ⚡ Elétrico
- 🔄 Flex

### **Tipos de Manutenção**
- ✅ Preventiva
- 🔧 Corretiva
- 📋 Revisão
- 🚨 Emergencial

### **Tipos de Despesas**
- ⛽ Combustível
- 🔧 Manutenção
- 🛡️ Seguro
- 📄 IPVA
- 🅿️ Estacionamento
- 🚿 Lavagem
- ⚠️ Multa
- 🛣️ Pedágio
- 📋 Licenciamento
- 🎁 Acessórios
- 📁 Documentação
- 💰 Outro

### **Páginas/Telas Existentes**
- ✅ **Vehicles** - Lista e gerenciamento de veículos
- ✅ **Fuel** - Registro de abastecimentos
- ✅ **Maintenance** - Gerenciamento de manutenções
- ✅ **Expenses** - Controle de despesas
- ✅ **Odometer** - Registro de quilometragem
- ✅ **Reports** - Relatórios e estatísticas
- ✅ **Profile** - Perfil do usuário
- ✅ **Premium** - Assinatura premium
- ✅ **Settings** - Configurações
- ✅ **Data Export** - Exportação de dados

---

## 🚀 Sugestões de Novas Features

### **Categoria 1: Análise Inteligente e Insights** 📈

#### 1.1 **Previsão de Gastos Mensais (ML)**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰💰 Premium

**Descrição:**
- Análise preditiva de gastos baseada no histórico
- Projeção de custos para os próximos meses
- Alertas quando gastos estão acima da média
- Identificação de padrões de consumo anormais

**Benefícios:**
- Planejamento financeiro do veículo
- Identificação precoce de problemas (consumo alto = problema mecânico?)
- Diferencial competitivo forte

**Nova Entidade:**
```dart
class ExpenseForecast {
  final String vehicleId;
  final DateTime month;
  final double predictedFuelCost;
  final double predictedMaintenanceCost;
  final double predictedOtherExpenses;
  final double totalPredicted;
  final double confidenceLevel; // 0.0 a 1.0
  final List<String> insights; // "Gastos 15% acima da média"
}
```

---

#### 1.2 **Comparador de Postos de Combustível**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium / Afiliados

**Descrição:**
- Ranking de postos mais baratos baseado no histórico do usuário
- Mapa com postos próximos e preços registrados pela comunidade
- Economia estimada ao escolher posto mais barato
- Histórico de preços por posto

**Benefícios:**
- Economia real para o usuário
- Dados crowdsourced da comunidade
- Engajamento e fidelização

**Nova Entidade:**
```dart
class GasStation {
  final String id;
  final String name;
  final String brand; // Shell, Ipiranga, BR, etc.
  final double latitude;
  final double longitude;
  final String address;
  final Map<FuelType, double> currentPrices;
  final DateTime lastPriceUpdate;
  final double averageRating;
  final int totalReviews;
}
```

---

#### 1.3 **Análise de Consumo por Rota/Período**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Identificar consumo em cidade vs estrada
- Análise por período (verão/inverno, com/sem ar-condicionado)
- Identificar rotas mais econômicas
- Comparação entre diferentes veículos do usuário

**Insights Gerados:**
- "Seu consumo na estrada é 30% melhor que na cidade"
- "Nos últimos 3 meses, seu consumo aumentou 15%"
- "Veículo X é 20% mais econômico que veículo Y"

---

#### 1.4 **Score de Eficiência do Veículo**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free (engajamento)

**Descrição:**
- Pontuação geral de 0-100 baseada em:
  - Consumo de combustível vs média do modelo
  - Manutenções em dia
  - Custos totais vs benchmark
- Dicas para melhorar o score
- Comparação com outros usuários do mesmo veículo (anônimo)

---

### **Categoria 2: Lembretes e Automação** ⏰

#### 2.1 **Lembretes Inteligentes de Manutenção**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Lembretes automáticos baseados em:
  - Quilometragem (próxima troca de óleo em 1.000 km)
  - Tempo (revisão em 30 dias)
  - Padrões de uso (você roda 2.000 km/mês, próxima manutenção em ~15 dias)
- Push notifications inteligentes
- Integração com calendário do celular

**Tipos de Lembretes:**
```dart
enum ReminderType {
  oilChange('Troca de Óleo', 5000, 180), // 5000km ou 6 meses
  tireRotation('Rodízio de Pneus', 10000, 365),
  brakeInspection('Inspeção de Freios', 20000, 365),
  airFilter('Filtro de Ar', 15000, 365),
  cabinFilter('Filtro de Cabine', 15000, 365),
  sparkPlugs('Velas de Ignição', 30000, null),
  timingBelt('Correia Dentada', 60000, null),
  coolant('Fluido de Arrefecimento', 40000, 730),
  transmissionFluid('Fluido de Transmissão', 60000, null),
  batteryCheck('Verificação da Bateria', null, 365),
  alignment('Alinhamento', 10000, 365),
  balancing('Balanceamento', 10000, 365),
  insurance('Seguro', null, 365),
  ipva('IPVA', null, 365),
  licensing('Licenciamento', null, 365),
  inspection('Inspeção Veicular', null, 365);

  const ReminderType(this.name, this.kmInterval, this.daysInterval);
  final String name;
  final int? kmInterval;
  final int? daysInterval;
}
```

---

#### 2.2 **Alertas de Documentação**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Alerta de vencimento de CNH
- Alerta de vencimento de seguro
- Alerta de IPVA/DPVAT
- Alerta de licenciamento
- Alerta de inspeção veicular (onde aplicável)

**Nova Entidade:**
```dart
class VehicleDocument {
  final String id;
  final String vehicleId;
  final DocumentType type;
  final DateTime expirationDate;
  final String? documentNumber;
  final String? imagePath;
  final double? cost;
  final bool isRenewed;
}

enum DocumentType {
  cnh, // Carteira de Motorista
  crlv, // Certificado de Registro
  seguro,
  ipva,
  dpvat,
  inspecao,
  other;
}
```

---

#### 2.3 **Modo Viagem**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Registrar início e fim de viagens longas
- Cálculo automático de:
  - Quilometragem total da viagem
  - Consumo médio durante a viagem
  - Custo total (combustível + pedágios)
  - Tempo total de viagem
- Relatório de viagem para reembolso empresarial
- Compartilhamento de relatório em PDF

**Nova Entidade:**
```dart
class TripRecord {
  final String id;
  final String vehicleId;
  final String name; // "Viagem SP-RJ"
  final DateTime startDate;
  final DateTime? endDate;
  final double startOdometer;
  final double? endOdometer;
  final List<String> fuelRecordIds;
  final List<String> expenseIds;
  final double totalDistance;
  final double totalFuelCost;
  final double totalTollCost;
  final double totalOtherExpenses;
  final double averageConsumption;
  final String? notes;
  final TripStatus status;
}
```

---

### **Categoria 3: Gamificação e Engajamento** 🎮

#### 3.1 **Sistema de Conquistas**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free (aumenta retenção)

**Descrição:**
- Conquistas por marcos e comportamentos
- Badges colecionáveis
- Níveis de experiência
- Streak de registros diários

**Conquistas Sugeridas:**
```dart
enum Achievement {
  // Registros
  firstFuelRecord('Primeiro Abastecimento', 'Registrou seu primeiro abastecimento'),
  fuelMaster100('Controlador de Combustível', 'Registrou 100 abastecimentos'),
  fuelMaster500('Mestre do Combustível', 'Registrou 500 abastecimentos'),
  
  // Economia
  economyKing('Rei da Economia', 'Consumo médio 20% melhor que a média'),
  smartFueler('Abastecedor Inteligente', 'Sempre abastece tanque cheio'),
  priceHunter('Caçador de Preços', 'Economia de R$500 escolhendo postos baratos'),
  
  // Manutenção
  maintenanceGuru('Guru da Manutenção', 'Todas manutenções em dia por 1 ano'),
  preventiveMaster('Mestre Preventivo', 'Realizou 10 manutenções preventivas'),
  
  // Documentação
  documentOrganizer('Organizador', 'Todos documentos cadastrados e em dia'),
  
  // Streaks
  streak7('Semana Dedicada', '7 dias seguidos registrando'),
  streak30('Mês Completo', '30 dias seguidos registrando'),
  streak100('Motorista Dedicado', '100 dias seguidos registrando'),
  
  // Veículos
  fleetManager('Gerente de Frota', 'Gerencia 5+ veículos'),
  multiVehicle('Multi-Veículos', 'Cadastrou 3+ veículos'),
  
  // Especiais
  roadTripper('Viajante', 'Completou viagem de +500km'),
  longHauler('Estradeiro', 'Completou viagem de +1000km'),
  earlyAdopter('Pioneiro', 'Usuário desde o lançamento'),
}
```

---

#### 3.2 **Ranking de Economia**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free

**Descrição:**
- Comparação anônima com outros usuários do mesmo modelo
- "Seu consumo está no top 20% dos Honda Civic 2020"
- Dicas personalizadas para melhorar
- Ranking regional (cidade/estado)

---

### **Categoria 4: Compartilhamento e Comunidade** 👥

#### 4.1 **Compartilhamento de Preços de Combustível**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰 Premium (sem anúncios) / 💰 Free com anúncios

**Descrição:**
- Ao registrar abastecimento, contribuir com preço do posto
- Ver preços reportados por outros usuários
- Mapa colaborativo de preços
- Alertas de preços baixos na região

**Nota:** Similar ao Waze, mas focado em combustível.

---

#### 4.2 **Exportação para Empresas (Reembolso)**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰💰💰 Premium Business

**Descrição:**
- Relatórios formatados para reembolso empresarial
- Exportação em PDF/Excel profissional
- Filtro por período/categoria
- Comprovantes anexados automaticamente
- QR Code para validação

---

#### 4.3 **Perfil de Veículo Compartilhável**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- "Card" bonito do veículo para compartilhar
- Estatísticas resumidas
- Útil para venda (histórico comprovado)
- Certificado de manutenções em dia

---

### **Categoria 5: Integrações e Automação** 🔌

#### 5.1 **Integração com OBD-II (Bluetooth)**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧🔧🔧 ALTA  
**Monetização:** 💰💰💰 Premium Plus

**Descrição:**
- Leitura automática de quilometragem
- Consumo em tempo real
- Códigos de erro do veículo
- Alertas de problemas mecânicos

**Dispositivos Compatíveis:**
- ELM327 (genérico)
- OBDLink
- Carista
- BlueDriver

**Nota:** Feature avançada para versão futura.

---

#### 5.2 **Integração com Google/Apple Maps**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free

**Descrição:**
- Abrir navegação até posto mais barato
- Calcular custo de viagem antes de sair
- Sugerir paradas para abastecimento em viagens longas

---

#### 5.3 **Integração com Assistentes de Voz**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- "Ok Google, registrar abastecimento"
- "Siri, quanto gastei de combustível este mês?"
- "Alexa, qual o consumo médio do meu carro?"

---

### **Categoria 6: Veículos Elétricos e Híbridos** ⚡

#### 6.1 **Suporte Completo a Veículos Elétricos**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Registro de recargas (kWh em vez de litros)
- Consumo em kWh/100km ou km/kWh
- Mapa de eletropostos
- Custo por kWh
- Comparação custo elétrico vs combustível

**Nova Entidade:**
```dart
class ChargingRecord extends BaseSyncEntity {
  final String vehicleId;
  final double kWh;
  final double pricePerKWh;
  final double totalPrice;
  final double odometer;
  final DateTime date;
  final String? chargingStationName;
  final String? chargingStationNetwork; // Tesla, Eletrify, etc.
  final ChargingType type; // slow, fast, supercharger
  final int chargingTimeMinutes;
  final double? batteryPercentStart;
  final double? batteryPercentEnd;
}
```

---

#### 6.2 **Dashboard de Veículos Híbridos**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Split de uso elétrico vs combustível
- Economia estimada do modo elétrico
- Análise de quando vale usar cada modo

---

### **Categoria 7: Recursos Avançados** 🔧

#### 7.1 **Histórico de Preços por Região**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Gráfico de evolução de preços do combustível
- Por região (cidade/estado)
- Previsão de tendência
- Alerta "Preço baixo, hora de abastecer!"

---

#### 7.2 **Custo por Quilômetro Detalhado**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Custo total por km rodado incluindo:
  - Combustível
  - Manutenção
  - Seguro (diluído)
  - IPVA (diluído)
  - Depreciação estimada
- Comparação mês a mês
- Útil para decisão de troca de veículo

---

#### 7.3 **Calculadora de Etanol vs Gasolina**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Calculadora clássica (70% ou 75%)
- Personalizada baseada no histórico real do veículo
- "No seu carro, etanol vale a pena quando custa até 73% da gasolina"
- Recomendação automática ao registrar abastecimento

---

#### 7.4 **Simulador de Troca de Veículo**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰💰 Premium

**Descrição:**
- "Se trocar por um carro flex, economizaria R$ X/mês"
- "Se trocar por elétrico, economizaria R$ X/mês"
- Baseado nos dados reais de uso
- Tempo de payback do investimento

---

## 📋 Roadmap Sugerido

### **Fase 1 - Quick Wins (1-2 meses)**
Foco: Features de baixa complexidade com alto impacto

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Calculadora Etanol vs Gasolina | ⭐⭐⭐⭐⭐ | 🔧 | Alto |
| Alertas de Documentação | ⭐⭐⭐⭐⭐ | 🔧 | Alto |
| Custo por Quilômetro Detalhado | ⭐⭐⭐⭐⭐ | 🔧 | Alto |
| Score de Eficiência | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Exportação para Reembolso | ⭐⭐⭐⭐ | 🔧 | Alto |

### **Fase 2 - Engajamento (2-3 meses)**
Foco: Aumentar retenção e uso diário

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Sistema de Conquistas | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Lembretes Inteligentes | ⭐⭐⭐⭐⭐ | 🔧🔧 | Muito Alto |
| Modo Viagem | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Análise de Consumo | ⭐⭐⭐⭐ | 🔧🔧 | Alto |

### **Fase 3 - Diferenciação (3-4 meses)**
Foco: Features premium e diferenciação competitiva

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Comparador de Postos | ⭐⭐⭐⭐⭐ | 🔧🔧 | Muito Alto |
| Previsão de Gastos (ML) | ⭐⭐⭐⭐⭐ | 🔧🔧🔧 | Muito Alto |
| Histórico de Preços | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Suporte a Elétricos | ⭐⭐⭐⭐ | 🔧🔧🔧 | Alto (futuro) |

### **Fase 4 - Avançado (6+ meses)**
Foco: Features de longo prazo

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Integração OBD-II | ⭐⭐⭐ | 🔧🔧🔧🔧 | Alto (nicho) |
| Comunidade de Preços | ⭐⭐⭐⭐ | 🔧🔧🔧 | Muito Alto |
| Assistentes de Voz | ⭐⭐⭐ | 🔧🔧🔧 | Médio |
| Simulador de Troca | ⭐⭐⭐ | 🔧🔧🔧 | Médio |

---

## 🎯 Recomendação de Priorização

### **Top 5 Features para Implementar Primeiro:**

1. **🥇 Lembretes Inteligentes de Manutenção** - Valor prático enorme, diferencial forte
2. **🥈 Calculadora Etanol vs Gasolina Personalizada** - Quick win, todo brasileiro precisa
3. **🥉 Sistema de Conquistas** - Aumenta retenção drasticamente
4. **4️⃣ Comparador de Postos** - Killer feature, economia real
5. **5️⃣ Modo Viagem** - Muito útil para quem viaja a trabalho/lazer

### **Features "Low-Hanging Fruit" (Implementação Rápida):**
- ✅ Calculadora Etanol vs Gasolina
- ✅ Alertas de Documentação (CNH, IPVA, Seguro)
- ✅ Custo por Quilômetro Detalhado
- ✅ Score de Eficiência Básico
- ✅ Exportação PDF para Reembolso

---

## 📊 Análise de Impacto no Modelo de Negócio

| Feature | Impacto Free | Impacto Premium | Retenção | Aquisição |
|---------|--------------|-----------------|----------|-----------|
| Lembretes Inteligentes | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Comparador de Postos | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Conquistas | ⭐⭐⭐⭐⭐ | - | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Previsão ML | - | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Modo Viagem | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Elétricos | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🔧 Considerações Técnicas

### **APIs Externas Recomendadas:**

| API | Uso | Custo |
|-----|-----|-------|
| **Google Places** | Busca de postos | Pay per use |
| **OpenStreetMap** | Mapa gratuito | Gratuito |
| **ANP** | Preços oficiais de combustível | Gratuito (scraping) |
| **FIPE** | Tabela de veículos/preços | Gratuito/Pago |
| **ViaCEP** | Endereços | Gratuito |

### **Estrutura de Novas Features:**

Seguir padrão Clean Architecture existente:
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── providers/
    └── widgets/
```

### **Considerações de Performance:**

- **Cache Local:** Preços de combustível com TTL de 24h
- **Background Sync:** Sincronizar lembretes e alertas
- **Push Notifications:** FCM para alertas de vencimento
- **Offline First:** Todas features devem funcionar offline

---

## ✅ Próximos Passos

1. **Validar priorização** com stakeholders
2. **Estimar esforço detalhado** das features selecionadas
3. **Criar issues/cards** para cada feature aprovada
4. **Definir métricas de sucesso** para cada feature
5. **Iniciar implementação** da Fase 1

---

## 🏆 Diferencial Competitivo vs Concorrentes

| Feature | Gasometer | Fuelio | aCar | Drivvo |
|---------|-----------|--------|------|--------|
| Registro Básico | ✅ | ✅ | ✅ | ✅ |
| Multi-veículos | ✅ | ✅ | ✅ | ✅ |
| Manutenções | ✅ | ✅ | ✅ | ✅ |
| Lembretes Inteligentes | 🎯 | ⚠️ | ❌ | ⚠️ |
| Comparador Postos | 🎯 | ❌ | ❌ | ❌ |
| Previsão ML | 🎯 | ❌ | ❌ | ❌ |
| Modo Viagem | 🎯 | ⚠️ | ❌ | ⚠️ |
| Conquistas | 🎯 | ❌ | ❌ | ❌ |
| Elétricos/Híbridos | 🎯 | ⚠️ | ⚠️ | ⚠️ |
| Sync Cloud | ✅ | ⚠️ | ⚠️ | ✅ |

**🎯 = Oportunidade de Diferenciação**  
**✅ = Disponível**  
**⚠️ = Parcial/Básico**  
**❌ = Não disponível**

---

*Documento gerado para análise e discussão. Prioridades podem ser ajustadas baseado em feedback de usuários e métricas do app.*

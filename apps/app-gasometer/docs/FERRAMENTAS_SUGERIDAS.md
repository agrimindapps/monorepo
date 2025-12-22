# 🛠️ Ferramentas Sugeridas - App Gasometer

> **Documento de Planejamento**: Catálogo de ferramentas utilitárias para implementação futura no hub de Ferramentas do app-gasometer.
>
> **Data**: Dezembro 2024
> **Status**: Planejamento

---

## 📋 Índice

1. [Calculadoras & Análise](#calculadoras--análise)
2. [Planejamento & Lembretes](#planejamento--lembretes)
3. [Localização & Navegação](#localização--navegação)
4. [Exportação & Compartilhamento](#exportação--compartilhamento)
5. [Educativas & Informativas](#educativas--informativas)
6. [Manutenção & Diagnóstico](#manutenção--diagnóstico)
7. [Análise Avançada](#análise-avançada)
8. [Sustentabilidade](#sustentabilidade)
9. [Gamificação](#gamificação)
10. [Priorização & Roadmap](#priorização--roadmap)

---

## 📊 Calculadoras & Análise

### 1. 💰 Calculadora de Custo por Km

**Descrição**: Calcula o custo real por quilômetro rodado.

**Inputs**:
- Valor gasto (R$)
- Km inicial
- Km final

**Outputs**:
- R$/km
- Comparação com média brasileira (R$ 0,50 - R$ 1,20/km)
- Classificação (econômico, médio, alto)

**Extras**:
- Gráfico de evolução mensal do custo/km
- Comparação entre veículos (se houver mais de um)
- Filtro por tipo de despesa (combustível, manutenção, total)

**Complexidade**: 🟢 Baixa (2-3 horas)

**Prioridade**: 🔥 Alta

---

### 2. 🔋 Calculadora de Autonomia

**Descrição**: Calcula quantos km o veículo ainda pode rodar com o combustível atual.

**Inputs**:
- Capacidade do tanque (L)
- Consumo médio (km/L) - puxado do histórico
- Nível atual do tanque (% ou L)

**Outputs**:
- Autonomia total (km)
- Km que ainda pode rodar
- Alerta se autonomia < 50km

**Extras**:
- Postos no raio de autonomia (integração com mapa)
- Histórico de autonomia média
- Sugestão de quando abastecer

**Complexidade**: 🟢 Baixa (2 horas)

**Prioridade**: 🔥 Alta

---

### 3. 📈 Simulador de Economia

**Descrição**: Simula quanto o usuário economizaria melhorando o consumo.

**Inputs**:
- Consumo atual (km/L)
- Meta de consumo (km/L)
- Km rodados por mês

**Outputs**:
- Economia mensal (R$)
- Economia anual (R$)
- Litros economizados
- Equivalência ("X abastecimentos a menos")

**Extras**:
- Dicas personalizadas para melhorar consumo
- Comparação com veículos similares
- Gráfico de projeção

**Complexidade**: 🟡 Média (3-4 horas)

**Prioridade**: 🟡 Média

---

### 4. 🚗 Calculadora de Depreciação

**Descrição**: Estima o valor atual do veículo baseado em depreciação.

**Inputs**:
- Valor de compra (R$)
- Ano do veículo
- Km rodados
- Estado de conservação (opcional)

**Outputs**:
- Valor estimado atual (R$)
- Taxa de depreciação (% ao ano)
- Perda total (R$)

**Extras**:
- Projeção de valor futuro (1, 2, 5 anos)
- Comparação com tabela FIPE (API)
- Gráfico de depreciação

**Complexidade**: 🟡 Média (4-5 horas)

**Prioridade**: 🟡 Média

---

### 5. 💸 Comparador de Custos (Carro vs Transporte Público)

**Descrição**: Compara custo mensal do carro com alternativas de transporte.

**Inputs**:
- Km mensal
- Custos fixos (IPVA, seguro, estacionamento)
- Custo de transporte público da região

**Outputs**:
- Custo mensal total do carro
- Custo equivalente em transporte público
- Custo de Uber/táxi
- Análise de viabilidade

**Extras**:
- Gráfico comparativo
- Sugestões de economia
- Cálculo break-even (quando compensa ter carro)

**Complexidade**: 🟡 Média (4 horas)

**Prioridade**: 🔵 Baixa

---

## ⏰ Planejamento & Lembretes

### 6. 📅 Planejador de Manutenção

**Descrição**: Agenda e acompanha manutenções preventivas do veículo.

**Features**:
- Cadastro de manutenções recorrentes (óleo, filtros, pneus, etc.)
- Cronograma baseado em km ou tempo
- Próximas manutenções previstas
- Checklist de itens a verificar
- Notificações de alerta

**Tipos de Manutenção**:
- Troca de óleo (a cada 10.000 km ou 6 meses)
- Filtro de ar (15.000 km)
- Filtro de combustível (20.000 km)
- Velas (30.000 km)
- Correia dentada (60.000 km)
- Alinhamento e balanceamento (10.000 km)
- Rodízio de pneus (10.000 km)

**Complexidade**: 🟡 Média (5-6 horas)

**Prioridade**: 🔥 Alta

---

### 7. 🔔 Lembretes Inteligentes

**Descrição**: Sistema de notificações para prazos e vencimentos importantes.

**Tipos de Lembretes**:
- **IPVA**: Alerta 30, 15 e 7 dias antes
- **Licenciamento**: Renovação anual
- **Seguro**: 30 dias antes do vencimento
- **Revisões**: Baseado em km rodados
- **Rodízio**: Se aplicável (SP, RJ, etc.)
- **Inspeção Veicular**: Onde obrigatório

**Features**:
- Configuração de antecedência do alerta
- Push notifications
- Integração com calendário
- Histórico de lembretes

**Complexidade**: 🟡 Média (4-5 horas)

**Prioridade**: 🔥 Alta

---

### 8. 📊 Histórico de Revisões Programadas

**Descrição**: Timeline de manutenções recomendadas pelo fabricante.

**Features**:
- Lista de revisões do manual do veículo
- Marcar como "concluído" quando feito
- Previsão de custo baseado em histórico
- Itens incluídos em cada revisão
- Comparação: revisão oficial vs independente

**Extras**:
- Upload do manual do veículo
- Busca por marca/modelo (database)
- Lembrete automático ao atingir km

**Complexidade**: 🔴 Alta (6-8 horas)

**Prioridade**: 🟡 Média

---

## 🗺️ Localização & Navegação

### 9. ⛽ Pesquisar Postos Próximos

**Descrição**: Localiza postos de combustível ao redor da localização atual.

**Features**:
- Mapa interativo com postos
- Filtro por bandeira (Petrobras, Shell, Ipiranga, etc.)
- Ordenar por distância
- Ordenar por preço (se API disponível)
- Navegação via Google Maps/Waze

**APIs Necessárias**:
- Google Maps API / Mapbox
- API de preços (ex: ANP, Preço da Hora)

**Complexidade**: 🟡 Média (5-6 horas)

**Prioridade**: 🔥 Alta

---

### 10. 🔧 Oficinas Próximas

**Descrição**: Mapa de oficinas mecânicas e serviços automotivos.

**Features**:
- Mapa com oficinas ao redor
- Filtro por especialidade (mecânica, elétrica, funilaria, alinhamento)
- Avaliações (Google Places)
- Contato direto (WhatsApp/Telefone)
- Horário de funcionamento

**Extras**:
- Histórico de oficinas já utilizadas
- Favoritos
- Notas pessoais sobre cada oficina

**Complexidade**: 🟡 Média (4-5 horas)

**Prioridade**: 🟡 Média

---

### 11. 🅿️ Estacionamentos Próximos

**Descrição**: Localiza estacionamentos na região.

**Features**:
- Mapa de estacionamentos
- Preços (se API disponível)
- Vagas disponíveis (integração com apps)
- Navegação

**APIs Necessárias**:
- Google Maps API
- APIs de estacionamentos (ParkMe, SpotHero, etc.)

**Complexidade**: 🟡 Média (4 horas)

**Prioridade**: 🔵 Baixa

---

## 📥 Exportação & Compartilhamento

### 12. 📄 Exportar Relatório PDF

**Descrição**: Gera relatório completo em PDF com todos os dados do período.

**Conteúdo do PDF**:
- Resumo executivo (totais, médias)
- Gráficos (consumo, gastos, km rodados)
- Timeline de abastecimentos
- Timeline de manutenções
- Análise de custos
- Estatísticas comparativas

**Configurações**:
- Período (mensal, trimestral, anual, personalizado)
- Filtro por veículo
- Seções incluídas/excluídas

**Uso Prático**:
- Imposto de Renda (IR)
- Prestação de contas (empresas)
- Controle pessoal

**Complexidade**: 🟡 Média (5-6 horas)

**Prioridade**: 🔥 Alta

---

### 13. 📊 Exportar Excel/CSV

**Descrição**: Exporta dados brutos em planilha editável.

**Features**:
- Todos os registros em formato tabular
- Filtros personalizáveis (período, veículo, tipo)
- Múltiplas abas (abastecimentos, manutenções, despesas)
- Headers descritivos

**Formatos**:
- Excel (.xlsx)
- CSV (.csv)
- Google Sheets (compartilhamento direto)

**Complexidade**: 🟢 Baixa (3 horas)

**Prioridade**: 🟡 Média

---

### 14. 📲 Compartilhar Resumo

**Descrição**: Gera card visual com estatísticas para compartilhar.

**Features**:
- Card bonito com:
  - Consumo médio (km/L)
  - Km rodados no mês
  - Economia vs mês anterior
  - Badge de performance
- Compartilhar em redes sociais
- Comparar com amigos ("Desafio de economia")

**Extras**:
- Tema personalizável
- Marca d'água do app
- Link para download

**Complexidade**: 🟡 Média (4 horas)

**Prioridade**: 🔵 Baixa

---

## 🎓 Educativas & Informativas

### 15. 📚 Guia de Manutenção Preventiva

**Descrição**: Biblioteca de conhecimento sobre manutenção automotiva.

**Conteúdo**:
- Checklist de verificações mensais
- O que checar antes de viagens
- Dicas de economia de combustível
- Sinais de problemas comuns
- Quando trocar cada componente

**Formato**:
- Cards informativos
- Busca por palavra-chave
- Favoritos
- Vídeos explicativos (links YouTube)

**Complexidade**: 🟡 Média (4-5 horas)

**Prioridade**: 🟡 Média

---

### 16. 🔍 Decodificador de Luz do Painel

**Descrição**: Explica o significado das luzes/símbolos do painel do veículo.

**Features**:
- Catálogo visual de símbolos
- Busca por ícone (visual matching)
- Explicação do problema
- Urgência (pode dirigir ou parar imediatamente)
- Solução sugerida

**Database**:
- Símbolos universais (ISO)
- Símbolos por marca/modelo

**Extras**:
- Upload de foto do painel (IA identifica)
- Histórico de alertas

**Complexidade**: 🟡 Média (5-6 horas)

**Prioridade**: 🟡 Média

---

### 17. 📖 Glossário Automotivo

**Descrição**: Dicionário de termos técnicos automotivos.

**Conteúdo**:
- Termos técnicos explicados em linguagem simples
- Exemplos: "cambagem", "catalisador", "injeção eletrônica"
- Busca por palavra-chave
- Categorias (motor, suspensão, freios, etc.)

**Extras**:
- Imagens ilustrativas
- Links para vídeos explicativos

**Complexidade**: 🟢 Baixa (3 horas de conteúdo)

**Prioridade**: 🔵 Baixa

---

### 18. 💡 Dicas de Economia

**Descrição**: Coleção de dicas práticas para economizar combustível.

**Categorias**:
- Dicas de condução (acelerar suavemente, manter velocidade constante)
- Manutenção preventiva (filtros, velas, pneus)
- Otimização de uso (rotas, horários, ar-condicionado)
- Preparação do veículo (peso, calibragem, aerodinâmica)

**Formato**:
- Cards com dicas curtas
- Impacto estimado (% de economia)
- Favoritar dicas

**Complexidade**: 🟢 Baixa (2-3 horas)

**Prioridade**: 🟡 Média

---

## 🔧 Manutenção & Diagnóstico

### 19. 🛠️ Verificador de Recall

**Descrição**: Verifica se há recalls ativos para o veículo do usuário.

**Inputs**:
- Marca, modelo, ano
- Chassi (opcional, mais preciso)

**Outputs**:
- Lista de recalls ativos
- Descrição do problema
- Risco (baixo, médio, alto)
- Link para agendamento na concessionária

**APIs Necessárias**:
- API de recalls (Denatran, sites de fabricantes)

**Complexidade**: 🟡 Média (4-5 horas)

**Prioridade**: 🟡 Média

---

### 20. 🔋 Calculadora de Vida Útil da Bateria

**Descrição**: Estima quando a bateria do veículo precisará ser trocada.

**Inputs**:
- Data da última troca
- Tipo de bateria
- Clima da região (frio/quente degrada mais rápido)
- Uso (urbano/rodoviário)

**Outputs**:
- Vida útil restante (meses)
- Alerta quando próximo do fim (< 3 meses)
- Sinais de bateria fraca

**Extras**:
- Dicas para prolongar vida útil
- Lembrete de verificação

**Complexidade**: 🟢 Baixa (2 horas)

**Prioridade**: 🟡 Média

---

### 21. 🛞 Calculadora de Pressão dos Pneus

**Descrição**: Calcula a pressão ideal dos pneus baseado em condições de uso.

**Inputs**:
- Tipo de pneu
- Carga do veículo (vazio, cheio, com bagagem)
- Tipo de uso (cidade, estrada)

**Outputs**:
- Pressão ideal dianteira (PSI/Bar)
- Pressão ideal traseira (PSI/Bar)
- Ajuste para viagens longas

**Extras**:
- Referência do manual do veículo
- Efeitos de pressão incorreta

**Complexidade**: 🟢 Baixa (2 horas)

**Prioridade**: 🟡 Média

---

### 22. 🌡️ Conversor de Unidades Automotivas

**Descrição**: Converte entre diferentes unidades usadas em automóveis.

**Conversões**:
- **Pressão**: PSI ↔ Bar ↔ kPa
- **Consumo**: MPG ↔ Km/L ↔ L/100km
- **Potência**: HP ↔ CV ↔ kW
- **Volume**: Litros ↔ Galões (US/UK)
- **Torque**: Nm ↔ kgfm ↔ lb-ft
- **Velocidade**: Km/h ↔ MPH

**Complexidade**: 🟢 Baixa (2 horas)

**Prioridade**: 🟢 Baixa

---

## 📊 Análise Avançada

### 23. 📈 Análise de Padrões de Uso

**Descrição**: Identifica padrões e insights sobre o uso do veículo.

**Análises**:
- Dias/horários que mais abastece
- Postos mais frequentados
- Média de km rodados por dia/semana/mês
- Sazonalidade (meses com mais/menos uso)
- Correlação consumo x tipo de percurso

**Outputs**:
- Dashboard visual
- Insights automáticos ("Você abastece 60% no posto X")
- Sugestões de otimização

**Complexidade**: 🔴 Alta (6-8 horas)

**Prioridade**: 🔵 Baixa

---

### 24. 💰 Previsão de Gastos

**Descrição**: Prevê gastos futuros baseado em histórico.

**Features**:
- Projeção mensal/anual
- Baseado em tendências
- Alertas de gastos acima da média
- Budget mensal configurável

**Machine Learning**:
- Modelo de previsão simples (média móvel)
- Considera sazonalidade
- Ajusta com tempo

**Complexidade**: 🔴 Alta (8-10 horas)

**Prioridade**: 🔵 Baixa

---

### 25. 🏆 Ranking de Economia

**Descrição**: Compara performance do veículo com médias e outros usuários.

**Features**:
- Comparação com média de veículos similares (mesmo modelo/ano)
- Badge de economia (bronze, prata, ouro, platina)
- Percentil (top 10%, top 25%, etc.)
- Dicas personalizadas baseado em performance

**Extras**:
- Ranking anônimo entre amigos
- Desafios de melhoria

**Complexidade**: 🔴 Alta (6-8 horas) + backend

**Prioridade**: 🔵 Baixa

---

## 🌍 Sustentabilidade

### 26. 🌱 Calculadora de CO₂

**Descrição**: Calcula emissões de CO₂ baseado no uso do veículo.

**Inputs**:
- Km rodados
- Tipo de combustível
- Consumo médio

**Outputs**:
- Total de CO₂ emitido (kg)
- Comparação com transporte público
- Equivalência (ex: "X árvores necessárias para compensar")
- Pegada de carbono mensal/anual

**Extras**:
- Dicas para reduzir emissões
- Opções de compensação (reflorestamento)

**Complexidade**: 🟡 Média (4 horas)

**Prioridade**: 🔵 Baixa

---

### 27. 🚴 Alternativas de Transporte

**Descrição**: Sugere alternativas de transporte mais sustentáveis.

**Features**:
- Rotas de bike (integração Google Maps)
- Cálculo de economia usando transporte alternativo
- Integração com apps de mobilidade (Uber, 99, bike/patinete compartilhado)
- Comparação ambiental

**Complexidade**: 🟡 Média (5 horas)

**Prioridade**: 🔵 Baixa

---

## 🎮 Gamificação

### 28. 🏅 Desafios de Economia

**Descrição**: Sistema de desafios para engajar usuários.

**Exemplos de Desafios**:
- "Rode 100km com menos de R$50"
- "Melhore seu consumo em 10% este mês"
- "Faça 5 abastecimentos sem ultrapassar X km/L"
- "Mantenha seu carro sem manutenção corretiva por 3 meses"

**Features**:
- Badges e conquistas
- Pontuação
- Ranking entre amigos
- Recompensas (descontos em parceiros)

**Complexidade**: 🔴 Alta (8-10 horas) + backend

**Prioridade**: 🔵 Baixa

---

### 29. 📊 Dashboard de Performance

**Descrição**: Score geral de performance do veículo.

**Métricas do Score (0-100)**:
- Economia (30%): consumo vs esperado
- Manutenção (30%): preventiva em dia
- Uso (20%): otimização de rotas/horários
- Sustentabilidade (20%): emissões

**Features**:
- Score visual (medidor)
- Histórico de evolução
- Sugestões específicas para melhorar score
- Comparação com mês anterior

**Complexidade**: 🔴 Alta (6-8 horas)

**Prioridade**: 🔵 Baixa

---

## 🎯 Priorização & Roadmap

### Critérios de Priorização

1. **Valor para o usuário** (Alto/Médio/Baixo)
2. **Complexidade de implementação** (Baixa/Média/Alta)
3. **Dependências externas** (APIs, serviços)
4. **Diferencial competitivo** (único no mercado?)

---

### 🔥 ALTA PRIORIDADE (Quick Wins)

Ferramentas com **alto valor** e **baixa/média complexidade**:

| # | Ferramenta | Valor | Complexidade | Tempo Estimado |
|---|-----------|-------|--------------|----------------|
| 1 | 💰 Calculadora de Custo/Km | 🔥 Alto | 🟢 Baixa | 2-3h |
| 2 | 🔋 Calculadora de Autonomia | 🔥 Alto | 🟢 Baixa | 2h |
| 3 | 📅 Planejador de Manutenção | 🔥 Alto | 🟡 Média | 5-6h |
| 4 | 🔔 Lembretes Inteligentes | 🔥 Alto | 🟡 Média | 4-5h |
| 5 | ⛽ Pesquisar Postos | 🔥 Alto | 🟡 Média | 5-6h |
| 6 | 📄 Exportar PDF | 🔥 Alto | 🟡 Média | 5-6h |

**Total estimado**: ~23-28 horas

---

### 🟡 MÉDIA PRIORIDADE

Ferramentas com **médio valor** ou **média complexidade**:

| # | Ferramenta | Valor | Complexidade | Tempo Estimado |
|---|-----------|-------|--------------|----------------|
| 7 | 📈 Simulador de Economia | 🟡 Médio | 🟡 Média | 3-4h |
| 8 | 🚗 Calculadora Depreciação | 🟡 Médio | 🟡 Média | 4-5h |
| 9 | 🔧 Oficinas Próximas | 🟡 Médio | 🟡 Média | 4-5h |
| 10 | 📊 Exportar Excel/CSV | 🟡 Médio | 🟢 Baixa | 3h |
| 11 | 📚 Guia Manutenção | 🟡 Médio | 🟡 Média | 4-5h |
| 12 | 🔍 Decodificador Painel | 🟡 Médio | 🟡 Média | 5-6h |
| 13 | 🛠️ Verificador Recall | 🟡 Médio | 🟡 Média | 4-5h |
| 14 | 🔋 Vida Útil Bateria | 🟡 Médio | 🟢 Baixa | 2h |
| 15 | 🛞 Pressão Pneus | 🟡 Médio | 🟢 Baixa | 2h |
| 16 | 💡 Dicas de Economia | 🟡 Médio | 🟢 Baixa | 2-3h |

**Total estimado**: ~33-40 horas

---

### 🔵 BAIXA PRIORIDADE (Futuro)

Ferramentas **nice-to-have** ou com **alta complexidade**:

| # | Ferramenta | Valor | Complexidade | Notas |
|---|-----------|-------|--------------|-------|
| 17 | 💸 Comparador de Custos | 🔵 Baixo | 🟡 Média | Nicho específico |
| 18 | 📊 Revisões Programadas | 🔵 Baixo | 🔴 Alta | Database extenso |
| 19 | 🅿️ Estacionamentos | 🔵 Baixo | 🟡 Média | API paga |
| 20 | 📲 Compartilhar Resumo | 🔵 Baixo | 🟡 Média | Social feature |
| 21 | 📖 Glossário | 🔵 Baixo | 🟢 Baixa | Conteúdo extenso |
| 22 | 🌡️ Conversor Unidades | 🔵 Baixo | 🟢 Baixa | Utilidade limitada |
| 23 | 📈 Análise de Padrões | 🔵 Baixo | 🔴 Alta | ML/Analytics |
| 24 | 💰 Previsão de Gastos | 🔵 Baixo | 🔴 Alta | ML + Backend |
| 25 | 🏆 Ranking | 🔵 Baixo | 🔴 Alta | Backend complexo |
| 26 | 🌱 Calculadora CO₂ | 🔵 Baixo | 🟡 Média | Nicho sustentável |
| 27 | 🚴 Alternativas Transporte | 🔵 Baixo | 🟡 Média | Escopo diferente |
| 28 | 🏅 Desafios | 🔵 Baixo | 🔴 Alta | Gamificação completa |
| 29 | 📊 Dashboard Performance | 🔵 Baixo | 🔴 Alta | Sistema de score |

---

## 🚀 Roadmap Sugerido

### Sprint 1 (1 semana)
- ✅ Calculadora Flex (IMPLEMENTADA)
- 💰 Calculadora de Custo/Km
- 🔋 Calculadora de Autonomia
- 🛞 Pressão dos Pneus

**Resultado**: 4 calculadoras funcionais

---

### Sprint 2 (1-2 semanas)
- 📅 Planejador de Manutenção
- 🔔 Lembretes Inteligentes
- 🔋 Vida Útil da Bateria
- 💡 Dicas de Economia

**Resultado**: Sistema de manutenção preventiva completo

---

### Sprint 3 (1-2 semanas)
- ⛽ Pesquisar Postos
- 🔧 Oficinas Próximas
- 🔍 Decodificador de Painel

**Resultado**: Features baseadas em localização

---

### Sprint 4 (1 semana)
- 📄 Exportar PDF
- 📊 Exportar Excel
- 📚 Guia de Manutenção

**Resultado**: Exportação e documentação

---

### Backlog (Futuro)
- Features de análise avançada (ML)
- Gamificação completa
- Sustentabilidade
- Integrações premium (APIs pagas)

---

## 📊 Métricas de Sucesso

Para cada ferramenta implementada, acompanhar:

1. **Adoção**: % de usuários que usaram a ferramenta
2. **Engajamento**: Frequência de uso (mensal, semanal)
3. **Satisfação**: Rating da ferramenta (1-5 ⭐)
4. **Impacto**: Mudança em comportamento (ex: consumo melhorou após usar calculadora?)

---

## 🔗 Dependências Técnicas

### APIs Externas Necessárias

| Ferramenta | API Necessária | Status | Custo |
|-----------|----------------|--------|-------|
| Pesquisar Postos | Google Maps API | ⚠️ Requer | Free tier limitado |
| Preços Combustível | ANP / Preço da Hora | ⚠️ Opcional | Grátis |
| Oficinas | Google Places API | ⚠️ Requer | Free tier limitado |
| Depreciação | Tabela FIPE API | ⚠️ Opcional | Grátis |
| Recalls | Denatran / Fabricantes | ⚠️ Requer scraping | Grátis |
| Estacionamentos | ParkMe / SpotHero | ⚠️ Requer | Pago |

---

## 💡 Notas de Implementação

### Padrões de UI Sugeridos

Todas as ferramentas devem seguir:

1. **CustomHeader** padrão do app
2. **Inputs coloridos** por categoria
3. **Resultado visual** com badge/card destacado
4. **Explicação educativa** quando aplicável
5. **Navegação via** `/tools/[feature-name]`

### Estrutura de Pastas

```
lib/features/tools/
├── presentation/
│   ├── pages/
│   │   ├── tools_page.dart (hub)
│   │   ├── flex_calculator_page.dart ✅
│   │   ├── cost_per_km_page.dart
│   │   ├── autonomy_calculator_page.dart
│   │   └── ... (outras ferramentas)
│   └── widgets/
│       ├── tool_card.dart
│       └── result_badge.dart
└── domain/
    └── calculators/ (lógica de negócio)
```

---

## 📝 Conclusão

Este documento serve como **roadmap vivo** para o desenvolvimento contínuo do hub de Ferramentas do app-gasometer.

**Priorização recomendada**: Foco em ferramentas de **alta prioridade** que oferecem **máximo valor** com **mínimo esforço**.

**Próximos passos**: Implementar Sprint 1 (calculadoras básicas) para validar adoção antes de investir em features mais complexas.

---

**Documento atualizado em**: Dezembro 2024
**Versão**: 1.0
**Autor**: Planejamento técnico app-gasometer

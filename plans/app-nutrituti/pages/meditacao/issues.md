# Issues e Melhorias - Módulo Meditação

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [BUG] - Timer recursivo problemático com vazamentos de memória
2. [SECURITY] - Notificações comentadas com falha de segurança
3. [REFACTOR] - Separação de responsabilidades no controller
4. [OPTIMIZE] - Gerenciamento ineficiente de recursos de áudio
5. [BUG] - Lógica defeituosa de cálculo de streak

### 🟡 Complexidade MÉDIA (7 issues)  
6. [FIXME] - Validação ausente de parâmetros de entrada
7. [TODO] - Sistema de backup e sincronização de dados
8. [REFACTOR] - Melhoria na persistência de dados com Hive
9. [OPTIMIZE] - Cache e performance de carregamento
10. [TODO] - Guias de meditação com instruções
11. [HACK] - Hardcoded de arquivos de áudio sem verificação
12. [TEST] - Ausência completa de testes automatizados

### 🟢 Complexidade BAIXA (6 issues)
13. [STYLE] - Padronização de cores e estilos visuais
14. [DOC] - Documentação insuficiente de métodos
15. ✅ [FIXME] - Magic numbers em durações e configurações
16. [TODO] - Melhorias de acessibilidade na UI
17. ✅ [OPTIMIZE] - Otimização de widgets desnecessários
18. ✅ [DEPRECATED] - Uso de printError em production

---

## 🔴 Complexidade ALTA

### 1. [BUG] - Timer recursivo problemático com vazamentos de memória

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método _iniciarTimer() usa recursão com Future.delayed criando 
vazamentos de memória e comportamento imprevisível quando usuário pausa/retoma 
rapidamente. Timer pode continuar executando mesmo após dispose.

**Prompt de Implementação:**

Substitua o timer recursivo por Stream.periodic ou Timer.periodic oficial. 
Implemente cancelamento adequado no onClose e pausas. Adicione estado de 
controle para evitar múltiplos timers simultâneos. Garanta que recursos sejam 
liberados adequadamente.

**Dependências:** controllers/meditacao_controller.dart, widgets/meditacao_timer_widget.dart

**Validação:** Timer deve pausar/retomar corretamente sem vazamentos de 
memória detectáveis

---

### 2. [SECURITY] - Notificações comentadas com falha de segurança

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Código de agendamento de notificações está comentado (linhas 
186-197) sem explicação. Isso indica falha de funcionalidade ou problema de 
segurança não resolvido que foi "silenciado".

**Prompt de Implementação:**

Investigate por que o código de notificação foi comentado. Se houver problema 
de segurança, corrija-o adequadamente. Se funcionalidade foi removida, remova 
código comentado completamente. Documente decisão e implemente solução 
definitiva.

**Dependências:** controllers/meditacao_controller.dart, permissões de notificação

**Validação:** Notificações funcionando seguramente ou código limpo sem 
comentários de produção

---

### 3. [REFACTOR] - Separação de responsabilidades no controller

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Controller assume múltiplas responsabilidades: gerenciamento de 
estado, lógica de negócio, controle de áudio, timer, notificações e 
persistência. Viola princípio de responsabilidade única.

**Prompt de Implementação:**

Divida controller em serviços especializados: AudioService para gerenciamento 
de áudio, TimerService para controle de timer, NotificationService para 
notificações, AchievementService para conquistas. Controller deve apenas 
coordenar estado da UI e chamar serviços apropriados.

**Dependências:** Todos os widgets que dependem do controller, criação de novos services

**Validação:** Controller menor e mais focado, serviços reutilizáveis e testáveis

---

### 4. [OPTIMIZE] - Gerenciamento ineficiente de recursos de áudio

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** AudioPlayer é criado no controller mas áudio é tocado/parado 
sem controle de estado adequado. Múltiplos arquivos podem tocar 
simultaneamente e recursos não são liberados corretamente.

**Prompt de Implementação:**

Implemente singleton AudioService com controle de estado. Adicione verificação 
de existência de arquivos de áudio antes de reproduzir. Implemente fadein/
fadeout suaves. Garanta que apenas um áudio toque por vez e recursos sejam 
liberados adequadamente.

**Dependências:** controllers/meditacao_controller.dart, arquivos de áudio assets

**Validação:** Áudio tocando sem conflitos, transições suaves, sem vazamentos 
de recursos

---

### 5. [BUG] - Lógica defeituosa de cálculo de streak

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Cálculo de sequência em MeditacaoStatsModel tem lógica 
defeituosa para determinar dias consecutivos. isAtSameMomentAs pode falhar 
com fusos horários e comparação de datas pode ser imprecisa.

**Prompt de Implementação:**

Refatore lógica de streak usando DateUtils do Flutter para comparação precisa 
de datas. Implemente cálculo baseado em dias calendários independente de 
horário. Adicione tratamento para mudanças de fuso horário. Teste edge cases 
como virada de ano e horário de verão.

**Dependências:** models/meditacao_stats_model.dart, repository que processa estatísticas

**Validação:** Streak calculado corretamente em diferentes cenários de data/hora

---

## 🟡 Complexidade MÉDIA

### 6. [FIXME] - Validação ausente de parâmetros de entrada

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Métodos não validam parâmetros de entrada. Durações podem ser 
negativas, tipos de meditação inválidos podem ser aceitos, humor pode ser 
string vazia causando comportamento inesperado.

**Prompt de Implementação:**

Adicione validação de entrada em todos os métodos públicos. Duração deve ser 
positiva e dentro de limites razoáveis. Tipos de meditação devem estar na 
lista predefinida. Humor deve ser selecionado antes de finalizar sessão. 
Retorne erros claros para entradas inválidas.

**Dependências:** controllers/meditacao_controller.dart, widgets de entrada

**Validação:** Impossibilidade de inserir dados inválidos com feedback claro

---

### 7. [TODO] - Sistema de backup e sincronização de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Dados ficam apenas no SharedPreferences local. Usuário pode 
perder histórico de meditação ao trocar de dispositivo ou reinstalar app. 
Falta sincronização na nuvem.

**Prompt de Implementação:**

Implemente backup automático para Firebase Firestore. Adicione sincronização 
bidirecional entre dispositivos. Crie estratégia de resolução de conflitos 
para dados modificados offline. Permita exportação manual de dados para JSON.

**Dependências:** repository/meditacao_repository.dart, configuração Firebase

**Validação:** Dados sincronizados entre dispositivos e backup automático funcionando

---

### 8. [REFACTOR] - Melhoria na persistência de dados com Hive

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Uso de SharedPreferences para dados complexos é ineficiente. 
Serialização JSON manual é propensa a erros. Hive seria mais apropriado para 
modelos estruturados como já usado em outros módulos.

**Prompt de Implementação:**

Migre persistência de SharedPreferences para Hive. Crie adapters para todos 
os models. Implemente migração automática de dados existentes. Mantenha 
compatibilidade backward durante transição. Use TypeAdapters para melhor 
performance.

**Dependências:** Todos os models, repository/meditacao_repository.dart

**Validação:** Dados migrados sem perda, performance melhorada, código mais limpo

---

### 9. [OPTIMIZE] - Cache e performance de carregamento

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados são recarregados completamente a cada inicialização. 
Estatísticas são recalculadas desnecessariamente. Falta cache inteligente 
para melhorar responsividade.

**Prompt de Implementação:**

Implemente cache em memória para dados frequentemente acessados. Use lazy 
loading para carregar apenas dados necessários. Adicione invalidação seletiva 
de cache quando dados mudam. Otimize cálculos de estatísticas usando cache 
incremental.

**Dependências:** repository/meditacao_repository.dart, controllers

**Validação:** Tempo de carregamento reduzido significativamente, UI mais responsiva

---

### 10. [TODO] - Guias de meditação com instruções

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** App oferece apenas timer e áudio. Usuários iniciantes precisam 
de orientações sobre técnicas de meditação. Falta conteúdo educativo 
integrado.

**Prompt de Implementação:**

Adicione sistema de guias com instruções passo-a-passo para cada tipo de 
meditação. Inclua textos explicativos sobre técnicas. Crie modo tutorial para 
iniciantes. Adicione dicas contextuais durante sessões. Implemente progressão 
de dificuldade.

**Dependências:** Novos widgets de tutorial, conteúdo textual, UI expandida

**Validação:** Guias acessíveis e úteis para usuários de diferentes níveis

---

### 11. [HACK] - Hardcoded de arquivos de áudio sem verificação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Arquivos de áudio são hardcoded em Map sem verificação de 
existência. Se arquivo não existir, app pode crashar. Não há fallback ou 
tratamento de erro.

**Prompt de Implementação:**

Implemente verificação de existência de arquivos de áudio durante 
inicialização. Adicione arquivos padrão como fallback. Crie sistema de 
configuração dinâmica para arquivos de áudio. Trate erros de reprodução 
gracefully com feedback ao usuário.

**Dependências:** controllers/meditacao_controller.dart, assets de áudio

**Validação:** App funciona mesmo com arquivos de áudio ausentes, com fallbacks adequados

---

### 12. [TEST] - Ausência completa de testes automatizados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo complexo sem testes unitários, widgets ou integração. 
Dificulta refatorações seguras e detecção de regressões. Qualidade não é 
garantida.

**Prompt de Implementação:**

Crie testes unitários para todos os models e repository. Teste lógica de 
cálculo de streak e estatísticas. Implemente widget tests para componentes UI. 
Adicione integration tests para fluxos principais. Configure CI com cobertura 
mínima de 80%.

**Dependências:** Configuração de ambiente de teste, mocks

**Validação:** Cobertura de testes acima de 80% e pipeline de CI passando

---

## 🟢 Complexidade BAIXA

### 13. [STYLE] - Padronização de cores e estilos visuais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets usam cores hardcoded (Colors.blue, Colors.grey) sem 
consistência com tema da aplicação. Interface pode parecer desconectada do 
design system.

**Prompt de Implementação:**

Substitua cores hardcoded por Theme.of(context). Crie ColorScheme consistente 
para módulo de meditação. Use cores que transmitam calma e tranquilidade. 
Garanta contraste adequado para acessibilidade. Aplique tema consistente em 
todos os widgets.

**Dependências:** Todos os widgets do módulo

**Validação:** Interface visualmente consistente e seguindo design system

---

### 14. [DOC] - Documentação insuficiente de métodos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos públicos não possuem dartdoc adequado. Parâmetros e 
comportamentos não são documentados. Dificulta manutenção e uso por outros 
desenvolvedores.

**Prompt de Implementação:**

Adicione dartdoc completo para todos os métodos públicos. Documente parâmetros, 
retornos e efeitos colaterais. Inclua exemplos de uso quando apropriado. 
Documente comportamentos especiais como tratamento de timer e notificações.

**Dependências:** Nenhuma

**Validação:** Documentação gerada automaticamente sem warnings

---

### 15. ✅ [FIXME] - Magic numbers em durações e configurações

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Valores como 24 (horas), durações 5,10,15,20 (minutos), IDs 
numéricos aparecem hardcoded no código. Reduz legibilidade e flexibilidade.

**Prompt de Implementação:**

Extraia magic numbers para constantes nomeadas. Crie classe MeditacaoConstants 
com valores padrão. Use constantes semanticamente nomeadas em todo código. 
Permita configuração futura destes valores via settings.

**Dependências:** Todos os arquivos que usam valores hardcoded

**Validação:** Ausência de magic numbers, uso de constantes bem nomeadas

---

### 16. [TODO] - Melhorias de acessibilidade na UI

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets não possuem semantics adequados para leitores de tela. 
Botões podem não ter labels descritivos. Contraste de cores pode ser 
insuficiente.

**Prompt de Implementação:**

Adicione Semantics widgets onde apropriado. Inclua labels descritivos para 
todos os botões e controles. Verifique contraste de cores para AA/AAA 
compliance. Adicione suporte para navegação por teclado. Teste com TalkBack/VoiceOver.

**Dependências:** Todos os widgets de UI

**Validação:** App utilizável com leitor de tela e navegação por teclado

---

### 17. ✅ [OPTIMIZE] - Otimização de widgets desnecessários

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns widgets fazem rebuild desnecessários. Obx() usado em 
lugares onde Obx específico seria mais eficiente. SizedBox.shrink() usado 
incorretamente.

**Prompt de Implementação:**

Otimize uso de Obx() para observar apenas variáveis necessárias. Use const 
constructors onde possível. Substitua SizedBox.shrink() por Visibility ou 
Offstage quando apropriado. Adicione keys em widgets de lista.

**Dependências:** Todos os widgets do módulo

**Validação:** Performance melhorada sem rebuilds desnecessários

---

### 18. ✅ [DEPRECATED] - Uso de printError em production

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** printError() usado para log de erros não é adequado para 
produção. Logs podem vazar informações sensíveis ou simplesmente não aparecer 
em release builds.

**Prompt de Implementação:**

Substitua printError() por sistema de logging adequado usando package:logging. 
Configure diferentes níveis de log para debug/release. Implemente logs 
estruturados que podem ser enviados para serviços de monitoramento.

**Dependências:** controllers/meditacao_controller.dart

**Validação:** Sistema de logging profissional sem prints em produção

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
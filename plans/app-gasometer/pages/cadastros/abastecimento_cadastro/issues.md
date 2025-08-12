# Issues e Melhorias - Abastecimento Cadastro

## 📋 Índice Geral

### 🔴 Complexidade ALTA (7 issues)
1. [BUG] - Race conditions no controle de estado do formulário
2. [BUG] - Vazamento de memória com timers não cancelados
3. [REFACTOR] - Controller com responsabilidades excessivas
4. [SECURITY] - Falta de sanitização em campos de texto
5. [OPTIMIZE] - Rebuilds excessivos prejudicando performance
6. [REFACTOR] - Separação inadequada de camadas MVC
7. [BUG] - Tratamento inconsistente de erros

### 🟡 Complexidade MÉDIA (6 issues)
8. [TODO] - Implementar auto-save de rascunho
9. [FIXME] - Validação incompleta de limites superiores
10. [OPTIMIZE] - Múltiplas chamadas refresh desnecessárias
11. [TODO] - Adicionar cálculo de eficiência de combustível
12. [REFACTOR] - Extrair lógica de negócio do controller
13. [STYLE] - Dialog com altura fixa não responsiva

### 🟢 Complexidade BAIXA (5 issues)
14. [TODO] - Implementar autocomplete para posto
15. [STYLE] - Melhorar feedback visual durante cálculos
16. [DOC] - Documentação ausente nos métodos principais
17. [TEST] - Falta cobertura de testes unitários
18. [NOTE] - Services poderiam ser compartilhados

---

## 🔴 Complexidade ALTA

### 1. [BUG] - Race conditions no controle de estado do formulário

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O controller usa múltiplas flags booleanas (_isUpdating, 
_isFormattingUpdate, isLoading) de forma inconsistente para prevenir condições 
de corrida. Isso pode causar estados inconsistentes e comportamentos inesperados 
quando múltiplas atualizações ocorrem simultaneamente.

**Prompt de Implementação:**
```
Refatore o sistema de controle de estado no AbastecimentoFormController para 
usar um padrão de máquina de estados único. Crie um enum FormState com valores 
como idle, updating, formatting, loading, saving. Use uma única variável de 
estado ao invés de múltiplas flags. Implemente métodos que garantam transições 
de estado atômicas e previna operações concorrentes conflitantes. Adicione logs 
para rastrear mudanças de estado durante desenvolvimento.
```

**Dependências:** controller/abastecimento_form_controller.dart, todos os 
widgets que observam o estado do controller

**Validação:** Testar múltiplas interações rápidas nos campos de valor e litros, 
verificar se os cálculos permanecem consistentes

---

### 2. [BUG] - Vazamento de memória com timers não cancelados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller possui três timers de debounce que não são 
adequadamente cancelados em todos os cenários, especialmente quando o dialog 
é fechado abruptamente. Isso pode causar vazamentos de memória em uso prolongado.

**Prompt de Implementação:**
```
No método onClose do AbastecimentoFormController, garanta que todos os timers 
sejam cancelados. Crie um método _cancelAllTimers que cancele _litrosDebounceTimer, 
_valorPorLitroDebounceTimer e _odometroDebounceTimer. Chame este método no 
onClose e antes de criar novos timers. Adicione verificações null-safe antes 
de cancelar. Considere usar uma lista de timers para gerenciamento centralizado.
```

**Dependências:** controller/abastecimento_form_controller.dart

**Validação:** Abrir e fechar o dialog múltiplas vezes rapidamente, monitorar 
uso de memória no DevTools

---

### 3. [REFACTOR] - Controller com responsabilidades excessivas

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller tem 475 linhas e gerencia validação, formatação, 
cálculos, persistência e estado de UI. Isso viola o princípio de responsabilidade 
única e dificulta manutenção e testes.

**Prompt de Implementação:**
```
Divida o AbastecimentoFormController em múltiplas classes especializadas. Crie 
um AbastecimentoCalculationService para lógica de cálculo, um 
AbastecimentoRepository para operações de dados, mantenha apenas gerenciamento 
de estado no controller. Use injeção de dependência do GetX para conectar os 
serviços. Mova métodos de cálculo para o service, operações de banco para o 
repository. O controller deve orquestrar mas não implementar lógica de negócio.
```

**Dependências:** controller/abastecimento_form_controller.dart, criação de 
novos arquivos services/calculation_service.dart e 
repositories/abastecimento_repository.dart

**Validação:** Todos os testes existentes devem continuar passando, 
funcionalidade deve permanecer idêntica

---

### 4. [SECURITY] - Falta de sanitização em campos de texto

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Campos de texto como posto e observação não possuem sanitização, 
podendo permitir injeção de scripts maliciosos se os dados forem exibidos em 
contextos web ou compartilhados.

**Prompt de Implementação:**
```
Adicione sanitização para todos os campos de texto no AbastecimentoFormModel. 
Crie um método sanitizeText que remova caracteres especiais perigosos e tags 
HTML. Aplique sanitização nos setters de posto e observacao. Para o campo posto, 
permita apenas letras, números, espaços e pontuação básica. Para observação, 
seja mais permissivo mas remova tags HTML e scripts. Mantenha comprimento 
máximo de 500 caracteres para observação.
```

**Dependências:** models/abastecimento_form_model.dart, 
widgets/observacao_field.dart, controller/abastecimento_form_controller.dart

**Validação:** Tentar inserir tags HTML e scripts nos campos, verificar se são 
removidos ou escapados

---

### 5. [OPTIMIZE] - Rebuilds excessivos prejudicando performance

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O uso de Obx na raiz do formulário causa rebuild completo a cada 
mudança de estado, prejudicando performance em dispositivos mais lentos.

**Prompt de Implementação:**
```
Refatore abastecimento_form_view para usar Obx apenas onde necessário. Mova 
Obx para envolver apenas widgets que realmente precisam reagir a mudanças. Por 
exemplo, envolva apenas o CircularProgressIndicator com Obx para isLoading. 
Para campos do formulário, use GetBuilder com IDs específicos ou crie observables 
individuais. Considere usar keys para preservar estado de widgets que não mudam.
```

**Dependências:** views/abastecimento_form_view.dart, todos os widgets de campo

**Validação:** Usar Flutter Inspector para verificar quantos widgets são 
reconstruídos ao digitar em um campo

---

### 6. [REFACTOR] - Separação inadequada de camadas MVC

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Widgets acessam diretamente o controller, criando acoplamento 
forte. Lógica de negócio está misturada com lógica de apresentação no controller.

**Prompt de Implementação:**
```
Implemente padrão de callbacks para desacoplar widgets do controller. Cada 
widget deve receber callbacks como parâmetros ao invés de acessar o controller 
diretamente. Crie interfaces ou classes abstratas para definir contratos. Por 
exemplo, LitrosField deve receber onChanged callback ao invés de chamar 
controller.updateLitros. Isso facilitará testes e reutilização dos widgets.
```

**Dependências:** Todos os widgets na pasta widgets/, 
views/abastecimento_form_view.dart

**Validação:** Widgets devem funcionar isoladamente em testes sem necessidade 
do controller real

---

### 7. [BUG] - Tratamento inconsistente de erros

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Erros de validação aparecem inline mas erros de submissão usam 
AlertDialog. Mensagens genéricas não ajudam o usuário a entender o problema.

**Prompt de Implementação:**
```
Padronize tratamento de erros em toda a aplicação. Crie um ErrorHandler 
centralizado que categorize erros e forneça mensagens específicas. Para erros 
de validação, mantenha inline. Para erros de rede, use SnackBar. Para erros 
críticos, use AlertDialog. Adicione códigos de erro e ações sugeridas. Implemente 
logging de erros para debugging.
```

**Dependências:** widgets/abastecimento_cadastro.dart, 
controller/abastecimento_form_controller.dart, criação de 
services/error_handler.dart

**Validação:** Simular diferentes tipos de erro e verificar consistência na 
apresentação

---

## 🟡 Complexidade MÉDIA

### 8. [TODO] - Implementar auto-save de rascunho

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Formulário não salva rascunho automaticamente, causando perda 
de dados se o usuário fechar acidentalmente o dialog.

**Prompt de Implementação:**
```
Implemente auto-save usando SharedPreferences ou banco local. Crie método 
saveDraft que serializa o model atual para JSON e salva com timestamp. Implemente 
loadDraft que recupera e deserializa. Adicione timer que salva a cada 30 segundos 
se houver mudanças. Ao abrir o form, verifique se existe rascunho e pergunte 
se deseja recuperar. Limpe rascunho após salvar com sucesso.
```

**Dependências:** controller/abastecimento_form_controller.dart, 
models/abastecimento_form_model.dart

**Validação:** Preencher formulário parcialmente, fechar e reabrir, verificar 
se oferece recuperação

---

### 9. [FIXME] - Validação incompleta de limites superiores

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Validação permite até 999 litros mas não limita preço por litro 
ou valor total, permitindo valores irreais.

**Prompt de Implementação:**
```
Adicione limites superiores realistas em ValidationService. Para preço por 
litro, limite a 50 reais. Para valor total, limite a 50000 reais. Para odômetro, 
limite a 9999999 km. Adicione mensagens de erro específicas explicando os limites. 
Considere tornar limites configuráveis para diferentes contextos de uso.
```

**Dependências:** services/validation_service.dart

**Validação:** Tentar inserir valores acima dos limites e verificar mensagens 
de erro

---

### 10. [OPTIMIZE] - Múltiplas chamadas refresh desnecessárias

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Controller chama _formModel.refresh() múltiplas vezes em sequência, 
causando rebuilds desnecessários.

**Prompt de Implementação:**
```
Implemente padrão de batch updates. Crie método beginUpdate e endUpdate que 
controlam quando refresh é chamado. Durante beginUpdate, acumule mudanças sem 
notificar. Em endUpdate, chame refresh uma única vez. Use este padrão em métodos 
que fazem múltiplas atualizações como calcularValorTotal. Adicione flag para 
rastrear se há mudanças pendentes.
```

**Dependências:** controller/abastecimento_form_controller.dart, 
models/abastecimento_form_model.dart

**Validação:** Contar quantas vezes refresh é chamado durante uma operação de 
cálculo

---

### 11. [TODO] - Adicionar cálculo de eficiência de combustível

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Após salvar abastecimento, poderia calcular e exibir km/L baseado 
no abastecimento anterior.

**Prompt de Implementação:**
```
Adicione método calculateFuelEfficiency no controller que busca o abastecimento 
anterior do mesmo veículo. Calcule km percorridos dividido por litros abastecidos. 
Exiba resultado em SnackBar após salvar com sucesso. Considere tanque cheio 
para cálculos mais precisos. Armazene eficiência calculada no modelo para 
histórico. Trate casos especiais como primeiro abastecimento.
```

**Dependências:** controller/abastecimento_form_controller.dart, 
repository de abastecimentos

**Validação:** Criar dois abastecimentos sequenciais e verificar cálculo de 
eficiência

---

### 12. [REFACTOR] - Extrair lógica de negócio do controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Métodos como calcularValorTotal e criarNovoAbastecimento contêm 
lógica de negócio que deveria estar em camada de domínio.

**Prompt de Implementação:**
```
Crie pasta domain/use_cases e implemente CalculateAbastecimentoTotalsUseCase 
e CreateAbastecimentoUseCase. Mova toda lógica de cálculo e criação para estes 
use cases. Controller deve apenas chamar use cases e atualizar UI. Use cases 
devem ser testáveis independentemente. Injete use cases no controller via GetX.
```

**Dependências:** controller/abastecimento_form_controller.dart, criação de 
novos arquivos em domain/use_cases/

**Validação:** Lógica de negócio deve ser testável sem dependências de UI

---

### 13. [STYLE] - Dialog com altura fixa não responsiva

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dialog tem maxHeight fixo de 570 pixels que pode não funcionar 
bem em telas pequenas ou landscape.

**Prompt de Implementação:**
```
Torne o dialog responsivo usando MediaQuery. Calcule altura máxima como 80% 
da altura da tela. Para landscape, use 90%. Adicione scroll se conteúdo exceder 
altura disponível. Considere usar LayoutBuilder para ajustes mais precisos. 
Teste em diferentes tamanhos de tela e orientações.
```

**Dependências:** widgets/abastecimento_cadastro.dart

**Validação:** Testar em dispositivos com diferentes tamanhos de tela e 
orientações

---

## 🟢 Complexidade BAIXA

### 14. [TODO] - Implementar autocomplete para posto

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Campo posto poderia sugerir postos previamente utilizados para 
entrada mais rápida.

**Prompt de Implementação:**
```
Implemente autocomplete que busca postos únicos já cadastrados. Crie método 
getUniquePostos no repository que retorna lista de postos distintos. Use 
Autocomplete widget do Flutter com esta lista. Filtre sugestões conforme usuário 
digita. Mantenha limite de 10 sugestões. Ordene por frequência de uso ou 
alfabeticamente.
```

**Dependências:** Criar novo widget posto_autocomplete_field.dart, modificar 
info_section.dart

**Validação:** Após cadastrar alguns postos, verificar se aparecem como sugestões

---

### 15. [STYLE] - Melhorar feedback visual durante cálculos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Usuário não tem feedback visual quando cálculos automáticos estão 
ocorrendo após mudanças nos campos.

**Prompt de Implementação:**
```
Adicione indicadores visuais sutis durante cálculos. Use CircularProgressIndicator 
pequeno ao lado dos campos sendo calculados. Ou mude cor/opacidade do campo 
durante atualização. Adicione pequena animação de fade. Duração máxima de 300ms 
para não parecer lento. Use AnimatedContainer para transições suaves.
```

**Dependências:** widgets/valor_total_field.dart, widgets/litros_field.dart, 
widgets/preco_por_litro_field.dart

**Validação:** Alterar valores e observar feedback visual durante cálculos

---

### 16. [DOC] - Documentação ausente nos métodos principais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Controller e model não possuem documentação adequada dos métodos 
públicos e lógica complexa.

**Prompt de Implementação:**
```
Adicione comentários de documentação em formato DartDoc para todos métodos 
públicos. Inclua descrição, parâmetros, retorno e exemplos quando relevante. 
Documente especialmente lógica de cálculo e regras de negócio. Use tags como 
@param, @return, @throws. Mantenha documentação concisa mas informativa.
```

**Dependências:** controller/abastecimento_form_controller.dart, 
models/abastecimento_form_model.dart

**Validação:** Executar dartdoc e verificar geração de documentação

---

### 17. [TEST] - Falta cobertura de testes unitários

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo não possui testes unitários, dificultando refatorações 
seguras e detecção de regressões.

**Prompt de Implementação:**
```
Crie estrutura de testes unitários para o módulo. Comece testando ValidationService 
e FormattingService por serem mais simples. Depois teste Model com diferentes 
cenários de dados. Para Controller, use mocks do repository. Teste cálculos, 
validações e fluxos principais. Aim para 80% de cobertura. Use flutter_test 
e mockito.
```

**Dependências:** Criação de arquivos test/ correspondentes a cada classe

**Validação:** Executar flutter test e verificar cobertura

---

### 18. [NOTE] - Services poderiam ser compartilhados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** ValidationService e FormattingService são específicos do módulo 
mas poderiam ser reutilizados em outras partes da aplicação.

**Prompt de Implementação:**
```
Mova services genéricos para pasta core/services. Torne métodos mais genéricos 
removendo lógica específica de abastecimento. Por exemplo, formatCurrency poderia 
aceitar parâmetros de localização. validateNumericRange poderia ser usado para 
qualquer validação numérica. Mantenha retrocompatibilidade criando aliases 
nos services atuais.
```

**Dependências:** services/validation_service.dart, services/formatting_service.dart, 
outros módulos que poderiam beneficiar

**Validação:** Outros módulos devem poder importar e usar os services 
compartilhados

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
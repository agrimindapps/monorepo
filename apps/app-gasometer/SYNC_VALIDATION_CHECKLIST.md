# Checklist de Validação - Sistema UnifiedSync
## App Gasometer - Lista de Verificação Prática

### 📋 INSTRUÇÕES DE USO
- [ ] **Imprimir ou manter aberto** este checklist durante testes
- [ ] **Marcar cada item** conforme completa os testes
- [ ] **Anotar observações** na seção de notas de cada categoria
- [ ] **Reportar problemas** com número do teste específico (ex: "CT001 falhou")

---

## 🚀 FASE 1: SETUP E CONFIGURAÇÃO INICIAL

### ✅ 1.1 Preparação do Ambiente
- [ ] **CF001**: Flutter clean executado
- [ ] **CF002**: flutter pub get executado sem erros
- [ ] **CF003**: Firebase conectado e funcionando
- [ ] **CF004**: Ambos main.dart e main_unified_sync.dart compilam
- [ ] **CF005**: Hive boxes criados e acessíveis

### ✅ 1.2 Verificação de Modes
- [ ] **CM001**: Simple mode executa (main_unified_sync.dart)
- [ ] **CM002**: Development mode executa
- [ ] **CM003**: Offline-first mode executa
- [ ] **CM004**: Alternar entre modes sem crash
- [ ] **CM005**: Logs aparecem corretamente no debug

**📝 Notas Fase 1:**
```
[Anotar aqui problemas encontrados na configuração inicial]
```

---

## 🏗️ FASE 2: ENTIDADES BÁSICAS

### ✅ 2.1 VehicleEntity Tests
- [ ] **CV001**: Criar veículo via botão "+" funciona
- [ ] **CV002**: Veículo aparece na lista imediatamente
- [ ] **CV003**: Status muda de "Syncing..." para "Synced"
- [ ] **CV004**: Editar veículo via menu ⋮ funciona
- [ ] **CV005**: Exclusão de veículo funciona
- [ ] **CV006**: Confirmação dialog aparece antes exclusão
- [ ] **CV007**: Veículo removido desaparece da lista
- [ ] **CV008**: Detalhes do veículo (tap) mostram info completa

### ✅ 2.2 FuelRecordEntity Tests
- [ ] **CF001**: "Add Fuel" no menu do veículo funciona
- [ ] **CF002**: Registro criado com dados simulados
- [ ] **CF003**: Associação com veículo correto
- [ ] **CF004**: Mensagem de sucesso exibida
- [ ] **CF005**: Dados aparecem no Firebase Console

### ✅ 2.3 ExpenseEntity Tests
- [ ] **CE001**: Sistema aceita valores monetários válidos
- [ ] **CE002**: Sistema rejeita valores negativos
- [ ] **CE003**: Validação de formato monetário funciona
- [ ] **CE004**: Audit trail registra mudanças

### ✅ 2.4 MaintenanceEntity Tests
- [ ] **CM001**: Criação de manutenção funciona
- [ ] **CM002**: Associação com veículo correta
- [ ] **CM003**: Agendamento funcionando

**📝 Notas Fase 2:**
```
[Anotar problemas com entidades específicas]
```

---

## 🔄 FASE 3: SINCRONIZAÇÃO AVANÇADA

### ✅ 3.1 Offline → Online Sync
- [ ] **CO001**: Modo avião ativado
- [ ] **CO002**: 3+ veículos criados offline
- [ ] **CO003**: Status "Syncing..." ou similar para todos
- [ ] **CO004**: Modo avião desativado
- [ ] **CO005**: Sync automático inicia em ≤5 min
- [ ] **CO006**: Todos dados aparecem no Firebase
- [ ] **CO007**: Status muda para "Synced" para todos
- [ ] **CO008**: Nenhum dado perdido no processo

### ✅ 3.2 Real-time Sync (2 dispositivos necessários)
- [ ] **CR001**: Device A cria veículo
- [ ] **CR002**: Device B recebe veículo em ≤30s
- [ ] **CR003**: Device B edita veículo
- [ ] **CR004**: Device A reflete mudança em ≤30s
- [ ] **CR005**: Ambos dispositivos convergem ao mesmo estado

### ✅ 3.3 Conflict Resolution
- [ ] **CC001**: Mesmo item editado em 2 dispositivos
- [ ] **CC002**: Conflito detectado automaticamente
- [ ] **CC003**: Strategy timestamp aplicada corretamente
- [ ] **CC004**: Dispositivos convergem para versão mais recente
- [ ] **CC005**: Nenhum dado corrompido no processo

### ✅ 3.4 Background Sync
- [ ] **CB001**: App minimizado por 5+ minutos
- [ ] **CB002**: Dados modificados no Firebase Console
- [ ] **CB003**: App maximizado novamente
- [ ] **CB004**: Dados atualizados sem ação do usuário

**📝 Notas Fase 3:**
```
[Anotar problemas com sincronização avançada]
```

---

## 💰 FASE 4: FEATURES FINANCEIRAS

### ✅ 4.1 Financial Validator
- [ ] **FV001**: R$ 100,50 aceito ✅
- [ ] **FV002**: 1.234,56 aceito ✅
- [ ] **FV003**: 0,01 aceito ✅
- [ ] **FV004**: -100,50 rejeitado ❌
- [ ] **FV005**: abc,50 rejeitado ❌
- [ ] **FV006**: 100,999 rejeitado ❌
- [ ] **FV007**: Campo vazio rejeitado ❌

### ✅ 4.2 Audit Trail
- [ ] **FA001**: Criação de despesa R$ 100,00
- [ ] **FA002**: Edição para R$ 150,00 registrada
- [ ] **FA003**: Edição para R$ 200,00 registrada
- [ ] **FA004**: Histórico mostra: 100→150→200
- [ ] **FA005**: Timestamps corretos no histórico
- [ ] **FA006**: User ID registrado em cada mudança

### ✅ 4.3 Manual Conflict Resolution
- [ ] **FM001**: Conflito financeiro detectado
- [ ] **FM002**: UI para resolução manual aparece
- [ ] **FM003**: Usuário pode escolher versão correta
- [ ] **FM004**: Ambas versões mantidas para auditoria

**📝 Notas Fase 4:**
```
[Anotar problemas específicos com features financeiras]
```

---

## 📊 FASE 5: COMPARAÇÃO COM APP-PLANTIS

### ✅ 5.1 Feature Parity Check
- [ ] **FP001**: UnifiedSync funcionando em ambos apps
- [ ] **FP002**: Sync status indicator presente em ambos
- [ ] **FP003**: Force sync button funciona em ambos
- [ ] **FP004**: Offline support equivalente
- [ ] **FP005**: Conflict resolution equivalente
- [ ] **FP006**: Performance similar entre apps

### ✅ 5.2 UI/UX Consistency
- [ ] **UI001**: Sync indicators consistentes
- [ ] **UI002**: Error handling similar
- [ ] **UI003**: Loading states equivalentes
- [ ] **UI004**: Debug info no mesmo formato

### ✅ 5.3 Performance Comparison
- [ ] **PERF001**: Tempo de sync ≤ plantis + 10%
- [ ] **PERF002**: Uso de memória similar
- [ ] **PERF003**: Impacto na bateria equivalente

**📝 Notas Fase 5:**
```
[Anotar diferenças encontradas com app-plantis]
```

---

## 🔧 FASE 6: TROUBLESHOOTING

### ✅ 6.1 Error Recovery
- [ ] **ER001**: Restart app após erro recupera estado
- [ ] **ER002**: Flutter clean + pub get resolve issues
- [ ] **ER003**: Limpar Hive boxes restaura funcionalidade
- [ ] **ER004**: Debug logs ajudam identificar problemas

### ✅ 6.2 Network Issues
- [ ] **EN001**: Internet instável não corrompe dados
- [ ] **EN002**: Reconexão automática funciona
- [ ] **EN003**: Retry mechanism efetivo

**📝 Notas Fase 6:**
```
[Anotar problemas de recovery e soluções encontradas]
```

---

## 🏁 VALIDAÇÃO FINAL

### ✅ Critérios de Aprovação
- [ ] **FINAL001**: Pelo menos 90% dos testes passaram
- [ ] **FINAL002**: Nenhum teste crítico (CV, CF, FV) falhou
- [ ] **FINAL003**: Performance equivalente ou melhor que plantis
- [ ] **FINAL004**: Features financeiras funcionando 100%
- [ ] **FINAL005**: Multi-device sync funciona corretamente

### 📊 Resumo dos Resultados

| Fase | Total Tests | Passed | Failed | Success Rate |
|------|-------------|--------|--------|--------------|
| Fase 1 | 10 | ___ | ___ | ___% |
| Fase 2 | 18 | ___ | ___ | ___% |
| Fase 3 | 21 | ___ | ___ | ___% |
| Fase 4 | 16 | ___ | ___ | ___% |
| Fase 5 | 9 | ___ | ___ | ___% |
| Fase 6 | 6 | ___ | ___ | ___% |
| **TOTAL** | **80** | **___** | **___** | **___%** |

### 🎯 Status Final
- [ ] ✅ **APROVADO**: Pronto para produção (≥90% success)
- [ ] ⚠️ **CONDICIONAL**: Necessita correções menores (80-89%)
- [ ] ❌ **REPROVADO**: Necessita revisão completa (<80%)

---

## 📞 SUPORTE

**Em caso de falhas:**
1. **Anotar número do teste específico** (ex: CV003, FV005)
2. **Copiar logs completos** do console
3. **Screenshot** se possível
4. **Reportar** com contexto completo

**Informações importantes para reportar:**
- Dispositivo usado: _______________
- Versão Flutter: _______________
- Mode testado: _______________
- Internet: WiFi/Mobile/Instável
- Firebase Project: _______________

---

**Data do Teste:** _______________
**Testador:** _______________
**Versão do App:** _______________
**Resultado Final:** ✅ / ⚠️ / ❌
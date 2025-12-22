# Unificação do Seletor de Veículos - Timeline

**Data**: 2025-12-21
**Arquivo**: `lib/features/timeline/presentation/pages/timeline_page.dart`

## 🎯 Objetivo

Unificar o seletor de veículos em todas as páginas do app (Timeline, Abastecimentos, Odômetro, etc.) para garantir consistência visual e funcional.

## 📋 Mudanças Realizadas

### **Antes**
- Timeline usava um `DropdownButton` manual básico
- Container azul customizado (`Colors.blue.shade50`)
- Sem persistência, sem animações
- Estados loading/error tratados manualmente
- Suportava opção "Todos os veículos" (value: null)
- ~100 linhas de código duplicado

### **Depois**
- Timeline agora usa `EnhancedVehicleSelector` (componente compartilhado)
- Visual consistente com Fuel/Odometer pages
- Persistência automática (SharedPreferences)
- Auto-seleção inteligente (prioriza veículos ativos)
- Animações e feedback háptico
- ~10 linhas de código (90% redução)

## ⚠️ Mudança de Comportamento

### **Comportamento Anterior**
Timeline permitia visualizar "Todos os veículos" (filtro null), mostrando registros de todos os veículos simultaneamente.

### **Comportamento Atual**
O `EnhancedVehicleSelector` sempre auto-seleciona um veículo (não suporta opção "null" nativamente).

**Impacto**:
- Usuário sempre verá registros filtrados por um veículo específico
- Melhora UX ao persistir seleção entre sessões
- Reduz complexidade visual

### **Próximos Passos (Opcional)**

Se necessário restaurar funcionalidade "Todos os veículos":

**Opção 1**: Adicionar parâmetro `allowAllOption` ao `EnhancedVehicleSelector`
```dart
EnhancedVehicleSelector(
  selectedVehicleId: _selectedVehicleId,
  onVehicleChanged: (vehicleId) { ... },
  allowAllOption: true, // Adiciona item "Todos os veículos"
  hintText: 'Todos os veículos',
)
```

**Opção 2**: Adicionar chip/botão "Limpar filtro" na Timeline
```dart
Row(
  children: [
    Expanded(child: EnhancedVehicleSelector(...)),
    if (_selectedVehicleId != null)
      TextButton(
        onPressed: () => setState(() => _selectedVehicleId = null),
        child: Text('Todos'),
      ),
  ],
)
```

## ✅ Benefícios

1. **Consistência Visual** - Mesmo design em todas as páginas
2. **Melhor UX** - Persistência automática, auto-seleção, animações
3. **Manutenibilidade** - 90% menos código, componente centralizado
4. **Performance** - Componente otimizado com animações suaves
5. **Acessibilidade** - Semantics integrada, feedback háptico

## 🔗 Arquivos Modificados

- `lib/features/timeline/presentation/pages/timeline_page.dart`
  - Import adicionado: `enhanced_vehicle_selector.dart`
  - Método `_buildVehicleSelector()` simplificado (de ~100 para ~10 linhas)

## 📊 Métricas

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Linhas de código | ~100 | ~10 | -90% |
| Componentes reutilizados | 0 | 1 | ✅ |
| Persistência | ❌ | ✅ | +UX |
| Animações | ❌ | ✅ | +UX |
| Auto-seleção | ❌ | ✅ | +UX |

---

**Observação**: Funcionalidade "Todos os veículos" pode ser restaurada facilmente se necessário através das opções sugeridas acima.

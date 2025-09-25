# Análise de Migração - shimmer ^3.0.0

## 📊 Executive Summary

**Classificação**: 🥉 **BAIXA PRIORIDADE**
**Complexidade**: 🟡 MÉDIA
**ROI**: 📉 BAIXO
**Recomendação**: ❌ **NÃO MIGRAR** (manter apps independentes)

### Justificativa da Decisão
- Apenas **2 de 6 apps** utilizam shimmer (33% de coverage)
- Uso misto: 1 app com shimmer real + 1 app com implementação custom
- Overhead de migração não justifica benefício limitado
- Loading states altamente específicos por contexto de domínio

## 🏢 Contexto do Monorepo

### Apps Analisados
| App | Usa shimmer? | Implementação | Complexidade |
|-----|--------------|---------------|--------------|
| **app-gasometer** | ✅ SIM | Shimmer.fromColors | Simples |
| **app-receituagro** | ⚠️ MISTO | Custom + Shimmer | Complexa |
| **app-plantis** | ❌ NÃO | - | - |
| **app_taskolist** | ❌ NÃO | - | - |
| **app-petiveti** | ❌ NÃO | - | - |
| **app-agrihurbi** | ❌ NÃO | - | - |

### Status Atual no core package
```yaml
# packages/core/pubspec.yaml
dependencies:
  # shimmer: NÃO ESTÁ PRESENTE
```

## 🔍 Análise Detalhada por App

### 1. app-gasometer: Uso Simples e Correto

**Arquivos que usam shimmer:**
- `lib/core/presentation/widgets/cached_image_widget.dart` (linha 5, 253)
- `lib/features/vehicles/presentation/pages/add_vehicle_page.dart` (linha 7)

**Padrão de uso:**
```dart
// Shimmer para placeholder de imagens
Shimmer.fromColors(
  baseColor: theme.colorScheme.surfaceContainerHighest,
  highlightColor: theme.colorScheme.surface,
  child: Container(...),
)
```

**Características:**
- ✅ Uso integrado ao design system
- ✅ Cores responsivas ao tema
- ✅ Performance otimizada
- ✅ Apenas para image loading placeholders

### 2. app-receituagro: Implementação Híbrida Problemática

**Arquivos analisados:**
- `lib/features/favoritos/widgets/enhanced_loading_states.dart` (linha 2, 15)
- `lib/features/defensivos/presentation/widgets/defensivos_loading_skeleton_widget.dart` (custom)
- `lib/features/pragas/widgets/pragas_loading_skeleton_widget.dart` (custom)
- `lib/features/culturas/widgets/loading_skeleton_widget.dart` (custom)

**Problema identificado: INCONSISTÊNCIA**
- ⚠️ **Favoritos**: Usa shimmer real (`Shimmer.fromColors`)
- ⚠️ **Defensivos/Pragas/Culturas**: Implementação custom com `AnimationController`

**Implementação Custom (Exemplo):**
```dart
// Pattern duplicado em 3+ widgets diferentes
class _DefensivosLoadingSkeletonWidgetState extends State<DefensivosLoadingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(...)
  }
  // ... código duplicado
}
```

## 🎯 Análise de Complexidade

### app-gasometer: Complexidade BAIXA
- **Uso**: Image loading placeholders apenas
- **Integração**: Bem integrado ao design system
- **Customização**: Mínima, usando cores do tema
- **Dependencies**: Apenas shimmer package

### app-receituagro: Complexidade ALTA
- **Uso**: Múltiplos contextos (favoritos, listas, grids)
- **Inconsistências**: 2 implementações diferentes no mesmo app
- **Código duplicado**: 3+ widgets com lógica shimmer similar
- **Customização**: Alta (cores dark/light, diferentes layouts)

## 💰 Análise de Custo-Benefício

### Custos da Migração
1. **Development Time**: ~8 horas
   - Migrar shimmer para core: 2h
   - Refatorar app-receituagro para consistência: 4h
   - Testes e validação: 2h

2. **Complexity Overhead**:
   - Configurações específicas por domínio
   - Multiple loading skeleton types needed
   - Theme integration complexa

3. **Maintenance Burden**:
   - API unificada para casos muito específicos
   - Backwards compatibility com implementations custom

### Benefícios da Migração
1. **Consistency**: 🔴 BAIXO (apenas 2 apps)
2. **Code Reuse**: 🔴 BAIXO (loading states são domain-specific)
3. **Maintenance**: 🔴 NEUTRO (shimmer é stable, pouca manutenção)

### ROI Calculation
- **Investment**: 8 horas development
- **Apps beneficiados**: 2 de 6 (33%)
- **Economia futura**: ~1 hora por ano
- **ROI**: 8 anos para break-even ❌

## 🔄 Comparação com Outras Migrações

| Package | Apps Affected | ROI | Status |
|---------|---------------|-----|--------|
| provider | 5/6 apps | ✅ ALTO | ✅ Migrado |
| go_router | 3/6 apps | ✅ MÉDIO | ⚠️ Em análise |
| flutter_svg | 4/6 apps | ✅ ALTO | ⚠️ Em análise |
| **shimmer** | **2/6 apps** | **❌ BAIXO** | **❌ Não migrar** |

## 🛠️ Alternativas Recomendadas

### Opção 1: Status Quo (RECOMENDADA)
- Manter shimmer nos apps individuais
- Padronizar apenas dentro do app-receituagro
- Foco em migrações de maior impacto

### Opção 2: Standardização Interna
```dart
// app-receituagro/lib/core/widgets/shimmer_factory.dart
class AppShimmerFactory {
  static Widget createListSkeleton({...}) => Shimmer.fromColors(...);
  static Widget createGridSkeleton({...}) => Shimmer.fromColors(...);
  // Unificar apenas dentro do app
}
```

### Opção 3: Future Consideration
- Aguardar mais apps utilizarem shimmer
- Reavaliar quando coverage > 50% (3+ apps)

## 🎯 Recomendação Final

### ❌ NÃO MIGRAR shimmer para packages/core

**Razões:**
1. **Baixo coverage**: Apenas 33% dos apps (2/6)
2. **ROI negativo**: 8 anos para break-even
3. **Domain-specific**: Loading states são muito específicos por contexto
4. **Prioridades**: Existem migrações mais impactantes pendentes

### ✅ Ações Recomendadas
1. **app-receituagro**: Padronizar internamente (usar shimmer real em todos widgets)
2. **app-gasometer**: Manter implementação atual (já está correta)
3. **Monitoring**: Reavaliar se mais apps adotarem shimmer

### 🔧 Quick Fix para app-receituagro
```dart
// Refatorar widgets custom para usar Shimmer.fromColors
// Eliminar code duplication
// Tempo estimado: 2 horas
```

## 📋 Implementation Guide (Se decidir prosseguir)

### Phase 1: Core Package Setup
```yaml
# packages/core/pubspec.yaml
dependencies:
  shimmer: ^3.0.0
```

### Phase 2: Shared Shimmer Service
```dart
// packages/core/lib/src/ui/shimmer_service.dart
class CoreShimmerService {
  static Widget imageLoading({required BuildContext context}) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(...),
    );
  }

  static Widget listSkeleton({
    required BuildContext context,
    int itemCount = 5,
    ViewMode mode = ViewMode.list,
  }) {
    // Implementation
  }
}
```

### Phase 3: Migration Steps
1. Add shimmer to core package
2. Create CoreShimmerService
3. Update app-gasometer imports
4. Refactor app-receituagro to use consistent implementation
5. Update both apps to use core service
6. Remove individual shimmer dependencies

**Estimated Time: 8 hours**

## 📊 Success Metrics

If migration proceeds (not recommended):
- ✅ Code duplication reduced by 70% in app-receituagro
- ✅ Consistent loading states across 2 apps
- ✅ Single source of shimmer configuration

## 🔍 Future Considerations

- **Trigger for Reevaluation**: When 3+ apps use shimmer
- **Alternative Strategy**: Focus on higher-impact migrations first
- **Long-term**: Consider Flutter's built-in loading patterns in future versions

## 📝 Related Documents

- [Migration Analysis Overview](package-migration-analysis.md)
- [Provider Migration (COMPLETED)](ok-migration-provider.md)
- [Go Router Migration Analysis](migration-go-router.md)
- [Flutter SVG Migration Analysis](migration-flutter-svg.md)

---
*Gerado em: 2025-09-25*
*Análise baseada em: shimmer ^3.0.0*
*Classificação: 🥉 BAIXA PRIORIDADE*
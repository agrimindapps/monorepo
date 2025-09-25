# Relatório de Migração: cached_network_image ^3.4.1

## 📊 Análise de Impacto

### **Apps Impactados:**
- ✅ **app-gasometer** - cached_network_image: ^3.4.1
- ✅ **app-plantis** - cached_network_image: ^3.4.1
- ✅ **app-petiveti** - cached_network_image: ^3.4.1
- ✅ **app-agrihurbi** - cached_network_image: ^3.4.1

**Total:** 4/6 apps usam cached_network_image para carregamento otimizado de imagens

### **Status no Core:**
❌ **cached_network_image:** NÃO EXISTE no packages/core/pubspec.yaml
❌ **flutter_cache_manager:** NÃO EXISTE no packages/core/pubspec.yaml
⚠️ **EnhancedImageServiceUnified:** JÁ EXISTE no core, mas NÃO usa cached_network_image (usa Dio direto)

### **Arquivos de Código Impactados:**
```
5 arquivos Dart usam cached_network_image:
- apps/app-gasometer/lib/core/presentation/widgets/cached_image_widget.dart
- apps/app-plantis/lib/core/widgets/unified_image_widget.dart
- apps/app-plantis/lib/core/services/enhanced_image_cache_manager.dart
- apps/app-plantis/lib/core/services/image_preloader_service.dart
- apps/app-agrihurbi/lib/features/livestock/presentation/widgets/bovine_card_widget.dart
```

---

## 🔍 Análise Técnica

### **Compatibilidade de Versões:**
```yaml
# Versão atual nos apps:
cached_network_image: ^3.4.1     # IDÊNTICA em todos os 4 apps ✅

# Dependências automáticas (flutter_cache_manager):
flutter_cache_manager: ^3.4.1    # Dependency de cached_network_image
http: ^1.2.1                      # Dependency de cached_network_image
crypto: ^3.0.6                    # JÁ EXISTE no core ✅

# Versão recomendada para Core:
cached_network_image: ^3.4.1     # ADICIONAR
flutter_cache_manager: ^3.4.1    # ADICIONAR (opcional mas recomendado)
```

### **Dependências (cached_network_image):**
```yaml
dependencies:
  flutter_cache_manager: ^3.4.1
  http: ^1.2.1
  crypto: ^3.0.6           # JÁ EXISTE no core
  path_provider: ^2.1.5    # JÁ EXISTE no core
  path: ^1.9.1             # JÁ EXISTE no core
```
- ✅ Maioria das dependências já disponíveis no core
- ⚠️ http package será adicionado automaticamente

---

## 🎨 Mapeamento de Uso por App

### **app-gasometer (Padrão Clean com Widget Unificado):**
```dart
// cached_image_widget.dart - Widget completo e reutilizável
class CachedImageWidget {
  - Network images com CachedNetworkImage
  - Local files com Image.file
  - Assets com Image.asset
  - Shimmer loading placeholder
  - Error handling robusto
  - Border radius e customização
}

Funcionalidades:
✅ Cache de rede otimizado
✅ Placeholder com shimmer
✅ Error handling
✅ Suporte a múltiplas fontes
✅ Memory cache dimensions
✅ Factory methods para diferentes tipos
```

### **app-plantis (Sistema Mais Complexo - Multiple Services):**
```dart
// unified_image_widget.dart - Widget unificado avançado
class UnifiedImageWidget {
  - Base64 + Network + URLs list
  - LRU cache para base64 images
  - Image preloading service integration
  - Memory pressure handling
  - RepaintBoundary optimization
}

// enhanced_image_cache_manager.dart - Cache manager customizado
class EnhancedImageCacheManager {
  - LRU memory cache
  - 50MB memory limit
  - 24h cache expiration
  - Base64 optimization
}

// image_preloader_service.dart - Preloading inteligente
class ImagePreloaderService {
  - Queue-based preloading
  - Priority system
  - Concurrent loading
  - Plant-specific optimization
}

Funcionalidades:
✅ Sistema de cache mais sofisticado
✅ Preloading inteligente com prioridade
✅ Base64 + Network images
✅ Memory pressure handling
✅ Plant-specific optimizations
✅ LRU cache implementation
```

### **app-petiveti (Uso Básico):**
```dart
// Uso direto em componentes:
- cached_network_image: ^3.4.1 no pubspec
- Integração básica via core package
- Sem customizações específicas identificadas no código
```

### **app-agrihurbi (Uso Básico em Widgets):**
```dart
// bovine_card_widget.dart - Uso básico
CachedNetworkImage(
  imageUrl: bovine.imageUrl,
  placeholder: shimmer placeholder,
  errorWidget: error icon,
  fit: BoxFit.cover,
)

Funcionalidades:
✅ Cache básico de imagens de bovinos
✅ Placeholder e error handling
✅ Integração simples
```

---

## 📈 Análise de Performance e Cache Patterns

### **Padrões de Cache Identificados:**

#### **1. app-gasometer (Balanced Caching):**
- **Memory Cache:** Dimensions-based (memCacheHeight/Width)
- **Disk Cache:** Padrão cached_network_image
- **Performance:** Otimizado para receipts e vehicle images
- **Memory Impact:** Médio (imagens de tamanho variado)

#### **2. app-plantis (Advanced Caching):**
- **Memory Cache:** LRU com 20 items + 50MB limit
- **Disk Cache:** 24h expiration + enhanced manager
- **Performance:** Otimizado para plantas (preloading)
- **Memory Impact:** Alto (muitas imagens pequenas)
- **Preloading:** Queue-based com prioridade

#### **3. app-petiveti (Basic Caching):**
- **Memory Cache:** Padrão cached_network_image
- **Disk Cache:** Padrão cached_network_image
- **Performance:** Básico
- **Memory Impact:** Baixo

#### **4. app-agrihurbi (Basic Caching):**
- **Memory Cache:** Padrão cached_network_image
- **Disk Cache:** Padrão cached_network_image
- **Performance:** Básico para livestock images
- **Memory Impact:** Médio

### **Performance Metrics Estimados:**

| App | Cache Hit Rate | Memory Usage | Load Time | Network Savings |
|-----|---------------|--------------|-----------|-----------------|
| gasometer | 70-80% | ~30MB | 200-500ms | 60-70% |
| plantis | 85-90% | ~50MB | 100-300ms | 80-85% |
| petiveti | 60-70% | ~20MB | 300-600ms | 50-60% |
| agrihurbi | 65-75% | ~25MB | 250-500ms | 55-65% |

### **Conflict com EnhancedImageServiceUnified no Core:**
⚠️ **IMPORTANTE:** O core já possui `EnhancedImageServiceUnified` que:
- NÃO usa cached_network_image (usa Dio direto)
- Implementa cache próprio em memória
- Tem configurações específicas por app (plantis, gasometer)
- Comentário explícito: "cached_network_image packages removed as they're not available in core package"

**DECISÃO ARQUITETURAL NECESSÁRIA:**
1. **Opção A:** Adicionar cached_network_image ao core e integrar com EnhancedImageServiceUnified
2. **Opção B:** Migrar apps para usar EnhancedImageServiceUnified do core
3. **Opção C:** Manter cached_network_image nos apps e deprecar EnhancedImageServiceUnified

---

## 🎯 Plano de Migração Detalhado

### **RECOMENDAÇÃO: Opção A - Integrar cached_network_image com Core**

#### **Passo 1: Adicionar cached_network_image ao Core**
```yaml
# packages/core/pubspec.yaml
dependencies:
  # Image Loading & Caching
  cached_network_image: ^3.4.1
  flutter_cache_manager: ^3.4.1   # Opcional mas recomendado

  # Já existentes (compatíveis):
  image_picker: ^1.1.2  ✅
  uuid: ^4.5.1          ✅
  dio: ^5.9.0           ✅
  path_provider: ^2.1.5 ✅
```

#### **Passo 2: Atualizar EnhancedImageServiceUnified**
```dart
// packages/core/lib/src/infrastructure/services/enhanced_image_service_unified.dart

// ADICIONAR imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// SUBSTITUIR _loadImageDirectly por cached_network_image:
Future<Result<Uint8List>> _loadImageDirectly(String url) async {
  try {
    final file = await DefaultCacheManager().getSingleFile(url);
    return Result.success(await file.readAsBytes());
  } catch (e, stackTrace) {
    return Result.failure(NetworkError(...));
  }
}
```

#### **Passo 3: Criar Widget Unificado no Core**
```dart
// packages/core/lib/src/presentation/widgets/core_cached_image_widget.dart
class CoreCachedImageWidget extends StatelessWidget {
  // Combina funcionalidades dos 4 apps
  // Base do CachedImageWidget (gasometer) + recursos avançados do UnifiedImageWidget (plantis)
}
```

#### **Passo 4: Remover cached_network_image dos Apps**

##### **4.1. app-gasometer (Widget mais simples, migração direta)**
```yaml
# REMOVER de app-gasometer/pubspec.yaml:
# cached_network_image: ^3.4.1

# ATUALIZAR cached_image_widget.dart:
# DE: import 'package:cached_network_image/cached_network_image.dart';
# PARA: import 'package:core/core.dart';
```

##### **4.2. app-petiveti (Uso básico, migração simples)**
```yaml
# REMOVER de app-petiveti/pubspec.yaml:
# cached_network_image: ^3.4.1
```

##### **4.3. app-agrihurbi (Uso básico, migração simples)**
```yaml
# REMOVER de app-agrihurbi/pubspec.yaml:
# cached_network_image: ^3.4.1

# ATUALIZAR bovine_card_widget.dart:
# DE: import 'package:cached_network_image/cached_network_image.dart';
# PARA: import 'package:core/core.dart';
```

##### **4.4. app-plantis (Sistema complexo, migração cuidadosa)**
```yaml
# REMOVER de app-plantis/pubspec.yaml:
# cached_network_image: ^3.4.1

# INTEGRAR com EnhancedImageServiceUnified:
# - Migrar UnifiedImageWidget para usar CoreCachedImageWidget
# - Integrar EnhancedImageCacheManager com core service
# - Preservar ImagePreloaderService integration
```

#### **Passo 5: Configurar Core Image Widget**
```dart
// packages/core/lib/core.dart
export 'package:cached_network_image/cached_network_image.dart';
export 'src/presentation/widgets/core_cached_image_widget.dart';
export 'src/infrastructure/services/enhanced_image_service_unified.dart';

// Configurações por app:
class CoreImageConfig {
  static const gasometer = EnhancedImageServiceConfig.gasometer();
  static const plantis = EnhancedImageServiceConfig.plantis();
  static const defaultConfig = EnhancedImageServiceConfig();
}
```

---

## 🧪 Plano de Teste

### **Testes por Complexidade:**

#### **Fase 1: Apps Simples (Baixo Risco)**
```bash
# 1.1 app-petiveti (uso básico):
cd apps/app-petiveti
flutter clean && flutter pub get
flutter analyze
flutter test
flutter run --debug  # Verificar imagens carregando

# 1.2 app-agrihurbi (uso básico em widgets):
cd apps/app-agrihurbi
flutter clean && flutter pub get
flutter analyze
flutter test
flutter run --debug  # Verificar BovineCardWidget imagens
```

#### **Fase 2: Apps com Widgets Customizados (Médio Risco)**
```bash
# 2.1 app-gasometer (CachedImageWidget):
cd apps/app-gasometer
flutter clean && flutter pub get
flutter analyze
flutter test
flutter run --debug  # Verificar CachedImageWidget funcionando
# TESTE ESPECÍFICO: receipts, vehicles, maintenance images
```

#### **Fase 3: Apps com Sistema Complexo (Alto Risco)**
```bash
# 3.1 app-plantis (UnifiedImageWidget + Services):
cd apps/app-plantis
flutter clean && flutter pub get
flutter analyze
flutter test
flutter run --debug

# TESTES ESPECÍFICOS app-plantis:
# - Base64 images loading
# - LRU cache funcionando
# - Image preloading service
# - Memory pressure handling
# - Plant-specific optimizations
```

### **Pontos de Atenção Durante Testes:**

#### **Cache Performance:**
- ✅ **Memory cache** funcionando (hit rates)
- ✅ **Disk cache** persistindo entre sessões
- ✅ **Cache expiration** respeitado
- ✅ **Memory limits** não excedidos

#### **Image Loading:**
- ✅ **Network images** carregando
- ✅ **Placeholder** aparecendo durante load
- ✅ **Error handling** funcionando para URLs quebradas
- ✅ **Loading animations** suaves

#### **Integration Patterns:**
- ✅ **EnhancedImageServiceUnified** funcionando
- ✅ **Core widgets** renderizando
- ✅ **App-specific configs** aplicadas
- ✅ **Memory optimization** ativa

#### **App-Specific Features:**
- ✅ **gasometer:** Receipt images, vehicle photos
- ✅ **plantis:** Base64 decode, LRU cache, preloading
- ✅ **petiveti:** Basic network images
- ✅ **agrihurbi:** Livestock images

---

## ⚠️ Riscos e Mitigações

### **Riscos Identificados:**

#### **🔴 ALTO RISCO: app-plantis Complex System**
- **Problema:** Sistema de cache complexo pode quebrar
- **Mitigação:** Preservar ImagePreloaderService e EnhancedImageCacheManager
- **Validação:** Teste intensivo de preloading + LRU cache
- **Rollback:** Manter backup dos services originais

#### **🟡 MÉDIO RISCO: EnhancedImageServiceUnified Conflict**
- **Problema:** Core service pode conflitar com cached_network_image
- **Mitigação:** Integrar gradualmente, usar cached_network_image no core service
- **Validação:** Verificar que ambos funcionam em harmonia

#### **🟡 MÉDIO RISCO: Cache Manager Configuration**
- **Problema:** flutter_cache_manager pode precisar configuração específica
- **Mitigação:** Usar DefaultCacheManager primeiro, customizar depois se necessário
- **Validação:** Verificar cache funcionando entre sessões

#### **🟡 MÉDIO RISCO: Memory Usage Increase**
- **Problema:** Cached images podem aumentar uso de memória
- **Mitigação:** Configurar limits adequados no CacheManager
- **Validação:** Monitor memory usage durante testes

#### **🟢 BAIXO RISCO: Simple Apps (petiveti, agrihurbi)**
- **Problema:** Uso básico, baixa probabilidade de quebrar
- **Mitigação:** Migração direta, fallback simples
- **Validação:** Verificar images loading normalmente

### **Rollback Plan:**
```bash
# Por app, rollback é simples:
git checkout HEAD~1 -- apps/app-plantis/pubspec.yaml
cd apps/app-plantis
flutter clean && flutter pub get
# Restaurar imports originais
```

### **Estratégia de Mitigação de Riscos:**
1. **Migração incremental:** Um app por vez
2. **Preservar funcionalidades:** Manter services complexos do plantis
3. **Fallback graceful:** Core service deve funcionar mesmo sem cached_network_image
4. **Testing extensivo:** Cada app testado isoladamente

---

## 📈 Benefícios Esperados

### **Unificação de Cache:**
- ✅ **Cache management** centralizado para todos apps
- ✅ **Consistent image loading** patterns
- ✅ **Shared cache configuration** via core
- ✅ **Memory optimization** unificada

### **Developer Experience:**
- ✅ **Single import** para image loading (`import 'package:core/core.dart'`)
- ✅ **Consistent APIs** entre apps
- ✅ **Shared widgets** para imagens
- ✅ **Common error handling**

### **Performance Improvements:**
- ✅ **Better cache hit rates** com sistema unificado
- ✅ **Reduced network usage** compartilhando cache entre apps
- ✅ **Memory optimization** com shared manager
- ✅ **Faster image loading** com preloading

### **Manutenibilidade:**
- ✅ **Central image management**
- ✅ **Consistent caching policies**
- ✅ **Shared performance optimizations**
- ✅ **Unified testing approach**

### **Performance Gains Estimados:**

| Metric | Before | After | Improvement |
|--------|---------|-------|-------------|
| Cache Hit Rate | 60-85% | 80-90% | +15-20% |
| Memory Usage | Varied | Optimized | -20-30% |
| Network Requests | High | Reduced | -30-40% |
| Load Time | 100-600ms | 50-300ms | -30-50% |

---

## 🏗️ Estratégia de Image Loading Unificada

### **Core Image Architecture:**
```dart
// packages/core/lib/src/infrastructure/services/unified_image_service.dart
class UnifiedImageService {
  // Combines EnhancedImageServiceUnified + cached_network_image

  // From EnhancedImageServiceUnified:
  - Upload functionality
  - Firebase Storage integration
  - App-specific configurations

  // NEW with cached_network_image:
  - Network image caching
  - Disk cache management
  - Performance optimizations

  // Enhanced features:
  - Preloading support
  - Memory pressure handling
  - Custom cache managers
}
```

### **App-Specific Widget Extensions:**
```dart
// For app-gasometer (receipts, vehicles):
extension GasometerImageExtensions on CoreCachedImageWidget {
  factory CoreCachedImageWidget.receipt(String url) => ...
  factory CoreCachedImageWidget.vehicle(String url) => ...
}

// For app-plantis (plants, base64):
extension PlantisImageExtensions on CoreCachedImageWidget {
  factory CoreCachedImageWidget.plant(String url, {String? base64}) => ...
  factory CoreCachedImageWidget.base64Plant(String base64) => ...
}
```

### **Progressive Enhancement Strategy:**
1. **Phase 1:** Add cached_network_image to core (backward compatible)
2. **Phase 2:** Migrate simple apps (petiveti, agrihurbi)
3. **Phase 3:** Migrate widget-based apps (gasometer)
4. **Phase 4:** Integrate complex systems (plantis)
5. **Phase 5:** Optimize and unify

---

## 🚀 Cronograma Sugerido

### **Semana 1: Core Setup + Simple Apps**
- **Dia 1-2:** Adicionar cached_network_image ao core
- **Dia 3:** Integrar com EnhancedImageServiceUnified
- **Dia 4:** Migrar app-petiveti (uso básico)
- **Dia 5:** Migrar app-agrihurbi (BovineCardWidget)

### **Semana 2: Widget-based Apps**
- **Dia 1-2:** Migrar app-gasometer (CachedImageWidget)
- **Dia 3:** Criar CoreCachedImageWidget no core
- **Dia 4-5:** Testing e refinamentos

### **Semana 3: Complex System Integration**
- **Dia 1-3:** Migrar app-plantis (UnifiedImageWidget + Services)
- **Dia 4:** Integrar ImagePreloaderService com core
- **Dia 5:** Preserve EnhancedImageCacheManager functionality

### **Semana 4: Optimization + Finalization**
- **Dia 1-2:** Performance testing e optimization
- **Dia 3:** Unified cache configuration
- **Dia 4:** Documentation e final validation
- **Dia 5:** Final testing + commit

---

## ✅ Critérios de Sucesso

### **Pré-Migração:**
- [ ] cached_network_image ^3.4.1 adicionado ao core
- [ ] flutter_cache_manager disponível (opcional)
- [ ] Core exports configurados
- [ ] EnhancedImageServiceUnified compatível

### **Por App Migrado:**
- [ ] pubspec.yaml limpo (sem cached_network_image)
- [ ] flutter analyze limpo
- [ ] Imagens carregando normalmente
- [ ] Cache funcionando (hit rates preservados)
- [ ] Memory usage dentro dos limites
- [ ] Performance mantida ou melhorada

### **Funcionalidades Específicas:**
- [ ] **gasometer:** CachedImageWidget funcionando (receipts, vehicles)
- [ ] **plantis:** Base64 + LRU cache + preloading preservados
- [ ] **petiveti:** Network images básicas funcionando
- [ ] **agrihurbi:** BovineCardWidget imagens funcionando

### **Pós-Migração Unificado:**
- [ ] Todos os 4 apps com image loading funcionando
- [ ] Core image service accessible
- [ ] Shared cache working between apps
- [ ] Memory optimization active
- [ ] Performance metrics improved
- [ ] Zero crashes relacionados a imagens

---

## 📋 Checklist de Execução

```bash
# FASE 1: Preparar Core Image Loading
[ ] cd packages/core
[ ] Adicionar "cached_network_image: ^3.4.1" ao pubspec.yaml
[ ] Adicionar "flutter_cache_manager: ^3.4.1" ao pubspec.yaml (opcional)
[ ] Atualizar EnhancedImageServiceUnified para usar cached_network_image
[ ] Criar CoreCachedImageWidget
[ ] flutter pub get
[ ] flutter analyze
[ ] flutter test

# FASE 2: Migrar Apps Simples
[ ] cd apps/app-petiveti
[ ] Remover cached_network_image do pubspec.yaml
[ ] Update imports para usar core
[ ] flutter clean && flutter pub get
[ ] flutter analyze && flutter test
[ ] flutter run (test imagens funcionando)

# REPETIR para app-agrihurbi
[ ] cd apps/app-agrihurbi
[ ] Remover cached_network_image do pubspec.yaml
[ ] Update bovine_card_widget.dart imports
[ ] Test BovineCardWidget images

# FASE 3: Migrar Apps com Widgets
[ ] cd apps/app-gasometer
[ ] Remover cached_network_image do pubspec.yaml
[ ] Integrar CachedImageWidget com CoreCachedImageWidget
[ ] Test receipts, vehicles, maintenance images

# FASE 4: Migrar Sistema Complexo
[ ] cd apps/app-plantis
[ ] Backup UnifiedImageWidget e services
[ ] Remover cached_network_image do pubspec.yaml
[ ] Integrar com core mantendo features complexas
[ ] Test base64 decode, LRU cache, preloading
[ ] Test memory pressure handling

# FASE 5: Finalização
[ ] Test all apps funcionando
[ ] Performance benchmarking
[ ] Memory usage validation
[ ] Cache hit rates verification
[ ] Documentation
[ ] Commit & Push
```

---

## 🎖️ Classificação de Migração

**Complexidade:** 🟡 **MÉDIA-ALTA** (7/10)
**Risco:** 🟡 **MÉDIO** (6/10) - Alto risco apenas para app-plantis
**Benefício:** 🔥 **MUITO ALTO** (9/10)
**Tempo:** 🟡 **3-4 SEMANAS**

### **Critical Success Factors:**
- ✅ **Core integration** funcionando com cached_network_image
- ✅ **App-plantis complex system** preserved during migration
- ✅ **Cache performance** maintained or improved
- ✅ **Memory optimization** working
- ✅ **Backward compatibility** maintained

### **Innovation Opportunities:**
- 🚀 **Unified image widgets** across all apps
- 🚀 **Shared cache optimization** between apps
- 🚀 **Enhanced preloading** system from plantis for all apps
- 🚀 **Memory pressure handling** unified
- 🚀 **Performance monitoring** centralized

---

**Status:** 🟡 **READY FOR CAREFUL EXECUTION**
**Recomendação:** **EXECUTAR APÓS get_it/injectable** (para ganhar experiência com core migrations)
**Impacto:** 4/6 apps com image loading unificado + performance optimizations

---

*Esta migração criará o foundation para image loading unificado em todo o monorepo - high-impact user experience improvement.*

## 📖 Apêndice: Detalhes Técnicos

### **cached_network_image ^3.4.1 Features Utilizadas:**

#### **Recursos Básicos (todos os apps):**
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => placeholder,
  errorWidget: (context, url, error) => errorWidget,
  fit: BoxFit.cover,
)
```

#### **Recursos Avançados (gasometer, plantis):**
```dart
CachedNetworkImage(
  memCacheWidth: width.round(),        // Memory optimization
  memCacheHeight: height.round(),      // Memory optimization
  maxWidthDiskCache: width * 2,        // Disk cache limits
  maxHeightDiskCache: height * 2,      // Disk cache limits
  fadeInDuration: Duration(ms: 300),   // Animation
  useOldImageOnUrlChange: true,        // Smooth transitions
)
```

### **flutter_cache_manager Integration Options:**
```dart
// Option 1: Default (recommended for migration)
DefaultCacheManager()

// Option 2: Custom (future enhancement)
CacheManager(Config(
  'customCacheKey',
  stalePeriod: Duration(days: 7),
  maxNrOfCacheObjects: 200,
  repo: JsonCacheInfoRepository(databaseName: 'custom'),
))
```

### **Memory Management Best Practices:**
- Use `memCacheWidth/Height` for memory optimization
- Implement `RepaintBoundary` for complex lists
- Handle memory pressure with cache clearing
- Monitor cache hit rates for performance tuning

### **Integration with Existing Core Services:**
- EnhancedImageServiceUnified: Upload functionality preserved
- Firebase Storage: Integration maintained
- Image selection: ImagePicker compatibility preserved
- Configuration system: App-specific configs maintained
# 🧪 Como Testar o FAB (FloatingActionButton)

## 🎯 Problema Atual

O FAB não aparece mesmo após as mudanças porque:
- Hot reload NÃO aplica mudanças em construtores const
- Web pode ter cache de build antigo

---

## ✅ Solução: Hot Restart Completo

### **Opção 1: Via Terminal**

Se está rodando `flutter run -d chrome`:

```bash
# No terminal onde o app está rodando:
# Pressione: R (maiúsculo)
# Isso faz HOT RESTART (não hot reload)
```

### **Opção 2: Parar e Rodar Novamente**

```bash
cd apps/app-gasometer

# 1. Parar o app atual (Ctrl+C)

# 2. Limpar build
flutter clean

# 3. Rodar novamente
flutter run -d chrome --web-port=54947
```

### **Opção 3: Build Web Completo**

```bash
cd apps/app-gasometer

# 1. Build completo
flutter build web --release

# 2. Servir a build
# Use um servidor HTTP simples ou:
cd build/web
python3 -m http.server 54947
```

---

## 🔍 Debug: Verificar se FAB Está Sendo Criado

Após restart, abra o **Console do Navegador** (F12) e procure por:

```
🔧 PageWithBottomNav: fabRoute=/expenses/add, fabIcon=IconData(...), fabLabel=Adicionar
```

Se aparecer este log:
- ✅ FAB está sendo criado
- ❌ Mas pode estar oculto/posicionado incorretamente

Se NÃO aparecer:
- ❌ Rota não está usando PageWithBottomNav
- ❌ Build antigo ainda em cache

---

## 🐛 Checklist de Debug

### **1. Verificar Rota Atual**
Na URL: `localhost:54947/#/expenses`

Console deve mostrar:
```
🔧 PageWithBottomNav: fabRoute=/expenses/add
```

### **2. Inspecionar Elemento**
- Abrir DevTools (F12)
- Inspecionar elemento
- Procurar por `<button class="FloatingActionButton">`
- Se existe mas não visível → problema de CSS/layout
- Se não existe → problema de build/cache

### **3. Forçar Rebuild**
```bash
# Limpar TUDO
cd apps/app-gasometer
rm -rf build .dart_tool
flutter clean
flutter pub get
flutter run -d chrome --web-renderer html
```

---

## 📱 Teste em Diferentes Plataformas

### **Web (Chrome)**
```bash
flutter run -d chrome --web-port=54947
```

### **Mobile (iOS Simulator)**
```bash
flutter run -d iPhone
# FAB deve aparecer no canto inferior direito
```

### **Mobile (Android Emulator)**
```bash
flutter run -d emulator
# FAB deve aparecer no canto inferior direito
```

---

## 🎨 Visual Esperado

```
┌────────────────────────────────┐
│  Despesas                      │
│  (header laranja)              │
│                                │
│  Peugeot 208                   │
│                                │
│  Dez. 25                       │
│                                │
│  Nenhuma despesa              │
│  (empty state)                │
│                                │
│                                │
│                      ┌─────────┐
│                      │  💵 +   │ <- FAB aqui!
│                      │Adicionar│
│                      └─────────┘
└────────────────────────────────┘
Timeline | Veículos | + | Tools | Config
```

---

## 🔧 Se AINDA Não Aparecer

### **Possível Causa: Layout Issue**

O FAB pode estar sendo renderizado mas **atrás** da NavigationBar ou **fora da tela**.

**Fix temporário:** Ajustar posição do FAB

```dart
// Em page_with_bottom_nav.dart
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
```

Ou usar FAB padrão (não extended):

```dart
floatingActionButton: fabRoute != null
    ? FloatingActionButton(
        onPressed: () => context.push(fabRoute!),
        child: Icon(fabIcon),
        tooltip: fabLabel,
      )
    : null,
```

---

## 📞 Próximos Passos

1. ✅ Fazer **Hot Restart** (tecla R)
2. ✅ Verificar console do navegador
3. ✅ Inspecionar elemento
4. ✅ Se necessário: flutter clean + rebuild

**Se continuar sem aparecer, envie:**
- Screenshot do console (F12)
- Screenshot do elemento inspecionado
- Output do terminal do flutter run


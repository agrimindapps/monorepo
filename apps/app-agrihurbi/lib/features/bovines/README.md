# 🐄 Bovines Module - Raças de Bovinos

## 📋 Descrição

Módulo dedicado ao cadastro e gerenciamento de **raças de bovinos** no AgriHurbi.

**NÃO confundir com cotações de gado!** (isso está em `features/markets/`)

## 🎯 Funcionalidades

- ✅ Cadastro de raças bovinas (Nelore, Angus, Holandês, Gir, etc)
- ✅ Informações zootécnicas detalhadas
- ✅ Características físicas e genéticas
- ✅ Aptidões (corte, leite, mista)
- ✅ Sistema de criação (extensivo, intensivo, semi-intensivo)
- ✅ Galeria de imagens
- ✅ Admin-only CRUD

## 🏗️ Arquitetura

Este módulo **reutiliza** a estrutura compartilhada de `features/livestock/`:

```
bovines/
├── domain/
│   └── entities/          # Re-exports de livestock entities
├── presentation/
│   ├── pages/             # Páginas específicas de bovinos
│   └── providers/         # Providers específicos
└── README.md
```

## 🔐 Permissões

### Firestore Rules:
```javascript
match /bovinos/{bovineId} {
  allow read: if true;  // Leitura pública
  allow write: if isAdmin();  // Escrita apenas admin
}
```

### Rotas:
- **Admin**: `/admin/bovines` (CRUD completo)
- **Público**: Futuramente no site web (somente leitura)

## 📊 Entidades

### BovineEntity
Herda de `AnimalBaseEntity` (livestock shared) e adiciona:
- `animalType`: Tipo específico
- `origin`: Origem detalhada
- `characteristics`: Características físicas
- `breed`: Raça específica
- `aptitude`: Aptidão (leiteira, corte, mista)
- `breedingSystem`: Sistema de criação
- `purpose`: Finalidade
- `tags`: Tags categorizadas
- `notes`: Observações

## 🚀 Uso

```dart
// Import do módulo
import 'package:app_agrihurbi/features/bovines/bovines.dart';

// Navegar para listagem
context.go('/admin/bovines');

// Provider
ref.watch(bovinesProvider);
```

## 📝 Relacionamento com Outros Módulos

- **livestock**: Compartilha entities, repositories, datasources
- **admin**: Protegido por AdminGuard
- **markets**: Independente (markets = cotações, bovines = raças)

## 🎨 Exemplo de Dados

```json
{
  "id": "nelore_001",
  "registrationId": "NEL-2024-001",
  "commonName": "Nelore",
  "originCountry": "Brasil (Índia originalmente)",
  "animalType": "Zebuíno",
  "origin": "Originário da Índia, adaptado ao Brasil",
  "breed": "Nelore",
  "aptitude": "Corte",
  "breedingSystem": "Extensivo",
  "characteristics": "Pelagem cinza claro, cupim proeminente, orelhas longas",
  "purpose": "Produção de carne em clima tropical",
  "tags": ["zebu", "corte", "tropical", "resistente"],
  "imageUrls": ["https://..."],
  "isActive": true
}
```

## 📚 Documentação Adicional

- [Livestock Shared Module](../livestock/README.md)
- [Admin Security](../../ADMIN_SECURITY.md)
- [Firestore Rules](../../firestore.rules)

# 🐴 Equines Module - Raças de Equinos

## 📋 Descrição

Módulo dedicado ao cadastro e gerenciamento de **raças de equinos** no AgriHurbi.

## 🎯 Funcionalidades

- ✅ Cadastro de raças equinas (Mangalarga, Quarto de Milha, Crioulo, etc)
- ✅ Informações zootécnicas detalhadas
- ✅ Características físicas e temperamento
- ✅ Pelagem e coloração
- ✅ Uso principal (montaria, esporte, trabalho, reprodução)
- ✅ Influências genéticas
- ✅ Galeria de imagens
- ✅ Admin-only CRUD

## 🏗️ Arquitetura

Este módulo **reutiliza** a estrutura compartilhada de `features/livestock/`:

```
equines/
├── domain/
│   └── entities/          # Re-exports de livestock entities
├── presentation/
│   ├── pages/             # Páginas específicas de equinos
│   └── providers/         # Providers específicos
└── README.md
```

## 🔐 Permissões

### Firestore Rules:
```javascript
match /equinos/{equineId} {
  allow read: if true;  // Leitura pública
  allow write: if isAdmin();  // Escrita apenas admin
}
```

### Rotas:
- **Admin**: `/admin/equines` (CRUD completo)
- **Público**: Futuramente no site web (somente leitura)

## 📊 Entidades

### EquineEntity
Herda de `AnimalBaseEntity` (livestock shared) e adiciona:
- `history`: História da raça
- `temperament`: Temperamento (calmo, vivaz, dócil, energético)
- `coat`: Pelagem (baio, alazão, preto, tordilho, etc)
- `primaryUse`: Uso principal (montaria, esporte, trabalho, reprodução, lazer)
- `geneticInfluences`: Influências genéticas
- `height`: Altura física
- `weight`: Peso médio

## 🚀 Uso

```dart
// Import do módulo
import 'package:app_agrihurbi/features/equines/equines.dart';

// Navegar para listagem
context.go('/admin/equines');

// Provider
ref.watch(equinesProvider);
```

## 📝 Relacionamento com Outros Módulos

- **livestock**: Compartilha entities, repositories, datasources
- **admin**: Protegido por AdminGuard
- **bovines**: Módulo irmão (ambos usam livestock shared)

## 🎨 Exemplo de Dados

```json
{
  "id": "mangalarga_001",
  "registrationId": "MAN-2024-001",
  "commonName": "Mangalarga Marchador",
  "originCountry": "Brasil",
  "history": "Raça genuinamente brasileira originada no sul de Minas Gerais",
  "temperament": "Dócil",
  "coat": "Baio",
  "primaryUse": "Montaria",
  "geneticInfluences": "Alter Real, Andaluz",
  "height": "1.52m",
  "weight": "450kg",
  "imageUrls": ["https://..."],
  "isActive": true
}
```

## 📚 Documentação Adicional

- [Livestock Shared Module](../livestock/README.md)
- [Admin Security](../../ADMIN_SECURITY.md)
- [Firestore Rules](../../firestore.rules)

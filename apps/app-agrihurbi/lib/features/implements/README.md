# 🚜 Implements Module - Implementos Agrícolas

## 📋 Descrição

Módulo dedicado ao cadastro e gerenciamento de **implementos agrícolas** no AgriHurbi.

**Status**: 🚧 Em construção - Aguardando definição de campos

## 🎯 Funcionalidades Planejadas

- [ ] Cadastro de implementos agrícolas
- [ ] Categorização por tipo de operação
- [ ] Especificações técnicas
- [ ] Fabricantes e modelos
- [ ] Galeria de imagens
- [ ] Admin-only CRUD
- [ ] Leitura pública (site web)

## 🏗️ Arquitetura

```
implements/
├── domain/
│   ├── entities/
│   │   └── implement_entity.dart (TODO)
│   └── repositories/
│       └── implement_repository.dart (TODO)
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── presentation/
│   ├── pages/
│   │   ├── implements_list_page.dart (scaffold)
│   │   ├── implement_form_page.dart (TODO)
│   │   └── implement_detail_page.dart (TODO)
│   ├── providers/
│   └── widgets/
└── README.md
```

## 📊 Categorias Sugeridas

### 1. Preparo de Solo
- Grade aradora
- Grade niveladora
- Arado de disco
- Arado de aiveca
- Subsolador
- Escarificador

### 2. Plantio
- Plantadeira pneumática
- Plantadeira mecânica
- Semeadora a lanço
- Transplantadora

### 3. Tratos Culturais
- Pulverizador (costal, tratorizado, autopropelido)
- Cultivador
- Roçadeira
- Adubador
- Distribuidor de calcário

### 4. Colheita
- Colhedora de grãos
- Colhedora de cana
- Colhedora de café
- Colhedora de algodão

### 5. Outros
- Carreta agrícola
- Distribuidor de esterco
- Ensiladeira
- Picador de forr agem

## 📝 Campos Propostos (A Definir)

```dart
// TODO: Definir campos específicos
class ImplementEntity {
  final String id;
  final String nome;
  final ImplementCategory categoria;
  final ImplementType tipo;
  final String fabricante;
  final String modelo;
  final double? larguraTrabalho;  // metros
  final double? potenciaRequerida;  // cv/hp
  final double? pesoAproximado;  // kg
  final String? capacidade;  // ex: "5000L", "10 linhas"
  final String aplicacao;
  final List<String> caracteristicas;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

## 🔐 Permissões

### Firestore Rules:
```javascript
match /implementos/{implementId} {
  allow read: if true;  // Leitura pública
  allow write: if isAdmin();  // Escrita apenas admin
}
```

### Rotas:
- **Admin**: `/admin/implements` (CRUD completo)
- **Público**: Futuramente no site web (somente leitura)

## 🚀 Próximos Passos

1. ✅ Estrutura de pastas criada
2. ⏳ Definir campos da entidade ImplementEntity
3. ⏳ Criar enums (ImplementCategory, ImplementType)
4. ⏳ Implementar repository pattern
5. ⏳ Criar datasources (Firestore + Drift local)
6. ⏳ Desenvolver páginas de CRUD
7. ⏳ Adicionar providers Riverpod
8. ⏳ Integrar com rotas admin
9. ⏳ Testes e validação

## 📚 Documentação Adicional

- [Admin Security](../../ADMIN_SECURITY.md)
- [Firestore Rules](../../firestore.rules)
- [Bovines Module](../bovines/README.md) (referência de estrutura)

---

**Status**: 🟡 Aguardando definição de campos e requisitos  
**Prioridade**: Média  
**Responsável**: A definir

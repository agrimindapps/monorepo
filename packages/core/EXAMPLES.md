# Core Package - Exemplos de Uso

## 📦 Novos Pacotes Disponíveis

### icons_plus
Acesso a múltiplas bibliotecas de ícones (Bootstrap, BoxIcons, FontAwesome, IonIcons, etc.)

### carousel_slider
Widget de carrossel/slider para imagens e conteúdo

---

## 🎨 CoreIcons - Helper de Ícones

### Uso Básico

```dart
import 'package:core/core.dart';

// Bootstrap Icons
Icon(CoreIcons.bsShield)
Icon(CoreIcons.bsHeart)
Icon(CoreIcons.bsComment)

// BoxIcons
Icon(CoreIcons.boxShield)
Icon(CoreIcons.boxBug)

// FontAwesome Solid
Icon(CoreIcons.faShield)
Icon(CoreIcons.faHeart)

// FontAwesome Brand (logos)
Icon(CoreIcons.faApple)
Icon(CoreIcons.faGoogle)
Icon(CoreIcons.faWhatsapp)

// IonIcons
Icon(CoreIcons.ionShield)
Icon(CoreIcons.ionHeart)

// LineAwesome
Icon(CoreIcons.lineShield)
Icon(CoreIcons.lineHeart)

// EvaIcons
Icon(CoreIcons.evaShield)
Icon(CoreIcons.evaHeart)
```

### Exemplo Completo

```dart
Widget _buildIconButton() {
  return IconButton(
    icon: Icon(CoreIcons.bsShield),
    color: Colors.blue,
    iconSize: 32,
    onPressed: () {
      // Handle tap
    },
  );
}
```

---

## 🎠 CoreCarouselWidget - Carrossel Simples

### Uso Básico

```dart
import 'package:core/core.dart';

CoreCarouselWidget(
  items: [
    Image.network('https://example.com/image1.jpg'),
    Image.network('https://example.com/image2.jpg'),
    Image.network('https://example.com/image3.jpg'),
  ],
  height: 200,
  autoPlay: true,
  enlargeCenterPage: true,
)
```

### Com Configurações Customizadas

```dart
CoreCarouselWidget(
  items: myWidgetList,
  height: 300,
  viewportFraction: 0.9,
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 5),
  enlargeCenterPage: true,
  onPageChanged: (index, reason) {
    print('Page changed to: $index');
  },
)
```

---

## 🎨 CoreCarouselBuilder - Carrossel Dinâmico

### Uso com Builder

```dart
final List<String> images = [
  'assets/img1.jpg',
  'assets/img2.jpg',
  'assets/img3.jpg',
];

CoreCarouselBuilder(
  itemCount: images.length,
  itemBuilder: (context, index, realIndex) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(images[index]),
          fit: BoxFit.cover,
        ),
      ),
    );
  },
  height: 250,
  autoPlay: true,
)
```

### Com Controle Manual

```dart
class MyCarouselWidget extends StatefulWidget {
  @override
  State<MyCarouselWidget> createState() => _MyCarouselWidgetState();
}

class _MyCarouselWidgetState extends State<MyCarouselWidget> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CoreCarouselWidget(
          items: myItems,
          controller: _controller,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),

        // Botões de controle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _controller.previousPage(),
            ),
            Text('${_currentIndex + 1} / ${myItems.length}'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => _controller.nextPage(),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## 📱 Exemplo Completo - Galeria de Produtos

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ProductGallery extends StatelessWidget {
  final List<Product> products;

  const ProductGallery({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título com ícone
        Row(
          children: [
            Icon(CoreIcons.bsHeart, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Produtos em Destaque',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Carrossel de produtos
        CoreCarouselBuilder(
          itemCount: products.length,
          itemBuilder: (context, index, realIndex) {
            final product = products[index];
            return _buildProductCard(product);
          },
          height: 300,
          viewportFraction: 0.85,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(CoreIcons.faShield, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Bibliotecas de Ícones Disponíveis

| Biblioteca | Prefixo | Exemplo |
|------------|---------|---------|
| Bootstrap Icons | `bs` | `CoreIcons.bsShield` |
| BoxIcons | `box` | `CoreIcons.boxHeart` |
| FontAwesome Solid | `fa` | `CoreIcons.faHome` |
| FontAwesome Brand | `fa` | `CoreIcons.faGoogle` |
| IonIcons | `ion` | `CoreIcons.ionShield` |
| LineAwesome | `line` | `CoreIcons.lineHeart` |
| EvaIcons | `eva` | `CoreIcons.evaShield` |

---

## 📚 Referências

- [icons_plus no pub.dev](https://pub.dev/packages/icons_plus)
- [carousel_slider no pub.dev](https://pub.dev/packages/carousel_slider)

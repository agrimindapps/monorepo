// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'promo/call_to_action.dart';
import 'promo/categories_section.dart';
import 'promo/faq_section.dart';
import 'promo/footer_section.dart';
import 'promo/header_section.dart';
import 'promo/how_it_works.dart';
import 'promo/navigation_bar.dart';
import 'promo/statistics_section.dart';
import 'promo/testimonials_section.dart';

class CalculeiPromoPage extends StatefulWidget {
  const CalculeiPromoPage({super.key});

  @override
  State<CalculeiPromoPage> createState() => _CalculeiPromoPageState();
}

class _CalculeiPromoPageState extends State<CalculeiPromoPage> {
  // Variável de controle para exibição do modo "Em breve"
  final bool _isAppReleased = false; // Altere para 'true' após o lançamento

  // Lista de categorias de calculadoras
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.attach_money,
      'title': 'Finanças',
      'description': 'Calcule juros, investimentos, empréstimos e muito mais.',
      'color': const Color(0xFF4CAF50),
    },
    {
      'icon': Icons.health_and_safety,
      'title': 'Saúde',
      'description':
          'IMC, calorias, dosagem de medicamentos e outros cálculos importantes.',
      'color': const Color(0xFF2196F3),
    },
    {
      'icon': Icons.agriculture,
      'title': 'Agronomia',
      'description':
          'Calcule área de plantio, fertilizantes, produtividade e conversões.',
      'color': const Color(0xFF8BC34A),
    },
    {
      'icon': Icons.pets,
      'title': 'Veterinária',
      'description':
          'Dosagem de medicamentos para pets, cálculos de nutrição animal e mais.',
      'color': const Color(0xFFFF9800),
    },
    {
      'icon': Icons.science,
      'title': 'Engenharia',
      'description':
          'Cálculos estruturais, conversão de unidades e fórmulas essenciais.',
      'color': const Color(0xFF607D8B),
    },
    {
      'icon': Icons.fitness_center,
      'title': 'Bem-estar',
      'description':
          'Taxa metabólica, consumo de água, macronutrientes e muito mais.',
      'color': const Color(0xFFE91E63),
    },
  ];

  // Lista de depoimentos
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Ana Costa',
      'comment':
          'O Agrimind me ajuda muito no controle financeiro. As calculadoras de juros e investimentos são precisas e fáceis de usar. Perfeito para quem precisa de cálculos rápidos e confiáveis.',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Pedro Santos',
      'comment':
          'Como estudante de agronomia, uso diariamente para calcular proporções de fertilizantes e área de plantio. A interface é intuitiva e os resultados sempre precisos.',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Mariana Lima',
      'comment':
          'As calculadoras de saúde são ótimas! Uso para controlar minha dieta e acompanhar minha evolução física. Recomendo para todos os profissionais de nutrição e educação física.',
      'avatar': Icons.person,
      'rating': 4
    },
    {
      'name': 'Rafael Oliveira',
      'comment':
          'Como engenheiro civil, o Agrimind é uma ferramenta indispensável no meu dia a dia. As calculadoras estruturais e de conversão de unidades economizam muito tempo nos projetos.',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Juliana Mendes',
      'comment':
          'Uso o aplicativo na clínica veterinária para calcular dosagens de medicamentos com segurança. A precisão é fundamental e o Agrimind nunca me decepcionou.',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Carlos Eduardo',
      'comment':
          'Como professor de matemática, recomendo o Calculei para meus alunos. As calculadoras são didáticas e ajudam a compreender melhor os conceitos aplicados na prática.',
      'avatar': Icons.person,
      'rating': 4
    }
  ];

  // Lista de estatísticas do app
  final List<Map<String, dynamic>> _statistics = [
    {
      'value': 'Em breve',
      'label': 'Calculadoras Profissionais',
      'icon': Icons.calculate
    },
    {
      'value': 'Em breve',
      'label': 'Categorias Especializadas',
      'icon': Icons.category
    },
    {
      'value': 'Em breve',
      'label': 'Disponibilidade Offline',
      'icon': Icons.access_time
    },
    {
      'value': 'Em breve',
      'label': 'Precisão nos Cálculos',
      'icon': Icons.verified
    },
    {
      'value': 'Em breve',
      'label': 'Formatos de Exportação',
      'icon': Icons.file_download
    },
    {
      'value': '2025',
      'label': 'Ano de Lançamento',
      'icon': Icons.rocket_launch
    },
  ];

  // Lista de perguntas frequentes
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'O aplicativo funciona offline?',
      'answer':
          'Sim! Após o download inicial, todas as calculadoras funcionam sem conexão com internet. Isso permite que você utilize o Calculei em qualquer lugar, mesmo sem acesso à rede.'
    },
    {
      'question': 'É possível salvar os resultados dos cálculos?',
      'answer':
          'Sim, o Calculei permite salvar o histórico de cálculos, exportar resultados e compartilhar via WhatsApp, e-mail ou outras plataformas. Você pode criar relatórios personalizados e manter um registro de todos os seus cálculos para consultas futuras.'
    },
    {
      'question': 'Como sugerir uma nova calculadora?',
      'answer':
          'Dentro do app, acesse o menu "Sugestões" e envie sua ideia. Nossa equipe analisa todas as sugestões e novas calculadoras são adicionadas mensalmente com base nas necessidades dos usuários. Valorizamos muito o feedback da nossa comunidade!'
    },
    {
      'question': 'O aplicativo é gratuito?',
      'answer':
          'O Calculei oferece uma versão gratuita com muitas calculadoras e uma versão premium com recursos avançados. Na versão gratuita, você já tem acesso a dezenas de calculadoras essenciais, enquanto a versão premium remove anúncios e libera todas as calculadoras especializadas por um preço acessível.'
    },
    {
      'question': 'Em quais plataformas o Calculei está disponível?',
      'answer':
          'O aplicativo Calculei estará disponível para dispositivos Android e iOS a partir do lançamento oficial em 01 de agosto de 2025. Estamos trabalhando também em uma versão web que permitirá acessar as calculadoras diretamente pelo navegador.'
    },
    {
      'question': 'Como funciona o modo profissional do aplicativo?',
      'answer':
          'O modo profissional é um conjunto de recursos avançados destinados a profissionais que utilizam cálculos específicos no dia a dia. Ele inclui calculadoras exclusivas para cada área (Engenharia, Finanças, Agricultura, etc.), exportação de dados em formatos profissionais (PDF, Excel) e sincronização com outros softwares do mercado.'
    },
    {
      'question': 'Existe algum limite de cálculos que posso realizar?',
      'answer':
          'Não há limites para a quantidade de cálculos que você pode realizar no Calculei. Na versão gratuita, algumas calculadoras avançadas podem ter limitações de funcionalidades, mas não de quantidade de uso. Na versão premium, você tem acesso ilimitado a todas as ferramentas sem restrições.'
    },
    {
      'question': 'O aplicativo recebe atualizações frequentes?',
      'answer':
          'Sim, o Calculei é constantemente atualizado com novos recursos, calculadoras e melhorias de desempenho. Lançamos atualizações mensais para garantir que nossos usuários tenham sempre as melhores ferramentas e fórmulas mais atualizadas. Todas as atualizações serão gratuitas para usuários existentes.'
    },
    {
      'question': 'Posso utilizar o Calculei para fins educacionais?',
      'answer':
          'Absolutamente! O Calculei é uma ferramenta excelente para fins educacionais. Professores e instituições de ensino podem solicitar licenças especiais para uso em sala de aula. O aplicativo inclui explicações detalhadas sobre as fórmulas utilizadas, o que o torna um ótimo recurso de aprendizado.'
    },
    {
      'question': 'Como o Calculei protege meus dados pessoais?',
      'answer':
          'A privacidade dos usuários é uma prioridade para nós. O Calculei armazena seus dados localmente em seu dispositivo sempre que possível. Quando há necessidade de sincronização com a nuvem, utilizamos criptografia de ponta a ponta para garantir a segurança das suas informações. Não compartilhamos seus dados com terceiros sem sua autorização explícita.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    // Forçar orientação retrato para melhor experiência
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // Background com gradiente moderno e animado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9), // Verde muito claro
                  Colors.white,
                  Color(0xFFE3F2FD), // Azul muito claro
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomPaint(
              painter: _BackgroundPatternPainter(),
              child: Container(), // Container vazio para ocupar espaço
            ),
          ),

          // Conteúdo principal com rolagem
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espaço para compensar a barra de navegação
                SizedBox(height: AppBar().preferredSize.height + 40),

                // Header com logo e chamada principal
                const HeaderSection(),

                // Categorias de calculadoras
                CategoriesSection(categories: _categories),

                // Como o app funciona
                const HowItWorksSection(),

                // Depoimentos - Exibido independentemente do lançamento do app
                TestimonialsSection(testimonials: _testimonials),

                // Estatísticas do app - Exibido independentemente do lançamento do app
                StatisticsSection(statistics: _statistics),

                // FAQ - Exibido independentemente do lançamento do app
                FAQSection(faqs: _faqs),

                // Call to Action
                const CallToActionSection(),

                // Footer
                const FooterSection(),
              ],
            ),
          ),

          // Barra de navegação fixa no topo
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PromoNavigationBar(),
          ),
        ],
      ),
    );
  }
}

// Pintura personalizada para o padrão de fundo
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Desenhar linhas diagonais finas
    for (double i = 0; i <= size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
      canvas.drawLine(Offset(size.width - i, 0), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

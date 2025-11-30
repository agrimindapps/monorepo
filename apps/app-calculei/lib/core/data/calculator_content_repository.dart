import '../models/calculator_content.dart';

/// Repository for calculator educational content
class CalculatorContentRepository {
  static final Map<String, CalculatorContent> _content = {
    '/calculators/financial/vacation': const CalculatorContent(
      calculatorRoute: '/calculators/financial/vacation',
      about: AboutSection(
        title: 'Como calcular suas férias',
        description:
            'A calculadora de férias ajuda você a entender quanto vai receber durante o período de descanso. O cálculo considera seu salário, dias de férias e o adicional de 1/3 constitucional.',
        steps: [
          HowToStep(
            number: 1,
            title: 'Informe seu salário bruto',
            description:
                'Digite o valor do seu salário mensal antes dos descontos (INSS, IR, etc).',
          ),
          HowToStep(
            number: 2,
            title: 'Selecione os dias de férias',
            description:
                'Escolha quantos dias de férias você vai tirar (geralmente 30 dias).',
          ),
          HowToStep(
            number: 3,
            title: 'Adicione dias vendidos (opcional)',
            description:
                'Se você vendeu parte das férias, informe quantos dias foram vendidos.',
          ),
          HowToStep(
            number: 4,
            title: 'Veja o resultado',
            description:
                'O sistema calculará o valor bruto, descontos e líquido que você receberá.',
          ),
        ],
        tips: [
          'Você pode vender até 1/3 (10 dias) das suas férias',
          'O adicional de 1/3 é garantido pela Constituição',
          'Férias vendidas são tributadas normalmente',
          'Consulte sempre o RH da sua empresa para confirmar valores',
        ],
      ),
      faq: [
        FAQItem(
          question: 'O que é o adicional de 1/3?',
          answer:
              'É um valor extra garantido pela Constituição Federal. Corresponde a 1/3 do seu salário e é pago junto com as férias para ajudar nas despesas do período.',
        ),
        FAQItem(
          question: 'Posso vender minhas férias?',
          answer:
              'Sim, você pode vender até 1/3 do período de férias (10 dias em férias de 30 dias). O valor dos dias vendidos é pago junto com o salário.',
        ),
        FAQItem(
          question: 'Quando devo receber o pagamento das férias?',
          answer:
              'O pagamento deve ser feito até 2 dias antes do início das férias, conforme a CLT (Consolidação das Leis do Trabalho).',
        ),
        FAQItem(
          question: 'Há desconto de INSS e IR nas férias?',
          answer:
              'Sim, os descontos de INSS e Imposto de Renda são aplicados normalmente sobre o valor das férias, incluindo o adicional de 1/3.',
        ),
        FAQItem(
          question: 'Posso parcelar minhas férias?',
          answer:
              'Sim, desde 2017 é possível dividir as férias em até 3 períodos, sendo que um deles deve ter pelo menos 14 dias e os demais não podem ser inferiores a 5 dias.',
        ),
      ],
      related: [
        RelatedCalculator(
          title: '13º Salário',
          description: 'Calcule quanto você vai receber de 13º salário',
          route: '/calculators/financial/thirteenth-salary',
        ),
        RelatedCalculator(
          title: 'Salário Líquido',
          description: 'Descubra seu salário após todos os descontos',
          route: '/calculators/financial/net-salary',
        ),
        RelatedCalculator(
          title: 'Horas Extras',
          description: 'Calcule o valor das suas horas extras',
          route: '/calculators/financial/overtime',
        ),
      ],
    ),
    '/calculators/financial/thirteenth-salary': const CalculatorContent(
      calculatorRoute: '/calculators/financial/thirteenth-salary',
      about: AboutSection(
        title: 'Como calcular o 13º salário',
        description:
            'O 13º salário é um direito dos trabalhadores brasileiros. Corresponde a 1/12 do salário por mês trabalhado no ano. Veja como calcular o valor que você vai receber.',
        steps: [
          HowToStep(
            number: 1,
            title: 'Informe seu salário bruto',
            description: 'Digite o valor do seu salário mensal atual.',
          ),
          HowToStep(
            number: 2,
            title: 'Informe os meses trabalhados',
            description:
                'Digite quantos meses você trabalhou no ano (máximo 12).',
          ),
          HowToStep(
            number: 3,
            title: 'Veja o resultado',
            description:
                'O sistema mostrará o valor bruto, descontos e líquido do seu 13º.',
          ),
        ],
        tips: [
          'O 13º é pago em duas parcelas: até 30/11 e 20/12',
          'A primeira parcela não tem descontos',
          'A segunda parcela tem desconto de INSS e IR',
          'Cada mês com 15 dias ou mais conta como mês completo',
        ],
      ),
      faq: [
        FAQItem(
          question: 'Quando o 13º salário é pago?',
          answer:
              'A primeira parcela deve ser paga entre 1º de fevereiro e 30 de novembro. A segunda parcela deve ser paga até 20 de dezembro.',
        ),
        FAQItem(
          question: 'Como funciona o cálculo por meses trabalhados?',
          answer:
              'Você recebe 1/12 do salário por mês trabalhado. Se trabalhou 6 meses, recebe 6/12 (metade) do salário como 13º.',
        ),
        FAQItem(
          question: 'Há descontos no 13º salário?',
          answer:
              'Sim, na segunda parcela são descontados INSS e Imposto de Renda, quando aplicável.',
        ),
      ],
      related: [
        RelatedCalculator(
          title: 'Férias',
          description: 'Calcule o valor das suas férias',
          route: '/calculators/financial/vacation',
        ),
        RelatedCalculator(
          title: 'Salário Líquido',
          description: 'Veja seu salário após descontos',
          route: '/calculators/financial/net-salary',
        ),
      ],
    ),
    '/calculators/financial/net-salary': const CalculatorContent(
      calculatorRoute: '/calculators/financial/net-salary',
      about: AboutSection(
        title: 'Como calcular o salário líquido',
        description:
            'Entenda quanto você realmente recebe após todos os descontos obrigatórios como INSS, Imposto de Renda e outros.',
        steps: [
          HowToStep(
            number: 1,
            title: 'Informe seu salário bruto',
            description: 'Digite o valor acordado no seu contrato de trabalho.',
          ),
          HowToStep(
            number: 2,
            title: 'Adicione outros descontos',
            description:
                'Inclua descontos como vale-transporte, plano de saúde, etc.',
          ),
          HowToStep(
            number: 3,
            title: 'Veja os descontos detalhados',
            description:
                'O sistema mostrará INSS, IR e o valor líquido final.',
          ),
        ],
        tips: [
          'O INSS é calculado por faixas progressivas',
          'O IR considera dependentes e deduções',
          'Vale-transporte tem desconto máximo de 6%',
          'Salários até o teto do INSS são totalmente tributados',
        ],
      ),
      faq: [
        FAQItem(
          question: 'Quais são os principais descontos?',
          answer:
              'INSS (7,5% a 14%), Imposto de Renda (até 27,5%), vale-transporte (até 6%), plano de saúde e outros benefícios opcionais.',
        ),
        FAQItem(
          question: 'Como funciona o desconto do INSS?',
          answer:
              'O INSS é progressivo por faixas. Cada faixa salarial tem uma alíquota diferente, variando de 7,5% a 14%.',
        ),
      ],
      related: [
        RelatedCalculator(
          title: 'INSS Detalhado',
          description: 'Veja apenas o cálculo do INSS',
          route: '/calculators/financial/net-salary',
        ),
      ],
    ),
  };

  /// Get content for a calculator by route
  static CalculatorContent? getContent(String route) {
    return _content[route];
  }

  /// Check if content exists for a route
  static bool hasContent(String route) {
    return _content.containsKey(route);
  }

  /// Get all available content routes
  static List<String> getAvailableRoutes() {
    return _content.keys.toList();
  }
}

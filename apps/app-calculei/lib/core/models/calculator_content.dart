/// Educational content for calculators
class CalculatorContent {
  final String calculatorRoute;
  final AboutSection about;
  final List<FAQItem> faq;
  final List<RelatedCalculator> related;

  const CalculatorContent({
    required this.calculatorRoute,
    required this.about,
    required this.faq,
    required this.related,
  });
}

/// About section content
class AboutSection {
  final String title;
  final String description;
  final List<HowToStep> steps;
  final List<String> tips;

  const AboutSection({
    required this.title,
    required this.description,
    required this.steps,
    this.tips = const [],
  });
}

/// How-to step
class HowToStep {
  final int number;
  final String title;
  final String description;

  const HowToStep({
    required this.number,
    required this.title,
    required this.description,
  });
}

/// FAQ item
class FAQItem {
  final String question;
  final String answer;

  const FAQItem({
    required this.question,
    required this.answer,
  });
}

/// Related calculator reference
class RelatedCalculator {
  final String title;
  final String description;
  final String route;

  const RelatedCalculator({
    required this.title,
    required this.description,
    required this.route,
  });
}

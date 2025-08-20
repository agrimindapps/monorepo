class AppInfo {
  final String version;
  final String buildNumber;
  final String appName;
  final String packageName;
  final DateTime buildDate;
  final String? gitCommit;

  const AppInfo({
    required this.version,
    required this.buildNumber,
    required this.appName,
    required this.packageName,
    required this.buildDate,
    this.gitCommit,
  });

  String get formattedVersion => '$version ($buildNumber)';
  String get formattedBuildDate => _formatDate(buildDate);

  String _formatDate(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'appName': appName,
      'packageName': packageName,
      'buildDate': buildDate.toIso8601String(),
      'gitCommit': gitCommit,
    };
  }

  static AppInfo fromJson(Map<String, dynamic> json) {
    return AppInfo(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? '1',
      appName: json['appName'] ?? 'PetiVeti',
      packageName: json['packageName'] ?? 'com.example.petiveti',
      buildDate: json['buildDate'] != null 
          ? DateTime.parse(json['buildDate'])
          : DateTime.now(),
      gitCommit: json['gitCommit'],
    );
  }

  static AppInfo defaultInfo() {
    return AppInfo(
      version: '1.0.0',
      buildNumber: '1',
      appName: 'PetiVeti',
      packageName: 'com.example.petiveti',
      buildDate: DateTime.now(),
    );
  }
}

class LegalDocument {
  final String title;
  final String content;
  final DateTime lastUpdated;
  final String language;

  const LegalDocument({
    required this.title,
    required this.content,
    required this.lastUpdated,
    this.language = 'pt_BR',
  });

  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else {
      return 'Hoje';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'lastUpdated': lastUpdated.toIso8601String(),
      'language': language,
    };
  }

  static LegalDocument fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      language: json['language'] ?? 'pt_BR',
    );
  }
}

class AppInfoRepository {
  static AppInfo getCurrentAppInfo() {
    // Em uma implementação real, esses dados viriam do package_info_plus
    return AppInfo(
      version: '1.0.0',
      buildNumber: '1',
      appName: 'PetiVeti',
      packageName: 'com.example.petiveti',
      buildDate: DateTime(2024, 1, 15),
      gitCommit: 'abc1234',
    );
  }

  static LegalDocument getTermsOfService() {
    return LegalDocument(
      title: 'Termos de Uso',
      content: _getTermsContent(),
      lastUpdated: DateTime(2024, 1, 1),
    );
  }

  static LegalDocument getPrivacyPolicy() {
    return LegalDocument(
      title: 'Política de Privacidade',
      content: _getPrivacyContent(),
      lastUpdated: DateTime(2024, 1, 1),
    );
  }

  static String _getTermsContent() {
    return '''
TERMOS DE USO DO PETIVETI

1. ACEITAÇÃO DOS TERMOS
Ao usar o aplicativo PetiVeti, você concorda com estes termos de uso.

2. DESCRIÇÃO DO SERVIÇO
O PetiVeti é um aplicativo para gestão de informações veterinárias e cuidados com animais de estimação.

3. USO PERMITIDO
- Você pode usar o aplicativo para fins pessoais e profissionais relacionados ao cuidado veterinário
- É proibido usar o aplicativo para atividades ilegais ou não autorizadas

4. PROPRIEDADE INTELECTUAL
Todo o conteúdo do aplicativo é protegido por direitos autorais.

5. LIMITAÇÃO DE RESPONSABILIDADE
O aplicativo é fornecido "como está" sem garantias de qualquer tipo.

6. MODIFICAÇÕES
Estes termos podem ser modificados a qualquer momento.

7. CONTATO
Para dúvidas sobre estes termos, entre em contato conosco.

Última atualização: 01 de Janeiro de 2024
''';
  }

  static String _getPrivacyContent() {
    return '''
POLÍTICA DE PRIVACIDADE DO PETIVETI

1. INFORMAÇÕES COLETADAS
Coletamos apenas as informações necessárias para o funcionamento do aplicativo:
- Dados dos animais cadastrados
- Informações de consultas e tratamentos
- Configurações do aplicativo

2. USO DAS INFORMAÇÕES
Usamos suas informações para:
- Fornecer os serviços do aplicativo
- Melhorar a experiência do usuário
- Enviar notificações relevantes

3. COMPARTILHAMENTO DE DADOS
Não compartilhamos seus dados pessoais com terceiros sem seu consentimento.

4. SEGURANÇA
Implementamos medidas de segurança para proteger suas informações.

5. SEUS DIREITOS
Você tem direito de:
- Acessar seus dados
- Corrigir informações incorretas
- Solicitar a exclusão de dados

6. ARMAZENAMENTO LOCAL
Os dados são armazenados localmente em seu dispositivo.

7. CONTATO
Para questões sobre privacidade, entre em contato conosco.

Última atualização: 01 de Janeiro de 2024
''';
  }

  static Map<String, String> getSystemInfo() {
    return {
      'Plataforma': 'Flutter',
      'Versão do Dart': '3.0+',
      'Banco de Dados': 'Hive',
      'Arquitetura': 'MVC',
      'Estado': 'ChangeNotifier',
    };
  }

  static List<Map<String, String>> getDevelopmentTeam() {
    return [
      {
        'nome': 'Equipe PetiVeti',
        'cargo': 'Desenvolvimento',
        'email': 'dev@petiveti.com',
      },
    ];
  }

  static Map<String, String> getLibraries() {
    return {
      'Flutter': 'Framework de UI',
      'Hive': 'Banco de dados local',
      'GetX': 'Gerenciamento de estado',
      'Provider': 'Injeção de dependência',
      'Material Icons': 'Ícones',
    };
  }

  static String getAttributions() {
    return '''
ATRIBUIÇÕES E CRÉDITOS

Este aplicativo utiliza as seguintes bibliotecas e recursos:

• Flutter - Framework de desenvolvimento
• Hive - Banco de dados local
• Material Design Icons - Ícones da interface
• GetX - Gerenciamento de navegação
• Provider - Padrão de injeção de dependência

Agradecimentos especiais:
• Comunidade Flutter
• Desenvolvedores das bibliotecas utilizadas
• Beta testers e usuários

Para mais informações sobre licenças de terceiros, 
consulte os arquivos de licença incluídos no aplicativo.
''';
  }

  static bool isDebugMode() {
    // Em uma implementação real, verificaria kDebugMode
    return false;
  }

  static String getEnvironment() {
    return isDebugMode() ? 'Desenvolvimento' : 'Produção';
  }

  static Map<String, dynamic> getDebugInfo() {
    return {
      'isDebug': isDebugMode(),
      'environment': getEnvironment(),
      'timestamp': DateTime.now().toIso8601String(),
      'systemInfo': getSystemInfo(),
    };
  }
}
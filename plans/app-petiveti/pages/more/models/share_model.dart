enum ShareType {
  text('text', 'Texto'),
  link('link', 'Link'),
  textWithLink('text_with_link', 'Texto com Link'),
  file('file', 'Arquivo'),
  image('image', 'Imagem');

  const ShareType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum SharePlatform {
  generic('generic', 'Genérico'),
  whatsapp('whatsapp', 'WhatsApp'),
  telegram('telegram', 'Telegram'),
  email('email', 'Email'),
  sms('sms', 'SMS'),
  social('social', 'Redes Sociais');

  const SharePlatform(this.id, this.displayName);
  final String id;
  final String displayName;
}

class ShareContent {
  final String id;
  final String title;
  final String text;
  final String? subject;
  final String? url;
  final ShareType type;
  final SharePlatform? preferredPlatform;
  final Map<String, String>? customTexts;
  final bool isTemplate;

  const ShareContent({
    required this.id,
    required this.title,
    required this.text,
    this.subject,
    this.url,
    required this.type,
    this.preferredPlatform,
    this.customTexts,
    this.isTemplate = false,
  });

  ShareContent copyWith({
    String? id,
    String? title,
    String? text,
    String? subject,
    String? url,
    ShareType? type,
    SharePlatform? preferredPlatform,
    Map<String, String>? customTexts,
    bool? isTemplate,
  }) {
    return ShareContent(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      url: url ?? this.url,
      type: type ?? this.type,
      preferredPlatform: preferredPlatform ?? this.preferredPlatform,
      customTexts: customTexts ?? this.customTexts,
      isTemplate: isTemplate ?? this.isTemplate,
    );
  }

  String get fullText {
    if (type == ShareType.textWithLink && url != null) {
      return '$text $url';
    }
    return text;
  }

  String getTextForPlatform(SharePlatform platform) {
    if (customTexts != null && customTexts!.containsKey(platform.id)) {
      return customTexts![platform.id]!;
    }
    return fullText;
  }

  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasSubject => subject != null && subject!.isNotEmpty;
  bool get hasCustomTexts => customTexts != null && customTexts!.isNotEmpty;
  String get typeDisplayName => type.displayName;
  String? get platformDisplayName => preferredPlatform?.displayName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'subject': subject,
      'url': url,
      'type': type.id,
      'preferredPlatform': preferredPlatform?.id,
      'customTexts': customTexts,
      'isTemplate': isTemplate,
    };
  }

  static ShareContent fromJson(Map<String, dynamic> json) {
    return ShareContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      subject: json['subject'],
      url: json['url'],
      type: _getShareTypeById(json['type'] ?? 'text'),
      preferredPlatform: json['preferredPlatform'] != null 
          ? _getSharePlatformById(json['preferredPlatform'])
          : null,
      customTexts: json['customTexts'] != null 
          ? Map<String, String>.from(json['customTexts'])
          : null,
      isTemplate: json['isTemplate'] ?? false,
    );
  }

  static ShareType _getShareTypeById(String id) {
    return ShareType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => ShareType.text,
    );
  }

  static SharePlatform _getSharePlatformById(String id) {
    return SharePlatform.values.firstWhere(
      (platform) => platform.id == id,
      orElse: () => SharePlatform.generic,
    );
  }

  @override
  String toString() {
    return 'ShareContent(id: $id, title: $title, type: ${type.id})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareContent &&
        other.id == id &&
        other.title == title &&
        other.text == text &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, text, type);
  }
}

class ShareAction {
  final String id;
  final String contentId;
  final SharePlatform platform;
  final DateTime timestamp;
  final bool success;
  final String? error;

  const ShareAction({
    required this.id,
    required this.contentId,
    required this.platform,
    required this.timestamp,
    this.success = true,
    this.error,
  });

  ShareAction copyWith({
    String? id,
    String? contentId,
    SharePlatform? platform,
    DateTime? timestamp,
    bool? success,
    String? error,
  }) {
    return ShareAction(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      platform: platform ?? this.platform,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null && error!.isNotEmpty;
  String get platformDisplayName => platform.displayName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'platform': platform.id,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error': error,
    };
  }

  static ShareAction fromJson(Map<String, dynamic> json) {
    return ShareAction(
      id: json['id'] ?? '',
      contentId: json['contentId'] ?? '',
      platform: ShareContent._getSharePlatformById(json['platform'] ?? 'generic'),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      success: json['success'] ?? true,
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'ShareAction(id: $id, contentId: $contentId, platform: ${platform.id}, success: $success)';
  }
}

class ShareRepository {
  static List<ShareContent> getDefaultShareContents() {
    return [
      const ShareContent(
        id: 'app_share',
        title: 'Compartilhar App',
        text: 'Experimente o PetiVeti, o aplicativo completo para cuidar da saúde e bem-estar do seu pet!',
        url: 'https://play.google.com/store/apps/details?id=com.petiveti',
        type: ShareType.textWithLink,
        preferredPlatform: SharePlatform.generic,
        customTexts: {
          'whatsapp': '🐾 Olha que app incrível eu encontrei para cuidar dos pets! PetiVeti - o app completo para a saúde e bem-estar do seu pet! 🐕🐱\n\nhttps://play.google.com/store/apps/details?id=com.petiveti',
          'email': 'Recomendo este aplicativo para cuidar da saúde dos seus pets. O PetiVeti oferece recursos completos para o bem-estar animal.',
          'social': '🐾 Descobri o PetiVeti - app completo para cuidar da saúde e bem-estar dos pets! #PetiVeti #Pets #SaudePet',
        },
      ),
      const ShareContent(
        id: 'promo_share',
        title: 'Compartilhar Promoção',
        text: 'Conheça o PetiVeti Premium! Recursos exclusivos para o cuidado completo do seu pet.',
        url: 'https://petiveti.com/premium',
        type: ShareType.textWithLink,
        preferredPlatform: SharePlatform.social,
        customTexts: {
          'whatsapp': '🌟 OFERTA ESPECIAL! PetiVeti Premium com recursos exclusivos para o seu pet! 🐾\n\nDescubra: https://petiveti.com/premium',
          'social': '🌟 PetiVeti Premium - Recursos exclusivos para o cuidado completo do seu pet! #PetiVetiPremium #CuidadoPet',
        },
      ),
      const ShareContent(
        id: 'feedback_share',
        title: 'Compartilhar Feedback',
        text: 'O PetiVeti está me ajudando muito a cuidar do meu pet! Recomendo a todos os tutores.',
        type: ShareType.text,
        preferredPlatform: SharePlatform.social,
        customTexts: {
          'social': '⭐ O PetiVeti está sendo fundamental para cuidar do meu pet! Recomendo para todos os tutores! 🐾 #PetiVeti #Pets #Recomendo',
          'whatsapp': '⭐ Pessoal, estou usando o PetiVeti para cuidar do meu pet e está sendo incrível! Recomendo muito! 🐾',
        },
      ),
    ];
  }

  static ShareContent? getContentById(String id) {
    try {
      return getDefaultShareContents().firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ShareContent> getContentsByType(ShareType type) {
    return getDefaultShareContents()
        .where((content) => content.type == type)
        .toList();
  }

  static List<ShareContent> getContentsByPlatform(SharePlatform platform) {
    return getDefaultShareContents()
        .where((content) => content.preferredPlatform == platform)
        .toList();
  }

  static List<ShareContent> getTemplateContents() {
    return getDefaultShareContents()
        .where((content) => content.isTemplate)
        .toList();
  }

  static List<ShareType> getAvailableTypes() {
    return ShareType.values;
  }

  static List<SharePlatform> getAvailablePlatforms() {
    return SharePlatform.values;
  }

  static String getTypeDisplayName(ShareType type) {
    return type.displayName;
  }

  static String getPlatformDisplayName(SharePlatform platform) {
    return platform.displayName;
  }

  static Map<ShareType, List<ShareContent>> groupByType() {
    final grouped = <ShareType, List<ShareContent>>{};
    
    for (final content in getDefaultShareContents()) {
      grouped.putIfAbsent(content.type, () => []).add(content);
    }
    
    return grouped;
  }

  static Map<SharePlatform, List<ShareContent>> groupByPlatform() {
    final grouped = <SharePlatform, List<ShareContent>>{};
    
    for (final content in getDefaultShareContents()) {
      if (content.preferredPlatform != null) {
        grouped.putIfAbsent(content.preferredPlatform!, () => []).add(content);
      }
    }
    
    return grouped;
  }

  static int getContentCount() {
    return getDefaultShareContents().length;
  }

  static int getTemplateCount() {
    return getTemplateContents().length;
  }

  static Map<String, dynamic> getShareStatistics() {
    final contents = getDefaultShareContents();
    final types = <String, int>{};
    final platforms = <String, int>{};
    
    for (final content in contents) {
      types[content.type.id] = (types[content.type.id] ?? 0) + 1;
      if (content.preferredPlatform != null) {
        platforms[content.preferredPlatform!.id] = (platforms[content.preferredPlatform!.id] ?? 0) + 1;
      }
    }
    
    return {
      'totalContents': contents.length,
      'templateContents': contents.where((c) => c.isTemplate).length,
      'contentsWithUrl': contents.where((c) => c.hasUrl).length,
      'contentsWithCustomTexts': contents.where((c) => c.hasCustomTexts).length,
      'typeCounts': types,
      'platformCounts': platforms,
    };
  }

  static ShareContent createCustomContent({
    required String id,
    required String title,
    required String text,
    String? subject,
    String? url,
    ShareType type = ShareType.text,
    SharePlatform? preferredPlatform,
    Map<String, String>? customTexts,
    bool isTemplate = false,
  }) {
    return ShareContent(
      id: id,
      title: title,
      text: text,
      subject: subject,
      url: url,
      type: type,
      preferredPlatform: preferredPlatform,
      customTexts: customTexts,
      isTemplate: isTemplate,
    );
  }

  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return Uri.tryParse(url) != null;
  }

  static Map<String, String> validateContent(ShareContent content) {
    final errors = <String, String>{};
    
    if (content.id.isEmpty) {
      errors['id'] = 'ID é obrigatório';
    }
    
    if (content.title.isEmpty) {
      errors['title'] = 'Título é obrigatório';
    }
    
    if (content.text.isEmpty) {
      errors['text'] = 'Texto é obrigatório';
    }
    
    if (content.hasUrl && !isValidUrl(content.url)) {
      errors['url'] = 'URL inválida';
    }
    
    return errors;
  }

  static bool hasValidationErrors(ShareContent content) {
    return validateContent(content).isNotEmpty;
  }

  static String generateShareText(ShareContent content, SharePlatform platform) {
    return content.getTextForPlatform(platform);
  }

  static ShareAction createShareAction({
    required String contentId,
    required SharePlatform platform,
    bool success = true,
    String? error,
  }) {
    return ShareAction(
      id: '${contentId}_${platform.id}_${DateTime.now().millisecondsSinceEpoch}',
      contentId: contentId,
      platform: platform,
      timestamp: DateTime.now(),
      success: success,
      error: error,
    );
  }
}
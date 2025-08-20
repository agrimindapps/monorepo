class VersionService {
  static const String currentVersion = '2024.07.14v1';
  
  /// Compara duas versões e retorna:
  /// - 1 se version1 > version2
  /// - 0 se são iguais
  /// - -1 se version1 < version2
  static int compareVersions(String version1, String version2) {
    final v1 = _normalizeVersion(version1);
    final v2 = _normalizeVersion(version2);
    
    final parts1 = _parseVersionParts(v1);
    final parts2 = _parseVersionParts(v2);
    
    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      
      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }
    
    return 0;
  }
  
  static bool isNewerVersion(String version1, String version2) {
    return compareVersions(version1, version2) > 0;
  }
  
  static bool isOlderVersion(String version1, String version2) {
    return compareVersions(version1, version2) < 0;
  }
  
  static bool isSameVersion(String version1, String version2) {
    return compareVersions(version1, version2) == 0;
  }
  
  static String _normalizeVersion(String version) {
    // Remove prefixos como 'v' ou 'V'
    return version.replaceAll(RegExp(r'^[vV]'), '');
  }
  
  static List<int> _parseVersionParts(String version) {
    // Separar por pontos e tentar converter para números
    return version.split('.').map((part) {
      // Extrair apenas números da parte (remover letras como 'v1', 'beta', etc.)
      final match = RegExp(r'\d+').firstMatch(part);
      return match != null ? int.parse(match.group(0)!) : 0;
    }).toList();
  }
  
  static String formatVersion(String version) {
    if (version.isEmpty) return 'Versão desconhecida';
    
    // Adicionar 'v' se não tiver
    if (!version.startsWith('v') && !version.startsWith('V')) {
      return 'v$version';
    }
    
    return version;
  }
  
  static String getVersionType(String version) {
    final normalized = _normalizeVersion(version).toLowerCase();
    
    if (normalized.contains('alpha')) return 'Alpha';
    if (normalized.contains('beta')) return 'Beta';
    if (normalized.contains('rc')) return 'Release Candidate';
    if (normalized.contains('dev')) return 'Desenvolvimento';
    if (normalized.contains('nightly')) return 'Nightly';
    
    return 'Estável';
  }
  
  static bool isStableVersion(String version) {
    return getVersionType(version) == 'Estável';
  }
  
  static bool isPreReleaseVersion(String version) {
    return !isStableVersion(version);
  }
  
  static String extractMajorVersion(String version) {
    final normalized = _normalizeVersion(version);
    final parts = normalized.split('.');
    return parts.isNotEmpty ? parts[0] : '0';
  }
  
  static String extractMinorVersion(String version) {
    final normalized = _normalizeVersion(version);
    final parts = normalized.split('.');
    return parts.length > 1 ? parts[1] : '0';
  }
  
  static String extractPatchVersion(String version) {
    final normalized = _normalizeVersion(version);
    final parts = normalized.split('.');
    return parts.length > 2 ? parts[2] : '0';
  }
  
  static Map<String, String> parseVersionComponents(String version) {
    final normalized = _normalizeVersion(version);
    final parts = normalized.split('.');
    
    return {
      'major': parts.isNotEmpty ? parts[0] : '0',
      'minor': parts.length > 1 ? parts[1] : '0',
      'patch': parts.length > 2 ? parts[2] : '0',
      'type': getVersionType(version),
      'formatted': formatVersion(version),
    };
  }
  
  static List<String> sortVersions(List<String> versions, {bool ascending = false}) {
    final sorted = List<String>.from(versions);
    
    sorted.sort((a, b) {
      final comparison = compareVersions(a, b);
      return ascending ? comparison : -comparison;
    });
    
    return sorted;
  }
  
  static String getLatestVersion(List<String> versions) {
    if (versions.isEmpty) return '';
    
    final sorted = sortVersions(versions, ascending: false);
    return sorted.first;
  }
  
  static String getOldestVersion(List<String> versions) {
    if (versions.isEmpty) return '';
    
    final sorted = sortVersions(versions, ascending: true);
    return sorted.first;
  }
  
  static bool isValidVersion(String version) {
    if (version.isEmpty) return false;
    
    final normalized = _normalizeVersion(version);
    
    // Verificar se tem pelo menos um número
    return RegExp(r'\d+').hasMatch(normalized);
  }
  
  static String incrementVersion(String version, VersionComponent component) {
    final parts = _parseVersionParts(_normalizeVersion(version));
    
    // Garantir que temos pelo menos 3 partes
    while (parts.length < 3) {
      parts.add(0);
    }
    
    switch (component) {
      case VersionComponent.major:
        parts[0]++;
        parts[1] = 0;
        parts[2] = 0;
        break;
      case VersionComponent.minor:
        if (parts.length > 1) {
          parts[1]++;
          parts[2] = 0;
        }
        break;
      case VersionComponent.patch:
        if (parts.length > 2) {
          parts[2]++;
        }
        break;
    }
    
    return 'v${parts.join('.')}';
  }
  
  static Duration getTimeSinceVersion(String version, DateTime releaseDate) {
    return DateTime.now().difference(releaseDate);
  }
  
  static String formatTimeSinceRelease(Duration duration) {
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'dia' : 'dias'} atrás';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else {
      return 'Há poucos minutos';
    }
  }
}

enum VersionComponent {
  major,
  minor,
  patch,
}
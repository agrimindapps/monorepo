/// App store enum
enum Store {
  appStore, // Apple App Store
  playStore, // Google Play Store
  webstore, // Web store
  direct, // Direct purchase (backend)
  unknown; // Unknown store

  bool get isApple => this == Store.appStore;
  bool get isGoogle => this == Store.playStore;
  bool get isDirect => this == Store.direct;

  String get displayName {
    switch (this) {
      case Store.appStore:
        return 'App Store';
      case Store.playStore:
        return 'Play Store';
      case Store.webstore:
        return 'Web Store';
      case Store.direct:
        return 'Direto';
      case Store.unknown:
        return 'Desconhecido';
    }
  }
}
